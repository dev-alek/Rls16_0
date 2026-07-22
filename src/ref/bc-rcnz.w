&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME b-bc-rcnz
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS b-bc-rcnz
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор (через интерфейс или автоматический) или подтверждение одного из бар-кодов или 1 выключенного бар-кода

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08


Автор1: Суслов Алексей Юрьевич
Дата создания: 04/11/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input param d-str as char no-undo.                     /* повторный дополнительный бар-код */
define input param r-price as decimal no-undo.             /* требуемая цена товара, может отсутствовать */
define input param c-point as char no-undo.                  /* точка вызова, ref - справочник, choose - выбор */
define input-output param rid as recid no-undo.            /* recid выбранного бар-кода, на входе - включенного (если есть) */
/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
define variable gds-price as decimal no-undo.
define variable v-bc-price as logical no-undo . /*с проверкой цены*/
{ ref/send-ref.i }
{ gbl/getcntxt.i def }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME b-bc-rcnz
&Scoped-define BROWSE-NAME br-dpl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.prod-bc ub.bar-code ub.goods

/* Definitions for BROWSE br-dpl                                        */
&Scoped-define FIELDS-IN-QUERY-br-dpl ub.prod-bc.bc-on ub.goods.artic ~
ub.goods.gds-name gds-price ub.goods.engl-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dpl
&Scoped-define QUERY-STRING-br-dpl FOR EACH ub.prod-bc ~
      WHERE prod-bc.b-str = duplicate-str NO-LOCK, ~
      EACH ub.bar-code OF ub.prod-bc NO-LOCK, ~
      EACH ub.goods OF ub.bar-code NO-LOCK ~
    BY ub.goods.artic
&Scoped-define OPEN-QUERY-br-dpl OPEN QUERY br-dpl FOR EACH ub.prod-bc ~
      WHERE prod-bc.b-str = duplicate-str NO-LOCK, ~
      EACH ub.bar-code OF ub.prod-bc NO-LOCK, ~
      EACH ub.goods OF ub.bar-code NO-LOCK ~
    BY ub.goods.artic.
&Scoped-define TABLES-IN-QUERY-br-dpl ub.prod-bc ub.bar-code ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-dpl ub.prod-bc
&Scoped-define SECOND-TABLE-IN-QUERY-br-dpl ub.bar-code
&Scoped-define THIRD-TABLE-IN-QUERY-br-dpl ub.goods


/* Definitions for DIALOG-BOX b-bc-rcnz                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-b-bc-rcnz ~
    ~{&OPEN-QUERY-br-dpl}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-on b-help br-dpl
&Scoped-Define DISPLAYED-FIELDS ub.gds-prt.f-name ub.parts.part-code ~
ub.parts.in-code
&Scoped-define DISPLAYED-TABLES ub.gds-prt ub.parts
&Scoped-define FIRST-DISPLAYED-TABLE ub.gds-prt
&Scoped-define SECOND-DISPLAYED-TABLE ub.parts
&Scoped-Define DISPLAYED-OBJECTS duplicate-str

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-on
     LABEL "&Вкл/выкл"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE duplicate-str AS CHARACTER FORMAT "X(40)":U
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 41.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE req-price AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0
     LABEL "Цена"
     VIEW-AS FILL-IN
     SIZE 24.25 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dpl FOR
      ub.prod-bc,
      ub.bar-code,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dpl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dpl b-bc-rcnz _STRUCTURED
  QUERY br-dpl NO-LOCK DISPLAY
      ub.prod-bc.bc-on FORMAT "+/":U
      ub.goods.artic FORMAT "X(16)":U
      ub.goods.gds-name
      gds-price COLUMN-LABEL "Цена" FORMAT "->>>,>>>,>>>.<<":U
      ub.goods.engl-name FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79.75 BY 9.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME b-bc-rcnz
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-on AT ROW 1 COL 21
     b-help AT ROW 1 COL 31
     duplicate-str AT ROW 2.25 COL 10 COLON-ALIGNED
     req-price AT ROW 3.5 COL 10 COLON-ALIGNED
     br-dpl AT ROW 5.29 COL 2.88
     ub.gds-prt.f-name AT ROW 14.63 COL 60.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          FGCOLOR 4
     ub.parts.part-code AT ROW 14.67 COL 10.25 COLON-ALIGNED
          LABEL "Партия"
          VIEW-AS FILL-IN
          SIZE 25.75 BY 1
          FGCOLOR 4
     ub.parts.in-code AT ROW 15.71 COL 10.25 COLON-ALIGNED
          LABEL "Номер ПН"
          VIEW-AS FILL-IN
          SIZE 25.75 BY 1
          FGCOLOR 4
     SPACE(45.48) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Повторные дополнительные бар-коды"
         DEFAULT-BUTTON b-sel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX b-bc-rcnz
                                                                        */
/* BROWSE-TAB br-dpl req-price b-bc-rcnz */
ASSIGN
       FRAME b-bc-rcnz:SCROLLABLE       = FALSE
       FRAME b-bc-rcnz:HIDDEN           = TRUE.

ASSIGN
       br-dpl:NUM-LOCKED-COLUMNS IN FRAME b-bc-rcnz     = 2.

/* SETTINGS FOR FILL-IN duplicate-str IN FRAME b-bc-rcnz
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.gds-prt.f-name IN FRAME b-bc-rcnz
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.parts.in-code IN FRAME b-bc-rcnz
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.parts.part-code IN FRAME b-bc-rcnz
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN req-price IN FRAME b-bc-rcnz
   NO-DISPLAY NO-ENABLE                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX b-bc-rcnz
/* Query rebuild information for DIALOG-BOX b-bc-rcnz
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX b-bc-rcnz */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dpl
/* Query rebuild information for BROWSE br-dpl
     _TblList          = "ub.prod-bc,ub.bar-code OF ub.prod-bc,ub.goods OF ub.bar-code"
     _Options          = "NO-LOCK"
     _OrdList          = "ub.goods.artic|yes"
     _Where[1]         = "prod-bc.b-str = duplicate-str"
     _FldNameList[1]   > ub.prod-bc.bc-on
"prod-bc.bc-on" ? "+/" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   = ub.goods.artic
     _FldNameList[3]   > ub.goods.gds-name
"goods.gds-name" ? "X(35)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   > "_<CALC>"
"gds-price" "Цена" "->>>,>>>,>>>.<<" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   = ub.goods.engl-name
     _Query            is OPENED
*/  /* BROWSE br-dpl */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-bc-rcnz
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bc-rcnz b-bc-rcnz
ON WINDOW-CLOSE OF FRAME b-bc-rcnz /* Повторные дополнительные бар-коды */
DO:
  rid = ?.
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-on
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-on b-bc-rcnz
ON CHOOSE OF b-on IN FRAME b-bc-rcnz /* Вкл/выкл */
DO:
define variable glog as logical no-undo .
define variable v-rep-rec as recid no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define buffer prod-on for ub.prod-bc.
define buffer bc-on   for ub.bar-code.
  if not available ub.prod-bc then do:
    message "Неправильно выбран дополнительный бар-код.".
    return no-apply.
  end.
  find ub.units where ub.units.unit-name = ub.bar-code.unit-cli no-lock.
  if lookup({&weight}, ub.units.type) > 0 then do:
    message "Нельзя выключить весовой код.".
    return no-apply.
  end.
  if lookup({&pieces}, ub.units.type) > 0 then do:
      /*проверим что это не весовой и не петрол*/
      { gbl/prodbcat.i
        prod-on
        "'pgweight=request':u"
        l-prod-bc-pgweight
        no-error
      }
      if error-status:error then return no-apply.
      if l-prod-bc-pgweight then do:
        message "Нельзя выключить штучный код для весов.".
        return no-apply.
      end.
  end.
  define variable v-current-db-num as integer no-undo .
  define variable v-current-userid as character no-undo .
  /*НЕ МЕНЯТЬ НА getcntxt.i !!!!!!!!!*/
  run get-db-num in parparentproc ( output v-current-db-num).
  run get-userid in parparentproc ( output v-current-userid).
  { gbl/chk-actg.i
  v-current-db-num
  v-current-userid
  {&action-head-code-main}
  'actn_alt-barcode_turn-on':U
  {&cntxt-global}
  0
  '':U
  0
  0
  ub.goods.grp-code
  0
  true
  glog
  }
  if not glog then return no-apply.
  v-rep-rec = recid(prod-bc).
  run trg/bc-upd.p (
                input parparentproc
               ,input prod-bc.b-code
               ,input prod-bc.b-str
               ,input (NOT prod-bc.bc-on)
               ,input no
               ,input send-ref
               ,input ?
               ,input ?
               ) no-error  .
  if error-status:error then do:
    if return-value <> "":U then do:
      message
      return-value
      view-as alert-box .
    end.
    return no-apply.
  end.
  run enable_ui.
  apply "entry" to br-dpl in frame {&frame-name}.
  reposition br-dpl to recid v-rep-rec no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit b-bc-rcnz
ON CHOOSE OF b-quit IN FRAME b-bc-rcnz /* Выход */
DO:
  rid = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel b-bc-rcnz
ON CHOOSE OF b-sel IN FRAME b-bc-rcnz /* Выбор  */
DO:
  if c-point = "choose" then rid = recid (ub.prod-bc).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dpl
&Scoped-define SELF-NAME br-dpl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dpl b-bc-rcnz
ON MOUSE-SELECT-DBLCLICK OF br-dpl IN FRAME b-bc-rcnz
DO:
  apply "choose" to b-sel in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dpl b-bc-rcnz
ON RETURN OF br-dpl IN FRAME b-bc-rcnz
DO:
  apply "choose" to b-sel in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dpl b-bc-rcnz
ON VALUE-CHANGED OF br-dpl IN FRAME b-bc-rcnz
DO:
find first ub.parts where
           ub.parts.artic     = ub.goods.artic and
           ub.parts.prod-type = ub.goods.prod-type and
           ub.parts.prod-code = ub.goods.prod-code and
           ub.parts.part-code = ub.bar-code.part-code and
           ub.parts.in-code   = ub.bar-code.in-code no-lock no-error.
if available ub.parts then
  disp ub.parts.part-code ub.parts.in-code with frame {&frame-name}.
else
  disp "" @ ub.parts.part-code "" @ ub.parts.in-code with frame {&frame-name}.
find ub.gds-prt where
     ub.bar-code.node-code = ub.gds-prt.node-code no-lock.
disp ub.gds-prt.f-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK b-bc-rcnz


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

{ gbl/brwrepos.i
  &line-num=5
}

on find of ub.bar-code do:
  find ub.gds-obj where ub.gds-obj.obj-type  = p-curr-obj-type
                 and ub.gds-obj.obj-code  = p-curr-obj-code
                 and ub.gds-obj.gds-code  = ub.bar-code.gds-code
                 no-lock no-error.
  if available ub.gds-obj then
    gds-price  = ub.gds-obj.price-sale.
  else
    gds-price = 0.
end.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  duplicate-str = d-str.
  RUN enable_UI.
  if c-point <> {&update} then
    disable b-on with frame {&frame-name}.
  if c-point <> "choose" then do:
    b-sel:sensitive = no.
  end.
  if r-price <> ? and
     r-price <> 0 then do:
    /* программа вызвана из продажи (указана цена чека) */
    find ub.prod-bc where recid (ub.prod-bc) = rid no-lock.
    if not ub.prod-bc.bc-on then do:
      /* нет ни одного включенного при продаже - считаем код нераспознанным */
      rid = ?.
      return.
    end.
    run get-bc-price  in parparentproc (output v-bc-price) no-error .
    if v-bc-price then do:
      /* дополнительный режим - проверка цены чека */
      find ub.bar-code where
           ub.bar-code.b-code = ub.prod-bc.b-code no-lock.
      find ub.gds-obj where ub.gds-obj.obj-type = p-curr-obj-type
                     and ub.gds-obj.obj-code = p-curr-obj-code
                     and ub.gds-obj.gds-code = ub.bar-code.gds-code
                     no-lock no-error.
      if available ub.gds-obj and
         ub.gds-obj.price-sale = r-price and
         ub.prod-bc.bc-on then
        return.
    end.
    else
      /* основной режим - просто выбор включенного */
      if ub.prod-bc.bc-on then return.
    req-price = r-price.
    disp req-price with frame {&frame-name}.
  end.
  else hide req-price in frame {&frame-name}.
  assign ub.goods.gds-name:resizable in browse {&browse-name} = yes
         ub.goods.gds-name:width-chars in browse {&browse-name} = 35  .
  apply "value-changed" to br-dpl in frame {&frame-name}.
  reposition br-dpl to recid rid no-error.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-dpl.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI b-bc-rcnz  _DEFAULT-DISABLE
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
  HIDE FRAME b-bc-rcnz.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI b-bc-rcnz  _DEFAULT-ENABLE
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
  DISPLAY duplicate-str
      WITH FRAME b-bc-rcnz.
  IF AVAILABLE ub.gds-prt THEN
    DISPLAY ub.gds-prt.f-name
      WITH FRAME b-bc-rcnz.
  IF AVAILABLE ub.parts THEN
    DISPLAY ub.parts.part-code ub.parts.in-code
      WITH FRAME b-bc-rcnz.
  ENABLE b-quit b-sel b-on b-help br-dpl
      WITH FRAME b-bc-rcnz.
  VIEW FRAME b-bc-rcnz.
  {&OPEN-BROWSERS-IN-QUERY-b-bc-rcnz}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME