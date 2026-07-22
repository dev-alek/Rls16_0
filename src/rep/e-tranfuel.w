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
define variable mChkTypeCodeList as character no-undo init "*".
define variable mCashPayList as character no-undo init "*".
define variable mGdsCodeList as character no-undo init "*".

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
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-8 RECT-6 RECT-9 RECT-7 RECT-10 ~
mGds mTRK mGds-list mTRKList mTranTimeMax mCashPay mCashPay-list mChkType ~
mChkType-list mGrpChk mGrpTran 
&Scoped-Define DISPLAYED-OBJECTS mGds mTRK mGds-list mTRKList mTranTimeMax ~
mCashPay mCashPay-list mChkType mChkType-list mGrpChk mGrpTran 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE mCashPay-list AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 30 BY 4 NO-UNDO.

DEFINE VARIABLE mChkType-list AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 30 BY 4 NO-UNDO.

DEFINE VARIABLE mGds-list AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 30 BY 4 NO-UNDO.

DEFINE VARIABLE mTranTimeMax AS INTEGER FORMAT ">>>>>>9":U INITIAL 30 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE mTRKList AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 28.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE mCashPay AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", "All",
"Выбор", "Select"
     SIZE 15.5 BY 1.25 NO-UNDO.

DEFINE VARIABLE mChkType AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", "All",
"Выбор", "Select"
     SIZE 15.5 BY 1.25 NO-UNDO.

DEFINE VARIABLE mGds AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", "All",
"Выбор", "Select"
     SIZE 15.5 BY 1.25 NO-UNDO.

DEFINE VARIABLE mTRK AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", "All",
"Список", "List"
     SIZE 15.5 BY 1.25 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 25.5 BY 2.5.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.5 BY 5.5.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31 BY 3.25.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 51 BY 2.25.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.5 BY 6.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.5 BY 5.5.

DEFINE VARIABLE mGrpChk AS LOGICAL INITIAL no 
     LABEL "по чекам" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.

DEFINE VARIABLE mGrpTran AS LOGICAL INITIAL no 
     LABEL "по транзакциям" 
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     mGds AT ROW 1.5 COL 6 NO-LABEL WIDGET-ID 46
     mTRK AT ROW 1.5 COL 37.5 NO-LABEL WIDGET-ID 16
     mGds-list AT ROW 2.5 COL 3.5 NO-LABEL WIDGET-ID 52
     mTRKList AT ROW 3 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     mTranTimeMax AT ROW 6 COL 35 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     mCashPay AT ROW 7.25 COL 5.5 NO-LABEL WIDGET-ID 26
     mCashPay-list AT ROW 8.25 COL 3.5 NO-LABEL WIDGET-ID 32
     mChkType AT ROW 13.25 COL 5.5 NO-LABEL WIDGET-ID 38
     mChkType-list AT ROW 14.5 COL 3.5 NO-LABEL WIDGET-ID 42
     mGrpChk AT ROW 16.75 COL 69.5 WIDGET-ID 64
     mGrpTran AT ROW 17.75 COL 69.5 WIDGET-ID 66
     "мин" VIEW-AS TEXT
          SIZE 3.5 BY .75 AT ROW 6.25 COL 46.5 WIDGET-ID 62
     " Типы платежей:" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 6.75 COL 4 WIDGET-ID 34
          FGCOLOR 4 
     " ТРК :" VIEW-AS TEXT
          SIZE 7 BY .75 AT ROW 1 COL 37 WIDGET-ID 20
          FGCOLOR 4 
     " Мин. длительность жизненного цикла заказа НП:" VIEW-AS TEXT
          SIZE 47 BY 1 AT ROW 4.75 COL 36 WIDGET-ID 58
          FGCOLOR 4 
     " Типы чеков:" VIEW-AS TEXT
          SIZE 13 BY .75 AT ROW 12.75 COL 4.5 WIDGET-ID 44
          FGCOLOR 4 
     " Группировка:" VIEW-AS TEXT
          SIZE 14 BY .75 AT ROW 16 COL 71.5 WIDGET-ID 70
          FGCOLOR 4 
     " Топливные товары:" VIEW-AS TEXT
          SIZE 18.5 BY .75 AT ROW 1 COL 5 WIDGET-ID 50
          FGCOLOR 4 
     RECT-5 AT ROW 1.25 COL 2.5
     RECT-8 AT ROW 12.75 COL 2.5 WIDGET-ID 10
     RECT-6 AT ROW 1.25 COL 35 WIDGET-ID 22
     RECT-9 AT ROW 7 COL 2.5 WIDGET-ID 36
     RECT-7 AT ROW 5 COL 35 WIDGET-ID 60
     RECT-10 AT ROW 16.25 COL 67.5 WIDGET-ID 68
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
         HEIGHT             = 18.58
         WIDTH              = 92.5.
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
       mCashPay-list:HIDDEN IN FRAME F-Main           = TRUE
       mCashPay-list:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN 
       mChkType-list:HIDDEN IN FRAME F-Main           = TRUE
       mChkType-list:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN 
       mGds-list:HIDDEN IN FRAME F-Main           = TRUE
       mGds-list:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN 
       mTRKList:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME mCashPay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mCashPay s-object
ON MOUSE-SELECT-DBLCLICK OF mCashPay IN FRAME F-Main
DO:
   apply "VALUE-CHANGED" to mCashPay in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mCashPay s-object
ON VALUE-CHANGED OF mCashPay IN FRAME F-Main
DO:
   do with frame {&FRAME-NAME}:
      assign mCashPay.
      if mCashPay = "All" then do:
         disable mCashPay-list.
         mCashPay-list:visible = no.
         mCashPayList = "*".
      end.
      else do:
         run select-cash-pays.
         enable mCashPay-list.
         mCashPay-list:visible = yes.
      end.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mChkType
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mChkType s-object
ON MOUSE-SELECT-DBLCLICK OF mChkType IN FRAME F-Main
DO:
   apply "VALUE-CHANGED" to mChkType in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mChkType s-object
ON VALUE-CHANGED OF mChkType IN FRAME F-Main
DO:
   do with frame {&FRAME-NAME}:
      assign mChkType.
      if mChkType = "All" then do:
         disable mChkType-list.
         mChkType-list:visible = no.
         mChkTypeCodeList = "*".
      end.
      else do:
         run select-chk-type.
         enable mChkType-list.
         mChkType-list:visible = yes.
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
         enable mGds-list.
         mGds-list:visible = yes.
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


&Scoped-define SELF-NAME mTRK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mTRK s-object
ON VALUE-CHANGED OF mTRK IN FRAME F-Main
DO:
   do with frame {&FRAME-NAME}:
      assign mTrk.
      if mTrk = "All" then do:
         disable mTRKList.
         mTRKList:visible = no.
      end.
      else do:
         enable mTRKList.
         mTRKList:visible = yes.
      end.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mTRKList
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mTRKList s-object
ON LEAVE OF mTRKList IN FRAME F-Main
DO:
   assign frame {&FRAME-NAME} mTRKList.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_set-cp-list s-object 
PROCEDURE cb_set-cp-list :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define output parameter o-rid-list as character no-undo.
  assign
    o-rid-list = m-rid-list
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
      mTrk
      mGrpChk
      mGrpTran.

   run rep/r-tranfuel.p (v-cntxt-host-code-obj,
                         mChkTypeCodeList,
                         mGdsCodeList,
                         mCashPayList,
                         (if mTrk = "All" then "*" else mTRKList),
                         mTranTimeMax,
                         mGrpChk,
                         mGrpTran
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-cash-pays s-object 
PROCEDURE select-cash-pays :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   define buffer cash-pay for cash-pay.
   define variable vI            as int64     no-undo.
   define variable vCashPay-list as character no-undo.
   
   run ref/cashpays.w
       ( input parparentproc
       , input "b-mark,b-sel"
       , input {&all}
       , input v-cntxt-host-code-obj
       , input v-cntxt-obj-type
       , input v-cntxt-obj-code
       , output m-rid-list ) no-error .
   
   mCashPayList = "".
   do vI = 1 to num-entries(m-rid-list):
      find first cash-pay where
                 recid(cash-pay) = integer(entry(vI, m-rid-list))
      no-lock no-error.
      if available cash-pay then do:
         assign
            mCashPayList  = mCashPayList  + "," + string(cash-pay.cdpay-code)
            vCashPay-list = vCashPay-list + "," + cash-pay.obj-name.
      end.
   end.
   vCashPay-list = trim(vCashPay-list, ",").
   mCashPayList = trim(mCashPayList, ",").
   mCashPay-list:screen-value in frame {&FRAME-NAME} = vCashPay-list.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-chk-type s-object 
PROCEDURE select-chk-type :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   define variable vChkType-list as character no-undo.

   run ref/chk-type.w(input parparentproc) no-error.
   mChkTypeCodeList = "".
   for each tt-chk-type where
            tt-chk-type.sel = yes:
      assign
         vChkType-list    = vChkType-list    + "," + tt-chk-type.name
         mChkTypeCodeList = mChkTypeCodeList + "," + string(tt-chk-type.code)
         .
   end.
   assign
      vChkType-list    = trim(vChkType-list, ",")
      mChkTypeCodeList = trim(mChkTypeCodeList, ",")
      .
   mChkType-list:screen-value in frame {&FRAME-NAME} = vChkType-list.
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
                      ,input "ptrl"           /*p-list  */
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
         vGdsName-list = vGdsName-list + "," + string(goods.gds-code) + "(" + goods.gds-name + ")"
         mGdsCodeList  = mGdsCodeList  + "," + string(goods.gds-code)
         .
   end.
   assign
      vGdsName-list = trim(vGdsName-list, ",")
      mGdsCodeList  = trim(mGdsCodeList, ",")
      .
   mGds-list:screen-value in frame {&FRAME-NAME} = vGdsName-list.
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

