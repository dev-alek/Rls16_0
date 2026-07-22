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

Отчёт по Картам клиентов (парам. закладка-2)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

/* Note-1. Временно (до уточнения представления в отчёте "Дополнительных ДК" и "Перевыпущенных ДК") отключана работа с виджетами toggle */
/* См. Note-1 ниже в коде. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отчёт по Картам клиентов (парам. закладка-2)" .

{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
/*{ cmp/showinf.i }*/
/*{ gbl/cur-time.i }*/
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
/*{ gbl/prn-lib.i }*/
{ cmp/operlist.i }
/*{ cmp/breakstr.i }*/
/*{ cmp/getdpcnt.i }*/
{ gbl/waitfram.i }
{ cmp/dc-list.i dc-list def "new shared" }
{ ref/grplibfn.i }
/*{ rep/e-xldcd.i "NEW SHARED" }*/
define variable parparentproc as widget-handle no-undo.
{ gbl/getcntxt.i def }
{ rep/lhstprex.i dc-list-hist  "'дисконтных карт'" }
{ rep/lhstprex.i gds-list-hist "'товаров'" }

/*define variable State-source as Widget-handle no-undo.*/
/*define variable NotInc as logical no-undo.*/

define variable StrBuf as character no-undo.
define variable rec-list as character no-undo.
define variable Line as character no-undo.
define variable FixDCard as character no-undo.
define variable FixProdAttr as character no-undo.

/*define variable sym1 as character initial ":" no-undo.*/
/*define variable sym2 as character initial ":" no-undo.*/

/*define variable ii as integer no-undo.                   */
/*define variable only-one-card-per-cli as integer no-undo.*/
/*define variable only-one-card-per-leg as integer no-undo.*/
/*define variable i as integer no-undo.*/
/*define variable namebuf1 as character no-undo.*/
/*define variable namebuf2 as character no-undo.*/
/*название + признак*/
/*define variable for-name as character no-undo.*/
define variable DcardMode as character no-undo init "ALL".
define variable FIlter-name as character no-undo.
define variable where-phrase as character no-undo.
define variable SelectProducer as character no-undo.
define variable v-curr-r-b as character no-undo.
define variable v-dcoveris as character no-undo.
define variable v-tmp-T-zeros as logical no-undo.
define variable v-activate-v-tmp-t-zeros as integer initial 0 no-undo.

/*define buffer cli-obj for ub.clients.  */
/*define buffer cli-dcard for ub.clients.*/
/*define buffer cli-prod for ub.clients. */

/*define variable for-netto as decimal no-undo.*/

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
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-client RECT-4 selectcard T-zeros ~
T-legacy T-subsid T-imp T-obj-detal up-levelt 
&Scoped-Define DISPLAYED-OBJECTS selectcard UpLevel T-zeros T-legacy ~
T-subsid T-imp T-obj-detal up-levelt 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE label-time AS CHARACTER FORMAT "X(256)":U INITIAL "Выборочно по времени" 
      VIEW-AS TEXT 
     SIZE 7 BY .62
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE up-levelt AS CHARACTER FORMAT "X(256)":U INITIAL "с превышением суммы" 
      VIEW-AS TEXT 
     SIZE 25.8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE UpLevel AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 14.6 BY 1 NO-UNDO.

DEFINE VARIABLE selectcard AS CHARACTER INITIAL "ALL" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", "All":U,
"Выборочно по картам", "Selective":U
     SIZE 29 BY 2.14 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 6.29.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 10.4 BY 2.38.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 1.57.

DEFINE RECTANGLE RECT-client
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 5.48.

DEFINE VARIABLE T-imp AS LOGICAL INITIAL no 
     LABEL "С учетом импорта из ВС" 
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .86 NO-UNDO.

DEFINE VARIABLE T-legacy AS LOGICAL INITIAL no 
     LABEL "С учетом перевыпуска карт" 
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .86 NO-UNDO.

DEFINE VARIABLE T-obj-detal AS LOGICAL INITIAL no 
     LABEL "Детализация по объектам" 
     VIEW-AS TOGGLE-BOX
     SIZE 31 BY .86 NO-UNDO.

DEFINE VARIABLE T-subsid AS LOGICAL INITIAL no 
     LABEL "С учетом дополн. карт" 
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .86 NO-UNDO.

DEFINE VARIABLE T-zeros AS LOGICAL INITIAL no 
     LABEL "Нулевые обороты" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY .86 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     selectcard AT ROW 2.19 COL 3 NO-LABEL
     UpLevel AT ROW 5.76 COL 3 NO-LABEL
     T-zeros AT ROW 8.38 COL 3
     T-legacy AT ROW 9.38 COL 3
     T-subsid AT ROW 10.38 COL 3
     T-imp AT ROW 11.38 COL 3
     T-obj-detal AT ROW 12.86 COL 3 WIDGET-ID 26
     label-time AT ROW 2.14 COL 32 NO-LABEL WIDGET-ID 16
     up-levelt AT ROW 4.86 COL 3.2 NO-LABEL
     " Покупатели:" VIEW-AS TEXT
          SIZE 13.8 BY .71 AT ROW 1.38 COL 2.4
          FGCOLOR 4 
     " Представление:" VIEW-AS TEXT
          SIZE 15.8 BY .71 AT ROW 7.52 COL 2.4
          FGCOLOR 4 
     RECT-2 AT ROW 7.81 COL 2
     RECT-3 AT ROW 1.91 COL 31.2
     RECT-client AT ROW 1.67 COL 2
     RECT-4 AT ROW 12.52 COL 2 WIDGET-ID 22
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 47.8 BY 13.43.


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
         HEIGHT             = 13.43
         WIDTH              = 47.8.
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
/* SETTINGS FOR FILL-IN label-time IN FRAME F-Main
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
       label-time:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-3 IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN 
       RECT-3:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN up-levelt IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN UpLevel IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
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

&Scoped-define SELF-NAME selectcard
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL selectcard F-Frame-Win
ON VALUE-CHANGED OF selectcard IN FRAME F-Main
DO:
  assign selectcard.
  CASE selectcard:
    when "selective":U then do:
      run str/dc-list.w (my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
      assign
      FixDCard = ""
      DcardMode = "LIST":U
      .
      find first dc-list no-lock no-error .
      if not available dc-list then do:
        message
        "В списке карт нет ни одной карты"
        view-as alert-box WARNING.
        assign
        selectcard = "all":U
        DcardMode  = "ALL":U
        .
    end. /* if not avail:*/
  end.  /*selective*/
  when "all":U then do:
      assign
      FixDCard = ""
      DcardMode = "ALL":U
      .
  end.
 END CASE.
 display selectcard with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-imp F-Frame-Win
ON VALUE-CHANGED OF T-imp IN FRAME F-Main /* С учетом импорта из ВС */
DO:
  assign T-imp.
  display
    T-imp
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-legacy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-legacy F-Frame-Win
ON VALUE-CHANGED OF T-legacy IN FRAME F-Main /* С учетом перевыпуска карт */
DO:
    if v-dcoveris = "yes" then
    do:
        assign
            T-legacy = yes
        .
    end.
    else
    do:
        assign
            T-legacy = no
        .
        display
            T-legacy
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-obj-detal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-obj-detal F-Frame-Win
ON VALUE-CHANGED OF T-obj-detal IN FRAME F-Main /* Детализация по объектам */
DO:
    assign T-obj-detal.
    assign T-zeros.

/*    assign T-imp.                */
/*                                 */
/*        display                  */
/*            T-imp                */
/*        with frame {&frame-name}.*/

    if T-obj-detal = yes then
    do:
        v-activate-v-tmp-t-zeros = 1. /* Флаг активации "буфера возврата состояния" (что было до этой, запрещаемой ситуации) */
        v-tmp-T-zeros = T-zeros.
        T-zeros = no.
        T-zeros:screen-value in frame F-Main = string(T-zeros).

        disable
            T-zeros
        with frame F-Main.
    end.
    else
    do:
        if v-activate-v-tmp-t-zeros = 1 then T-zeros = v-tmp-T-zeros. /* Если был активирована активация "буфера возврата ситуации", то возвращаем из буффера предыдущее состояние */
        T-zeros:screen-value in frame F-Main = string(T-zeros).
        assign T-zeros.
        enable
            T-zeros
        with frame F-Main.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-subsid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-subsid F-Frame-Win
ON VALUE-CHANGED OF T-subsid IN FRAME F-Main /* С учетом дополн. карт */
DO:
    if v-dcoveris = "yes" then
    do:
        assign T-subsid.
    end.
    else
    do:
        assign T-subsid = no.
        display T-subsid with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-zeros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-zeros F-Frame-Win
ON VALUE-CHANGED OF T-zeros IN FRAME F-Main /* Нулевые обороты */
DO:
/*    assign TotalOnly .*/
    assign T-zeros /* rs-goods */.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win 


/* ***************************  Main Block  *************************** */

{ gbl/personly.i }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
   
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
  DISPLAY selectcard UpLevel T-zeros T-legacy T-subsid T-imp T-obj-detal 
          up-levelt 
      WITH FRAME F-Main.
  ENABLE RECT-2 RECT-client RECT-4 selectcard T-zeros T-legacy T-subsid T-imp 
         T-obj-detal up-levelt 
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
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
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
/*  RUN set-position IN h_s-time ( 1.96 , 34.88 ) NO-ERROR.*/ /* ТН-3320 26.11.2014г. Убрали smartview: s-time в этом окне. */
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  Up-Levelt  = Up-Levelt +
  (if v-curr-r-b = {&r-b-base} then " (вал.)" else " ({&abbr_rub}.)").
  DIsplay Up-levelt
  WITH frame {&frame-name}.
  define variable v-conf-type as character no-undo .
  { gbl/conf-rd.i
  "'dcoveris'"
  0
  "''":U
  0
  "''":U
  "''":U
  "''":U
  NO
  v-dcoveris
  v-conf-type
  NO-ERROR
  }
  IF ERROR-STATUS:ERROR OR v-conf-type <> {&type-log} THEN
    v-dcoveris = "no".

  if v-dcoveris <> "yes" then
    disable
      t-legacy
      t-subsid
    with frame {&frame-name}.

  Up-levelt:visible = false. /* ТН-3320 27.05.2015 Арн. Откл. для нового отчёта: "По Картам Клиентов" (подразумеваемя. что пользователь отфильтрует нужные данные в Excel). Было в старом отчёте "По постоянным клиентам". */
  UpLevel:visible = false.   /* ТН-3320. То-же... */

  disable /* Note-1. Временно (до уточнения представления в отчёте "Дополнительных ДК" и "Перевыпущенных ДК") отключана работа с виджетами toggle */
    t-legacy
    t-subsid
  with frame {&frame-name}.

  /*apply "VALUE-CHANGED" to rs-goods in frame {&frame-name}.*/
  /*Code placed here will execute AFTER standard behavior.*/
  parparentproc = my-handle.
  { gbl/getcntxt.i get }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win 
PROCEDURE My-report :
run My-var.

/* Перед отправкой в rep/r-xldcr2.p - присвоим поля */
assign frame {&frame-name}
    UpLevel
    selectcard
    T-imp
    T-obj-detal
    T-legacy
    T-subsid
    T-zeros
.

run rep/r-xldcr2.p (
                            input parparentproc
                           ,input DcardMode /* ALL | ONE | LIST :U */
                           ,input (if DcardMode = "ALL" then "" else Fixdcard)
                           ,input X-SelectGood
/*                           ,input FixProdAttr*/
/*                           ,input rs-goods /*TotalOnly*/ /* ТН-3320. 26.11.2014г. Арн. */*/
/*                           ,input X-date-Start*/
/*                           ,input X-date-End  */
/*                           ,input T-time*/
                           ,input T-zeros
                           ,input T-legacy
                           ,input T-subsid
/*                           ,input (if X-SelectGood = {&g-all} then "TRUE" else (IF num-g# > 1 then "LIST" else "ONE"))*/
                           ,input T-imp
                           ,input T-obj-detal
/*                           ,input f-lvl-grp*/
                           ,input UpLevel
                           ,input selectcard
                           ,input v-curr-r-b
).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Var F-Frame-Win 
PROCEDURE My-Var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
    frame {&frame-name} selectcard
    /*frame {&frame-name} TotalOnly*/ /* ТН-3320. 26.11.2014г. Арн. */
    frame {&frame-name} UpLevel
    /*frame {&frame-name} T-time*/
    frame {&frame-name} T-legacy
    frame {&frame-name} T-subsid
.

Assign
    STR-obj-type = ''
    STR-obj-code = ''
    STR-obj-name = ''
    STR-obj      = ''
.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
Reportname = "ОТЧЕТ ПО ПОКУПКАМ ПОСТОЯННЫХ КЛИЕНТОВ".
ReportHeader = "Покупатели: " +
                radio-label(string(selectcard), selectcard:radio-buttons) + {&New-line} +
/*              (if TotalOnly then totalOnly:label else "") + {&new-line} +*/
/*                (if rs-goods = 1 then "Только итоги" else "") + {&new-line} +*/
                (If Uplevel > 0
                then string((UpLevel:label + " " + string(Uplevel)))
                else "") +
/*              (IF T-time then string({&new-line} + "Выборочно по времени") else "") +*/
                (IF T-legacy then string({&new-line} + "С учетом перевыпуска карт") else "") +
                (IF T-subsid then string({&new-line} + "С учетом дополнительных карт") else "")
                 .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

