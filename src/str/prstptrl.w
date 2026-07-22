&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME frame-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS frame-place
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка топливных товаров в документе пересортица

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/23/07
Author: Dmitry Ukhanov
Creation date: 10/23/07

*/


/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define parameter buffer bf_goods      for ub.goods.
define input parameter paranother-gds-code like ub.goods.gds-code no-undo.
define input  parameter pardoc-code  as character no-undo.
define input  parameter parobj-type  as character no-undo.
define input  parameter parobj-code  as integer   no-undo.
define input  parameter parwrite-off as logical   no-undo.
define input  parameter parmode      as character no-undo.
define output parameter parstate     as logical initial no no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка топливных товаров в документе пересортица".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ str/lib-trn.i }
{ gbl/ptrlprop.i def }

DEFINE SHARED TEMP-TABLE tt-place NO-UNDO
    FIELD pl-code             LIKE ub.place.pl-code
    FIELD loc1                LIKE ub.place.loc1
    FIELD pl-name             LIKE ub.place.pl-name
    FIELD before-l            AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD before-kg           AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD write-off-l         AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD income-l            AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD write-off-kg        AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD income-kg           AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD write-off-doc-l     AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD income-doc-l        AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD write-off-doc-kg    AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD income-doc-kg       AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    INDEX pi IS UNIQUE PRIMARY pl-code.

DEFINE BUFFER bf_gds-obj  FOR ub.gds-obj.
DEFINE BUFFER bf_doc-line FOR ub.doc-line.
DEFINE BUFFER bf_inv-line FOR ub.inv-line.
DEFINE BUFFER bf_clients  FOR ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME frame-place
&Scoped-define BROWSE-NAME b-place

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-place

/* Definitions for BROWSE b-place                                       */
&Scoped-define FIELDS-IN-QUERY-b-place pl-code loc1 pl-name before-l write-off-l income-l write-off-kg income-kg write-off-doc-l income-doc-l write-off-doc-kg income-doc-kg
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-place
&Scoped-define SELF-NAME b-place
&Scoped-define QUERY-STRING-b-place FOR EACH tt-place
&Scoped-define OPEN-QUERY-b-place OPEN QUERY {&SELF-NAME} FOR EACH tt-place.
&Scoped-define TABLES-IN-QUERY-b-place tt-place
&Scoped-define FIRST-TABLE-IN-QUERY-b-place tt-place


/* Definitions for DIALOG-BOX frame-place                               */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frame-place ~
    ~{&OPEN-QUERY-b-place}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-help b-place
&Scoped-Define DISPLAYED-OBJECTS varbefore-l varafter-l ~
varwork-l varwork-kg

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .


DEFINE VARIABLE varafter-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Остаток (л)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.


DEFINE VARIABLE varbefore-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Факт(л)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE varwork-kg AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "По документу(кг)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE varwork-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "По документу(л)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-place FOR
      tt-place SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-place frame-place _FREEFORM
  QUERY b-place DISPLAY
      pl-code             COLUMN-LABEL "Бар-код рез." FORMAT "99999999999":U
loc1                COLUMN-LABEL "Код"
pl-name             COLUMN-LABEL "Название"
before-l            COLUMN-LABEL "Факт(л)"
write-off-l         COLUMN-LABEL "Списано(л)"
income-l            COLUMN-LABEL "Оприходовано(л)"
write-off-kg        COLUMN-LABEL "Списано(кг)"
income-kg           COLUMN-LABEL "Оприходовано(кг)"
write-off-doc-l     COLUMN-LABEL "Списано в док(л)"
income-doc-l        COLUMN-LABEL "Оприходовано в док(л)"
write-off-doc-kg    COLUMN-LABEL "Списано в док(кг)"
income-doc-kg       COLUMN-LABEL "Оприходовано в док(кг)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94.25 BY 15.75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frame-place
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-chg AT ROW 1 COL 21
     b-help AT ROW 1 COL 86
     varbefore-l AT ROW 2.5 COL 8 COLON-ALIGNED
     varafter-l AT ROW 2.5 COL 56 COLON-ALIGNED
     varwork-l AT ROW 3.75 COL 20.5 COLON-ALIGNED
     varwork-kg AT ROW 3.75 COL 69 COLON-ALIGNED
     b-place AT ROW 5 COL 1.5
     SPACE(0.25) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX frame-place
                                                                        */
