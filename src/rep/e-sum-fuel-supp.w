&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object 
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Отчет по длительности транзакций

Автор: Рукавишников Вадим
Дата создания: 24/05/21
Author: Rukavishnikov Vadim
Creation date: 24/05/21

*/
define variable vss-revision    as character no-undo init "$ $":U .
define variable vss-author      as character no-undo init "$ $":U .
define variable vss-date        as character no-undo init "$ $":U .
define variable vss-workfile    as character no-undo init "$ $":U .
define variable vss-archive     as character no-undo init "$ $":U .
define variable vss-description as character no-undo init "Отчет по длительности транзакций(закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ ref/chk-type.i "new shared"}
{ cmp/gds-list.i gds-list def shared }

CREATE WIDGET-POOL.

define variable mI  as int64 no-undo.
define variable mRowId as rowid no-undo.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .
define variable m-rid-list as character no-undo .
define variable parParentProc as widget-handle no-undo.
define variable mSuppsList as character no-undo init "*".
define variable mGdsCodeList as character no-undo init "*".
define variable mOilBasesList as character no-undo init "*".
define variable vOilBaseSupps as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-3 RECT-5 RECT-9 RECT-7 mSupps mGds mOilBases ~
mSuppList mGds-list mOilBaseList mTranTimeMax t-delta-tank-ac t-delta-tank-fact ~
t-itog rs-ac-type t-no-azk-itog rs-trk-err
&Scoped-Define DISPLAYED-OBJECTS mSupps mGds mOilBases mSuppList mGds-list mOilBaseList ~
rs-ac-type mTranTimeMax t-delta-tank-ac t-delta-tank-fact t-itog t-no-azk-itog rs-trk-err

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE mSuppList AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 27 BY 4 NO-UNDO.

DEFINE VARIABLE mGds-list AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 27 BY 4 NO-UNDO.

DEFINE VARIABLE mOilBaseList AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 27 BY 4 NO-UNDO.

DEFINE VARIABLE mTranTimeMax AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 TOOLTIP "мин. время слива одной секции в минутах, при превышении к-го выводим данные"
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE mSupps AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", "All",
          "Выбор", "Select"
     SIZE 15.6 BY 1.24 NO-UNDO.

DEFINE VARIABLE mGds AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", "All",
          "Выбор", "Select"
     SIZE 15.6 BY 1.24 NO-UNDO.

DEFINE VARIABLE mOilBases AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", "All",
          "Выбор", "Select"
     SIZE 15.6 BY 1.24 NO-UNDO.

DEFINE VARIABLE rs-ac-type AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", 1,
          "С СЭП", 2,
          "Без СЭП", 3
     SIZE 33 BY 1.19 NO-UNDO.
     
DEFINE VARIABLE rs-trk-err AS INTEGER 
     VIEW-AS RADIO-SET vertical
     RADIO-BUTTONS 
          "Все", 1,
          "Только с ошибками", 2,
          "Только без ошибок", 3
     SIZE 23 BY 2 NO-UNDO.


DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.6 BY 2.24.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 5.52.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 5.52.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35 BY 2.24.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 5.52.

DEFINE VARIABLE t-delta-tank-ac AS LOGICAL INITIAL no 
     LABEL "только со сверхнормативным расхождением между резервуаром и АЦ" 
     VIEW-AS TOGGLE-BOX
     SIZE 83 BY .81 NO-UNDO.

DEFINE VARIABLE t-delta-tank-fact AS LOGICAL INITIAL no 
     LABEL "только со сверхнормативным расхождением между резервуаром и принятым НП" 
     VIEW-AS TOGGLE-BOX
     SIZE 87 BY .81 NO-UNDO.

DEFINE VARIABLE t-itog AS LOGICAL INITIAL no 
     LABEL "только итоги" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .81 NO-UNDO.
     
DEFINE VARIABLE t-no-azk-itog AS LOGICAL INITIAL no 
     LABEL "не выводить итоги по АЗК" 
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     mSupps AT ROW 1.5 COL 36 NO-LABEL WIDGET-ID 26
     mGds AT ROW 1.5 COL 6 NO-LABEL WIDGET-ID 46
     mOilBases AT ROW 1.5 COL 64 NO-LABEL WIDGET-ID 16
     mSuppList AT ROW 2.5 COL 33.6 NO-LABEL WIDGET-ID 32
     mGds-list AT ROW 2.5 COL 3.6 NO-LABEL WIDGET-ID 52
     mOilBaseList AT ROW 2.5 COL 61.6 NO-LABEL WIDGET-ID 12
     rs-ac-type AT ROW 7.3 COL 16 NO-LABEL WIDGET-ID 72
     rs-trk-err AT ROW 9.3 COL 40 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     mTranTimeMax AT ROW 9.9 COL 4 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     t-delta-tank-ac AT ROW 11.95 COL 4 WIDGET-ID 88
     t-delta-tank-fact AT ROW 13.14 COL 4 WIDGET-ID 90
     t-itog AT ROW 14.33 COL 4 WIDGET-ID 92
     t-no-azk-itog  AT ROW 15.5 COL 4 WIDGET-ID 92
     "мин" VIEW-AS TEXT
          SIZE 3.6 BY .76 AT ROW 10.33 COL 15.6 WIDGET-ID 84
     " Минимальное время приёмки:" VIEW-AS TEXT
          SIZE 28 BY 1 AT ROW 8.6 COL 5 WIDGET-ID 86
          FGCOLOR 4 
     " Поставщики:" VIEW-AS TEXT
          SIZE 13 BY .76 AT ROW 1 COL 34 WIDGET-ID 34
          FGCOLOR 4 
     " Топливные товары:" VIEW-AS TEXT
          SIZE 18.6 BY .76 AT ROW 1 COL 4 WIDGET-ID 50
          FGCOLOR 4 
     " Нефтебазы:" VIEW-AS TEXT
          SIZE 13 BY .76 AT ROW 1 COL 62 WIDGET-ID 34
          FGCOLOR 4 
     " Типы АЦ:" VIEW-AS TEXT
          SIZE 11 BY .76 AT ROW 7.52 COL 3 WIDGET-ID 78
          FGCOLOR 4 
     " Ошибки по ТРК:" VIEW-AS TEXT
          SIZE 16 BY .76 AT ROW 8.6 COL 43 WIDGET-ID 78
          FGCOLOR 4 
     RECT-1 AT ROW 9.1 COL 40
     RECT-3 AT ROW 1.24 COL 61
     RECT-5 AT ROW 1.24 COL 2.6
     RECT-9 AT ROW 1.24 COL 32 WIDGET-ID 36
     RECT-7 AT ROW 9.1 COL 4 WIDGET-ID 82
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 18.57
         WIDTH              = 92.6.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN 
       mSuppList:HIDDEN IN FRAME F-Main           = TRUE
       mSuppList:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN 
       mGds-list:HIDDEN IN FRAME F-Main           = TRUE
       mGds-list:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN 
       mOilBaseList:HIDDEN IN FRAME F-Main           = TRUE
       mOilBaseList:READ-ONLY IN FRAME F-Main        = TRUE.


/* SETTINGS FOR RADIO-SET rs-ac-type IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-ac-type s-object
ON VALUE-CHANGED OF rs-ac-type IN FRAME F-Main
DO:
   assign rs-ac-type .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-trk-err s-object
ON VALUE-CHANGED OF rs-trk-err IN FRAME F-Main
DO:
   assign rs-trk-err .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define SELF-NAME mSupps
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mSupps s-object
ON MOUSE-SELECT-DBLCLICK OF mSupps IN FRAME F-Main
DO:
   apply "VALUE-CHANGED" to mSupps in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mSupps s-object
ON VALUE-CHANGED OF mSupps IN FRAME F-Main
DO:
   do with frame {&FRAME-NAME}:
      assign mSupps.
      if mSupps = "All" then do:
         disable mSuppList.
         mSuppList:visible = no.
         mSuppsList = "*".
         vOilBaseSupps = "" .
      end.
      else do:
         run select-supps.
         if mSuppsList > ""
         then do :
           enable mSuppList.
           mSuppList:visible = yes.
         end .
         else do :
           disable mSuppList.
           mSuppList:visible = no.
           mSuppsList = "*".
           vOilBaseSupps = "" .
         end .
      end.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mGds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mGds s-object
ON MOUSE-SELECT-DBLCLICK OF mGds IN FRAME F-Main
DO:
   apply "VALUE-CHANGED" to mGds in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mGds s-object
ON VALUE-CHANGED OF mGds IN FRAME F-Main
DO:
   do with frame {&FRAME-NAME}:
      assign mGds.
      if mGds = "All" then do:
         disable mGds-list.
         mGds-list:visible = no.
         mGdsCodeList = "*".
      end.
      else do:
         run select-gds.
         if mGdsCodeList > ""
         then do :
           enable mGds-list.
           mGds-list:visible = yes.
         end .
         else do :
           disable mGds-list.
           mGds-list:visible = no.
           mGdsCodeList = "*".
         end .
      end.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME mOilBases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mOilBases s-object
ON MOUSE-SELECT-DBLCLICK OF mOilBases IN FRAME F-Main
DO:
   apply "VALUE-CHANGED" to mOilBases in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mGds s-object
ON VALUE-CHANGED OF mOilBases IN FRAME F-Main
DO:
   do with frame {&FRAME-NAME}:
      assign mOilBases.
      if mOilBases = "All" then do:
         disable mOilBaselist.
         mOilBaselist:visible = no.
         mOilBasesList = "*".
      end.
      else do:
         run select-OilBase.
         if mOilBasesList > ""
         then do :
           enable mOilBaselist.
           mOilBaselist:visible = yes.
         end .
         else do :
           disable mOilBaselist.
           mOilBaselist:visible = no.
           mOilBasesList = "*".
         end .
      end.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mTranTimeMax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mTranTimeMax s-object
ON LEAVE OF mTranTimeMax IN FRAME F-Main
DO:
   assign frame {&FRAME-NAME} mTranTimeMax.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF
parParentProc = my-handle.
display mTranTimeMax with frame {&FRAME-NAME}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
------------------------------------------------------------------------------*/
   assign frame {&FRAME-NAME}
     t-delta-tank-ac
     t-delta-tank-fact
     t-itog
     t-no-azk-itog
   .

   run rep/r-sum-fuel-supp.p ( v-cntxt-host-code-obj,
                               rs-ac-type,
                               rs-trk-err,
                               mGdsCodeList,
                               mSuppsList,
                               mOilBasesList,
                               mTranTimeMax,
                               t-delta-tank-ac,
                               t-delta-tank-fact,
                               t-itog,
                               t-no-azk-itog
                              ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
/*
   assign frame {&frame-name}
   .
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-supps s-object 
PROCEDURE select-supps :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   define buffer clients for clients.
   define variable vI            as int64     no-undo.
   define variable vSuppNamelist as character no-undo.
   
   run ref/cli-all.w (parparentproc
                    , "b-sel,b-mark"
                    , {&all}
                    , ?
                    , ?
                    , ?
                    , ?
                    , "supp-np-lgas"
                    , output m-rid-list) .
   
   mSuppsList = "".
   vOilBaseSupps = "".
   do vI = 1 to num-entries(m-rid-list):
      find first clients where
                 recid(clients) = integer(entry(vI, m-rid-list))
      no-lock no-error.
      if available clients then do:
         assign
            mSuppsList  = mSuppsList  + "," + string(clients.obj-code)
            vSuppNamelist = vSuppNamelist + "," + {&new-line} + clients.obj-name
            vOilBaseSupps = vOilBaseSupps + "," + clients.obj-type + string(clients.obj-code)
         .
      end.
   end.
   vSuppNamelist = trim(vSuppNamelist, "," + {&new-line}).
   mSuppsList = trim(mSuppsList, ",").
   vOilBaseSupps = trim(vOilBaseSupps, ",").
   mSuppList:screen-value in frame {&FRAME-NAME} = vSuppNamelist.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-gds s-object 
PROCEDURE select-gds :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   define buffer goods for goods.
   define buffer units for units.
   
   define variable vGdsName-list as character no-undo.
   define variable v-recid-list  as character no-undo.
   define variable vRecId        as recid     no-undo.
   define variable vAnswer       as logical   no-undo.
   define variable vI            as integer   no-undo.

   run ref/gds-ref.p (
                       input parparentproc
                      ,input "b-mark,b-sel"
                      ,input {&all}           /*p-stat */
                      ,input "ptrlsug"        /*p-list  */
                      ,input ?                /*p-cond  */
                      ,input ?                /*p-rec   */
                      ,input ?                /*p-grp   */
                      ,input ?                /*p-cli-type */
                      ,input ?                /*p-cli-code  */
                      ,input v-cntxt-obj-type /*p-obj-type  */
                      ,input v-cntxt-obj-code /*p-obj-code  */
                      ,input ?                /*p-other     */
                      ,output v-recid-list).
   if v-recid-list = "" and can-find(first gds-list) then do:
      message
         "Не было выбрано ни одного товара. Очистить список ранее выбранных товаров?"
      view-as alert-box QUESTION buttons YES-NO update vAnswer.
      if not vAnswer then return.
   end.
   mGdsCodeList = "".
   empty temp-table gds-list.
   do vI = 1 to num-entries(v-recid-list):
      vRecId = integer(entry(vI, v-recid-list)).
      find first goods where
                 recid(goods) = vRecId
      no-lock no-error.
      if avail goods then do:
         create gds-list.
         buffer-copy goods to gds-list.
      end.
   end.
   for each gds-list no-lock:
      find first goods where
                 goods.artic     = gds-list.artic
             and goods.prod-type = gds-list.prod-type
             and goods.prod-code = gds-list.prod-code
      no-lock no-error .
      if not available goods then do:
         delete gds-list.
         next.
      end.
      find first units where
                 units.unit-name = goods.unit-base
      no-lock no-error .
      if not available units then do:
         delete gds-list.
         next.
      end.
      if not can-do(units.type, {&petrolium}) then do:
         delete gds-list .
         next.
      end.
      assign
         vGdsName-list = vGdsName-list + "," + {&new-line} + string(goods.gds-code) + "(" + goods.gds-name + ")"
         mGdsCodeList  = mGdsCodeList  + "," + string(goods.gds-code)
         .
   end.
   assign
      vGdsName-list = trim(vGdsName-list, "," + {&new-line})
      mGdsCodeList  = trim(mGdsCodeList, ",")
      .
   mGds-list:screen-value in frame {&FRAME-NAME} = vGdsName-list.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-supps s-object 
PROCEDURE select-OilBase :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   define buffer clients for clients.
   define variable vI            as int64     no-undo.
   define variable vOilBaselist as character no-undo.
   
   run ref/cli-all.w (parparentproc
                    , "b-sel,b-mark"
                    , {&all}
                    , ?
                    , ?
                    , ?
                    , ?
                    , substitute("tank-farm-for-supp=&1", vOilBaseSupps)
                    , output m-rid-list) .
   
   mOilBasesList = "".
   do vI = 1 to num-entries(m-rid-list):
      find first clients where
                 recid(clients) = integer(entry(vI, m-rid-list))
      no-lock no-error.
      if available clients then do:
         assign
            mOilBasesList = mOilBasesList  + "," + string(clients.obj-code)
            vOilBaselist = vOilBaselist + "," + {&new-line} + clients.obj-name.
      end.
   end.
   vOilBaselist = trim(vOilBaselist, "," + {&new-line}).
   mOilBasesList = trim(mOilBasesList, ",").
   mOilBaseList:screen-value in frame {&FRAME-NAME} = vOilBaselist.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

