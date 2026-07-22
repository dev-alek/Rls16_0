&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE TEMP-TABLE tt-gds-obj-prop NO-UNDO LIKE ub.gds-obj-prop.
DEFINE TEMP-TABLE tt-gds-obj-prop-attr NO-UNDO LIKE ub.gds-obj-prop-attr.
DEFINE TEMP-TABLE tt0-gds-obj-prop NO-UNDO LIKE ub.gds-obj-prop.
DEFINE TEMP-TABLE tt0-gds-obj-prop-attr NO-UNDO LIKE ub.gds-obj-prop-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Замена атрибутов товара на объекте(фирме) для заказов списком

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/28/05
*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования параметров заказа".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ ref/gds-ind1.i gds-obj-prop-attr }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/obj-list.i new }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ gbl/userobjs.i }

&scop display-message ~
      run write-log-and-file in p-log-handle ( ~
            input 1 ~
          , input log-file-name ~
          , input 1 ~
          , input ~{&my-message~})

define variable log-file-name as character no-undo init "ord-atru.txt".
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-gds-obj-prop

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-gds-obj-prop NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH tt-gds-obj-prop NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-gds-obj-prop
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-gds-obj-prop


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-gds B-obj B-Help B-1 B-2 B-3 ~
B-4 B-7 B-8 B-5 B-6
&Scoped-Define DISPLAYED-FIELDS tt-gds-obj-prop.gdop-min-stock ~
tt-gds-obj-prop.grop-max-stock tt-gds-obj-prop.grop-min-order ~
tt-gds-obj-prop.grop-level-always-presence tt-gds-obj-prop.gdop-assort-min ~
tt-gds-obj-prop.gdop-igt
&Scoped-define DISPLAYED-TABLES tt-gds-obj-prop
&Scoped-define FIRST-DISPLAYED-TABLE tt-gds-obj-prop
&Scoped-Define DISPLAYED-OBJECTS f-corrcoeff v-proc E-6 F-5 F-6

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-1  NO-CONVERT-3D-COLORS
     LABEL "B-1"
     SIZE 3 BY 1.

DEFINE BUTTON B-2
     LABEL "B-2"
     SIZE 3 BY 1.

DEFINE BUTTON B-3
     LABEL "B-3"
     SIZE 3 BY 1.

DEFINE BUTTON B-4
     LABEL "B-4"
     SIZE 3 BY 1.

DEFINE BUTTON B-5
     LABEL "B-5"
     SIZE 3 BY 1.

DEFINE BUTTON B-6
     LABEL "B-6"
     SIZE 3 BY 1.

DEFINE BUTTON B-7
     LABEL "B-7"
     SIZE 3 BY 1.

DEFINE BUTTON B-8
     LABEL "B-8"
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1 TOOLTIP "Прризвести изменения в базе данных"
     BGCOLOR 8 .

DEFINE BUTTON B-gds
     LABEL "Список товаров"
     SIZE 17 BY 1 TOOLTIP "Задания списока товаров"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-obj
     LABEL "Список О/Ф"
     SIZE 17 BY 1 TOOLTIP "Список объектов и/или фирм"
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1 TOOLTIP "Не проводить изменения"
     BGCOLOR 8 .

DEFINE VARIABLE v-proc AS CHARACTER FORMAT "X(256)":U INITIAL "not-proc"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "","not-proc",
                     "Минимальный заказ равен кванту","min-ord_qvant"
     DROP-DOWN-LIST
     SIZE 61.5 BY 1 TOOLTIP "Назначение параметров заказа особым способом" NO-UNDO.

DEFINE VARIABLE E-6 AS CHARACTER INITIAL "Если на объекте есть АссМатрица, то товары , которым нужно поменять ИЖТ должны быть включены в АссМатрицу до запуска этого интерфейса"
     VIEW-AS EDITOR NO-BOX
     SIZE 21.5 BY 5
     FONT 4 NO-UNDO.

DEFINE VARIABLE F-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Ассортиментный минимум :"
      VIEW-AS TEXT
     SIZE 24.6 BY .67 NO-UNDO.

DEFINE VARIABLE F-6 AS CHARACTER FORMAT "X(256)":U INITIAL "ИЖТ :"
      VIEW-AS TEXT
     SIZE 5.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-corrcoeff AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     LABEL "Коррект. коэфф. для расчета кол-ва"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-gds-obj-prop SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-gds AT ROW 1 COL 30.6 WIDGET-ID 2
     B-obj AT ROW 1 COL 47.6 WIDGET-ID 4
     B-Help AT ROW 1 COL 65
     tt-gds-obj-prop.gdop-min-stock AT ROW 3 COL 37.6 COLON-ALIGNED FORMAT "->>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-1 AT ROW 3 COL 51 WIDGET-ID 6
     tt-gds-obj-prop.grop-max-stock AT ROW 4.5 COL 37.6 COLON-ALIGNED FORMAT "->>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "ALT-L или 2клика мыши"
     B-2 AT ROW 4.5 COL 51 WIDGET-ID 8
     tt-gds-obj-prop.grop-min-order AT ROW 5.97 COL 37.6 COLON-ALIGNED FORMAT "->>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "ALT-L или 2клика мыши"
     B-3 AT ROW 5.97 COL 51 WIDGET-ID 10
     tt-gds-obj-prop.grop-level-always-presence AT ROW 7.43 COL 37.6 COLON-ALIGNED FORMAT ">.9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "ALT-L или 2клика мыши"
     B-4 AT ROW 7.43 COL 51 WIDGET-ID 12
     f-corrcoeff AT ROW 8.73 COL 37.6 COLON-ALIGNED WIDGET-ID 52
     B-7 AT ROW 8.73 COL 51 WIDGET-ID 54
     v-proc AT ROW 10.33 COL 1.5 NO-LABEL WIDGET-ID 46
     B-8 AT ROW 10.33 COL 63.5 WIDGET-ID 50
     B-5 AT ROW 11.7 COL 30.4 WIDGET-ID 24
     tt-gds-obj-prop.gdop-assort-min AT ROW 11.7 COL 34.5 NO-LABEL WIDGET-ID 30
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Не менять", ?,
"Да", yes,
"Нет", no
          SIZE 26.5 BY 1.27 TOOLTIP "Да=входит в ассортиментный минимум"
     E-6 AT ROW 13.2 COL 2 NO-LABEL WIDGET-ID 44
     B-6 AT ROW 13.2 COL 30.4 WIDGET-ID 26
     tt-gds-obj-prop.gdop-igt AT ROW 13.2 COL 34.5 NO-LABEL WIDGET-ID 34
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Не менять", ?,
"Item 2", "2":U,
"Item 3", "3":U,
"Item 4", "4":U,
"Item 6", "6":U,
"Item 5", "5":U
          SIZE 32 BY 6.5
     F-5 AT ROW 11.4 COL 1.5 NO-LABEL WIDGET-ID 40
     F-6 AT ROW 11.8 COL 25 NO-LABEL WIDGET-ID 42
     SPACE(38.59) SKIP(8.05)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Замена атрибутов товара на объекте(фирме) для заказов списком".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub goods
      TABLE: tt-gds-obj-prop T "?" NO-UNDO ub gds-obj-prop
      TABLE: tt-gds-obj-prop-attr T "?" NO-UNDO ub gds-obj-prop-attr
      TABLE: tt0-gds-obj-prop T "?" NO-UNDO ub gds-obj-prop
      TABLE: tt0-gds-obj-prop-attr T "?" NO-UNDO ub gds-obj-prop-attr
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

/* SETTINGS FOR EDITOR E-6 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       E-6:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN F-5 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN F-6 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-corrcoeff IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET tt-gds-obj-prop.gdop-assort-min IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET tt-gds-obj-prop.gdop-igt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-gds-obj-prop.gdop-min-stock IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-gds-obj-prop.grop-level-always-presence IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-gds-obj-prop.grop-max-stock IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-gds-obj-prop.grop-min-order IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX v-proc IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-gds-obj-prop NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Замена атрибутов товара на объекте(фирме) для заказов списком */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-1 Dialog-Frame
ON CHOOSE OF B-1 IN FRAME Dialog-Frame /* B-1 */
DO:
  tt-gds-obj-prop.gdop-min-stock = 0 .
  display tt-gds-obj-prop.gdop-min-stock with frame {&frame-name} .
  enable  tt-gds-obj-prop.gdop-min-stock with frame {&frame-name} .
  disable  b-1 with frame {&frame-name} .
  hide b-1 in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-2 Dialog-Frame
ON CHOOSE OF B-2 IN FRAME Dialog-Frame /* B-2 */
DO:
  tt-gds-obj-prop.grop-max-stock = 0 .

  display  tt-gds-obj-prop.grop-max-stock with frame {&frame-name} .
  enable   tt-gds-obj-prop.grop-max-stock with frame {&frame-name} .
  disable  b-2 with frame {&frame-name} .
  hide b-2 in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-3 Dialog-Frame
ON CHOOSE OF B-3 IN FRAME Dialog-Frame /* B-3 */
DO:
  tt-gds-obj-prop.grop-min-order = 0 .
  display tt-gds-obj-prop.grop-min-order with frame {&frame-name} .
  enable  tt-gds-obj-prop.grop-min-order with frame {&frame-name} .
  disable  b-3 with frame {&frame-name} .
  hide b-3 in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-4 Dialog-Frame
ON CHOOSE OF B-4 IN FRAME Dialog-Frame /* B-4 */
DO:
  tt-gds-obj-prop.grop-level-always-presence = 0 .
  display tt-gds-obj-prop.grop-level-always-presence with frame {&frame-name} .
  enable  tt-gds-obj-prop.grop-level-always-presence with frame {&frame-name} .
  disable  b-4 with frame {&frame-name} .
  hide b-4 in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-5 Dialog-Frame
ON CHOOSE OF B-5 IN FRAME Dialog-Frame /* B-5 */
DO:
  tt-gds-obj-prop.gdop-assort-min = yes .
  display tt-gds-obj-prop.gdop-assort-min with frame {&frame-name} .
  enable  tt-gds-obj-prop.gdop-assort-min with frame {&frame-name} .
  disable  b-5 with frame {&frame-name} .
  hide b-5 in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-6 Dialog-Frame
ON CHOOSE OF B-6 IN FRAME Dialog-Frame /* B-6 */
DO:
  tt-gds-obj-prop.gdop-igt = {&ass-izd-empty}.
  display tt-gds-obj-prop.gdop-igt with frame {&frame-name} .
  enable  tt-gds-obj-prop.gdop-igt with frame {&frame-name} .
  disable  b-6 with frame {&frame-name} .
  hide b-6 in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-7 Dialog-Frame
ON CHOOSE OF B-7 IN FRAME Dialog-Frame /* B-7 */
DO:
  f-corrcoeff = 1 .
  display f-corrcoeff with frame {&frame-name} .
  enable  f-corrcoeff with frame {&frame-name} .
  disable  b-7 with frame {&frame-name} .
  hide b-7 in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-8 Dialog-Frame
ON CHOOSE OF B-8 IN FRAME Dialog-Frame /* B-8 */
DO:
  v-proc = "min-ord_qvant" .
  display v-proc with frame {&frame-name} .
  enable  v-proc with frame {&frame-name} .
  disable  b-8 with frame {&frame-name} .
  hide b-8 in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dialog-Frame
ON CHOOSE OF B-gds IN FRAME Dialog-Frame /* Список товаров */
DO:
  run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame /* Список О/Ф */
DO:
define buffer buf_clients for ub.clients  .
define buffer buf_sysconf for ub.sysconf  .
define variable v-list as character no-undo .
define variable v-host-code as integer   no-undo .
define variable v-num as integer no-undo .
define variable ii    as integer no-undo .

for each obj-list :
  delete obj-list.
end.

  if p-mode = 'firm' then do:
      run adm/sconfs.w
        (input  parparentproc
        ,input  'b-sel,b-mark':U
        ,input  no
        ,input  v-cntxt-host-code-obj
        ,output v-host-code
        ,input-output v-list
        ) .
      if v-list = "" then return no-apply .
      assign v-num = num-entries (v-list) .
      do ii = 1 to v-num :
        find first buf_sysconf no-lock where RECID(buf_sysconf) = integer(entry(ii, v-list)) no-error.
        run create_obj-list ({&cmp},buf_sysconf.host-code) .
      end.
  end.
  else do:
  if v-cntxt-db-num = 0 then do:
    run ref/thobjs.w
        ( input parparentproc
        , input this-procedure:handle
        , input "b-mark,b-sel"
        , input {&all}
        , input '' /*p-obj-type*/
        , input ? /*p-db-num*/
        , input ? /*p-host-code*/
        , input-output v-list ) no-error .

    end. /*if v-cntxt-db-num = 0 then do:*/
    else do:
    run ref/thobjs.w
        ( input parparentproc
        , input this-procedure:handle
        , input "b-mark,b-sel"
        , input {&all}
        , input '' /*p-obj-type*/
        , input v-cntxt-db-num /*p-db-num*/
        , input ? /*p-host-code*/
        , input-output v-list ) no-error .
  end. /*else if v-cntxt-db-num = 0 then do:*/
  for each obj-list:
    delete obj-list.
      end.
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj.
  for each buf_userobjs_temp-user-obj:
    run create_obj-list ( buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code) .
  end.
end. /*if p-mode = 'firm' then do:*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-corrcoeff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-corrcoeff Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF f-corrcoeff IN FRAME Dialog-Frame /* Коррект. коэфф. для расчета кол-ва */
OR ALT-L OF f-corrcoeff IN FRAME Dialog-Frame
DO:
  f-corrcoeff = ? .
  display f-corrcoeff with frame {&frame-name} .
  disable f-corrcoeff with frame {&frame-name} .
  enable  b-7 with frame {&frame-name} .
  display b-7 with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-corrcoeff Dialog-Frame
ON RIGHT-MOUSE-CLICK OF f-corrcoeff IN FRAME Dialog-Frame /* Коррект. коэфф. для расчета кол-ва */
DO:
    assign
    f-corrcoeff = ?
    b-7:visible = true.
    display f-corrcoeff with frame {&frame-name}.
    disable f-corrcoeff with frame {&frame-name}.
    disable b-7 with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-gds-obj-prop.gdop-assort-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.gdop-assort-min Dialog-Frame
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.gdop-assort-min IN FRAME Dialog-Frame
DO:
  assign
    tt-gds-obj-prop.gdop-assort-min = ?
    b-5:visible = true.
    display tt-gds-obj-prop.gdop-assort-min with frame {&frame-name}.
    disable tt-gds-obj-prop.gdop-assort-min with frame {&frame-name}.
    disable b-5 with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.gdop-assort-min Dialog-Frame
ON VALUE-CHANGED OF tt-gds-obj-prop.gdop-assort-min IN FRAME Dialog-Frame
OR ALT-L OF tt-gds-obj-prop.gdop-assort-min IN FRAME Dialog-Frame
DO:
  assign tt-gds-obj-prop.gdop-assort-min .
  if tt-gds-obj-prop.gdop-assort-min = ? then do:
    display tt-gds-obj-prop.gdop-assort-min with frame {&frame-name} .
    disable tt-gds-obj-prop.gdop-assort-min with frame {&frame-name} .
    enable  b-5 with frame {&frame-name} .
    display b-5 with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-gds-obj-prop.gdop-igt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.gdop-igt Dialog-Frame
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.gdop-igt IN FRAME Dialog-Frame
DO:
  assign
    tt-gds-obj-prop.gdop-igt = ?
    b-6:visible = true.
    display tt-gds-obj-prop.gdop-igt with frame {&frame-name}.
    disable tt-gds-obj-prop.gdop-igt with frame {&frame-name}.
    disable b-6 with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.gdop-igt Dialog-Frame
ON VALUE-CHANGED OF tt-gds-obj-prop.gdop-igt IN FRAME Dialog-Frame
OR ALT-L OF tt-gds-obj-prop.gdop-igt IN FRAME Dialog-Frame
DO:
  assign tt-gds-obj-prop.gdop-igt .
  if tt-gds-obj-prop.gdop-igt = ? then do:
    display tt-gds-obj-prop.gdop-igt with frame {&frame-name} .
    disable tt-gds-obj-prop.gdop-igt with frame {&frame-name} .
    enable  b-6 with frame {&frame-name} .
    display b-6 with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-gds-obj-prop.gdop-min-stock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.gdop-min-stock Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-gds-obj-prop.gdop-min-stock IN FRAME Dialog-Frame /* Минимальный остаток */
OR ALT-L OF tt-gds-obj-prop.gdop-min-stock IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.gdop-min-stock = ? .
  display tt-gds-obj-prop.gdop-min-stock with frame {&frame-name} .
  disable tt-gds-obj-prop.gdop-min-stock with frame {&frame-name} .
  enable  b-1 with frame {&frame-name} .
  display b-1 with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.gdop-min-stock Dialog-Frame
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.gdop-min-stock IN FRAME Dialog-Frame /* Минимальный остаток */
DO:
    assign
    tt-gds-obj-prop.gdop-min-stock = ?
    b-1:visible = true.
    display tt-gds-obj-prop.gdop-min-stock with frame {&frame-name}.
    disable tt-gds-obj-prop.gdop-min-stock with frame {&frame-name}.
    disable b-1 with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-gds-obj-prop.grop-level-always-presence
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.grop-level-always-presence Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-gds-obj-prop.grop-level-always-presence IN FRAME Dialog-Frame /* Уровень постоянного присутствия */
OR ALT-L OF tt-gds-obj-prop.grop-level-always-presence IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.grop-level-always-presence = ? .
  display tt-gds-obj-prop.grop-level-always-presence with frame {&frame-name} .
  disable tt-gds-obj-prop.grop-level-always-presence with frame {&frame-name} .
  enable  b-4 with frame {&frame-name} .
  display b-4 with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.grop-level-always-presence Dialog-Frame
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.grop-level-always-presence IN FRAME Dialog-Frame /* Уровень постоянного присутствия */
DO:
    assign
    tt-gds-obj-prop.grop-level-always-presence = ?
    b-4:visible = true.
    display tt-gds-obj-prop.grop-level-always-presence with frame {&frame-name}.
    disable tt-gds-obj-prop.grop-level-always-presence with frame {&frame-name}.
    disable b-4 with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-gds-obj-prop.grop-max-stock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.grop-max-stock Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-gds-obj-prop.grop-max-stock IN FRAME Dialog-Frame /* Максимальный остаток */
OR ALT-L OF tt-gds-obj-prop.grop-max-stock IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.grop-max-stock = ? .
  display tt-gds-obj-prop.grop-max-stock with frame {&frame-name} .
  disable tt-gds-obj-prop.grop-max-stock with frame {&frame-name} .
  enable  b-2 with frame {&frame-name} .
  display b-2 with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.grop-max-stock Dialog-Frame
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.grop-max-stock IN FRAME Dialog-Frame /* Максимальный остаток */
DO:
  assign
  tt-gds-obj-prop.grop-max-stock = ?
  b-2:visible = true.
  display tt-gds-obj-prop.grop-max-stock with frame {&frame-name}.
  disable tt-gds-obj-prop.grop-max-stock with frame {&frame-name}.
  disable b-2 with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-gds-obj-prop.grop-min-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.grop-min-order Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-gds-obj-prop.grop-min-order IN FRAME Dialog-Frame /* Минимальный заказ */
OR ALT-L OF tt-gds-obj-prop.grop-min-order IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.grop-min-order = ? .
  display tt-gds-obj-prop.grop-min-order with frame {&frame-name} .
  disable tt-gds-obj-prop.grop-min-order with frame {&frame-name} .
  enable  b-3 with frame {&frame-name} .
  display b-3 with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-obj-prop.grop-min-order Dialog-Frame
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.grop-min-order IN FRAME Dialog-Frame /* Минимальный заказ */
DO:
    assign
    tt-gds-obj-prop.grop-min-order = ?
    b-3:visible = true.
    display tt-gds-obj-prop.grop-min-order with frame {&frame-name}.
    disable tt-gds-obj-prop.grop-min-order with frame {&frame-name}.
    disable b-3 with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-proc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-proc Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF v-proc IN FRAME Dialog-Frame
OR ALT-L OF v-proc IN FRAME Dialog-Frame
DO:
  v-proc = "not-proc" .
  display  v-proc with frame {&frame-name} .
  disable  v-proc with frame {&frame-name} .
  enable  b-8 with frame {&frame-name} .
  display b-8 with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-proc Dialog-Frame
ON RIGHT-MOUSE-CLICK OF v-proc IN FRAME Dialog-Frame
DO:
   assign
    v-proc = ?
    b-8:visible = true.
    display v-proc with frame {&frame-name}.
    disable v-proc with frame {&frame-name}.
    disable b-8 with frame {&frame-name}.
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

    b-1:load-image-up("cmp/lock.ico":u) .
    b-1:load-image-down("cmp/lock.ico":u) .
    b-1:load-image-insensitive("cmp/lock.ico":u) .

    b-2:load-image-up("cmp/lock.ico":u) .
    b-2:load-image-down("cmp/lock.ico":u) .
    b-2:load-image-insensitive("cmp/lock.ico":u) .

    b-3:load-image-up("cmp/lock.ico":u) .
    b-3:load-image-down("cmp/lock.ico":u) .
    b-3:load-image-insensitive("cmp/lock.ico":u) .

    b-4:load-image-up("cmp/lock.ico":u) .
    b-4:load-image-down("cmp/lock.ico":u) .
    b-4:load-image-insensitive("cmp/lock.ico":u) .

    b-5:load-image-up("cmp/lock.ico":u) .
    b-5:load-image-down("cmp/lock.ico":u) .
    b-5:load-image-insensitive("cmp/lock.ico":u) .

    b-6:load-image-up("cmp/lock.ico":u) .
    b-6:load-image-down("cmp/lock.ico":u) .
    b-6:load-image-insensitive("cmp/lock.ico":u) .

    b-7:load-image-up("cmp/lock.ico":u) .
    b-7:load-image-down("cmp/lock.ico":u) .
    b-7:load-image-insensitive("cmp/lock.ico":u) .

    b-8:load-image-up("cmp/lock.ico":u) .
    b-8:load-image-down("cmp/lock.ico":u) .
    b-8:load-image-insensitive("cmp/lock.ico":u) .


  run init-proc no-error .
  if error-status :error then return error return-value .

  define variable v-user-name as character no-undo .
  find first tt-gds-obj-prop no-error .
  run enable_ui.
  find first tt-gds-obj-prop no-error .

enable
  b-exit
  b-quit
  b-help
with frame {&frame-name}.
  case p-mode:
  when  'firm' then do:
     b-obj:label = "Список фирм" .
     assign frame {&frame-name}:title =  "Замена атрибутов товара на фирме для заказов списком" .
     hide
      tt-gds-obj-prop.grop-max-stock b-2
      b-5 f-5 tt-gds-obj-prop.gdop-assort-min
     e-6 b-6 b-7 f-6 tt-gds-obj-prop.gdop-igt f-corrcoeff
      in frame {&frame-name} .
  end.
  when  'obj' then do:
     b-obj:label = "Список объектов" .
     assign frame {&frame-name}:title =  "Замена атрибутов товара на объекте для заказов списком" .
     hide
      b-5 f-5 tt-gds-obj-prop.gdop-assort-min
      e-6 b-6 f-6 tt-gds-obj-prop.gdop-igt
      in frame {&frame-name} .
  end.
  when  'izt' then do:
     b-obj:label = "Список объектов" .
     assign frame {&frame-name}:title =  "Замена атрибутов товара на объекте по  Ассортиментной политики" .
    tt-gds-obj-prop.gdop-igt:RADIO-BUTTONS  = substitute("&1,&2,&3,&3,&4,&4,&5,&5,&6,&6,&7,&7",
      "Не менять" , ? ,
      {&ass-izd-new} ,
      {&ass-izd-com} ,
      {&ass-izd-spec} ,
      {&ass-izd-del} ,
      {&ass-izd-empty}
      ) .
    view frame {&frame-name}.
     hide
      tt-gds-obj-prop.grop-max-stock b-2
      tt-gds-obj-prop.gdop-min-stock b-1
      tt-gds-obj-prop.grop-min-order b-3
      tt-gds-obj-prop.grop-level-always-presence b-4
     v-proc b-8 f-corrcoeff b-7
      in frame {&frame-name} .
  end.
 end case.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-gds-obj-prop.gdop-min-stock.
END.
run disable_ui.

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY f-corrcoeff v-proc E-6 F-5 F-6
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-gds-obj-prop THEN
    DISPLAY tt-gds-obj-prop.gdop-min-stock tt-gds-obj-prop.grop-max-stock
          tt-gds-obj-prop.grop-min-order
          tt-gds-obj-prop.grop-level-always-presence
          tt-gds-obj-prop.gdop-assort-min tt-gds-obj-prop.gdop-igt
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-gds B-obj B-Help B-1 B-2 B-3 B-4 B-7 B-8 B-5 B-6
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
define variable v-ii as integer no-undo .
for each tt-gds-obj-prop :
  delete tt-gds-obj-prop.
end.

 create  tt-gds-obj-prop.
    assign
      tt-gds-obj-prop.gdop-min-stock             = ?
      tt-gds-obj-prop.grop-level-always-presence = ?
      tt-gds-obj-prop.grop-max-stock             = ?
      tt-gds-obj-prop.grop-min-order             = ?
      tt-gds-obj-prop.gdop-assort-min            = ?
      tt-gds-obj-prop.gdop-igt                   = ?
f-corrcoeff                                = ?
      v-proc = "not-proc"
     .
do v-ii = 1 to num-entries({&gdspoatr-list-obj}):
  find first tt-gds-obj-prop-attr where
            tt-gds-obj-prop-attr.attr-code = entry(v-ii, {&gdspoatr-list-obj}) no-error.
  if not available tt-gds-obj-prop-attr then do:
    create tt-gds-obj-prop-attr.
    assign
    tt-gds-obj-prop-attr.attr-code = entry(v-ii, {&gdspoatr-list-obj})
    .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
assign frame {&frame-name}  tt-gds-obj-prop.gdop-min-stock .
assign frame {&frame-name}  tt-gds-obj-prop.gdop-igt .
assign frame {&frame-name}  tt-gds-obj-prop.gdop-assort-min .
assign frame {&frame-name}  tt-gds-obj-prop.grop-level-always-presence .
assign frame {&frame-name}  tt-gds-obj-prop.grop-max-stock  .
assign frame {&frame-name}  tt-gds-obj-prop.grop-min-order .
assign frame {&frame-name}  f-corrcoeff .
assign frame {&frame-name}  v-proc .

    if not can-find ( first obj-list ) then do:
  message
  "Не задан список объектов/фирм"
  view-as alert-box error .
      return error.
    end.
    if not can-find ( first gds-list ) then do:
  message
  "Не задан список товаров"
  view-as alert-box error .
      return error.
    end.

    if  tt-gds-obj-prop.gdop-min-stock             = ? and
        tt-gds-obj-prop.gdop-igt                   = ? and
        tt-gds-obj-prop.gdop-assort-min            = ? and
        tt-gds-obj-prop.grop-level-always-presence = ? and
        tt-gds-obj-prop.grop-max-stock             = ? and
        tt-gds-obj-prop.grop-min-order             = ? and
    f-corrcoeff                                = ? and
        v-proc = "not-proc"
        then do:
  message
  "Не заданы значения для изменений"
  view-as alert-box error .
      return error.
    end.
for each tt-gds-obj-prop-attr:
  case tt-gds-obj-prop-attr.attr-code:
    when {&attr-corrcoeff-po} then do:
      assign
      tt-gds-obj-prop-attr.attr-value = string(f-corrcoeff).
    end.
  end.
end.


message
"Проводить изменения в БД ?"
           view-as alert-box question
           buttons yes-no update varlog as logical.

    if varlog = false then return error .


/* Пишем в БД */
run str/diallog.w ( input parparentproc
            , input this-procedure
            , input ('process-list':U + {&delim-par} +
                    "1" + {&delim-par} +
                    "0" + {&delim-par} +
                    "1" + {&delim-par} +
                    "1" + {&delim-par} +
                    "yes")
            , input ''
            , input no
            , input 'Прервать'
            , input "Сохранение изменений по списку товаров") no-error .







END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-list Dialog-Frame
PROCEDURE process-list :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ii-ok as integer no-undo .
define variable p-recid as recid no-undo.
define variable v-ok as logical no-undo.
define variable v-mes as character no-undo.
define buffer buf_goods for ub.goods  .
for each obj-list :
&scop my-message substitute("&1&2", obj-list.obj-type, obj-list.obj-code)
{&display-message}.
    for each gds-list :
        v-ii = v-ii + 1.
        run check-actg in this-procedure (
           input gds-list.grp-code
          ,input gds-list.gds-code
          ,input obj-list.obj-code
          ,input obj-list.obj-type
          ,output v-ok
          ,output v-mes
        ) no-error.
        if v-ok = true then do :
            CASE v-proc:
                WHEN "min-ord_qvant" THEN DO:
                find first buf_goods no-lock where
                          buf_goods.gds-code = gds-list.gds-code
                          no-error .
                    if not error-status :error  and
                      buf_goods.qnty-cart <> 0   and
                      buf_goods.qnty-cart <> ?
                      then do:
                    tt-gds-obj-prop.grop-min-order = buf_goods.qnty-cart.
                    end.
                END.
                OTHERWISE DO:
                END.
            END CASE.
            run gds-ind1 in this-procedure
                        (input-output p-recid
                        ,input gds-list.gds-code
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input tt-gds-obj-prop.gdop-igt
                        ,input tt-gds-obj-prop.gdop-assort-min
                        ,input tt-gds-obj-prop.gdop-min-stock
                        ,input tt-gds-obj-prop.grop-level-always-presence
                        ,input tt-gds-obj-prop.grop-max-stock
                        ,input tt-gds-obj-prop.grop-min-order
                        ,input TABLE tt-gds-obj-prop-attr
                        ) no-error .
            if not error-status:error then do:
              v-ii-ok = v-ii-ok + 1.
            end.
        end.
        else do :
          &scop my-message v-mes
          {&display-message}.
        end.
    end. /*for each gds-list :*/
end. /*for each obj-list :*/
case p-mode:
  when 'firm' then do:
    &scop my-message substitute("Обработано записей атрибутов товаров на фирме: &1, из них удачно: &2", v-ii, v-ii-ok)
    {&display-message}.
  end.
  when 'obj' then do:
    &scop my-message substitute("Обработано записей атрибутов товаров на объекте: &1, из них удачно: &2", v-ii, v-ii-ok)
    {&display-message}.
  end.
  when 'izt' then do:
    &scop my-message substitute("Обработано записей индикаторов товаров на объекте: &1, из них удачно: &2", v-ii, v-ii-ok)
    {&display-message}.
    end.

end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

procedure check-actg :

define input parameter p-grp-code as integer no-undo.
define input parameter p-gds-code as integer no-undo.
define input parameter p-obj-code as integer no-undo.
define input parameter p-obj-type as character no-undo.
define output parameter p-ok as logical no-undo.
define output parameter p-mes as character no-undo.
define variable glog as logical no-undo.

do
on error undo, return error
:
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    p-grp-code
    0
    false
    glog
    }
    if glog then do:
      assign
        p-ok = true.
    end.
    else do :
      find first gds-grp no-lock
           where gds-grp.node-code = p-grp-code no-error.
      p-mes = substitute("товар с кодом &1, &2&3: У вас отсутствует глобальное право на изменение товара в привязке к группе товаров &4"
                   , p-gds-code
                   , p-obj-type
                   , p-obj-code
                   , (string(gds-grp.node-code) + " " + gds-grp.node-name)
                    ).
    end.
end.

end procedure.   /*check-actg*/