&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME    d-units
&Scoped-define FRAME-NAME     d-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-units
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник единиц измерения.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

Created: 10/21/94 - 11:41 pm

*/

/* ***************************  Definitions  ************************** */
using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.

/* Parameters Definitions ---                                           */
define input parameter parparentproc as handle no-undo .
define input parameter p-mode        as character no-undo .
define input parameter p-gds-code    as integer no-undo .
define input parameter p-unit-list   as character no-undo . /* список ограничения отображаемых ЕИ через запятую */
define output parameter p-unit-name  as character no-undo .
define output parameter p-coeff      as decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник единиц измерения" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */

define variable ri as recid no-undo.
define variable glog as logical no-undo .

define variable ii as integer no-undo .
define variable v-unit-name as character no-undo .
define variable v-value as character no-undo .
define variable v-coeff as decimal no-undo .

define variable unitsObj as class unitsubs .
define variable unitObj as class unitsub .
define variable unitsObj2 as class unitsubs .
define variable unitsStr as class unitmercstr .

define buffer buf_units for ub.units .
define buffer buf_units-attr for ub.units-attr .
define buffer buf_goods for ub.goods .

define temp-table tt-units like ub.units
  field guid_ as character format "X(40)"
  field coeff as decimal 
.

define buffer buf_tt-units for tt-units .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/* ********************  Preprocessor Definitions  ******************** */

/* Name of first Frame and/or Browse (alphabetically)                   */
&Scoped-define FRAME-NAME  d-units
&Scoped-define BROWSE-NAME br-units

/* Custom List Definitions                                              */

/* Definitions for BROWSE br-units                                      */

/* Definitions for DIALOG-BOX d-units                                   */

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add-unit
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-change
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-select
     LABEL "Вы&брать":L
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "Удалить":L
     SIZE 10 BY 1.


/* Query definitions                                                    */
DEFINE QUERY br-units FOR tt-units SCROLLING.

/* Browse definitions                                                   */
DEFINE BROWSE br-units QUERY br-units NO-LOCK DISPLAY
      tt-units.unit-name
      tt-units.long-name FORMAT "X(30)"
      tt-units.coeff COLUMn-LABEL "Коэфф." format ">>>>>>>>9.<<<<<<<<"
      tt-units.guid_ column-label "GUID в ФГИС Меркурий" format "X(40)"
    WITH SEPARATORS
          &IF '{&WINDOW-SYSTEM}' = 'TTY':U &THEN SIZE 69 BY 13
          &ELSE size 90.25 by 12.58 &ENDIF
         .
         .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-units
     br-units at row 2.5 col 3
     b-exit at row 1 col 1
     b-select at row 1 col 11
     b-add-unit at row 1 col 21
     b-change at row 1 col 31
     b-del at row 1 col 41
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D
         SCROLLABLE size 93.5 by 16.25
         TITLE "ДОПОЛНИТЕЛЬНЫЕ ЕДИНИЦЫ  ИЗМЕРЕНИЯ":L.




/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-units
   UNDERLINE                                                            */
ASSIGN
       FRAME d-units:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-add-unit IN FRAME d-units
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-select IN FRAME d-units
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-help IN FRAME d-units
   NO-DISPLAY                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-units
/* Query rebuild information for BROWSE br-units
     _TblList          = "ub.units"
     _Options          = "NO-LOCK"
     _OrdList          = ""
     _FldNameList[1]   = ub.units.unit-name
     _FldNameList[2]   = ub.units.long-name
     _FldFormatList[2] = "X(30)"
     _FldNameList[3]   = "(IF (ub.units.type = """" ) THEN ("""") ELSE ({&unit-type-name}))"
     _FldLabelList[3]  = "Тип"
     _FldFormatList[3] = "x(30)"
     _Query            is OPENED
*/  /* BROWSE br-units */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add-unit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-unit d-units
ON CHOOSE OF b-add-unit IN FRAME d-units /* Добавить */
DO:
  
  run bge\units-merc.w (input parparentproc,
                        input yes,
                        output v-unit-name) .
  if v-unit-name <> ? and v-unit-name <> ""
  then do :
    find first ub.goods no-lock where ub.goods.gds-code = p-gds-code .
    if ub.goods.unit-base = v-unit-name
    then do :
      message "Данная ед. изм. совпадает с учётной." view-as alert-box .
      return no-apply . 
    end.
    find first buf_tt-units no-lock where buf_tt-units.unit-name = v-unit-name no-error .
    if available buf_tt-units
    then do :
      message "Данная ед. изм. уже добавлена." view-as alert-box .
      return no-apply .
    end.
    run gbl/d-prompt.w (
        'title=':u + "ВВЕДИТЕ КОЭФФИЦИЕНТ" + '\':u
      + 'text1=' + substitute("Коэффициент") + '\':u
      + 'format=' + ">>>>>>>>9.<<<<<<<<" + '\':u
      + 'type=' + {&type-dec} + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=30\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=no\':u
      , input-output v-value
      ).
    if v-value <> ? and v-value <> ""
    then do :
      v-coeff = decimal(v-value) no-error.
      if error-status:error
      then do :
        message "Введен неверный коэффициент" view-as alert-box .
        return no-apply .
      end.
      find first buf_units no-lock where buf_units.unit-name = v-unit-name .
      find first buf_units-attr no-lock where buf_units-attr.unit-name = v-unit-name no-error .
      create tt-units.
      assign
        tt-units.unit-name = buf_units.unit-name
        tt-units.long-name = buf_units.long-name
        tt-units.guid_     = if available buf_units-attr then buf_units-attr.attr-value else ""
        tt-units.coeff     = v-coeff
      .
      
      OPEN QUERY br-units FOR EACH tt-units exclusive-LOCK  .
    end.
  end.                      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-change
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-change d-units
ON CHOOSE OF b-change IN FRAME d-units /* Изменить */
DO:
  
  if not available tt-units then return no-apply .
  
  run gbl/d-prompt.w (
      'title=':u + "ВВЕДИТЕ КОЭФФИЦИЕНТ" + '\':u
    + 'text1=' + substitute("Коэффициент") + '\':u
    + 'format=' + ">>>>>>>>9.<<<<<<<<" + '\':u
    + 'type=' + {&type-dec} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=30\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output v-value
    ).
  if v-value <> ? and v-value <> ""
  then do :
    v-coeff = decimal(v-value) no-error.
    if error-status:error
    then do :
      message "Введен неверный коэффициент" view-as alert-box .
      return no-apply .
    end.
    assign
      tt-units.coeff     = v-coeff
    .
    br-units:refresh () .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-units
ON CHOOSE OF b-del IN FRAME d-units /* Выбрать */
DO:
  if not available tt-units then return no-apply .
  
  delete tt-units .
  
  br-units:refresh () .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-select d-units
ON CHOOSE OF b-select IN FRAME d-units /* Выбрать */
DO:
    // @FUTU вместо идент.ЕИ можно возвращать класс, содержащий выбранную единицу измерения
    if available tt-units then do:
      assign
        p-unit-name = tt-units.unit-name
        p-coeff     = tt-units.coeff
      .
      apply  "GO" to FRAME {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-units
&Scoped-define SELF-NAME br-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-units d-units
ON DEFAULT-ACTION OF br-units IN FRAME d-units
DO:
    if p-mode = {&select} then
      apply "CHOOSE":U to b-select.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-units d-units
ON RETURN OF br-units IN FRAME d-units
DO:
    if p-mode = {&select} then
      apply "CHOOSE":U to b-select.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-units
ON CHOOSE OF b-exit IN FRAME d-units /* Выбрать */
DO:
  if (p-mode <> {&select}) then do :

  find first tt-units no-lock no-error.
  if available tt-units
  then do :
    unitsObj2 = new unitsubs () .
    for each tt-units no-lock :
      unitObj = new unitsub () .
      unitObj:UnitName = tt-units.unit-name .
      unitObj:UnitFullName = tt-units.long-name .
      unitObj:UnitGuid = tt-units.guid_ .
      unitObj:UnitCoef = tt-units.coeff .
      
      unitsObj2:AddItem(unitObj) .
/*      delete object unitObj no-error .*/
    end.  
    
    unitsStr:writeDB(unitsObj2, p-gds-code) .
  end.
  else do :
    unitsStr:deleteDB(p-gds-code) .
  end.
  
  delete object unitsObj2 no-error .
  delete object unitsObj no-error .
  delete object unitsStr no-error .
  delete object unitObj no-error .
  
  end . // end_of not_mode_select    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-units


/* ***************************  Main Block  *************************** */

/* Restore the current-window if it is an icon.                         */
/* Otherwise the dialog box will be hidden                              */
IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
 { gbl/getcntxt.i get }
 
  unitsObj = new unitsubs () .
  unitsStr = new unitmercstr () . 
  
  unitsObj = unitsStr:getunitmercs(p-gds-code) .
  
  do ii = 1 to unitsObj:GetItem(ii) :
    v-unit-name = unitsObj:UnitObjCurr:UnitName .
    if p-unit-list > "" then do :
      if not can-do (p-unit-list, v-unit-name) then next .
    end .
    create tt-units .
    tt-units.unit-name  = v-unit-name .
    tt-units.long-name  = unitsObj:UnitObjCurr:UnitFullName .
    tt-units.guid_      = unitsObj:UnitObjCurr:UnitGuid .
    tt-units.coeff      = unitsObj:UnitObjCurr:UnitCoef .
  end.
  
  /* в режиме редактирования и просмотра отображаются только связанные ЕИ,
     в режиме выбора отображаются связанные ЕИ вместе с основной ЕИ товара */
  if (p-mode = {&select}) then do :
    assign
      p-unit-name = ""
      p-coeff     = 0.0
    .
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
    if available buf_goods then do :
      if not can-find (first tt-units where tt-units.unit-name = buf_goods.unit-base) then do :
        create tt-units .
        assign
          tt-units.unit-name  = buf_goods.unit-base
          tt-units.long-name  = " БАЗОВАЯ "
          tt-units.guid_      = ""
          tt-units.coeff      = 1
        .
      end .
    end .
  end .
    
  RUN enable_UI.

  if available tt-units then
      glog = br-units:select-focused-row( ).

do  on endkey undo, leave  on error undo, leave:
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
end.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-units _DEFAULT-DISABLE
PROCEDURE disable_UI :
/* --------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
   -------------------------------------------------------------------- */
  /* Hide all frames. */
  HIDE FRAME d-units.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-units
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
define variable v-is-editable as logical no-undo .
    v-is-editable = (ibs.th.gbl.gbl-var:g#db-num = 0) and
                    (p-mode <> {&lookup}) and
                    (p-mode <> {&select}) .   
    b-select:visible   IN FRAME {&frame-name} = (p-mode = {&select}) .
    ENABLE  br-units b-exit
                    b-select    WHEN b-select:visible
                    b-add-unit  when v-is-editable
                    b-change    when v-is-editable
                    b-del       when v-is-editable
        WITH FRAME d-units.
        
    OPEN QUERY br-units FOR EACH tt-units exclusive-LOCK  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE BROWSE-NAME
&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME