&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр и вызов редактирования отрицательных партий

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/22/00


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-doc-code     like ub.trn-doc.doc-code no-undo .
define input  parameter p-line-mode    as character no-undo .
define input-output parameter p-part-recid  as recid no-undo .


/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Просмотр и вызов редактирования отрицательных партий".
{ cmp/vssrevis.i }
{ gbl/color.i    }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/fltopend.i defproc }

define temp-table goods-cache no-undo
  field artic     like ub.parts.artic
  field prod-type like ub.parts.prod-type
  field prod-code like ub.parts.prod-code
  field root-node as integer
  field b-code    like ub.bar-code.b-code
  field gds-name  like ub.goods.gds-name
  index pk is unique primary artic prod-type prod-code
.


def var parts-b-code    like ub.bar-code.b-code no-undo .
def var parts-gds-name  like ub.goods.gds-name no-undo .
def var parts-part-code as character no-undo COLUMN-LABEL "Партия" FORMAT "x(14)" .
def var parts-prod      as character no-undo COLUMN-LABEL "Производитель" FORMAT "x(12)" .
def var parts-supp      as character no-undo COLUMN-LABEL "Поставщик"     FORMAT "x(16)" .

def var filter-point     as character no-undo .
def var sort-column-name as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-parts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES parts

/* Definitions for BROWSE br-parts                                      */
&Scoped-define FIELDS-IN-QUERY-br-parts get-goods-bar-code(ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code) @ parts-b-code ub.parts.artic get-goods-gds-name(ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code) @ parts-gds-name ub.parts.price-base ub.parts.price-rubl ub.parts.qnty ub.parts.fact-qnty (if ub.parts.part-code = "" then "------" else ub.parts.part-code) @ parts-part-code (ub.parts.prod-type + " " + string (ub.parts.prod-code)) @ parts-prod (ub.parts.supp-type + " " + string (ub.parts.supp-code)) @ parts-supp is-supp
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-parts ub.parts.qnty ~
ub.parts.fact-qnty
&Scoped-define FIELD-PAIRS-IN-QUERY-br-parts~
 ~{&FP1}qnty ~{&FP2}qnty ~{&FP3}~
 ~{&FP1}fact-qnty ~{&FP2}fact-qnty ~{&FP3}
&Scoped-define ENABLED-TABLES-IN-QUERY-br-parts ub.parts
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-parts ub.parts
&Scoped-define SELF-NAME br-parts
&Scoped-define OPEN-QUERY-br-parts OPEN QUERY {&SELF-NAME} FOR EACH ub.parts NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-parts ub.parts
&Scoped-define FIRST-TABLE-IN-QUERY-br-parts ub.parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-flt s-code b-exit b-lkp b-gds b-in ~
b-sch b-b-alt b-pl b-help br-parts RECT-1
&Scoped-Define DISPLAYED-FIELDS parts.artic parts.prod-type parts.prod-code ~
parts.price-base parts.SLT-pc parts.SLT-type parts.price-rubl parts.VAT-pc ~
parts.VAT-type parts.price-cli parts.qnty parts.fact-qnty parts.supp-type ~
parts.supp-code parts.is-supp
&Scoped-Define DISPLAYED-OBJECTS s-code fi-prod-name fi-curr-base ~
fi-curr-rubl fi-curr-cli fi-supp-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-goods-bar-code Dialog-Frame
FUNCTION get-goods-bar-code RETURNS INTEGER
  ( p-artic as character, p-prod-type as character, p-prod-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-goods-gds-name Dialog-Frame
FUNCTION get-goods-gds-name RETURNS CHARACTER
  ( p-artic as character, p-prod-type as character, p-prod-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-b-alt
     LABEL "Доп.&БК"
     SIZE 8 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход "
     SIZE 6 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 6 BY 1.

DEFINE BUTTON b-gds
     LABEL "&Товар"
     SIZE 6 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 6 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-in
     LABEL "П&Н"
     SIZE 6 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просм"
     SIZE 6 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-pl
     LABEL "&Место"
     SIZE 6 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 6 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-curr-base AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-curr-cli AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-curr-rubl AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-prod-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-supp-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE s-code AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 95.75 BY 8.25.

DEFINE RECTANGLE rect-flt
     EDGE-PIXELS 0
     SIZE 0.1 BY 0.1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-parts FOR
      ub.parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-parts Dialog-Frame _FREEFORM
  QUERY br-parts DISPLAY
      get-goods-bar-code(ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code) @ parts-b-code
      ub.parts.artic
      get-goods-gds-name(ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code) @ parts-gds-name
      ub.parts.price-base
      ub.parts.price-rubl
      ub.parts.qnty COLUMN-LABEL "По док./ Свобод."
      ub.parts.fact-qnty COLUMN-LABEL "Факт / Остаток"
      (if ub.parts.part-code = "" then "------" else ub.parts.part-code) @ parts-part-code
      (ub.parts.prod-type + " " + string (ub.parts.prod-code)) @ parts-prod
      (ub.parts.supp-type + " " + string (ub.parts.supp-code)) @ parts-supp
      is-supp FORMAT "+/-" COLUMN-LABEL "П"
  ENABLE
      parts.qnty
      parts.fact-qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 11.33
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     s-code AT ROW 1.21 COL 67.63 COLON-ALIGNED
     b-exit AT ROW 1.25 COL 1
     b-lkp AT ROW 1.25 COL 7
     b-gds AT ROW 1.25 COL 13
     b-in AT ROW 1.25 COL 19
     b-sch AT ROW 1.25 COL 25
     b-b-alt AT ROW 1.25 COL 25
     b-pl AT ROW 1.25 COL 37
     b-help AT ROW 1.25 COL 43
     b-print AT ROW 1.25 COL 49
     br-parts AT ROW 2.42 COL 1
     parts.artic AT ROW 14 COL 17.75 COLON-ALIGNED
          LABEL "Артикул"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     parts.prod-type AT ROW 15.08 COL 17.75 COLON-ALIGNED
          LABEL "Производитель"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4
     parts.prod-code AT ROW 15.08 COL 27.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          FGCOLOR 4
     fi-prod-name AT ROW 15.08 COL 34.25 COLON-ALIGNED NO-LABEL
     parts.price-base AT ROW 16.25 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     fi-curr-base AT ROW 16.25 COL 36.25 COLON-ALIGNED NO-LABEL
     parts.SLT-pc AT ROW 16.42 COL 52.75 COLON-ALIGNED
          LABEL "НП"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          FGCOLOR 4
     parts.SLT-type AT ROW 16.42 COL 59.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4
     parts.price-rubl AT ROW 17.5 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     fi-curr-rubl AT ROW 17.5 COL 36.25 COLON-ALIGNED NO-LABEL
     parts.VAT-pc AT ROW 17.5 COL 52.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          FGCOLOR 4
     parts.VAT-type AT ROW 17.5 COL 59.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4
     parts.price-cli AT ROW 18.67 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     fi-curr-cli AT ROW 18.67 COL 36.25 COLON-ALIGNED NO-LABEL
     parts.qnty AT ROW 19.83 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     parts.fact-qnty AT ROW 19.92 COL 52.75 COLON-ALIGNED
          LABEL "Факт"
          VIEW-AS FILL-IN
          SIZE 18 BY 1
          FGCOLOR 4
     parts.supp-type AT ROW 21 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     parts.supp-code AT ROW 21 COL 28 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     fi-supp-name AT ROW 21 COL 38.75 COLON-ALIGNED NO-LABEL
     parts.is-supp AT ROW 21.08 COL 67.75
          LABEL "Поставка"
          VIEW-AS TOGGLE-BOX
          SIZE 11.5 BY .83
     rect-flt AT ROW 1 COL 25
     "Информация из документа" VIEW-AS TEXT
          SIZE 23.75 BY .67 AT ROW 13.33 COL 36.25
     RECT-1 AT ROW 13.83 COL 1.25
     SPACE(0.49) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Порожденные партии по документу"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-parts b-print Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN parts.artic IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR BUTTON b-print IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-print:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       br-parts:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 2.

/* SETTINGS FOR FILL-IN parts.fact-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN fi-curr-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-curr-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-curr-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-prod-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-supp-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX parts.is-supp IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN parts.price-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parts.price-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parts.price-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parts.prod-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parts.prod-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN parts.qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parts.SLT-pc IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN parts.SLT-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parts.supp-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parts.supp-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parts.VAT-pc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parts.VAT-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-parts
/* Query rebuild information for BROWSE br-parts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH parts NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-parts */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Порожденные партии по документу */
DO:
  /* ничего не делаем */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Порожденные партии по документу */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-b-alt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-b-alt Dialog-Frame
ON CHOOSE OF b-b-alt IN FRAME Dialog-Frame /* Доп.БК */
DO:
  { gbl/stdbtn.i }

  if available ub.parts then do:
    def var v-b-code like ub.bar-code.b-code no-undo .
    { gbl/partbcod.i
      parts
      v-b-code
    }
    run ref/alt-bc.w
      (
       input parparentproc
      ,input ub.trn-doc.obj-type
      ,input ub.trn-doc.obj-code
      ,input v-b-code
      ).
  end.
  apply "entry":u to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход  */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  { gbl/stdbtn.i }

  def var tbl      as character no-undo.
  def var join-tbl as character no-undo.
  def var fld      as character no-undo.
  def var lab      as character no-undo.
  def var spr      as character no-undo.
  def var dim      as character no-undo.

  assign
    tbl      = 'ub.parts'
    join-tbl = ''
    fld      = 'substring(parts.artic{&delim-flt-tilda}0541{&delim-flt-tilda}0543),in-code,artic,prod-type{&delim-flt}prod-code,obj-type{&delim-flt}obj-code,supp-type{&delim-flt}supp-code,part-code,status_,qnty,fact-qnty,fact-date,pay-code,doc-type,price-base,price-rubl,price-cli,exch-code,is-supp'
    lab      = 'Артик 3,Номер ПН,,Производитель,Объект,Поставщик,,Закр,Кол.док.,Факт.кол.,Дата,Код Оплаты,Тип Докум.,Цена (вал),Цена ({&abbr_rub}),Цена пост. (вал),Валюта пост.,Поставка'
    spr      = 'function_character,,,,cli,cli,cli,,,,,,pay,trn-type,,,curr,'
    dim      = '18'
  .

/* Список полей, не включенных в фильтр в настоящее время,
   которые можно включить в дальнейшем

SLT-pc
VAT-pc
VAT-type

cli-base-rate
cli-qnty
fact-num
host-code
is-supp
pl-code
rsrv-free
PS
*/


  do on stop undo, leave:
    run gbl/filter.w (parparentproc, filter-point, tbl, join-tbl, fld, lab, spr, dim).
    run reopen-query .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds Dialog-Frame
ON CHOOSE OF b-gds IN FRAME Dialog-Frame /* Товар */
DO:
  { gbl/stdbtn.i }
  if available ub.parts
  then do:
    define variable v-gds-code as integer   no-undo .
    { gbl/pargocod.i
      recid(ub.parts)
      v-gds-code
    }

    run str/showgds.p
      (input parparentproc
      ,input ? /*p-call-handle*/
      ,input v-gds-code /* p-gds-code */
      ,input {&lookup}  /* p-mode     */
      ).
  end.
  apply "entry":u to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-in
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-in Dialog-Frame
ON CHOOSE OF b-in IN FRAME Dialog-Frame /* ПН */
DO:
  { gbl/stdbtn.i }
  if available ub.parts then do:
    /* показать складской документ */
    run str/showdoc.p
      (input parparentproc       /* parparentproc */
      ,input ub.parts.in-code    /* p-doc-code    */
      ,input ub.parts.artic      /* p-artic       */
      ,input ub.parts.prod-type  /* p-prod-type   */
      ,input ub.parts.prod-code  /* p-prod-code   */
      ,input true                /* p-doc-type    */
      ).
  end.
  apply "entry":u to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просм */
DO:
  if available ub.parts then do:
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = ub.parts.artic
        and buf_doc-line.prod-type = ub.parts.prod-type
        and buf_doc-line.prod-code = ub.parts.prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        "На найдена строка документа" skip
        "Документ" p-doc-code
        "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code
        view-as alert-box error .
      undo, return no-apply .
    end.
    run str/partsedt.p
      (input parparentproc
      ,buffer buf_doc-line /* buf_doc-line */
      ,input  true         /* l-update     */
      ,input  true         /* l-reserv     */
      ,input  0            /* p-chg-qnty   */
      ) no-error .
    /* переоткрываем query, если мы находимся в режиме редактирования партий */
    if p-line-mode = {&update}
    then do:
      assign
        p-part-recid = recid(parts)
      .
      run reopen-query .
    end.
  end.
  else do:
    message
      "Не выбрана строка"
      view-as alert-box .
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-pl Dialog-Frame
ON CHOOSE OF b-pl IN FRAME Dialog-Frame /* Место */
DO:
  { gbl/stdbtn.i }
  if available ub.parts
  then do:
    run str/pl-lkp.w
      (
        input parparentproc
       ,input recid(parts)
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  /* */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-parts
&Scoped-define SELF-NAME br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-parts IN FRAME Dialog-Frame
DO:
  if b-lkp :sensitive then do:
    apply "choose":u to b-lkp in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON RETURN OF br-parts IN FRAME Dialog-Frame
DO:
  if b-lkp :sensitive then do:
    apply "choose":u to b-lkp in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON VALUE-CHANGED OF br-parts IN FRAME Dialog-Frame
DO:
  run display-parts-info .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME s-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-code Dialog-Frame
ON LEAVE OF s-code IN FRAME Dialog-Frame /* Бар-код */
DO:
  def var v-s-code as integer no-undo .

  assign
    v-s-code = input frame {&frame-name} s-code
  .

  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods    .
  define buffer buf_parts    for ub.parts    .

  find first buf_bar-code no-lock
    where buf_bar-code.b-code = v-s-code
    no-error .

  if available buf_bar-code then do:
    find first buf_goods no-lock
      where buf_goods.gds-code = buf_bar-code.gds-code
      .

    for each buf_parts no-lock
      where buf_parts.artic     = buf_goods.artic
        and buf_parts.prod-type = buf_goods.prod-type
        and buf_parts.prod-code = buf_goods.prod-code
        and buf_parts.in-code   = buf_bar-code.in-code
        and buf_parts.part-code = buf_bar-code.part-code
    :
      reposition br-parts to recid recid(buf_parts) no-error.
      if not error-status :error then do:
        run reposition-query in this-procedure
          (input recid(buf_parts)
          ).
        return no-apply.
      end.
    end.
  end.

  message
    "Бар-код не найден !"
    view-as alert-box .
  return no-apply.
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

{ gbl/hot-key.i b-lkp }

run init-filter-point .

assign
  parts.qnty      :read-only in browse {&BROWSE-NAME} = true
  parts.fact-qnty :read-only in browse {&BROWSE-NAME} = true
.

/* по умолчанию выбранная строка будет показана посередине брауза */
if browse {&browse-name}:set-repositioned-row(3, "CONDITIONAL" ) then .

{ gbl/mv-clmn.i
  &frame-name = "{&frame-name}"
  &browse-name = "{&browse-name}"
  &table-name = "{&first-table-in-query-{&browse-name}}"
  &start-column = 3
  &ext-col = 11
}


{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "ub.parts.artic"
  &sort-clmn_2    = "parts-prod"
  &sort-clmn_3    = "ub.parts.qnty"
  &sort-clmn_4    = "ub.parts.fact-qnty"
  &sort-clmn_5    = "ub.parts.price-base"
  &sort-clmn_6    = "ub.parts.price-rubl"
  &sort-clmn_7    = "parts-part-code"
  &sort-clmn_8    = "get-goods-bar-code(ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code)"
  &dyn_sort-clmn_8  = "substitute('dynamic-function(&1get-goods-bar-code&1,&1&2&1,&1&3&1,&1&4&1)', ~{&double-quote~} ,ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code)"
  &label-clmn_8   = "parts-b-code :label in browse {&browse-name}"
  &sort-clmn_9    = "get-goods-gds-name(ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code)"
  &dyn_sort-clmn_9    = "substitute('dynamic-function(&1get-goods-gds-name&1,&1&2&1,&1&3&1,&1&4&1)', ~{&double-quote~} ,ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code)"
  &label-clmn_9   = "parts-gds-name :label in browse {&browse-name}"
  &sort-clmn_10   = "is-supp"
  &sort-clmn_11   = "parts-supp"
  &open-query     = "run reopen-query."
  &open-query-otherwise = "run reopen-query."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "no"
}

/* possible todo - ??? - сделать поиск по отсортированному полю */
/*{ str/sch-line.i {&first-table-in-query-{&browse-name}} {&browse-name}}*/

/* закомментировали код по умолчанию */
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

/* we have replace standard main_block with custom main_block */
/*MAIN-BLOCK:*/
/*DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK*/
/*   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:*/
/*  RUN enable_UI .*/
/*  WAIT-FOR GO OF FRAME {&FRAME-NAME}.*/
/*END.*/
/*RUN disable_UI.*/

MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  run main-block-procedure no-error .
  if error-status :error then do:
    undo MAIN-BLOCK, LEAVE MAIN-BLOCK .
  end.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-parts-info Dialog-Frame
PROCEDURE display-parts-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_clients  for ub.clients .

  def var v-b-code like ub.bar-code.b-code no-undo .

  do with frame {&frame-name}:
    if available ub.parts then do:
      { gbl/partbcod.i
        ub.parts
        v-b-code
        no-error
      }
      display
        v-b-code @ s-code
        with frame {&frame-name}.

      find buf_clients no-lock
        where buf_clients.obj-type = parts.prod-type
          and buf_clients.obj-code = parts.prod-code
        no-error .
      if available buf_clients then do:
        assign
          fi-prod-name :screen-value = buf_clients.obj-name
        .
      end.

      find buf_clients no-lock
        where buf_clients.obj-type = parts.supp-type
          and buf_clients.obj-code = parts.supp-code
        no-error .
      if available buf_clients then do:
        assign
          fi-supp-name :screen-value = buf_clients.obj-name
        .
      end.


      display
        parts.artic
        parts.prod-type
        parts.prod-code
        parts.supp-type
        parts.supp-code
        parts.is-supp
        parts.price-base
        parts.price-rubl
        parts.price-cli
        parts.SLT-pc
        parts.SLT-type
        parts.VAT-pc
        parts.VAT-type
        parts.qnty
        parts.fact-qnty
        with frame {&frame-name}.
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY s-code fi-prod-name fi-curr-base fi-curr-rubl fi-curr-cli fi-supp-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.parts THEN
    DISPLAY parts.artic parts.prod-type parts.prod-code parts.price-base
          parts.SLT-pc parts.SLT-type parts.price-rubl parts.VAT-pc
          parts.VAT-type parts.price-cli parts.qnty parts.fact-qnty
          parts.supp-type parts.supp-code parts.is-supp
      WITH FRAME Dialog-Frame.
  ENABLE rect-flt s-code b-exit b-lkp b-gds b-in b-sch b-b-alt b-pl b-help
         br-parts RECT-1
      WITH FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-goods-cache Dialog-Frame
PROCEDURE get-goods-cache :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-artic     like ub.goods.artic     no-undo .
  define input parameter p-prod-type like ub.goods.prod-type no-undo .
  define input parameter p-prod-code like ub.goods.prod-code no-undo .
  define parameter buffer buf_goods-cache for goods-cache .

  find first buf_goods-cache no-lock
    where buf_goods-cache.artic     = p-artic
      and buf_goods-cache.prod-type = p-prod-type
      and buf_goods-cache.prod-code = p-prod-code
    no-error .

  if not available buf_goods-cache then do:
    create buf_goods-cache .
    assign
      buf_goods-cache.artic     = p-artic
      buf_goods-cache.prod-type = p-prod-type
      buf_goods-cache.prod-code = p-prod-code
    .

    define buffer buf_goods for ub.goods .
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    assign
      buf_goods-cache.gds-name = buf_goods.gds-name
    .

    { gbl/rootnode.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      buf_goods-cache.root-node
    }

    { gbl/gdsbcode.i
      buf_goods.gds-code
      buf_goods-cache.root-node
      buf_goods-cache.b-code
    }
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-filter-point Dialog-Frame
PROCEDURE init-filter-point :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  assign
    filter-point = entry(1, entry(2, vss-workfile, ' '), '.')
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main-block-procedure Dialog-Frame
PROCEDURE main-block-procedure :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error   undo , return error
  on end-key undo , return error
  :
    find first ub.trn-doc no-lock
      where ub.trn-doc.doc-code = p-doc-code
      no-error .
    if not available ub.trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Документ не найден" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      p-part-recid = ?
    .

    if p-line-mode = {&update}
    then do:
      do with frame {&frame-name}:
        assign
          b-lkp :label = "&Измен"
        .
      end. /* do with frame */
    end.


    RUN enable_UI .

    run reopen-query .

    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-parts .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame
PROCEDURE reopen-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  run UI-on .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-parts Dialog-Frame
PROCEDURE reposition-parts :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-direction   as character no-undo .
  define output parameter p-parts-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую
     или на определенную запись по recid
   */

  case p-direction :
    when "first":U then do:
      get first br-parts.
    end.
    when "last":U then do:
      get last br-parts.
    end.
    when "prev":U then do:
      get prev br-parts.
    end.
    when "next":U then do:
      get next br-parts.
    end.
    otherwise do:
      reposition br-parts to recid integer(p-direction) no-error .
    end.
  end case . /* p-direction */

  assign
    p-parts-recid = recid(ub.parts)
  .
  run reposition-query in this-procedure
    (input p-parts-recid
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input parameter p-recid as recid no-undo .

  if p-recid <> ? then do:
    reposition br-parts to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
  end. /* do with frame */

  run display-parts-info .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        rect-flt :BGCOLOR = RED_COLOR
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        rect-flt :BGCOLOR = GREY_COLOR
        b-sch :TOOLTIP = ""
      .
    end.

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on Dialog-Frame
PROCEDURE UI-on :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

def var l-query-was-opened as logical no-undo .

assign
  l-query-was-opened = false
.

def var sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  when "parts-out-code" then do:
    assign
      sort-column-phrase = "by parts.out-code"
    .
  end.
  when "parts-prod" then do:
    assign
      sort-column-phrase = "by parts.prod-type by parts.prod-code"
    .
  end.
  when "parts-supp" then do:
    assign
      sort-column-phrase = "by parts.supp-type by parts.supp-code"
    .
  end.
  when "parts-part-code" then do:
    assign
      sort-column-phrase = "by parts.part-code"
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.


&scop flt-open-open-query open query br-parts for each ub.parts no-lock

&scop flt-open-dyn_open-query  FOR EACH ub.parts

&scop flt-open-query-handle query br-parts:handle

&scop flt-open-find-buffer-name ub.parts

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-debug-file

assign
  frame {&frame-name}:title = "Порожденные партии по документу " + string(p-doc-code)
.
{ gbl/fltopend.i
  &where-cond = "ub.parts.out-code  = ub.trn-doc.doc-code ~
              and ub.parts.obj-type = ub.trn-doc.obj-type ~
              and ub.parts.obj-code = ub.trn-doc.obj-code ~
              and ub.parts.in-code  = ub.trn-doc.doc-code "
  &dyn_where-cond = " substitute('  ~
                  ub.parts.out-code = &1&2&1  ~
              and ub.parts.obj-type = &1&3&1  ~
              and ub.parts.obj-code = &4     ~
              and ub.parts.in-code  = &1&5&1 ~
                  '  , ~{&double-quote~} ~
                  ,ub.trn-doc.doc-code    ~
                  ,ub.trn-doc.obj-type    ~
                  ,ub.trn-doc.obj-code    ~
                  ,ub.trn-doc.doc-code ) "
  &use-ind = " use-index out-code "
  &by = "by ub.parts.artic by ub.parts.prod-type by ub.parts.prod-code"
}


run reposition-query in this-procedure
  (input p-part-recid
  ).
if v-fltopend-rowid[1] <> ? then
query br-parts:handle:reposition-to-rowid(v-fltopend-rowid) no-error.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-goods-bar-code Dialog-Frame
FUNCTION get-goods-bar-code RETURNS INTEGER
  ( p-artic as character, p-prod-type as character, p-prod-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  Возвращает номер бар-кода для товара
------------------------------------------------------------------------------*/
   def var v-b-code as integer no-undo .

   define buffer buf_goods-cache for goods-cache .
   run get-goods-cache
     (input  p-artic
     ,input  p-prod-type
     ,input  p-prod-code
     ,buffer buf_goods-cache
     ).
   assign
     v-b-code = buf_goods-cache.b-code
   .

   return v-b-code .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-goods-gds-name Dialog-Frame
FUNCTION get-goods-gds-name RETURNS CHARACTER
  ( p-artic as character, p-prod-type as character, p-prod-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  Возвращает имя товара
------------------------------------------------------------------------------*/

   def var v-gds-name as character no-undo .

   define buffer buf_goods-cache for goods-cache .
   run get-goods-cache
     (input  p-artic
     ,input  p-prod-type
     ,input  p-prod-code
     ,buffer buf_goods-cache
     ).
   assign
     v-gds-name = buf_goods-cache.gds-name
   .

   return v-gds-name .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME