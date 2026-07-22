&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-bc-form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-bc-form
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bc-form.w $
$Archive: ref/bc-form.w $

Форма работы с собственным бар-кодом

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

Author: Андрей Исаков
Created: 7.10.98

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter action        as character no-undo .
define input parameter base-bc       like ub.bar-code.b-code no-undo .
define input-output parameter rid    as recid no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bc-form.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/bc-form.w $":U .
define variable vss-description as character no-undo init "Форма работы с собственным бар-кодом".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ trg/new-bcod.i }
{ ref/send-ref.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

define buffer base-bar-code for ub.bar-code.
define buffer u-base    for ub.units.  /* для поиска базовой единицы измерения */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-bc-form

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.bar-code.b-code ub.bar-code.unit-cli ~
ub.bar-code.cli-base-rate
&Scoped-define ENABLED-TABLES ub.bar-code
&Scoped-define FIRST-ENABLED-TABLE ub.bar-code
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help r-units
&Scoped-Define DISPLAYED-FIELDS ub.bar-code.b-code ub.bar-code.unit-cli ~
ub.units.long-name ub.goods.unit-base ub.bar-code.cli-base-rate
&Scoped-define DISPLAYED-TABLES ub.bar-code ub.units ub.goods
&Scoped-define FIRST-DISPLAYED-TABLE ub.bar-code
&Scoped-define SECOND-DISPLAYED-TABLE ub.units
&Scoped-define THIRD-DISPLAYED-TABLE ub.goods


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-units
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-units"
     SIZE 3 BY .88.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-bc-form
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     ub.bar-code.b-code AT ROW 2.25 COL 15 COLON-ALIGNED FORMAT ">>>>>>>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
          FGCOLOR 4
     ub.bar-code.unit-cli AT ROW 3.54 COL 15 COLON-ALIGNED
          LABEL "Ед.изм."
          VIEW-AS FILL-IN
          SIZE 5.5 BY 1
     r-units AT ROW 3.58 COL 22.63
     ub.units.long-name AT ROW 3.58 COL 23.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 31.75 BY 1
          FGCOLOR 4
     ub.goods.unit-base AT ROW 4.92 COL 15 COLON-ALIGNED
          LABEL "Осн. ед. изм."
          VIEW-AS FILL-IN
          SIZE 5.25 BY 1
     ub.bar-code.cli-base-rate AT ROW 4.92 COL 36.5 COLON-ALIGNED FORMAT ">,>>9.9999999999"
          VIEW-AS FILL-IN
          SIZE 18.75 BY 1
     SPACE(1.49) SKIP(0.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-bc-form
                                                                        */
ASSIGN
       FRAME d-bc-form:SCROLLABLE       = FALSE
       FRAME d-bc-form:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ub.bar-code.cli-base-rate IN FRAME d-bc-form
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.units.long-name IN FRAME d-bc-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.goods.unit-base IN FRAME d-bc-form
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.bar-code.unit-cli IN FRAME d-bc-form
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-bc-form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-bc-form d-bc-form
ON GO OF FRAME d-bc-form
DO:
  /**/
  run create-bar-code no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-bc-form d-bc-form
ON WINDOW-CLOSE OF FRAME d-bc-form
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.bar-code.cli-base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.bar-code.cli-base-rate d-bc-form
ON RETURN OF ub.bar-code.cli-base-rate IN FRAME d-bc-form /* Коэффициент */
DO:
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-units d-bc-form
ON CHOOSE OF r-units IN FRAME d-bc-form /* r-units */
do:
  define variable ref-rec as recid no-undo .
  run ref/units.w
    (input parparentproc
    ,input  yes
    ,output ref-rec
    ).
  if ref-rec = ?
  then do:
    apply "entry" to r-units in frame {&frame-name}.
    return no-apply.
  end.
  find ub.units no-lock
    where recid (ub.units) = ref-rec
    .
  display
    ub.units.unit-name @ ub.bar-code.unit-cli
    ub.units.long-name
    with frame {&frame-name}.
  apply "entry" to ub.bar-code.cli-base-rate in frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.bar-code.unit-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.bar-code.unit-cli d-bc-form
ON RETURN OF ub.bar-code.unit-cli IN FRAME d-bc-form /* Ед.изм. */
DO:
  define variable ref-rec as recid no-undo .
  if not can-FIND (ub.units where ub.units.unit-name = input frame {&frame-name} ub.bar-code.unit-cli)
  then do:
    run ref/units.w ( input parparentproc
                     ,input yes
                     ,output ref-rec).
    if ref-rec = ?
    then do:
       apply "entry" to ub.bar-code.unit-cli in frame {&frame-name}.
       return no-apply.
    end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY
    ub.units.unit-name @ ub.bar-code.unit-cli
    ub.units.long-name with frame {&frame-name}.
  end.
  apply "entry" to ub.bar-code.cli-base-rate in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-bc-form


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE (ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_main-barcode_preparation':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
  }
  if v-ok <> true
  then do:
    return. /* --->>>--- */
  end.

  VIEW FRAME d-bc-form.
  find base-bar-code no-lock where
       base-bar-code.b-code = base-bc.
  find ub.goods no-lock where
       ub.goods.gds-code = base-bar-code.gds-code.
  find ub.gds-prt no-lock where
       ub.gds-prt.node-code = base-bar-code.node-code.
  if action = {&add-def}
  then do:
    ENABLE
    ub.bar-code.unit-cli
    r-units
    WITH FRAME d-bc-form.
    rid = ?. /* чтоб в вызывающей пр-ре было видно, когда нажали Отказ */
  end.
  else do:
    find ub.bar-code where recid (ub.bar-code) = rid no-error .
    if not available ub.bar-code then do:
      message
      "Запись уже отсутствует или недоступна"
      view-as alert-box warning.
      return.
    end.
  end.
  IF AVAILABLE ub.bar-code THEN
    DISP
    ub.bar-code.b-code
    ub.bar-code.unit-cli
    ub.bar-code.cli-base-rate
    WITH FRAME d-bc-form.
  find ub.units where
       ub.units.unit-name = input frame {&frame-name} ub.bar-code.unit-cli
       no-lock no-error.
  if available ub.units then
    disp
    ub.units.long-name with frame {&frame-name}.
  DISPLAY
  ub.goods.unit-base WITH FRAME d-bc-form.
  ENABLE b-exit
         b-help
         b-quit
         ub.bar-code.cli-base-rate
         WITH FRAME d-bc-form.
  frame {&frame-name}:title = "СОБСТВЕННЫЙ код              " + action.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus bar-code.cli-base-rate.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-bar-code d-bc-form
PROCEDURE create-bar-code :
define variable v-rid as recid no-undo .
run ref/barcode1.p (
                     input action
                    ,input no /*p-silent*/
                    ,input (if action = {&add-def}
                            then 0
                            else ub.bar-code.b-code)
                    ,input ub.goods.gds-code
                    ,input ub.gds-prt.node-code
                    ,input base-bar-code.part-code
                    ,input base-bar-code.in-code
                    ,input (input frame {&frame-name} ub.bar-code.unit-cli)
                    ,input (input frame {&frame-name} ub.bar-code.cli-base-rate)
                    ,output v-rid) no-error.
if error-status :error then undo, return  error .
find first bar-code where recid(bar-code) = v-rid.
if send-ref
then do:
  run str/diallog.w
    (input  parparentproc
    ,input  this-procedure
    ,input  'str/send-bc.p':U
    ,input  string(recid(ub.bar-code)) + {&delim-par} + 'U':U
    ,input  yes /* p-auto-go */
    ,input  '':U
    ,input  "Пересылка бар-кода на кассы"
    ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-bc-form  _DEFAULT-DISABLE
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
  HIDE FRAME d-bc-form.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME