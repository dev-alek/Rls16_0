&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER bar_units FOR ub.units.
DEFINE BUFFER obj_clients FOR ub.clients.
DEFINE TEMP-TABLE temp0-goods NO-UNDO LIKE ub.goods.
DEFINE TEMP-TABLE temp0-scaleable NO-UNDO LIKE ub.prod-bc
       field prod-bc-rec as recid
       field price-sale like ub.price-list.price-sale
       field unit-cli like ub.bar-code.unit-cli
       field is-global as logical
       index pi is primary unique
       b-code
       b-str
       index ss-code
       b-str
       index reci
       prod-bc-rec
       .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список взвешиваемых бар-кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/04/02
Author: Bakhtadze Natalya
Creation date: 07/04/02

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
/*par-mode бывает
*/
define input parameter par-mode as character no-undo .
DEFINE INPUT PARAMETER parhost-code like ub.sysconf.host-code no-undo.
DEFINE INPUT PARAMETER parobj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER parobj-code like ub.clients.obj-code no-undo.
define output parameter p-rid-list    as  character no-undo . /* список recid'ов выбранных prod-bc */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список взвешиваемых бар-кодов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ ref/send-ref.i }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
DEFINE VARIABLE varempty-code like ub.gds-prt.node-code no-undo .
DEFINE VARIABLE filter-point as character no-undo init "locsscds" .
DEFINE VARIABLE filter-point0 as character no-undo init "locsscds" .
DEFINE VARIABLE filter-label as character no-undo init "Взвешивамые коды" .
DEFINE VARIABLE filter-label0 as character no-undo init "Взвешивамые коды" .
define variable v-rid-list as character no-undo .
DEFINE VARIABLE sort-column-name as character no-undo .
DEFINE VARIABLE varhost-code like ub.sysconf.host-code no-undo.
define variable gds-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .


DEFINE buffer TEMP-goods for TEMP0-goods.
DEFINE buffer TEMP-SCALEABLE for TEMP0-SCALEABLE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-pbc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-goods temp-scaleable

/* Definitions for BROWSE BR-pbc                                        */
&Scoped-define FIELDS-IN-QUERY-BR-pbc mark-string( temp-scaleable.prod-bc-rec, v-rid-list ) temp-goods.gds-code temp-scaleable.b-str temp-scaleable.is-global temp-scaleable.unit-cli temp-goods.gds-name temp-scaleable.price-sale temp-goods.artic
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-pbc
&Scoped-define SELF-NAME BR-pbc
&Scoped-define QUERY-STRING-BR-pbc FOR EACH temp-goods NO-LOCK, ~
             EACH temp-scaleable WHERE temp-scaleable.b-code = temp-goods.gds-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-pbc OPEN QUERY {&SELF-NAME} FOR EACH temp-goods NO-LOCK, ~
             EACH temp-scaleable WHERE temp-scaleable.b-code = temp-goods.gds-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-pbc temp-goods temp-scaleable
&Scoped-define FIRST-TABLE-IN-QUERY-BR-pbc temp-goods
&Scoped-define SECOND-TABLE-IN-QUERY-BR-pbc temp-scaleable


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-del B-gds B-sch ~
B-print B-Help Rs-sort T-object r-obj BR-pbc mark-num varobj-code var-prod ~
var-prod-name varobj-type
&Scoped-Define DISPLAYED-OBJECTS Rs-sort T-object mark-num varobj-code ~
var-prod var-prod-name varobj-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-price Dialog-Frame
FUNCTION get-price RETURNS DECIMAL
  ( input parobj-type as character, input parobj-code as integer, parb-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-gds
     LABEL "&Товар"
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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE BUTTON r-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3"
     SIZE 3 BY .87 TOOLTIP "Выбор объекта".

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE var-prod AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 8.9 BY .67 NO-UNDO.

DEFINE VARIABLE var-prod-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.1 BY .67 NO-UNDO.

DEFINE VARIABLE varobj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8.9 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varobj-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 5.4 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Rs-sort AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Код товара", 1,
"Взвешиваемый код", 2,
"Название товара", 3,
"Артикул", 4
     SIZE 61.9 BY .97 NO-UNDO.

DEFINE VARIABLE T-object AS LOGICAL INITIAL no
     LABEL "Объект"
     VIEW-AS TOGGLE-BOX
     SIZE 20.6 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-pbc FOR  temp-goods ,temp-scaleable SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-pbc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-pbc Dialog-Frame _FREEFORM
  QUERY BR-pbc NO-LOCK DISPLAY
      mark-string( temp-scaleable.prod-bc-rec, v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)"
      temp-goods.gds-code
      temp-scaleable.b-str FORMAT "X(10)" COLUMN-LABEL "Доп.БК"
      temp-scaleable.is-global FORMAT "+/" COLUMN-LABEL "Глоб"
      temp-scaleable.unit-cli COLUMn-LABEL "Ед!изм"
      temp-goods.gds-name
      temp-scaleable.price-sale COLUMN-LABEL "Цена на объекте" FORMAT ">>>,>>>,>>9.99"
      temp-goods.artic
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.97.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 20
     B-add AT ROW 1 COL 30
     B-del AT ROW 1 COL 40
     B-gds AT ROW 1 COL 50
     B-sch AT ROW 1 COL 89
     B-print AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     Rs-sort AT ROW 2.2 COL 14.6 NO-LABEL
     T-object AT ROW 2.27 COL 78
     r-obj AT ROW 3.67 COL 93.8
     BR-pbc AT ROW 4.63 COL 1
     mark-num AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL
     varobj-code AT ROW 3.67 COL 81.9 COLON-ALIGNED NO-LABEL
     var-prod AT ROW 3.77 COL 16.1 NO-LABEL
     var-prod-name AT ROW 3.77 COL 26 NO-LABEL
     varobj-type AT ROW 3.77 COL 75.1 COLON-ALIGNED
     "Производитель:" VIEW-AS TEXT
          SIZE 15.3 BY .77 AT ROW 3.67 COL 1
          FGCOLOR 1
     "Сортировка:" VIEW-AS TEXT
          SIZE 12.1 BY 1 AT ROW 2.2 COL 1.8
          FGCOLOR 4
     SPACE(85.10) SKIP(20.40)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Взвешиваемые товары/ДОПБК"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: bar_units B "?" ? ub units
      TABLE: obj_clients B "?" ? ub clients
      TABLE: temp0-goods T "?" NO-UNDO ub goods
      TABLE: temp0-scaleable T "?" NO-UNDO ub prod-bc
      ADDITIONAL-FIELDS:
          field prod-bc-rec as recid
          field price-sale like ub.price-list.price-sale
          field unit-cli like ub.bar-code.unit-cli
          field is-global as logical
          index pi is primary unique
          b-code
          b-str
          index ss-code
          b-str
          index reci
          prod-bc-rec

      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-pbc r-obj Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN var-prod IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN var-prod-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-pbc
/* Query rebuild information for BROWSE BR-pbc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-goods NO-LOCK,
      EACH temp-scaleable WHERE temp-scaleable.b-code = temp-goods.gds-code NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-pbc FOR  temp-goods ,temp-scaleable SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BR-pbc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Взвешиваемые товары/ДОПБК */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Взвешиваемые товары/ДОПБК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
 DEFINE VARIABLE loc-rid-list as character no-undo .
  /*запустим справчоник товаров на выбор*/
  run ref/gds-ref.p ( parparentproc
                 ,"b-sel,b-mark,b-add"
                 ,?                     /*p-stat */
                 ,?                     /*p-list  */
                 ,?                     /*p-cond  */
                 ,?                     /*p-rec   */
                 ,?                     /*p-grp   */
                 ,?                     /*p-cli-type */
                 ,?                     /*p-cli-code  */
                 ,parobj-type           /*p-obj-type  */
                 ,parobj-code            /*p-obj-code  */
                 ,?                     /*p-other     */
                 , output loc-rid-list).
  Run fill-table in this-procedure.
  RUn openbr in this-procedure ( input yes, input no, input '':U).
  APPLY "Value-changed" to br-pbc.
  APPLY "entry" to br-pbc.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
 define variable glog as logical no-undo .
  define buffer buf_temp-scaleable for temp-scaleable.
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_alt-barcode_preparation':U
  {&cntxt-global}
  0
  '':U
  0
  0
  temp-goods.grp-code
  0
  true
  glog
  }
if not glog then return no-apply.
 message
 "Вы действительно хотите удалить взвешимаемый код" temp-scaleable.b-str SKIP
 "для товара" temp-goods.artic temp-goods.prod-type temp-goods.prod-code
 view-as alert-box QUESTION buttons YES-NO update glog.
 if not glog then return no-apply.
    find first ub.prod-bc exclusive-lock where
                recid(ub.prod-bc) = temp-scaleable.prod-bc-rec No-wait No-error.
     if not avail ub.prod-bc then do:
        message "К сожалению в настоящий момент запись не доступна"
        view-as alert-box ERROR.
        return no-apply.
     end.
del-bc1:
do on stop undo del-bc1, return no-apply on error undo del-bc1, return no-apply:
  if prod-bc.bc-on AND send-ref then
        run str/diallog.w ( parparentproc
                    , this-procedure
                    , 'str/s-prodbc.p':U
                    , string(recid(prod-bc)) + {&delim-par} + "D":U
                    , yes /*p-auto-go*/
                    , '':U
                    , 'Удаление ДопБК с кассы') .
    delete prod-bc.
    delete temp-scaleable.
    find first buf_temp-scaleable no-lock where buf_temp-scaleable.b-code = temp-goods.gds-code no-error.
    if not avail buf_temp-scaleable then delete temp-goods.
  end.
  RUn openbr in this-procedure ( input yes, input no, input '':U).
  APPLY "Value-changed" to br-pbc.
  APPLY "entry" to br-pbc.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dialog-Frame
ON CHOOSE OF B-gds IN FRAME Dialog-Frame /* Товар */
DO:
 define variable v-gds-rec as recid no-undo .
  if available temp-goods then do:
    find first ub.goods No-LOCK WHERE
                 ub.goods.gds-code = temp-goods.gds-code no-error.
    if not avail ub.goods then return no-apply.
    v-gds-rec = recid(goods).
    run ref/gds-form.w ( input parparentproc
                    ,input {&lookup}
                    ,input parobj-type
                    ,input parobj-code
                    ,input this-procedure:handle
                    ,input-output v-gds-rec
                    ).
    apply "entry" to br-pbc in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable v-num-entry as integer no-undo .
define variable glog as logical no-undo .
  if available temp-scaleable then do:
    assign
      v-num-entry = lookup(string( temp-scaleable.prod-bc-rec), v-rid-list ).
    if v-num-entry > 0 then do:
      assign
        entry(v-num-entry, v-rid-list) = "":U
        v-rid-list = replace( v-rid-list, {&comma-char} + {&comma-char}, {&comma-char}) .
    end.
    else do:
      assign
        v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else {&comma-char} ) + string( temp-scaleable.prod-bc-rec ) .
    end.
    glog = br-pbc:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-pbc:select-next-row ().
        apply "Value-changed" to br-pbc in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-pbc in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
run proc-b-sch no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
      if ( available temp-scaleable ) AND ( v-rid-list = "" ) then
    v-rid-list = string( temp-scaleable.prod-bc-rec  ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-pbc
&Scoped-define SELF-NAME BR-pbc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-pbc Dialog-Frame
ON VALUE-CHANGED OF BR-pbc IN FRAME Dialog-Frame
DO:
  if available temp-goods then do:
    var-prod = temp-goods.prod-type + string(temp-goods.prod-code).
    find first ub.clients no-lock where
                 ub.clients.obj-type = temp-goods.prod-type and
                 ub.clients.obj-code = temp-goods.prod-code no-error.
    if available ub.clients then do:
        assign
        var-prod-name = ub.clients.obj-name.
    end.
    else do:
        var-prod-name = "":U.
    end.
  end.
  else do:
    assign
    var-prod = "":U
    var-prod-name = "":U.
  end.
  display
  var-prod
  var-prod-name
  with frame {&frame-name}
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj Dialog-Frame
ON CHOOSE OF r-obj IN FRAME Dialog-Frame /* Btn 3 */
DO:
  run sel-cur-obj  in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-sort Dialog-Frame
ON VALUE-CHANGED OF Rs-sort IN FRAME Dialog-Frame
DO:
  assign
  rs-sort.
  assign
  par-mode = string(rs-sort).
   RUn openbr in this-procedure ( input yes, input no, input '':U).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-object Dialog-Frame
ON VALUE-CHANGED OF T-object IN FRAME Dialog-Frame /* Объект */
DO:
   assign
  T-object.
  run MyEnable.
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
{ gbl/f2.i br-pbc goods-recid  get-gds-rec parparentproc " " this-procedure:handle }
{ gbl/brwrepos.i
&line-num=5 }

{ gbl/setfltnm.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  FIND FIRST obj_clients No-LOCK WHERE
                      obj_clients.obj-type = parobj-type AND
                      obj_clients.obj-code = parobj-code
                        no-error
                      .
  if not available obj_clients or
      NOT (parobj-type = {&shop} or parobj-type = {&stock}) then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра parobj-type/parobj-code" parobj-type parobj-code
        view-as alert-box.
        return error.
    end.
  FIND FIRST ub.sysconf No-LOCK WHERE
                      ub.sysconf.host-code = parhost-code no-error.
  if not available ub.sysconf then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра parhost-code" parhost-code
        view-as alert-box.
        return error.
    end.
    varempty-code = ?.
    { gbl/emptyscl.i varempty-code no-error  }
    if error-status:error then return error.
  assign
   varobj-type = parobj-type
   varobj-code = parobj-code
  .
  RUN MyEnable.
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
  DISPLAY Rs-sort T-object mark-num varobj-code var-prod var-prod-name
          varobj-type
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-del B-gds B-sch B-print B-Help Rs-sort
         T-object r-obj BR-pbc mark-num varobj-code var-prod var-prod-name
         varobj-type
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
for each temp-scaleable:
    delete temp-scaleable.
end.
for each temp-goods:
    delete temp-goods.
end.
_goods:
FOR EACH ub.goods NO-LOCK,
      EACH ub.units WHERE ub.units.unit-name = ub.goods.unit-base AND
                      LOOKUP({&weight}, ub.units.type) > 0 NO-LOCK,
      EACH ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code AND
                      ub.bar-code.unit-cli <> ub.goods.unit-base AND
                      ub.bar-code.part-code = "":U and
                      ub.bar-code.node-code = varempty-code NO-LOCK,
      EACH ub.bar_units where ub.bar_units.unit-name = ub.bar-code.unit-cli and
                      bar_units.type = {&divisional} NO-LOCK,
      EACH ub.prod-bc WHERE ub.prod-bc.b-code = ub.bar-code.b-code NO-LOCK
      On error undo, return error

      :
      IF t-object then do:
                FIND FIRST ub.gds-obj No-LOCK WHERE
                                 ub.gds-obj.gds-code = ub.goods.gds-code and
                                 ub.gds-obj.obj-type = varobj-type AND
                                 ub.gds-obj.obj-code = varobj-code No-ERROR.
                    if not avail ub.gds-obj then NEXT _goods.
              end.
      FIND FIRST temp-goods no-lock where
                 temp-goods.gds-code = ub.goods.gds-code no-error .
      if not avail temp-goods then do:
        create temp-goods.
        buffer-copy goods to temp-goods.
      end.
     create temp-scaleable.
    assign
    temp-scaleable.b-code = ub.goods.gds-code
    temp-scaleable.b-str  = ub.prod-bc.b-str
    temp-scaleable.prod-bc-rec = recid(ub.prod-bc)
        temp-scaleable.unit-cli  = ub.bar-code.unit-cli
    .
      { gbl/prodbcat.i
        ub.prod-bc
        "'global=request':u"
        temp-scaleable.is-global
        no-error
      }
    temp-scaleable.price-sale = get-price(varobj-type, varobj-code, ub.bar-code.b-code).
End.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-gds-rec Dialog-Frame
PROCEDURE get-gds-rec :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER loc_goods for ub.goods.

FIND FIRST loc_goods No-LOCK WHERE
                    loc_goods.gds-code = temp-goods.gds-code no-error.
if available loc_goods then gds-rec = recid(loc_goods).
else gds-rec = ?.
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
 DISPLAY
 mark-num
 var-prod
 var-prod-name
 varobj-code
 varobj-type
 WITH FRAME Dialog-Frame.
  ENABLE
  Rs-SOrt
  b-quit
  b-add
  b-del
  B-mark when lookup("b-mark":U, bttns) > 0
  B-sel when lookup("b-sel":U, bttns) > 0
  B-gds
  B-sch
  B-print
  B-Help
  BR-pbc
  mark-num
  var-prod
  var-prod-name
  r-obj
  T-object
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run waitfram-show in this-procedure ("Ждите...").
  Run fill-table in this-procedure.
  APPLY "VAlUE-CHANGED" to rs-sort.
  RUn openbr in this-procedure ( input yes, input no, input '':U).
  APPLY "Value-changed" to br-pbc.
  APPLY "entry" to br-pbc.
  run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE obj-on Dialog-Frame
PROCEDURE obj-on :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def input param o-type as character no-undo .
def input param o-code as integer   no-undo .

/* проверяем права на данный объект
   актуально при входе в систему, при переключении выборе контекста пользователь может
   выбрать только объект, который ему доступен
 */

define variable v-object-available as logical   no-undo .
{ gbl/usobjava.i
  v-cntxt-db-num
  {&action-head-code-main}
  v-cntxt-userid
  o-type
  o-code
  v-object-available
  no-error
}
if error-status :error
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при вызове процедуры gbl/usobjava.i" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return no-apply .
end.

if v-object-available <> true
then do:
  message
    "Объект недоступен для пользователя." skip
    "База данных" v-cntxt-db-num skip
    "Идентификатор пользователя" v-cntxt-userid skip
    "Объект" o-type o-code skip
    view-as alert-box error.
  return error.
end.
/* инициируем текущий объект */
do transaction
   on error undo, return error
   on stop undo, return error:
  assign
    varobj-type = o-type
    varobj-code = o-code
  .
end.
/* вывод новых значений на экран */
display
varobj-type
varobj-code
with frame {&frame-name}.
run MyEnable.
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
title0 = "Взвешиваемые коды".
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

&scop flt-open-open-query OPEN QUERY BR-pbc FOR EACH temp-goods

&scop flt-open-dyn_open-query  FOR EACH temp-goods

&scop flt-open-query-handle QUERY BR-pbc:handle

&scop flt-open-open-query-tail  , EACH temp-scaleable WHERE temp-scaleable.b-code = temp-goods.gds-code NO-LOCK


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name temp-goods

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 /*+ par-mode*/ .
CASE par-mode :
WHEN "1":U  THEN DO:
  assign
    frame {&frame-name}:title = title0 + {&space-char} + varobj-type + {&space-char} + string(varobj-code)
    filter-label = substitute("&1", filter-label0)
    .
  { gbl/fltopend.i
    &where-cond = " TRUE "
    &use-ind    = " "
    &by         = "  " }
END.
WHEN "2":U  THEN DO:
    assign
    frame {&frame-name}:title = title0 + {&space-char} + varobj-type + {&space-char} + string(varobj-code)
    filter-label = substitute("&1", filter-label0)
    .
  { gbl/fltopend.i
    &where-cond = " TRUE "
    &use-ind    = " "
    &by         = " by temp-scaleable.b-str " }
END.
WHEN "3":U  THEN DO:
    assign
    frame {&frame-name}:title = title0 + {&space-char} + varobj-type + {&space-char} + string(varobj-code)
    filter-label = substitute("&1", filter-label0)
    .
  { gbl/fltopend.i
    &where-cond = " TRUE "
    &use-ind    = " "
    &by         = " by temp-goods.gds-name " }
END.
WHEN "4":U  THEN DO:
    assign
    filter-label = substitute("&1", filter-label0)
    frame {&frame-name}:title = title0 + {&space-char} + varobj-type + {&space-char} + string(varobj-code).
  { gbl/fltopend.i
    &where-cond = " TRUE "
    &use-ind    = " "
    &by         = " by temp-goods.artic " }
END.

END CASE.
if not p-open-query then
REPOSITION br-pbc to recid v-doc-rec No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-pbc in frame {&frame-name}.
APPLY "ENTRY" TO br-pbc.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
define variable accum-count as integer.
DEFINE VARIABLE var-rec as recid no-undo.
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-r-b-abbr as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
{ gbl/r-b-abbr.i parhost-code v-r-b-abbr }

if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( v-r-b-abbr ) + " )" )
  .
end.
define buffer prod_clients for ub.clients.

DEFINE FRAME locsslist
temp-goods.gds-code
temp-scaleable.b-str FORMAT "X(9)"
temp-scaleable.is-global FORMAT "+/" COLUMN-LABEL "Глоб"
temp-scaleable.unit-cli COLUMn-LABEL "Ед!изм"
temp-goods.gds-name FORMAT "X(20)"
temp-scaleable.price-sale
temp-goods.artic
temp-goods.prod-type COLUMn-LABEL "":U
temp-goods.prod-code COLUMN-LABEL "Пр-ль"
prod_clients.obj-name COLUMN-LABEL "Название произв-ля" format "X(20)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(Prnlibstream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

if not available temp-goods then do:
    return.
end.
var-rec = recid(temp-goods).

Line = fill("-", 195).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM Prnlibstream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM Prnlibstream FRAME BottomFrame .

FORM with FRAME locsslist  .
run waitfram-show in this-procedure ("Ждите...").
DO WHILE available temp-goods :
  GET prev br-pbc.
END.
GET next br-pbc.
 DO WHILE available temp-goods :
        FIND prod_clients NO-LOCK WHERE
                prod_clients.obj-type = temp-goods.prod-type AND
                prod_clients.obj-code = temp-goods.prod-code NO-ERROR.
  Display STREAM Prnlibstream
  temp-goods.gds-code
    temp-goods.artic
    temp-goods.gds-name FORMAT "X(20)"
    temp-scaleable.b-str
    temp-scaleable.is-global
    temp-scaleable.unit-cli
    temp-goods.prod-type
    temp-goods.prod-code
    (if avail prod_clients then prod_clients.obj-name else "":U ) @ prod_clients.obj-name
    temp-scaleable.price-sale
  with FRAME locssList .
  DOWN STREAM Prnlibstream 1
  with FRAME locsslist  .
  assign
  accum-count = accum-count + 1
    .
  GET next br-pbc.
  END.
  UNDERLINE  STREAM Prnlibstream
    temp-goods.gds-code
    temp-goods.artic
    temp-goods.gds-name FORMAT "X(20)"
    temp-scaleable.b-str
    temp-scaleable.is-global
        temp-scaleable.unit-cli
    temp-goods.prod-type
    temp-goods.prod-code
    prod_clients.obj-name
    temp-scaleable.price-sale
  with FRAME locsslist .
  DISPLAY STREAM Prnlibstream
  ("ИТОГО" + {&space-char} + string(accum-count))  @ temp-goods.gds-name
  with frame locsslist.
HIDE  STREAM Prnlibstream FRAME BottomFrame .
HIDE  STREAM Prnlibstream FRAME locssList.
output  STREAM Prnlibstream CLOSE.
REPOSITION br-pbc to recid var-rec.
APPLY "ENTRY" to br-pbc.
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
  tbl = 'goods,clients'
  join-tbl = 'temp-goods,clients'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  c-point = "Список товаров"
  .
run fltfield-add in this-procedure('artic', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-name', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('engl-name', 'Название по-английски', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-base', '', 'unit',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-cli', '', 'unit',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('grp-name', '', 'gdsgrp',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prt-root', 'Шкала', 'prt',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('increase-pc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('qnty-cart', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wt-cart', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okdp', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('destin', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sert', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('struct', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sort', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('deadline', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('negative-rest', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cost-calc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-type', 'Услуга-товар', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tnved', 'Код ТНВЭД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nationality', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-cst', 'Таможенная единица', 'unit',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('alpha1', 'Код страны изготовления', 'country',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('normal-wastage', 'Норма естест.убыли', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('normal-waste', 'Норма отходов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('min-rate', 'Min кол-во в штуке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('max-rate', 'Max кол-во в штуке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

assign
fld = fld
lab = lab
dim = dim + {&comma-char}
.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
  ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
  ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
run gbl/filter.w ( INPUT parparentproc
                 , INPUT (filter-point + {&delim-par} + filter-label)
                 , INPUT tbl
                 , INPUT join-tbl
                 , INPUT fld
                 , INPUT lab
                 , INPUT spr
                 , INPUT dim ).
Run fill-table in this-procedure.
RUN OpenBr in this-procedure ( input  yes, input no, input '':U).
END. /* Filter-Block */



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-goods Dialog-Frame
PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .
DEFINE BUFFER buf_goods FOR ub.goods.
  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-pbc.
    end.
    when "last":U
    then do:
      get last br-pbc.
    end.
    when "prev":U
    then do:
      get prev br-pbc.
      if not available temp-goods then do:
        message
        "Это первый товар списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next {&browse-name}.
      if not available temp-goods then do:
        message
        "Это последний товар списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
    find first buf_goods No-LOCK WHERE
                 buf_goods.gds-code = temp-goods.gds-code no-error.
    if not avail buf_goods then do:
       p-recid = ?.
    END.
  assign
  p-recid = recid(buf_goods)
  .
  run reposition-query in this-procedure
    (input recid(temp-goods)
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-cur-obj Dialog-Frame
PROCEDURE sel-cur-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*----------------------------------------------------------
смена текущего объекта
----------------------------------------------------------*/
  define variable s-t as char no-undo.              /* старое значение varobj-type */
  define variable s-c as integer no-undo.           /* старое значение varobj-code */

  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .

  /* запоминаем текущие значения */
  assign
    s-t = varobj-type
    s-c = varobj-code
  .

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    parhost-code
    parobj-type
    parobj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select = true
  then do:
    /* меняем текущий объект */
    run obj-on in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ) no-error.
    if error-status:error then do:
      /* возвращаем старый объект */
      run obj-on (s-t, s-c) no-error.
      if error-status:error
      then do:
        return error.
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-price Dialog-Frame
FUNCTION get-price RETURNS DECIMAL
  ( input parobj-type as character, input parobj-code as integer, parb-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable v-doc-num like ub.price-doc.doc-num no-undo.
define variable v-price-sale like ub.price-list.price-sale no-undo.
define variable v-road-tax like ub.price-list.road-tax no-undo.
define variable v-excise like ub.price-list.excise no-undo.

    { gbl/bcodeprc.i parobj-type parobj-code parb-code 0 0 v-doc-num v-price-sale v-road-tax v-excise no-error }
    return v-price-sale.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME