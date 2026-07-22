&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Реестр документов расширенный

Автор: Комаров Иван Сергеевич
Дата создания: 12/28/09
Author: Ivan Komarov
Creation date: 12/28/09

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Реестр документов расширенный".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ rep/rep-bt.i  }
{ rep/gn-extp.i  }
{ rep/par-actu.i }
{ rep/par-actu.i proc }
{ cmp/cli-list.i cli-list def "new shared" }
{ gbl/twowin.i   }
{ rep/reg-par.i  }
{ gbl/usr-flt.i  }
{ cmp/operlist.i }
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source     as WIDGET-HANDLE.
define variable g#log            as logical      no-undo .
define variable post-grp_recids  as character    no-undo .
define variable ii               as integer      no-undo .
define variable v-list-edt       as character    no-undo .
define variable v-list-edt1      as character    no-undo .
define variable v-list-edt2      as character    no-undo .
define variable v-list-edt-full  as character    no-undo .
define variable v-list-edt1-full as character    no-undo .
define variable v-list-edt2-full as character    no-undo .

define buffer cli-post for ub.clients .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-15 RECT-16 RECT-12 RADIO-serv ie em wm ~
ee im ep ot es ap VAT-SLT re pc rs rz-objecte mp we vp CalcRest vt iv ev ~
NullPer rv sl-col-type bt-col-type PostName RADPost
&Scoped-Define DISPLAYED-OBJECTS RADIO-serv ie em wm ee im ep ot es ap ~
VAT-SLT re pc rs rz-objecte mp we vp CalcRest vt iv ev NullPer rv ~
sl-col-type PostName RADPost

/* Custom List Definitions                                              */
/* list-tdedt,List-2,List-3,List-4,List-5,List-6                        */
&Scoped-define list-tdedt ie em wm ee im ep ot es ap re pc rs mp we vp vt ~
iv ev rv

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-col-type
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE VARIABLE PostName AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 30 BY 4.88 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.

DEFINE VARIABLE RADIO-serv AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Реестр по товарам", 1,
"Реестр по услугам", 2
     SIZE 31 BY 2.63 NO-UNDO.

DEFINE VARIABLE RADPost AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Справочник", 2,
"Список", 3
     SIZE 15.63 BY 2.75 NO-UNDO.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 3.33.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 4.71.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 1.71.

DEFINE VARIABLE sl-col-type AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "< Все >","''"
     SIZE 26 BY 5 NO-UNDO.

DEFINE VARIABLE ap AS LOGICAL INITIAL yes
     LABEL "Коррекция учетных цен":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE CalcRest AS LOGICAL INITIAL no
     LABEL "Расчет остатков"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE ee AS LOGICAL INITIAL no
     LABEL "расход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE em AS LOGICAL INITIAL no
     LABEL "расход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE ep AS LOGICAL INITIAL no
     LABEL "возврат поставщику"
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE es AS LOGICAL INITIAL no
     LABEL "касса продажа":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE ev AS LOGICAL INITIAL no
     LABEL "расход внутренний":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE ie AS LOGICAL INITIAL no
     LABEL "приход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE im AS LOGICAL INITIAL no
     LABEL "приход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE iv AS LOGICAL INITIAL no
     LABEL "приход внутренний":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE mp AS LOGICAL INITIAL no
     LABEL "Коррект. отриц. партий":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE NullPer AS LOGICAL INITIAL no
     LABEL "не удалять нулевые переоценки"
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .75 NO-UNDO.

DEFINE VARIABLE ot AS LOGICAL INITIAL no
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE pc AS LOGICAL INITIAL no
     LABEL "Смена типа приобретения":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.13 BY .75 NO-UNDO.

DEFINE VARIABLE re AS LOGICAL INITIAL no
     LABEL "возврат внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE rs AS LOGICAL INITIAL no
     LABEL "касса возврат":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE rv AS LOGICAL INITIAL no
     LABEL "возврат внутренний":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.63 BY .75 NO-UNDO.

DEFINE VARIABLE rz-objecte AS LOGICAL INITIAL no
     LABEL "Раздельно по объектам"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .79 NO-UNDO.

DEFINE VARIABLE VAT-SLT AS LOGICAL INITIAL no
     LABEL "Распределение НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE vp AS LOGICAL INITIAL no
     LABEL "Пересортица":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE vt AS LOGICAL INITIAL no
     LABEL "инвентаризация":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE we AS LOGICAL INITIAL no
     LABEL "списание":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE wm AS LOGICAL INITIAL no
     LABEL "списан. произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RADIO-serv AT ROW 1.63 COL 4.5 NO-LABEL WIDGET-ID 26
     ie AT ROW 1.88  COL 39.38 WIDGET-ID 92
     ee AT ROW 2.80  COL 39.38 WIDGET-ID 82
     ep AT ROW 3.72  COL 39.38 WIDGET-ID 86
     es AT ROW 4.64  COL 39.38 WIDGET-ID 88
     re AT ROW 5.56  COL 39.38 WIDGET-ID 104
     rs AT ROW 6.48  COL 39.38 WIDGET-ID 106
     we AT ROW 7.4   COL 39.38 WIDGET-ID 112
     vt AT ROW 8.32  COL 39.38 WIDGET-ID 110
     iv AT ROW 9.24  COL 39.38 WIDGET-ID 96
     ev AT ROW 10.16 COL 39.38 WIDGET-ID 90
     rv AT ROW 11.08 COL 39.38 WIDGET-ID 108
     em AT ROW 1.88  COL 63.5 WIDGET-ID 84
     wm AT ROW 2.80  COL 63.5 WIDGET-ID 114
     im AT ROW 3.72  COL 63.5 WIDGET-ID 94
     ot AT ROW 4.64  COL 63.5 WIDGET-ID 100
     ap AT ROW 5.56  COL 63.5 WIDGET-ID 80
     pc AT ROW 6.48  COL 63.5 WIDGET-ID 98
     mp AT ROW 7.4   COL 63.5 WIDGET-ID 102
     vp AT ROW 8.32  COL 63.5 WIDGET-ID 118
     VAT-SLT AT ROW 5.5 COL 4.5
     rz-objecte AT ROW 6.79 COL 4.5 WIDGET-ID 30
     CalcRest AT ROW 8.21 COL 4.5
     NullPer AT ROW 10.42 COL 4.5
     sl-col-type AT ROW 13.13 COL 2 NO-LABEL WIDGET-ID 36
     bt-col-type AT ROW 13.13 COL 28.5 WIDGET-ID 38
     PostName AT ROW 13.13 COL 39.38 NO-LABEL WIDGET-ID 24
     RADPost AT ROW 13.25 COL 71 NO-LABEL WIDGET-ID 20
     "Выбор колонок для печати" VIEW-AS TEXT
          SIZE 26 BY .67 AT ROW 12.21 COL 2 WIDGET-ID 34
          FGCOLOR 4
     "Учитывать только типы документов:" VIEW-AS TEXT
          SIZE 37 BY .67 AT ROW 1.08 COL 39.63 WIDGET-ID 4
          FGCOLOR 4
     "Выбор поставщика:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 12.25 COL 39.5 WIDGET-ID 18
          FGCOLOR 4
     RECT-15 AT ROW 4.79 COL 3
     RECT-16 AT ROW 9.75 COL 3
     RECT-12 AT ROW 1.25 COL 3
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 18.13
         WIDTH              = 92.25.
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

/* SETTINGS FOR TOGGLE-BOX ap IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ee IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX em IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ep IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX es IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ev IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ie IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX im IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX iv IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX mp IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ot IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX pc IN FRAME F-Main
   1                                                                    */
ASSIGN
       PostName:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR TOGGLE-BOX re IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX rs IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX rv IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX vp IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX vt IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX we IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX wm IN FRAME F-Main
   1                                                                    */
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

&Scoped-define SELF-NAME bt-col-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-col-type s-object
ON CHOOSE OF bt-col-type IN FRAME F-Main /* Изменить */
DO:
    run select-col-type in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-serv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-serv s-object
ON VALUE-CHANGED OF RADIO-serv IN FRAME F-Main
DO:
  ASSIGN
    RADIO-serv
  .
  IF RADIO-serv = 2
  THEN DO:
    ASSIGN
        CalcRest = FALSE
    .
    DISPLAY
        CalcRest
    WITH FRAME F-Main.
    DISABLE
        CalcRest
    WITH FRAME F-Main.
  END.
  ELSE DO:
    ENABLE
        CalcRest
    WITH FRAME F-Main.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADPost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADPost s-object
ON VALUE-CHANGED OF RADPost IN FRAME F-Main
DO:
   Assign RadPost.
   for each g#post-f :
         delete g#post-f.
   end.
   Case RAdPost :
   when 3
   then DO:
      run str/cli-list.w
         ( my-handle,
            v-cntxt-host-code-obj,
            v-cntxt-obj-type,
            v-cntxt-obj-code)
            .
      Postname = "" .
      For each cli-list :
         /*
         find first cli-grp where cli-grp.node-code = cli-list.grp-code no-lock no-error .
         if available cli-grp then do:
               g#post-f.lvl-num  = cli-grp.lvl-num
         end.
         */
         create g#post-f.
         assign
            g#post-f.obj-type = cli-list.obj-type
            g#post-f.obj-code = cli-list.obj-code
            g#post-f.obj-name = cli-list.obj-name
            g#post-f.grp-code = cli-list.grp-code
            g#post-f.grp-name = cli-list.grp-name
            Postname = Postname + cli-list.obj-name + chr(10)
         .
      End.
      Display
         PostName
      with frame {&FRAME-NAME} .
   END.

   when 1
   then DO:
      Assign
         Postname = ""
      .
      Display
         PostName
      with frame {&FRAME-NAME} .
   END.
   when 2
   then do:
      run ref/cli-all.w ( my-handle
                        , "b-sel,b-mark"
                        , {&cmp}
                        , {&all}
                        , {&current}
                        , ?
                        , ",,,,,,NO,,"
                        , ?
                        , output post-grp_recids
                        ) .

      if post-grp_recids = ""
      then do:
         Assign
            Postname = {&all}
            radpost = 1
         .
         Display
            PostName
            radpost
         with frame {&FRAME-NAME}.
      end.
      else do:
         Assign
            Postname = ''
         .
         DO ii = 1 TO num-entries( post-grp_recids )
         :
            FIND FIRST cli-post
                 where recid( cli-post ) = int(entry( ii, post-grp_recids ))
                 no-lock
                 no-error
                 .
               /*
            if cli-post.obj-type = {&cmp}
            or cli-post.obj-type = {&prs}
            then do:
               find first cli-grp where cli-grp.node-code = cli-post.grp-code no-lock no-error .
               if available cli-post and available cli-grp then do:
                     g#post-f.lvl-num  = cli-grp.lvl-num
               end.
            end.
               */
            create g#post-f.
            assign
               g#post-f.obj-type = cli-post.obj-type
               g#post-f.obj-code = cli-post.obj-code
               g#post-f.obj-name = cli-post.obj-name
               g#post-f.grp-code = cli-post.grp-code
               g#post-f.grp-name = cli-post.grp-name
               Postname = PostName + cli-post.obj-name + chr(10)
            .
         END.
         Display PostName with frame {&FRAME-NAME} .
      end.
   end.
   End case.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  run dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF
define variable  list-com-hand as character no-undo .
define variable var-r-b as character no-undo .
{ gbl/curr-r-b.i var-r-b }

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI s-object  _DEFAULT-ENABLE
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
  DISPLAY RADIO-serv ie em wm ee im ep ot es ap VAT-SLT re pc rs rz-objecte mp
          we vp CalcRest vt iv ev NullPer rv sl-col-type PostName RADPost
      WITH FRAME F-Main.
  ENABLE RECT-15 RECT-16 RECT-12 RADIO-serv ie em wm ee im ep ot es ap VAT-SLT
         re pc rs rz-objecte mp we vp CalcRest vt iv ev NullPer rv sl-col-type
         bt-col-type PostName RADPost
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------------------------------------------------------*/
define variable v-void-log    as logical      no-undo .
define variable v-call-point  as character    no-undo .
define variable v-naim        as character    no-undo .
define variable v-list        as character    no-undo .
define variable v-counter     as integer      no-undo .
define variable v-found       as logical      no-undo .
define variable v-widget      as handle       no-undo .
define variable v-ok          as logical      no-undo .

v-ok = RADIO-serv:disable (radio-label("2", RADIO-serv:radio-buttons)) in frame {&frame-name} .
   assign
      v-list-edt1 = {&N-doc-print} + {&comma-char}
                  + {&N-doc-post} + {&comma-char}
                  + {&N-sf} + {&comma-char}
                  + {&d-sf} + {&comma-char}
                  + {&qnty} + {&comma-char}
                  + {&sum-vat}
      v-list-edt2 = {&vat} + {&comma-char}
                  + {&sum-no-vat} + {&comma-char}
                  + {&sum-discount} + {&comma-char}
/*                  + {&sum-auto-mrgn} + {&comma-char} */
                  + {&d-doc-post} + {&comma-char}
                  + {&mark-up} + {&comma-char}
                  + {&mark-up-noNDS} + {&comma-char}
                  + {&reason}
      v-list-edt = v-list-edt1 + {&comma-char} + v-list-edt2
      v-list-edt1-full  = {&N-doc-print} + {&comma-char}
                        + {&N-doc-post} + {&comma-char}
                        + {&N-sf} + {&comma-char}
                        + {&d-sf} + {&comma-char}
                        + {&qnty} + {&comma-char}
                        + {&sum-vat}
      v-list-edt2-full  = {&vat} + {&comma-char}
                        + {&sum-no-vat} + {&comma-char}
                        + {&sum-discount} + {&comma-char}
/*                        + {&sum-auto-mrgn} + {&comma-char} */
                        + {&d-doc-post} + {&comma-char}
                        + {&mark-up} + {&comma-char}
                        + {&mark-up-noNDS} + {&comma-char}
                        + {&reason}
      v-list-edt-full = v-list-edt1-full + {&comma-char} +  v-list-edt2-full
      v-widget = FRAME {&frame-name}:FIRST-CHILD
      v-widget = v-widget:FIRST-CHILD
      v-call-point = {&uf-regdoc}
   .
   run uf-get ( input v-call-point
                     , input v-cntxt-userid
                     , output v-list         /* все TOGGLE-BOX */
                     , output v-naim
                     , output v-void-log
                     , output v-void-log
                     , output v-void-log
                     , output v-void-log
                     ) .
      DO WHILE  VALID-HANDLE(v-widget)
      :

         IF  v-widget:TYPE = "TOGGLE-BOX":U
         THEN DO:
            ASSIGN
               v-widget:CHECKED      = LOOKUP (v-widget:NAME, v-list) > 0
            .
         END.
         assign
            v-widget = v-widget:NEXT-SIBLING
         .
      END.
      IF v-naim <> "":U
      THEN DO:
         ASSIGN
            sl-col-type :list-item-pairs = v-naim
         .
      END.
      ELSE DO:
         ASSIGN
            sl-col-type :list-item-pairs = "< Все >,"
         .

      END.



  run dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-cost':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    g#log
  }
   if not  g#log then do :
/*   CostSum = false . */
   /*DispUpFact = false .
   disable CostSum DispUpFact  with frame {&frame-name} .
   display CostSum  DispUpFact with frame {&frame-name} .  */
 end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
define variable v-call-point  as character  no-undo .
define variable v-naim        as character  no-undo .
define variable v-list        as character  no-undo .
define variable v-counter     as integer    no-undo .
define variable v-widget      as handle     no-undo .

   FOR EACH tdedt:
      DELETE tdedt.
   END.
  DO
  WITH FRAME F-Main
  :
  ASSIGN
      ie em VAT-SLT wm ee rz-objecte im ep ot es RADIO-serv ap re pc rs mp
          we vp vt CalcRest iv ev NullPer rv
      .
  END.

   IF ie then  do: { rep/r-mtdedt.i {&TDEDT_Pri_Vnesh}    01 }       END.
   IF ee then  do: { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh}    02 }       END.
   IF ep then  do: { rep/r-mtdedt.i {&TDEDT_RAS_Vnesh_VP}  03}       END.
   IF es then  do: { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh_Kass} 04 }     END.
   IF re then  do: { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh} 05 }      END.
   IF rs then  do: { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh_Kass} 06 } END.
   IF we then  do: { rep/r-mtdedt.i {&TDEDT_Spi_Vnesh} 07 }          END.
   IF vt then  do: { rep/r-mtdedt.i {&TDEDT_Inv} 08 }                END.
   IF iv then  do: { rep/r-mtdedt.i {&TDEDT_Pri_Perem} 09 }          END.
   IF ev then  do: { rep/r-mtdedt.i {&TDEDT_Ras_Perem} 10 }          END.
   IF rv then  do: { rep/r-mtdedt.i {&TDEDT_Vozvrat_Perem} 11 }      END.
   IF em then  do: { rep/r-mtdedt.i {&TDEDT_Ras_Prvo} 12 }           END.
   IF wm then  do: { rep/r-mtdedt.i {&TDEDT_Spi_Prvo} 13 }           END.
   IF im then  do: { rep/r-mtdedt.i {&TDEDT_Pri_Prvo} 14 }           END.
   IF ot then  do: { rep/r-mtdedt.i {&TDEDT_Overturn} 15 }           END.
   IF ap then  do: { rep/r-mtdedt.i {&TDEDT_Corr_Acc_Price} 16 }     END.
   IF pc then  do: { rep/r-mtdedt.i {&TDEDT_Chg_Purch_Code} 17 }     END.
   IF mp then  do: { rep/r-mtdedt.i {&TDEDT_Corr_Minus_Parts} 18 }   END.
   IF vp then  do: { rep/r-mtdedt.i {&TDEDT_Peresort} 19 }           END.


   IF  NOT can-find (FIRST temp_twowin_itemsSelected_col)
   THEN DO:
      IF INDEX(sl-col-type :list-item-pairs, "<") > 0
      THEN DO:
         run twowin_clear in this-procedure.

         do v-counter = 1 to num-entries( v-list-edt-full )
         with frame {&frame-name}
         on error undo, return error
         :
            create temp_twowin_itemsSelected_col.
            assign
               temp_twowin_itemsSelected_col.its-key   = v-counter
               temp_twowin_itemsSelected_col.itm-key   = v-counter
               temp_twowin_itemsSelected_col.itmExtKey = entry( v-counter, v-list-edt )
            .
         end.        /* do */
      END.
      ELSE DO:
         run twowin_clear in this-procedure.

         do v-counter = 1 to num-entries( sl-col-type :list-item-pairs )
         with frame {&frame-name}
         on error undo, return error
         :
            create temp_twowin_itemsSelected_col.
            assign
               temp_twowin_itemsSelected_col.its-key   = v-counter
               temp_twowin_itemsSelected_col.itm-key   = v-counter
               temp_twowin_itemsSelected_col.itmExtKey = entry( v-counter, sl-col-type:list-item-pairs )
            .
         end.        /* do */
      END.
   END.

   /* Сохранить параметры */
   assign
      v-naim = sl-col-type :list-item-pairs
   .


   assign
      v-list       = "":U
      v-call-point = {&uf-regdoc}
   .
   assign
      v-widget = FRAME {&frame-name}:FIRST-CHILD
      v-widget = v-widget:FIRST-CHILD
   .

   DO WHILE  VALID-HANDLE(v-widget)
   :

      IF  v-widget:TYPE = "TOGGLE-BOX":U
      AND v-widget:CHECKED = TRUE
      THEN DO:
         ASSIGN
            v-list = v-list + "," + v-widget:NAME
         .
      END.
      assign
         v-widget = v-widget:NEXT-SIBLING
      .
   END.


   run uf-set ( input v-call-point
                    , input v-cntxt-userid
                    , input v-list
                    , input v-naim
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    ) .

   run rep/r-regdoc.p
          ( input v-cntxt-obj-code ,
            input v-cntxt-obj-type ,
            input base-type,
            input base-code,
            input VAT-SLT,     /*НДС детально*/
            input radio-serv,  /* Услуги-товары*/
            input NullPer,     /* Нулевые переоценки */
            input CalcRest,     /*Расчет остатков*/
            input table temp_twowin_itemsSelected_col, /*Колонки для печати*/
            input table g#post-f,
            input rz-objecte ,
            input x-SelectGood

            )    /* раздельно по объектам */
     .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} {&list-tdedt}
 VAT-SLT
 radio-serv
 rz-objecte
 CalcRest
 NullPer
 .

 assign
 ReportHeader   = {&new-line}
                + (if radio-serv = 1 then "Отчет по товарам," else "Отчет по услугам,":U ) + {&new-line}
                + (if x-SET_val_TYPE = {&v-rubl} then "В {&abbr_rublyah},"  else "в базовой валюте,") + {&new-line}
                + (if VAT-SLT then "Распределение НДС," + {&new-line} else "":U)
                + (if rz-objecte then "Раздельно по объектам," + {&new-line} else "":U)
                + (if CalcRest then "Расчет остатков," + {&new-line} else "":U)
                + (if NullPer and ot then "Выводятся нулевые переоценки," + {&new-line} else "":U)
                + "Выбор поставщика: " + (if Postname = "":U then {&all}  else Postname)
 .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE report-to-ach s-object
PROCEDURE report-to-ach :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
 DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR param-to-export .

  for each  param-to-export : delete  param-to-export. end.
 { rep/par-std.i }

{ rep/par-actu.i run-proc
 "'vat-slt'                           "
 "''                                  "
 "'logical'                           "
 "string(vat-slt,'yes/no')            "
 "vat-slt:label in frame {&frame-name}"
 }

{ rep/par-actu.i run-proc
 "'null-pricelist'                                    "
 "''                                                  "
 "'logical'                                           "
 "string(nullper,'yes/no')                            "
 "nullper:label in frame {&frame-name}                "

    }

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-col-type s-object
PROCEDURE select-col-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable v-counter    as integer    no-undo .
define variable v-label      as character  no-undo .
define variable v-value      as character  no-undo .
define variable v-list       as character  no-undo .
define variable v-changed    as logical    no-undo .
define variable v-accepted   as logical    no-undo .

do
with frame {&frame-name}
on error undo, return error
:
    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( v-list-edt-full )
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, v-list-edt-full )
            v-value = entry( v-counter, v-list-edt )
        .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Колонка: &1", v-value )
            , input ( sl-col-type :lookup( v-value ) <> 0 or sl-col-type :list-item-pairs = "< Все >,''":U  )
        ).
    end.        /* do */
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор колонок":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-changed
        , output v-accepted
    ).
    if  v-accepted = yes
    and v-changed = yes
    then do:

        IF NOT CAN-FIND( FIRST temp_twowin_itemsSelected_col )
        THEN DO:
            assign
                  sl-col-type :list-item-pairs    = "Нет выбранных колонок,''":U
                  v-list                          = "":U
                  v-counter = 0
            .
            return.
        END.
        assign
            sl-col-type :list-item-pairs    = "< Все >,''":U
            v-list                          = "":U
            v-counter = 0
        .
        for each temp_twowin_itemsSelected_col
        by temp_twowin_itemsSelected_col.itm-key
        :
            assign
                v-counter = v-counter + 1
                v-list = substitute( "&1&2&3"
                                , v-list
                                , ( if v-list = "":U then "":U else ",":U )
                                , temp_twowin_itemsSelected_col.itmExtKey
                                )
            .
            if v-counter = 1
            then do:
                assign
                    sl-col-type :list-item-pairs    = substitute( "&1,&2"
                                        , entry( lookup( temp_twowin_itemsSelected_col.itmExtKey, v-list-edt ), v-list-edt-full )
                                        , temp_twowin_itemsSelected_col.itmExtKey
                                             )
                .
            end.
            else do:
                sl-col-type :add-last (
                    entry( lookup( temp_twowin_itemsSelected_col.itmExtKey, v-list-edt ), v-list-edt-full )
                    , temp_twowin_itemsSelected_col.itmExtKey
                ).
            end.
        end.
        if v-list = v-list-edt
        then do:
            assign
                sl-col-type :list-item-pairs = "< Все >,''":U
            .
        end.

    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME