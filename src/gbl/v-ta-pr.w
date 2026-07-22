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

Корректировка списка методов переоценки

Автор: Комаров Иван Сергеевич
Дата создания: 10/19/10
Author: Ivan Komarov
Creation date: 10/19/10

Автор1: Чернова Светлана Александровна
Дата создания1: 07/02/08

*/

define input         parameter p-mode as character no-undo .
define input-output  parameter p-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка списка методов переоценки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }

/*------------------------------------------------------------------------

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-ok B-cancel B-Help I-pr-calc-goods ~
I-pr-calc-grp I-pr-calc-cost I-pr-calc-costobj I-pr-calc-rsrv ~
I-pr-calc-last I-pr-calc-lastobj I-pr-calc-old I-pr-calc-new I-pr-calc-obj ~
I-pr-calc-wbill I-pr-calc-wbill-novat I-pr-calc-cost-novat ~
I-pr-calc-old-novat I-pr-calc-ov I-pr-calc-pdf I-pr-calc-cost-wbill ~
I-pr-calc-cost-wbill-novat I-pr-calc-slt I-pr-calc-slt-wbill ~
I-pr-calc-cost-gr I-pr-calc-rsrv-gr I-pr-calc-last-gr I-pr-calc-novat-gr ~
I-pr-common I-pr-calc-no I-pr-calc-fix I-pr-calc-prod I-pr-calc-prod-vat ~
I-pr-calc-level-prod I-pr-calc-level-prod-VAT I-pr-calc-specif ~
pr-calc-goods pr-calc-slt pr-calc-grp pr-calc-slt-wbill pr-calc-cost ~
pr-calc-cost-gr pr-calc-costobj pr-calc-rsrv-gr pr-calc-rsrv ~
pr-calc-last-gr pr-calc-last pr-calc-cost-novat-gr pr-calc-lastobj ~
pr-common pr-calc-old pr-calc-prod pr-calc-new pr-calc-prod-vat pr-calc-obj ~
pr-calc-no pr-calc-wbill pr-calc-fix pr-calc-wbill-novat pr-calc-level-prod ~
pr-calc-cost-novat pr-calc-level-prod-VAT pr-calc-old-novat pr-calc-specif ~
pr-calc-ov pr-calc-pdf pr-calc-cost-wbill pr-calc-cost-wbill-novat
&Scoped-Define DISPLAYED-OBJECTS pr-calc-goods pr-calc-slt pr-calc-grp ~
pr-calc-slt-wbill pr-calc-cost pr-calc-cost-gr pr-calc-costobj ~
pr-calc-rsrv-gr pr-calc-rsrv pr-calc-last-gr pr-calc-last ~
pr-calc-cost-novat-gr pr-calc-lastobj pr-common pr-calc-old pr-calc-prod ~
pr-calc-new pr-calc-prod-vat pr-calc-obj pr-calc-no pr-calc-wbill ~
pr-calc-fix pr-calc-wbill-novat pr-calc-level-prod pr-calc-cost-novat ~
pr-calc-level-prod-VAT pr-calc-old-novat pr-calc-specif pr-calc-ov ~
pr-calc-pdf pr-calc-cost-wbill pr-calc-cost-wbill-novat

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cancel AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-ok AUTO-GO
     LABEL "В&вод"
     SIZE 10 BY 1.

DEFINE IMAGE I-pr-calc-cost
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-cost-gr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-cost-novat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-cost-wbill
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-cost-wbill-novat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-costobj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-fix
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-goods
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-grp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-last
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-last-gr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-lastobj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-level-prod
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-level-prod-VAT
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-new
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-no
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-novat-gr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-obj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-old
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-old-novat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-ov
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-pdf
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-prod
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-prod-vat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-rsrv
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-rsrv-gr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-slt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-slt-wbill
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-specif
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-wbill
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-calc-wbill-novat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pr-common
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE VARIABLE pr-calc-cost AS LOGICAL INITIAL no
     LABEL "Учетная"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-cost-gr AS LOGICAL INITIAL no
     LABEL "УчетнаяS"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-cost-novat AS LOGICAL INITIAL no
     LABEL "Учет-безНДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-cost-novat-gr AS LOGICAL INITIAL no
     LABEL "Учет-НДСS"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-cost-wbill AS LOGICAL INITIAL no
     LABEL "Учет+накл"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-cost-wbill-novat AS LOGICAL INITIAL no
     LABEL "Уч+накл-НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-costobj AS LOGICAL INITIAL no
     LABEL "Учет-объект"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-fix AS LOGICAL INITIAL no
     LABEL "Не-считать"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-goods AS LOGICAL INITIAL no
     LABEL "Товар"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-grp AS LOGICAL INITIAL no
     LABEL "Группа"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-last AS LOGICAL INITIAL no
     LABEL "Приходная"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-last-gr AS LOGICAL INITIAL no
     LABEL "ПриходнаяS"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-lastobj AS LOGICAL INITIAL no
     LABEL "Прих-объект"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-level-prod AS LOGICAL INITIAL no
     LABEL "ПорогПр-НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-level-prod-VAT AS LOGICAL INITIAL no
     LABEL "ПорогПр+НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-new AS LOGICAL INITIAL no
     LABEL "Новая"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-no AS LOGICAL INITIAL no
     LABEL "Отсутствует"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-obj AS LOGICAL INITIAL no
     LABEL "Объект"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-old AS LOGICAL INITIAL no
     LABEL "Старая"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-old-novat AS LOGICAL INITIAL no
     LABEL "Стар-безНДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-ov AS LOGICAL INITIAL no
     LABEL "Переоценка"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-pdf AS LOGICAL INITIAL no
     LABEL "ДокФормЦены"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-prod AS LOGICAL INITIAL no
     LABEL "Производитель"
     VIEW-AS TOGGLE-BOX
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-prod-vat AS LOGICAL INITIAL no
     LABEL "Произв-НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-rsrv AS LOGICAL INITIAL no
     LABEL "Учет-резерв"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-rsrv-gr AS LOGICAL INITIAL no
     LABEL "Учет-рзрвS"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-slt AS LOGICAL INITIAL no
     LABEL "НсП"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-slt-wbill AS LOGICAL INITIAL no
     LABEL "НсП+накл"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-specif AS LOGICAL INITIAL no
     LABEL "Спецификация"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-wbill AS LOGICAL INITIAL no
     LABEL "Накладная"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-calc-wbill-novat AS LOGICAL INITIAL no
     LABEL "Накл-безНДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pr-common AS LOGICAL INITIAL no
     LABEL "Единая"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-ok AT ROW 1 COL 1 WIDGET-ID 4
     B-cancel AT ROW 1 COL 11 WIDGET-ID 6
     B-Help AT ROW 1 COL 50
     pr-calc-goods AT ROW 2 COL 5 WIDGET-ID 12
     pr-calc-slt AT ROW 2 COL 31 WIDGET-ID 48
     pr-calc-grp AT ROW 3 COL 5 WIDGET-ID 14
     pr-calc-slt-wbill AT ROW 3 COL 31 WIDGET-ID 50
     pr-calc-cost AT ROW 4 COL 5 WIDGET-ID 16
     pr-calc-cost-gr AT ROW 4 COL 31 WIDGET-ID 52
     pr-calc-costobj AT ROW 5 COL 5 WIDGET-ID 18
     pr-calc-rsrv-gr AT ROW 5 COL 31 WIDGET-ID 54
     pr-calc-rsrv AT ROW 6 COL 5 WIDGET-ID 20
     pr-calc-last-gr AT ROW 6 COL 31 WIDGET-ID 56
     pr-calc-last AT ROW 7 COL 5 WIDGET-ID 22
     pr-calc-cost-novat-gr AT ROW 7 COL 31 WIDGET-ID 58
     pr-calc-lastobj AT ROW 8 COL 5 WIDGET-ID 24
     pr-common AT ROW 8 COL 31 WIDGET-ID 60
     pr-calc-old AT ROW 9 COL 5 WIDGET-ID 26
     pr-calc-prod AT ROW 9 COL 31 WIDGET-ID 120
     pr-calc-new AT ROW 10 COL 5 WIDGET-ID 28
     pr-calc-prod-vat AT ROW 10 COL 31 WIDGET-ID 126
     pr-calc-obj AT ROW 11 COL 5 WIDGET-ID 30
     pr-calc-no AT ROW 11 COL 31 WIDGET-ID 62
     pr-calc-wbill AT ROW 12 COL 5 WIDGET-ID 32
     pr-calc-fix AT ROW 12 COL 31 WIDGET-ID 64
     pr-calc-wbill-novat AT ROW 13 COL 5 WIDGET-ID 34
     pr-calc-level-prod AT ROW 13 COL 31 WIDGET-ID 130
     pr-calc-cost-novat AT ROW 14 COL 5 WIDGET-ID 36
     pr-calc-level-prod-VAT AT ROW 14 COL 31 WIDGET-ID 134
     pr-calc-old-novat AT ROW 15 COL 5 WIDGET-ID 38
     pr-calc-specif AT ROW 15 COL 31 WIDGET-ID 138
     pr-calc-ov AT ROW 16 COL 5 WIDGET-ID 40
     pr-calc-pdf AT ROW 17 COL 5 WIDGET-ID 42
     pr-calc-cost-wbill AT ROW 18 COL 5 WIDGET-ID 44
     pr-calc-cost-wbill-novat AT ROW 19 COL 5 WIDGET-ID 46
     I-pr-calc-goods AT ROW 2 COL 1.13 WIDGET-ID 66
     I-pr-calc-grp AT ROW 3 COL 1.13 WIDGET-ID 68
     I-pr-calc-cost AT ROW 4 COL 1.13 WIDGET-ID 70
     I-pr-calc-costobj AT ROW 5 COL 1.13 WIDGET-ID 72
     I-pr-calc-rsrv AT ROW 6 COL 1.13 WIDGET-ID 74
     I-pr-calc-last AT ROW 7 COL 1.13 WIDGET-ID 76
     I-pr-calc-lastobj AT ROW 8 COL 1.13 WIDGET-ID 78
     I-pr-calc-old AT ROW 9 COL 1.13 WIDGET-ID 80
     I-pr-calc-new AT ROW 10 COL 1.13 WIDGET-ID 82
     I-pr-calc-obj AT ROW 11 COL 1.13 WIDGET-ID 84
     I-pr-calc-wbill AT ROW 12 COL 1.13 WIDGET-ID 86
     I-pr-calc-wbill-novat AT ROW 13 COL 1.13 WIDGET-ID 88
     I-pr-calc-cost-novat AT ROW 14 COL 1.13 WIDGET-ID 90
     I-pr-calc-old-novat AT ROW 15 COL 1.13 WIDGET-ID 92
     I-pr-calc-ov AT ROW 16 COL 1.13 WIDGET-ID 94
     I-pr-calc-pdf AT ROW 17 COL 1.13 WIDGET-ID 96
     I-pr-calc-cost-wbill AT ROW 18 COL 1.13 WIDGET-ID 98
     I-pr-calc-cost-wbill-novat AT ROW 19 COL 1.13 WIDGET-ID 100
     I-pr-calc-slt AT ROW 2 COL 27.5 WIDGET-ID 102
     I-pr-calc-slt-wbill AT ROW 3 COL 27.5 WIDGET-ID 104
     I-pr-calc-cost-gr AT ROW 4 COL 27.5 WIDGET-ID 106
     I-pr-calc-rsrv-gr AT ROW 5 COL 27.5 WIDGET-ID 108
     I-pr-calc-last-gr AT ROW 6 COL 27.5 WIDGET-ID 110
     I-pr-calc-novat-gr AT ROW 7 COL 27.5 WIDGET-ID 112
     I-pr-common AT ROW 8 COL 27.5 WIDGET-ID 114
     I-pr-calc-no AT ROW 11 COL 27.5 WIDGET-ID 116
     I-pr-calc-fix AT ROW 12 COL 27.5 WIDGET-ID 118
     I-pr-calc-prod AT ROW 9 COL 27.5 WIDGET-ID 122
     I-pr-calc-prod-vat AT ROW 10 COL 27.5 WIDGET-ID 124
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON B-cancel WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     I-pr-calc-level-prod AT ROW 13 COL 27.5 WIDGET-ID 128
     I-pr-calc-level-prod-VAT AT ROW 14 COL 27.5 WIDGET-ID 132
     I-pr-calc-specif AT ROW 15 COL 27.5 WIDGET-ID 136
     SPACE(23.49) SKIP(4.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Методы расчета цены используемые в системе"
         CANCEL-BUTTON B-cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Методы расчета цены используемые в системе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Help */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ok Dialog-Frame
ON CHOOSE OF B-ok IN FRAME Dialog-Frame /* Ввод */
DO:
IF p-mode = {&LOOKUP} THEN RETURN .
  ASSIGN
      pr-calc-cost
      pr-calc-cost-gr
      pr-calc-cost-novat
      pr-calc-cost-novat-gr
      pr-calc-costobj
      pr-calc-cost-wbill
      pr-calc-cost-wbill-novat
      pr-calc-fix
      pr-calc-goods
      pr-calc-grp
      pr-calc-last
      pr-calc-last-gr
      pr-calc-lastobj
      pr-calc-new
      pr-calc-no
      pr-calc-obj
      pr-calc-old
      pr-calc-old-novat
      pr-calc-ov
      pr-calc-pdf
      pr-calc-rsrv
      pr-calc-rsrv-gr
      pr-calc-slt
      pr-calc-slt-wbill
      pr-calc-wbill
      pr-calc-wbill-novat
      pr-common
      pr-calc-prod
      pr-calc-prod-vat
      pr-calc-level-prod
      pr-calc-level-prod-vat
      pr-calc-specif
      .
p-list = "".
if pr-calc-cost               = true  then p-list = p-list + {&pr-calc-cost}             + ","  .
if pr-calc-cost-gr            = true  then p-list = p-list + {&pr-calc-cost-gr}          + ","  .
if pr-calc-cost-novat         = true  then p-list = p-list + {&pr-calc-cost-novat}       + ","  .
if pr-calc-cost-novat-gr      = true  then p-list = p-list + {&pr-calc-cost-novat-gr}    + ","  .
if pr-calc-costobj            = true  then p-list = p-list + {&pr-calc-costobj}          + ","  .
if pr-calc-cost-wbill         = true  then p-list = p-list + {&pr-calc-cost-wbill}       + ","  .
if pr-calc-cost-wbill-novat   = true  then p-list = p-list + {&pr-calc-cost-wbill-novat} + ","  .
if pr-calc-fix                = true  then p-list = p-list + {&pr-calc-fix}              + ","  .
if pr-calc-goods              = true  then p-list = p-list + {&pr-calc-goods}            + ","  .
if pr-calc-grp                = true  then p-list = p-list + {&pr-calc-grp}              + ","  .
if pr-calc-last               = true  then p-list = p-list + {&pr-calc-last}             + ","  .
if pr-calc-last-gr            = true  then p-list = p-list + {&pr-calc-last-gr}          + ","  .
if pr-calc-lastobj            = true  then p-list = p-list + {&pr-calc-lastobj}          + ","  .
if pr-calc-new                = true  then p-list = p-list + {&pr-calc-new}              + ","  .
if pr-calc-no                 = true  then p-list = p-list + {&pr-calc-no}               + ","  .
if pr-calc-obj                = true  then p-list = p-list + {&pr-calc-obj}              + ","  .
if pr-calc-old                = true  then p-list = p-list + {&pr-calc-old}              + ","  .
if pr-calc-old-novat          = true  then p-list = p-list + {&pr-calc-old-novat}        + ","  .
if pr-calc-ov                 = true  then p-list = p-list + {&pr-calc-ov}               + ","  .
if pr-calc-pdf                = true  then p-list = p-list + {&pr-calc-pdf}              + ","  .
if pr-calc-rsrv               = true  then p-list = p-list + {&pr-calc-rsrv}             + ","  .
if pr-calc-rsrv-gr            = true  then p-list = p-list + {&pr-calc-rsrv-gr}          + ","  .
if pr-calc-slt                = true  then p-list = p-list + {&pr-calc-slt}              + ","  .
if pr-calc-slt-wbill          = true  then p-list = p-list + {&pr-calc-slt-wbill}        + ","  .
if pr-calc-wbill              = true  then p-list = p-list + {&pr-calc-wbill}            + ","  .
if pr-calc-wbill-novat        = true  then p-list = p-list + {&pr-calc-wbill-novat}      + ","  .
if pr-common                  = true  then p-list = p-list + {&pr-common}                + ","  .
if pr-calc-prod               = true  then p-list = p-list + {&pr-calc-prod}             + ","  .
if pr-calc-prod-vat           = true  then p-list = p-list + {&pr-calc-prod-vat}         + ","  .
if pr-calc-level-prod         = true  then p-list = p-list + {&pr-calc-level-prod}       + ","  .
if pr-calc-level-prod-vat     = true  then p-list = p-list + {&pr-calc-level-prod-vat}   + ","  .
if pr-calc-specif             = true  then p-list = p-list + {&pr-calc-specif}           + ","  .


p-list = trim (p-list ,",") .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-cost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-cost Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-cost-gr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-cost-gr Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost-gr IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-cost-novat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-cost-novat Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost-novat IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-cost-wbill
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-cost-wbill Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost-wbill IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-cost-wbill-novat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-cost-wbill-novat Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost-wbill-novat IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-costobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-costobj Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-costobj IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-fix
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-fix Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-fix IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-goods Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-goods IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-grp Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-grp IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-last
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-last Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-last IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-last-gr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-last-gr Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-last-gr IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-lastobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-lastobj Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-lastobj IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-level-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-level-prod Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-level-prod IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-level-prod-VAT
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-level-prod-VAT Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-level-prod-VAT IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-new
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-new Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-new IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-no
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-no Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-no IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-novat-gr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-novat-gr Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-novat-gr IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-obj Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-obj IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-old
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-old Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-old IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-old-novat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-old-novat Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-old-novat IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-ov
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-ov Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-ov IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-pdf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-pdf Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-pdf IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-prod Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-prod IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-prod-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-prod-vat Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-prod-vat IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-rsrv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-rsrv Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-rsrv IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-rsrv-gr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-rsrv-gr Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-rsrv-gr IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-slt Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-slt IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-slt-wbill
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-slt-wbill Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-slt-wbill IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-specif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-specif Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-specif IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-wbill
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-wbill Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-wbill IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-calc-wbill-novat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-calc-wbill-novat Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-calc-wbill-novat IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pr-common
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pr-common Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pr-common IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
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

  run init-tt in this-procedure .
  run enable_ui in this-procedure .
  if p-mode <> {&update} then do:
     disable
     pr-calc-cost
     pr-calc-cost-gr
     pr-calc-cost-novat
     pr-calc-cost-novat-gr
     pr-calc-costobj
     pr-calc-cost-wbill
     pr-calc-cost-wbill-novat
     pr-calc-fix
     pr-calc-goods
     pr-calc-grp
     pr-calc-last
     pr-calc-last-gr
     pr-calc-lastobj
     pr-calc-new
     pr-calc-no
     pr-calc-obj
     pr-calc-old
     pr-calc-old-novat
     pr-calc-ov
     pr-calc-pdf
     pr-calc-rsrv
     pr-calc-rsrv-gr
     pr-calc-slt
     pr-calc-slt-wbill
     pr-calc-wbill
     pr-calc-wbill-novat
     pr-common
     pr-calc-prod
     pr-calc-prod-vat
     pr-calc-level-prod
     pr-calc-level-prod-vat
     pr-calc-specif
     with frame {&frame-name}.
     B-ok:label = "Вы&ход"  .
     hide B-cancel in frame {&frame-name} .
  end.
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
  DISPLAY pr-calc-goods pr-calc-slt pr-calc-grp pr-calc-slt-wbill pr-calc-cost
          pr-calc-cost-gr pr-calc-costobj pr-calc-rsrv-gr pr-calc-rsrv
          pr-calc-last-gr pr-calc-last pr-calc-cost-novat-gr pr-calc-lastobj
          pr-common pr-calc-old pr-calc-prod pr-calc-new pr-calc-prod-vat
          pr-calc-obj pr-calc-no pr-calc-wbill pr-calc-fix pr-calc-wbill-novat
          pr-calc-level-prod pr-calc-cost-novat pr-calc-level-prod-VAT
          pr-calc-old-novat pr-calc-specif pr-calc-ov pr-calc-pdf
          pr-calc-cost-wbill pr-calc-cost-wbill-novat
      WITH FRAME Dialog-Frame.
  ENABLE B-ok B-cancel B-Help I-pr-calc-goods I-pr-calc-grp I-pr-calc-cost
         I-pr-calc-costobj I-pr-calc-rsrv I-pr-calc-last I-pr-calc-lastobj
         I-pr-calc-old I-pr-calc-new I-pr-calc-obj I-pr-calc-wbill
         I-pr-calc-wbill-novat I-pr-calc-cost-novat I-pr-calc-old-novat
         I-pr-calc-ov I-pr-calc-pdf I-pr-calc-cost-wbill
         I-pr-calc-cost-wbill-novat I-pr-calc-slt I-pr-calc-slt-wbill
         I-pr-calc-cost-gr I-pr-calc-rsrv-gr I-pr-calc-last-gr
         I-pr-calc-novat-gr I-pr-common I-pr-calc-no I-pr-calc-fix
         I-pr-calc-prod I-pr-calc-prod-vat I-pr-calc-level-prod
         I-pr-calc-level-prod-VAT I-pr-calc-specif pr-calc-goods pr-calc-slt
         pr-calc-grp pr-calc-slt-wbill pr-calc-cost pr-calc-cost-gr
         pr-calc-costobj pr-calc-rsrv-gr pr-calc-rsrv pr-calc-last-gr
         pr-calc-last pr-calc-cost-novat-gr pr-calc-lastobj pr-common
         pr-calc-old pr-calc-prod pr-calc-new pr-calc-prod-vat pr-calc-obj
         pr-calc-no pr-calc-wbill pr-calc-fix pr-calc-wbill-novat
         pr-calc-level-prod pr-calc-cost-novat pr-calc-level-prod-VAT
         pr-calc-old-novat pr-calc-specif pr-calc-ov pr-calc-pdf
         pr-calc-cost-wbill pr-calc-cost-wbill-novat
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame
PROCEDURE init-tt :
if lookup ({&pr-calc-cost},p-list ) > 0 then             pr-calc-cost               = true .
if lookup ({&pr-calc-cost-gr},p-list ) > 0 then          pr-calc-cost-gr            = true .
if lookup ({&pr-calc-cost-novat},p-list ) > 0 then       pr-calc-cost-novat         = true .
if lookup ({&pr-calc-cost-novat-gr},p-list ) > 0 then    pr-calc-cost-novat-gr      = true .
if lookup ({&pr-calc-costobj},p-list ) > 0 then          pr-calc-costobj            = true .
if lookup ({&pr-calc-cost-wbill},p-list ) > 0 then       pr-calc-cost-wbill         = true .
if lookup ({&pr-calc-cost-wbill-novat},p-list ) > 0 then pr-calc-cost-wbill-novat   = true .
if lookup ({&pr-calc-fix},p-list ) > 0 then              pr-calc-fix                = true .
if lookup ({&pr-calc-goods},p-list ) > 0 then            pr-calc-goods              = true .
if lookup ({&pr-calc-grp},p-list ) > 0 then              pr-calc-grp                = true .
if lookup ({&pr-calc-last},p-list ) > 0 then             pr-calc-last               = true .
if lookup ({&pr-calc-last-gr},p-list ) > 0 then          pr-calc-last-gr            = true .
if lookup ({&pr-calc-lastobj},p-list ) > 0 then          pr-calc-lastobj            = true .
if lookup ({&pr-calc-new},p-list ) > 0 then              pr-calc-new                = true .
if lookup ({&pr-calc-no},p-list ) > 0 then               pr-calc-no                 = true .
if lookup ({&pr-calc-obj},p-list ) > 0 then              pr-calc-obj                = true .
if lookup ({&pr-calc-old},p-list ) > 0 then              pr-calc-old                = true .
if lookup ({&pr-calc-old-novat},p-list ) > 0 then        pr-calc-old-novat          = true .
if lookup ({&pr-calc-ov},p-list ) > 0 then               pr-calc-ov                 = true .
if lookup ({&pr-calc-pdf},p-list ) > 0 then              pr-calc-pdf                = true .
if lookup ({&pr-calc-rsrv},p-list ) > 0 then             pr-calc-rsrv               = true .
if lookup ({&pr-calc-rsrv-gr},p-list ) > 0 then          pr-calc-rsrv-gr            = true .
if lookup ({&pr-calc-slt},p-list ) > 0 then              pr-calc-slt                = true .
if lookup ({&pr-calc-slt-wbill},p-list ) > 0 then        pr-calc-slt-wbill          = true .
if lookup ({&pr-calc-wbill},p-list ) > 0 then            pr-calc-wbill              = true .
if lookup ({&pr-calc-wbill-novat},p-list ) > 0 then      pr-calc-wbill-novat        = true .
if lookup ({&pr-common},p-list ) > 0 then                pr-common                  = true .
if lookup ({&pr-calc-prod},p-list ) > 0 then             pr-calc-prod               = true .
if lookup ({&pr-calc-prod-vat},p-list ) > 0 THEN         pr-calc-prod-vat           = true .
if lookup ({&pr-calc-level-prod},p-list ) > 0 THEN       pr-calc-level-prod         = true .
if lookup ({&pr-calc-level-prod-vat},p-list ) > 0 THEN   pr-calc-level-prod-vat     = true .
if lookup ({&pr-calc-specif},p-list ) > 0 THEN           pr-calc-specif             = true .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
