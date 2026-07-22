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

Помесячный оборот по производителю и классификатору

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Помесячный оборот по производителю и классификатору".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ rep/s-month.i NEW }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ ref/grplibfn.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
define variable parparentproc as widget-handle no-undo .
{ str/getctxtp.i def }
{ gbl/getsect.i  def }

def temp-table grp_sum no-undo
    field obj-type      like ub.clients.obj-type
    field obj-code      like ub.clients.obj-code
    field grp-code      like ub.goods.grp-code
    field grp-name      as  char
    field tot-sum           as decimal
    INDEX grp-ind      IS PRIMARY grp-code ASCENDING
    INDEX grp-nam grp-name ASCENDING
    .
def work-table objects no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    .

def buffer cli-obj for ub.clients .
def buffer cli-prod for ub.clients .
def buffer b-gds-grp for ub.gds-grp .
def buffer ret-doc for ub.trn-doc.
def var     cli-list                  as char         no-undo.
def var cas-shft as logical no-undo.
def var cas-num as integer no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 button-prod E-prod
&Scoped-Define DISPLAYED-OBJECTS E-prod

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_s-month AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON button-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "button-prod"
     SIZE 3 BY .88.

DEFINE VARIABLE E-prod AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.63 BY 2.33 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 34.88 BY 4.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     button-prod AT ROW 12.13 COL 28.13
     E-prod AT ROW 13.42 COL 3 NO-LABEL
     "Выбор производителя" VIEW-AS TEXT
          SIZE 20.25 BY .88 AT ROW 12.04 COL 3.13
          FGCOLOR 4
     RECT-1 AT ROW 11.88 COL 1.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 35.88 BY 15.29.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 15.29
         WIDTH              = 35.88.
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
   NOT-VISIBLE                                                          */
ASSIGN
       E-prod:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME button-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL button-prod F-Frame-Win
ON CHOOSE OF button-prod IN FRAME F-Main /* button-prod */
DO:
    assign
    cli-list = ""
    .
    run ref/cli-all.w ( input my-handle
                  ,input  "b-sel"
                  ,input {&pro}
                  ,input {&all}
                  ,input {&current}
                  ,input ?
                  ,input ",,,,,,NO,,"
                 , input ?
    , output cli-list ) .
    if cli-list <> ""
    then do:
        FIND FIRST cli-prod WHERE recid( cli-prod ) = int( cli-list ) NO-LOCK .
        assign
        E-prod:screen-value = cli-prod.obj-name.
    end.
    else do:
        assign
        E-prod:screen-value = "".
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
{ gbl/getcntxt.i get " " my-handle}
parparentproc = my-handle.
{ str/getctxtp.i get }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

{ rep/e-nobenq.i }

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
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  CASE adm-current-page:

    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-month.w':U ,
             INPUT  FRAME F-Main:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_s-month ).
       /* Position in AB:  ( 1.08 , 2.63 ) */
       /* Size in UIB:  ( 10.54 , 29.88 ) */

       /* Adjust the tab order of the smart objects. */
        RUN adjust-tab-order IN adm-broker-hdl ( h_s-month ,
          button-prod:HANDLE IN FRAME F-Main , 'BEFORE':U ).

    END. /* Page 0 */

  END CASE.

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
  DISPLAY E-prod
      WITH FRAME F-Main.
  ENABLE RECT-1 button-prod E-prod
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VAR StrBuf as char no-undo.
DEFINE VAR XLStrBuf as char no-undo.
def var     NotInc          as  log     no-undo.
define variable v-grp as character no-undo .
define variable glog as logical no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .

{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.



if NOT avail cli-prod then do:
    message "Не выбран производитель"
    view-as alert-box ERROR.
    return.
end.

run Assign-Frame in h_s-month.

FOR EACH grp_sum :
   delete grp_sum .
END.
FOR EACH objects :
   delete objects .
END.

assign
glog = FALSE
.

if X-SelectGood = {&g-all} then do:
    message "Вас действительно интересуют" skip
            "ВСЕ ГРУППЫ товаров ?"
    view-as alert-box question buttons YES-NO update glog .
end.
else
glog = TRUE .

if NOT glog then
return .


run waitfram-show in this-procedure ( "Подождите ..." ) .

run no-benqi(OUTPUT NotInc).

FOR EACH obj-list :
    FIND FIRST ub.clients WHERE ub.clients.obj-type = obj-list.obj-type AND
                             ub.clients.obj-code = obj-list.obj-code NO-LOCK .
    CREATE objects .
    assign
    objects.obj-type = obj-list.obj-type
    objects.obj-code = obj-list.obj-code
    objects.obj-name = REPLACE(REPLACE(ub.clients.obj-name, {&comma-char}, ""), p-XL-delim, "")
    .

    if X-SelectGood = {&g-all} then
        FOR EACH ub.gds-grp NO-LOCK :
            if NOT can-find( first b-gds-grp where
                                   b-gds-grp.upper-code = ub.gds-grp.node-code ) then do:
                v-grp = "" .
                RUN grplib-get-full-name in this-procedure( ub.gds-grp.node-code, output v-grp ) .
                CREATE grp_sum .
                assign
                grp_sum.obj-type = obj-list.obj-type
                grp_sum.obj-code = obj-list.obj-code
                grp_sum.grp-name = v-grp
                grp_sum.grp-code = ub.gds-grp.node-code
                .
            end.
        END.
    else do:
        FOR EACH tmp#grp NO-LOCK:
            CREATE grp_sum .
            assign
            grp_sum.obj-type = obj-list.obj-type
            grp_sum.obj-code = obj-list.obj-code
            grp_sum.grp-code = tmp#grp.node-code
            grp_sum.grp-name = tmp#grp.grp-name
            .
        END.
    end.
    if can-find( FIRST ub.inkas WHERE
                       ub.inkas.obj-type = obj-list.obj-type AND
                       ub.inkas.obj-code = obj-list.obj-code AND
                       ub.inkas.doc-date >= vStartPoint AND
                       ub.inkas.doc-date <= vEndPoint AND
                       ub.inkas.status_ = {&fact} ) then
        FOR EACH ub.inkas WHERE
                 ub.inkas.obj-type = obj-list.obj-type AND
                 ub.inkas.obj-code = obj-list.obj-code AND
                 ub.inkas.doc-date >= vStartPoint AND
                 ub.inkas.doc-date <= vEndPoint AND
                 ub.inkas.status_ = {&fact} NO-LOCK :
          PROCESS EVENTS .
          ACCUMULATE     ub.inkas.inkas-code ( COUNT ) .
          if ( ( ACCUM COUNT ub.inkas.inkas-code ) modulo 5 ) = 0 AND
               ( ACCUM COUNT ub.inkas.inkas-code ) >= 5
          then
          run waitfram-show in this-procedure ( obj-list.obj-type + " N" + string( obj-list.obj-code ) +
                          ", обработано отчетов о продаже : " +
                          string( ACCUM COUNT ub.inkas.inkas-code ) ) .
          FIND FIRST ub.trn-doc where ub.trn-doc.doc-code = ub.inkas.inkas-code no-lock no-error.
          FIND FIRST ret-doc where ret-doc.doc-code = ub.trn-doc.out-code no-lock no-error.

          FOR EACH ub.gds-dtl NO-LOCK WHERE ub.gds-dtl.doc-code = trn-doc.doc-code
            BREAK BY ub.gds-dtl.prod-type
                         BY ub.gds-dtl.prod-code:

            FIND FIRST ub.goods WHERE ub.goods.prod-type = ub.gds-dtl.prod-type AND
                                                         ub.goods.prod-code = ub.gds-dtl.prod-code AND
                                                         ub.goods.artic = ub.gds-dtl.artic NO-ERROR .
            if available ub.goods then do:
                FIND FIRST grp_sum WHERE
                           grp_sum.grp-code = ub.goods.grp-code AND
                           grp_sum.obj-type = obj-list.obj-type AND
                           grp_sum.obj-code = obj-list.obj-code NO-ERROR .
                if available grp_sum then do:
                   grp_sum.tot-sum = grp_sum.tot-sum + ub.gds-dtl.doc-qnty * ub.gds-dtl.cur-base.
                end.
            end.
         END.
         if available ret-doc then do:
          FOR EACH ub.gds-dtl NO-LOCK WHERE ub.gds-dtl.doc-code = ret-doc.doc-code
              BREAK BY ub.gds-dtl.prod-type
                          BY ub.gds-dtl.prod-code:

              FIND FIRST ub.goods WHERE ub.goods.prod-type = ub.gds-dtl.prod-type AND
                                                          ub.goods.prod-code = ub.gds-dtl.prod-code AND
                                                          ub.goods.artic = ub.gds-dtl.artic NO-ERROR .
              if available ub.goods then do:
                  FIND FIRST grp_sum WHERE
                            grp_sum.grp-code = ub.goods.grp-code AND
                            grp_sum.obj-type = obj-list.obj-type AND
                            grp_sum.obj-code = obj-list.obj-code NO-ERROR .
                  if available grp_sum then do:
                      grp_sum.tot-sum = grp_sum.tot-sum - gds-dtl.doc-qnty * gds-dtl.cur-base.
                  end.
              end.
          END.
        end. /*if availabe ret-roc*/

    END.    /* FOR EACH inkas WHERE ... */
    if can-find( FIRST ub.trn-doc WHERE
                       ub.trn-doc.obj-type = obj-list.obj-type AND
                       ub.trn-doc.obj-code = obj-list.obj-code AND
                       ub.trn-doc.internal = no AND
                     ( ub.trn-doc.doc-type = {&expense} OR trn-doc.doc-type = {&return} ) AND
                       ub.trn-doc.status_ = {&fact} AND
                       ub.trn-doc.fact-date >= vStartPoint AND
                       ub.trn-doc.fact-date <= vEndPoint AND
                       ub.trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} AND
                       ub.trn-doc.discnt-type <> {&cash-desk} ) then
        FOR EACH ub.trn-doc WHERE
                 ub.trn-doc.obj-type = obj-list.obj-type AND
                 ub.trn-doc.obj-code = obj-list.obj-code AND
                 ub.trn-doc.internal = no AND
               ( ub.trn-doc.doc-type = {&expense} OR ub.trn-doc.doc-type = {&return} ) AND
                 ub.trn-doc.status_ = {&fact} AND
                 ub.trn-doc.fact-date >= vStartPoint AND
                 ub.trn-doc.fact-date <= vEndPoint AND
                 ub.trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} AND
                 ub.trn-doc.discnt-type <> {&cash-desk} NO-LOCK :
            PROCESS EVENTS .
            ACCUMULATE     ub.trn-doc.doc-code ( COUNT ) .
            if ( ( ACCUM COUNT ub.trn-doc.doc-code ) modulo 10 ) = 0 AND
                 ( ACCUM COUNT ub.trn-doc.doc-code ) >= 10
            then
            run waitfram-show in this-procedure (obj-list.obj-type + " N" + string( obj-list.obj-code ) +
                            ", обработано накладных : " +
                            string( ACCUM COUNT ub.trn-doc.doc-code ) ) .

            FOR EACH ub.doc-line WHERE ub.doc-line.doc-code = ub.trn-doc.doc-code AND
                                    ub.doc-line.prod-type = cli-prod.obj-type AND
                                    ub.doc-line.prod-code = cli-prod.obj-code NO-LOCK :
                FIND FIRST ub.goods WHERE ub.goods.prod-type = ub.doc-line.prod-type AND
                                                             ub.goods.prod-code = ub.doc-line.prod-code AND
                                                             ub.goods.artic = ub.doc-line.artic NO-ERROR .
                if available ub.goods then do:
                    FIND FIRST grp_sum WHERE
                                        grp_sum.grp-code = ub.goods.grp-code AND
                                        grp_sum.obj-type = obj-list.obj-type AND
                                        grp_sum.obj-code = obj-list.obj-code NO-ERROR .
                    if available grp_sum then do:
                        FOR EACH ub.gds-dtl WHERE
                                 ub.gds-dtl.doc-code = ub.doc-line.doc-code AND
                                 ub.gds-dtl.prod-code = ub.doc-line.prod-code AND
                                 ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
                                 ub.gds-dtl.artic = ub.doc-line.artic    NO-LOCK :
                            ACCUMULATE
                            (if v-curr-r-b = {&r-b-base}
                            then ub.gds-dtl.price-base
                            else ub.gds-dtl.price-rubl )
                            * ub.gds-dtl.fact-qnty ( TOTAL ) .
                        END .
                        assign
                        grp_sum.tot-sum = grp_sum.tot-sum +
                                         ( if can-do( {&expense}, ub.trn-doc.doc-type )
                                          then ( ACCUM TOTAL
                                                (if v-curr-r-b = {&r-b-base}
                                                then ub.gds-dtl.price-base
                                                else ub.gds-dtl.price-rubl )
                                                * ub.gds-dtl.fact-qnty )
                                          else ( - ( ACCUM TOTAL
                                                    (if v-curr-r-b = {&r-b-base}
                                                    then ub.gds-dtl.price-base
                                                    else ub.gds-dtl.price-rubl )
                                                     * ub.gds-dtl.fact-qnty ) ) ) .
                    end.
                 end.
            END.
        END .
END. /* FOR EACH obj-list : */

run waitfram-hide in this-procedure .
if can-find( first grp_sum where grp_sum.tot-sum <> 0 ) then do:
    run gbl/numtomon.p ( month( vStartPoint ), output StrBuf ) .
    run prn-lib-open-stream  in this-procedure (
                                                input my-handle
                                                ,input 0
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
    PUT stream PrnLibStream space(10)
    string( "Реализация товаров производителя ( фирмы )   " +
            cli-prod.obj-name ) format "x(100)" skip
    space(25) "в действовавших продажных ценах" skip
    space(29) "за  " StrBuf format "x(9)" string( year( vStartPoint ), ">>>9" ) format "x(4)"
    " года  " skip(1)
    space(25) ( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ) format "x(40)" skip
    .
    assign
    StrBuf = string( p-XL-delim + string( "Группа товаров", "x(49)" ) + p-XL-delim )
    sheetf.Excel-COlumn-Lable = string( string( "Группа товаров", "x(49)" ) + {&comma-char} )
    sheetf.sizes = "49" + {&comma-char}
    .
    FOR EACH objects BY objects.obj-type BY objects.obj-code :
        assign
        StrBuf = StrBuf + string( caps( trim( objects.obj-type ) ) + ".  N " +
                 string ( objects.obj-code, ">>>>>>9" ) + p-XL-delim , "x(16)" )
        sheetf.Excel-Column-Lable = sheetf.Excel-COlumn-Lable + string( caps( trim( objects.obj-type ) ) + ".  N " +
                 string ( objects.obj-code, ">>>>>>9" ) + {&comma-char} , "x(16)" )
        sheetf.SIzes = sheetf.Sizes + "16" + {&comma-char}
        .
    END .
    assign
    StrBuf = StrBuf + "     ИТОГО" + fill( " ", 5 ) + p-XL-delim
    sheetf.Excel-COlumn-Lable = sheetf.Excel-Column-lable + "     ИТОГО" + fill( " ", 5 ) + {&comma-char}
    sheetf.SIzes = sheetf.SIzes + "16" + {&comma-char}
    .
    EXPORT stream PrnLibStream StrBuf .
    assign
    StrBuf = p-XL-delim + fill( " ", 49 ) + p-XL-delim
    sheetf.Excel-Column-Lable = sheetf.EXcel-COlumn-Lable + {&new-line} + {&comma-char}
    .
    FOR EACH objects BY objects.obj-type BY objects.obj-code :
        assign
        StrBuf = StrBuf + string( string( objects.obj-name, "x(15)" ) + p-XL-delim , "x(16)" )
        sheetf.Excel-COlumn-Lable = sheetf.Excel-COlumn-Lable +  string( replace(objects.obj-name, {&comma-char}, "":U), "x(16)" ) + {&comma-char}
        .
    END .
    assign
    StrBuf = StrBuf + fill( " ", 15 ) + p-XL-delim
    sheetf.Excel-COlumn-Lable = sheetf.Excel-COlumn-Lable + {&comma-char}
    str3 = " "
    .
    EXPORT stream PrnLibStream StrBuf .

    PUT stream PrnLibStream "" skip .

    run rep/extitle.p (1).
    FOR EACH grp_sum BREAK BY grp_sum.grp-name
                           BY grp_sum.obj-type
                           BY grp_sum.obj-code :
      if first-of( grp_sum.grp-name )
      then
      assign
      StrBuf = string( p-XL-delim + string( grp_sum.grp-name, "X(49)" ) + p-XL-delim )
      XLStrBuf = string( string( grp_sum.grp-name, "X(49)" ) + {&tabulation})
      .
      ACCUMULATE grp_sum.tot-sum ( SUB-TOTAL BY grp_sum.grp-name ) .
      assign
      StrBuf = StrBuf + ( if grp_sum.tot-sum <> 0
                          then string( grp_sum.tot-sum, "->>>,>>>,>>9.99" )
                          else fill( " ", 15 ) ) +   p-XL-delim
      XLStrBuf = XLStrBuf + ( if grp_sum.tot-sum <> 0
                          then string( grp_sum.tot-sum )
                          else "":U ) +   {&tabulation}
      .
      if last-of( grp_sum.grp-name ) then do:
          assign
          StrBuf = StrBuf + ( if ( ACCUM SUB-TOTAL BY grp_sum.grp-name grp_sum.tot-sum ) <> 0
                              then string( ACCUM SUB-TOTAL BY grp_sum.grp-name
                                        grp_sum.tot-sum, "->>>,>>>,>>9.99" )
                              else fill( " ", 15 ) ) + p-XL-delim
          XLStrBuf = XLStrBuf + ( if ( ACCUM SUB-TOTAL BY grp_sum.grp-name grp_sum.tot-sum ) <> 0
                              then string( ACCUM SUB-TOTAL BY grp_sum.grp-name
                                        grp_sum.tot-sum )
                              else "":U) + {&tabulation}
          .
          EXPORT stream PrnLibStream StrBuf .
          {&PutExcel}
          XLStrbuf
          SKIP.
      end.
   END.

   PUT stream PrnLibStream "" skip .
   assign
   StrBuf = p-XL-delim + string("ИТОГО:", "X(49)") + p-XL-delim
   XLStrBuf = string("ИТОГО:", "X(49)") + {&tabulation}
   .
   FOR EACH grp_sum BREAK BY grp_sum.obj-type BY grp_sum.obj-code :
      ACCUMULATE
      grp_sum.tot-sum ( SUB-TOTAL BY grp_sum.obj-code )
      grp_sum.tot-sum ( TOTAL ) .
      if last-of( grp_sum.obj-code )
      then
      assign
      StrBuf = StrBuf +
               string( ACCUM SUB-TOTAL BY grp_sum.obj-code grp_sum.tot-sum, "->>>,>>>,>>9.99" ) +
               p-XL-delim
      XLStrBuf = XLStrBuf +
               string( ACCUM SUB-TOTAL BY grp_sum.obj-code grp_sum.tot-sum) +
               {&tabulation}
      .
   END.
   assign
   StrBuf = StrBuf +
            string( ACCUM TOTAL grp_sum.tot-sum, "->>>,>>>,>>9.99" ) +
            p-XL-delim
   XLStrBuf = XLStrBuf +
            string( ACCUM TOTAL grp_sum.tot-sum ) +
            {&tabulation}
   .
   EXPORT stream PrnLibStream StrBuf .
   PUT stream PrnLibStream " " SKIP.
   {&PutExcel}
   XlStrBuf
   SKIP.

   output stream PrnLibStream CLOSE .
   {&CloseExcel}

    run prn-lib-prn-file in this-procedure (
                                              input my-handle
                                              ,input 11
                                              ).

/*
   assign
   g#rep-tblname = ""
   g#rep-tblrid = -129
   g#rep-updflds = "Помесячный оборот по производителю и классификатору|" +
                   string( vStartPoint ) + ".." + string( vEndPoint )
   .
   */
end.
else do:
    run waitfram-hide in this-procedure .
    message "Не было никакой выручки на выбранных объектах" skip
            "в течение заданного Вами периода времени."
    view-as alert-box INFORMATION .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VAR StrBuf as char no-undo.
def var     NotInc          as  log     no-undo.
run Assign-Frame in h_s-month.

Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.
IF X-SelectGood = {&g-all}
then
str2 = "По всем группам товаров".
For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
ReportNAme = "Помесячный оборот по производителю и классификатору в ценах продаж".
run gbl/numtomon.p ( month( vStartPoint ), output StrBuf ) .
run no-benqi(OUTPUT NotInc).
ReportHeader = "За " + StrBuf  + " " + ENTRY(NUm-entries(vStrBuf, " "), vStrBuf, " ") +
              {&new-line} +
              "Производитель: " + (if avail cli-prod then cli-prod.obj-name  else "") +
              {&new-line} +  ( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ).
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