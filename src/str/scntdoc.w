&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Экран просмотра разбивки документа по договорам поставщиков

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06
*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра разбивки документа по договорам поставщиков".

{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/clcprtsl.i }
{ str/cntparts.i }
{ gbl/tax-name.i }

/* Parameters Definitions ---                                           */
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define input parameter parfin-db   as   logical             no-undo.

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE vartax-name AS CHARACTER NO-UNDO.
DEFINE BUFFER bf_parts FOR ub.parts.
DEFINE BUFFER bf_fin-gds-part FOR ub.fin-gds-part.
DEFINE BUFFER bf_trn-doc FOR ub.trn-doc.
define buffer bf_fin-ob for ub.fin-ob.
define buffer bf_goods for ub.goods.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-parts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES bf_parts bf_goods bf_fin-gds-part bf_fin-ob ~
tt-cnt-parts

/* Definitions for BROWSE b-parts                                       */
&Scoped-define FIELDS-IN-QUERY-b-parts bf_parts.in-code bf_parts.part-code bf_parts.fact-qnty bf_parts.price-base bf_parts.price-rubl bf_fin-ob.prn-doc-code bf_fin-ob.doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-parts
&Scoped-define SELF-NAME b-parts
&Scoped-define QUERY-STRING-b-parts FOR EACH bf_parts NO-LOCK, ~
       FIRST bf_goods no-lock, ~
       FIRST bf_fin-gds-part NO-LOCK, ~
       FIRST bf_fin-ob NO-LOCK
&Scoped-define OPEN-QUERY-b-parts OPEN QUERY {&SELF-NAME} FOR EACH bf_parts NO-LOCK, ~
       FIRST bf_goods no-lock, ~
       FIRST bf_fin-gds-part NO-LOCK, ~
       FIRST bf_fin-ob NO-LOCK.
&Scoped-define TABLES-IN-QUERY-b-parts bf_parts bf_goods bf_fin-gds-part ~
bf_fin-ob
&Scoped-define FIRST-TABLE-IN-QUERY-b-parts bf_parts
&Scoped-define SECOND-TABLE-IN-QUERY-b-parts bf_goods
&Scoped-define THIRD-TABLE-IN-QUERY-b-parts bf_fin-gds-part
&Scoped-define FOURTH-TABLE-IN-QUERY-b-parts bf_fin-ob


/* Definitions for BROWSE b-supp-cnt                                    */
&Scoped-define FIELDS-IN-QUERY-b-supp-cnt tt-cnt-parts.contract-prn-code tt-cnt-parts.supp-name tt-cnt-parts.supp-type tt-cnt-parts.supp-code tt-cnt-parts.sum-dsc-base-acc tt-cnt-parts.sum-dsc-rubl-acc tt-cnt-parts.vat-base-acc tt-cnt-parts.vat-rubl-acc tt-cnt-parts.road-tax-base-acc tt-cnt-parts.road-tax-rubl-acc tt-cnt-parts.transport-base-acc tt-cnt-parts.transport-rubl-acc tt-cnt-parts.other-base-acc tt-cnt-parts.other-rubl-acc tt-cnt-parts.slt-base-acc tt-cnt-parts.slt-rubl-acc tt-cnt-parts.excise-base-acc tt-cnt-parts.excise-rubl-acc tt-cnt-parts.contract-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-supp-cnt
&Scoped-define SELF-NAME b-supp-cnt
&Scoped-define QUERY-STRING-b-supp-cnt FOR EACH tt-cnt-parts
&Scoped-define OPEN-QUERY-b-supp-cnt OPEN QUERY {&SELF-NAME} FOR EACH tt-cnt-parts.
&Scoped-define TABLES-IN-QUERY-b-supp-cnt tt-cnt-parts
&Scoped-define FIRST-TABLE-IN-QUERY-b-supp-cnt tt-cnt-parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-supp-cnt}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-supp-cnt b-parts

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-fin-doc
     LABEL "&Платежи"
     SIZE 10 BY 1.

DEFINE BUTTON b-fin-ob
     LABEL "&Фин. об"
     SIZE 10 BY 1.

DEFINE BUTTON b-fin-pob
     LABEL "П&редфиноб"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-parts FOR
      bf_parts,
      bf_goods,
      bf_fin-gds-part,
      bf_fin-ob SCROLLING.

DEFINE QUERY b-supp-cnt FOR
      tt-cnt-parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-parts Dialog-Frame _FREEFORM
  QUERY b-parts DISPLAY
      bf_parts.in-code COLUMN-LABEL "Прих. накл."
 bf_parts.part-code FORMAT "x(15)" COLUMN-LABEL "Код партии"
 bf_parts.fact-qnty COLUMN-LABEL "Факт кол-во"
 bf_parts.price-base COLUMN-LABEL "Цена (вал)"
 bf_parts.price-rubl COLUMN-LABEL "Цена (abbr_rub)"
 bf_fin-ob.prn-doc-code COLUMN-LABEL "Фин. обязат."
 bf_fin-ob.doc-code COLUMN-LABEL "Вн. код."
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9
         TITLE "Партии по договору".

DEFINE BROWSE b-supp-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-supp-cnt Dialog-Frame _FREEFORM
  QUERY b-supp-cnt DISPLAY
      tt-cnt-parts.contract-prn-code COLUMN-LABEL "Договор"
 tt-cnt-parts.supp-name FORMAT "x(20)" COLUMN-LABEL "Поставщик"
 tt-cnt-parts.supp-type COLUMN-LABEL ""
 tt-cnt-parts.supp-code COLUMN-LABEL ""
 tt-cnt-parts.sum-dsc-base-acc COLUMN-LABEL "Сумма (вал)"
 tt-cnt-parts.sum-dsc-rubl-acc COLUMN-LABEL "Сумма (abbr_rub)"
 tt-cnt-parts.vat-base-acc COLUMN-LABEL "НДС (вал)"
 tt-cnt-parts.vat-rubl-acc COLUMN-LABEL "НДС (abbr_rub)"
 tt-cnt-parts.road-tax-base-acc COLUMN-LABEL ""
 tt-cnt-parts.road-tax-rubl-acc COLUMN-LABEL ""
 tt-cnt-parts.transport-base-acc COLUMN-LABEL "Транспортные расходы (вал)"
 tt-cnt-parts.transport-rubl-acc COLUMN-LABEL "Транспортные расходы (abbr_rub)"
 tt-cnt-parts.other-base-acc COLUMN-LABEL "Прочие расходы (вал)"
 tt-cnt-parts.other-rubl-acc COLUMN-LABEL "Прочие расходы (abbr_rub)"
 tt-cnt-parts.slt-base-acc COLUMN-LABEL "НП (вал)"
 tt-cnt-parts.slt-rubl-acc COLUMN-LABEL "НП (abbr_rub)"
 tt-cnt-parts.excise-base-acc COLUMN-LABEL "Акциз (вал)"
 tt-cnt-parts.excise-rubl-acc COLUMN-LABEL "Акциз (abbr_rub)"
 tt-cnt-parts.contract-code COLUMN-LABEL "Вн. номер договора"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 9
         TITLE "Договора" ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-fin-pob AT ROW 1 COL 11
     b-fin-ob AT ROW 1 COL 21
     b-fin-doc AT ROW 1 COL 31
     b-help AT ROW 1 COL 41
     b-supp-cnt AT ROW 2.5 COL 1
     b-parts AT ROW 12 COL 1
     SPACE(0.50) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Разбивка документа по договорам поставщиков"
         DEFAULT-BUTTON b-exit.


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
                                                                        */
