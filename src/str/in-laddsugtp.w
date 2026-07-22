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

Экран просмотра технологических потерь по приемке СУГ

Автор: Ростовцев Александр Михайлович
Дата создания: 16/07/2024
Author: Alexandr Rostovtsev
Creation date: 16/07/2024

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра дополнительной информации по приемке топлива".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/trdcalib.i }
{ cmp/showinf.i  }
{ str/attrlist.i }
{ str/placelib.i}
{ gbl/cur-time.i }
{ gbl/ptrlprop.i def}
{ gbl/getsect.i def }
{ gbl/color.i    }

/* Parameters Definitions ---                                            */
define input parameter parparentproc as handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-doc-code like ub.trn-doc.doc-code   no-undo .
define input parameter table for tt-upd-attr-fuel .

define variable v-log as logical no-undo .
define variable v-autoent-obj-type as character no-undo.
define variable v-autoent-obj-code as integer no-undo.
define variable v-last-gds-code like ub.goods.gds-code no-undo .
define variable varrec-id as recid no-undo.
define variable v-no-news as logical   no-undo init false .

define variable pomi-licvalue   as character no-undo.
define variable pomi-lictype    as character no-undo.
define variable v-avai-acc-ship as logical no-undo.
define stream outstream.

define variable rdc-dnstvalue as character no-undo.
define variable rdc-dnsttype  as character no-undo.
   
define variable v-dop-info as character  no-undo .
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
define variable v-is-lgas as logical no-undo.

/* Local Variable Definitions ---                                       */
{ str/valddnst.i def }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-quit b-help f-massa-sug f-teh-loss ~
f-err-allow 
&Scoped-Define DISPLAYED-OBJECTS f-massa-sug f-teh-loss f-err-allow ~
FILL-IN-num-hoses 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getNunHoses Dialog-Frame 
FUNCTION getNunHoses RETURNS INTEGER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help 
     LABEL "&Помощь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-err-allow AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL ? 
     LABEL "Допустимые погрешности всех не финальных сливов" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-massa-sug AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL ? 
     LABEL "Суммарная масса всех не финальных сливов СУГ" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-teh-loss AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL ?
     LABEL "Технологические потери всех не финальных сливов" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-hoses AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Кол-во подключений рукавов" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 2.2
     b-quit AT ROW 1 COL 12.2
     b-help AT ROW 1 COL 66
     f-massa-sug AT ROW 2.43 COL 57 COLON-ALIGNED WIDGET-ID 152
     f-teh-loss AT ROW 3.62 COL 57 COLON-ALIGNED WIDGET-ID 154
     f-err-allow AT ROW 4.81 COL 57 COLON-ALIGNED WIDGET-ID 156
     f-num-hoses AT ROW 6 COL 57 COLON-ALIGNED WIDGET-ID 158
     "кг" VIEW-AS TEXT
          SIZE 3.2 BY .62 AT ROW 5 COL 73.8 WIDGET-ID 164
     "кг" VIEW-AS TEXT
          SIZE 3.2 BY .62 AT ROW 3.81 COL 73.8 WIDGET-ID 162
     "кг" VIEW-AS TEXT
          SIZE 4.2 BY .62 AT ROW 2.62 COL 73.8 WIDGET-ID 160
     SPACE(0.99) SKIP(5.13)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Расчет технологических потерь"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
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

/* SETTINGS FOR FILL-IN FILL-IN-num-hoses IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Расчет технологических потерь */
DO: 
  if p-mode <> {&lookup} then
  do: 
    assign frame {&frame-name}  
      f-massa-sug
      f-teh-loss
      f-err-allow
    .
    if f-massa-sug = ? or
       f-teh-loss  = ? or
       f-err-allow = ? then
    do:
      message "Данные не заполнены. Сохранение невозможно." 
        view-as alert-box error title "Ошибка".
      return no-apply. 
    end.
    run save-attr.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Расчет технологических потерь */
DO:
  APPLY "END-ERROR":U TO SELF.
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
  
  define buffer buf_doc-attr for ub.doc-attr.
  
  { str/tdat-val.i
     p-doc-code
     {&sugtpattr-massa-sug}
     varvalue
     vartype
     no-error
  }
  f-massa-sug = if varvalue = "" then ? else dec(varvalue).
  
  { str/tdat-val.i
     p-doc-code
     {&sugtpattr-teh-loss}
     varvalue
     vartype
     no-error
  }
  f-teh-loss = if varvalue = "" then ? else dec(varvalue).
  
  { str/tdat-val.i
     p-doc-code
     {&sugtpattr-err-allow}
     varvalue
     vartype
     no-error
  }
  f-err-allow = if varvalue = "" then ? else dec(varvalue).
  f-num-hoses = getNunHoses().
  
  RUN enable_UI.
  if p-mode = {&lookup} then
  disable 
    f-massa-sug
    f-teh-loss
    f-err-allow
    with frame {&frame-name}
  .
  /*
  display
    f-massa-sug
    f-teh-loss
    f-err-allow
    with frame {&frame-name}
  .
  */
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
  DISPLAY f-massa-sug f-teh-loss f-err-allow f-num-hoses 
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-quit b-help f-massa-sug f-teh-loss f-err-allow 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc1 Dialog-Frame 
PROCEDURE proc1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc2 Dialog-Frame 
PROCEDURE proc2 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-attr Dialog-Frame 
PROCEDURE save-attr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-attr-value as character no-undo.
  define buffer buf_doc-attr for ub.doc-attr.
  
  do transaction:
    _LABEL_FOR:
    for each tt-upd-attr-fuel no-lock:
      v-attr-value = ? .
      case tt-upd-attr-fuel.code:
        when {&sugtpattr-massa-sug} then
          v-attr-value = string(f-massa-sug).
        when {&sugtpattr-teh-loss} then
          v-attr-value = string(f-teh-loss).
        when {&sugtpattr-err-allow} then
          v-attr-value = string(f-err-allow).
        otherwise
          next _LABEL_FOR.            
      end case.
      
      find first buf_doc-attr
        where buf_doc-attr.doc-code  = p-doc-code
          and buf_doc-attr.attr-code = tt-upd-attr-fuel.code
        no-error .
      if v-attr-value <> ? 
      then do:
        if not available buf_doc-attr
            then do:
              create buf_doc-attr.
              assign
                buf_doc-attr.doc-code   = p-doc-code
                buf_doc-attr.attr-code = tt-upd-attr-fuel.code.
            end.
        
        { str/tdat-wrt.i
            buf_doc-attr.doc-code
            buf_doc-attr.attr-code
            v-attr-value
            no-error
        }
        if error-status :error then do:
            message "Ошибка при сохранении атрибута." view-as alert-box.
            undo, return no-apply.
        end.
      end.
      else do:
        if available buf_doc-attr then delete buf_doc-attr.
      end.
      
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getNunHoses Dialog-Frame 
FUNCTION getNunHoses RETURNS INTEGER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
/*  {&place-com-vessel}*/
  define variable vGateValve as character no-undo.  
  define variable vOk        as logical   no-undo.  
  define variable vNumHoses  as integer   no-undo init 0.  
    
  define buffer buf_doc-pl        for ub.doc-pl.
  define buffer buf_place         for ub.place.
  define buffer buf_doc-line      for ub.doc-line.
  define buffer buf_goods         for ub.goods.
  define buffer buf_doc-line-attr for ub.doc-line-attr.
  
/*  run gbl/inidebug.p.*/
  find first buf_doc-pl where
             buf_doc-pl.out-code = p-doc-code
       no-lock no-error.
  if avail buf_doc-pl then
    find first buf_place where
               buf_place.obj-type = buf_doc-pl.obj-type
           and buf_place.obj-code = buf_doc-pl.obj-code
           and buf_place.pl-code  = buf_doc-pl.pl-code
           no-lock no-error.
  if avail buf_place then do:
      run placelib_get-attr  ( 
        input {&place-gate-valve}
       ,input buf_place.obj-code
       ,input buf_place.obj-type
       ,input buf_place.pl-code
       ,output vGateValve
       ,output vOk      
      ) no-error.
     if not vOk or not logical(vGateValve) then
       vNumHoses = 1. 
     else do:
       for first buf_doc-line where  
                 buf_doc-line.doc-code = p-doc-code 
           no-lock,
           first buf_goods where 
                 buf_goods.artic     =  buf_doc-line.artic
             and buf_goods.prod-code =  buf_doc-line.prod-code
             and buf_goods.prod-type =  buf_doc-line.prod-type 
           no-lock,
           first buf_doc-line-attr where
                 buf_doc-line-attr.doc-code  = p-doc-code   
             and buf_doc-line-attr.gds-code  = buf_goods.gds-code
             and buf_doc-line-attr.attr-code = "connect-hoses"
           no-lock:
         vNumHoses = if buf_doc-line-attr.attr-value = "yes" then 1 else 0. /* согласно  ТЗ "Доработка отчетных форм СУГ" (09.12.2024) */ 
       end.         
     end.
  end. 

  RETURN vNumHoses.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

