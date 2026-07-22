&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_cd-plu FOR ub.cd-plu.
DEFINE BUFFER locked_cash-desk FOR ub.cash-desk.
DEFINE BUFFER X_bar-code FOR ub.bar-code.
DEFINE BUFFER X_cd-plu FOR ub.cd-plu.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товары на кассе MARIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
DEFINE INPUT PARAMETER p-mode  AS CHARACTER NO-UNDO.
/*{&all} {&g___OBJECT}*/

DEFINE INPUT PARAMETER p-curr-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-curr-obj-code LIKE ub.clients.obj-code NO-UNDO.
define input parameter p-pos-type as character no-undo .
/*тип POS может быть {&cd-type-maria}*/

define input parameter p-plu-type as character no-undo .
/*для cd-type-maria '':U и {&petrolium}
*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары на кассе МАРИЯ".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/color.i    }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/cd-attr.i  }
{ str/cd-mrkt.i  }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

{ cmp/bb-list.i bb-list def "new shared" }
{ cmp/bb-list.i save-list def }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/goa-list.i goa-list def "NEW shared" }
define variable filter-label as character no-undo init "Товары на кассе МАРИЯ" .
define variable filter-label0 as character no-undo init "Товары на кассе МАРИЯ" .
define variable filter-point0 as character no-undo init "mrkt-gds" .
define variable filter-point as character no-undo init "mrkt-gds" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
DEFINE VARIABLE v-obj-db-num like ub.db.db-num no-undo .
define variable lns-cnt as integer no-undo .
define variable glog as logical no-undo .
define variable SendOption as character no-undo .
define variable v-cd-list-update as character no-undo .
define variable v-cd-list-delete as character no-undo .

/*параметры касс*/
DEFINE VARIABLE v-max-gds AS integer no-undo .
DEFINE VARIABLE v-max-plu AS integer no-undo .
DEFINE VARIABLE v-tot-gds AS integer no-undo .
DEFINE VARIABLE l-exist-cd AS logical no-undo .
define variable gds-rec as recid no-undo .
define variable line-rec as recid no-undo .

define buffer pos_cd-plu for ub.cd-plu.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_cd-plu no-lock where ~
                                  recid(pos_cd-plu) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ТОВАРА НА КАССЕ" skip~
                            string(if avail pos_cd-plu ~
                                    then  substitute("PLU: &1, бар-код &2" ~
                                                    , pos_cd-plu.plu-code  ~
                                                    , pos_cd-plu.b-code) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

&scop lamp-image ~
do with frame {&frame-name}: ~
  if l-exist-~{&lamp-var~} then  ~
    /* лампочка должна гореть */ ~
    assign ~
      glog = ~{&lamp-var~}-image:load-image ("cmp/l-~{&lamp-var~}.bmp") ~
      ~{&lamp-var~}-image :selectable = yes ~
      ~{&lamp-var~}-image :sensitive = yes ~
      ~{&lamp-var~}-image :tooltip = ~{&lamp-var~}-image :private-data ~
      .  ~
  else do: ~
    assign ~
    glog = ~{&lamp-var~}-image:load-image (?) ~
      ~{&lamp-var~}-image :selectable = no ~
      ~{&lamp-var~}-image :sensitive = no ~
      ~{&lamp-var~}-image :tooltip = '':U ~
    . ~
  end. ~
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-mgds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cd-plu X_bar-code X_goods

/* Definitions for BROWSE BR-mgds                                       */
&Scoped-define FIELDS-IN-QUERY-BR-mgds X_cd-plu.plu-code X_cd-plu.b-str X_cd-plu.b-code X_cd-plu.to-del X_goods.gds-name X_cd-plu.to-send X_goods.artic X_cd-plu.key#_ONE get-prod-name(buffer X_goods) X_goods.prod-type + string(X_goods.prod-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-mgds
&Scoped-define SELF-NAME BR-mgds
&Scoped-define QUERY-STRING-BR-mgds FOR EACH X_cd-plu NO-LOCK, ~
             EACH X_bar-code OF X_cd-plu NO-LOCK, ~
             EACH X_goods OF X_bar-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-mgds OPEN QUERY {&SELF-NAME} FOR EACH X_cd-plu NO-LOCK, ~
             EACH X_bar-code OF X_cd-plu NO-LOCK, ~
             EACH X_goods OF X_bar-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-mgds X_cd-plu X_bar-code X_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BR-mgds X_cd-plu
&Scoped-define SECOND-TABLE-IN-QUERY-BR-mgds X_bar-code
&Scoped-define THIRD-TABLE-IN-QUERY-BR-mgds X_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-mgds}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit cd-image B-mark b-sel B-chg B-send ~
B-print B-sch B-Help a-n-c loc-name loc-code BR-mgds B-up B-down mark-num ~
f-max-gds f-tot-gds f-max-plu
&Scoped-Define DISPLAYED-OBJECTS a-n-c loc-name loc-code mark-num f-max-gds ~
f-tot-gds f-max-plu

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-prod-name Dialog-Frame
FUNCTION get-prod-name RETURNS CHARACTER
  ( BUFFER buf_goods FOR ub.goods )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-B-send
       MENU-ITEM m_all          LABEL "Все"
       MENU-ITEM m_changed      LABEL "Измененные"
       RULE
       MENU-ITEM m_send-stock-qnty LABEL "Отсылать остатки"
              TOGGLE-BOX.


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-down
     LABEL "В&низ"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-send
     LABEL "&Послать"
     SIZE 10 BY 1.

DEFINE BUTTON B-up
     LABEL "Вв&ерх"
     SIZE 10 BY 1.

DEFINE VARIABLE f-max-gds AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Max кол-во кодов"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-max-plu AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Max тек plu"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-tot-gds AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Тек кол-во кодов"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "X(256)":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE IMAGE cd-image
     FILENAME "adeicon/blank":U
     SIZE 3 BY 1 TOOLTIP "Отправьте товары на кассы".

DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Код", "b-code",
"&Доп.БК/лок.EAN", "b-str",
"&PLU", "plu"
     SIZE 29.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-mgds FOR
      X_cd-plu,
      X_bar-code,
      X_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-mgds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-mgds Dialog-Frame _FREEFORM
  QUERY BR-mgds NO-LOCK DISPLAY
      X_cd-plu.plu-code COLUMN-LABEL "PLU" FORMAT "9999":U
X_cd-plu.b-str COLUMN-LABEL "ДопБК/лок.ЕАН" FORMAT "X(18)":U
X_cd-plu.b-code COLUMN-LABEL "Бар-код!IBS TH" FORMAT "999999999":U
    WIDTH 10
X_cd-plu.to-del COLUMN-LABEL "У" FORMAT "У/":U
X_goods.gds-name FORMAT "X(30)":U
X_cd-plu.to-send COLUMN-LABEL "И" FORMAT "И/":U
X_goods.artic FORMAT "X(16)":U
X_cd-plu.key#_ONE COLUMN-LABEL "Резервуар!код" FORMAT ">>>>>>>>9":U
get-prod-name(buffer X_goods) COLUMN-LABEL "Назв. произв-ля" FORMAT "X(25)":U
    WIDTH 27
X_goods.prod-type + string(X_goods.prod-code) COLUMN-LABEL "Пр-ль" FORMAT "X(12)":U
    WIDTH 14
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.25 BY 17.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-chg AT ROW 1 COL 41
     B-send AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     a-n-c AT ROW 2 COL 2 NO-LABEL
     loc-name AT ROW 2 COL 55 COLON-ALIGNED
     loc-code AT ROW 2 COL 55 COLON-ALIGNED
     BR-mgds AT ROW 4.25 COL 1
     B-up AT ROW 8.75 COL 1
     B-down AT ROW 9.75 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     f-max-gds AT ROW 3 COL 1
     f-tot-gds AT ROW 3 COL 25
     f-max-plu AT ROW 3 COL 50
     cd-image AT ROW 2.25 COL 92
     SPACE(4.30) SKIP(18.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары на кассе".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_cd-plu B "?" ? ub cd-plu
      TABLE: locked_cash-desk B "?" ? ub cash-desk
      TABLE: X_bar-code B "?" ? ub bar-code
      TABLE: X_cd-plu B "?" ? ub cd-plu
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-mgds loc-code Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-down:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-send:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-B-send:HANDLE.

ASSIGN
       B-up:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-max-gds IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-max-plu IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-tot-gds IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-mgds
/* Query rebuild information for BROWSE BR-mgds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_cd-plu NO-LOCK,
      EACH X_bar-code OF X_cd-plu NO-LOCK,
      EACH X_goods OF X_bar-code NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-mgds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары на кассе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME a-n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c Dialog-Frame
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
    case input frame {&frame-name} a-n-c :
    when "b-code" then do:
      enable
      loc-code
      with frame {&frame-name}.
      loc-code:label = "Бар-код (весь)".
      display
      loc-code
      with frame {&frame-name}.
      hide
      loc-name
      in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
    when "PLU" then do:
      enable
      loc-code
      with frame {&frame-name}.
      loc-code:label = "PLU (без № маг)".
      display
      loc-code
      with frame {&frame-name}.
      hide
      loc-name
      in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
    when "b-str" then do:
      enable
      loc-name
      with frame {&frame-name}.
      loc-name:label = "Доп.БК".
      display
      loc-name
      with frame {&frame-name}.
      hide
      loc-code
      in frame {&frame-name}.
      apply "entry" to loc-name in frame {&frame-name}.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-down Dialog-Frame
ON CHOOSE OF B-down IN FRAME Dialog-Frame /* Вниз */
DO:
{ gbl/stdbtn.i }
DEFINE VARIABLE v-new AS integer NO-UNDO.
DEFINE VARIABLE v-old AS integer NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-rec as recid no-undo .
DEFINE BUFFER buf_cd-plu FOR ub.cd-plu.
IF NOT AVAILABLE X_cd-plu THEN RETURN NO-APPLY.

FIND last buf_cd-plu where
        buf_cd-plu.obj-type = p-curr-obj-type
    and buf_cd-plu.obj-code = p-curr-obj-code
    and buf_cd-plu.pos-type = p-pos-type
    and buf_cd-plu.plu-type = p-plu-type  USE-INDEX pi .
 IF buf_cd-plu.plu-code = X_cd-plu.plu-code THEN DO:
     BELL.
     RETURN NO-APPLY.
 END.
 ASSIGN
 v-rec = recid(X_cd-plu)
 v-old = X_cd-plu.plu-code
 v-ii = X_cd-plu.plu-code
 v-ii = v-ii + 1
 v-new = v-ii
 .
 FIND FIRST buf_cd-plu WHERE
        buf_cd-plu.obj-type = p-curr-obj-type
    and buf_cd-plu.obj-code = p-curr-obj-code
    and buf_cd-plu.pos-type = p-pos-type
    and buf_cd-plu.plu-type = p-plu-type
    and buf_cd-plu.plu-code= v-new NO-ERROR.
 ASSIGN
 buf_cd-plu.plu-code = 0.
 RELEASE buf_cd-plu.
 FIND FIRST buf_cd-plu WHERE
        buf_cd-plu.obj-type = p-curr-obj-type
    and buf_cd-plu.obj-code = p-curr-obj-code
    and buf_cd-plu.pos-type = p-pos-type
    and buf_cd-plu.plu-type = p-plu-type
    and buf_cd-plu.plu-code= v-old NO-ERROR.
ASSIGN
buf_cd-plu.plu-code = v-new.
RELEASE buf_cd-plu.
FIND FIRST buf_cd-plu WHERE
        buf_cd-plu.obj-type = p-curr-obj-type
    and buf_cd-plu.obj-code = p-curr-obj-code
    and buf_cd-plu.pos-type = p-pos-type
    and buf_cd-plu.plu-type = p-plu-type
    and buf_cd-plu.plu-code = 0 USE-INDEX pi .
buf_cd-plu.plu-code = v-old.
RELEASE buf_cd-plu.
RUn OpenBR IN THIS-PROCEDURE ( input yes, input no, input '':U).
reposition br-mgds to recid v-rec no-error .
apply "ENTRY" to  br-mgds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_cd-plu then do:
    { gbl/markstrn.i X_cd-plu p-rid-list }
    loc#log = br-mgds:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-mgds:select-next-row ().
        apply "VALUE-CHANGED" to br-mgds in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-mgds in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_cd-plu then return no-apply.
  run proc-b-print in this-procedure  no-error.
  if error-status:error then do:
     return no-apply.
  end.
  APPLY "ENTRY" to br-mgds.
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
  if ( available X_cd-plu ) then do:
    if ( p-rid-list = "" ) or b-mark:sensitive = no then
    p-rid-list = string( recid( X_cd-plu ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-send Dialog-Frame
ON CHOOSE OF B-send IN FRAME Dialog-Frame /* Послать */
DO:
if p-plu-type = {&petrolium} then do:
  sendoption = "all":U.
end.
else do:
  if SendOption = "" then
  run gbl/pop-up.p (
                     input self:handle
                    ,input yes) no-error.
  if SendOption = "" then return no-apply.
end.
if SendOption = "" then
run gbl/pop-up.p ( input self:handle, input yes) no-error.
if SendOption = "" then return no-apply.

v-doc-rec = recid(X_cd-plu).

define variable v-chk-act-host-code as integer   no-undo .
{ gbl/hostcode.i
  p-curr-obj-type
  p-curr-obj-code
  v-chk-act-host-code
}

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cashdesk-goods_add-def':U
  {&cntxt-object}
  v-chk-act-host-code
  p-curr-obj-type
  p-curr-obj-code
  0
  0
  0
  true
  glog
}

if NOT glog THEN return no-apply.

/*при вызове general-send из интерфейса - спросим на все объекты или текущий -
третий параметр вызова = ""*/
RUN general-send in this-procedure no-error.
if error-status:error then do:
    Sendoption = "".
  return no-apply.
end.
Sendoption = "".
RUn OpenBR in this-procedure ( input yes, input no, input '':U).
run disp-cd in this-procedure .
reposition br-mgds to recid v-doc-rec no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-up Dialog-Frame
ON CHOOSE OF B-up IN FRAME Dialog-Frame /* Вверх */
DO:
{ gbl/stdbtn.i }
DEFINE VARIABLE v-new AS integer NO-UNDO.
DEFINE VARIABLE v-old AS integer NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-rec as recid no-undo .
DEFINE BUFFER buf_cd-plu FOR ub.cd-plu.
 IF NOT AVAILABLE X_cd-plu THEN RETURN NO-APPLY.
 IF X_cd-plu.plu-code = 1 THEN DO:
     BELL.
     RETURN NO-APPLY.
 END.
 ASSIGN
 v-rec = recid(X_cd-plu)
 v-old = X_cd-plu.plu-code
 v-ii =  X_cd-plu.plu-code
 v-ii = v-ii - 1
 v-new = 0
 .
 FIND FIRST buf_cd-plu WHERE
           buf_cd-plu.obj-type = p-curr-obj-type
       and buf_cd-plu.obj-code = p-curr-obj-code
       and buf_cd-plu.pos-type = p-pos-type
       and buf_cd-plu.plu-type = p-plu-type
       and buf_cd-plu.plu-code = v-new NO-ERROR.
 ASSIGN
 buf_cd-plu.plu-code = 0.
 RELEASE buf_cd-plu.
 FIND FIRST buf_cd-plu WHERE
           buf_cd-plu.obj-type = p-curr-obj-type
       and buf_cd-plu.obj-code = p-curr-obj-code
       and buf_cd-plu.pos-type = p-pos-type
       and buf_cd-plu.plu-type = p-plu-type
       and buf_cd-plu.plu-code = v-old.
 buf_cd-plu.plu-code = v-new.
 RELEASE buf_cd-plu.
 FIND FIRST buf_cd-plu WHERE
           buf_cd-plu.obj-type = p-curr-obj-type
       and buf_cd-plu.obj-code = p-curr-obj-code
       and buf_cd-plu.pos-type = p-pos-type
       and buf_cd-plu.plu-type = p-plu-type
       and buf_cd-plu.plu-code = 0.
 ASSIGN
 buf_cd-plu.plu-code = v-old.
 RELEASE buf_cd-plu.
 RUn OpenBR IN THIS-PROCEDURE ( input yes, input no, input '':U).
reposition br-mgds to recid v-rec no-error .
apply "ENTRY" to br-mgds.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cd-image
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cd-image Dialog-Frame
ON MOUSE-SELECT-CLICK OF cd-image IN FRAME Dialog-Frame
OR selection of cd-image DO:
  if p-plu-type = {&petrolium} then return no-apply.
  /*послать все неотосланное на кассу*/
  run general-send in this-procedure  no-error .
  RUn OpenBR IN THIS-PROCEDURE ( input yes, input no, input '':U).
  run fill-vars in this-procedure no-error .
  run disp-cd in this-procedure no-error.
  reposition br-mgds to recid v-doc-rec no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-code Dialog-Frame
ON CTRL-J OF loc-code IN FRAME Dialog-Frame
DO:
    run proc-find-code in this-procedure ( input a-n-c, input YES, input frame {&frame-name} loc-code) no-error.
    if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-code Dialog-Frame
ON RETURN OF loc-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( input a-n-c, input no, input frame {&frame-name} loc-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-name Dialog-Frame
ON CTRL-J OF loc-name IN FRAME Dialog-Frame
DO:
  run proc-find-b-str in this-procedure ( input a-n-c, input YES, input frame {&frame-name} loc-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-name Dialog-Frame
ON RETURN OF loc-name IN FRAME Dialog-Frame
DO:
    run proc-find-b-str in this-procedure ( input a-n-c, input NO, input frame {&frame-name} loc-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* Все */
DO:
    assign
  SendOption = "ALL":U.
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_changed
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_changed Dialog-Frame
ON CHOOSE OF MENU-ITEM m_changed /* Измененные */
DO:
    assign
  SendOption = "changed":U.
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-mgds
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/f2.i br-mgds goods-recid get-gds-recid parparentproc }
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_cd-plu.plu-code"
  &sort-clmn_2    = "X_cd-plu.b-code"
  &sort-clmn_3    = "X_cd-plu.b-str"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/mv-clmn.i
&browse-name = "br-mgds"
&frame-name = "{&frame-name}"
&ext-col = 10
&start-column = 2
&prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10'"
&prev-order-column-condition_1 = " true "
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }


    if p-mode <> {&all}
    AND p-mode <> {&g___object} then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.

 find first X_clients no-lock where
                X_clients.obj-type = p-curr-obj-type
            and X_clients.obj-code = p-curr-obj-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-curr-obj-type и/или p-curr-obj-code"
          view-as alert-box ERROR.
        return.
    end.
  if p-rid-list <> "" then do:
      FIND FIRST find_cd-plu No-LOCK where
                 recid(find_cd-plu) = integer(entry(1, p-rid-list)) No-ERROR.
      if not avail find_cd-plu then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-rid-list" p-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, p-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  { gbl/objdbnum.i p-curr-obj-type p-curr-obj-code v-obj-db-num }
  if v-obj-db-num <> v-db-num then do:
    message
    "Нельзя работать с товарами кассы объекта удаленной БД"
    view-as alert-box error .
    undo, return error .
  end.
  do transaction
  on error undo main-block, return error
  :
    FIND FIRST LOCKED_cash-desk EXCLUSIVE-LOCK WHERE
              LOCKED_cash-desk.obj-code = p-curr-obj-code
          AND LOCKED_cash-desk.db-num = v-db-num
          AND LOCKED_cash-desk.pos-type = p-pos-type
          AND (p-pos-type = {&cd-type-maria} or LOCKED_cash-desk.cash-num = 0) NO-WAIT NO-ERROR.
    IF NOT AVAILABLE locked_cash-desk AND NOT LOCKED locked_cash-desk THEN DO:
        MESSAGE
        SUBSTITUTE("На &1&2 не определена касса типа &3 с номером 0 - кассовый менеджер&4" +
                  "Нельзя работать с товарами на кассе"
                  , p-curr-obj-type
                  , p-curr-obj-code
                  , p-pos-type
                  , {&new-line}
                  )
      VIEW-AS ALERT-BOX ERROR.
      UNDO main-block, RETURN ERROR.
    END.
    IF LOCKED locked_cash-desk THEN DO:
        MESSAGE
        SUBSTITUTE("На &1&2 в настоящее время занята запись кассы типа &3&4" +
                  "с номером 0 - кассовый менеджер" +
                  "Нельзя работать с товарами на кассе"
                  , p-curr-obj-type
                  , p-curr-obj-code
                  , p-pos-type
                  , {&NEW-LINE})
      VIEW-AS ALERT-BOX ERROR.
      UNDO main-block, RETURN ERROR.
    END.
    case p-pos-type:
      when {&cd-type-maria} then do:
         assign
         v-cd-list-delete = locked_cash-desk.addr-path
         v-cd-list-update = locked_cash-desk.addr-path
         .
      end.
    END CASE.
  end.
  RUN fill-vars IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN UNDO main-block, RETURN ERROR.
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure  ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if p-rid-list <> "":U then
  REPOSITION br-mgds to recid integer(entry(1, p-rid-list)) No-ERROR.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-cd Dialog-Frame
PROCEDURE disp-cd :
/*----------------------------------------------------------
проверка и вывод значения "Требуется отправка на кассы"
----------------------------------------------------------*/
DEFINE VARIABLE v-mes AS CHARACTER NO-UNDO.
define buffer buf_cd-plu for ub.cd-plu .
if p-plu-type = {&petrolium} then do:
  l-exist-cd = cd-attr_get-attr-log(buffer locked_cash-desk
                                  ,input {&cda-maria_operative}
                                  ,input {&cda-maria_operative_petrol-to-send}
                                  ,output v-mes).
end.
else do:
  l-exist-cd = cd-attr_get-attr-log(buffer locked_cash-desk
                                  ,input {&cda-maria_operative}
                                   ,input {&cda-maria_operative_to-send}
                                   ,output v-mes).
end.
if l-exist-cd = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.

&scop lamp-var cd
{&lamp-image}

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
  DISPLAY a-n-c loc-name loc-code mark-num f-max-gds f-tot-gds f-max-plu
      WITH FRAME Dialog-Frame.
  ENABLE b-quit cd-image B-mark b-sel B-chg B-send B-print B-sch B-Help a-n-c
         loc-name loc-code BR-mgds B-up B-down mark-num f-max-gds f-tot-gds
         f-max-plu
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-vars Dialog-Frame
PROCEDURE fill-vars :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-mes as character no-undo .
do
on error undo, return error
:

if p-plu-type = '':U then do:
  v-tot-gds = cd-attr_get-attr-int(buffer locked_cash-desk
                                  ,input {&cda-maria_operative}
                                  ,input {&cda-maria_operative_tot-gds}
                                  ,output v-mes).
end.
else do:
  v-tot-gds = cd-attr_get-attr-int(buffer locked_cash-desk
                                   ,input {&cda-maria_operative}
                                   ,input {&cda-maria_operative_tot-petrol}
                                   ,output v-mes).
end.
if v-tot-gds = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
if p-plu-type = '':U then do:
  v-max-gds = cd-attr_get-attr-int(buffer locked_cash-desk
                                  ,input {&cda-maria_general}
                                  ,input {&cda-maria_general_max-gds}
                                  ,output v-mes).
end.
else do:
  v-max-gds = cd-attr_get-attr-int(buffer locked_cash-desk
                                  ,input {&cda-maria_general}
                                  ,input {&cda-maria_general_petrolium-range}
                                  ,output v-mes).
end.
if v-max-gds = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
if p-plu-type = '':U then do:
  v-max-plu = cd-attr_get-attr-int(buffer locked_cash-desk
                                  ,input {&cda-maria_operative}
                                  ,input {&cda-maria_operative_max-plu}
                                  ,output v-mes).
end.
else do:
  v-max-plu = cd-attr_get-attr-int(buffer locked_cash-desk
                                  ,input {&cda-maria_operative}
                                  ,input {&cda-maria_operative_max-petrol-plu}
                                  ,output v-mes).
end.
if v-max-plu = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
if p-plu-type = '':U then do:
  l-exist-cd = cd-attr_get-attr-log(buffer locked_cash-desk
                                    ,input {&cda-maria_operative}
                                    ,input {&cda-maria_operative_to-send}
                                    ,output v-mes).
end.
else do:
  l-exist-cd = cd-attr_get-attr-log(buffer locked_cash-desk
                                   ,input {&cda-maria_operative}
                                   ,input {&cda-maria_operative_petrol-to-send}
                                   ,output v-mes).
end.
if l-exist-cd  = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
end. /*doe*/
DISPLAY
v-tot-gds @ f-tot-gds
v-max-gds @ f-max-gds
v-max-plu @ f-max-plu
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE general-send Dialog-Frame
PROCEDURE general-send :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE err1 as logical init yes.
DEFINE VARIABLE jj as integer no-undo.
define variable v-step as integer no-undo .
define variable glog as logical no-undo .
define buffer buf_cd-plu  for ub.cd-plu.
define buffer buf_bar-code for ub.bar-code.

/*
коментарим прием с касс
run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input 'str/get-chkf.p':U
              , input (p-curr-obj-type + {&delim-par} + string(p-curr-obj-code) + {&delim-par} + string(0))
              , input yes
              , input '':U
              , input 'Прием чеков с касс') no-error .
if error-status:error then do:
    return error .
end.
if return-value = "error":U then return error .
*/
message
"Вы уверены что Вы приняли ВСЕ ЧЕКИ С КАССЫ?" skip
"В противном случае при изменении ассортимента товаров на кассе," skip
"может возникнуть ПЕРЕСОРТИЦА и/или появиться чеки с НЕОПОЗНАННЫМ ТОВАРОМ"
view-as alert-box QUESTION buttons YES-NO update glog.
if not glog then return error .

  FOR EACH gds-list :
    delete gds-list .
  END .

do
on error undo, return error
:


_zz:
DO ON STOP UNDO, return error
      ON END-KEY UNDO, return error
      ON ERROR UNDO, LEAVE:
  run waitfram-show in this-procedure ( input {&MyWaitMess} ) .
  jj = 0.
  _jj:
  FOR EACH buf_cd-plu WHERE
          buf_cd-plu.obj-type = p-curr-obj-type
       and buf_cd-plu.obj-code = p-curr-obj-code
       and buf_cd-plu.pos-type = p-pos-type
       and buf_cd-plu.plu-type = p-plu-type ,
      first buf_bar-code no-lock where
          buf_bar-code.b-code = buf_cd-plu.b-code,
      first ub.goods no-lock where
            ub.goods.gds-code = buf_bar-code.gds-code:
    IF sendoption <> "ALL"
    AND buf_cd-plu.charkey_one = "":U
    AND  buf_cd-plu.charkey_two = "":U THEN NEXT _jj.
    { cmp/gds-list.i gds-list assign }
    jj = jj + 1.
    if ( jj modulo 10 = 0 ) then
    run waitfram-show in this-procedure ( input substitute("Обработано &1 кодов", jj)).
      /*buf_cd-plu.stato-send = FALSE .*/
  END.
END. /*of transaction*/
  run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input 'str/send-gds.p':U
              , input (string( - p-curr-obj-code) + {&delim-par} +
                 "no":U + {&delim-par} +
                 ("del-mrkt-gds":U +
                  (if menu-item m_send-stock-qnty:checked in menu popup-menu-b-send
                   then ({&comma-char} + 'send-stock-qnty' )
                   else '':U))
                 )
              , input no /*p-auto-go*/
              , input '':U
              , input 'Отправка товаров на кассу') no-error .



run cd-mrkt_update-marketer in this-procedure (
                                                input locked_cash-desk.db-num
                                                ,input locked_cash-desk.obj-code
                                                ,input locked_cash-desk.pos-type
                                                ,input locked_cash-desk.cash-num
                                                ,input (p-pos-type = {&cd-type-maria}
                                                       AND p-plu-type = {&petrolium})
                                              )  .

end. /*doe*/
run fill-vars in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-gds-recid Dialog-Frame
PROCEDURE get-gds-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF NOT AVAIL X_goods THEN gds-rec = ?.
ELSE gds-rec = RECID(X_goods).
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
ASSIGN b-send:MENU-MOUSE in frame {&frame-name}  = 1.
ASSIGN
cd-image:private-data in frame {&frame-name} = cd-image:TOOLTIP
cd-image:fgcolor in frame {&frame-name} = GRAY_COLOR
cd-image:bgcolor in frame {&frame-name} = GRAY_COLOR
.
/*
if p-plu-type = {&petrolium} then do:
   assign
   X_cd-plu.b-str:width  in browse br-mgds  = X_cd-plu.b-str:width  in browse br-mgds - 11
   br-mgds:width-chars = br-mgds:width-chars - 11
   br-mgds:column = 11
   .
end.
*/
if p-plu-type = {&petrolium} then do:
  X_cd-plu.key#_one:visible in browse br-mgds = yes.
end.

ASSIGN
MENU-ITEM m_send-stock-qnty:SENSITIVE IN MENU popup-menu-b-send = (p-pos-type = {&cd-type-maria} AND p-plu-type = {&petrolium})
.

DISPLAY
a-n-c
loc-name
loc-code
mark-num
WITH FRAME {&frame-name} .
ENABLE
b-quit
B-mark WHEN LOOKUP("b-mark", bttns) > 0
b-sel  WHEN LOOKUP("b-sel", bttns) > 0
B-chg
B-sch
B-print
B-Help
b-send
a-n-c
loc-name
loc-code
BR-mgds
mark-num
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
hide
loc-name in frame {&frame-name}.
if p-plu-type = {&petrolium} then do:
  assign
  B-send:POPUP-MENU IN FRAME {&frame-name} =  ?
  b-send:tooltip = "Пересылка цен и скидок"
  .
  hide
  cd-image in frame {&frame-name}.
  /*
  enable
  b-up
  b-down
  with frame {&frame-name}.
  */
end.
RUN disp-cd IN THIS-PROCEDURE.
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
title0 = substitute("Товары на кассе &1 &2 "
                    , p-pos-type
                    , (if p-pos-type = {&cd-type-maria}
                      and p-plu-type = {&petrolium}
                      then  " - НЕФТЕПРОДУКТЫ"
                      else '':U)).

run waitfram-show in this-procedure ( input "Ждите...").
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

&scop flt-open-open-query OPEN QUERY br-mgds FOR EACH X_cd-plu

&scop flt-open-dyn_open-query FOR EACH X_cd-plu

&scop flt-open-query-handle QUERY br-mgds:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_cd-plu

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_cd-plu


&scop flt-open-open-query-tail , first X_bar-code NO-LOCK WHERE X_bar-code.b-code = X_cd-plu.b-code OUTER-JOIN , ~
                                FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_bar-code.gds-code OUTER-JOIN


&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


CASE p-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1", filter-label0)
    .
    if p-open-query then do:
      frame {&frame-name}:TITLE = title0.
    end.
  { gbl/fltopend.i
    &where-cond = " X_cd-plu.pos-type = p-pos-type and X_cd-plu.plu-type = p-plu-type "
    &dyn_where-cond = " substitute('X_cd-plu.pos-type = &1&2&1 and X_cd-plu.plu-type = &1&3&1 ', ~{&double-quote~}, p-pos-type, p-plu-type)"
    &use-ind    = "  "
    &by         = "  "
    }

  END.
  WHEN {&g___object} THEN DO:
    ASSIGN
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Один объект", filter-label0)
    .
    if p-open-query then do:
      frame {&frame-name}:TITLE = title0 +
                                  substitute(" &1&2", p-curr-obj-type, p-curr-obj-code).
    end.

    { gbl/fltopend.i
      &where-cond = " ~
        X_cd-plu.obj-type = p-curr-obj-type and X_cd-plu.obj-code = p-curr-obj-code ~
        and X_cd-plu.plu-type = p-plu-type  and X_cd-plu.pos-type = p-pos-type ~
                    "
      &dyn_where-cond = " substitute(' X_cd-plu.obj-type = &1&2&1 and X_cd-plu.obj-code = &3 ~
        and X_cd-plu.plu-type = &1&4&1  and X_cd-plu.pos-type = &1&5&1 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-plu-type, p-pos-type)"

      &use-ind    = "  "
      &by         = "  "
      }

  END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-mgds to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-mgds:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-mgds in frame {&frame-name}.
APPLY "ENTRY" TO br-mgds.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable old-mode as char no-undo.
define variable old-handle as handle no-undo.
define variable old-type as char no-undo.
define variable old-stat as char no-undo.
define variable old-flag as logical no-undo.
define variable old-internal as logical no-undo.
DEFINE VARIABLE v-skip-next as logical no-undo .
DEFINE VARIABLE v-update as logical no-undo .
define variable v-f-name as character no-undo .
define variable l-empty-scale as logical no-undo .
define variable ves-err as integer no-undo .
define variable v-to-send as logical no-undo .
define variable v-mes as character no-undo .
define variable v-is-petrol as logical no-undo .
define variable bar_code as character no-undo .
define variable v-restore as logical   no-undo .
define variable v-pl-code as integer no-undo .
define variable v-found as logical no-undo .
define variable v-is-prt as logical no-undo .
define variable v-empty-code as integer no-undo .


define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_gds-prt for ub.gds-prt.
DEFINE BUFFER buf_cd-plu FOR ub.cd-plu.
define buffer check_cd-plu for ub.cd-plu.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_place for ub.place.


FOR EACH bb-list : /* Когда все ОК - цикл не вып-ся ни разу */
    delete bb-list.
END.
FOR EACH save-list:
  delete save-list.
end.
run waitfram-show in this-procedure ( input "ЖДИТЕ.  Заполняется список...").

_block:
DO ON error UNDO _block, return error
on stop undo _block, return error:

_cd-plu:
  FOR EACH buf_cd-plu  WHERE
         buf_cd-plu.obj-type = p-curr-obj-type
     and buf_cd-plu.obj-code = p-curr-obj-code
     and buf_cd-plu.pos-type = p-pos-type
     and buf_cd-plu.plu-type = p-plu-type
  by buf_cd-plu.plu-code:
     IF buf_cd-plu.charkey_one = v-cd-list-delete THEN NEXT.
     buf_cd-plu.charkey_one = v-cd-list-delete.

    FIND FIRST buf_bar-code WHERE
            buf_bar-code.b-code = buf_cd-plu.b-code NO-LOCK no-error .
    if not available buf_bar-code then do:
      assign
      buf_cd-plu.charkey_one = v-cd-list-delete
      buf_cd-plu.to-del = yes
      .
      next _cd-plu.
    end.
    FIND FIRST ub.goods WHERE
            ub.goods.gds-code = buf_bar-code.gds-code NO-LOCK.
    FIND FIRST buf_gds-prt where
                buf_gds-prt.upper-code = ub.goods.prt-root NO-LOCK .
    assign
    l-empty-scale =  (buf_gds-prt.node-name <> {&empty-scale})
    .

    if l-empty-scale then  do:
    end.
    else do:
      find first buf_gds-prt no-lock where
                buf_gds-prt.node-code = buf_bar-code.node-code no-error.
      if not available buf_gds-prt
      then v-f-name = "!!!Неизвестный признак шкалы".
      else v-f-name = buf_gds-prt.f-name.
    end.

    { cmp/bb-list.i bb-list assign goods buf_bar-code buf_prod-bc buf_cd-plu.b-str v-f-name buf_cd-plu.logkey_one }
    { cmp/bb-list.i save-list assign goods buf_bar-code buf_prod-bc buf_cd-plu.b-str v-f-name buf_cd-plu.logkey_one }
    assign
    buf_cd-plu.charkey_one = v-cd-list-delete
    buf_cd-plu.to-del = yes
    .
  /* пометка - потенциально лишняя запись */
  end.

run waitfram-hide in this-procedure .
END. /*block*/

run run-bb-list in this-procedure no-error .
if error-status:error then do:
  assign
  v-restore = yes.
end.
if not v-restore then do:
  message
  substitute("Вы действительно хотите изменить список товаров на кассах &4 на &1&2&3" +
            "в соответствии с данным списком кодов?"
            , p-curr-obj-type
            , p-curr-obj-code
            , {&new-line}
            , p-pos-type
            )
  view-as alert-box QUESTION buttons YES-NO update v-update.
end.
if not v-update then do:
  FOR EACH bb-list:
    delete bb-list.
  END.
  FOR EACH buf_cd-plu where
         buf_cd-plu.obj-type = p-curr-obj-type
     and buf_cd-plu.obj-code = p-curr-obj-code
     and buf_cd-plu.pos-type = p-pos-type
     and buf_cd-plu.plu-type = p-plu-type,
      FIRST save-list WHERE
            save-list.b-code = buf_cd-plu.b-code
         AND save-list.b-str = buf_cd-plu.b-str NO-LOCK:
    assign
    buf_cd-plu.charkey_one = "":U
    buf_cd-plu.to-del = no
    .
    delete save-list.
  end.
    return .
end. /*if not v-update then do:*/
run waitfram-show in this-procedure ( input "ЖДИТЕ.  Началось изменение справочника.").
ves-err = 0.
{ gbl/objat.i p-curr-obj-type p-curr-obj-code "'doc-prt=request'" v-is-prt }
v-empty-code = ?.
{ gbl/emptyscl.i v-empty-code  }
DO ON error UNDO, return error :
_TO-GDS:
FOR EACH bb-list:
  ACCUMULATE bb-list.b-str ( count ).
  if ( accum count bb-list.b-str ) modulo 100 = 0 then do:
    run waitfram-show in this-procedure ( input ("ЖДИТЕ.  Обработано строк списка : " +
                                   string ( accum count bb-list.b-str ) ) ).
  end.
  /*проверим что если это признак - то на объекте включены признаки */
  if v-is-prt = no
  and bb-list.node-code <> v-empty-code  then do:
     ves-err = ves-err + 1.
     next _to-gds.
  end.
  /*топливные В МАРИЕ должны обрабатывать по-другом*/
  if p-plu-type = {&petrolium} then do:
    if bb-list.b-str <> '':U
    and bb-list.loc-ean = no then do:
      find first buf_prod-bc no-lock where
                buf_prod-bc.b-str = bb-list.b-str
            AND buf_prod-bc.b-code = bb-list.b-code no-error .
      if available buf_prod-bc then do:
        { gbl/prodbcat.i
          buf_prod-bc
        'petrolium=request':U
        v-is-petrol
        no-error }
        if error-status:error
        or not v-is-petrol then next _to-gds.
        /*найдем резервуары*/
        v-found = no.
        _pl-gds:
        for each buf_pl-gds no-lock where
              buf_pl-gds.obj-type = p-curr-obj-type
          AND buf_pl-gds.obj-code = p-curr-obj-code
          AND buf_pl-gds.gds-code = bb-list.gds-code
          AND buf_pl-gds.status_ = {&current-status},
            first buf_place no-lock where
                  buf_Place.obj-type = buf_pl-gds.obj-type
              and buf_Place.obj-code = buf_pl-gds.obj-code
              and buf_Place.pl-code = buf_pl-gds.pl-code:
          assign
          v-pl-code = integer(buf_place.loc1) no-error
          .
          if error-status:error then do:
            next _pl-gds.
          end.
          v-found = yes.
          FIND FIRST buf_cd-plu WHERE
                    buf_cd-plu.obj-type = p-curr-obj-type
                and buf_cd-plu.obj-code = p-curr-obj-code
                and buf_cd-plu.pos-type = p-pos-type
                and buf_cd-plu.plu-type = p-plu-type
                and buf_cd-plu.plu-code = v-pl-code
                AND buf_cd-plu.b-code = bb-list.b-code
                AND buf_cd-plu.b-str = bb-list.b-str
                AND buf_cd-plu.key#_one = buf_pl-gds.pl-code NO-ERROR.
          if available buf_cd-plu then do:
            assign
            buf_cd-plu.charkey_one = "":U
            buf_cd-plu.to-del = no
            .    /* отметка, что запись нужна */
          end.
          else do:
            if v-skip-next then do:
              delete bb-list.
            end.
            else do:
              find first check_cd-plu WHERE
                    check_cd-plu.obj-type = p-curr-obj-type
                and check_cd-plu.obj-code = p-curr-obj-code
                and check_cd-plu.pos-type = p-pos-type
                and check_cd-plu.plu-type = p-plu-type
                and check_cd-plu.plu-code = buf_cd-plu.plu-code no-error .
              if available check_cd-plu then do:
                /*даже если он со статусом удаляется - все равно сначал он должне уйти с кассы - а потом уже добавится*/
                ves-err = ves-err + 1.
                next _pl-gds.
              end.
              run cd-mrkt_plu-marketer in this-procedure (
                                                            input no /*p-silence*/
                                                            ,buffer locked_cash-desk
                                                            ,input buf_place.loc1
                                                            ,input bb-list.b-code
                                                            ,input bb-list.b-str
                                                            ,input bb-list.loc-ean
                                                            ,input v-is-petrol
                                                            ,input string(buf_place.pl-code)
                                                            ) no-error.
              if error-status:error then do:
                if return-value = "max-gds":U then dO:
                  assign
                  v-skip-next = yes
                  ves-err = ves-err + 1.
                  NEXT _pl-gds.
                end.
                else do:
                  ves-err = ves-err + 1.
                  next _pl-GDS.
                end.
              end. /*if error-status:error then do:*/
              else do:
                delete bb-list.
              end.
            end. /*not skip:*/
          end. /*not availabuf_cd-plu-*/
        end. /*for each buf_pl-gds no-lock where*/
        if not v-found then do:
          ves-err = ves-err + 1.
        end.
      end. /*avail prod-bc      end.*/
    end. /*if bb-list.b-str <> '':U*/
  end. /*if p-plu-type = {&petrolium} then do:*/
  else do:
    FIND FIRST buf_cd-plu WHERE
              buf_cd-plu.obj-type = p-curr-obj-type
          and buf_cd-plu.obj-code = p-curr-obj-code
          and buf_cd-plu.pos-type = p-pos-type
          and buf_cd-plu.plu-type = p-plu-type
          AND buf_cd-plu.b-code = bb-list.b-code
         AND buf_cd-plu.b-str = bb-list.b-str NO-ERROR.
    if available buf_cd-plu then do:
      assign
      buf_cd-plu.charkey_one = "":U
      buf_cd-plu.to-del = no
      .    /* отметка, что запись нужна */
    end.
    else do:
      if v-skip-next then do:
        delete bb-list.
      end.
      else do:
        v-is-petrol = no.
        /*для MARKETER*/
        CASE p-pos-type:
          when {&cd-type-maria} then do:
            /*должны определить уникальный или нет этот b-code на кассе*/
            find first check_cd-plu WHERE
                    check_cd-plu.obj-type = p-curr-obj-type
                and check_cd-plu.obj-code = p-curr-obj-code
                and check_cd-plu.pos-type = p-pos-type
                and check_cd-plu.plu-type = p-plu-type
                AND check_cd-plu.b-code = bb-list.b-code NO-ERROR.
            if available check_cd-plu then do:
              /*даже если он со статусом удаляется - все равно сначал он должне уйти с кассы - а потом уже добавится*/
              ves-err = ves-err + 1.
              next _to-gds.
            end.
            /*должны определить - топливный это или нет*/
            if  bb-list.b-str <> "":U
            and bb-list.loc-ean = no
            then do:
              find first buf_prod-bc no-lock where
                        buf_prod-bc.b-str = bb-list.b-str
                    AND buf_prod-bc.b-code = bb-list.b-code no-error .
              if available buf_prod-bc then do:
                  { gbl/prodbcat.i
                    buf_prod-bc
                    'petrolium=request':U
                    v-is-petrol
                    no-error }
              end.
            end.
            if v-is-petrol then next _to-gds.
            run cd-mrkt_plu-marketer in this-procedure (
                                                          input no /*p-silence*/
                                                          ,buffer locked_cash-desk
                                                          ,input '':U /*p-id*/
                                                          ,input bb-list.b-code
                                                          ,input bb-list.b-str
                                                          ,input bb-list.loc-ean
                                                          ,input v-is-petrol
                                                          ,input '':U
                                                          ) no-error.
            if error-status:error then do:
              if return-value = "max-gds":U then dO:
                assign
                v-skip-next = yes
                ves-err = ves-err + 1.
                NEXT _to-gds.
              end.
              else do:
                ves-err = ves-err + 1.
                next _TO-GDS.
              end.
            end. /*if error-status:error then do:*/
            else do:
              delete bb-list.
             end.
          end. /*wehn maria*/
        end CASE.
      end. /*not skip:*/
    end. /*not if available buf_cd-plu then do:*/
  end. /*не топливо МАРИЯ*/
END . /*FOR EACH bb-list*/
run waitfram-hide in this-procedure .
  /* уничтожение лишних записей */
_mrktr-GDS:
FOR EACH buf_cd-plu WHERE
        buf_cd-plu.obj-type = p-curr-obj-type
   and buf_cd-plu.obj-code = p-curr-obj-code
   and buf_cd-plu.pos-type = p-pos-type
   and buf_cd-plu.plu-type = p-plu-type :
  IF buf_cd-plu.to-del = no THEN NEXT _mrktr-gds.
    assign
    buf_cd-plu.to-send = yes
    buf_cd-plu.charkey_two = v-cd-list-update.
END .
run cd-mrkt_update-marketer in this-procedure (
                                                input locked_cash-desk.db-num
                                                ,input locked_cash-desk.obj-code
                                                ,input locked_cash-desk.pos-type
                                                ,input locked_cash-desk.cash-num
                                                ,input (p-pos-type = {&cd-type-maria}
                                                       AND p-plu-type = {&petrolium})

                                              )  .

END. /*doe*/
run waitfram-hide in this-procedure .
RUn OpenBR in this-procedure ( input yes, input no, input '':U).
run fill-vars in this-procedure .
run disp-cd in this-procedure .
if ves-err > 0 then
message
SUBSTITUTE("При добавления товаров на кассу встретилось &1 кодов,&2" +
            "для которых не удалось создать запись товара на кассе&2&2" +
            "Эти товары на кассы НЕ ДОБАВЛЕНЫ !!!!"
            , ves-err
            ,{&NEW-LINE})
view-as alert-box warning.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      CHARACTER    no-undo.
define variable Line            as      CHARACTER    no-undo.
define variable for-time        as      CHARACTER    no-undo.
define variable v-prod-name     as      character    no-undo .
define variable v-prod-type-code as      character    no-undo .
define variable v-imp-date as date no-undo .
define variable v-imp-user as character no-undo .
define buffer buf_c-cd-plu for ub.c-cd-plu.

DEFINE FRAME cd-plu-list
X_cd-plu.plu-code COLUMN-LABEL "PLU" FORMAT "9999":U
X_cd-plu.b-str COLUMN-LABEL "ДопБК/лок.ЕАН" FORMAT "X(18)":U
X_cd-plu.b-code COLUMN-LABEL "Бар-код!IBS TH" FORMAT "999999999":U
X_cd-plu.to-del COLUMN-LABEL "У" FORMAT "У/":U
X_cd-plu.to-send COLUMN-LABEL "И" FORMAT "И/":U
X_goods.gds-name FORMAT "X(30)":U
X_goods.artic FORMAT "X(16)":U
v-prod-name  COLUMN-LABEL "Назв. произв-ля" FORMAT "X(25)":U  /*get-prod-name(buffer X_goods) */
v-prod-type-code  COLUMN-LABEL "Пр-ль" FORMAT "X(12)":U  /*X_goods.prod-type + string(X_goods.prod-code)*/
v-imp-date COLUMn-LABEL "В списке с" format "99/99/9999"
for-time no-label format "X(5)"
v-imp-user COLUMn-LABEL "Оператор" format "X(20)"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME cd-plu-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_cd-plu).
DO WHILE available X_cd-plu :
  GET prev br-mgds.
END.
GET next br-mgds.
DO WHILE available X_cd-plu :
  ASSIGN
  v-prod-name = get-prod-name(buffer X_goods)
  v-prod-type-code = X_goods.prod-type + string(X_goods.prod-code)
  .
  find last buf_c-cd-plu no-lock where
          buf_c-cd-plu.obj-type = X_cd-plu.obj-type
      and buf_c-cd-plu.obj-code = X_cd-plu.obj-code
      and buf_c-cd-plu.pos-type = X_cd-plu.pos-type
      and buf_c-cd-plu.plu-type = X_cd-plu.plu-type
      and buf_c-cd-plu.plu-code = X_cd-plu.plu-code
      and buf_c-cd-plu.corr-user-db-num = v-obj-db-num
      and buf_c-cd-plu.action = integer({&hn-create}) no-error.
  if available buf_c-cd-plu then do:
    assign
    v-imp-date = buf_c-cd-plu.corr-date
    for-time = string(buf_c-cd-plu.corr-time, "hh:mm:ss")
    v-imp-user = buf_c-cd-plu.corr-user-name
    .
  end.
  else do:
    assign
    v-imp-date = ?
    for-time = {&question-mark}
    v-imp-user = {&question-mark}
    .
  end.
  Display STREAM PrnLibStream
  X_cd-plu.plu-code
  X_cd-plu.b-str
  X_cd-plu.b-code
  X_cd-plu.to-del
  X_cd-plu.to-send
  X_goods.gds-name
  X_goods.artic
  get-prod-name(buffer X_goods) @ v-prod-name
  v-prod-type-code
  v-imp-date
  for-time
  v-imp-user
  with FRAME cd-plu-list .
  DOWN STREAM PrnLibStream 1
  with FRAME cd-plu-list  .

  assign
  accum-count = accum-count + 1
  .
  GET next br-mgds.
END.
UNDERLINE  STREAM PrnLibStream
X_cd-plu.plu-code
X_cd-plu.b-str
X_cd-plu.b-code
X_cd-plu.to-del
X_cd-plu.to-send
X_goods.gds-name
X_goods.artic
v-prod-name
v-prod-type-code
v-imp-date
for-time
v-imp-user
with FRAME cd-plu-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_cd-plu.plu-code
accum-count @ X_cd-plu.b-str
with frame cd-plu-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME cd-plu-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-mgds to recid v-doc-rec no-error.
APPLY "entry" to br-mgds.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

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
  tbl = 'cd-plu'
  join-tbl = 'X_cd-plu'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('plu-code', 'PLU', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('b-code', 'Бар-код TH IBS', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('b-str', 'ДопБК или лок.EAN', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('to-del', 'Статус удаления', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('to-send', 'Статус изменения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    , INPUT (filter-point + {&delim-par} +
                        filter-label  + {&delim-par} +
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-b-str Dialog-Frame
PROCEDURE proc-find-b-str :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-a-n-c as character no-undo.
define input parameter p-next as logical no-undo.
define input parameter p-b-str AS character no-undo.
assign
p-b-str = replace(p-b-str, {&double-quote}, "":U)
p-b-str = replace(p-b-str, {&single-quote}, {&single-quote} + {&single-quote})
p-b-str = {&double-quote} + p-b-str + {&double-quote}
.

run OpenBr in this-procedure
(input false /* p-open-query */
,input p-next  /* p-find-next  */
,input substitute("and X_cd-plu.b-str = &1 "
  , p-b-str)
).



apply "entry":u to loc-code in frame {&frame-name} .
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
define input parameter p-a-n-c as character no-undo.
define input parameter p-next as logical no-undo.
define input parameter p-code AS integer no-undo.
IF input frame {&frame-name} a-n-c = "b-code":U THEN DO:
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_cd-plu.b-code = &1 "
          , p-code)
        ).

END.
IF input frame {&frame-name} a-n-c = "plu":U THEN DO:

    run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_cd-plu.plu-code = &1 "
      , p-code)
    ).

END.

apply "entry":u to loc-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RUN-BB-LIST Dialog-Frame
PROCEDURE RUN-BB-LIST :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DO
ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:

  run str/bb-list.w (
                INPUT parparentproc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input {&cd-type-maria}
                ).
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-prod-name Dialog-Frame
FUNCTION get-prod-name RETURNS CHARACTER
  ( BUFFER buf_goods FOR goods ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_clients FOR ub.clients.
FIND FIRST buf_clients NO-LOCK WHERE
          buf_Clients.obj-type = buf_goods.prod-type
     AND  buf_Clients.obj-code = buf_goods.prod-code NO-ERROR.
  IF NOT AVAILABLE buf_Clients  THEN RETURN "!!!Неизвестный произ-ль".
  RETURN buf_clients.obj-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME