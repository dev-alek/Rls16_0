&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME PERS-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS PERS-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура выбора персонала смены (например для сменного отчета)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/17/06
Author: Bakhtadze Natalya
Creation date: 03/17/06

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc as widget-handle no-undo .

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER pobj-type like  ub.shift-obj.obj-type no-undo.
DEFINE INPUT PARAMETER pobj-code like  ub.shift-obj.obj-code no-undo.
DEFINE INPUT PARAMETER pshift-date like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num like  ub.shift-obj.shift-num no-undo.
DEFINE INPUT PARAMETER bttns as char no-UNDO.
DEFINE INPUT PARAMETER call-point as char no-UNDO.
/*может быть "" или  {&obj-shift-open} */



/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура выбора персонала смены".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ ref/shftpers.i "NEW SHARED" }
{ gbl/getcntxt.i def }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */

DEFINE BUFFER next-shft-pers for shft-pers.
DEFINE variable add-option as char no-undo.
define variable v-need-rec as recid no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character AS character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-noanshftstaff as logical no-undo .
define variable v-tth as handle no-undo .
define variable v-close as logical no-undo .

define variable par-type as character no-undo .
define variable par-is-cctv as character no-undo .
define variable is-cctv as logical no-undo .

define variable v-vid-action        as integer no-undo .
define variable v-vid-ok            as logical  no-undo .
define variable v-vid-mes           as character no-undo .
define variable v-vid-param         as longchar no-undo .

define variable v-shift-staff-list  as character no-undo .
define variable v-shift-manager     as character no-undo .

define variable conf-par as character no-undo .
define variable v-1C     as logical   no-undo .

DEFINE BUFFER next-shift-obj for shift-obj.
DEFINE BUFFER previous-shift-obj for shift-obj.
DEFINE BUFFER previous-shift-obj2 for shift-obj.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME PERS-Frame
&Scoped-define BROWSE-NAME BR-staff

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES shft-pers next-shft-pers

/* Definitions for BROWSE BR-staff                                      */
&Scoped-define FIELDS-IN-QUERY-BR-staff shft-pers.FIO shft-pers.cashier shft-pers.staff-role shft-pers.psn-code   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-staff shft-pers.FIO ~
shft-pers.cashier   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-staff shft-pers
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-staff shft-pers
&Scoped-define SELF-NAME BR-staff
&Scoped-define QUERY-STRING-BR-staff FOR EACH shft-pers       WHERE shft-pers.next-shift = no SHARE-LOCK     BY shft-pers.staff-role DESCENDING
&Scoped-define OPEN-QUERY-BR-staff OPEN QUERY {&SELF-NAME} FOR EACH shft-pers       WHERE shft-pers.next-shift = no SHARE-LOCK     BY shft-pers.staff-role DESCENDING.
&Scoped-define TABLES-IN-QUERY-BR-staff shft-pers
&Scoped-define FIRST-TABLE-IN-QUERY-BR-staff shft-pers


/* Definitions for BROWSE BR-staff-next                                 */
&Scoped-define FIELDS-IN-QUERY-BR-staff-next next-shft-pers.FIO next-shft-pers.cashier next-shft-pers.staff-role next-shft-pers.psn-code   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-staff-next NEXt-shft-pers.FIO ~
next-shft-pers.cashier   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-staff-next NEXt-shft-pers
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-staff-next NEXt-shft-pers
&Scoped-define SELF-NAME BR-staff-next
&Scoped-define QUERY-STRING-BR-staff-next FOR EACH next-shft-pers       WHERE next-shft-pers.next-shift = yes SHARE-LOCK     BY next-shft-pers.staff-role DESCENDING
&Scoped-define OPEN-QUERY-BR-staff-next OPEN QUERY {&SELF-NAME} FOR EACH next-shft-pers       WHERE next-shft-pers.next-shift = yes SHARE-LOCK     BY next-shft-pers.staff-role DESCENDING.
&Scoped-define TABLES-IN-QUERY-BR-staff-next next-shft-pers
&Scoped-define FIRST-TABLE-IN-QUERY-BR-staff-next next-shft-pers


/* Definitions for DIALOG-BOX PERS-Frame                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-PERS-Frame ~
    ~{&OPEN-QUERY-BR-staff}~
    ~{&OPEN-QUERY-BR-staff-next}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RECT-1 RECT-2 B-add ~
B-del B-chg B-mng BR-staff B-add-next B-del-next B-chg-next BR-staff-next 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add 
       MENU-ITEM m-add-ref      LABEL "Из справочника"
       MENU-ITEM m-add-blank    LABEL "Произвольно"   .

DEFINE MENU MENU-B-add-next 
       MENU-ITEM m-add-next-ref LABEL "Из справочника"
       MENU-ITEM m-add-next-blank LABEL "Произвольно"   .

DEFINE MENU MENU-BR-staff 
       MENU-ITEM m-br-ref       LABEL "Из справочника"
       MENU-ITEM m-br-blank     LABEL "Произвольно"   .

DEFINE MENU MENU-BR-staff-next 
       MENU-ITEM m-br-next-ref  LABEL "Из справочника"
       MENU-ITEM m-br-next-blank LABEL "Произвольно"   .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add 
     LABEL "Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-add-next 
     LABEL "Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-chg 
     LABEL "Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-chg-next 
     LABEL "Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-del 
     LABEL "Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-del-next 
     LABEL "Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mng 
     LABEL "Менеджер" 
     SIZE 10 BY 1.

DEFINE BUTTON B-mng-next 
     LABEL "Менеджер" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 86.4 BY 9.87.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 86.1 BY 6.53.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-staff FOR 
      shft-pers SCROLLING.

DEFINE QUERY BR-staff-next FOR 
      next-shft-pers SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-staff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-staff PERS-Frame _FREEFORM
  QUERY BR-staff SHARE-LOCK NO-WAIT DISPLAY
      shft-pers.FIO column-label " ФИО"
      shft-pers.cashier column-label "Код!кассира"
      shft-pers.staff-role column-label "Менеджер"
      shft-pers.psn-code COLUMN-LABEL "Код!физ.лица"
      ENABLE
      shft-pers.FIO
      shft-pers.cashier
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 83.8 BY 7.53
         TITLE "Персонал текущей смены".

DEFINE BROWSE BR-staff-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-staff-next PERS-Frame _FREEFORM
  QUERY BR-staff-next SHARE-LOCK NO-WAIT DISPLAY
      next-shft-pers.FIO column-label " ФИО"
      next-shft-pers.cashier column-label "Код!кассира"
      next-shft-pers.staff-role column-label "Менеджер"
      next-shft-pers.psn-code COLUMN-LABEL "Код!физ.лица"
      ENABLE
      NEXt-shft-pers.FIO
      next-shft-pers.cashier
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 84.1 BY 4.17
         TITLE "Персонал принимающей смены".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME PERS-Frame
     B-exit AT ROW 1 COL 1.1
     b-quit AT ROW 1 COL 11.1
     B-Help AT ROW 1 COL 80
     B-add AT ROW 3 COL 3.9
     B-del AT ROW 3 COL 13.9
     B-chg AT ROW 3 COL 23.9
     B-mng AT ROW 3 COL 33.9
     BR-staff AT ROW 4.3 COL 3.6
     B-add-next AT ROW 13.03 COL 3.9
     B-del-next AT ROW 13.03 COL 13.9
     B-chg-next AT ROW 13.03 COL 23.9
     B-mng-next AT ROW 13.03 COL 33.9
     BR-staff-next AT ROW 14.43 COL 3.3
     RECT-1 AT ROW 2.37 COL 2.4
     RECT-2 AT ROW 12.7 COL 2.3
     SPACE(1.72) SKIP(0.39)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Персонал  смены"
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
/* SETTINGS FOR DIALOG-BOX PERS-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-staff B-mng PERS-Frame */
/* BROWSE-TAB BR-staff-next B-mng-next PERS-Frame */
ASSIGN 
       FRAME PERS-Frame:SCROLLABLE       = FALSE
       FRAME PERS-Frame:HIDDEN           = TRUE.

ASSIGN 
       B-add:POPUP-MENU IN FRAME PERS-Frame       = MENU MENU-B-add:HANDLE.

ASSIGN 
       B-add-next:POPUP-MENU IN FRAME PERS-Frame       = MENU MENU-B-add-next:HANDLE.

/* SETTINGS FOR BUTTON B-mng-next IN FRAME PERS-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-mng-next:HIDDEN IN FRAME PERS-Frame           = TRUE.

ASSIGN 
       BR-staff:POPUP-MENU IN FRAME PERS-Frame             = MENU MENU-BR-staff:HANDLE.

ASSIGN 
       BR-staff-next:POPUP-MENU IN FRAME PERS-Frame             = MENU MENU-BR-staff-next:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-staff
/* Query rebuild information for BROWSE BR-staff
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH shft-pers
      WHERE shft-pers.next-shift = no SHARE-LOCK
    BY shft-pers.staff-role DESCENDING.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _OrdList          = "shft-pers.staff-role|no"
     _Where[1]         = "shft-pers.next-shift = no"
     _Query            is OPENED
*/  /* BROWSE BR-staff */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-staff-next
/* Query rebuild information for BROWSE BR-staff-next
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH next-shft-pers
      WHERE next-shft-pers.next-shift = yes SHARE-LOCK
    BY next-shft-pers.staff-role DESCENDING.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _OrdList          = "next-shft-pers.staff-role|no"
     _Where[1]         = "next-shft-pers.next-shift = yes"
     _Query            is OPENED
*/  /* BROWSE BR-staff-next */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME PERS-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PERS-Frame PERS-Frame
ON END-ERROR OF FRAME PERS-Frame /* Персонал  смены */
DO:
  apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PERS-Frame PERS-Frame
ON GO OF FRAME PERS-Frame /* Персонал  смены */
DO:
    IF FOCUS:NAME <> "B-exit" and FOCUS:NAME <> "B-QUIT" THEN DO:
    RETURN NO-APPLY.
    END.
    run fill-db in this-procedure no-error.
    if error-status:error then return no-apply.
   
    for each ub.shift-staff no-lock where ub.shift-staff.obj-type = pobj-type
                                      and ub.shift-staff.obj-code = pobj-code
                                      and ub.shift-staff.shift-num = pshift-num
                                      and ub.shift-staff.shift-date = pshift-date
                                      and ub.shift-staff.next-shift = no :
        if ub.shift-staff.staff-role
        then
        assign
            v-shift-manager = ub.shift-staff.name
        .
        else
        assign
            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
        .    
        run trg/userlog.p (
              input {&nwsdochs_action_update}
            , input {&table_shift-staff}
            , input ( buffer ub.shift-staff :handle )
            , input ?
            , input ""
        ) no-error.
        if error-status :error
        then do:
            undo, return no-apply .
        end.                              
    end.
    
    find first ub.shift-obj no-lock where ub.shift-obj.obj-type = pobj-type
                                      and ub.shift-obj.obj-code = pobj-code
                                      and ub.shift-obj.shift-num = pshift-num
                                      and ub.shift-obj.shift-date = pshift-date .
    
    v-vid-action = 52 .
    v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + {&delim-par} +
                  "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + {&delim-par} +
                  "ShiftManager=" + v-shift-manager + {&delim-par} +
                  "ShiftStaff=" + v-shift-staff-list + {&delim-par} +
                  "RESULT=0" + {&delim-par} + 
                  "Description=".
                  
    run trg/userlog.p (
          input {&nwsdochs_action_update}
        , input {&table_shift-obj}
        , input ( buffer ub.shift-obj :handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.
    if error-status :error
    then do:
        undo, return no-apply .
    end. 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PERS-Frame PERS-Frame
ON stop OF FRAME PERS-Frame /* Персонал  смены */
DO:
    apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PERS-Frame PERS-Frame
ON WINDOW-CLOSE OF FRAME PERS-Frame /* Персонал  смены */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add PERS-Frame
ON CHOOSE OF B-add IN FRAME PERS-Frame /* Добавить */
DO:
  { gbl/stdbtn.i }
  if add-option = "" then
  run gbl/pop-up.p ( input self:handle, input no) no-error.
  if error-status:error then return no-apply.
  run create-pers in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-next PERS-Frame
ON CHOOSE OF B-add-next IN FRAME PERS-Frame /* Добавить */
DO:
  { gbl/stdbtn.i }
  if add-option = "" then
  run gbl/pop-up.p ( input self:handle, input no) no-error.
  run create-pers in this-procedure ( input 1) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg PERS-Frame
ON CHOOSE OF B-chg IN FRAME PERS-Frame /* Изменить */
DO:
   { gbl/stdbtn.i }
    if avail shft-pers then do:
        if shft-pers.psn-code <> ? then do:
            MESSAGE "Нельзя изменить эту запись - она была выбрана из справочника"
            VIEW-AS ALERT-BOX ERROR.
            return no-apply.
        end.
      assign
      shft-pers.fio:read-only in browse br-staff = false
      shft-pers.cashier:read-only in browse br-staff = false
      .
      APPLY "ENTRY" to shft-pers.fio in browse br-staff.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg-next PERS-Frame
ON CHOOSE OF B-chg-next IN FRAME PERS-Frame /* Изменить */
DO:
   { gbl/stdbtn.i }
    if avail next-shft-pers then do:
        if next-shft-pers.psn-code <> ? then do:
            MESSAGE "Нельзя изменить эту запись - она была выбрана из справочника"
            VIEW-AS ALERT-BOX ERROR.
            return no-apply.
        end.
      assign
      next-shft-pers.fio:read-only in browse br-staff-next = false
      next-shft-pers.cashier:read-only in browse br-staff-next = false
      .
      APPLY "ENTRY" to br-staff-next.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del PERS-Frame
ON CHOOSE OF B-del IN FRAME PERS-Frame /* Удалить */
DO:
  { gbl/stdbtn.i }
  run delete-pers  in this-procedure ( input 0, buffer shft-pers) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-next PERS-Frame
ON CHOOSE OF B-del-next IN FRAME PERS-Frame /* Удалить */
DO:
  { gbl/stdbtn.i }
  run delete-pers  in this-procedure ( input 1, buffer next-shft-pers) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit PERS-Frame
ON CHOOSE OF B-exit IN FRAME PERS-Frame /* Ввод */
DO:
    { gbl/stdbtn.i }
    if v-1C
    then do :
      find first shft-pers no-lock where shft-pers.next-shift = no
                                     and shft-pers.psn-code <> -1
                                     no-error .
      if not available shft-pers
      then do :
        message "Включен обмен с 1С. Ввод персонала смены обязателен." view-as alert-box .
        return no-apply .
      end .                                  
    end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit PERS-Frame
ON CHOOSE OF B-quit IN FRAME PERS-Frame /* Отмена */
DO:
    { gbl/stdbtn.i }
    if v-1C
    then do :
      find first ub.shift-staff no-lock where ub.shift-staff.obj-type = pobj-type
                                          and ub.shift-staff.obj-code = pobj-code
                                          and ub.shift-staff.shift-num = pshift-num
                                          and ub.shift-staff.shift-date = pshift-date
                                          and ub.shift-staff.next-shift = no
                                          no-error .
      if not available ub.shift-staff
      then do :                                    
        message "Включен обмен с 1С. Ввод персонала смены обязателен." view-as alert-box .
        return no-apply .
      end .
    end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mng
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mng PERS-Frame
ON CHOOSE OF B-mng IN FRAME PERS-Frame /* Менеджер */
DO:
  { gbl/stdbtn.i }
  run mng-pers  in this-procedure ( input 0, buffer shft-pers) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mng-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mng-next PERS-Frame
ON CHOOSE OF B-mng-next IN FRAME PERS-Frame /* Менеджер */
DO:
  { gbl/stdbtn.i }
  run mng-pers  in this-procedure ( input 1, buffer next-shft-pers) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-staff
&Scoped-define SELF-NAME BR-staff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-staff PERS-Frame
ON + OF BR-staff IN FRAME PERS-Frame /* Персонал текущей смены */
DO:
  run mng-pers  in this-procedure ( input 0, buffer shft-pers) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-staff PERS-Frame
ON DELETE-CHARACTER OF BR-staff IN FRAME PERS-Frame /* Персонал текущей смены */
DO:
  IF lookup("b-add", bttns) = 0 then return no-apply.
  run delete-pers  in this-procedure ( input 0, buffer shft-pers) no-error.
  if error-status:error then return NO-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-staff PERS-Frame
ON INSERT-MODE OF BR-staff IN FRAME PERS-Frame /* Персонал текущей смены */
DO:
  IF lookup("b-add", bttns) = 0 then return no-apply.
  run gbl/pop-up.p ( input self:handle, input yes) no-error.
  if error-status:error then return no-apply.
  run create-pers  in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-staff PERS-Frame
ON RETURN OF BR-staff IN FRAME PERS-Frame /* Персонал текущей смены */
or mouse-select-dblclick of br-STAFF in frame {&frame-name} DO:
  IF AVAIL SHFT-PERS AND SHFT-PERS.PSN-CODE = ? AND B-add:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
        apply "entry" to br-staff in frame {&frame-name}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-staff PERS-Frame
ON ROW-LEAVE OF BR-staff IN FRAME PERS-Frame /* Персонал текущей смены */
DO:
  run upd-shft-pers in this-procedure no-error.
  if error-status:error then return no-apply.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-staff-next
&Scoped-define SELF-NAME BR-staff-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-staff-next PERS-Frame
ON + OF BR-staff-next IN FRAME PERS-Frame /* Персонал принимающей смены */
DO:
  run mng-pers  in this-procedure ( input 1, buffer next-shft-pers) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-staff-next PERS-Frame
ON DELETE-CHARACTER OF BR-staff-next IN FRAME PERS-Frame /* Персонал принимающей смены */
DO:
  IF lookup("b-add-next", bttns) = 0 then return no-apply.
  run delete-pers  in this-procedure ( input 1, buffer next-shft-pers) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-staff-next PERS-Frame
ON INSERT-MODE OF BR-staff-next IN FRAME PERS-Frame /* Персонал принимающей смены */
DO:
  IF lookup("b-add-next", bttns) = 0 then return no-apply.
  run gbl/pop-up.p ( input self:handle, input yes) no-error.
  if error-status:error then return no-apply.
  run create-pers in this-procedure ( input 1) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-staff-next PERS-Frame
ON RETURN OF BR-staff-next IN FRAME PERS-Frame /* Персонал принимающей смены */
or mouse-select-dblclick of br-STAFF-next in frame {&frame-name} DO:
  IF AVAIL NEXT-SHFT-PERS AND NEXT-SHFT-PERS.PSN-CODE = ? AND B-add-NEXT:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
        apply "entry" to br-staff-NEXT in frame {&frame-name}.
  END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-add-blank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-add-blank PERS-Frame
ON CHOOSE OF MENU-ITEM m-add-blank /* Произвольно */
DO:
  add-option = "blank":U.
  run create-pers in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-add-next-blank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-add-next-blank PERS-Frame
ON CHOOSE OF MENU-ITEM m-add-next-blank /* Произвольно */
DO:
    add-option = "blank":U.
    run create-pers in this-procedure ( input 1) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-add-next-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-add-next-ref PERS-Frame
ON CHOOSE OF MENU-ITEM m-add-next-ref /* Из справочника */
DO:
    add-option = "ref":U.
    run create-pers in this-procedure ( input 1) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-add-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-add-ref PERS-Frame
ON CHOOSE OF MENU-ITEM m-add-ref /* Из справочника */
DO:
    add-option = "ref":U.
  run create-pers in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-br-blank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-br-blank PERS-Frame
ON CHOOSE OF MENU-ITEM m-br-blank /* Произвольно */
DO:
  add-option = "blank":U.
  run create-pers in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-br-next-blank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-br-next-blank PERS-Frame
ON CHOOSE OF MENU-ITEM m-br-next-blank /* Произвольно */
DO:
    add-option = "blank":U.
    run create-pers in this-procedure ( input 1) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-br-next-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-br-next-ref PERS-Frame
ON CHOOSE OF MENU-ITEM m-br-next-ref /* Из справочника */
DO:
    add-option = "ref":U.
    run create-pers in this-procedure ( input 1) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-br-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-br-ref PERS-Frame
ON CHOOSE OF MENU-ITEM m-br-ref /* Из справочника */
DO:
    add-option = "ref":U.
    run create-pers in this-procedure ( input 0) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-staff
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK PERS-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

on end-error of SHFT-PERS.FIO, SHFT-PERS.CASHIER In browse br-STAFF do:
  disp SHFT-PERS.FIO SHFT-PERS.CASHIER with browse br-STAFF.
  return no-apply.
end.

on end-error of NEXT-SHFT-PERS.FIO, NEXT-SHFT-PERS.CASHIER In browse br-STAFF-NEXT do:
  disp NEXT-SHFT-PERS.FIO NEXT-SHFT-PERS.CASHIER with browse br-STAFF-NEXT.
  return no-apply.
end.


On RETURN OF shft-pers.cashier in browse br-staff
OR RETURN OF shft-pers.FIO in browse br-staff
OR TAB OF shft-pers.cashier in browse br-staff
DO:
  run upd-shft-pers in this-procedure no-error.
  if error-status:error then return no-apply.
  return no-apply.
end.


On RETURN OF next-shft-pers.cashier in browse br-staff-next
OR RETURN OF next-shft-pers.FIO in browse br-staff-next
OR TAB OF next-shft-pers.cashier in browse br-staff-next
DO:
  run upd-NEXT-shft-pers in this-procedure no-error.
  if error-status:error then return no-apply.
 return no-apply.
end.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  FIND FIRST ub.shift-obj SHARE-LOCK WHERE
             ub.shift-obj.obj-type = pobj-type AND
             ub.shift-obj.obj-code = pobj-code AND
             ub.shift-obj.shift-num = pshift-num AND
             ub.shift-obj.shift-date = pshift-date NO-ERROR.
  IF NOT AVAIL shift-obj then do:
    message
    vss-workfile vss-revision vss-description skip
    "Отсутствует запись о смене на объекте" skip
    "объект" pobj-type pobj-code
    "смена" pshift-date "порядок" pshift-num
    view-as alert-box ERROR.
    return error.
  END.
  IF call-point = {&obj-shift-open} then do:
    /*при открытии смены мы должны по умолчанию поставить менеджера из предыдущей*/
    /*но если смена была открыта ожидаемой то могли переустановить персонал      */
    /*тогда по умолчанию из предыдущей не устанавливаем                          */
    if can-find(first ub.shift-staff no-lock where
                      ub.shift-staff.obj-type = pobj-type AND
                      ub.shift-staff.obj-code = pobj-code AND
                      ub.shift-staff.shift-num = pshift-num AND
                      ub.shift-staff.shift-date = pshift-date) then
    call-point = "".
    else do:
      FIND LAST  previous-shift-obj SHARE-LOCK WHERE
                previous-shift-obj.obj-type = pobj-type
            AND previous-shift-obj.obj-code = pobj-code
            AND (previous-shift-obj.shift-date = pshift-date
            AND previous-shift-obj.shift-num < pshift-num) use-index pi no-error.

      FIND LAST  previous-shift-obj2 SHARE-LOCK WHERE
                previous-shift-obj2.obj-type = pobj-type
            AND previous-shift-obj2.obj-code = pobj-code
            AND previous-shift-obj2.shift-date < pshift-date use-index pi no-error.
      v-need-rec = ?.
      if available previous-shift-obj then do:
        v-need-rec = recid(previous-shift-obj).
      end.
      else do:
        if available previous-shift-obj2 then do:
          v-need-rec = recid(previous-shift-obj2).
        end.
      end.
      if v-need-rec <> ? then do:
        find first previous-shift-obj where recid(previous-shift-obj) = v-need-rec.
      end.
    end.
  end.
  FIND first next-shift-obj NO-LOCK WHERE
             recid(next-shift-obj) = recid(shift-obj) NO-ERROR.
  FIND NEXT  next-shift-obj SHARE-LOCK WHERE
             next-shift-obj.obj-type = pobj-type AND
             next-shift-obj.obj-code = pobj-code
                use-index pi NO-ERROR.
  /*если следующая смена ожидаемая то она не должна влиять на персонал*/
  if avail next-shift-obj then do:
    if next-shift-obj.status_ = {&sht-expected} then release next-shift-obj. 
    else if next-shift-obj.status_ = {&sht-closed} or next-shift-obj.status_ = {&sht-current} then
    bttns = replace(bttns, "b-add-next", "").
  end.
  run adm/shattri.p (
    input "get":U
    ,input  pobj-type
    ,input  pobj-code
    ,input  {&attr-staff-options}
    ,input  {&attr-staff-options_noanshftstaff} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-noanshftstaff
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .

  delete object v-tth no-error.

  { gbl/conf-rd.i
       "'is-erpRN'"
       0
       "''"
       0
       "''"
       "''"
       "''"
       NO
       conf-par
       par-type
       no-error
  }
  IF not error-status:error and conf-par = "yes":U 
  then do: 
    v-1C = true .
  end .
  else do :
    v-1C = false .
  end .

  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Create-pers PERS-Frame 
PROCEDURE Create-pers :
DEFINE INPUT PARAMETER pnext-shift as logical no-undo.
/*вид смены для которой создаем запись no - текущая yes следующая*/
define variable cli-list as char no-undo.
define variable cli-rec as recid no-undo.
define variable ii as integer no-undo.
define variable for-name as char no-undo.
define buffer loc-shft-pers for shft-pers.
define buffer buf_staff for ub.staff.


if add-option = "" then return error.
CASE add-option:
  when "ref":U then do:
    run ref/staffs.w ( input parparentproc
                    , input (if pnext-shift then "b-sel" else "b-sel,b-mark")
                    , input {&role-cashier}
                    , input v-cntxt-db-num
                    , input 0
                    , output cli-list ) .

    if cli-list <> "" then do:
        DO ii = 1 to NUM-ENTRIES(cli-list):
            cli-rec = integer(entry(ii, cli-list)).
            FIND FIRSt buf_staff No-LOCK WHERE
                       recid(buf_staff) = cli-rec No-ERROR.
            if not avail buf_staff then do:
                add-option = "".
                return error substitute("Не найден кассир - recid &1", cli-rec).
            end.
            FIND FIRSt ub.person No-LOCK WHERE
                       ub.person.psn-code  = buf_staff.psn-code No-ERROR.
            if not avail person then do:
                add-option = "".
                return error.
            end.
            FIND FIRSt ub.clients No-LOCK WHERE
                       ub.clients.obj-type = {&prs} AND
                       ub.clients.obj-code = ub.person.psn-code No-ERROR.
            if not avail ub.clients then do:
                add-option = "".
                return error.
            end.
            FIND FIRST loc-shft-pers No-LOCK WHERE
                       loc-shft-pers.psn-code = person.psn-code AND
                       loc-shft-pers.next-shift = pnext-shift No-ERROR.
            if not avail loc-shft-pers then do:
                create loc-shft-pers.
                assign
                loc-shft-pers.FIO = clients.obj-name + {&space-char} +
                                person.name1 + {&space-char} + person.name2
                loc-shft-pers.psn-code = buf_staff.psn-code
                loc-shft-pers.cashier  = buf_staff.staff-code
                loc-shft-pers.next-shift = pnext-shift
                loc-shft-pers.staff-role = if pnext-shift then yes else no
                CLI-REC = RECID(loc-shft-pers)
                .
                RELEASE LOC-SHFT-PERS.
            end.
            else do:
                message substitute("&1 &2 &3 уже входит в состав персонала &4"
                                   , clients.obj-name
                                   , person.name1
                                   , person.name2
                                   , (if NOT pnext-shift
                                    then "передающей смены"
                                    else "принимающей смены"))
                view-as alert-box ERROR.
            end.
        END.
    end.
    else do:
      undo, return error .
    end.
  END. /*when ref*/
  WHEN "blank":U then do:
    if v-noanshftstaff then do:
      message
      "Для данного объекта действует запрет на ввод произвольных данных по персоналу"
      view-as alert-box error .
      undo, return error .
    end.

    run gbl/d-prompt.w (
      'title=':u + "Введите ФИО оператора или старшего по смене" + '\':u
    + 'text1=':u + " ФИО" + '\':u
    + 'format=' + "X(40)" + '\':u
    + 'type=' + {&type-char} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output for-name
    ).
  if return-value = 'false':u then do:
    add-option = "".
    return error.
  end.
    create loc-shft-pers.
    assign
    loc-shft-pers.cashier = 0
    loc-shft-pers.psn-code = ?
    loc-shft-pers.fio = for-name
    loc-shft-pers.next-shift = pnext-shift
    loc-shft-pers.staff-role = if pnext-shift then yes else no
    cli-rec = recid(loc-shft-pers)
    .
    release loc-shft-pers.
    if NOT pnext-shift then do:
      assign
      shft-pers.fio:read-only in browse br-staff = false
      shft-pers.cashier:read-only in browse br-staff = false
      .
    end.
    else do:
      assign
      next-shft-pers.fio:read-only in browse br-staff-next = false
      next-shft-pers.cashier:read-only in browse br-staff-next = false
      .
    end.
    add-option = "".
  END.
END CASE.
    if NOT pnext-shift then do:
        {&OPEN-QUERY-BR-staff}
        reposition br-staff to recid cli-rec no-error.
        apply "entry" to br-staff in frame {&frame-name}.
    end.
    else do:
        {&OPEN-QUERY-BR-staff-next}
        reposition br-staff-next to recid cli-rec no-error.
        DISABLE b-add-next with frame {&frame-name}.
        apply "entry" to br-staff-next in frame {&frame-name}.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-pers PERS-Frame 
PROCEDURE delete-pers :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER pnext-shift as logical no-undo.
/*вид смены для которой создаем запись no - текущая yes следующая*/
DEFINE PARAMETER BUFFER loc-shft-pers for shft-pers.
define variable glog as logical no-undo .
  if avail loc-shft-pers then do:
  glog = yes.
  message "Удалить "
  (if NOT pnext-shift
   then shft-pers.fio
   else next-shft-pers.fio)
   "из состава персонала"
  (if NOT pnext-shift
   then "передающей смены"
   else "принимающей смены")
    "?"
   view-as alert-box question buttons OK-Cancel update glog.
  if glog <> true then return error.
  delete loc-shft-pers.

  if NOT pnext-shift then do:
      {&OPEN-QUERY-BR-staff}
      reposition br-staff to row 1 no-error.
      apply "entry" to br-staff in frame {&frame-name}.
  end.
  else do:
      {&OPEN-QUERY-BR-staff-next}
      reposition br-staff-next to row 1 no-error.
      apply "entry" to br-staff-next in frame {&frame-name}.
      ENABLE b-add-next with frame {&frame-name}.
  end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI PERS-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME PERS-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI PERS-Frame  _DEFAULT-ENABLE
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
  ENABLE b-quit B-Help RECT-1 RECT-2 B-add B-del B-chg B-mng BR-staff 
         B-add-next B-del-next B-chg-next BR-staff-next 
      WITH FRAME PERS-Frame.
  Display B-exit with frame PERS-Frame .      
  VIEW FRAME PERS-Frame.
  {&OPEN-BROWSERS-IN-QUERY-PERS-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-db PERS-Frame 
PROCEDURE fill-db :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable for-psn-num like ub.shift-staff.psn-num no-undo init 0.
define buffer buf_shift-staff for ub.shift-staff.

/*пропишем персонал текущей смены*/

    FOR EACH shft-pers NO-LOCK where
         shft-pers.next-shift = no and
         shft-pers.psn-code <> -1
         by shft-pers.staff-role
         by shft-pers.fio:
       FIND FIRST buf_shift-staff where
                  buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
                  buf_shift-staff.obj-code = pobj-code AND
                  buf_shift-staff.shift-num = pshift-num AND
                  buf_shift-staff.shift-date = pshift-date AND
                  buf_shift-staff.next-shift = no AND
                  buf_shift-staff.psn-num = for-psn-num no-error.

        if not avail buf_shift-staff then do:
            create buf_shift-staff.
            assign
            buf_shift-staff.obj-type = pobj-type
            buf_shift-staff.obj-code = pobj-code
            buf_shift-staff.shift-num = pshift-num
            buf_shift-staff.shift-name = shift-obj.shift-name
            buf_shift-staff.shift-date = pshift-date
            buf_shift-staff.psn-num = for-psn-num
            buf_shift-staff.next-shift = no
            .
        end.
        if avail buf_shift-staff THEN DO:
            ASSIGN
            buf_shift-staff.NAME = SHft-pers.fio
            buf_shift-staff.psn-code = shft-pers.psn-code
            buf_shift-staff.cashier = shft-pers.cashier
            buf_shift-staff.staff-role = shft-pers.staff-role
            .
        END.
        for-psn-num = for-psn-num + 1.
    END. /*FOR EACH shft-pers*/
    /*удалим ненужные*/
    FOR EACH buf_shift-staff where
             buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
             buf_shift-staff.obj-code = pobj-code AND
             buf_shift-staff.shift-num = pshift-num AND
             buf_shift-staff.shift-date = pshift-date AND
             buf_shift-staff.next-shift = no AND
             buf_shift-staff.psn-num >= for-psn-num:
        delete buf_shift-staff.
    END.
    for-psn-num = 0.
    /*даже если была следующая смена и она открыта или ожидается в текущую запишем  менеджера след смены*/
    FOR EACH shft-pers NO-LOCK where
      shft-pers.next-shift = yes
      by shft-pers.staff-role
      by shft-pers.fio:
        FIND FIRST buf_shift-staff where
                  buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
                  buf_shift-staff.obj-code = pobj-code AND
                  buf_shift-staff.shift-num = pshift-num AND
                  buf_shift-staff.shift-date = pshift-date AND
                  buf_shift-staff.next-shift = yes AND
                  buf_shift-staff.psn-num = for-psn-num no-error.
        if not avail buf_shift-staff then do:
            create buf_shift-staff.
            assign
            buf_shift-staff.obj-type   = pobj-type
            buf_shift-staff.obj-code   = pobj-code
            buf_shift-staff.shift-num  = pshift-num
            buf_shift-staff.shift-name = shift-obj.shift-name
            buf_shift-staff.shift-date = pshift-date
            buf_shift-staff.psn-num    = for-psn-num
            buf_shift-staff.next-shift = yes
            .
        end.
    if avail buf_shift-staff THEN DO:
        ASSIGN
        buf_shift-staff.NAME = SHft-pers.fio
        buf_shift-staff.next-shift = shft-pers.next-shift
        buf_shift-staff.cashier = shft-pers.cashier
        buf_shift-staff.staff-role = shft-pers.staff-role
         buf_shift-staff.psn-code = shft-pers.psn-code
        .
    END.
    for-psn-num = for-psn-num + 1.
    END. /*FOR EACH shft-pers*/
    /*удалим ненужные*/
    FOR EACH buf_shift-staff where
              buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
              buf_shift-staff.obj-code = pobj-code AND
              buf_shift-staff.shift-num = pshift-num AND
              buf_shift-staff.shift-date = pshift-date AND
              buf_shift-staff.next-shift = yes AND
              buf_shift-staff.psn-num >= for-psn-num:
        delete buf_shift-staff.
    END.
    /*следующая смена доступна - пропишем и туда*/
    for-psn-num = 0.
    if avail next-shift-obj and next-shift-obj.status_ <> {&sht-closed} then do:
        FOR EACH shft-pers NO-LOCK where
         shft-pers.next-shift = yes
         by shft-pers.staff-role
         by shft-pers.fio:
           FIND FIRST buf_shift-staff where
                      buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
                      buf_shift-staff.obj-code = pobj-code AND
                      buf_shift-staff.shift-num = next-shift-obj.shift-num AND
                      buf_shift-staff.shift-date = next-shift-obj.shift-date AND
                      buf_shift-staff.next-shift = no AND
                      buf_shift-staff.psn-num = for-psn-num no-error.
            if not avail buf_shift-staff then do:
                create buf_shift-staff.
                assign
                buf_shift-staff.obj-type   = pobj-type
                buf_shift-staff.obj-code   = pobj-code
                buf_shift-staff.shift-num  = next-shift-obj.shift-num
                buf_shift-staff.shift-name = next-shift-obj.shift-name
                buf_shift-staff.shift-date = next-shift-obj.shift-date
                buf_shift-staff.psn-num    = for-psn-num
                buf_shift-staff.next-shift = no
                .
            end.
          if avail buf_shift-staff THEN DO:
              ASSIGN
              buf_shift-staff.NAME = SHft-pers.fio
              buf_shift-staff.next-shift = no
              buf_shift-staff.cashier = shft-pers.cashier
              buf_shift-staff.staff-role = shft-pers.staff-role
              buf_shift-staff.psn-code = shft-pers.psn-code
              .
          END.
        for-psn-num = for-psn-num + 1.
        END. /*FOR EACH shft-pers*/
        /*удалим ненужные*/
        FOR EACH buf_shift-staff where
                  buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
                  buf_shift-staff.obj-code = pobj-code AND
                  buf_shift-staff.shift-num = next-shift-obj.shift-num AND
                  buf_shift-staff.shift-date = next-shift-obj.shift-date AND
                  buf_shift-staff.next-shift = no AND
                  buf_shift-staff.psn-num >= for-psn-num:
            delete buf_shift-staff.
        END.
        /**/
    end. /*if vail next-shfit-obj and next-shift-obj.status_ <> {&sht-closed} */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table PERS-Frame 
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:     заполнение shft-pers по данным из БД
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER find-mng-next as logical no-undo.
/*если есть старший по принимающей смене то надо выкл кнопку b-add*/
define buffer buf_shift-staff for ub.shift-staff.

for each shft-pers:
    delete shft-pers.
end.
/*заполним таблицу персонала текцщей смены */
if call-point = {&obj-shift-open} and avail previous-shift-obj then do:
  FOR EACH buf_shift-staff No-LOCK WHERE
          buf_shift-staff.obj-type = pobj-type AND
          buf_shift-staff.obj-code = pobj-code AND
          buf_shift-staff.shift-num = previous-shift-obj.shift-num AND
          buf_shift-staff.shift-date = previous-shift-obj.shift-date AND
          buf_shift-staff.next-shift = yes use-index pi:
          create shft-pers.
          assign
          shft-pers.psn-code = buf_shift-staff.psn-code
          shft-pers.cashier = buf_shift-staff.cashier
          shft-pers.fio = buf_shift-staff.name
          shft-pers.staff-role = buf_shift-staff.staff-role
          shft-pers.next-shift = no
          .
  END.
end.
else
FOR EACH buf_shift-staff No-LOCK WHERE
         buf_shift-staff.obj-type = pobj-type AND
         buf_shift-staff.obj-code = pobj-code AND
         buf_shift-staff.shift-num = pshift-num AND
         buf_shift-staff.shift-date = pshift-date AND
         buf_shift-staff.next-shift = no use-index pi:
         create shft-pers.
         assign
         shft-pers.psn-code = buf_shift-staff.psn-code
         shft-pers.cashier = buf_shift-staff.cashier
         shft-pers.fio = buf_shift-staff.name
         shft-pers.staff-role = buf_shift-staff.staff-role
         shft-pers.next-shift = buf_shift-staff.next-shift
         .
END.
IF AVAIL next-shift-obj then do:
/*если есть следующая смена то должна быть и хотя бы одна запись для персонала след смены*/
  FOR EACH buf_shift-staff No-LOCK WHERE
          buf_shift-staff.obj-type = next-shift-obj.obj-type AND
          buf_shift-staff.obj-code = next-shift-obj.obj-code AND
          buf_shift-staff.shift-num = next-shift-obj.shift-num AND
          buf_shift-staff.shift-date = next-shift-obj.shift-date AND
          buf_shift-staff.staff-role = yes AND
          buf_shift-staff.next-shift = no use-index pi:
          create shft-pers.
          assign
          shft-pers.psn-code = buf_shift-staff.psn-code
          shft-pers.cashier = buf_shift-staff.cashier
          shft-pers.fio = buf_shift-staff.name
          shft-pers.staff-role = buf_shift-staff.staff-role
          shft-pers.next-shift = yes
          .
    find-mng-next = yes.
  END.
end.
/*если след смены нет то менеджера  берем из таблицы для текущей смены  с флажком next-shift = yes*/
else
FOR EACH buf_shift-staff No-LOCK WHERE
         buf_shift-staff.obj-type = pobj-type AND
         buf_shift-staff.obj-code = pobj-code AND
         buf_shift-staff.shift-num = pshift-num AND
         buf_shift-staff.shift-date = pshift-date AND
         buf_shift-staff.next-shift = yes use-index pi:
         create shft-pers.
         assign
         shft-pers.psn-code = buf_shift-staff.psn-code
         shft-pers.cashier = buf_shift-staff.cashier
         shft-pers.fio = buf_shift-staff.name
         shft-pers.staff-role = buf_shift-staff.staff-role
         shft-pers.next-shift = buf_shift-staff.next-shift
         .
    find-mng-next = yes.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Mng-pers PERS-Frame 
PROCEDURE Mng-pers :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER pnext-shift as integer no-undo.
/*вид смены для которой создаем запись 0 - текущая 1 следующая*/
DEFINE PARAMETER BUFFER loc-shft-pers for shft-pers.

define variable cli-rec as recid no-undo.
define buffer b-shft-pers for shft-pers.
if avail loc-shft-pers then do:
   DO TRANSACTION ON ERROR UNDO, return error:
    if loc-shft-pers.staff-role = no THEN DO:
        FOR EACH b-shft-pers where
                 b-shft-pers.next-shift = loc-shft-pers.next-shift AND
                 b-shft-pers.staff-role = yes:
            assign
            b-shft-pers.staff-role = no.
        END.
    end.
    assign
    loc-shft-pers.staff-role = NOT loc-shft-pers.staff-role
    cli-rec = recid(loc-shft-pers)
    .
    END.
   if pnext-shift = 0 then do:

    {&OPEN-QUERY-BR-staff}
    reposition br-staff to recid cli-rec no-error.
    apply "entry" to br-staff in frame {&frame-name}.

   end.
   else do:
    {&OPEN-QUERY-BR-staff-NEXT}
    reposition br-staff-NEXT to recid cli-rec no-error.
    apply "entry" to br-staff-next in frame {&frame-name}.

   end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable PERS-Frame 
PROCEDURE MyEnable :
define variable varshift-name as character no-undo .
define variable varshift-name-next as character no-undo .
define variable varshift-name-num as character no-undo .
define variable varshift-name-num-next as character no-undo .
define variable glog as logical no-undo .
define variable v-obj-db-num as integer no-undo .
{ gbl/objdbnum.i pobj-type pobj-code v-obj-db-num }

ASSIGN b-add:POPUP-MENU IN FRAME {&frame-name} = MENU menu-b-add:HANDLE.
ASSIGN b-add:MENU-MOUSE = 1.
ASSIGN b-add-next:POPUP-MENU IN FRAME {&frame-name} = MENU menu-b-add-next:HANDLE.
ASSIGN b-add-next:MENU-MOUSE = 1.
if lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num then do:
  assign
  B-add:POPUP-MENU IN FRAME PERS-Frame       = MENU MENU-B-add:HANDLE
  BR-staff:POPUP-MENU IN FRAME PERS-Frame             = MENU MENU-BR-staff:HANDLE
  .
end.
else do:
  assign
  B-add:POPUP-MENU IN FRAME PERS-Frame       = ?
  BR-staff:POPUP-MENU IN FRAME PERS-Frame    = ?
  .
end.
if lookup("b-add-next", bttns) > 0 and v-obj-db-num = v-cntxt-db-num then do:
  ASSIGN
  B-add-next:POPUP-MENU IN FRAME PERS-Frame       = MENU MENU-B-add-next:HANDLE
  BR-staff-next:POPUP-MENU IN FRAME PERS-Frame    = MENU MENU-BR-staff-next:HANDLE
  .
end.
else do:
  ASSIGN
  B-add-next:POPUP-MENU IN FRAME PERS-Frame       = ?
  BR-staff-next:POPUP-MENU IN FRAME PERS-Frame    = ?
  .
end.

ENABLE
B-exit 
b-quit 
B-Help
RECT-1
RECT-2
B-add when lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
B-del when lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
b-mng when lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
b-chg when lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
BR-staff
B-add-next when lookup("b-add-next", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
B-del-next when lookup("b-add-next", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
b-chg-next when lookup("b-add-next", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
BR-staff-next
/*b-mng-next оставим кнопку на всякий случай*/
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
run fill-table in this-procedure ( output glog) no-error.
if glog then
disable b-add-next with frame {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Pers-Frame}
assign
shft-pers.fio:read-only in browse br-staff = true
shft-pers.cashier:read-only in browse br-staff = true
.
assign
next-shft-pers.fio:read-only in browse br-staff-next = true
next-shft-pers.cashier:read-only in browse br-staff-next = true
.
{ str/shiftnam.i
  pobj-type
  pobj-code
  pshift-date
  pshift-num
  varshift-name
  varshift-name-num
  no-error
}
if available next-shift-obj then do:

{ str/shiftnam.i
  pobj-type
  pobj-code
  next-shift-obj.shift-date
  next-shift-obj.shift-num
  varshift-name-next
  varshift-name-num-next
  no-error
}
end.
assign
MENU-ITEM m-add-blank:sensitive   in MENU MENU-B-add = not v-noanshftstaff
MENU-ITEM m-add-next-blank:sensitive in menu menu-b-add-next = not v-noanshftstaff
MENU-ITEM m-br-blank:sensitive in menu menu-br-staff = not v-noanshftstaff
MENU-ITEM m-br-next-blank:sensitive in menu menu-br-staff-next = not v-noanshftstaff
.
ASSIGN
browse br-staff:title = substitute("&1 &2 &3"
                                    , browse br-staff:title
                                    , string(pshift-date, "99/99/9999")
                                    , varshift-name-num)
browse br-staff-next:title = substitute("&1 &2 &3"
                                        , browse br-staff-next:title
                                        , (if available next-shift-obj
                                          then string(next-shift-obj.shift-date, "99/99/9999")
                                          else '':U)
                                        , (if available next-shift-obj
                                          then  varshift-name-num-next
                                          else '':U) )
.
if b-add:sensitive in frame {&frame-name} then do:
  APPLY "ENTRY" to b-add.
end.
if lookup("b-add", bttns) = 0
and lookup("b-add-next", bttns) = 0 then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide
  b-exit in frame {&frame-name}
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE upd-next-shft-pers PERS-Frame 
PROCEDURE upd-next-shft-pers :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  IF AVAIL next-shft-pers THEN DO:
  IF next-shft-pers.PSN-CODE <> ? THEN DO:
    MESSAGE "Нельзя изменить эту запись - она была выбрана из справочника"
    VIEW-AS ALERT-BOX ERROR.
    DISPLAY
    next-shft-pers.fio
    next-shft-pers.cashier
    with browse br-staff-next
    .
    RETURN error.
  END.
  assign
  next-shft-pers.fio = next-shft-pers.fio:screen-value in browse br-staff-next
  next-shft-pers.cashier = integer(next-shft-pers.cashier:screen-value in browse br-staff-next)
  .
  DISPLAY
  next-shft-pers.fio
  next-shft-pers.cashier
  with browse br-staff-next
  .
  assign
  next-shft-pers.fio:read-only in browse br-staff-next = true
  next-shft-pers.cashier:read-only in browse br-staff-next = true
  .
  end.
  run gbl/frcclick.p (
                        input br-staff-next:handle in frame {&frame-name}
                       ,input next-shft-pers.staff-role:handle in browse br-staff-next
                       ,input no) no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE upd-shft-pers PERS-Frame 
PROCEDURE upd-shft-pers :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  IF AVAIL SHFT-PERS THEN DO:
  IF SHFT-PERS.PSN-CODE <> ? THEN DO:
    MESSAGE "Нельзя изменить эту запись - она была выбрана из справочника"
    VIEW-AS ALERT-BOX ERROR.
    DISPLAY
    shft-pers.fio
    shft-pers.cashier
    with browse br-staff
    .
    RETURN error.
  END.
  assign
  shft-pers.fio = shft-pers.fio:screen-value in browse br-staff
  shft-pers.cashier = integer(shft-pers.cashier:screen-value in browse br-staff)
  .
  DISPLAY
  shft-pers.fio
  shft-pers.cashier
  with browse br-staff
  .
  assign
  shft-pers.fio:read-only in browse br-staff = true
  shft-pers.cashier:read-only in browse br-staff = true
  .
  end.
  run gbl/frcclick.p (
                       input br-staff:handle in frame {&frame-name}
                      ,input shft-pers.staff-role:handle in browse br-staff
                      ,input no) no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

