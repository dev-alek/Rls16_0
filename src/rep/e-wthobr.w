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

Отчет оборотная ведомость серийных МЦ по контрагентам (ЗАКЛАДКА №2)

Автор: Хныкин Павел Андреевич
Дата создания: 07/04/07
Author: Pavel Khnykin
Creation date: 07/04/07

*/

/* no app_help.i */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет оборотная ведомость серийных МЦ по контрагентам (ЗАКЛАДКА №2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/cli-list.i cli-list def "new shared" }
{ rep/wthobr.i   }
{ gbl/usr-flt.i }

define variable v-wth-recid-list      as character no-undo .
define variable v-clients-recid-list  as character no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-3 ed-supp t-calc rs-supp ~
rs-wth-type ed-wth rs-wth cb-wth-detail
&Scoped-Define DISPLAYED-OBJECTS ed-supp t-calc rs-supp f-dtFrom f-dtTo ~
rs-wth-type ed-wth rs-wth cb-wth-detail

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE cb-wth-detail AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "",1
     DROP-DOWN-LIST
     SIZE 19.5 BY 1 NO-UNDO.

DEFINE VARIABLE ed-supp AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 32.5 BY 5.5
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ed-wth AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 46.5 BY 4.75
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-dtFrom AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-dtTo AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE rs-supp AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Справочник", 2,
"Список", 3
     SIZE 14 BY 2 NO-UNDO.

DEFINE VARIABLE rs-wth AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Справочник", 2
     SIZE 13 BY 1.5 NO-UNDO.

DEFINE VARIABLE rs-wth-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "МЦ", 1,
"Номиналы", 2,
"Серии", 3
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE t-calc AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По фактической дате", 1,
"По началу срока годности", 2,
"По фактич. дате, с учетом", 3
     SIZE 30.5 BY 3 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.5 BY 7.25.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 81 BY 9.5.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33 BY 7.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     ed-supp AT ROW 2.5 COL 48.5 NO-LABEL WIDGET-ID 6
     t-calc AT ROW 2.75 COL 2.5 NO-LABEL WIDGET-ID 36
     rs-supp AT ROW 3 COL 34.5 NO-LABEL WIDGET-ID 2
     f-dtFrom AT ROW 6.75 COL 1.5 WIDGET-ID 48
     f-dtTo AT ROW 6.75 COL 19 COLON-ALIGNED WIDGET-ID 50
     rs-wth-type AT ROW 9.75 COL 2.5 NO-LABEL WIDGET-ID 16
     ed-wth AT ROW 11 COL 23.5 NO-LABEL WIDGET-ID 24
     rs-wth AT ROW 11.5 COL 10 NO-LABEL WIDGET-ID 20
     cb-wth-detail AT ROW 16 COL 21.5 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     "Способ расчета :" VIEW-AS TEXT
          SIZE 16 BY .67 AT ROW 1.5 COL 2.5 WIDGET-ID 44
          FGCOLOR 4
     "Контрагенты :" VIEW-AS TEXT
          SIZE 14 BY .67 AT ROW 1.5 COL 35.5 WIDGET-ID 8
          FGCOLOR 4
     "Материальные ценности :" VIEW-AS TEXT
          SIZE 27.5 BY .67 AT ROW 8.75 COL 2.5 WIDGET-ID 30
          FGCOLOR 4
     "Уровень детализации:" VIEW-AS TEXT
          SIZE 21 BY .67 AT ROW 16.25 COL 2.5 WIDGET-ID 34
          FGCOLOR 4
     "срока годности" VIEW-AS TEXT
          SIZE 16.5 BY .67 AT ROW 5.5 COL 4.5 WIDGET-ID 42
     RECT-1 AT ROW 1 COL 33.5 WIDGET-ID 26
     RECT-2 AT ROW 8.29 COL 1 WIDGET-ID 28
     RECT-3 AT ROW 1 COL 1 WIDGET-ID 46
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 .


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
         HEIGHT             = 17.33
         WIDTH              = 81.63.
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
       ed-supp:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN
       ed-wth:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN f-dtFrom IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       f-dtFrom:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN f-dtTo IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       f-dtTo:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME rs-supp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-supp s-object
ON VALUE-CHANGED OF rs-supp IN FRAME F-Main
DO:
  assign
    rs-supp
  .
  run proc-change-sup in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-wth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-wth s-object
ON VALUE-CHANGED OF rs-wth IN FRAME F-Main
DO:
  assign
    rs-wth
    rs-wth-type
  .
  run proc-change-wth in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-wth-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-wth-type s-object
ON VALUE-CHANGED OF rs-wth-type IN FRAME F-Main
DO:
  assign
    rs-wth
    rs-wth-type
  .
  run proc-change-wth-type in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-calc s-object
ON VALUE-CHANGED OF t-calc IN FRAME F-Main
DO:
  IF SELF:SCREEN-VALUE = '3' THEN DO:
      ENABLE f-dtFrom f-dtTo WITH FRAME {&FRAME-NAME}.
      apply "entry":U to f-dtFrom.

  END.
  ELSE DO:
      DISABLE f-dtFrom f-dtTo WITH FRAME {&FRAME-NAME}.
      hide f-dtFrom f-dtTo in FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */


/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .
  /* Code placed here will execute AFTER standard behavior.    */
  define buffer buf_clients for ub.clients.
  define buffer buf_wth-ser for ub.wth-ser.
  define buffer buf_wealth  for ub.wealth.
  define buffer buf_wth-par for ub.wth-par.

  define variable v-userid         as character        no-undo.
  define variable v-call-point     as character        no-undo.
  define variable v-naim           as character        no-undo.
  define variable v-list           as character        no-undo.
  define variable v-print-graft    as logical          no-undo.
  define variable v-sort-gr        as logical          no-undo.
  define variable v-type-price     as logical          no-undo.
  define variable v-type-val       as logical          no-undo.

  define variable v-found               as logical   no-undo .
  define variable v-wth-str             as character no-undo .
  define variable v-sup-str             as character no-undo .
  define variable v-i                   as integer   no-undo .
  define variable v-supp-name-list      as character no-undo .
  define variable v-rs-wth              as integer   no-undo .
  define variable v-rs-wth-type         as integer   no-undo .
  define variable v-cb-wth-detail       as integer   no-undo .
  define variable v-wth-list            as character no-undo .
  define variable v-list-item-str as character no-undo .

  assign
    v-list-item-str = "{&bef-wth-no-detail-full},{&wth-no-detail}," +
                      "{&bef-wth-wealth-detail-full},{&wth-wealth-detail}," +
                      "{&bef-wth-wealth-par-detail-full},{&wth-wealth-par-detail}," +
                      "{&bef-wth-wealth-ser-detail-full},{&wth-wealth-ser-detail}":U
    cb-wth-detail:list-item-pairs in frame {&frame-name} = v-list-item-str
  .

  assign
    ed-supp = "Все":U
    ed-wth  = "Все":U
    cb-wth-detail = 1
  .


  run uf-get ( input {&uf-wthobr-sup}
             , input v-cntxt-userid
             , output v-sup-str
             , output v-clients-recid-list
             , output v-print-graft
             , output v-sort-gr
             , output v-type-price
             , output v-type-val
             ) .
  assign
    v-i     = integer( v-sup-str )
    rs-supp = v-i
  .

  if v-i = 1
  then do:
    assign
      ed-supp = "Все"
    .
  end.
  else do:
    do v-i = 1 to num-entries(v-clients-recid-list)
    :
      find first buf_clients no-lock
        where recid(buf_clients) = integer( entry(v-i,v-clients-recid-list))
      no-error .
      if available buf_clients
      then do:
        assign
          v-supp-name-list = v-supp-name-list + buf_clients.obj-name + {&new-line}
        .
      end.
    end.
    assign
      ed-supp = v-supp-name-list
    .
  end.

  run uf-get ( input {&uf-wthobr-wth}
             , input v-cntxt-userid
             , output v-wth-recid-list
             , output v-wth-str
             , output v-print-graft
             , output v-sort-gr
             , output v-type-price
             , output v-type-val
             ) .
  if num-entries(v-wth-str) = 3
  then do:
    assign
      v-rs-wth-type   = integer(entry( 1 , v-wth-str ))
      v-rs-wth        = integer(entry( 2 , v-wth-str ))
      v-cb-wth-detail = integer(entry( 3 , v-wth-str ))
      rs-wth-type     = v-rs-wth-type
      rs-wth          = v-rs-wth
      cb-wth-detail   = v-cb-wth-detail
    .
    if v-rs-wth = 1
    then do:
      assign
        v-wth-list = "Все":U
      .
    end.
    else do:
      case rs-wth-type :
        when 1 then do:
          assign
            v-wth-list        = "МЦ :":U + {&new-line}
          .
          do v-i = 1 to num-entries( v-wth-recid-list ) :
            find first buf_wealth no-lock
              where recid(buf_wealth) = integer( entry( v-i , v-wth-recid-list ) )
            no-error .
            if available buf_wealth then do:
              assign
                v-wth-list = v-wth-list + buf_wealth.wth-name + {&new-line}
              .
            end.
          end.
        end.
        when 2 then do:
          assign
            v-wth-list        = "Номиналы :":U + {&new-line}
          .
          do v-i = 1 to num-entries(v-wth-recid-list) :
            find first buf_wth-par no-lock
              where recid(buf_wth-par) = integer( entry( v-i , v-wth-recid-list ) )
            no-error .
            if available buf_wth-par then do:
              find first buf_wealth no-lock
                where buf_wealth.wth-code = buf_wth-par.wth-code
              no-error .
              if available buf_wealth then do:
                assign
                  v-wth-list = v-wth-list + substitute( "&1 - &2 &3&4"
                                                      , buf_wealth.wth-name
                                                      , buf_wth-par.par-val
                                                      , buf_wth-par.par-unit
                                                      , {&new-line}
                                                      )
                .
              end.
            end.
          end.
        end.
        when 3 then do:
          assign
            v-wth-list        = "Серии :":U + {&new-line}
          .
          do v-i = 1 to num-entries(v-wth-recid-list) :
            find first buf_wth-ser no-lock
              where recid(buf_wth-ser) = integer( entry( v-i , v-wth-recid-list ) )
            no-error .
            if available buf_wth-ser then do:
              find first buf_wealth no-lock
                where buf_wealth.wth-code = buf_wth-ser.wth-code
              no-error .
              find first buf_wth-par no-lock
                where buf_wth-par.wth-code = buf_wth-ser.wth-code
                  and buf_wth-par.par-code = buf_wth-ser.par-code
              no-error .
              if available buf_wealth and available buf_wth-par then do:
                assign
                  v-wth-list = v-wth-list + substitute( "&1 : &2 - &3 &4&5"
                                                      , buf_wth-ser.series
                                                      , buf_wealth.wth-name
                                                      , buf_wth-par.par-val
                                                      , buf_wth-par.par-unit
                                                      , {&new-line}
                                                      )
                .
              end.
            end.
          end.
        end.
      end case.
      assign
        ed-wth = v-wth-list
      .
    end.
  end.

  display
    ed-supp
    rs-supp
    rs-wth-type
    ed-wth
    rs-wth
    cb-wth-detail
  with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/

define variable v-userid         as character        no-undo.
define variable v-call-point     as character        no-undo.
define variable v-naim           as character        no-undo.
define variable v-list           as character        no-undo.
define variable v-print-graft    as logical          no-undo.
define variable v-sort-gr        as logical          no-undo.
define variable v-type-price     as logical          no-undo.
define variable v-type-val       as logical          no-undo.

define variable v-wth-str        as character        no-undo .
define variable v-sup-str        as character        no-undo .

  assign frame {&frame-name}
    rs-supp
    rs-wth-type
    rs-wth
    cb-wth-detail
    t-calc
    f-dtFrom
    f-dtTo
  .

  assign
    v-sup-str = string(rs-supp)
  .

   run uf-set( input {&uf-wthobr-sup}
             , input v-cntxt-userid
             , input v-sup-str
             , input v-clients-recid-list
             , input v-print-graft
             , input v-sort-gr
             , input v-type-price
             , input v-type-val
             ) .

  assign
    v-wth-str = string(rs-wth-type) + ',' + string(rs-wth) + ',' + string(cb-wth-detail)
  .

  run uf-set ( input {&uf-wthobr-wth}
             , input v-cntxt-userid
             , input v-wth-recid-list
             , input v-wth-str
             , input v-print-graft
             , input v-sort-gr
             , input v-type-price
             , input v-type-val
             ) .

  run rep/r-wthobr.p ( input my-handle
                     , input rs-supp
                     , input rs-wth-type
                     , input rs-wth
                     , input cb-wth-detail
                     , input v-clients-recid-list
                     , input v-wth-recid-list
                     , input t-calc
                     , input f-dtFrom
                     , input f-dtTo).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???

------------------------------------------------------------------------------*/
  &scop my-tab fill( ' ' , 3 )
  define variable v-i as integer.

  assign frame {&frame-name}
    ed-supp
    ed-wth
    rs-supp
    rs-wth
    t-calc
    f-dtFrom
    f-dtTo
  .
    assign
    ReportHeader = {&new-line} + "Выбор даты: ":U
  .
  if t-calc = 1 then     assign
    ReportHeader = ReportHeader + "Фактические даты".
  else    if t-calc = 1 then     assign
    ReportHeader = ReportHeader + "По сроку годности".
  else   ReportHeader = ReportHeader + substitute("Фактические даты и Срок годности с &1 по &2"
                                           ,f-dtFrom
                                           ,f-dtTo).

  assign
    ReportHeader = ReportHeader +  {&new-line} + "Контрагенты : ":U
  .

  if rs-supp <> 1 then do:
    assign
      ReportHeader = ReportHeader + {&new-line}
    .
    do v-i = 1 to num-entries( ed-supp , {&new-line} ):
      assign
        ReportHeader = ReportHeader + {&my-tab} + entry( v-i , ed-supp , {&new-line} ) + {&new-line}
      .
    end.
  end.
  else do:
    assign
      ReportHeader = ReportHeader + ed-supp + {&new-line} + {&new-line}
    .
  end.
  assign
    ReportHeader = ReportHeader + "Материальные ценности : ":U
  .
  if rs-wth = 1 then do:
    assign
      ReportHeader = ReportHeader + ed-wth
    .
  end.
  else do:
    assign
      ReportHeader = ReportHeader + {&new-line} + {&my-tab} + entry( 1 , ed-wth , {&new-line} ) + {&new-line}
    .
    do v-i = 2 to num-entries( ed-wth , {&new-line} ) :
      assign
        ReportHeader = ReportHeader + {&my-tab} + {&my-tab} + entry( v-i , ed-wth , {&new-line} ) + {&new-line}
      .
    end.
  end.
  assign
    ReportHeader = ReportHeader + {&new-line} + "Уровень детализации: ":U + entry( cb-wth-detail , {&wth-wealth-list})
  .
  /*ReportHeader = "Контрагенты : " + (if radpost = 1 then "Все" else PostName) + chr(10).*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-change-sup s-object
PROCEDURE proc-change-sup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients for ub.clients.

define variable v-supp-recid-list as character no-undo .
define variable v-supp-name-list  as character no-undo .
define variable v-i               as integer   no-undo .
define variable v-total           as integer   no-undo .

assign
  v-clients-recid-list = '':U
.

case rs-supp :
  when 1 then do:
    assign
      ed-supp = "Все"
    .
  end.
  when 2 then do:
    run ref/cli-all.w ( input my-handle
                      , "b-sel,b-mark"
                      , {&cmp}
                      , {&all}
                      , {&current}
                      , ?
                      , ",,,,,,NO,,"
                      , ?
                      , output v-supp-recid-list
                      ) .
    if v-supp-recid-list = "" then do:
      assign
        rs-supp = 1
        ed-supp = "Все"
      .
    end.
    else do:
      assign
        v-total = num-entries(v-supp-recid-list)
      .
      do v-i = 1 to v-total :
        find first buf_clients no-lock
          where recid(buf_clients) = integer( entry( v-i , v-supp-recid-list))
        no-error .
        if available buf_clients then do:
          assign
            v-clients-recid-list = v-clients-recid-list + string(recid(buf_clients)) + ','
            v-supp-name-list     = v-supp-name-list + buf_clients.obj-name + {&new-line}
          .
        end.
      end.
      assign
        ed-supp = v-supp-name-list
      .
    end.
  end.
  when 3 then do:
    run str/cli-list.w ( input my-handle
                       , input v-cntxt-host-code-obj
                       , input v-cntxt-obj-type
                       , input v-cntxt-obj-code
                       ) .
    find first cli-list no-lock no-error .
    if not available cli-list then do:
      assign
        rs-supp = 1
        ed-supp = "Все"
      .
    end.
    else do:
      for each cli-list :
        find first buf_clients no-lock
          where buf_clients.obj-type = cli-list.obj-type
            and buf_clients.obj-code = cli-list.obj-code
        no-error .
        if available buf_clients
        then do:
          assign
            v-clients-recid-list = v-clients-recid-list + string(recid(buf_clients)) + ','
            v-supp-name-list     = v-supp-name-list + cli-list.obj-name + {&new-line}
          .
        end.
      end.
      assign
        ed-supp = v-supp-name-list
      .
    end.
  end.
end case.

assign
  v-clients-recid-list = trim(v-clients-recid-list , ',' )
.

display
  rs-supp
  ed-supp
with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-change-wth s-object
PROCEDURE proc-change-wth :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_wealth  for ub.wealth.
  define buffer buf_wth-par for ub.wth-par.
  define buffer buf_wth-ser for ub.wth-ser.

  define variable v-rid-list    as character no-undo .
  define variable v-wth-list    as character no-undo .
  define variable v-i           as integer   no-undo .
  define variable v-total       as integer   no-undo .

  case rs-wth :
    when 1 then do:
      assign
        v-wth-list = "Все":U
        v-wth-recid-list = '':U .
      .
    end.
    when 2 then do:
      case rs-wth-type :
        when 1 then do:
          run ref/wth-ref.w ( input my-handle
                            , input "b-sel,b-mark":U
                            , input v-cntxt-host-code-obj
                            , input v-cntxt-obj-type
                            , input v-cntxt-obj-code
                            , input 'wth-ser':U
                            , input-output v-rid-list
                            ) .
          if v-rid-list = "" then do:
            assign
              rs-wth     = 1
              v-wth-list = "Все":U
            .
          end.
          else do:
            assign
              v-total           = num-entries( v-rid-list)
              v-wth-list        = "МЦ :":U + {&new-line}
              v-wth-recid-list  = v-rid-list
            .
            do v-i = 1 to v-total :
              find first buf_wealth no-lock
                where recid(buf_wealth) = integer( entry( v-i , v-rid-list ) )
              no-error .
              if available buf_wealth then do:
                assign
                  v-wth-list = v-wth-list + buf_wealth.wth-name + {&new-line}
                .
              end.
            end.
          end.
        end.
        when 2 then do:
          run ref/wthp-ref.w ( input my-handle
                             , input 'b-sel,b-mark':u
                             , input v-cntxt-host-code-obj
                             , input v-cntxt-obj-type
                             , input v-cntxt-obj-code
                             , input 'ser_wealth':U
                             , input 0
                             , input-output v-rid-list
                             ) .
          if v-rid-list = "" then do:
            assign
              rs-wth     = 1
              v-wth-list = "Все":U
            .
          end.
          else do:
            assign
              v-total           = num-entries( v-rid-list)
              v-wth-list        = "Номиналы :":U + {&new-line}
              v-wth-recid-list  = v-rid-list
            .
            do v-i = 1 to v-total :
              find first buf_wth-par no-lock
                where recid(buf_wth-par) = integer( entry( v-i , v-rid-list ) )
              no-error .
              if available buf_wth-par then do:
                find first buf_wealth no-lock
                  where buf_wealth.wth-code = buf_wth-par.wth-code
                no-error .
                if available buf_wealth
                  and buf_wealth.stts = 0
                then do:
                  assign
                    v-wth-list = v-wth-list + substitute( "&1 - &2 &3&4"
                                                        , buf_wealth.wth-name
                                                        , buf_wth-par.par-val
                                                        , buf_wth-par.par-unit
                                                        , {&new-line}
                                                        )
                  .
                end.
              end.
            end.
          end.

        end.
        when 3 then do:
          run ref/wths-ref.w ( input my-handle
                             , input "b-sel,b-mark"
                             , input v-cntxt-host-code-obj
                             , input v-cntxt-obj-type
                             , input v-cntxt-obj-code
                             , input {&all}
                             , input 0
                             , input 0
                             , input-output v-rid-list
                             ) .
          if v-rid-list = "" then do:
            assign
              rs-wth     = 1
              v-wth-list = "Все":U
            .
          end.
          else do:
            assign
              v-total           = num-entries( v-rid-list)
              v-wth-list        = "Серии :":U + {&new-line}
              v-wth-recid-list  = v-rid-list
            .
            do v-i = 1 to v-total :
              find first buf_wth-ser no-lock
                where recid(buf_wth-ser) = integer( entry( v-i , v-rid-list ) )
              no-error .
              if available buf_wth-ser
                and buf_wth-ser.stts = 0
              then do:
                find first buf_wealth no-lock
                  where buf_wealth.wth-code = buf_wth-ser.wth-code
                no-error .
                find first buf_wth-par no-lock
                  where buf_wth-par.wth-code = buf_wth-ser.wth-code
                    and buf_wth-par.par-code = buf_wth-ser.par-code
                no-error .
                if available buf_wealth and available buf_wth-par then do:
                  assign
                    v-wth-list = v-wth-list + substitute( "&1 : &2 - &3 &4&5"
                                                        , buf_wth-ser.series
                                                        , buf_wealth.wth-name
                                                        , buf_wth-par.par-val
                                                        , buf_wth-par.par-unit
                                                        , {&new-line}
                                                        )
                  .
                end.
              end.
            end.
          end.
        end.
      end case.
    end.
  end case.
  assign
    ed-wth = v-wth-list
  .
  display
    rs-wth
    ed-wth
  with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-change-wth-type s-object
PROCEDURE proc-change-wth-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    rs-wth           = 1
    v-wth-recid-list = "":U
    ed-wth           = "Все":U
  .
  display
    rs-wth
    ed-wth
  with frame {&frame-name}.
/*  case rs-wth-type :
    when 1 then do:
      assign
        tgl-detail-nom = no
        tgl-detail-ser = no
      .
      display
        tgl-detail-nom
        tgl-detail-ser
      with frame {&frame-name}.
      enable
        tgl-detail-nom
      with frame {&frame-name}.
      disable
        tgl-detail-ser
      with frame {&frame-name}.
    end.
    when 2 then do:
      assign
        tgl-detail-nom = yes
        tgl-detail-ser = no
      .
      display
        tgl-detail-nom
        tgl-detail-ser
      with frame {&frame-name}.
      disable
        tgl-detail-nom
      with frame {&frame-name}.
      enable
        tgl-detail-ser
      with frame {&frame-name}.
    end.
    when 3 then do:
      assign
        tgl-detail-nom = yes
        tgl-detail-ser = yes
      .
      display
        tgl-detail-nom
        tgl-detail-ser
      with frame {&frame-name}.
      disable
        tgl-detail-nom
        tgl-detail-ser
      with frame {&frame-name}.
    end.
  end case.*/
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
      /* link-changed */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
