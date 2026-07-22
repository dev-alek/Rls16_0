&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Установка полей (проценты отклонения, бонус, НДС, ретро-бонус) для всех товаров спецификации

Автор: Сливенко Сергей Андреевич
Дата создания: 09/14/11
Author: Sergey Slivenko
Creation date: 09/14/11

*/


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Установка полей (проценты отклонения, бонус, НДС, ретро-бонус) для всех товаров спецификации".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parParentProc  as widget-handle no-undo.

define output parameter p-prc          as decimal   no-undo.
define output parameter p-prc-2        as decimal   no-undo.
define output parameter p-bonus        as decimal   no-undo.
define output parameter p-vat-pc       as decimal   no-undo.
define output parameter p-vat-type     as character no-undo.
define output parameter p-retro-bonus  as character no-undo.

define output parameter p-change-fields  as character no-undo.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit RECT-1 RECT-2 l-prc l-prc-2 ~
l-bonus l-vat l-retro-bonus FILL-prc FILL-prc-2 FILL-bonus vat-type ~
FILL-VAT-pc v-date-from v-date-to v-pct v-sum v-method v-vozvrat
&Scoped-Define DISPLAYED-OBJECTS FILL-prc FILL-prc-2 FILL-bonus vat-type ~
FILL-VAT-pc v-date-from v-date-to v-pct v-sum v-method v-vozvrat

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-method AS CHARACTER FORMAT "X(256)":U
     LABEL "Метод расчета"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Приход с НДС","vat-yes",
                     "Приход без НДС","vat-no"
     DROP-DOWN-LIST
     SIZE 22 BY 1 NO-UNDO.

DEFINE VARIABLE vat-type AS CHARACTER FORMAT "x(8)"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "1","2"
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-bonus AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Бонус от цены товара %"
     VIEW-AS FILL-IN
     SIZE 13.2 BY 1 TOOLTIP "Процент к продажной цене" NO-UNDO.

DEFINE VARIABLE FILL-prc AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Допустимый % отклонения цены от спецификации в большую сторону"
     VIEW-AS FILL-IN
     SIZE 13.2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-prc-2 AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Допустимый % отклонения цены от спецификации в меньшую сторону"
     VIEW-AS FILL-IN
     SIZE 13.2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-VAT-pc AS DECIMAL FORMAT ">9.9":U INITIAL 0
     LABEL "НДС"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE v-date-from AS DATE FORMAT "99/99/9999":U initial TODAY
     LABEL "Период с"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-date-to AS DATE FORMAT "99/99/9999":U initial TODAY
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-pct AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "%"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-sum AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE IMAGE l-bonus
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.

DEFINE IMAGE l-prc
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.

DEFINE IMAGE l-prc-2
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.

DEFINE IMAGE l-retro-bonus
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.

DEFINE IMAGE l-vat
     FILENAME "adeicon\lock":U
     SIZE 3 BY .95.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 85.4 BY 3.33.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 85.4 BY 1.95.

DEFINE VARIABLE v-vozvrat AS LOGICAL INITIAL no
     LABEL "Не считать бонусы при наличии возвратов"
     VIEW-AS TOGGLE-BOX
     SIZE 48 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11 WIDGET-ID 4
     FILL-prc AT ROW 2.33 COL 8 WIDGET-ID 10
     FILL-prc-2 AT ROW 3.62 COL 8 WIDGET-ID 8
     FILL-bonus AT ROW 4.86 COL 48 WIDGET-ID 6
     vat-type AT ROW 6.29 COL 22 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     FILL-VAT-pc AT ROW 6.33 COL 12.4 COLON-ALIGNED WIDGET-ID 12
     v-date-from AT ROW 8.29 COL 19 COLON-ALIGNED WIDGET-ID 20
     v-date-to AT ROW 8.29 COL 38 COLON-ALIGNED WIDGET-ID 22
     v-pct AT ROW 10.14 COL 10.6 COLON-ALIGNED WIDGET-ID 26
     v-sum AT ROW 10.14 COL 33.6 COLON-ALIGNED WIDGET-ID 28
     v-method AT ROW 10.14 COL 65 COLON-ALIGNED WIDGET-ID 24
     v-vozvrat AT ROW 11.81 COL 9.8 WIDGET-ID 30
     "%" VIEW-AS TEXT
          SIZE 1.8 BY .67 AT ROW 6.48 COL 21.8 WIDGET-ID 14
     RECT-1 AT ROW 9.67 COL 8.6 WIDGET-ID 18
     RECT-2 AT ROW 7.81 COL 8.6 WIDGET-ID 32
     l-prc AT ROW 2.43 COL 2.6 WIDGET-ID 34
     l-prc-2 AT ROW 3.67 COL 2.6 WIDGET-ID 36
     l-bonus AT ROW 4.91 COL 2.6 WIDGET-ID 38
     l-vat AT ROW 6.33 COL 2.6 WIDGET-ID 40
     l-retro-bonus AT ROW 8.29 COL 2.6 WIDGET-ID 42
     SPACE(89.19) SKIP(3.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры для всех товаров спецификации" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-bonus IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-prc IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-prc-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры для всех товаров спецификации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:  /* отказ - выход  */
  assign FILL-prc FILL-prc-2 vat-type FILL-vat-pc FILL-bonus v-date-from v-date-to v-pct v-sum v-method v-vozvrat .
  if l-retro-bonus:visible = false THen do :
  if v-date-to < v-date-from then do :
     message "Неверно введены даты!" view-as alert-box.
     return no-apply.
  end.

  if v-method:screen-value = ? then do :
     message "Выберите метод расчета ретро-бонуса!" view-as alert-box.
     return  no-apply.
  end.

  if v-pct = 0 and v-sum = 0 then do :
     MESSAGE "Процент и сумма ретро-бонуса нулевые. Всё равно продолжить?"
     VIEW-AS ALERT-BOX QUESTION
     BUTTONS yes-no UPDATE continue-ok AS LOGICAL.
     IF not continue-ok then return no-apply.
  end.
  end.

  assign
    p-change-fields = '':U
    p-change-fields = IF FILL-prc:sensitive
                                  then (p-change-fields + {&comma-char} + "prc":U)
                                  else p-change-fields
    p-change-fields = IF FILL-prc-2:sensitive
                                  then (p-change-fields + {&comma-char} + "prc-2":U)
                                  else p-change-fields
    p-change-fields = IF FILL-bonus:sensitive
                                  then (p-change-fields + {&comma-char} + "bonus":U)
                                  else p-change-fields
    p-change-fields = IF FILL-vat-pc:sensitive
                                  then (p-change-fields + {&comma-char} + "vat-pc":U)
                                  else p-change-fields
    p-change-fields = IF v-pct:sensitive
                                  then (p-change-fields + {&comma-char} + "retro-bonus":U)
                                  else p-change-fields

    p-prc   = FILL-prc
    p-prc-2   = FILL-prc-2
    p-vat-type = vat-type
    p-vat-pc = FILL-vat-pc
    p-bonus = FILL-bonus
    p-retro-bonus = string(v-date-from) + "," +
                    string(v-date-to)   + "," +
                    string(v-pct)       + "," +
                    string(v-sum)       + "," +
                    string(v-method)    + "," +
                    string(v-vozvrat)   + ";"
  .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-bonus Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-bonus IN FRAME Dialog-Frame
DO:
   IF l-bonus:visible then do:
    assign
    l-bonus:visible = false.
    enable FILL-bonus with frame {&frame-name}.
    APPLY "ENTRY" TO FILL-bonus.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-prc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-prc Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-prc IN FRAME Dialog-Frame
DO:
   IF l-prc:visible then do:
    assign
    l-prc:visible = false.
    enable FILL-prc with frame {&frame-name}.
    APPLY "ENTRY" TO FILL-prc.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-prc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-prc-2 Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-prc-2 IN FRAME Dialog-Frame
DO:
   IF l-prc-2:visible then do:
    assign
    l-prc-2:visible = false.
    enable FILL-prc-2 with frame {&frame-name}.
    APPLY "ENTRY" TO FILL-prc-2.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-retro-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-retro-bonus Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-retro-bonus IN FRAME Dialog-Frame
DO:
  IF l-retro-bonus:visible then do:
    define variable glog as logical no-undo .
    { gbl/getcntxt.i get }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_fin-bonus_work':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      true
      gLog
    }
    if NOT gLog then do:
      return.
    end.

    assign
    l-retro-bonus:visible = false.
    enable v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame {&frame-name}.
    APPLY "ENTRY" TO v-date-from.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-vat Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-vat IN FRAME Dialog-Frame
DO:
   IF l-vat:visible then do:
    assign
    l-vat:visible = false.
    enable vat-type FILL-vat-pc with frame {&frame-name}.
    APPLY "ENTRY" TO FILL-vat-pc.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-bonus Dialog-Frame
ON RIGHT-MOUSE-CLICK OF FILL-bonus IN FRAME Dialog-Frame
DO:
    assign
    FILL-bonus = 0.00
    l-bonus:visible = true.
    display FILL-bonus with frame {&frame-name}.
    disable FILL-bonus with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-prc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-prc Dialog-Frame
ON RIGHT-MOUSE-CLICK OF FILL-prc IN FRAME Dialog-Frame
DO:
    assign
    FILL-prc = 0.00
    l-prc:visible = true.
    display FILL-prc with frame {&frame-name}.
    disable FILL-prc with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-prc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-prc-2 Dialog-Frame
ON RIGHT-MOUSE-CLICK OF FILL-prc-2 IN FRAME Dialog-Frame
DO:
    assign
    FILL-prc-2 = 0.00
    l-prc-2:visible = true.
    display FILL-prc-2 with frame {&frame-name}.
    disable FILL-prc-2 with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-vat-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-vat-pc Dialog-Frame
ON RIGHT-MOUSE-CLICK OF FILL-vat-pc IN FRAME Dialog-Frame
DO:
    assign
    FILL-vat-pc = 0.00
    vat-type = ?
    l-vat:visible = true.
    display FILL-vat-pc vat-type with frame {&frame-name}.
    disable FILL-vat-pc vat-type with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-pct
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-pct Dialog-Frame
ON RIGHT-MOUSE-CLICK OF v-pct IN FRAME Dialog-Frame
DO:
    assign
    v-date-from = TODAY
    v-date-to   = TODAY
    v-pct = 0.00
    v-sum = 0.00
    v-method = ?
    v-vozvrat = no
    l-retro-bonus:visible = true.
    display v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame {&frame-name}.
    disable v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-sum Dialog-Frame
ON RIGHT-MOUSE-CLICK OF v-sum IN FRAME Dialog-Frame
DO:
    assign
    v-date-from = TODAY
    v-date-to   = TODAY
    v-pct = 0.00
    v-sum = 0.00
    v-method = ?
    v-vozvrat = no
    l-retro-bonus:visible = true.
    display v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame {&frame-name}.
    disable v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-method Dialog-Frame
ON RIGHT-MOUSE-CLICK OF v-method IN FRAME Dialog-Frame
DO:
    assign
    v-date-from = TODAY
    v-date-to   = TODAY
    v-pct = 0.00
    v-sum = 0.00
    v-method = ?
    v-vozvrat = no
    l-retro-bonus:visible = true.
    display v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame {&frame-name}.
    disable v-date-from v-date-to v-pct v-sum v-method v-vozvrat with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vat-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vat-type Dialog-Frame
ON VALUE-CHANGED OF vat-type IN FRAME Dialog-Frame
DO:
  assign vat-type .
  if vat-type = {&without-vat} then do:
    assign FILL-vat-pc = 0 .
    DISABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
    display FILL-vat-pc WITH FRAME Dialog-Frame.
  end.
  else do:
    ENABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
    display FILL-vat-pc WITH FRAME Dialog-Frame.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/ed_date.i v-date-from }
  { gbl/ed_date.i v-date-to }
  VAT-type:LIST-ITEMS  in frame {&frame-name} =  {&no-vat} + "," + {&inc-vat} + "," + {&without-vat} .
  RUN enable_UI.
  if vat-type = {&without-vat} then  DISABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
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
  DISPLAY FILL-prc FILL-prc-2 FILL-bonus vat-type FILL-VAT-pc v-date-from
          v-date-to v-pct v-sum v-method v-vozvrat
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit RECT-1 RECT-2 l-prc l-prc-2 l-bonus l-vat l-retro-bonus
         /*FILL-prc FILL-prc-2 FILL-bonus vat-type FILL-VAT-pc v-date-from
         v-date-to v-pct v-sum v-method v-vozvrat*/
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME