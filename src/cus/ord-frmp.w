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

Корректировка строки заказа ПО

Автор: Чернова Светлана Александровна
Дата создания: 09/12/06
Author: Svetlana Chernova
Creation date: 09/12/06

*/
/*---------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT  PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter par-tmp as recid no-undo.
define input  parameter par-ord as recid no-undo.
define input  parameter p-line-mode as character no-undo .
define output parameter stp-cycle as log no-undo.
define output parameter stp-exit  as log no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "корректировка строки заказа ПО".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cus/df-zakaz.i }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ str/mplfacor.i }
/* Local Variable Definitions ---                                       */

define variable p-curr-code   as integer no-undo .
define variable p-curr-date   as date no-undo .
define variable p-exch-rate   as decimal no-undo .
define variable p-exch-scale  as decimal no-undo .
define variable p-curr-abbr   as character no-undo .

define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
{ gbl/getcntxt.i get }

assign
  store-type     = v-cntxt-obj-type
  store-code     = v-cntxt-obj-code
  loc-store-type = v-cntxt-obj-type
  loc-store-code = v-cntxt-obj-code

.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.ord-line

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.ord-line SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.ord-line SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.ord-line
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.ord-line


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-quit b-exit-cycl B-help scr-qnty ~
scr-price-rubl r-price scr-price-base scr-artic scr-gds-name scr-prod-code ~
scr-prod-type scr-prod-name scr-unit-base scr-unit-cli scr-cli-qnty ~
scr-sum-rubl scr-val scr-sum-base
&Scoped-Define DISPLAYED-OBJECTS scr-qnty scr-price-rubl scr-price-base ~
scr-artic scr-gds-name scr-prod-code scr-prod-type scr-prod-name ~
scr-unit-base v-cli-base-rate scr-unit-cli scr-cli-qnty scr-sum-rubl ~
scr-val scr-sum-base

/* Custom List Definitions                                              */
/* List-all,List-2,List-3,List-4,List-5,List-6                          */
&Scoped-define List-all scr-qnty scr-price-rubl scr-price-base scr-artic ~
scr-gds-name scr-prod-code scr-prod-type scr-prod-name scr-unit-base ~
scr-unit-cli scr-cli-qnty scr-sum-rubl scr-val scr-sum-base

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit-cycl AUTO-GO
     LABEL "Стоп&Цикл"
     SIZE 11 BY 1.

DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-save AUTO-GO
     LABEL "Со&хранить"
     SIZE 11 BY 1.

DEFINE BUTTON r-price
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Выбор цены".

DEFINE VARIABLE scr-artic AS CHARACTER FORMAT "X(16)"
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 17 BY .67.

DEFINE VARIABLE scr-cli-qnty AS DECIMAL FORMAT ">,>>>,>>9.999" INITIAL 0
     LABEL "Количество"
      VIEW-AS TEXT
     SIZE 13 BY .67 TOOLTIP "В ед.изм.поставщика".

DEFINE VARIABLE scr-gds-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-price-base AS DECIMAL FORMAT ">,>>>,>>9.99" INITIAL 0
     LABEL "Цена (вал)"
     VIEW-AS FILL-IN
     SIZE 23.25 BY 1.

DEFINE VARIABLE scr-price-rubl AS DECIMAL FORMAT ">,>>>,>>9.99" INITIAL 0
     LABEL "Цена (abbr_rub)"
     VIEW-AS FILL-IN
     SIZE 23 BY 1.

DEFINE VARIABLE scr-prod-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Производитель"
      VIEW-AS TEXT
     SIZE 10 BY .67.

DEFINE VARIABLE scr-prod-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-prod-type AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4.88 BY .67.

DEFINE VARIABLE scr-qnty AS DECIMAL FORMAT ">,>>>,>>9.999" INITIAL 0
     LABEL "Количество"
     VIEW-AS FILL-IN
     SIZE 13 BY 1.

DEFINE VARIABLE scr-sum-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма (баз.в.)"
      VIEW-AS TEXT
     SIZE 22 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE scr-sum-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма в abbr_rub"
      VIEW-AS TEXT
     SIZE 22 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE scr-unit-base AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE scr-unit-cli AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE scr-val AS CHARACTER FORMAT "XXX":U
      VIEW-AS TEXT
     SIZE 4.75 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-cli-base-rate AS DECIMAL FORMAT ">>,>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Коэффициент пересчета баз.ед.изм. в ед.изм.поставщика"
     FGCOLOR 1  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.ord-line SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-quit AT ROW 1 COL 12
     b-exit-cycl AT ROW 1 COL 22
     B-help AT ROW 1 COL 78.38
     scr-qnty AT ROW 5.38 COL 17.38 COLON-ALIGNED
     scr-price-rubl AT ROW 8 COL 17.5 COLON-ALIGNED
     r-price AT ROW 8 COL 43.5
     scr-price-base AT ROW 9 COL 17.5 COLON-ALIGNED
     scr-artic AT ROW 2.79 COL 17.38 COLON-ALIGNED
     scr-gds-name AT ROW 2.79 COL 36 COLON-ALIGNED NO-LABEL
     scr-prod-code AT ROW 3.83 COL 17.38 COLON-ALIGNED
     scr-prod-type AT ROW 3.88 COL 29 COLON-ALIGNED NO-LABEL
     scr-prod-name AT ROW 3.92 COL 35.75 COLON-ALIGNED NO-LABEL
     scr-unit-base AT ROW 5.54 COL 30.75 COLON-ALIGNED NO-LABEL
     v-cli-base-rate AT ROW 5.75 COL 37.5 COLON-ALIGNED NO-LABEL
     scr-unit-cli AT ROW 6.63 COL 30.75 COLON-ALIGNED NO-LABEL
     scr-cli-qnty AT ROW 6.67 COL 17.38 COLON-ALIGNED
     scr-sum-rubl AT ROW 8 COL 64.5 COLON-ALIGNED
     scr-val AT ROW 9 COL 2 NO-LABEL
     scr-sum-base AT ROW 9 COL 64.5 COLON-ALIGNED
     SPACE(1.12) SKIP(6.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>".


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN scr-artic IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-cli-qnty IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-gds-name IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-price-base IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-price-rubl IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-prod-code IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-prod-name IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-prod-type IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-qnty IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-sum-base IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-sum-rubl IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-unit-base IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-unit-cli IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN scr-val IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN v-cli-base-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.ord-line"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit-cycl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit-cycl Dialog-Frame
ON CHOOSE OF b-exit-cycl IN FRAME Dialog-Frame /* СтопЦикл */
DO:
   assign
     stp-cycle  =  true
     stp-exit  =  false.
     .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
if p-line-mode = {&lookup} then do:
    stp-cycle  =  false.
    stp-exit  =  true .
    return.

end.

define variable compare-log as logical no-undo .
if p-line-mode <> "ЦИКЛ":u   then do:
   /* BUFFER-COMPARE  tt-ord-line to tmp#zakaz save result in compare-log no-error.*/
    if compare-log = false then do:
        message "Вы действительно хотите выйти без сохранения изменений ?" view-as alert-box question
                buttons yes-no   update jjj as logical .
                if jjj = true then
                       /* BUFFER-COPY tt-ord-line to  tmp#zakaz . */
    end.
end.
    stp-cycle  =  false.
    stp-exit  =  true .
    return "error".


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
    stp-cycle  =  false.
    stp-exit   =  false.

    assign frame {&frame-name} scr-qnty .
    if scr-price-rubl:SENSITIVE then  assign frame {&frame-name} scr-price-rubl .
    if scr-price-base:SENSITIVE then  assign frame {&frame-name} scr-price-base .
    assign
      shar_ord-line.qnty       = scr-qnty
      shar_ord-line.cli-qnty   = scr-qnty
      shar_ord-line.cli-base-rate   = 1
      shar_ord-line.price-rubl = scr-price-rubl
      shar_ord-line.price-base = scr-price-base
      shar_ord-line.price-cli  = scr-price-rubl
      shar_ord-line.sum-rubl = shar_ord-line.price-rubl * shar_ord-line.qnty
      shar_ord-line.sum-base = shar_ord-line.price-base * shar_ord-line.qnty
      shar_ord-line.sum-cli  = shar_ord-line.price-cli  * shar_ord-line.qnty

    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-price Dialog-Frame
ON CHOOSE OF r-price IN FRAME Dialog-Frame
DO:
  run ch-price in this-procedure no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка !!!"
    view-as alert-box error
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-price-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-price-base Dialog-Frame
ON LEAVE OF scr-price-base IN FRAME Dialog-Frame /* Цена (вал) */
DO:
if scr-price-base:modified = false then return .
 assign  frame {&frame-name} scr-price-base .
    scr-price-rubl = scr-price-base * ( p-exch-rate  / p-exch-scale )     .
    scr-sum-rubl =  scr-price-rubl * scr-qnty .
    scr-sum-base =  scr-price-base  * scr-qnty .

    display scr-price-rubl  scr-sum-base scr-sum-rubl with frame {&frame-name} .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-price-base Dialog-Frame
ON return OF scr-price-base IN FRAME Dialog-Frame /* Цена (вал) */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-price-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-price-rubl Dialog-Frame
ON LEAVE OF scr-price-rubl IN FRAME Dialog-Frame /* Цена (abbr_rub) */
DO:
   if scr-price-rubl:modified = false then return .
    assign  frame {&frame-name}  scr-price-rubl.
    scr-price-base = scr-price-rubl / ( p-exch-rate  * p-exch-scale )     .
    scr-sum-rubl =  scr-price-rubl * scr-qnty .
    scr-sum-base =  scr-price-base  * scr-qnty .

    display scr-price-base  scr-sum-base scr-sum-rubl with frame {&frame-name} .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-price-rubl Dialog-Frame
ON return OF scr-price-rubl IN FRAME Dialog-Frame /* Цена (abbr_rub) */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-qnty Dialog-Frame
ON LEAVE OF scr-qnty IN FRAME Dialog-Frame /* Количество */
DO:
  assign frame {&frame-name} scr-qnty .
/*Если кол-во в базовых единицах товара получается дробное, то ошибка.*/
 IF CAN-FIND ( FIRST ub.units WHERE ub.units.unit-name = scr-unit-base
                    and LOOKUP({&pieces}, ub.units.type) > 0   AND
                       TRUNC(scr-qnty, 0)   <>    scr-qnty         )
   THEN DO:
      MESSAGE "Базовая единица товара " scr-unit-base " - штучная." skip
              "Кол-во  должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN no-apply.
  END.


    scr-sum-rubl =  scr-price-rubl * scr-qnty .
    scr-sum-base =  scr-price-base * scr-qnty .
    scr-cli-qnty =  scr-qnty / v-cli-base-rate .

 IF CAN-FIND ( FIRST ub.units WHERE ub.units.unit-name = scr-unit-cli
                    and LOOKUP({&pieces}, ub.units.type) > 0   AND
                       TRUNC(scr-cli-qnty, 0)   <>    scr-cli-qnty         )
   THEN DO:
      MESSAGE
              "Единица товара поставщика" scr-unit-cli " - штучная." skip
              "Получается не полная единица измерения поставщика !!!."
      view-as alert-box information
      title "внимание".

  END.

    display  scr-cli-qnty  scr-sum-base scr-sum-rubl with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-qnty Dialog-Frame
ON return OF scr-qnty IN FRAME Dialog-Frame /* Количество */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

assign
  scr-price-rubl :label = "Цена ({&abbr_rub})"
  scr-sum-rubl   :label = "Сумма в {&abbr_rub}"
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

 { gbl/basecode.i g#host-code p-curr-code  }
 { gbl/exchrate.i
   p-curr-code
   p-curr-date
   p-exch-rate
   p-exch-scale
   p-curr-abbr
  }

    run init-proc.
    if p-line-mode = {&lookup} then run lkp-enable.
                               else RUN my-enable.

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-price Dialog-Frame
PROCEDURE ch-price :
define variable v-cli-type    as character no-undo .
define variable v-cli-code    as integer   no-undo .
define variable v-main-b-code as integer   no-undo .
define variable v-b-code      as integer   no-undo .
define variable v-obj-type    as character no-undo .
define variable v-obj-code    as integer   no-undo .
define variable v-qnty-doc    as decimal   no-undo .
define variable v-sum-doc     as decimal   no-undo .
define variable v-fact-order  as decimal   no-undo .
define variable v-plt-id      as integer   no-undo .
define variable v-plt-db-num  as integer   no-undo .
define variable v-pdf-id      as integer   no-undo .
define variable v-pdf-db-num  as integer   no-undo .
define variable v-sale-price-base as decimal   no-undo .
define variable v-sale-price-rubl as decimal   no-undo .
define variable v-pay-code as character no-undo .
  do
  on error undo, return error return-value
  :

  { gbl/gdsbcode.i
     shar_ord-line.gds-code
     ?
     v-main-b-code }

run fact-order-mpl  in this-procedure (
    input doc-date ,
    input loc-store-type ,
    input loc-store-code ,
    output v-fact-order) .

assign
  v-pay-code  = string(paytype)
  v-cli-type  = loc-cli-type
  v-cli-code  = loc-cli-code
  v-b-code    = v-main-b-code
  v-obj-type  = loc-store-type
  v-obj-code  = loc-store-code
  .
v-sum-doc       = 0 .
define buffer buf_loc_ord-line for ub.ord-line  .
for each buf_loc_ord-line no-lock where
         buf_loc_ord-line.doc-code = shar_ord-line.doc-code :
  if
  not
  ( buf_loc_ord-line.prod-code = shar_ord-line.prod-code and
    buf_loc_ord-line.prod-type = shar_ord-line.prod-type and
    buf_loc_ord-line.artic     = shar_ord-line.artic      )
   then
   v-sum-doc = v-sum-doc + ( buf_loc_ord-line.fact-qnty * buf_loc_ord-line.price-rubl ) .
end.

    run str/chmpldoc.w
        (input parparentproc
        ,input  v-cli-type
        ,input  v-cli-code
        ,input  v-main-b-code
        ,input  v-b-code
        ,input  v-obj-type
        ,input  v-obj-code
        ,input  v-qnty-doc
        ,input  v-sum-doc
        ,input  v-pay-code
        ,input  ""
        ,input  v-fact-order
        ,output v-plt-id
        ,output v-plt-db-num
        ,output v-pdf-id
        ,output v-pdf-db-num
        ,output v-sale-price-base
        ,output v-sale-price-rubl
        ).
 if v-plt-id = ? then return.

 if scr-price-rubl:visible in frame {&frame-name} and scr-price-rubl:SENSITIVE then do:
    scr-price-rubl = v-sale-price-rubl .
    display scr-price-rubl with frame {&frame-name} .
    apply "leave" to scr-price-rubl in frame {&frame-name}.
 end.
 else do:
    if scr-price-base:visible and  scr-price-base:SENSITIVE then do:
        scr-price-base = v-sale-price-base .
        display scr-price-base with frame {&frame-name} .
        apply "leave" to scr-price-base in frame {&frame-name}.
    end.
  end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY scr-qnty scr-price-rubl scr-price-base scr-artic scr-gds-name
          scr-prod-code scr-prod-type scr-prod-name scr-unit-base
          v-cli-base-rate scr-unit-cli scr-cli-qnty scr-sum-rubl scr-val
          scr-sum-base
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-quit b-exit-cycl B-help scr-qnty scr-price-rubl r-price
         scr-price-base scr-artic scr-gds-name scr-prod-code scr-prod-type
         scr-prod-name scr-unit-base scr-unit-cli scr-cli-qnty scr-sum-rubl
         scr-val scr-sum-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  define buffer buf_goods for ub.goods.
  define buffer buf_clients for ub.clients.
  if p-line-mode = {&lookup} then
     find first shar_ord-line no-lock where recid(shar_ord-line) = par-ord no-error .
  else
     find first shar_ord-line  exclusive-lock  where recid(shar_ord-line) = par-ord no-error .
          if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
                "Ошибка  " skip
                  "p-line-mode" p-line-mode    skip
                  "par-ord" par-ord  skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error
          .
          return error .
          end.

   ASSIGN frame {&frame-name}:TITLE = "Строка заказа  № " + shar_ord-line.doc-code  + " - " + caps(p-line-mode).


  find first buf_goods no-lock  WHERE
            buf_goods.artic     = shar_ord-line.artic      and
            buf_goods.prod-code = shar_ord-line.prod-code  and
            buf_goods.prod-type = shar_ord-line.prod-type no-error .
          if error-status :error then do:
             return error .
          end.
  find first buf_clients no-lock  WHERE
            buf_clients.obj-code = shar_ord-line.prod-code  and
            buf_clients.obj-type = shar_ord-line.prod-type no-error .
          if error-status :error then do:
             return error .
          end.

       assign
          scr-qnty       = shar_ord-line.qnty
          scr-price-rubl = shar_ord-line.price-rubl
          scr-price-base = shar_ord-line.price-base
          scr-artic      = shar_ord-line.artic
          scr-gds-name   = buf_goods.gds-name
          scr-prod-code  = shar_ord-line.prod-code
          scr-prod-type  = shar_ord-line.prod-type
          scr-prod-name  = buf_clients.obj-name
          scr-unit-base  = buf_goods.unit-base
          scr-val        = p-curr-abbr
          scr-cli-qnty   =  scr-qnty / buf_goods.cli-base-rate
          scr-unit-cli   = shar_ord-line.unit-cli
          scr-sum-rubl   = scr-qnty  *  scr-price-rubl
          scr-sum-base   = scr-qnty  *  scr-price-base
          v-cli-base-rate = buf_goods.cli-base-rate
       .



  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lkp-enable Dialog-Frame
PROCEDURE lkp-enable :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

  DISPLAY scr-qnty scr-price-rubl scr-price-base scr-artic scr-gds-name
          scr-prod-code scr-prod-type scr-prod-name scr-unit-base scr-val
          scr-cli-qnty scr-unit-cli scr-sum-rubl scr-sum-base v-cli-base-rate
      WITH FRAME Dialog-Frame.
  ENABLE b-quit
         B-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  WAIT-FOR GO OF FRAME {&FRAME-NAME} .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable p-r-b-abbr as character no-undo .
{ gbl/curr-r-b.i p-r-b-abbr}
  DISPLAY scr-qnty scr-price-rubl scr-price-base scr-artic scr-gds-name
          scr-prod-code scr-prod-type scr-prod-name scr-unit-base scr-val
          scr-cli-qnty scr-unit-cli scr-sum-rubl scr-sum-base v-cli-base-rate
      WITH FRAME Dialog-Frame.
  ENABLE b-save
         b-quit
         b-exit-cycl   when p-line-mode = "ЦИКЛ":u
         B-help
         scr-qnty
         r-price
         scr-price-rubl when p-r-b-abbr = {&r-b-rubl}
         scr-price-base when p-r-b-abbr <> {&r-b-rubl}
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-line-mode <> "ЦИКЛ":u  then hide b-exit-cycl in frame {&frame-name} .

  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus scr-qnty .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-focus Dialog-Frame
PROCEDURE next-focus :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter p-widget-handle as handle no-undo .
define variable l-apply-entry as logical no-undo .

assign
  l-apply-entry = /* false */  true
.

do with frame {&frame-name} :
  if  scr-qnty       :handle = p-widget-handle then do:  if scr-price-rubl     :sensitive then do:       apply "entry":u to scr-price-rubl   .        return . end.
                                                         if scr-price-base     :sensitive then do:       apply "entry":u to scr-price-base   .        return . end.
                                                    end.
  if  scr-price-rubl :handle = p-widget-handle then do:  if B-save    :sensitive then do:       apply "entry":u to B-save    .        return . end. end.
  if  scr-price-base :handle = p-widget-handle then do:  if B-save    :sensitive then do:       apply "entry":u to B-save    .        return . end. end.
  end. /* do with frame */


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME