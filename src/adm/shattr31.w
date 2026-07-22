&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута объекта TH (thbj-attr) "cd-type-ibs-th-MOB"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/08
Author: Bakhtadze Natalya
Creation date: 07/08/08

*/


/*-----------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута объекта TH (thbj-attr) cd-type-ibs-th-MOB".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
&UNDEFINE thbj-def_i
{ gbl/thbj-def.i __ }
{ gbl/tempwidg.i }
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO EXTENT 5.
DEFINE VARIABLE v-labels AS CHARACTER NO-UNDO EXTENT 5.
DEFINE VARIABLE v-current-tab-order AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-host-code AS INTEGER NO-UNDO.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
define variable v-tth_ as handle NO-UNDO .
define variable v-tth_main as handle NO-UNDO .
define variable v-tth_devices as handle NO-UNDO .
define variable v-tth_fisreg as handle NO-UNDO .
define variable v-tth_rec-print as handle NO-UNDO .
define variable v-tth_interface as handle NO-UNDO .
DEFINE VARIABLE v-frpay-name AS CHARACTER NO-UNDO.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle
v-tth_ = buffer thbjattr___thbj-attr:table-handle
.
DEFINE TEMP-TABLE temp-cash-pay-list
FIELD cdpay-code AS INTEGER
FIELD curr-code AS INTEGER
FIELD frpay-code AS INTEGER
INDEX pi IS UNIQUE PRIMARY
cdpay-code curr-code
INDEX ifr frpay-code
    .

DEFINE TEMP-TABLE temp-pay-names
FIELD frpay-code AS INTEGER
FIELD frpay-name AS CHARACTER
INDEX pi IS UNIQUE PRIMARY frpay-code.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-rec-print b-quit B-Help ~
t-salesman-mandatory cb-pos-type-for-discnt B-main t-rcpt-ord-slip-print ~
t-rcpt-ord-alt-print f-main f-rec-print for-curr-name
&Scoped-Define DISPLAYED-OBJECTS t-salesman-mandatory ~
cb-pos-type-for-discnt t-rcpt-ord-slip-print t-rcpt-ord-alt-print f-main ~
f-rec-print for-curr-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-frpay-name Dialog-Frame
FUNCTION get-frpay-name RETURNS CHARACTER
  ( INPUT p-frpay-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getcp-name Dialog-Frame
FUNCTION getcp-name RETURNS CHARACTER
  ( INPUT p-cdpay-code AS INTEGER , INPUT p-curr-code AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
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
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-main
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL "&1.Перемещ."
     SIZE 14 BY 1.13.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rec-print
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.

DEFINE VARIABLE cb-pos-type-for-discnt AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип POS, с которого брать скидки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE f-main AS CHARACTER FORMAT "X(12)" INITIAL "Основные"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-rec-print AS CHARACTER FORMAT "X(12)":U INITIAL "Чеки"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.

DEFINE VARIABLE for-curr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-rcpt-ord-alt-print AS LOGICAL INITIAL no
     LABEL "Печатать отлож.чек на доп принтере"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE t-rcpt-ord-slip-print AS LOGICAL INITIAL no
     LABEL "Печатать слип отложенного чека"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE t-salesman-mandatory AS LOGICAL INITIAL no
     LABEL "Обязателен продавец"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-rec-print AT ROW 2.57 COL 43 WIDGET-ID 34
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     t-salesman-mandatory AT ROW 4.2 COL 14 WIDGET-ID 156
     cb-pos-type-for-discnt AT ROW 6.33 COL 35 COLON-ALIGNED WIDGET-ID 158
     B-main AT ROW 2.57 COL 1 WIDGET-ID 14
     t-rcpt-ord-slip-print AT ROW 8 COL 18 WIDGET-ID 198
     t-rcpt-ord-alt-print AT ROW 9 COL 18 WIDGET-ID 200
     f-main AT ROW 2.93 COL 2.5 NO-LABEL WIDGET-ID 18
     f-rec-print AT ROW 2.93 COL 44.5 NO-LABEL WIDGET-ID 36
     for-curr-name AT ROW 17 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 136
     SPACE(41.49) SKIP(4.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки по умолчанию и опции работы POS IBS TH"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-main IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-rec-print IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки по умолчанию и опции работы POS IBS TH */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-main
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-main Dialog-Frame
ON CHOOSE OF B-main IN FRAME Dialog-Frame /* 1.Перемещ. */
DO:
   run proc-init-main in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rec-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rec-print Dialog-Frame
ON CHOOSE OF b-rec-print IN FRAME Dialog-Frame
DO:
run proc-init-rec-print in this-procedure .

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
{ ref/tabhndmv.i v-current-tab-order underline-tb }
{ gbl/rethndmv.i v-current-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ibs-th-MOB}
        AND   locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ibs-th-MOB}
    and   locked_thbj-attr.prop-code = '':U
    NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.

  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.

  RUN Myenable.
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
  DISPLAY t-salesman-mandatory cb-pos-type-for-discnt t-rcpt-ord-slip-print
          t-rcpt-ord-alt-print f-main f-rec-print for-curr-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-rec-print b-quit B-Help t-salesman-mandatory
         cb-pos-type-for-discnt B-main t-rcpt-ord-slip-print
         t-rcpt-ord-alt-print f-main f-rec-print for-curr-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
DEFINE VARIABLE v-dop1 AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fr-code AS integer NO-UNDO.
DEFINE VARIABLE v-cp-list AS character NO-UNDO.
DEFINE VARIABLE v-name AS character NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DEFINE VARIABLE v-jj AS integer NO-UNDO.
DEFINE BUFFER buf_currency FOR ub.currency.
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-cd-type-ibs-th-MOB}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT TABLE-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  CASE thbjattr_thbj-attr.upper-prop-code :
    WHEN {&attr-cd-type-ibs-th-MOB_ibs-th-MOB_main} THEN DO:
      CASE v-entry:
       WHEN {&attr-cd-type-ibs-th-MOB_ibs-th-MOB_main_salesman-mandatory} THEN DO:
          ASSIGN
          t-salesman-mandatory = logical(thbjattr_thbj-attr.property-value-integer)
          t-salesman-mandatory:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
       END.
       WHEN {&attr-cd-type-ibs-th-MOB_ibs-th-MOB_main_pos-type-for-discnt} THEN DO:
          ASSIGN
          cb-pos-type-for-discnt = thbjattr_thbj-attr.property-value-character
          cb-pos-type-for-discnt:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
       END.
      END CASE.
    END.
    when {&attr-cd-type-ibs-th-MOB_ibs-th-MOB_rec-print} THEN DO:
      case v-entry:
       when {&attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print_rcpt-ord-slip-print} then do:
         ASSIGN
         t-rcpt-ord-slip-print = logical(thbjattr_thbj-attr.property-value-integer)
         t-rcpt-ord-slip-print:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.
       when {&attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print_rcpt-ord-alt-print} then do:
         ASSIGN
         t-rcpt-ord-alt-print = logical(thbjattr_thbj-attr.property-value-integer)
         t-rcpt-ord-alt-print:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.

      END CASE.

    end.
  END CASE.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS HANDLE NO-UNDO.
DEFINE VARIABLE v-h1 AS HANDLE NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DEFINE VARIABLE v-jj AS integer NO-UNDO.
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
ASSIGN
FRAME {&FRAME-NAME}:TITLE = substitute("&1 &2&3"
                                       ,FRAME {&FRAME-NAME}:TITLE
                                       ,(if p-obj-type = ""
                                         then ""
                                         else {&shop})
                                       ,(IF p-obj-type = "" THEN "" ELSE string(p-obj-code)))
cb-pos-type-for-discnt:LIST-ITEMS = {&cd-type-ibs-th} + {&comma-char} + {&CD-TYPE-IBS-TH-MOB}
v-tab-order[1] = "t-salesman-mandatory,cb-pos-type-for-discnt"
v-labels[1] = ''
v-tab-order[2] = "t-rcpt-ord-slip-print,t-rcpt-ord-alt-print"
v-labels[2] = ''

.
v-h = FRAME {&FRAME-NAME}:FIRST-CHILD.
DO WHILE valid-handle(v-h).
  IF v-h:TYPE = "field-group"  THEN DO:
     v-h1 = v-h:FIRST-CHILD.
     DO WHILE valid-handle(v-h1).
      RUN tempwidg_create-record IN THIS-PROCEDURE ( INPUT v-h1).
      ASSIGN
      v-h1 = v-h1:NEXT-sibling.
    END.
  END.
  v-h = v-h:NEXT-SIBLING.
END.
DO v-ii = 1 TO 5:
  IF v-tab-order[v-ii] > '' THEN do:
    DO v-jj = 1 TO NUM-ENTRIES(v-tab-order[v-ii]):
     FIND FIRST temp-widget WHERE
                temp-widget.name_ = ENTRY(v-jj,v-tab-order[v-ii]) NO-ERROR.
     IF AVAILABLE temp-widget THEN DO:
         temp-widget.section_ = STRING(v-ii).
     END.
    END.
  END.
  IF v-labels[v-ii] > '' THEN do:
    DO v-jj = 1 TO NUM-ENTRIES(v-labels[v-ii]):
     FIND FIRST temp-widget WHERE
                temp-widget.name_ = ENTRY(v-jj,v-labels[v-ii]) NO-ERROR.
     IF AVAILABLE temp-widget THEN DO:
        temp-widget.section_ = STRING(v-ii).
      END.
    END.
  END.
END.
DISPLAY
f-main
f-rec-print
WITH FRAME {&frame-name}.
assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
if wh:private-data begins "recid=" then do:
  find first thbjattr_thbj-attr where
            recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
  IF wh:DATA-TYPE = {&abl-datatype-logical}
  AND thbjattr_thbj-attr.prop-value-type = {&abl-datatype-integer} THEN DO:
     wh:screen-value = string(IF thbjattr_thbj-attr.property-value-integer = 1 THEN YES ELSE NO).

  END.
  ELSE DO:
    assign
    wh:screen-value = string(buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value).
  END.
end.
ELSE DO:
   FIND FIRST temp-widget NO-LOCK WHERE
             temp-widget.NAME_ = wh:NAME NO-ERROR.
   IF AVAILABLE temp-widget THEN DO:
      CASE temp-widget.DATA-TYPE_:
        WHEN {&abl-datatype-character} THEN DO:
            ASSIGN
            wh:SCREEN-VALUE = temp-widget.CHARACTER_.
        END.
      END CASE.
   END.
END.
wh = wh:next-sibling.
end.

ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
b-main
b-rec-print
t-salesman-mandatory WHEN p-mode = {&UPDATE}
t-rcpt-ord-slip-print WHEN p-mode = {&UPDATE}
t-rcpt-ord-alt-print WHEN p-mode = {&UPDATE}
cb-pos-type-for-discnt WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    b-quit:COLUMN = 1
    .
END.
APPLY "CHOOSE" TO b-main.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-main Dialog-Frame
PROCEDURE proc-init-main :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-main:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 f-main:fgcolor = 1   .
 f-rec-print:fgcolor = ? .
 /*
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .

 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 */
 /*
 ASSIGN
 f-devices:fgcolor = ?
 f-fisreg:fgcolor = ?

 f-interface:fgcolor = ?
 .
 */
 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "1":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "1"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[1].
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-rec-print Dialog-Frame
PROCEDURE proc-init-rec-print :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-main:LOAD-IMAGE-UP("adeicon\ts-dn110":U)           in frame {&frame-name} .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-up110":U)      in frame {&frame-name} .
 f-main:fgcolor = ?   .
 f-rec-print:fgcolor = 1 .
 /*
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .

 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 */
 /*
 ASSIGN
 f-devices:fgcolor = ?
 f-fisreg:fgcolor = ?

 f-interface:fgcolor = ?
 .
 */
 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "2":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "2"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[2].
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
define variable v-loc-same as logical no-undo .
define variable l-write-cd as logical no-undo .

IF p-mode = {&LOOKUP} THEN RETURN ERROR.
MESSAGE
substitute( "Применить сделанные Вами изменения ко всем POS IBS TH MOB&1&2?"
           ,{&NEW-LINE}
           ,(IF p-obj-type <> '' THEN substitute("&1&2", p-obj-type, p-obj-code) ELSE "")
           )
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-CANCEL UPDATE l-write-cd.
IF l-write-cd = ? THEN UNDO, RETURN ERROR.

assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
 if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).

    IF wh:DATA-TYPE = {&abl-datatype-logical}
    AND thbjattr_thbj-attr.prop-value-type = {&abl-datatype-integer} THEN DO:
      assign
      thbjattr_thbj-attr.property-value-integer = (IF wh:INPUT-VALUE = YES THEN 1 ELSE 0).

    END.
    ELSE DO:
     assign
      buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.

    END.
  end.
  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code
break
by thbjattr_thbj-attr.upper-prop-code :
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-loc-same.
   if v-loc-same = no then do:
     v-same = v-loc-same.
     if l-write-cd = yes
     and thbjattr_thbj-attr.upper-prop-code <> {&attr-cd-type-ibs-th-MOB}
     then do:
       run update-cda in this-procedure ( buffer thbjattr_thbj-attr).
     end.
     else do:
       leave.
    end.
   end.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.

for each thbjattr_thbj-attr
break by thbjattr_thbj-attr.upper-prop-code
:
  if first-of(thbjattr_thbj-attr.upper-prop-code) then do:
    empty temp-table thbjattr___thbj-attr.
  end.
  create thbjattr___thbj-attr.
  buffer-copy
  thbjattr_thbj-attr
  to
  thbjattr___thbj-attr.
  if last-of(thbjattr_thbj-attr.upper-prop-code) then do:
    run adm/shattri.p (
                  input "check":U
                , input p-obj-type
                , input p-obj-code
                , input thbjattr_thbj-attr.upper-prop-code
                , input '':U
                , output v-value-character
                , output v-value-date
                , output v-value-decimal
                , output v-value-integer
                , output v-value-logical
                , output v-param-type
                , input-output TABLE-handle v-tth_
                ) no-error .

    if error-status:error then do:
      message
      "Некорректное значение ПАРАМЕТРОВ" skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
    empty temp-table thbjattr___thbj-attr.
  end.
end.
RUN thbjattr_set-section IN THIS-PROCEDURE (
     input p-obj-type
    ,input p-obj-code
    ,input {&attr-cd-type-ibs-th-MOB}
    ,input table thbjattr_thbj-attr
) NO-ERROR.
IF ERROR-STATUS:error THEN do:
  MESSAGE ERROR-STATUS:get-message(1)  SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX.
  UNDO, RETURN ERROR.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-cda Dialog-Frame
PROCEDURE update-cda :
DEFINE PARAMETER BUFFER buf_thbjattr_thbj-attr FOR thbjattr_thbj-attr.
define variable v-obj-db-num as integer no-undo .
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
case p-obj-type:
  when '':U then do:
    main-block:
    for each buf_Cash-desk no-lock where
            buf_cash-desk.pos-type = {&cd-type-ibs-th-MOB}
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
       find first   buf_cash-desk-attr share-lock where
             buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
         and buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
         and buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
         and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
         and buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
        and buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
        no-error.
       if not available buf_Cash-desk-attr then do:
         create buf_cash-desk-attr.
         assign
         buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
         buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
         buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
         buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
         buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
         buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
         .
       end.
       assign
       buf_cash-desk-attr.attr-value-character = buf_thbjattr_thbj-attr.property-value-character
       buf_cash-desk-attr.attr-value-date = buf_thbjattr_thbj-attr.property-value-date
       buf_cash-desk-attr.attr-value-decimal = buf_thbjattr_thbj-attr.property-value-decimal
       buf_cash-desk-attr.attr-value-integer = buf_thbjattr_thbj-attr.property-value-integer
       buf_cash-desk-attr.attr-value-logical = buf_thbjattr_thbj-attr.property-value-logical
       buf_cash-desk-attr.attr-value-type = buf_thbjattr_thbj-attr.prop-value-type
       .
    end.
  end.
  when {&shop} then do:
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-obj-db-num }
    main-block:
    for each buf_Cash-desk no-lock where
            buf_cash-desk.pos-type = {&cd-type-ibs-th-MOB}
        and buf_cash-desk.obj-code = p-obj-code
        and buf_cash-desk.db-num = v-obj-db-num
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
       find first   buf_cash-desk-attr share-lock where
             buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
         and buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
         and buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
         and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
         and buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
        and buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
        no-error.
       if not available buf_Cash-desk-attr then do:
         create buf_cash-desk-attr.
         assign
         buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
         buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
         buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
         buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
         buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
         buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
         .
       end.
       assign
       buf_cash-desk-attr.attr-value-character = buf_thbjattr_thbj-attr.property-value-character
       buf_cash-desk-attr.attr-value-date = buf_thbjattr_thbj-attr.property-value-date
       buf_cash-desk-attr.attr-value-decimal = buf_thbjattr_thbj-attr.property-value-decimal
       buf_cash-desk-attr.attr-value-integer = buf_thbjattr_thbj-attr.property-value-integer
       buf_cash-desk-attr.attr-value-logical = buf_thbjattr_thbj-attr.property-value-logical
       buf_cash-desk-attr.attr-value-type = buf_thbjattr_thbj-attr.prop-value-type
       .
    end.
  end. /*when shop*/
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-frpay-name Dialog-Frame
FUNCTION get-frpay-name RETURNS CHARACTER
  ( INPUT p-frpay-code AS INTEGER ) :
DEFINE BUFFER buf_temp-pay-names FOR temp-pay-names.
FIND first buf_temp-pay-names WHERE
        buf_temp-pay-names.frpay-code = p-frpay-code NO-ERROR.
IF NOT AVAILABLE buf_temp-pay-names THEN RETURN "".
RETURN buf_temp-pay-names.frpay-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getcp-name Dialog-Frame
FUNCTION getcp-name RETURNS CHARACTER
  ( INPUT p-cdpay-code AS INTEGER , INPUT p-curr-code AS INTEGER) :
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
FIND first buf_cash-pay NO-LOCK  WHERE
        buf_cash-pay.cdpay-code = p-cdpay-code
    AND buf_Cash-pay.curr-code = p-curr-code NO-ERROR.
IF NOT AVAILABLE buf_cash-pay THEN RETURN "!!!НЕИЗВЕСТНЫЙ ТИП КАСС.ПЛАТЕЖА".
RETURN buf_cash-pay.obj-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME