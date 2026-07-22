&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товары ЕГАИС

Автор: Шкляр Елена 
Дата создания: 01/16/07
Author: Elena Shklyar
Creation date: 01/16/07
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.bge.egais.*.
/* Parameters Definitions ---                                           */

define input  parameter parparentproc as handle no-undo.
define input  parameter p-mode     as character   no-undo.
define input-output  parameter p-alc-code as character   no-undo.
define input-output parameter p-gds-code like ub.goods.gds-code  no-undo.
define output parameter p-gds-name like ub.goods.gds-name  no-undo.
define output parameter p-prod-full-name as character  no-undo.
define output parameter p-import-full-name as character  no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары ЕГАИС".

define temp-table tt-goods no-undo
  field gds-code         like goods.gds-code
  field artic            like goods.artic
  field gds-name         like goods.gds-name
  field alc-code         as character label "Алког.код"
  field import-full-name as character label "Импортер"
  field prod-full-name   as character label "Производитель"
  field CliRegIdProd     as character
  field INNProd          as character
  field KPPProd          as character
  field FullNameProd     as character
  field CountryProd      as character
  field CliRegIdImpor    as character
  field INNImpor         as character
  field KPPImpor         as character
  field FullNameImpor    as character
  field CountryImpor     as character   
  index pi as primary unique gds-code alc-code .
    
 
define variable extGdsObj      as class     extgds no-undo.
define variable ii             as integer   no-undo .
define variable v-gds-code     as integer   no-undo .
define variable v-gds-code-old as integer   no-undo .
define variable v-alc-code-old as character no-undo .
define variable v-gds-name     as character no-undo .
define variable v-gds-name1    as character no-undo .
define variable v-prod-name    as character no-undo .
define variable v-prod-name1   as character no-undo .
define variable v-imp-name     as character no-undo .
define variable v-imp-name1    as character no-undo .
define variable glog           as logical   no-undo .

{ cmp/vssrevis.i }
{bge/egais-mark.i}
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/color.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-goods

/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-3 Btn_OK Btn_Cancel ~
Btn_add Btn_del br-goods 
&Scoped-Define DISPLAYED-OBJECTS v-FullNameProd v-FullNameImpor ~
v-FullNameGds v-FullNameProd-2 v-FullNameImpor-2 v-FullNameGds-2 ~
v-CliRegIdProd v-CliRegIdImpor v-GdsCode v-INNProd v-INNImpor v-AlcCode ~
v-KPPProd v-KPPImpor v-CountryProd v-CountryImpor 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_add 
     LABEL "Добавить" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_del 
     LABEL "Удалить" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Ввод" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE v-AlcCode AS CHARACTER FORMAT "X(256)":U 
     LABEL "Алк.код" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-CliRegIdImpor AS CHARACTER FORMAT "X(256)":U 
     LABEL "Рег.ID" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-CliRegIdProd AS CHARACTER FORMAT "X(256)":U 
     LABEL "Рег.ID" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-CountryImpor AS CHARACTER FORMAT "X(256)":U 
     LABEL "Город" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-CountryProd AS CHARACTER FORMAT "X(256)":U 
     LABEL "Город" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-FullNameGds AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-FullNameGds-2 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-FullNameImpor AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-FullNameImpor-2 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-FullNameProd AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-FullNameProd-2 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 38.38 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-GdsCode AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-INNImpor AS CHARACTER FORMAT "X(256)":U 
     LABEL "ИНН" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-INNProd AS CHARACTER FORMAT "X(256)":U 
     LABEL "ИНН" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-KPPImpor AS CHARACTER FORMAT "X(256)":U 
     LABEL "КПП" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-KPPProd AS CHARACTER FORMAT "X(256)":U 
     LABEL "КПП" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 40 BY 7.75.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 40 BY 7.75.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 40 BY 7.75.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
  DEFINE QUERY br-goods FOR 
    tt-goods SCROLLING.
&ANALYZE-RESUME

  /* Browse definitions                                                   */
  DEFINE BROWSE br-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
    QUERY br-goods  DISPLAY
    tt-goods.gds-code 
    WIDTH 20
    tt-goods.artic 
    WIDTH 20
    tt-goods.gds-name 
    WIDTH 30
    tt-goods.alc-code format "X(256)"
    WIDTH 30
    tt-goods.import-full-name format "X(256)"
    WIDTH 30
    tt-goods.prod-full-name format "X(256)"
    WIDTH 30 
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 121 BY 14.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 16.5
     Btn_add AT ROW 1.25 COL 31.5 WIDGET-ID 4
     Btn_del AT ROW 1.25 COL 46.5 WIDGET-ID 2
     br-goods AT ROW 3 COL 1.5 WIDGET-ID 200
     v-FullNameProd AT ROW 18.83 COL 2 NO-LABEL WIDGET-ID 10 AUTO-RETURN 
     v-FullNameImpor AT ROW 18.83 COL 42.5 NO-LABEL WIDGET-ID 30 AUTO-RETURN 
     v-FullNameGds AT ROW 18.83 COL 83 NO-LABEL WIDGET-ID 50 AUTO-RETURN 
     v-FullNameProd-2 AT ROW 19.88 COL 2 NO-LABEL WIDGET-ID 52 AUTO-RETURN 
     v-FullNameImpor-2 AT ROW 19.88 COL 42.5 NO-LABEL WIDGET-ID 54 AUTO-RETURN 
     v-FullNameGds-2 AT ROW 19.88 COL 83 NO-LABEL WIDGET-ID 56 AUTO-RETURN 
     v-CliRegIdProd AT ROW 21.38 COL 9 COLON-ALIGNED WIDGET-ID 14
     v-CliRegIdImpor AT ROW 21.38 COL 49.5 COLON-ALIGNED WIDGET-ID 26
     v-GdsCode AT ROW 21.38 COL 90 COLON-ALIGNED WIDGET-ID 40
     v-INNProd AT ROW 22.38 COL 9 COLON-ALIGNED WIDGET-ID 16
     v-INNImpor AT ROW 22.38 COL 49.5 COLON-ALIGNED WIDGET-ID 32
     v-AlcCode AT ROW 22.38 COL 90 COLON-ALIGNED WIDGET-ID 46
     v-KPPProd AT ROW 23.38 COL 9 COLON-ALIGNED WIDGET-ID 18
     v-KPPImpor AT ROW 23.38 COL 49.5 COLON-ALIGNED WIDGET-ID 34
     v-CountryProd AT ROW 24.38 COL 9 COLON-ALIGNED WIDGET-ID 20
     v-CountryImpor AT ROW 24.38 COL 49.5 COLON-ALIGNED WIDGET-ID 28
     "Товар:" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 17.88 COL 83 WIDGET-ID 38
     "Импортер:" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 17.88 COL 42.5 WIDGET-ID 24
     "Производитель:" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 17.88 COL 2 WIDGET-ID 12
     RECT-1 AT ROW 17.75 COL 1.5 WIDGET-ID 6
     RECT-2 AT ROW 17.75 COL 42 WIDGET-ID 22
     RECT-3 AT ROW 17.75 COL 82.5 WIDGET-ID 36
     SPACE(0.87) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Товары ЕГАИС"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-goods Btn_del Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       br-goods:column-resizable IN FRAME Dialog-Frame              = TRUE.
       

/* SETTINGS FOR FILL-IN v-AlcCode IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-CliRegIdImpor IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-CliRegIdProd IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-CountryImpor IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-CountryProd IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-FullNameGds IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN v-FullNameGds-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN v-FullNameImpor IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN v-FullNameImpor-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN v-FullNameProd IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN v-FullNameProd-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN v-GdsCode IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-INNImpor IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-INNProd IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-KPPImpor IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-KPPProd IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары ЕГАИС */
DO:
      APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_add Dialog-Frame
ON choose OF Btn_add IN FRAME Dialog-Frame /* Добавить */
DO:
      define variable ref-list as character no-undo .
      define variable extGdsValueObjnew as class ExtGdsValue.
      define variable v-GdsCode as integer no-undo .
      define variable v-GdsCodenew as integer no-undo .  
      define variable glog         as logical no-undo.
      
 { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-ref':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    glog
  }
  
  if not glog then  return .
  
      run ref/gds-ref.p
        ( input parparentproc
        ,input "b-sel,b-add"
        ,input {&current}
        ,input {&all}
        ,input {&all}
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input ?
        ,output ref-list).
      find first ub.goods where recid (ub.goods) = integer (ref-list) no-lock no-error .
      find first ub.goods-attr where ub.goods-attr.gds-code = ub.goods.gds-code and goods-attr.attr-code = "alcohol-prod" no-lock no-error .
      if available ub.goods-attr then do:
      if extGdsObj:NumBundles > 0 then 
        do:
          do ii = 1 to extGdsObj:NumBundles:
            v-gds-code = extGdsObj:GetExtGdsValue(ii):GdsCode .
            v-GdsCodenew = ub.goods.gds-code .
            if v-GdsCodenew = v-Gds-Code then do:
              message "Такой товар уже есть"
              view-as alert-box.
              return no-apply.
            end.
          end.  
        end.  

      extGdsValueObjnew = new ExtGdsValue () . 
      extGdsObj:CopyEgaisInfo(extGdsObj:GetExtGdsValue(), extGdsValueObjnew).
      extGdsValueObjnew:GdsCode = v-GdsCodenew.
      extGdsValueObjnew:AlcCode = p-alc-code.
      extGdsObj:CreateExtGds (extGdsValueObjnew).
      extGdsObj:OpenQueryExtGds(p-gds-code, p-alc-code).
      
      find first tt-goods where tt-goods.gds-code = extGdsValueObjnew:GdsCode and
        tt-goods.gds-name = ub.goods.gds-name and 
        tt-goods.artic    = ub.goods.artic no-lock no-error.
      if not available tt-goods then do:  
      create tt-goods .
        tt-goods.alc-code = extGdsValueObjnew:AlcCode . 
        tt-goods.gds-code = extGdsValueObjnew:GdsCode .
        tt-goods.gds-name = ub.goods.gds-name .
        tt-goods.artic    = ub.goods.artic .
        tt-goods.import-full-name = extGdsValueObjnew:FullNameImpor .
        tt-goods.prod-full-name   = extGdsValueObjnew:FullNameProd .
        tt-goods.CliRegIdProd = extGdsValueObjnew:CliRegIdProd .
        tt-goods.CountryProd = extGdsValueObjnew:CountryProd .
        tt-goods.INNProd = extGdsValueObjnew:INNProd .
        tt-goods.KPPProd = extGdsValueObjnew:KPPProd .
        tt-goods.CliRegIdImpor = extGdsValueObjnew:CliRegIdImpor .
        tt-goods.CountryImpor = extGdsValueObjnew:CountryImpor .
        tt-goods.INNImpor = extGdsValueObjnew:INNImpor .
        tt-goods.KPPImpor = extGdsValueObjnew:KPPImpor .

        .
      end.
      end.
      else do:
        message "Товар не является алкогольным"
        view-as alert-box.
      end.  
      
      open query br-goods for each tt-goods .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON choose OF Btn_Cancel IN FRAME Dialog-Frame /* Отмена */
DO:

  assign
    p-alc-code = v-alc-code-old
    p-gds-code = v-gds-code-old
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME value-changed
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL value-changed Dialog-Frame
on value-changed of br-goods do:
  run local-value-changed.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
  
&Scoped-define SELF-NAME Btn_del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_del Dialog-Frame
ON choose OF Btn_del IN FRAME Dialog-Frame /* Удалить */
DO:
      define variable glog         as logical no-undo.
      
 { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-ref':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    glog
  }
  
  if not glog then  return .
  

      extGdsObj:DeleteExtGds (tt-goods.gds-code, p-alc-code).
      delete tt-goods.
      extGdsObj:OpenQueryExtGds(p-gds-code, p-alc-code).
      open query br-goods for each tt-goods .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON choose OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
      if available tt-goods then do:
      assign
        p-alc-code = tt-goods.alc-code
        p-gds-code = tt-goods.gds-code
        p-gds-name = tt-goods.gds-name
        p-import-full-name = tt-goods.import-full-name
        p-prod-full-name   = tt-goods.prod-full-name
        .  
       end. 
      RUN disable_UI.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-goods
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

  /* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
  IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


  /* Now enable the interface and wait for the exit condition.            */
  /* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
  MAIN-BLOCK:
  DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    assign
      v-gds-code-old = p-gds-code
      v-alc-code-old = p-alc-code
    .
    RUN enable_UI.
    RUN enable_goods.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_goods Dialog-Frame 
PROCEDURE enable_goods :
/*------------------------------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:       
  ------------------------------------------------------------------------------*/
  
  define variable extGdsValueObj  as class ExtGdsValue no-undo.
  
  extGdsObj = new ExtGds (true).
  extGdsObj:OpenQueryExtGds(p-gds-code, p-alc-code). 
  if extGdsObj:NumBundles > 0 then 
  do:
    do ii = 1 to extGdsObj:NumBundles:
      v-gds-code = extGdsObj:GetExtGdsValue(ii):GdsCode .
      find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
      if not available (ub.goods) then do:
        message "Не найден товар с кодом - " v-gds-code view-as alert-box.
      end.
      extGdsValueObj = extGdsObj:GetExtGdsValue(ii).
      create tt-goods .
      assign
        tt-goods.gds-code = extGdsValueObj:GdsCode
        tt-goods.alc-code = extGdsValueObj:AlcCode
        tt-goods.gds-name = ub.goods.gds-name
        tt-goods.artic    = ub.goods.artic
        tt-goods.import-full-name = extGdsValueObj:FullNameImpor
        tt-goods.prod-full-name   = extGdsValueObj:FullNameProd
        tt-goods.CliRegIdProd = extGdsValueObj:CliRegIdProd
        tt-goods.CountryProd = extGdsValueObj:CountryProd
        tt-goods.INNProd = extGdsValueObj:INNProd
        tt-goods.KPPProd = extGdsValueObj:KPPProd
        tt-goods.CliRegIdImpor = extGdsValueObj:CliRegIdImpor
        tt-goods.CountryImpor = extGdsValueObj:CountryImpor
        tt-goods.INNImpor = extGdsValueObj:INNImpor
        tt-goods.KPPImpor = extGdsValueObj:KPPImpor
      .
    end.  
  end.    
  open query br-goods for each tt-goods .
  run local-value-changed.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-value-changed Dialog-Frame 
PROCEDURE local-value-changed :
/*------------------------------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:       
  ------------------------------------------------------------------------------*/
  if available tt-goods then do:

    
    if length (tt-goods.prod-full-name) > 33 then do:
      v-prod-name = substring (tt-goods.prod-full-name,1,36,"character") .
      v-prod-name1 = substring (tt-goods.prod-full-name,37,81,"character") .
    end.
    else v-prod-name = tt-goods.prod-full-name .
    DISPLAY v-prod-name @ v-FullNameProd with frame {&frame-name}.
    DISPLAY v-prod-name1 @ v-FullNameProd-2 with frame {&frame-name}.
    DISPLAY tt-goods.CliRegIdProd @ v-CliRegIdProd with frame {&frame-name}.
    DISPLAY tt-goods.CountryProd @ v-CountryProd with frame {&frame-name}.
    DISPLAY tt-goods.INNProd @ v-INNProd with frame {&frame-name}.
    DISPLAY tt-goods.KPPProd @ v-KPPProd with frame {&frame-name}.   
    if length (tt-goods.import-full-name) > 33 then do:
      v-imp-name = substring (tt-goods.import-full-name,1,36,"character") .
      v-imp-name1 = substring (tt-goods.import-full-name,37,81,"character") .
    end.
    else v-imp-name = tt-goods.import-full-name .      
    DISPLAY v-imp-name @ v-FullNameImpor with frame {&frame-name}.
    DISPLAY v-imp-name1 @ v-FullNameImpor-2 with frame {&frame-name}.
    DISPLAY tt-goods.CliRegIdImpor @ v-CliRegIdImpor with frame {&frame-name}.
    DISPLAY tt-goods.CountryImpor @ v-CountryImpor with frame {&frame-name}.
    DISPLAY tt-goods.INNImpor @ v-INNImpor with frame {&frame-name}.
    DISPLAY tt-goods.KPPImpor @ v-KPPImpor with frame {&frame-name}.
    DISPLAY tt-goods.alc-code @ v-AlcCode with frame {&frame-name}.
    DISPLAY string(tt-goods.gds-code) @ v-GdsCode with frame {&frame-name}.
    if length (tt-goods.gds-name) > 33 then do:
      v-gds-name = substring (tt-goods.gds-name,1,33,"character") .
      v-gds-name1 = substring (tt-goods.gds-name,34,67,"character") .
    end.
    else v-gds-name = tt-goods.gds-name .   
    DISPLAY v-gds-name @ v-FullNameGds with frame {&frame-name}.
    DISPLAY v-gds-name1 @ v-FullNameGds-2 with frame {&frame-name}.      
/*    v-FullNameProd = tt-goods.FullNameProd*/
/*    v-CliRegIdProd = tt-goods.CliRegIdProd*/
/*    v-CountryProd = tt-goods.CountryProd*/
/*    v-INNProd = tt-goods.INNProd        */
/*    v-KPPProd = tt-goods.KPPProd        */
/*    v-FullNameImpor = tt-goods.FullNameImpor*/
/*    v-CliRegIdImpor = tt-goods.CliRegIdImpor*/
/*    v-CountryImpor = tt-goods.CountryImpor  */
/*    v-INNImpor = tt-goods.INNImpor          */
/*    v-KPPImpor = tt-goods.KPPImpor          */

  end.  

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
  ENABLE Btn_OK Btn_Cancel Btn_add Btn_del br-goods
      WITH FRAME Dialog-Frame.
  if p-mode = {&lookup} then do:
  DISABLE Btn_add Btn_del  
      WITH FRAME Dialog-Frame.
  end.
  if p-mode = {&update} then do:
  /*DISABLE Btn_Cancel  
      WITH FRAME Dialog-Frame.*/
  end. 
  if p-mode = {&select}  then do: 
   DISABLE Btn_add Btn_del Btn_OK WITH FRAME Dialog-Frame.

  end.          
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