/* BROWSE-TAB b-supp-cnt b-help Dialog-Frame */
/* BROWSE-TAB b-parts b-supp-cnt Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-fin-doc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-fin-ob IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-fin-pob IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-parts
/* Query rebuild information for BROWSE b-parts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH bf_parts NO-LOCK, FIRST bf_goods no-lock, FIRST bf_fin-gds-part NO-LOCK, FIRST bf_fin-ob NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE b-parts */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-supp-cnt
/* Query rebuild information for BROWSE b-supp-cnt
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-cnt-parts.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-supp-cnt */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Разбивка документа по договорам поставщиков */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fin-doc Dialog-Frame
ON CHOOSE OF b-fin-doc IN FRAME Dialog-Frame /* Платежи */
DO:
  run str/sfddoc.w (INPUT pardoc-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-fin-ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fin-ob Dialog-Frame
ON CHOOSE OF b-fin-ob IN FRAME Dialog-Frame /* Фин. об */
DO:
  run str/sfodoc.w (INPUT pardoc-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-fin-pob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fin-pob Dialog-Frame
ON CHOOSE OF b-fin-pob IN FRAME Dialog-Frame /* Предфиноб */
DO:
  run str/spfodoc.w (INPUT pardoc-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-supp-cnt
&Scoped-define SELF-NAME b-supp-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-supp-cnt Dialog-Frame
ON VALUE-CHANGED OF b-supp-cnt IN FRAME Dialog-Frame /* Договора */
DO:
  RUN open-query-parts IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-parts
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name=b-supp-cnt}

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse b-parts:handle
  ) .

run diasize_init in this-procedure .


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:
 find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
 run tax-name ({&road-tax}, output vartax-name).
 assign
 tt-cnt-parts.road-tax-base-acc:label in browse b-supp-cnt  = vartax-name + " (вал)"
 tt-cnt-parts.road-tax-rubl-acc:label in browse b-supp-cnt  = vartax-name + " ({&abbr_rub})"
 tt-cnt-parts.sum-dsc-rubl-acc:label in browse b-supp-cnt   = "Сумма ({&abbr_rub})"
 tt-cnt-parts.vat-rubl-acc:label in browse b-supp-cnt       = "НДС ({&abbr_rub})"
 tt-cnt-parts.transport-rubl-acc:label in browse b-supp-cnt = "Транспортные расходы ({&abbr_rub})"
 tt-cnt-parts.other-rubl-acc:label in browse b-supp-cnt     = "Прочие расходы ({&abbr_rub})"
 tt-cnt-parts.slt-rubl-acc:label in browse b-supp-cnt       = "НП ({&abbr_rub})"
 tt-cnt-parts.excise-rubl-acc:label in browse b-supp-cnt    = "Акциз ({&abbr_rub})"
 bf_parts.price-rubl:label in browse b-parts                = "Цена ({&abbr_rub})"
 .
 assign frame
   {&FRAME-NAME}:TITLE = "Разбивка документа " + pardoc-code + " по договорам поставщиков".
  run cntparts_calc-table-cnt in this-procedure (input pardoc-code) no-error.
  if error-status:error then do:
    message "Ошибка при обсчете документа." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
     view-as alert-box error.
    return error.
  end.
    run enable_ui.
  IF parfin-db THEN DO:
    ENABLE b-fin-pob b-fin-ob b-fin-doc WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    HIDE b-fin-pob b-fin-ob b-fin-doc IN FRAME {&FRAME-NAME}.
  END.
  run open-query-parts in this-procedure.

  wait-for go of frame {&frame-name}.
end.
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
  ENABLE b-exit b-help b-supp-cnt b-parts
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-parts Dialog-Frame
PROCEDURE open-query-parts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF AVAILABLE tt-cnt-parts THEN DO:
    OPEN QUERY b-parts FOR EACH bf_parts WHERE bf_parts.out-code      = pardoc-code          AND
                                               bf_parts.host-code     = tt-cnt-parts.host-code AND
                                               bf_parts.contract-code = tt-cnt-parts.contract-code USE-INDEX out-code NO-LOCK,
    first bf_goods where bf_goods.artic = bf_parts.artic and
                         bf_goods.prod-type = bf_parts.prod-type and
                         bf_goods.prod-code = bf_parts.prod-code no-lock,
    FIRST bf_fin-gds-part outer-join WHERE bf_fin-gds-part.obj-type = bf_trn-doc.obj-type AND
                                           bf_fin-gds-part.obj-code = bf_trn-doc.obj-code AND
                                           bf_fin-gds-part.out-code = bf_parts.out-code AND
                                           bf_fin-gds-part.gds-code = bf_goods.gds-code AND
                                           bf_fin-gds-part.in-code = bf_parts.in-code AND
                                           bf_fin-gds-part.part-code = bf_parts.part-code NO-LOCK,
    FIRST bf_fin-ob outer-join WHERE bf_fin-ob.doc-code = bf_fin-gds-part.fin-ob-code no-lock.
    display b-parts with frame {&frame-name}.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME