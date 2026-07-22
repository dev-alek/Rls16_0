&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_parts FOR ub.parts.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Партии ювелирных изделий с двумя единицами измерени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter paction as character no-undo .
/*может быть "split":U и "fuse":U*/
define input parameter p-mode as character no-undo .
/*{&g___object}*/
DEFINE INPUT PARAMETER partic like ub.goods.artic NO-UNDO.
DEFINE INPUT PARAMETER pprod-type like ub.goods.prod-type NO-UNDO.
DEFINE INPUT PARAMETER pprod-code like ub.goods.prod-code NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type like ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code like ub.clients.obj-code NO-UNDO.


/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Партии товаров с двумя ед измерения" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

define variable filter-point as character no-undo init "twoparts" .
define variable filter-point0 as character no-undo init "twoparts" .
define variable filter-label as character no-undo init "Партии_товаров_с_2_ед_изм" .
define variable filter-label0 as character no-undo init "Партии_товаров_с_2_ед_изм" .

define variable mark-list as character no-undo.
define variable mark as char no-undo.
define variable sort-column-name as character no-undo .
define buffer buf_goods for ub.goods.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-parts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_parts

/* Definitions for BROWSE BR-parts                                      */
&Scoped-define FIELDS-IN-QUERY-BR-parts mark X_parts.cli-qnty X_parts.in-code X_parts.part-code X_parts.qnty X_parts.fact-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-parts
&Scoped-define SELF-NAME BR-parts
&Scoped-define QUERY-STRING-BR-parts FOR EACH X_parts       WHERE X_parts.cli-qnty > 1  AND X_parts.out-code = {&free-code}  AND X_parts.artic = partic  AND X_parts.prod-type = pprod-type  AND X_parts.prod-code = pprod-code  AND X_parts.obj-type = p-obj-type  AND X_parts.obj-code = p-obj-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-parts OPEN QUERY {&SELF-NAME} FOR EACH X_parts       WHERE X_parts.cli-qnty > 1  AND X_parts.out-code = {&free-code}  AND X_parts.artic = partic  AND X_parts.prod-type = pprod-type  AND X_parts.prod-code = pprod-code  AND X_parts.obj-type = p-obj-type  AND X_parts.obj-code = p-obj-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-parts X_parts
&Scoped-define FIRST-TABLE-IN-QUERY-BR-parts X_parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-gds B-doc B-part B-mark B-case ~
B-sch B-Help Rs-action BR-parts ED-notes for-gds for-gds-code
&Scoped-Define DISPLAYED-OBJECTS Rs-action ED-notes for-gds for-gds-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-case
     LABEL "&Коробка"
     SIZE 10 BY 1.

DEFINE BUTTON B-doc
     LABEL "&ПН"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

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

DEFINE BUTTON B-part
     LABEL "Па&ртии"
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 97.75 BY 1.63
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE for-gds AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 78.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-gds-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 17.38 BY 1 NO-UNDO.

DEFINE VARIABLE Rs-action AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Неразбитые партии", "split",
"Штуки", "fuse"
     SIZE 31.13 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-parts FOR
                X_parts SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-parts Dialog-Frame _FREEFORM
  QUERY BR-parts DISPLAY
      mark COLUMN-LABEL "*" FORMAT "X(1)":U
      X_parts.cli-qnty FORMAT "->>,>>>,>>9.999":U
      X_parts.in-code FORMAT "X(14)":U
      X_parts.part-code FORMAT "X(12)":U
      X_parts.qnty FORMAT "->>,>>>,>>9.999":U
      X_parts.fact-qnty FORMAT "->>,>>>,>>9.999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     B-gds AT ROW 1 COL 21
     B-doc AT ROW 1 COL 31
     B-part AT ROW 1 COL 41
     B-mark AT ROW 1 COL 51
     B-case AT ROW 1 COL 54
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     Rs-action AT ROW 4.04 COL 3.25 NO-LABEL
     BR-parts AT ROW 5.54 COL 1.25
     ED-notes AT ROW 21.08 COL 1.5 NO-LABEL
     for-gds AT ROW 2.71 COL 1.75 NO-LABEL
     for-gds-code AT ROW 2.71 COL 79.25 COLON-ALIGNED NO-LABEL
     SPACE(0.86) SKIP(19.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_parts B "?" ? ub parts
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-parts Rs-action Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN for-gds IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-parts
/* Query rebuild information for BROWSE BR-parts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_parts
      WHERE X_parts.cli-qnty > 1
 AND X_parts.out-code = {&free-code}
 AND X_parts.artic = partic
 AND X_parts.prod-type = pprod-type
 AND X_parts.prod-code = pprod-code
 AND X_parts.obj-type = p-obj-type
 AND X_parts.obj-code = p-obj-code NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-parts FOR
                X_parts SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE BR-parts */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Партии */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-case
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-case Dialog-Frame
ON CHOOSE OF B-case IN FRAME Dialog-Frame /* Коробка */
DO:
define variable glog as logical no-undo .
define variable v-line-rec as recid no-undo .

  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_parts_split-fuse':U
    {&cntxt-object}
    v-chk-act-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    glog
  }
  if NOT glog then return no-apply.
  case paction:
    when "split":U then do:
      if avail X_parts then do:
        if buf_goods.min-rate = 0
        or buf_goods.max-rate = 0 then do:
          message "Товар в справочнике имеет неверные значения полей КОЛИЧЕСТВО ДРОБНОГО В ШТУКЕ!"
          view-as alert-box .
          return no-apply.
        end.
          if X_parts.cli-qnty = 1 then do:
            message "Партия уже состоит из одного изделия"
            view-as alert-box ERROR.
            return no-apply.
          end.
          v-line-rec = recid(X_parts).
          run ref/spltpart.w (input parparentproc, input-output v-line-rec)  no-error.
          if v-line-rec <> ? then do:
            RUN OPENBr in this-procedure ( input yes, input no, input '':U, input paction).
            APPLY "ENTRY" TO br-parts.
          end.
      end.
    end.
    when "fuse":U then do:
      if mark-list = "" then do:
        message "Не выбрано ни одной записи для слияния партий"
        view-as alert-box ERROR.
        return no-apply.
      end.
        if INDEX(X_parts.part-code, {&part-split}) = 0 then do:
          message "Партия слиянию не подлежит"
          view-as alert-box ERROR.
          return no-apply.
        end.
      run fuse-parts no-error.
      if error-status:error then return no-apply.
      mark-list = "".
      run openbr in this-procedure ( input yes, input no, input '':U, input paction).
    end.
  END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-doc Dialog-Frame
ON CHOOSE OF B-doc IN FRAME Dialog-Frame /* ПН */
DO:
  if available X_parts
  then do:
    run str/showdoc.p
      (input parparentproc   /* parparentproc */
      ,input X_parts.in-code /* p-doc-code    */
      ,input buf_goods.artic     /* p-artic       */
      ,input buf_goods.prod-type /* p-prod-type   */
      ,input buf_goods.prod-code /* p-prod-code   */
      ,input true            /* p-doc-type    */
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dialog-Frame
ON CHOOSE OF B-gds IN FRAME Dialog-Frame /* Товар */
DO:
  define variable v-gds-rec as recid no-undo .
  define variable glog as logical no-undo .
  define variable v-call-handle as handle no-undo .

  FIND FIRST ub.db WHERE ub.db.db-num = v-cntxt-db-num NO-LOCK .
  if not avail db then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_update':U
    {&cntxt-object}
    0
    '':U
    0
    0
    buf_goods.grp-code
    0
    true
    glog
  }
  v-gds-rec = recid (buf_goods).
  if glog AND NOT buf_goods.stts <> 0 AND db.add-goods AND NOT transaction
  then do:
    assign
    v-call-handle = ?
        .
    run ref/gds-form.w ( input parparentproc
                        ,input {&update}
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input v-call-handle
                        ,input-output v-gds-rec
                        ).
  end.
  else do:
    assign
    v-call-handle = ?
        .
    run ref/gds-form.w ( input parparentproc
                       , input {&lookup}
                       , input p-obj-type
                       , input p-obj-code
                       , input v-call-handle
                       , input-output v-gds-rec
                       ) no-error.
  end.
  FIND current buf_goods No-LOCK No-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  RUN loc-mark.
  glog = {&browse-name}:select-next-row ().
  apply "entry" to {&browse-name} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-part
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-part Dialog-Frame
ON CHOOSE OF B-part IN FRAME Dialog-Frame /* Партии */
DO:
 define variable v-prt-rec as recid no-undo .
  if avail X_parts then do:
    run str/parts-l.w
      (input parparentproc
      ,input p-obj-type               /* v-obj-type   */
      ,input p-obj-code               /* v-obj-code   */
      ,input buf_goods.gds-code            /* p-gds-code   */
      ,input ""                        /* p-doc-code   */
      ,input {&lookup}                 /* p-edit-mode  */
      ,input {&parts-l_parts-rest}     /* p-r-parts    */
      ,input {&parts-l_object-current} /* p-one-all    */
      ,input {&parts-l_call-reference} /* p-call-point */
      ,output v-prt-rec                /* part-recid   */
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'parts'
  join-tbl = 'X_parts'
  fld = '':U
  spr = '':U
  lab = '':U
  dim = '0':U
  .
  run fltfield-add in this-procedure('artic', 'Артикул', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-qnty', 'Кол-во в ед.поставщика', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('qnty', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-qnty', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('part-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
      run gbl/filter.w ( input parparentproc
                        ,input (filter-point + {&delim-par} + filter-label)
                        ,input tbl
                        ,input join-tbl
                        ,input fld
                        ,input lab
                        ,input spr
                        ,input dim).
      RUN OpenBr in this-procedure ( input yes, input no, input '':U, input paction).
  END .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-parts
&Scoped-define SELF-NAME BR-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-parts Dialog-Frame
ON DEFAULT-ACTION OF BR-parts IN FRAME Dialog-Frame
DO:
  case paction:
      when "split":U then do:
          APPLY "CHOOSE" TO b-case.
      end.
      when "fuse":U then do:
          APPLY "CHOOSE" TO b-mark.
      end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-parts Dialog-Frame
ON RETURN OF BR-parts IN FRAME Dialog-Frame
DO:
  APPLY "DEFAULT-ACTION" to br-parts.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-parts Dialog-Frame
ON VALUE-CHANGED OF BR-parts IN FRAME Dialog-Frame
DO:
  if avail X_parts then do:
    ed-notes = X_parts.PS.
    display
    ed-notes
    with frame {&frame-name}.
  end.
  else do:
      ed-notes = "".
      display
      ed-notes
      with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON ENTRY OF ED-notes IN FRAME Dialog-Frame
DO:
  APPLY "ENTRY" to br-parts.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-action
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-action Dialog-Frame
ON VALUE-CHANGED OF Rs-action IN FRAME Dialog-Frame
DO:
  assign
  rs-action
  paction = rs-action.
  run  Myenable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U, input paction).

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
{ gbl/brwrepos.i
&line-num=5 }
{ gbl/setfltnm.i }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  FIND FIRST buf_goods No-LOCK WHERE
             buf_goods.artic = partic AND
             buf_goods.prod-type = pprod-type AND
             buf_goods.prod-code = pprod-code NO-ERROR.
  IF NOT AVAIL buf_goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найден товар " partic pprod-type string(pprod-code) skip
      view-as alert-box error .
    return "error".
  END.
  assign
  for-gds = buf_goods.artic + " " + buf_goods.prod-type + string(buf_goods.prod-code) + " " + buf_goods.gds-name
  for-gds-code = buf_goods.gds-code.
  FIND FIRST ub.clients No-LOCK WHERE
             ub.clients.obj-type = p-obj-type AND
             ub.clients.obj-code = p-obj-code No-ERROR.
  IF NOT AVAIL ub.clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найден объект " p-obj-type p-obj-code skip
      view-as alert-box error .
    return "error".

  end.

  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U, input paction).
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
  DISPLAY Rs-action ED-notes for-gds for-gds-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-gds B-doc B-part B-mark B-case B-sch B-Help Rs-action
         BR-parts ED-notes for-gds for-gds-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fuse-parts Dialog-Frame
PROCEDURE fuse-parts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii as integer no-undo.
define variable glog as logical no-undo .
glog = no.
message "Вы уверены, что хотите слить отмеченные партии?"
view-as alert-box QUESTION buttons YES-NO
update glog.
if not glog then return no-apply.
_ii:
do ii = 1 to num-entries(mark-list)
ON ERROR UNDO, return error
ON STOP UNDO, return error:
    find first X_parts No-LOCK where
               recid(X_parts) = integer(entry(ii, mark-list)) NO-ERROR.
    if not avail X_parts then NEXT _ii.
    run trg/partjoin.p (
                  input X_parts.obj-type,
                  input X_parts.obj-code,
                  input X_parts.artic,
                  input X_parts.prod-type,
                  input X_parts.prod-code,
                  input X_parts.in-code,
                  input X_parts.out-code,
                  input X_parts.part-code) no-error.
    if error-status:error then do:
        message "Не удалось слить партию с номерос X_parts.part-code" skip
          error-status:get-message(1)
          view-as alert-box ERROR.
        UNDO _ii, return error.
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loc-mark Dialog-Frame
PROCEDURE loc-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if not available X_parts then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i X_parts mark-list }
  display
  string(lookup (string (recid (X_parts)), mark-list ) > 0, "*/":U)  @ mark
  with browse {&browse-name}.
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
  assign
  rs-action = paction.
  case paction:
    when "split":U then do:
      b-case:label in frame {&frame-name} = "&Коробка".
    end.
    when "fuse":U then do:
      b-case:label = "В &коробку".
    end.
  end case.
  DISPLAY ED-notes for-gds rs-action
      WITH FRAME Dialog-Frame.
  ENABLE B-exit
  /*проверим что объект живет в текущей базе данных*/
  B-case when ub.clients.db-num = v-cntxt-db-num
  RS-action
  b-mark when paction = "fuse":U
  B-sch B-gds B-doc B-Help B-part BR-parts ED-notes for-gds
      WITH FRAME Dialog-Frame.
  if paction = "split":U then
  hide b-mark in frame {&frame-name} .
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input parameter loc-action as character no-undo .
define variable l-query-was-opened as logical no-undo .
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

&scop flt-open-open-query OPEN QUERY br-parts FOR EACH X_parts NO-LOCK

&scop flt-open-dyn_open-query FOR EACH X_parts NO-LOCK

&scop flt-open-query-handle QUERY br-parts:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-debug-file

&scop flt-open-waitfram yes

CASE p-mode:
    when {&g___object} then do:
        ASSIGN frame {&frame-name}:TITLE = "Партии товаров с двумя ед.изм. на объекте " + p-obj-type + string(p-obj-code)
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один объект", filter-label0)
        .
        case paction:
          when "split":U then do:
          { gbl/fltopend.i
            &where-cond = " X_parts.artic = partic AND X_parts.prod-type = pprod-type AND X_parts.prod-code = pprod-code AND X_parts.obj-type = p-obj-type AND X_parts.obj-code = p-obj-code AND X_parts.cli-qnty > 1 AND X_parts.out-code = {&free-code} "
            &dyn_where-cond = " substitute('X_parts.artic = &1&2&1 AND X_parts.prod-type = &1&3&1 AND X_parts.prod-code = &4 AND X_parts.obj-type = &1&5&1 AND X_parts.obj-code = &6 AND X_parts.cli-qnty > 1 AND X_parts.out-code = &1&7&1 ' ~
                                 , ~{&double-quote~}, partic, pprod-type, pprod-code, p-obj-type, p-obj-code, {&free-code})"
            &use-ind = " "
            &by = "  "
          }
          end.
          when "fuse":U then do:
          { gbl/fltopend.i
            &where-cond = " X_parts.artic = partic AND X_parts.prod-type = pprod-type AND X_parts.prod-code = pprod-code AND X_parts.obj-type = p-obj-type AND X_parts.obj-code = p-obj-code AND X_parts.cli-qnty = 1 AND X_parts.out-code = {&free-code} "
            &dyn_where-cond = " substitute('X_parts.artic = &1&2&1 AND X_parts.prod-type = &1&3&1 AND X_parts.prod-code = &4 AND X_parts.obj-type = &1&5&1 AND X_parts.obj-code = &6 AND X_parts.cli-qnty = 1 AND X_parts.out-code = &1&7&1 ' ~
                                , ~{&double-quote~}, partic, pprod-type, pprod-code, p-obj-type, p-obj-code, {&free-code})"
            &use-ind = " "
            &by = "  "
          }
          end.

        end case.
    end.

END CASE.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-parts.
APPLY "ENTRY" TO br-parts.
APPLY "VALUE-CHANGED" TO br-parts.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME