&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка внешний артикул

Автор: Хныкин Павел Андреевич
Дата создания: 05/02/07
Author: Pavel Khnykin
Creation date: 05/02/07

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input            parameter parParentProc   as handle               no-undo .
define input            parameter p-mode          as character            no-undo .
define input            parameter p-gds-code      like ub.goods.gds-code  no-undo .
define input-output     parameter p-recid         as recid                no-undo .

/* для автовыбора контрагента с последующей блокировкой выбора или 0 */
define input            parameter p-sel-contractor-recid as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка внешний артикул".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.goods ub.clients buf_goods

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame buf_goods.artic ~
buf_goods.gds-name ub.clients.obj-type ub.clients.obj-code ~
ub.clients.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame buf_goods.artic ~
buf_goods.gds-name ub.clients.obj-type ub.clients.obj-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame buf_goods ub.clients
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame buf_goods
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.clients
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.goods SHARE-LOCK, ~
      EACH ub.clients WHERE TRUE /* Join to ub.goods incomplete */ SHARE-LOCK, ~
      EACH buf_goods WHERE TRUE /* Join to ub.goods incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.goods SHARE-LOCK, ~
      EACH ub.clients WHERE TRUE /* Join to ub.goods incomplete */ SHARE-LOCK, ~
      EACH buf_goods WHERE TRUE /* Join to ub.goods incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.goods ub.clients buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.goods
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame ub.clients
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame buf_goods


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS buf_goods.artic buf_goods.gds-name ~
ub.clients.obj-type ub.clients.obj-code
&Scoped-define ENABLED-TABLES buf_goods ub.clients
&Scoped-define FIRST-ENABLED-TABLE buf_goods
&Scoped-define SECOND-ENABLED-TABLE ub.clients
&Scoped-Define ENABLED-OBJECTS b-exit b-rest b-help RECT-1 RECT-2 RECT-3 ~
fi-ext-artic fi-unit-cli b-units fi-cli-base-rate fi-unit-cli-ord ~
b-units-ord fi-cli-base-rate-ord fi-unit-cli-rcv b-units-rcv ~
fi-cli-base-rate-rcv ed-ps r-prod
&Scoped-Define DISPLAYED-FIELDS buf_goods.artic buf_goods.gds-name ~
ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name
&Scoped-define DISPLAYED-TABLES buf_goods ub.clients
&Scoped-define FIRST-DISPLAYED-TABLE buf_goods
&Scoped-define SECOND-DISPLAYED-TABLE ub.clients
&Scoped-Define DISPLAYED-OBJECTS fi-ext-artic fi-unit-cli fi-cli-base-rate ~
fi-unit-cli-ord fi-cli-base-rate-ord fi-unit-cli-rcv fi-cli-base-rate-rcv ~
ed-ps

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON b-rest AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-units
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY .88.

DEFINE BUTTON b-units-ord
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY .88.

DEFINE BUTTON b-units-rcv
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY .88.

DEFINE BUTTON r-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-prod"
     SIZE 3 BY .88.

DEFINE VARIABLE ed-ps AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 80.5 BY 5 NO-UNDO.

DEFINE VARIABLE fi-cli-base-rate LIKE ub.ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE fi-cli-base-rate-ord LIKE ub.ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE fi-cli-base-rate-rcv LIKE ub.ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE fi-ext-artic LIKE ub.ext-artic.ext-artic
     LABEL "Вн. артикул"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE fi-unit-cli AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE fi-unit-cli-ord AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE fi-unit-cli-rcv AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 80.5 BY 1.83.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 80.5 BY 1.83.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 80.5 BY 1.83.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.goods,
      ub.clients,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 4
     b-rest AT ROW 1 COL 11 WIDGET-ID 8
     b-help AT ROW 1 COL 21 WIDGET-ID 6
     buf_goods.artic AT ROW 3.04 COL 9.25 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     buf_goods.gds-name AT ROW 4 COL 17 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN
          SIZE 64 BY 1
          FGCOLOR 4
     ub.clients.obj-type AT ROW 5 COL 12 COLON-ALIGNED WIDGET-ID 16
          LABEL "Контрагент"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-code AT ROW 5 COL 15.75 COLON-ALIGNED NO-LABEL WIDGET-ID 12
          VIEW-AS FILL-IN
          SIZE 13 BY 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-name AT ROW 5 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 14
          VIEW-AS FILL-IN
          SIZE 49 BY 1
          BGCOLOR 3 FGCOLOR 15
     fi-ext-artic AT ROW 6 COL 12 COLON-ALIGNED HELP
          "" WIDGET-ID 26
          LABEL "Вн. артикул"
     fi-unit-cli AT ROW 7.75 COL 46.75 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     b-units AT ROW 7.75 COL 56.25 WIDGET-ID 30
     fi-cli-base-rate AT ROW 7.75 COL 70.75 COLON-ALIGNED HELP
          "" WIDGET-ID 34
     fi-unit-cli-ord AT ROW 9.75 COL 46.75 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     b-units-ord AT ROW 9.75 COL 56.25 WIDGET-ID 40
     fi-cli-base-rate-ord AT ROW 9.75 COL 70.75 COLON-ALIGNED HELP
          "" WIDGET-ID 42
     fi-unit-cli-rcv AT ROW 11.75 COL 46.75 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     b-units-rcv AT ROW 11.75 COL 56.25 WIDGET-ID 50
     fi-cli-base-rate-rcv AT ROW 11.75 COL 70.75 COLON-ALIGNED HELP
          "" WIDGET-ID 52
     ed-ps AT ROW 14.38 COL 1.5 NO-LABEL WIDGET-ID 28
     r-prod AT ROW 5 COL 32 WIDGET-ID 18
     "Единица  измерения поставщика в  поставке:" VIEW-AS TEXT
          SIZE 42.5 BY .67 AT ROW 12 COL 3 WIDGET-ID 58
     "Единица  измерения поставщика в накладной:" VIEW-AS TEXT
          SIZE 43.75 BY .67 AT ROW 8 COL 3 WIDGET-ID 36
     "Примечание" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 13.5 COL 2 WIDGET-ID 20
     "Единица  измерения поставщика в заказе:" VIEW-AS TEXT
          SIZE 42 BY .67 AT ROW 10 COL 3 WIDGET-ID 48
     RECT-1 AT ROW 7.5 COL 1.5 WIDGET-ID 38
     RECT-2 AT ROW 9.5 COL 1.5 WIDGET-ID 46
     RECT-3 AT ROW 11.5 COL 1.5 WIDGET-ID 56
     SPACE(0.87) SKIP(6.05)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Внешний артикул" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub ub.goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME Custom                                                    */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-cli-base-rate IN FRAME Dialog-Frame
   LIKE = ub.ext-artic.cli-base-rate EXP-SIZE                           */
/* SETTINGS FOR FILL-IN fi-cli-base-rate-ord IN FRAME Dialog-Frame
   LIKE = ub.ext-artic.cli-base-rate EXP-SIZE                           */
/* SETTINGS FOR FILL-IN fi-cli-base-rate-rcv IN FRAME Dialog-Frame
   LIKE = ub.ext-artic.cli-base-rate EXP-SIZE                           */
/* SETTINGS FOR FILL-IN fi-ext-artic IN FRAME Dialog-Frame
   LIKE = ub.ext-artic.ext-artic EXP-LABEL EXP-SIZE                     */
/* SETTINGS FOR FILL-IN ub.clients.obj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.clients.obj-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.goods,ub.clients WHERE ub.goods ...,Temp-Tables.buf_goods WHERE ub.goods ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Внешний артикул */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  define buffer buf_goods     for ub.goods.
  define buffer cur_ext-artic for ub.ext-artic.

  define variable v-log       as logical                no-undo .
  define variable v-cli-code           like ub.clients.obj-code          no-undo .
  define variable v-cli-type           like ub.clients.obj-type          no-undo .
  define variable v-ext-artic          like ub.ext-artic.ext-artic          no-undo .
  define variable v-ps                 like ub.ext-artic.ps                 no-undo .
  define variable v-unit-cli           like ub.ext-artic.unit-cli           no-undo .
  define variable v-cli-base-rate      like ub.ext-artic.cli-base-rate      no-undo .
  define variable v-unit-cli-ord       like ub.ext-artic.unit-cli-ord       no-undo .
  define variable v-cli-base-rate-ord  like ub.ext-artic.cli-base-rate-ord  no-undo .
  define variable v-unit-cli-rcv       like ub.ext-artic.unit-cli-rcv       no-undo .
  define variable v-cli-base-rate-rcv  like ub.ext-artic.cli-base-rate-rcv  no-undo .

  if p-mode = {&lookup} then return.

  run chk-client in this-procedure (output v-log).
  if not v-log then do :
    message
      "Неверный контрагент!"
    view-as alert-box error.
    apply "choose":U to r-prod.
    return no-apply.
  end.
  if fi-ext-artic :screen-value = "" then do:
    message
      "Введите внешний артикул!"
    view-as alert-box error.
    apply "entry":u to fi-ext-artic.
    return no-apply.
  end.
  assign
    v-cli-code  = input frame {&frame-name} ub.clients.obj-code
    v-cli-type  = input frame {&frame-name} ub.clients.obj-type
    v-ext-artic = fi-ext-artic :screen-value
    v-ps        = ed-ps :screen-value
    v-unit-cli          = fi-unit-cli :screen-value
    v-cli-base-rate     = input frame {&frame-name} fi-cli-base-rate
    v-unit-cli-ord      = fi-unit-cli-ord :screen-value
    v-cli-base-rate-ord = input frame {&frame-name} fi-cli-base-rate-ord
    v-unit-cli-rcv      = fi-unit-cli-rcv :screen-value
    v-cli-base-rate-rcv = input frame {&frame-name} fi-cli-base-rate-rcv
  .

  run check-exist-artic in this-procedure ( input  v-cli-type
                                          , input  v-cli-code
                                          , input  v-ext-artic
                                          , input  p-recid
                                          , output v-log
                                          ) .
  if v-log then return no-apply.
  run ref/extarts.p ( input p-mode
                   , input v-cli-type
                   , input v-cli-code
                   , input p-gds-code
                   , input v-ext-artic
                   , input v-ps
                   , input v-unit-cli
                   , input v-cli-base-rate
                   , input v-unit-cli-ord
                   , input v-cli-base-rate-ord
                   , input v-unit-cli-rcv
                   , input v-cli-base-rate-rcv
                   ) no-error .
  if error-status :error then do :
    message
      return-value skip
      error-status :get-message(1)
    view-as alert-box error.
    return no-apply.
  end.
  find first cur_ext-artic no-lock
    where cur_ext-artic.cli-type = v-cli-type
      and cur_ext-artic.cli-code = v-cli-code
      and cur_ext-artic.gds-code = p-gds-code
  no-error .
  if not available cur_ext-artic then do :
    message
      "Ошибка при сохранении внешнего артикула!" skip
    view-as alert-box error.
  end.
  else do :
    assign
      p-recid = recid( cur_ext-artic )
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-units Dialog-Frame
ON choose OF b-units IN FRAME Dialog-Frame /* b-units */
do:
  { gbl/stdbtn.i }

  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli  = buf_units.unit-name.
  display fi-unit-cli with frame {&frame-name}.
  apply "entry":U to fi-cli-base-rate .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-units-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-units-ord Dialog-Frame
ON choose OF b-units-ord IN FRAME Dialog-Frame /* b-units */
do:
  { gbl/stdbtn.i }

  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli-ord  = buf_units.unit-name.
  display fi-unit-cli-ord with frame {&frame-name}.
  apply "entry":U to fi-cli-base-rate-ord .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-units-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-units-rcv Dialog-Frame
ON choose OF b-units-rcv IN FRAME Dialog-Frame /* b-units */
do:
  { gbl/stdbtn.i }

  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli-rcv  = buf_units.unit-name.
  display fi-unit-cli-rcv with frame {&frame-name}.
  apply "entry":U to fi-cli-base-rate-rcv .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-unit-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli Dialog-Frame
ON leave OF fi-unit-cli IN FRAME Dialog-Frame
do:
  find ub.units where ub.units.unit-name = input frame {&frame-name} fi-unit-cli no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli with frame {&frame-name}.
    apply "choose" to b-units.
    return no-apply.
  end.
  assign frame {&frame-name} fi-unit-cli.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli Dialog-Frame
ON return OF fi-unit-cli IN FRAME Dialog-Frame
do:
  apply "entry" to fi-cli-base-rate in frame {&frame-name}.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-unit-cli-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli-ord Dialog-Frame
ON leave OF fi-unit-cli-ord IN FRAME Dialog-Frame
do:
  find ub.units where ub.units.unit-name = input frame {&frame-name} fi-unit-cli-ord no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli-ord with frame {&frame-name}.
    apply "choose" to b-units-ord.
    return no-apply.
  end.
  assign frame {&frame-name} fi-unit-cli-ord.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli-ord Dialog-Frame
ON return OF fi-unit-cli-ord IN FRAME Dialog-Frame
do:
  apply "entry" to fi-cli-base-rate-ord in frame {&frame-name}.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-unit-cli-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli-rcv Dialog-Frame
ON leave OF fi-unit-cli-rcv IN FRAME Dialog-Frame
do:
  find ub.units where ub.units.unit-name = input frame {&frame-name} fi-unit-cli-rcv no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli-rcv with frame {&frame-name}.
    apply "choose" to b-units-rcv.
    return no-apply.
  end.
  assign frame {&frame-name} fi-unit-cli-rcv.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli-rcv Dialog-Frame
ON return OF fi-unit-cli-rcv IN FRAME Dialog-Frame
do:
  apply "entry" to fi-cli-base-rate-rcv in frame {&frame-name}.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.clients.obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.clients.obj-code Dialog-Frame
ON LEAVE OF ub.clients.obj-code IN FRAME Dialog-Frame /* Объект */
DO:
  run proc-choose-client in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.clients.obj-code Dialog-Frame
ON RETURN OF ub.clients.obj-code IN FRAME Dialog-Frame /* Объект */
DO:
  run proc-choose-client in this-procedure no-error .
  if error-status :error then return no-apply.
  apply "entry":u to fi-ext-artic in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.clients.obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.clients.obj-type Dialog-Frame
ON RETURN OF ub.clients.obj-type IN FRAME Dialog-Frame /* Контрагент */
DO:
  apply "ENTRY" to ub.clients.obj-code in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-prod Dialog-Frame
ON CHOOSE OF r-prod IN FRAME Dialog-Frame /* r-prod */
DO:
  define variable v-ref-list as character no-undo .

  run ref/cli-all.w ( parParentProc
                    , "b-add,b-sel"
                    , ?
                    , ?
                    , ?
                    , ?
                    , ?
                    , ?
                    , output v-ref-list
                    ) .

  if v-ref-list = "" then do:
    return no-apply.
  end.
  find ub.clients no-lock
    where recid (ub.clients) = integer(v-ref-list)
  no-error .
  if available ub.clients then do :
    display
      ub.clients.obj-type
      ub.clients.obj-code
      ub.clients.obj-name
    with frame {&frame-name}.
  end.
  else do:
    message
      "Не найден контрагент!"
    view-as alert-box error.
    return no-apply.
  end.
  apply "entry":U to fi-ext-artic.
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
  RUN my-enable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-exist-artic Dialog-Frame
PROCEDURE check-exist-artic :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-cli-type  like ub.ext-artic.cli-type  no-undo .
define input  parameter p-cli-code  like ub.ext-artic.cli-code  no-undo .
define input  parameter p-ext-artic like ub.ext-artic.ext-artic no-undo .
define input  parameter p-recid     as recid                    no-undo .
define output parameter p-exist     as logical                  no-undo .

define buffer ea        for ub.ext-artic.
define buffer buf_goods for ub.goods.

define variable v-del as logical   no-undo .

do
on error undo, return error return-value
:
  /* Проверяем есть ли уже для этого поставщика такой артикул */
  find first ea no-lock
    where ea.cli-type  = p-cli-type
      and ea.cli-code  = p-cli-code
      and ea.ext-artic = p-ext-artic
      and ea.status_   <> {&deleted}
  no-error .
  if available ea then do:
    if recid( ea ) <> p-recid then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = ea.gds-code
      no-error .
      message
        substitute( "Для данного контрагента уже есть товар &1 &2 с таким внешним артикулом"
                  , buf_goods.artic
                  , buf_goods.gds-name
                  )
      view-as alert-box error .
      assign
        p-exist = yes
      .
    end.
    else do:
      assign
        p-exist = no
      .
    end.
  end.
  else do:
    assign
      p-exist = no
    .
  end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-client Dialog-Frame
PROCEDURE chk-client :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-log as logical   no-undo .
define buffer buf_clients for ub.clients.

  find first ub.clients no-lock
    where ub.clients.obj-type = input frame {&frame-name} ub.clients.obj-type
      and ub.clients.obj-code = input frame {&frame-name} ub.clients.obj-code
  no-error.
  if available ub.clients then do :
    assign
      p-log = yes
    .
    display
      ub.clients.obj-name
    with frame {&frame-name}.
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
  DISPLAY fi-ext-artic fi-unit-cli fi-cli-base-rate fi-unit-cli-ord
          fi-cli-base-rate-ord fi-unit-cli-rcv fi-cli-base-rate-rcv ed-ps
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_goods THEN
    DISPLAY buf_goods.artic buf_goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-rest b-help buf_goods.artic buf_goods.gds-name RECT-1
         ub.clients.obj-type RECT-2 ub.clients.obj-code RECT-3 fi-ext-artic
         fi-unit-cli b-units fi-cli-base-rate fi-unit-cli-ord b-units-ord
         fi-cli-base-rate-ord fi-unit-cli-rcv b-units-rcv fi-cli-base-rate-rcv
         ed-ps r-prod
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-clients Dialog-Frame
PROCEDURE find-clients :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-recid as recid     no-undo .

define buffer buf_ext-artic for ub.ext-artic.

do
on error undo, return error return-value
:
  find first buf_ext-artic no-lock
    where recid( buf_ext-artic ) = p-recid
  no-error .
  if available buf_ext-artic then do:
    find first ub.clients
      where ub.clients.obj-type = buf_ext-artic.cli-type
        and ub.clients.obj-code = buf_ext-artic.cli-code
        no-error .
    assign
      fi-ext-artic         = buf_ext-artic.ext-artic
      ed-ps                = buf_ext-artic.ps
      fi-unit-cli          = buf_ext-artic.unit-cli
      fi-cli-base-rate     = buf_ext-artic.cli-base-rate
      fi-unit-cli-ord      = buf_ext-artic.unit-cli-ord
      fi-cli-base-rate-ord = buf_ext-artic.cli-base-rate-ord
      fi-unit-cli-rcv      = buf_ext-artic.unit-cli-rcv
      fi-cli-base-rate-rcv = buf_ext-artic.cli-base-rate-rcv
    .
    display
      ub.clients.obj-type
      ub.clients.obj-code
      ub.clients.obj-name
      fi-ext-artic
      fi-unit-cli
      fi-cli-base-rate
      fi-unit-cli-ord
      fi-cli-base-rate-ord
      fi-unit-cli-rcv
      fi-cli-base-rate-rcv
      ed-ps
    with frame {&frame-name}.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
  no-error .
  if not available buf_goods then do:
    message "Не найден товар с кодом: " p-gds-code view-as alert-box error .
    return error substitute( "Не найден товар с кодом: &1" , p-gds-code ).
  end.
  case p-mode :
    when {&add-def} then do:
      frame {&frame-name}:title = "Д О Б А В Л Е Н И Е   внешний артикул для товара артикул: " + buf_goods.artic + "   " + buf_goods.gds-name.
      b-exit:label = "&Ввод".
      assign
        fi-unit-cli          = buf_goods.unit-cli
        fi-cli-base-rate     = buf_goods.cli-base-rate
        fi-unit-cli-ord      = buf_goods.unit-cli
        fi-cli-base-rate-ord = buf_goods.cli-base-rate
        fi-unit-cli-rcv      = buf_goods.unit-cli
        fi-cli-base-rate-rcv = buf_goods.cli-base-rate
      .
      enable
          r-prod
          ub.clients.obj-type
          ub.clients.obj-code
          fi-ext-artic
          fi-unit-cli
          b-units
          fi-cli-base-rate
          fi-unit-cli-ord
          b-units-ord
          fi-cli-base-rate-ord
          fi-unit-cli-rcv
          b-units-rcv
          fi-cli-base-rate-rcv
          ed-PS
      with frame {&frame-name}.
      display
        fi-unit-cli
        fi-cli-base-rate
        fi-unit-cli-ord
        fi-cli-base-rate-ord
        fi-unit-cli-rcv
        fi-cli-base-rate-rcv
      with frame {&frame-name}.
      run set-client-by-recid in this-procedure.
    end.
    when {&lookup} then do:
      frame {&frame-name}:title = "П Р О С М О Т Р   внешний артикул для товара артикул: " + buf_goods.artic + "   " + buf_goods.gds-name.
      assign
        ed-PS:read-only = yes
        b-rest:visible  = no
      .
      disable
        r-prod
      with frame {&frame-name}.
      run find-clients in this-procedure  ( input p-recid ) no-error .
    end.
    when {&update} then do:
      frame {&frame-name}:title = "И З М Е Н Е Н И Е   внешний артикул для товара артикул: " + buf_goods.artic + "   " + buf_goods.gds-name.
      b-exit:label = "&Ввод".
      enable
        fi-ext-artic
        ed-PS
        fi-unit-cli
        b-units
        fi-cli-base-rate
        fi-unit-cli-ord
        b-units-ord
        fi-cli-base-rate-ord
        fi-unit-cli-rcv
        b-units-rcv
        fi-cli-base-rate-rcv
      with frame {&frame-name}.
      assign
        ub.clients.obj-type :read-only = yes
        ub.clients.obj-code :read-only = yes
        ub.clients.obj-name :read-only = yes
      .
      run find-clients in this-procedure  ( input p-recid ) no-error .
    end.
  end case.

  ENABLE
    b-exit
    b-help
    b-rest when p-mode <> {&lookup}
    ed-PS
  WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
  display
      buf_goods.artic
      buf_goods.gds-name
  with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-choose-client Dialog-Frame
PROCEDURE proc-choose-client :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  define variable v-log       as logical   no-undo .
  define variable v-ref-list  as character no-undo .

  run chk-client in this-procedure (output v-log).
  if not v-log then do :
    run ref/cli-all.w ( parParentProc
                      , "b-add,b-sel"
                      , ?
                      , ?
                      , ?
                      , ?
                      , ?
                      , ?
                      , output v-ref-list
                      ) .

    if v-ref-list = "" then do:
      return error.
    end.
    find ub.clients no-lock
      where recid (ub.clients) = integer(v-ref-list)
    no-error .
    if available ub.clients then do :
      display
        ub.clients.obj-type
        ub.clients.obj-code
        ub.clients.obj-name
      with frame {&frame-name}.
    end.
    else do:
      message
        "Не найден контрагент!"
      view-as alert-box error.
      return error.
    end.
  end. /* not v-log */

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*
    заблокировать выбор контрагента если
    параметр p-sel-contractor-recid == 0
*/
procedure set-client-by-recid:    
    if p-sel-contractor-recid = 0 then return.
     
    find first ub.clients no-lock
        where recid(ub.clients) = p-sel-contractor-recid
        no-error.
           
    if avail ub.clients then
        do:
            display
                ub.clients.obj-code
                ub.clients.obj-name
                ub.clients.obj-type
                with frame {&frame-name}.
            
            disable
                r-prod
                ub.clients.obj-code
                ub.clients.obj-name
                ub.clients.obj-type
                with frame {&frame-name}.
        end.
end.