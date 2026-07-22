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

Помесячный оборот по производителям

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
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Помесячный оборот по производителям".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ rep/s-month.i NEW }
{ cmp/r-pril.i new}
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
define variable parparentproc as widget-handle no-undo .
{ str/getctxtp.i def }
{ gbl/getsect.i  def }

define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}


def temp-table prod_sum no-undo
    field obj-type      like ub.clients.obj-type
    field obj-code      like ub.clients.obj-code
    field obj-name      like ub.clients.obj-name
    field name-attr     as  char
    field prod-type     like ub.goods.prod-type
    field prod-code     like ub.goods.prod-code
    field tot-sum      as   decimal
    INDEX pi        IS PRIMARY prod-type prod-code ASCENDING
    INDEX iden                         name-attr                   ASCENDING
    .
def work-table objects no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    .

def buffer cli-obj for ub.clients .
def buffer cli-prod for ub.clients .
def buffer ret-doc for ub.trn-doc.
define variable cas-shft as logical no-undo.
define variable cas-num as integer no-undo.
{ rep/e-nobenq.i }
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_s-month AS HANDLE NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 40 BY 11.88.


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
         HEIGHT             = 11.92
         WIDTH              = 39.88.
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
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/getcntxt.i get " " my-handle }
parparentproc = my-handle.
{ str/getctxtp.i get }
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
       /* Position in AB:  ( 1.79 , 2.63 ) */
       /* Size in UIB:  ( 10.08 , 29.38 ) */

       /* Adjust the tab order of the smart objects. */
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
DEFINE VAR II as INTEGER No-UNDO.
DEFINE VAR CurrDay as  integer     no-undo.
DEFINE VAR StrBuf as char no-undo.
DEFINE VAR XLStrBuf as char no-undo.
define variable     Retail             as  log         no-undo.
define variable     Opt                 as  log         no-undo.
define variable     NotInc          as  log     no-undo.
define variable glog as logical no-undo .
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .

{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.



run Assign-Frame in h_s-month.

IF X-SelectGood = {&g-all} then do:
    message "Вас действительно интересуют" skip
            "ВСЕ производители ?"
    view-as alert-box question buttons YES-NO update glog .
end.
else
glog = TRUE .
if NOT glog then return .
run My-var.
run no-benqi(OUTPUT NotInc).

for each prod_sum:
    delete prod_sum.
end.
for each objects:
    delete objects.
end.


assign
Retail = FALSE
Opt = FALSE
.

run waitfram-show in this-procedure ( "Подождите ..." ) .
FOR EACH obj-list :
    FIND FIRST ub.clients WHERE ub.clients.obj-type = obj-list.obj-type AND
                       ub.clients.obj-code = obj-list.obj-code NO-LOCK .
    CREATE objects .
    assign
    objects.obj-type = ub.clients.obj-type
    objects.obj-code = ub.clients.obj-code
    objects.obj-name = REPLACE(REPLACE(ub.clients.obj-name, {&comma-char}, ""), p-XL-delim, "")
    .

    if X-SElectGood = {&g-all}
    then
    FOR EACH cli-prod WHERE cli-prod.is-prod = TRUE NO-LOCK :
        CREATE prod_sum .
        assign
        prod_sum.obj-type = obj-list.obj-type
        prod_sum.obj-code = obj-list.obj-code
        prod_sum.obj-name = cli-prod.obj-name
        prod_sum.name-attr =
        cli-prod.obj-name + cli-prod.obj-type + string( cli-prod.obj-code )
        prod_sum.prod-type = cli-prod.obj-type
        prod_sum.prod-code = cli-prod.obj-code .
    END.
    else do:
        FOR EACH g#cli No-LOCK :
            CREATE prod_sum .
            assign
            prod_sum.obj-type = obj-list.obj-type
            prod_sum.obj-code = obj-list.obj-code
            prod_sum.obj-name = g#cli.obj-name
            prod_sum.name-attr = g#cli.obj-name + g#cli.obj-type + string( g#cli.obj-code )
            prod_sum.prod-type = g#cli.obj-type
            prod_sum.prod-code = g#cli.obj-code
            .
        END .
    END.
    if can-find( FIRST ub.inkas WHERE
                       ub.inkas.obj-type = obj-list.obj-type AND
                       ub.inkas.obj-code = obj-list.obj-code AND
                       ub.inkas.doc-date >= vStartPoint AND
                       ub.inkas.doc-date <= vEndPoint AND
                       ub.inkas.status_ = {&fact} )
    then
    FOR EACH ub.inkas WHERE
                      ub.inkas.obj-type = obj-list.obj-type AND
                      ub.inkas.obj-code = obj-list.obj-code AND
                      ub.inkas.doc-date >= vStartPoint AND
                      ub.inkas.doc-date <= vEndPoint AND
                      ub.inkas.status_ = {&fact}      NO-LOCK :
        PROCESS EVENTS .
        ACCUMULATE     ub.inkas.inkas-code ( COUNT ) .
        if ( ( ACCUM COUNT ub.inkas.inkas-code ) modulo 5 ) = 0 AND
             ( ACCUM COUNT ub.inkas.inkas-code ) >= 5
        then
        run waitfram-show in this-procedure ( obj-list.obj-type + " N" + string( obj-list.obj-code ) +
                        ", обработано отчетов по продаже : " +
                        string( ACCUM COUNT ub.inkas.inkas-code ) ) .

        FIND FIRST ub.trn-doc where ub.trn-doc.doc-code = ub.inkas.inkas-code no-lock no-error.
        FIND FIRST ret-doc where ret-doc.doc-code = ub.trn-doc.out-code no-lock no-error.
        FOR EACH ub.gds-dtl NO-LOCK WHERE ub.gds-dtl.doc-code = ub.trn-doc.doc-code
            BREAK BY ub.gds-dtl.prod-type BY ub.gds-dtl.prod-code:
            IF FIRST-OF (ub.gds-dtl.prod-code) then do:
                FIND FIRST prod_sum WHERE
                prod_sum.prod-type = ub.gds-dtl.prod-type AND
                prod_sum.prod-code = ub.gds-dtl.prod-code NO-ERROR .
            end.
            if available prod_sum then do:
                assign
                prod_sum.tot-sum = prod_sum.tot-sum +
                                   ub.gds-dtl.doc-qnty * ub.gds-dtl.cur-base.
            end.
        END.
        IF AVAILABLE RET-DOC THEN DO:
          FOR EACH ub.gds-dtl NO-LOCK WHERE ub.gds-dtl.doc-code = ret-doc.doc-code
              BREAK BY ub.gds-dtl.prod-type BY ub.gds-dtl.prod-code:
              IF FIRST-OF (ub.gds-dtl.prod-code) then do:
                  FIND FIRST prod_sum WHERE
                            prod_sum.prod-type = ub.gds-dtl.prod-type AND
                            prod_sum.prod-code = ub.gds-dtl.prod-code NO-ERROR .
              end.
              if available prod_sum then do:
                  assign
                  prod_sum.tot-sum = prod_sum.tot-sum -
                                    ub.gds-dtl.doc-qnty * ub.gds-dtl.cur-base.
              end.
          END.
        END.
    END.    /* FOR EACH inkas WHERE ... */
    if can-find( FIRST ub.trn-doc WHERE
                       ub.trn-doc.obj-type = obj-list.obj-type AND
                       ub.trn-doc.obj-code = obj-list.obj-code AND
                       ub.trn-doc.internal = no AND
                     ( ub.trn-doc.doc-type = {&expense} OR ub.trn-doc.doc-type = {&return} ) AND
                       ub.trn-doc.status_ = {&fact} AND
                       ub.trn-doc.fact-date >= vStartPoint AND
                       ub.trn-doc.fact-date <= vEndPoint AND
                       ub.trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} AND
                       ub.trn-doc.discnt-type <> {&cash-desk} )
     then
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
        if ( ( ACCUM COUNT ub.trn-doc.doc-code ) modulo 25 ) = 0 AND
             ( ACCUM COUNT ub.trn-doc.doc-code ) >= 25
        then
        run waitfram-show in this-procedure (obj-list.obj-type + " N" + string( obj-list.obj-code ) +
                         ", обработано накладных : " +
                       string( ACCUM COUNT ub.trn-doc.doc-code ) ) .

        FOR EACH ub.doc-line WHERE ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK :
            FIND FIRST prod_sum WHERE
                       prod_sum.prod-type = ub.doc-line.prod-type AND
                       prod_sum.prod-code = ub.doc-line.prod-code NO-ERROR .
            if available prod_sum then do:
                FOR EACH gds-dtl WHERE
                         gds-dtl.doc-code = ub.doc-line.doc-code AND
                         gds-dtl.prod-code = ub.doc-line.prod-code AND
                         gds-dtl.prod-type = ub.doc-line.prod-type AND
                         gds-dtl.artic = ub.doc-line.artic    NO-LOCK :
                    ACCUMULATE (if v-curr-r-b = {&r-b-base}
                                then ub.gds-dtl.price-base
                                else ub.gds-dtl.price-rubl) * ub.gds-dtl.fact-qnty ( TOTAL ) .
                END .
                assign
                prod_sum.tot-sum = prod_sum.tot-sum +
                                 ( if can-do( {&expense}, ub.trn-doc.doc-type )
                                   then ( ACCUM TOTAL
                                                    (if v-curr-r-b = {&r-b-base}
                                                    then ub.gds-dtl.price-base
                                                    else ub.gds-dtl.price-rubl)
                                                    * ub.gds-dtl.fact-qnty )
                                   else ( - ( ACCUM TOTAL
                                                    (if v-curr-r-b = {&r-b-base}
                                                    then ub.gds-dtl.price-base
                                                    else ub.gds-dtl.price-rubl)
                                                    * ub.gds-dtl.fact-qnty ) ) ) .
             end.
        END.
     END .
END. /* FOR EACH obj-list : */
run waitfram-hide in this-procedure .


if can-find( first prod_sum where prod_sum.tot-sum <> 0 ) then do:
    run gbl/numtomon.p ( month( vStartPoint ), output StrBuf ) .
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input 0
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).

     PUT stream PrnLibStream space(20)
     "Реализация товаров в магазинах" skip
     space(20) "в действовавших продажных ценах" skip
     space(21) "по фирмам ( производителям )" skip(1)
     space(23) "за " StrBuf format "x(9)" string( year( vStartPoint ), ">>>9" ) format "x(4)"
               "  года  " skip(1)
     space(20) ( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ) format "x(40)" skip
     .
     assign
     StrBuf = string( p-XL-delim + string( "ФИРМА", "x(19)" ) + p-XL-delim )
     sheetf.Excel-COlumn-Lable = string( "ФИРМА", "x(19)" ) + {&comma-char}
     sheetf.sizes = "10" + {&comma-char}
       .
     FOR EACH objects BY objects.obj-type BY objects.obj-code :
        assign
        StrBuf = StrBuf + string( caps( trim( objects.obj-type ) ) + ".  N " +
                 string ( objects.obj-code, ">>>>>>9" ) + p-XL-delim , "x(16)" )
        sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + string( caps( trim( objects.obj-type ) ) + ".  N " +
                         string ( objects.obj-code, ">>>>>>9" ) + {&comma-char} , "x(16)" )
        sheetf.SIzes = sheetf.Sizes + "16" + {&comma-char}
        .
     END .
     assign
     StrBuf = StrBuf + "     ИТОГО" + fill( " ", 5 ) + p-XL-delim
     sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + "     ИТОГО" + fill( " ", 5 ) + {&comma-char}
     sheetf.SIzes = sheetf.SIzes + "16" + {&comma-char}
     .
     EXPORT stream PrnLibStream StrBuf .

     ASSIGN
     StrBuf = p-XL-delim + fill( " ", 18 ) + p-XL-delim
     sheetf.EXcel-COlumn-Lable = sheetf.EXcel-COlumn-Lable + {&new-line} + {&comma-char}
     .
     FOR EACH objects BY objects.obj-type BY objects.obj-code :
         assign
         StrBuf = StrBuf + string( string( objects.obj-name, "x(15)" ) + p-XL-delim , "x(16)" )
         sheetf.Excel-COlumn-Lable = sheetf.Excel-COlumn-Lable + string( replace( objects.obj-name, {&comma-char}, "":U), "x(15)" ) + {&comma-char}
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

     FOR EACH prod_sum BREAK BY prod_sum.name-attr
                             BY prod_sum.obj-type
                             BY prod_sum.obj-code :
        if first-of( prod_sum.name-attr )
        then
        assign
        StrBuf = string( string( p-XL-delim + prod_sum.obj-name, "X(19)" ) + p-XL-delim )
        XLStrBuf = string( string(prod_sum.obj-name, "X(19)" ) + {&tabulation} )
        .
        ACCUMULATE prod_sum.tot-sum ( SUB-TOTAL BY prod_sum.name-attr ) .
        assign
        StrBuf = StrBuf + ( if prod_sum.tot-sum <> 0
                            then string( prod_sum.tot-sum, "->>>,>>>,>>9.99" )
                            else fill( " ", 15 ) ) + p-XL-delim
        XLStrBuf = XLStrBuf + ( if prod_sum.tot-sum <> 0
                            then string( prod_sum.tot-sum )
                            else "":U) + {&tabulation}
        .

        if last-of( prod_sum.name-attr ) then do:
           assign
           StrBuf = StrBuf +
                   ( if ( ACCUM SUB-TOTAL BY prod_sum.name-attr prod_sum.tot-sum ) <> 0
                     then string( ACCUM SUB-TOTAL BY prod_sum.name-attr prod_sum.tot-sum, "->>>,>>>,>>9.99" )
                     else fill( " ", 15 ) ) + p-XL-delim
           XLStrBuf = XLStrBuf +
                   ( if ( ACCUM SUB-TOTAL BY prod_sum.name-attr prod_sum.tot-sum ) <> 0
                     then string( ACCUM SUB-TOTAL BY prod_sum.name-attr prod_sum.tot-sum )
                     else "":U) + {&tabulation}
           .
           EXPORT stream PrnLibStream StrBuf .
           {&PutExcel}
           XlStrBuf
           SKIP
           .
        end.
     END.

    PUT stream PrnLibStream "" skip .
    assign
    StrBuf = p-XL-delim + string("ИТОГО:", "X(18)") + p-XL-delim
    XLStrBuf = string("ИТОГО:", "X(18)") + {&tabulation}
    .

    FOR EACH prod_sum BREAK BY prod_sum.obj-type BY prod_sum.obj-code :
        ACCUMULATE
        prod_sum.tot-sum ( SUB-TOTAL BY prod_sum.obj-code )
        prod_sum.tot-sum ( TOTAL )
        .
        if last-of( prod_sum.obj-code )
        then
        assign
        StrBuf = StrBuf +
                 string( ACCUM SUB-TOTAL BY prod_sum.obj-code prod_sum.tot-sum, "->>>,>>>,>>9.99" ) +
                 p-XL-delim
        XLStrBuf = XLStrBuf +
                 string( ACCUM SUB-TOTAL BY prod_sum.obj-code prod_sum.tot-sum ) +
                 {&tabulation}
        .
    END.
    assign
    StrBuf = StrBuf +
             string( ACCUM TOTAL prod_sum.tot-sum, "->>>,>>>,>>9.99" ) + p-XL-delim
    XLStrBuf = XLStrBuf +
             string( ACCUM TOTAL prod_sum.tot-sum) + {&tabulation}

     .
    EXPORT stream PrnLibStream StrBuf .

    PUT stream PrnLibStream " " SKIP.
    {&putExcel}
     XLstrBuf
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
    g#rep-tblrid = -128
    g#rep-updflds = "Помесячные обороты по пр-лям|" +
                    string( vStartPoint ) + ".." + string( vEndPoint ) .
     */
    run waitfram-hide in this-procedure .
end.
else do:
    run waitfram-hide in this-procedure .
    message "Не было никакой выручки на выбранных объектах" skip
            "в течение заданного Вами периода времени."
    view-as alert-box INFORMATION .
end.

FOR EACH prod_sum :
    delete prod_sum .
END.
FOR EACH objects :
    delete objects .
END.
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
run Assign-Frame in h_s-month.
DEFINE VAR StrBuf as char no-undo.
define variable     NotInc          as  log     no-undo.

Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.
IF X-SelectGood = {&g-all}
then
str2 = "По всем производителям".
else str2 = " ".
For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
ReportNAme = "Помесячный оборот по производителям в ценах продаж".
run gbl/numtomon.p ( month( vStartPoint ), output StrBuf ) .
run no-benqi(OUTPUT NotInc).
ReportHeader = "За " + StrBuf  + " " + ENTRY(NUm-entries(vStrBuf, " "), vStrBuf, " ") +
               {&new-line} + ( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ).

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