/* BROWSE-TAB b-place varwork-kg frame-place */
ASSIGN
       FRAME frame-place:SCROLLABLE       = FALSE
       FRAME frame-place:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-chg IN FRAME frame-place
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-save IN FRAME frame-place
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varafter-l IN FRAME frame-place
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varbefore-l IN FRAME frame-place
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwork-kg IN FRAME frame-place
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwork-l IN FRAME frame-place
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-place
/* Query rebuild information for BROWSE b-place
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-place.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-place */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME frame-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frame-place frame-place
ON GO OF FRAME frame-place /* <insert dialog title> */
DO:
  ASSIGN
    parstate = YES.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frame-place frame-place
ON return OF FRAME frame-place /* <insert dialog title> */
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frame-place frame-place
ON WINDOW-CLOSE OF FRAME frame-place /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg frame-place
ON CHOOSE OF b-chg IN FRAME frame-place /* Изменить */
DO:
  define variable varstate       as logical no-undo.
  define variable varqnty-l      as decimal no-undo.
  define variable varqnty-kg     as decimal no-undo.
  define variable varqnty-l-mem  as decimal no-undo.
  define variable varqnty-kg-mem as decimal no-undo.
  define buffer bf_place for ub.place.
  if available tt-place then do:
    if parwrite-off = yes then do:
      assign
        varqnty-l-mem  = tt-place.write-off-l
        varqnty-kg-mem = tt-place.write-off-kg .
    end.
    else do:
      assign
        varqnty-l-mem  = tt-place.income-l
        varqnty-kg-mem = tt-place.income-kg .
    end.
    find first bf_place where bf_place.obj-type = parobj-type      and
                              bf_place.obj-code = parobj-code      and
                              bf_place.pl-code  = tt-place.pl-code no-lock.
    run str/prstptru.w (buffer bf_goods,
                    buffer bf_place,
                    input  (if ptrlprop-expptrl = {&calc-petrol-volume} then yes else no),
                    input  {&update},
                    input  (if parwrite-off = yes then yes else no),
                    input  tt-place.before-l,
                    input  tt-place.before-kg,
                    input  (if parwrite-off = yes then tt-place.write-off-l  else tt-place.income-l),
                    input  (if parwrite-off = yes then tt-place.write-off-kg else tt-place.income-kg),
                    input  tt-place.write-off-doc-l,
                    input  tt-place.write-off-doc-kg,
                    input  tt-place.income-doc-l,
                    input  tt-place.income-doc-kg,
                    output varstate,
                    output varqnty-l,
                    output varqnty-kg) no-error.

    if not error-status:error and
       varstate = yes         then do:
      if parwrite-off = yes then do:
        assign
          tt-place.write-off-l  = varqnty-l
          tt-place.write-off-kg = varqnty-kg
          tt-place.write-off-doc-l  = tt-place.write-off-doc-l  - varqnty-l-mem + varqnty-l
          tt-place.write-off-doc-kg = tt-place.write-off-doc-kg - varqnty-kg-mem + varqnty-kg
        .
      end.
      else do:
        assign
          tt-place.income-l  = varqnty-l
          tt-place.income-kg = varqnty-kg
          tt-place.income-doc-l  = tt-place.income-doc-l  - varqnty-l-mem + varqnty-l
          tt-place.income-doc-kg = tt-place.income-doc-kg - varqnty-kg-mem + varqnty-kg
        .
      end.
      display tt-place.write-off-l tt-place.write-off-kg tt-place.write-off-doc-l tt-place.write-off-doc-kg tt-place.income-l tt-place.income-kg tt-place.income-doc-l tt-place.income-doc-kg
      with browse {&browse-name}.
      run disp-free-qnty in this-procedure.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-place
&Scoped-define SELF-NAME b-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-place frame-place
ON return OF b-place IN FRAME frame-place
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK frame-place


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 ASSIGN
    frame {&FRAME-NAME}:TITLE = "Определение количеств в резервуарах для документа пересортица " + pardoc-code + " для товара " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code) + " " + bf_goods.gds-name.
  FIND FIRST bf_gds-obj WHERE bf_gds-obj.obj-type  = parobj-type  AND
                              bf_gds-obj.obj-code  = parobj-code  AND
                              bf_gds-obj.artic     = bf_goods.artic     AND
                              bf_gds-obj.prod-type = bf_goods.prod-type AND
                              bf_gds-obj.prod-code = bf_goods.prod-code NO-LOCK no-error.
  if available bf_gds-obj then do:
    ASSIGN
      varbefore-l = bf_gds-obj.fact-qnty.
  end.
  DISPLAY varbefore-l WITH FRAME {&FRAME-NAME}.
  RUN make-tt-table IN THIS-PROCEDURE.
  RUN disp-free-qnty IN THIS-PROCEDURE.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = parobj-type AND
                              bf_clients.obj-code = parobj-code NO-LOCK.

  { gbl/ptrlprop.i run parobj-type parobj-code }

  RUN enable_UI.
  IF parmode = {&add-def} OR
     parmode = {&UPDATE}  THEN DO:
    ENABLE b-save b-chg WITH FRAME {&FRAME-NAME}.
  END.
  ASSIGN
    tt-place.pl-name:WIDTH IN BROWSE {&browse-name} = 30
    tt-place.pl-name:RESIZABLE IN BROWSE {&browse-name} = YES.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI frame-place  _DEFAULT-DISABLE
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
  HIDE FRAME frame-place.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-free-qnty frame-place
PROCEDURE disp-free-qnty :
DEFINE BUFFER bf_tt-place FOR tt-place.
  ASSIGN
    varwork-l  = 0.00
    varwork-kg = 0.00  .
  FOR EACH bf_tt-place ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    assign
      varwork-l  = varwork-l  + bf_tt-place.income-doc-l  - bf_tt-place.write-off-doc-l
      varwork-kg = varwork-kg + bf_tt-place.income-doc-kg - bf_tt-place.write-off-doc-kg.
  END.
  ASSIGN
    varafter-l  = varbefore-l  + varwork-l.
  DISPLAY varwork-l varwork-kg varafter-l WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI frame-place  _DEFAULT-ENABLE
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
  DISPLAY varbefore-l varafter-l varwork-l varwork-kg
      WITH FRAME frame-place.
  ENABLE b-cancel b-help b-place
      WITH FRAME frame-place.
  VIEW FRAME frame-place.
  {&OPEN-BROWSERS-IN-QUERY-frame-place}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-tt-table frame-place
PROCEDURE make-tt-table :
DEFINE BUFFER bf_pl-gds     FOR ub.pl-gds.
DEFINE BUFFER bf_place      FOR ub.place.
DEFINE BUFFER bf_parts      FOR ub.parts.
define buffer bf-another_parts for ub.parts.
define buffer bf_parts-root for ub.parts-root.
define buffer bf-another_goods for ub.goods.
define buffer bf_doc-pl        for ub.doc-pl.
DEFINE VARIABLE varwrite-off-doc-l  AS DECIMAL NO-UNDO.
DEFINE VARIABLE varincome-doc-l     AS DECIMAL NO-UNDO.
DEFINE VARIABLE varwrite-off-doc-kg AS DECIMAL NO-UNDO.
DEFINE VARIABLE varincome-doc-kg    AS DECIMAL NO-UNDO.
DEFINE VARIABLE varwrite-off-l      AS DECIMAL NO-UNDO.
DEFINE VARIABLE varincome-l         AS DECIMAL NO-UNDO.
DEFINE VARIABLE varwrite-off-kg     AS DECIMAL NO-UNDO.
DEFINE VARIABLE varincome-kg        AS DECIMAL NO-UNDO.
FOR EACH tt-place ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  DELETE tt-place.
END.
FOR EACH bf_pl-gds WHERE bf_pl-gds.gds-code = bf_goods.gds-code AND
                         bf_pl-gds.obj-type = parobj-type       AND
                         bf_pl-gds.obj-code = parobj-code       NO-LOCK ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  FIND FIRST bf_place WHERE bf_place.obj-type = bf_pl-gds.obj-type AND
                            bf_place.obj-code = bf_pl-gds.obj-code AND
                            bf_place.pl-code  = bf_pl-gds.pl-code  NO-LOCK.
  ASSIGN
    varwrite-off-doc-l  = 0.00
    varincome-doc-l     = 0.00
    varwrite-off-doc-kg = 0.00
    varincome-doc-kg    = 0.00
    varwrite-off-l  = 0.00
    varincome-l     = 0.00
    varwrite-off-kg = 0.00
    varincome-kg    = 0.00
    .
  FOR EACH bf_parts WHERE bf_parts.out-code  = pardoc-code        AND
                          bf_parts.obj-type  = parobj-type        AND
                          bf_parts.obj-code  = parobj-code        AND
                          bf_parts.artic     = bf_goods.artic     AND
                          bf_parts.prod-type = bf_goods.prod-type AND
                          bf_parts.prod-code = bf_goods.prod-code AND
                          bf_parts.pl-code   = bf_pl-gds.pl-code  ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    find first bf_doc-pl where bf_doc-pl.obj-type = bf_parts.obj-type and
                               bf_doc-pl.obj-code = bf_parts.obj-code and
                               bf_doc-pl.pl-code  = bf_parts.pl-code  and
                               bf_doc-pl.out-code = bf_parts.out-code and
                               bf_doc-pl.gds-code = bf_goods.gds-code no-lock.
    IF bf_parts.fact-qnty < 0 THEN DO:
      ASSIGN
        varwrite-off-doc-l  = varwrite-off-doc-l  - bf_parts.fact-qnty
        varwrite-off-doc-kg = varwrite-off-doc-kg - (bf_doc-pl.cli-fact-qnty / bf_doc-pl.fact-qnty) * bf_parts.fact-qnty.
    END.
    ELSE DO:
      ASSIGN
        varincome-doc-l  = varincome-doc-l  + bf_parts.fact-qnty
        varincome-doc-kg = varincome-doc-kg + (bf_doc-pl.cli-fact-qnty / bf_doc-pl.fact-qnty) * bf_parts.fact-qnty.
    END.
    if parmode <> {&add-def} then do:
      find first bf-another_goods where bf-another_goods.gds-code = paranother-gds-code no-lock.
      if parwrite-off then do:
        find first bf_parts-root where bf_parts-root.doc-code       = bf_parts.out-code         and
                                       bf_parts-root.orig-in-code   = bf_parts.in-code          and
                                       bf_parts-root.orig-gds-code  = bf_goods.gds-code         and
                                       bf_parts-root.orig-part-code = bf_parts.part-code        and
                                       bf_parts-root.gds-code       = bf-another_goods.gds-code no-lock no-error.
        if available bf_parts-root then do:
          find first bf-another_parts where bf-another_parts.obj-type   = bf_parts.obj-type          and
                                            bf-another_parts.obj-code   = bf_parts.obj-code          and
                                            bf-another_parts.artic      = bf-another_goods.artic     and
                                            bf-another_parts.prod-type  = bf-another_goods.prod-type and
                                            bf-another_parts.prod-code  = bf-another_goods.prod-code and
                                            bf-another_parts.in-code    = bf_parts-root.in-code      and
                                            bf-another_parts.out-code   = bf_parts.out-code          and
                                            bf-another_parts.part-code  = bf_parts-root.part-code    no-lock.
             ASSIGN
               varwrite-off-l  = varwrite-off-l  + bf-another_parts.real-qnty
               varwrite-off-kg = varwrite-off-kg + (bf_doc-pl.cli-fact-qnty / bf_doc-pl.fact-qnty) * bf-another_parts.real-qnty.
        end.
      end.
      else do:
        find first bf_parts-root where bf_parts-root.doc-code      = bf_parts.out-code         and
                                       bf_parts-root.orig-gds-code = bf-another_goods.gds-code and
                                       bf_parts-root.in-code       = bf_parts.in-code          and
                                       bf_parts-root.gds-code      = bf_goods.gds-code         and
                                       bf_parts-root.part-code     = bf_parts.part-code        no-lock no-error.
        if available bf_parts-root then do:
          find first bf-another_parts where bf-another_parts.obj-type   = bf_parts.obj-type            and
                                            bf-another_parts.obj-code   = bf_parts.obj-code            and
                                            bf-another_parts.artic      = bf-another_goods.artic       and
                                            bf-another_parts.prod-type  = bf-another_goods.prod-type   and
                                            bf-another_parts.prod-code  = bf-another_goods.prod-code   and
                                            bf-another_parts.in-code    = bf_parts-root.orig-in-code   and
                                            bf-another_parts.out-code   = bf_parts.out-code            and
                                            bf-another_parts.part-code  = bf_parts-root.orig-part-code no-lock.
          ASSIGN
            varincome-l  = varincome-l  + bf-another_parts.real-qnty
            varincome-kg = varincome-kg + (bf_doc-pl.cli-fact-qnty / bf_doc-pl.fact-qnty) * bf-another_parts.real-qnty.
        end.
      end.
    end.
  END.

  CREATE tt-place.
  ASSIGN
    tt-place.pl-code          = bf_place.pl-code
    tt-place.loc1             = bf_place.loc1
    tt-place.pl-name          = bf_place.pl-name
    tt-place.before-l         = bf_pl-gds.fact-qnty
    tt-place.before-kg        = bf_pl-gds.cli-fact-qnty
    tt-place.write-off-l      = (if parmode = {&add-def} then 0 else varwrite-off-l)
    tt-place.income-l         = (if parmode = {&add-def} then 0 else varincome-l)
    tt-place.write-off-kg     = (if parmode = {&add-def} then 0 else varwrite-off-kg)
    tt-place.income-kg        = (if parmode = {&add-def} then 0 else varincome-kg   )
    tt-place.write-off-doc-l  = varwrite-off-doc-l
    tt-place.income-doc-l     = varincome-doc-l
    tt-place.write-off-doc-kg = varwrite-off-doc-kg
    tt-place.income-doc-kg    = varincome-doc-kg
  .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME