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

Экран просмотра разбивки удаленного документа по договорам поставщиков

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра разбивки удаленного документа по договорам поставщиков".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/clcprtsl.i }
{ str/cntparts.i }
{ gbl/tax-name.i }

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER pardoc-code LIKE ub.c-trn-doc.doc-code NO-UNDO.
define input parameter parchip-num like ub.c-trn-doc.chip-num no-undo.

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE vartax-name AS CHARACTER NO-UNDO.
DEFINE BUFFER bf_c-parts        FOR ub.c-parts.
DEFINE BUFFER bf_fin-gds-part FOR ub.fin-gds-part.
DEFINE BUFFER bf_c-trn-doc      FOR ub.c-trn-doc.
define buffer bf_fin-ob       for ub.fin-ob.
define buffer bf_goods for ub.goods.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-c-parts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES bf_c-parts bf_goods bf_fin-gds-part ~
bf_fin-ob tt-cnt-parts

/* Definitions for BROWSE b-c-parts                                     */
&Scoped-define FIELDS-IN-QUERY-b-c-parts bf_c-parts.in-code bf_c-parts.part-code bf_c-parts.fact-qnty bf_c-parts.price-base bf_c-parts.price-rubl bf_fin-ob.prn-doc-code bf_fin-ob.doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-c-parts
&Scoped-define SELF-NAME b-c-parts
&Scoped-define QUERY-STRING-b-c-parts FOR EACH bf_c-parts NO-LOCK, ~
       FIRST bf_goods no-lock, ~
       FIRST bf_fin-gds-part NO-LOCK, ~
       FIRST bf_fin-ob NO-LOCK
&Scoped-define OPEN-QUERY-b-c-parts OPEN QUERY {&SELF-NAME} FOR EACH bf_c-parts NO-LOCK, ~
       FIRST bf_goods no-lock, ~
       FIRST bf_fin-gds-part NO-LOCK, ~
       FIRST bf_fin-ob NO-LOCK.
&Scoped-define TABLES-IN-QUERY-b-c-parts bf_c-parts bf_goods ~
bf_fin-gds-part bf_fin-ob
&Scoped-define FIRST-TABLE-IN-QUERY-b-c-parts bf_c-parts
&Scoped-define SECOND-TABLE-IN-QUERY-b-c-parts bf_goods
&Scoped-define THIRD-TABLE-IN-QUERY-b-c-parts bf_fin-gds-part
&Scoped-define FOURTH-TABLE-IN-QUERY-b-c-parts bf_fin-ob


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
&Scoped-Define ENABLED-OBJECTS b-exit b-fin-pob b-fin-ob b-fin-doc b-help ~
b-supp-cnt b-c-parts

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
DEFINE QUERY b-c-parts FOR
      bf_c-parts,
      bf_goods,
      bf_fin-gds-part,
      bf_fin-ob SCROLLING.

DEFINE QUERY b-supp-cnt FOR
      tt-cnt-parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-c-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-c-parts Dialog-Frame _FREEFORM
  QUERY b-c-parts DISPLAY
      bf_c-parts.in-code COLUMN-LABEL "Прих. накл."
 bf_c-parts.part-code FORMAT "x(15)" COLUMN-LABEL "Код партии"
 bf_c-parts.fact-qnty COLUMN-LABEL "Факт кол-во"
 bf_c-parts.price-base COLUMN-LABEL "Цена (вал)"
 bf_c-parts.price-rubl COLUMN-LABEL "Цена (abbr_rub)"
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
     b-c-parts AT ROW 12 COL 1
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
/* BROWSE-TAB b-c-parts b-supp-cnt Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-c-parts
/* Query rebuild information for BROWSE b-c-parts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH bf_c-parts NO-LOCK, FIRST bf_goods no-lock, FIRST bf_fin-gds-part NO-LOCK, FIRST bf_fin-ob NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE b-c-parts */
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
  run str/scfddoc.w (INPUT pardoc-code, input parchip-num).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-fin-ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fin-ob Dialog-Frame
ON CHOOSE OF b-fin-ob IN FRAME Dialog-Frame /* Фин. об */
DO:
  run str/scfodoc.w (INPUT pardoc-code, input parchip-num).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-fin-pob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fin-pob Dialog-Frame
ON CHOOSE OF b-fin-pob IN FRAME Dialog-Frame /* Предфиноб */
DO:
  run str/scpfodoc.w (INPUT pardoc-code, input parchip-num).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-supp-cnt
&Scoped-define SELF-NAME b-supp-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-supp-cnt Dialog-Frame
ON VALUE-CHANGED OF b-supp-cnt IN FRAME Dialog-Frame /* Договора */
DO:
  RUN open-query-c-parts IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-c-parts
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:
 find first bf_c-trn-doc where bf_c-trn-doc.doc-code = pardoc-code and
                               bf_c-trn-doc.chip-num = parchip-num no-lock.
 run tax-name ({&road-tax}, output vartax-name).
 assign
 tt-cnt-parts.road-tax-base-acc:label in browse b-supp-cnt = vartax-name + " (вал)"
 tt-cnt-parts.road-tax-rubl-acc:label in browse b-supp-cnt = vartax-name + " ({&abbr_rub})"
 tt-cnt-parts.sum-dsc-rubl-acc:label  in browse b-supp-cnt = "Сумма ({&abbr_rub})"
 tt-cnt-parts.vat-rubl-acc:label      in browse b-supp-cnt = "НДС ({&abbr_rub})"
 tt-cnt-parts.transport-rubl-acc:label in browse b-supp-cnt = "Транспортные расходы ({&abbr_rub})"
 tt-cnt-parts.other-rubl-acc:label    in browse b-supp-cnt =  "Прочие расходы ({&abbr_rub})"
 tt-cnt-parts.slt-rubl-acc:label      in browse b-supp-cnt =  "НП ({&abbr_rub})"
 tt-cnt-parts.excise-rubl-acc:label   in browse b-supp-cnt =  "Акциз ({&abbr_rub})"
 bf_c-parts.price-rubl:LABEL in browse b-c-parts = "Цена ({&abbr_rub})"
 .


 assign frame
   {&FRAME-NAME}:TITLE = "Разбивка удаленного документа " + pardoc-code + " по договорам поставщиков".
  run cntparts_calc-c-table-cnt in this-procedure (input pardoc-code, input parchip-num) no-error.
  if error-status:error then do:
    message "Ошибка при обсчете документа." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
     view-as alert-box error.
    return error.
  end.
    run enable_ui.
  run open-query-c-parts in this-procedure.
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
  ENABLE b-exit b-fin-pob b-fin-ob b-fin-doc b-help b-supp-cnt b-c-parts
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-c-parts Dialog-Frame
PROCEDURE open-query-c-parts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF AVAILABLE tt-cnt-parts THEN DO:
    OPEN QUERY b-c-parts FOR EACH bf_c-parts WHERE bf_c-parts.out-code      = pardoc-code                 AND
                                                   bf_c-parts.chip-num      = parchip-num                 and
                                                   bf_c-parts.host-code     = tt-cnt-parts.host-code    AND
                                                   bf_c-parts.contract-code = tt-cnt-parts.contract-code USE-INDEX out-code NO-LOCK,
    first bf_goods where bf_goods.artic = bf_c-parts.artic and
                         bf_goods.prod-type = bf_c-parts.prod-type and
                         bf_goods.prod-code = bf_c-parts.prod-code no-lock,
    FIRST bf_fin-gds-part outer-join WHERE bf_fin-gds-part.obj-type = bf_c-trn-doc.obj-type AND
                                           bf_fin-gds-part.obj-code = bf_c-trn-doc.obj-code AND
                                           bf_fin-gds-part.out-code = bf_c-parts.out-code AND
                                           bf_fin-gds-part.gds-code = bf_goods.gds-code AND
                                           bf_fin-gds-part.in-code = bf_c-parts.in-code AND
                                           bf_fin-gds-part.part-code = bf_c-parts.part-code NO-LOCK,
    FIRST bf_fin-ob outer-join WHERE bf_fin-ob.doc-code = bf_fin-gds-part.fin-ob-code no-lock.
    display b-c-parts with frame {&frame-name}.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME