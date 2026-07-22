&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
Отчет по анализу параметров АРМ Кассира

Автор: Шкляр Елена
Дата создания: 09/07/05
Author: Shklyar Elena
Creation date: 09/07/05

*/

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define temp-table tt-device no-undo
  field code_    like ub.Code.code
  field codeName like ub.Code.CodeName
  index pi codeName code_
  .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по анализу параметров АРМ Кассира" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/cur-time.i }
{ gbl/tmprecid.i "new shared"}
{ gbl/cash-list.i }
{ gbl/cd-attr.i }

define temp-table tt-cash-list like cash-list .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-3 rect-4 rect-6 rect-8 SelectParam ~
choose-device SelectSource SelectDiff 
&Scoped-Define DISPLAYED-OBJECTS SelectParam choose-device SelectSource ~
SelectDiff 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-sel-cash DEFAULT 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "":L 
  SIZE 2.5 BY 1.08.

DEFINE BUTTON b-sel-param DEFAULT 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "":L 
  SIZE 2.5 BY 1.08.

DEFINE VARIABLE SelectDiff   AS CHARACTER 
  VIEW-AS RADIO-SET VERTICAL
  RADIO-BUTTONS 
  "Все кассы", "all":U,
  "Выбор кассы", "select":U
  SIZE 32.5 BY 1.54 NO-UNDO.

DEFINE VARIABLE SelectParam  AS CHARACTER 
  VIEW-AS RADIO-SET VERTICAL
  RADIO-BUTTONS 
  "Все параметры", "all":U,
  "Параметры с расхождениями", "diff":U,
  "Обязательные параметры", "mandatory":U,
  "Необязательные параметры", "optional":U,
  "Выбор параметров", "choose":U
  SIZE 30.63 BY 3.25 NO-UNDO.

DEFINE VARIABLE SelectSource AS CHARACTER 
  VIEW-AS RADIO-SET VERTICAL
  RADIO-BUTTONS 
  "Все", "all":U,
  "Параметры", "param":U,
  "Клавиатура", "keyboard":U
  SIZE 30.63 BY 2.5 NO-UNDO.

DEFINE RECTANGLE rect-3
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
  SIZE 37.25 BY 4.79.

DEFINE RECTANGLE rect-4
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
  SIZE 37.25 BY 11.5.

DEFINE RECTANGLE rect-6
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
  SIZE 37 BY 3.

DEFINE RECTANGLE rect-8
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
  SIZE 37.13 BY 3.75.

DEFINE VARIABLE choose-device AS CHARACTER INITIAL "-1" 
  VIEW-AS SELECTION-LIST MULTIPLE SCROLLBAR-VERTICAL 
  SIZE 35.5 BY 9.88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
  SelectParam AT ROW 2.5 COL 2.75 NO-LABEL
  choose-device AT ROW 2.63 COL 39.63 NO-LABEL WIDGET-ID 10
  b-sel-param AT ROW 4.83 COL 35.13 WIDGET-ID 80
  SelectSource AT ROW 7 COL 2.88 NO-LABEL WIDGET-ID 64
  SelectDiff AT ROW 11.04 COL 2.88 NO-LABEL WIDGET-ID 54
  b-sel-cash AT ROW 11.5 COL 35.13 WIDGET-ID 82
  "Выбор по обязательности" VIEW-AS TEXT
  SIZE 31.25 BY .79 AT ROW 1.42 COL 2.63
  FGCOLOR 4 
  "Выбор признака исполнения касссы" VIEW-AS TEXT
  SIZE 32.88 BY .79 AT ROW 1.46 COL 39.88 WIDGET-ID 50
  FGCOLOR 4
  "Выбор источника" VIEW-AS TEXT
  SIZE 31.25 BY .79 AT ROW 6.13 COL 2.75 WIDGET-ID 70
  FGCOLOR 4 
  "По наличию расхождений" VIEW-AS TEXT
  SIZE 31.25 BY .79 AT ROW 9.96 COL 2.75 WIDGET-ID 60
  FGCOLOR 4  
  rect-3 AT ROW 1.21 COL 1.25
  rect-4 AT ROW 1.25 COL 38.75 WIDGET-ID 42
  rect-6 AT ROW 9.75 COL 1.5 WIDGET-ID 52
  rect-8 AT ROW 6 COL 1.38 WIDGET-ID 62
  WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
  SIDE-LABELS NO-UNDERLINE THREE-D 
  AT COL 1 ROW 1
  SIZE 75 BY 12.08.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links: 
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 12.08
         WIDTH              = 75.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win 
/* ************************* Included-Libraries *********************** */
{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR BUTTON b-sel-cash IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-sel-param IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-sel-cash
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-cash F-Frame-Win
ON CHOOSE OF b-sel-cash IN FRAME F-Main
  DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
    define variable ii         as integer   no-undo .
    define buffer buf_cash-desk for ub.cash-desk.
    assign SelectDiff.
    for each tt-cash-list:
      delete tt-cash-list.
    end.
    run ref/cashlist.w (input my-handle
      ,INPUT "b-sel,b-mark"
      ,INPUT {&all}
      ,INPUT v-cntxt-db-num
      ,INPUT v-cntxt-host-code-obj
      ,INPUT {&shop}
      ,INPUT v-cntxt-obj-code
      ,INPUT ?
      ,OUTPUT v-rid-list) NO-ERROR.
    IF error-status:error
      OR v-rid-list = '':U THEN 
    DO:
      RETURN no-apply.
    END.
    do ii = 1 to num-entries(v-rid-list):
      find first buf_cash-desk no-lock where
        recid(buf_cash-desk) = integer(entry(ii, v-rid-list)) no-error .
      if available buf_cash-desk and buf_cash-desk.autonomy <> integer({&cd-slave}) then  
      do:
        CREATE tt-cash-list.
        buffer-copy buf_cash-desk to tt-cash-list.
      end.
    end.        

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-param F-Frame-Win
ON CHOOSE OF b-sel-param IN FRAME F-Main
  DO:
    empty temp-table tmprecid .
    run ref/cashpargroup.w ( input  my-handle
      ,input  {&select}
      ,input  ""
      ,input "cash-param"
      ,input ?
      ) .
                         
    find first tmprecid no-lock where tmprecid.fTable = "code" no-error .
    if not available tmprecid then 
    do:
      message
        "В списке нет ни одного параметра"
        view-as alert-box WARNING.
      SelectParam = "all" .
      display SelectParam with frame F-Main .
    end.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME choose-device
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL choose-device F-Frame-Win
ON VALUE-CHANGED OF choose-device IN FRAME F-Main
  DO:
    assign choose-device .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectDiff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectDiff F-Frame-Win
ON VALUE-CHANGED OF SelectDiff IN FRAME F-Main
  DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
    define variable ii         as integer   no-undo .
    define buffer buf_cash-desk for ub.cash-desk.
    assign SelectDiff.
    for each tt-cash-list:
      delete tt-cash-list.
    end.
    case SelectDiff:
      when "all" then 
        do:
          disable b-sel-cash with frame {&frame-name} .
          for each obj-list:
            for each cash-desk where cash-desk.obj-code = obj-list.obj-code and cash-desk.is-del = false and cash-desk.autonomy <> integer({&cd-slave}):
              buffer-copy cash-desk to tt-cash-list .
            end.  
          end. 
        end.
      otherwise 
      do:
        enable b-sel-cash with frame {&frame-name} .
        run ref/cashlist.w (input my-handle
          ,INPUT "b-sel,b-mark"
          ,INPUT {&all}
          ,INPUT v-cntxt-db-num
          ,INPUT v-cntxt-host-code-obj
          ,INPUT {&shop}
          ,INPUT v-cntxt-obj-code
          ,INPUT ?
          ,OUTPUT v-rid-list) NO-ERROR.
        IF error-status:error
          OR v-rid-list = '':U THEN 
        DO:
          message "Кассы не выбраны"
            view-as alert-box WARNING.
          SelectDiff = "all" .
          display SelectDiff with frame F-Main .
          disable b-sel-cash with frame {&frame-name} .
  for each obj-list:
    for each cash-desk where cash-desk.obj-code = obj-list.obj-code and cash-desk.is-del = false and cash-desk.autonomy <> integer({&cd-slave}):
      find first tt-cash-list where tt-cash-list.obj-code = cash-desk.obj-code and tt-cash-list.db-num = cash-desk.db-num and
        tt-cash-list.pos-type = cash-desk.pos-type and tt-cash-list.cash-num = cash-desk.cash-num no-error .
      if not available (tt-cash-list) then 
      do:
        create tt-cash-list.
        buffer-copy cash-desk to tt-cash-list .
      end.
    end.  
  end.          
        END.
        do ii = 1 to num-entries(v-rid-list):
          find first buf_cash-desk no-lock where
            recid(buf_cash-desk) = integer(entry(ii, v-rid-list)) no-error .
          if available buf_cash-desk and buf_cash-desk.autonomy <> integer({&cd-slave}) then 
          do:
            CREATE tt-cash-list.
            buffer-copy buf_cash-desk to tt-cash-list.
          end.
        end.        
      end. 
    end case .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectParam
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectParam F-Frame-Win
ON VALUE-CHANGED OF SelectParam IN FRAME F-Main
  DO:
    assign SelectParam.
    case SelectParam:
      when "choose":u then 
        do:
          enable b-sel-param with frame {&frame-name} .
          for each tmprecid exclusive-lock where tmprecid.fTable = "code":
            delete tmprecid .
        end.
          run ref/cashpargroup.w ( input  my-handle
            ,input  {&select}
            ,input  ""
            ,input "cash-param"
            ,input ?
            ) .
                         
          find first tmprecid no-lock where tmprecid.fTable = "code" no-error .
          if not available tmprecid then 
          do:
            message
              "В списке нет ни одного параметра"
              view-as alert-box WARNING.
            SelectParam = "all" .
            display SelectParam with frame F-Main .
            disable b-sel-param with frame {&frame-name} .
          end.
        end.
      otherwise 
      do:
        disable b-sel-param with frame {&frame-name} .
      end.
    end case.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectSource
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectSource F-Frame-Win
ON VALUE-CHANGED OF SelectSource IN FRAME F-Main
  DO:
    assign SelectSource.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win 
for each tt-cash-list:
  delete tt-cash-list.
end.
run inifields .

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
/* Now enable the interface  if in test mode - otherwise this happens when
   the object is explicitly initialized from its container. */
run dispatch in this-procedure ('initialize':u).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY SelectParam choose-device SelectSource SelectDiff 
    WITH FRAME F-Main.
  ENABLE rect-3 rect-4 rect-6 rect-8 SelectParam choose-device SelectSource 
    SelectDiff 
    WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inifields F-Frame-Win 
PROCEDURE inifields :
  /*------------------------------------------------------------------------------
          Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
        ------------------------------------------------------------------------------*/
  define variable mdevice as class ibs.th.str.cash.CashDevice
    no-undo.
  mdevice = new ibs.th.str.cash.CashDevice().
  define variable objType    as ibs.th.gbl.propmap no-undo.
  define variable kk as integer no-undo .
  
  do kk = 1 to mdevice:mapType:GetItem(kk):
    objType = mdevice:CurrProp.
    create tt-device .
    assign
      tt-device.code_    = string(objType:KeyIntDB)
      tt-device.codeName = objType:Label_
      .
  end.      

  choose-device:list-item-pairs in frame {&frame-name} = "ВСЕ,-1" .
  for each tt-device no-lock by tt-device.code_:

    assign
      choose-device :list-item-pairs = substitute( "&2&1&3&1&4"
                                       , ","
                                       , choose-device :list-item-pairs
                                       , tt-device.codeName
                                       , tt-device.code_) no-error   .
    if error-status:error then leave .
  end.
 
  for each obj-list:
    for each cash-desk where cash-desk.obj-code = obj-list.obj-code and cash-desk.is-del = false and cash-desk.autonomy <> integer({&cd-slave}):
      find first tt-cash-list where tt-cash-list.obj-code = cash-desk.obj-code and tt-cash-list.db-num = cash-desk.db-num and
        tt-cash-list.pos-type = cash-desk.pos-type and tt-cash-list.cash-num = cash-desk.cash-num no-error .
      if not available (tt-cash-list) then 
      do:
        create tt-cash-list.
        buffer-copy cash-desk to tt-cash-list .
      end.
    end.  
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win 
PROCEDURE local-initialize :
  /*------------------------------------------------------------------------------
        Purpose:     Override standard ADM method
        Notes:
      ------------------------------------------------------------------------------*/
  /* Code placed here will execute PRIOR to standard behavior. */
  /* Dispatch standard ADM method.                             */
  run dispatch in this-procedure ( input 'initialize':u ) .
/* Code placed here will execute AFTER standard behavior.    */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win 
PROCEDURE My-report :
define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define buffer buf_cash-desk-attr for ub.cash-desk-attr .
  define variable kk as integer no-undo .
  empty temp-table cash-list .
  for each tt-cash-list:
/*      find first buf_cash-desk-attr no-lock                                             */
/*       where buf_cash-desk-attr.db-num   = tt-cash-list.db-num                          */
/*         and buf_cash-desk-attr.obj-code = tt-cash-list.obj-code                        */
/*         and buf_cash-desk-attr.pos-type = tt-cash-list.pos-type                        */
/*         and buf_cash-desk-attr.cash-num = tt-cash-list.cash-num                        */
/*         and buf_cash-desk-attr.upper-attr-code = tt-cash-list.pos-type + "_operative":U*/
/*         and buf_cash-desk-attr.attr-code       = "device-kind":U no-error .            */
/*  if available buf_cash-desk-attr then                                                  */
/*       tt-cash-list.deviceCode = string(buf_cash-desk-attr.attr-value-integer) .        */
/*  else tt-cash-list.deviceCode = "0" .                                                  */
    create cash-list .
    buffer-copy tt-cash-list to cash-list .   
  end.
  
  if choose-device <> "-1" then 
  do:
    for each cash-list : 
      if lookup(string(cash-list.deviceCode), choose-device, ",") = 0 then
      delete cash-list .
    end.
  end.
  run rep/cash-param.p (
    input my-handle,
    input choose-device,
    input SelectParam,
    input SelectSource,
    input table tmprecid,
    input table cash-list
    ).

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var F-Frame-Win 
PROCEDURE my-var :
  .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

