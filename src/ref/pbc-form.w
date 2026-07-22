&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-bc-form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-bc-form

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма работы с дополнительным бар-кодом

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/11/06
Author: Bakhtadze Natalya
Creation date: 04/11/06

Автор1: Исаков Андрей Валерьевич
Дата создания: 10/07/98
Author: Andrew Isakoff
Creation date: 10/07/98

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter parparentproc as   widget-handle      no-undo .
define input        parameter p-mode        as character            no-undo .
define input        parameter bc            like ub.bar-code.b-code no-undo .
define input        parameter par-shbl      like ub.prod-bc.b-str   no-undo .
define input        parameter par-EAN       as   logical            no-undo .
define input        parameter p-cdrg-type   as character no-undo .
define input-output parameter rid           as   recid              no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Форма работы с дополнительным бар-кодом":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }


/* Local Variable Definitions ---                                       */

define variable dops        as character no-undo format "X(250)":U.
define variable dopst       as character no-undo format "X(1)":U.
{ ref/send-ref.i dops dopst }


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-bc-form

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES bar-code prod-bc units goods

/* Definitions for DIALOG-BOX d-bc-form                                 */
&Scoped-define QUERY-STRING-d-bc-form FOR EACH bar-code SHARE-LOCK, ~
      EACH prod-bc OF ub.bar-code SHARE-LOCK, ~
      EACH units WHERE TRUE /* Join to bar-code incomplete */ SHARE-LOCK, ~
      EACH goods OF ub.bar-code SHARE-LOCK
&Scoped-define OPEN-QUERY-d-bc-form OPEN QUERY d-bc-form FOR EACH bar-code SHARE-LOCK, ~
      EACH prod-bc OF ub.bar-code SHARE-LOCK, ~
      EACH units WHERE TRUE /* Join to bar-code incomplete */ SHARE-LOCK, ~
      EACH goods OF ub.bar-code SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-bc-form bar-code prod-bc units goods
&Scoped-define FIRST-TABLE-IN-QUERY-d-bc-form bar-code
&Scoped-define SECOND-TABLE-IN-QUERY-d-bc-form prod-bc
&Scoped-define THIRD-TABLE-IN-QUERY-d-bc-form units
&Scoped-define FOURTH-TABLE-IN-QUERY-d-bc-form goods


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.bar-code.unit-cli ~
ub.bar-code.cli-base-rate
&Scoped-define ENABLED-TABLES ub.bar-code
&Scoped-define FIRST-ENABLED-TABLE ub.bar-code
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help
&Scoped-Define DISPLAYED-FIELDS ub.bar-code.unit-cli ub.units.long-name ~
ub.goods.unit-base ub.bar-code.cli-base-rate
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

DEFINE VARIABLE t-EAN AS LOGICAL INITIAL no
     LABEL "Только EAN"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .83 NO-UNDO.

DEFINE VARIABLE t-NEdeMark AS LOGICAL INITIAL no 
     LABEL "Требуется  маркировка" 
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY d-bc-form FOR
      ub.bar-code,
      ub.prod-bc,
      ub.units,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-bc-form
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     t-EAN AT ROW 2.5 COL 17
     t-NEdeMark AT ROW 2.5 COL 31
     ub.prod-bc.b-str AT ROW 3.67 COL 15 COLON-ALIGNED FORMAT "X(40)"
          VIEW-AS FILL-IN
          SIZE 41.5 BY 1
          FGCOLOR 4
     ub.bar-code.unit-cli AT ROW 4.96 COL 15 COLON-ALIGNED
          LABEL "Ед.изм."
          VIEW-AS FILL-IN
          SIZE 5.5 BY 1
     ub.units.long-name AT ROW 5 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 34.63 BY 1
          FGCOLOR 4
     ub.goods.unit-base AT ROW 6.25 COL 15.13 COLON-ALIGNED
          LABEL "Осн. ед. изм."
          VIEW-AS FILL-IN
          SIZE 5.25 BY 1
     ub.bar-code.cli-base-rate AT ROW 6.33 COL 35.13 COLON-ALIGNED FORMAT ">,>>9.9999999999"
          VIEW-AS FILL-IN
          SIZE 21.63 BY 1
     SPACE(3.49) SKIP(0.58)
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

/* SETTINGS FOR FILL-IN ub.prod-bc.b-str IN FRAME d-bc-form
   NO-DISPLAY NO-ENABLE EXP-FORMAT                                      */
/* SETTINGS FOR FILL-IN ub.bar-code.cli-base-rate IN FRAME d-bc-form
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.units.long-name IN FRAME d-bc-form
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX t-EAN IN FRAME d-bc-form
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX t-NEdeMark IN FRAME d-bc-form
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN ub.goods.unit-base IN FRAME d-bc-form
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.bar-code.unit-cli IN FRAME d-bc-form
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-bc-form
/* Query rebuild information for DIALOG-BOX d-bc-form
     _TblList          = "bar-code,prod-bc OF bar-code,units WHERE bar-code ...,goods OF bar-code"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX d-bc-form */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-bc-form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-bc-form d-bc-form
ON GO OF FRAME d-bc-form
DO:
  run create-bar-code in this-procedure no-error .
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


&Scoped-define SELF-NAME ub.prod-bc.b-str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.prod-bc.b-str d-bc-form
ON RETURN OF ub.prod-bc.b-str IN FRAME d-bc-form /* Бар-код */
DO:
  apply "entry" to ub.bar-code.unit-cli in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME prod-bc.b-str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL prod-bc.b-str d-bc-form
ON leave OF prod-bc.b-str IN FRAME d-bc-form /* Бар-код */
DO:
    define variable VTXT as char no-undo.
    define variable vGtin as int64 no-undo.
    if p-cdrg-type  eq {&gtin}
    then do:
        vTXt = prod-bc.b-str:screen-value.
      if    length(vtxt) > 14
      then do:  
         if    (length(vtxt) eq 14 + 7 + 4 + 4
             or length(vtxt) eq 14 + 7 + 4 )
         then 
            prod-bc.b-str:screen-value = substring(vtxt,1,14).
         else if vtxt begins "01"
         then
            prod-bc.b-str:screen-value = substring(vtxt,3,14).
         else do:
            /*int(substring(vtxt,1,2)) no-error.
            prod-bc.b-str:screen-value = if error-status:error
                                         then substring(vtxt,3,14)
                                         else substring(vtxt,1,14).
          */
         end.
      end.    
   end. 
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
   VIEW FRAME d-bc-form.
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
  find ub.bar-code no-lock
    where ub.bar-code.b-code = bc
    .
  if ub.bar-code.stts_ = integer({&hn-delete})
  or ub.bar-code.stts_ = integer({&hn-switch-off})
  then do:
    message
    substitute("Собственный бар-код &1 заблокирован для удаления или логически удален", ub.bar-code.b-code) skip
    "Редактирование/добавление невозможно"
    view-as alert-box error .
    undo main-block, return error .
  end.
  find ub.goods no-lock
    where ub.goods.gds-code = ub.bar-code.gds-code
    .
  find ub.units no-lock
    where ub.units.unit-name = ub.bar-code.unit-cli
    .
  if p-mode = {&update} then do:  
  find first ub.prod-bc no-lock
    where ub.prod-bc.b-code = bc and ub.prod-bc.b-str = par-shbl
    .   
  end.
  assign
    t-EAN = p-cdrg-type ne {&Gtin}
    t-NEDEMark = no
  .
  if p-mode = {&add-def} then do:
     t-NEdeMark = no .
  end.
  else do:
     display ub.prod-bc.b-str with frame {&frame-name} .
      find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = ub.prod-bc.b-str and 
         buf_prod-bc-attr.b-code = ub.prod-bc.b-code and buf_prod-bc-attr.attr-code = {&mark} no-error .
      if available (buf_prod-bc-attr) then t-NEdeMark = logical(buf_prod-bc-attr.attr-value).
      else t-NEdeMark = no .
  end.       
  display
    ub.bar-code.unit-cli
    t-EAN when p-cdrg-type ne {&Gtin}
    t-NEDEMark when p-cdrg-type ne {&Gtin}
    ub.bar-code.cli-base-rate
    ub.units.long-name
    ub.goods.unit-base
    with frame {&frame-name}.
   if p-mode <> {&update} then do:    
  enable
    ub.prod-bc.b-str
    t-EAN when p-cdrg-type ne {&Gtin}
    t-NEDEMark when p-cdrg-type ne {&Gtin}
    b-exit
    b-help
    b-quit
    with frame {&frame-name} .
  end.
  else do:
  enable
    t-NEDEMark when p-cdrg-type ne {&Gtin}
    b-exit
    b-help
    b-quit
    with frame {&frame-name} .
  end.     
  if p-mode = {&add-def} then do:
  if par-EAN = no
  then do:
    assign
      t-ean = no
    .
    display
      t-EAN when p-cdrg-type ne {&Gtin}
      with frame {&frame-name} .
  end.
  end.
  if p-cdrg-type eq {&Gtin} 
  then assign
     t-EAN:visible = no
     t-NEDEMark:visible = no.
  else do:
     if p-mode = {&add-def} then 
     do:
        define buffer buf_prod-bc  for prod-bc.
        define buffer buf_gtin_bar for bar-code.
        /*      t-NEdeMark:visible = no.*/
        for each buf_gtin_bar where buf_gtin_bar.gds-code  = ub.goods.gds-code
           and can-find (first buf_prod-bc
           where buf_prod-bc.b-code =  buf_gtin_bar.b-code
           and buf_prod-bc.bc-on-type = {&GTIN} )
           no-lock:
           t-NEdeMark = yes.
        end.
        t-NEdeMark:visible = yes. 
        disp t-NEdeMark with frame {&frame-name} .
     end.          
  end.    
  if par-shbl <> ""
  then do:
    display
      par-shbl @ ub.prod-bc.b-str
      with frame {&frame-name} .
  end.


  /* присвоим коду неопределенное значение */
  /* чтобы в вызывающей процедуре было видно, когда нажали Отказ */
  assign
    rid = ?
  .
  assign frame {&frame-name} :title = "ДОПОЛНИТЕЛЬНЫЙ " + (if p-cdrg-type eq {&Gtin} then {&Gtin} + "                " else "бар-код                ") + p-mode.

  wait-for go of frame {&frame-name}  focus ub.prod-bc.b-str.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-bar-code d-bc-form 
PROCEDURE create-bar-code :
   define variable v-b-str as character no-undo .
   define buffer buf_prod-bc for ub.prod-bc.
   define variable v-send as logical no-undo .
   v-b-str = input frame {&frame-name} ub.prod-bc.b-str.
   ASSIGN frame {&frame-name} t-NEdeMark.
   rid = ?.
   if p-mode = {&add-def} then 
   do:
      run trg/prod-bc2.p (
         input  parparentproc
         ,input no /*p-silent*/
         ,input no /* dif-pdbc */
         ,input no /*pbc-veto*/
         ,input send-ref
         ,input p-cdrg-type
         ,input (if logical(t-EAN:screen-value) then "EAN" else "")
         ,buffer goods
         ,input bar-code.b-code
         ,input logical(t-NEDEMark:screen-value)
         ,input-output v-b-str
         ,output rid
         ) no-error.
      if error-status :error
         or rid = ? then 
      do:
         apply "entry" to ub.prod-bc.b-str in frame {&frame-name}.
         undo, return error return-value .
      end.
      else 
      do:
         find first buf_prod-bc no-lock
            where recid(buf_prod-bc) = rid.
         if  buf_prod-bc.bc-on
            and send-ref
            then 
         do:
            run str/diallog.w
               (input parparentproc
               ,input this-procedure
               ,input 'str/s-prodbc.p':U
               ,input string(rid) + {&delim-par} + "U":U
               ,input yes /*p-auto-go*/
               ,input '':U
               ,input "Пересылка ДопБК на кассы"
               ) .
         end.
      end.
   end.
   else 
   do:
      if t-NEdeMark 
         then 
      do:
         find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = ub.prod-bc.b-str and 
            buf_prod-bc-attr.b-code = ub.prod-bc.b-code and buf_prod-bc-attr.attr-code = {&mark} no-error .
         if available (buf_prod-bc-attr) then 
         do:
            if logical (buf_prod-bc-attr.attr-value) <> t-NEdeMark then v-send = true .
            buf_prod-bc-attr.attr-value = "yes" .
         end.
         else 
         do:
            create buf_prod-bc-attr.
            assign
               buf_prod-bc-attr.b-str      = ub.prod-bc.b-str
               buf_prod-bc-attr.b-code     = ub.prod-bc.b-code
               buf_prod-bc-attr.attr-code  = {&mark}
               buf_prod-bc-attr.attr-value = "yes"
               .
            v-send = true .
         end.
      end.   
      else 
      do:
         find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = ub.prod-bc.b-str and 
            buf_prod-bc-attr.b-code = ub.prod-bc.b-code and buf_prod-bc-attr.attr-code = {&mark} no-error .
         if available (buf_prod-bc-attr) then 
         do: 
            delete buf_prod-bc-attr . 
            v-send = true . 
         end.
      end. 
      if v-send then 
      do:  
         rid = recid(ub.prod-bc) .
         find first buf_prod-bc no-lock
            where recid(buf_prod-bc) = rid.
         if  buf_prod-bc.bc-on
            and send-ref
            then 
         do:
            run str/diallog.w
               (input parparentproc
               ,input this-procedure
               ,input 'str/s-prodbc.p':U
               ,input string(rid) + {&delim-par} + "U":U
               ,input yes /*p-auto-go*/
               ,input '':U
               ,input "Пересылка ДопБК на кассы"
               ) .
         end.
      end.
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

