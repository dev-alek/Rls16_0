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

Помесячная реализация в магазине

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

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Помесячная реализация в магазине".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ rep/s-month.i NEW }
{ cmp/r-pril.i new}
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ rep/rep-bt.i }
{ gbl/getsect.i def }



define temp-table day_sum no-undo
    field   day_             as   integer
    field   prod-type       like ub.goods.prod-type
    field   prod-code       like ub.goods.prod-code
    field   prod-attr           as  char
    field   prod-qnty       as   decimal
    field   prod-sum        as   decimal
    field   sale-sum        as   decimal
    field   str-qnty        as  integer
    field   discnt-sum        as   decimal
    INDEX   pi        IS PRIMARY day_ prod-type prod-code     ASCENDING
    INDEX   atr                           prod-attr                                ASCENDING
    .

define work-table chk-day no-undo
    field   day_          as  integer
    field   chk-qnty    as  integer
    .

define work-table prods no-undo
    field   prod-type       like ub.goods.prod-type
    field   prod-code      like ub.goods.prod-code
    field   prod-attr           as  char
    field   prod-name     as char
    .

define buffer cli-obj for ub.clients.
define buffer ret-doc for ub.trn-doc.

define variable cas-shft as logical no-undo.
define variable cas-num as integer no-undo.

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
         SIZE 32 BY 11.88.


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
         WIDTH              = 32.
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
{ gbl/personly.i }
{ gbl/getcntxt.i get " " my-handle }
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
       /* Position in AB:  ( 1.50 , 1.88 ) */
       /* Size in UIB:  ( 10.79 , 28.63 ) */

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
define variable     SaleChk-Amount      as  integer     no-undo.
define variable     ii                              as  integer     no-undo.
define variable     CurrDay                 as  integer     no-undo.
define variable     StrBuf              as char         no-undo.
define variable     NotInc          as  log     no-undo.
DEFINE VAR XLStrBuf as char no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
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




Run Assign-Frame in h_s-month.

for each day_sum:
    delete day_sum.
end.
for each chk-day:
    delete chk-day.
end.
for each prods:
    delete prods.
end.
for each obj-list No-LOCK:
    accumulate obj-list.obj-code (COUNT).
END.
if (accum count obj-list.obj-code) > 1 then do:
    message "Выбрано больше одного объекта для отчета!"
    view-as alert-box ERROR.
    return.
end.
run waitfram-show in this-procedure ( "Подождите ..." ) .
run no-benqi(OUTPUT NotInc).
FIND FIRST obj-list .
FOR EACH ub.inkas WHERE
         ub.inkas.obj-type = obj-list.obj-type AND
         ub.inkas.obj-code = obj-list.obj-code AND
         ub.inkas.doc-date >= vStartPoint AND
         ub.inkas.doc-date <= vEndPoint AND
         ub.inkas.status_ = {&fact}      NO-LOCK
         BREAK BY ub.inkas.obj-type
               BY ub.inkas.obj-code
               BY ub.inkas.doc-date :
    FIND FIRST ub.trn-doc where ub.trn-doc.doc-code = ub.inkas.inkas-code no-lock no-error.
    FIND FIRST ret-doc where ret-doc.doc-code = trn-doc.out-code no-lock no-error.

    if first-of( ub.inkas.doc-date ) then
    assign
    SaleChk-Amount = 0
    CurrDay = day( inkas.doc-date )
    .
    _chk-doc:
    FOR EACH ub.chk-doc where ub.chk-doc.out-code = ub.inkas.inkas-code NO-LOCK:
       if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
       SaleChk-Amount = SaleChk-Amount + ( if ub.chk-doc.tot-doc > 0 then 1 else ( -1 ) ) .
    END.
    ACCUMULATE
    SaleChk-Amount ( SUB-TOTAL BY ub.inkas.doc-date )
    inkas.inkas-code ( COUNT )
    .

    FOR EACH ub.gds-dtl NO-LOCK WHERE ub.gds-dtl.doc-code = ub.trn-doc.doc-code
        BREAK BY ub.gds-dtl.prod-type BY ub.gds-dtl.prod-code:

        FIND FIRST day_sum WHERE
                   day_sum.day_ = CurrDay AND
                   day_sum.prod-type = ub.gds-dtl.prod-type AND
                   day_sum.prod-code = ub.gds-dtl.prod-code NO-ERROR .
        if NOT available day_sum then do:
            FIND FIRST ub.clients WHERE ub.clients.obj-type = ub.gds-dtl.prod-type AND
                                     ub.clients.obj-code = ub.gds-dtl.prod-code NO-LOCK .
            CREATE day_sum .
            assign
            day_sum.day_ = CurrDay
            day_sum.prod-type = ub.gds-dtl.prod-type
            day_sum.prod-code = ub.gds-dtl.prod-code
            day_sum.prod-attr = ub.gds-dtl.prod-type + string( gds-dtl.prod-code )
            day_sum.prod-qnty = ub.gds-dtl.doc-qnty
            day_sum.prod-sum = ub.gds-dtl.doc-qnty * ub.gds-dtl.cur-base
            day_sum.sale-sum = ub.gds-dtl.doc-qnty * (if v-curr-r-b = {&r-b-base} then  ub.gds-dtl.price-base else ub.gds-dtl.price-rubl)
            day_sum.discnt-sum = gds-dtl.doc-qnty * (if v-curr-r-b = {&r-b-base} then  ub.gds-dtl.discnt-base else ub.gds-dtl.discnt-rubl)
            .
            FOR EACH ub.chk-gds where
                     ub.chk-gds.out-code = ub.inkas.inkas-code,
                FIRST ub.bar-code No-LOCK where
                      ub.bar-code.b-code = ub.chk-gds.b-code,
                FIRST ub.goods No-LOCK WHERE
                      ub.goods.gds-code = ub.bar-code.gds-code AND
                      ub.goods.prod-type = day_sum.prod-type AND
                      ub.goods.prod-code = day_sum.prod-code:
                day_sum.str-qnty = day_sum.str-qnty +
                                   ( if ub.chk-gds.doc-qnty > 0 then 1 else -1 ).

            END.
            FIND FIRST prods WHERE
                      prods.prod-type = ub.gds-dtl.prod-type AND
                      prods.prod-code = ub.gds-dtl.prod-code NO-ERROR .
            if NOT available prods then do:
                CREATE prods .
                assign
                prods.prod-type = ub.gds-dtl.prod-type
                prods.prod-code = ub.gds-dtl.prod-code
                prods.prod-attr = ub.gds-dtl.prod-type + string( ub.gds-dtl.prod-code )
                prods.prod-name = ub.clients.obj-name
                .
            end.
         end.
         else
         assign
         day_sum.prod-qnty = day_sum.prod-qnty + ub.gds-dtl.doc-qnty
         day_sum.prod-sum = day_sum.prod-sum + ub.gds-dtl.doc-qnty * ub.gds-dtl.cur-base
         day_sum.sale-sum = day_sum.sale-sum + ub.gds-dtl.doc-qnty * (if v-curr-r-b = {&r-b-base} then  ub.gds-dtl.price-base else gds-dtl.price-rubl)
         day_sum.discnt-sum = day_sum.discnt-sum + ub.gds-dtl.doc-qnty * (if v-curr-r-b = {&r-b-base} then  ub.gds-dtl.discnt-base else gds-dtl.discnt-rubl)
         .
      END.
      if available ret-doc then do:
        FOR EACH ub.gds-dtl NO-LOCK WHERE ub.gds-dtl.doc-code = ret-doc.doc-code
            BREAK BY ub.gds-dtl.prod-type
                  BY ub.gds-dtl.prod-code:

            FIND FIRST day_sum WHERE
                      day_sum.day_ = CurrDay AND
                      day_sum.prod-type = ub.gds-dtl.prod-type AND
                      day_sum.prod-code = ub.gds-dtl.prod-code NO-ERROR .
            if NOT available day_sum then do:
                FIND FIRST clients WHERE ub.clients.obj-type = ub.gds-dtl.prod-type AND
                                        ub.clients.obj-code = ub.gds-dtl.prod-code NO-LOCK .
                CREATE day_sum .
                assign
                day_sum.day_ = CurrDay
                day_sum.prod-type = ub.gds-dtl.prod-type
                day_sum.prod-code = ub.gds-dtl.prod-code
                day_sum.prod-attr = ub.gds-dtl.prod-type + string( ub.gds-dtl.prod-code )
                day_sum.prod-qnty = - ub.gds-dtl.doc-qnty
                day_sum.prod-sum = - ub.gds-dtl.doc-qnty * ub.gds-dtl.cur-base
                day_sum.sale-sum = - ub.gds-dtl.doc-qnty * (if v-curr-r-b = {&r-b-base} then  ub.gds-dtl.price-base else ub.gds-dtl.price-rubl)
                day_sum.discnt-sum = - ub.gds-dtl.doc-qnty * (if v-curr-r-b = {&r-b-base} then  ub.gds-dtl.discnt-base else ub.gds-dtl.discnt-rubl)
                .
                FOR EACH ub.chk-gds where
                        ub.chk-gds.out-code = ub.inkas.inkas-code,
                    FIRST ub.bar-code No-LOCK where
                          ub.bar-code.b-code = ub.chk-gds.b-code,
                    FIRST ub.goods No-LOCK WHERE
                          ub.goods.gds-code = ub.bar-code.gds-code AND
                          ub.goods.prod-type = day_sum.prod-type AND
                          ub.goods.prod-code = day_sum.prod-code:
                    day_sum.str-qnty = day_sum.str-qnty +  ( if ub.chk-gds.doc-qnty > 0 then 1 else -1 ).

                END.
                FIND FIRST prods WHERE
                          prods.prod-type = ub.gds-dtl.prod-type AND
                          prods.prod-code = ub.gds-dtl.prod-code NO-ERROR .
                if NOT available prods then do:
                    CREATE prods .
                    assign
                    prods.prod-type = ub.gds-dtl.prod-type
                    prods.prod-code = ub.gds-dtl.prod-code
                    prods.prod-attr = ub.gds-dtl.prod-type + string( ub.gds-dtl.prod-code )
                    prods.prod-name = ub.clients.obj-name
                    .
                end.
            end.
            else
            assign
            day_sum.prod-qnty = day_sum.prod-qnty -  ub.gds-dtl.doc-qnty
            day_sum.prod-sum = day_sum.prod-sum -  ub.gds-dtl.doc-qnty * ub.gds-dtl.cur-base
            day_sum.sale-sum = day_sum.sale-sum -  ub.gds-dtl.doc-qnty * (if v-curr-r-b = {&r-b-base} then  ub.gds-dtl.price-base else ub.gds-dtl.price-rubl)
            day_sum.discnt-sum = day_sum.discnt-sum - ub.gds-dtl.doc-qnty * (if v-curr-r-b = {&r-b-base} then  ub.gds-dtl.discnt-base else ub.gds-dtl.discnt-rubl)
            .
        END.
      end. /*if avail ret-do*/
      if ( ( ACCUM COUNT ub.inkas.inkas-code ) modulo 5 ) = 0 AND
           ( ACCUM COUNT ub.inkas.inkas-code ) >= 5
      then
      run waitfram-show in this-procedure ( obj-list.obj-type + " N" + string( obj-list.obj-code ) +
                      ", обработано отчетов по продаже : " + string( ACCUM COUNT ub.inkas.inkas-code ) ) .

      if last-of( inkas.doc-date ) then  do:
          CREATE chk-day .
          assign
          chk-day.day_ = CurrDay
          chk-day.chk-qnty = ( ACCUM SUB-TOTAL BY ub.inkas.doc-date     SaleChk-Amount )
          .
      end.
  END .

  run waitfram-hide in this-procedure .

  if can-find( first day_sum where day_sum.prod-sum <> 0 ) then do:
      DO ii = 1 TO vEndLastDay :
          FOR EACH prods :
              FIND FIRST day_sum WHERE
                         day_sum.day_ = ii AND
                         day_sum.prod-type = prods.prod-type AND
                         day_sum.prod-code = prods.prod-code NO-ERROR .
              if NOT available day_sum then do:
                  CREATE day_sum .
                  assign
                  day_sum.day_ = ii
                  day_sum.prod-type = prods.prod-type
                  day_sum.prod-code = prods.prod-code
                  day_sum.prod-attr = prods.prod-type + string( prods.prod-code )
                  .
              end.
           END .
           FIND FIRST chk-day WHERE chk-day.day_ = ii NO-ERROR .
           if NOT available chk-day then do:
               CREATE chk-day .
               chk-day.day_ = ii .
           end.
        END .

        FIND FIRST cli-obj WHERE
                   cli-obj.obj-type = obj-list.obj-type AND
                   cli-obj.obj-code = obj-list.obj-code NO-LOCK .
        FIND FIRST ub.db WHERE ub.db.db-num = cli-obj.db-num NO-LOCK .

        run gbl/numtomon.p ( month( vStartPoint ), output StrBuf ) .
        run prn-lib-open-stream  in this-procedure (
                                                    input my-handle
                                                    ,input 0
                                                    ,input yes /*p-is-stream*/
                                                    ,input no /*p-append*/
                                                    ).

        PUT stream PrnLibStream space(40)
        "Отчет по реализации" skip(1)
        space(20) "Магазин " db.db-name format "x(40)" AT 41 skip
        space(20) "Салон " cli-obj.obj-name format "x(40)" AT 41 skip
        space(20) "Отчетный период "
        StrBuf format "x(9)" AT 41 string( year( vStartPoint ), ">>>9" ) format "x(4)"
        skip(1)
        space(20) ( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ) format "x(40)" skip
        .
        assign
        StrBuf = p-XL-delim + string( "   Дата", "x(15)" ) + p-XL-delim
        sheetf.Excel-COlumn-Lable = string( "   Дата", "x(15)" ) + {&comma-char}
        sheetf.sizes = "10" + {&comma-char}
        .
        FOR EACH prods BY prods.prod-attr :
          assign
          StrBuf = StrBuf + fill( " ", 12 ) + p-XL-delim +
                   string( " " + prods.prod-name, "x(17)" ) + p-XL-delim
          sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + string(replace(prods.prod-name, {&comma-char}, "":U), "x(17)" ) + {&comma-char} +
                               fill (" ", 17) + {&comma-char}
          sheetf.sizes = sheetf.sizes + "17" + {&comma-char} + "17" + {&comma-char}
          .
        END .
     assign
     StrBuf = StrBuf + fill( " ", 5 ) + "  " + fill( " ", 5 ) + p-XL-delim +
              fill( " ", 4 ) + "  ИТОГО  " + fill( " ", 4 ) + p-XL-delim +
              " " + fill( " ", 7 ) + p-XL-delim
     sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + fill( " ", 6 ) + "ИТОГО" + fill( " ", 6 )  + {&comma-char} +
                          fill( " ", 17 ) + {&comma-char} +
                          fill( " ", 8 ) + {&comma-char}
     sheetf.sizes = sheetf.sizes + "17" + {&comma-char} + "17" + {&comma-char} + "8" + {&comma-char}
     str2 = " "
     str3 = " "
     .
     /*конец 1-ой строки шапки*/
     EXPORT stream PrnLibStream StrBuf .

     assign
     StrBuf = p-XL-delim + fill( " ", 15 ) + p-XL-delim
     sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + {&new-line} + fill( " ", 5 ) + "(День" + fill ( " ", 6) + {&comma-char}
     .
     FOR EACH prods :
        assign
        StrBuf = StrBuf + fill( " ", 5 ) + "шт" + fill( " ", 5 ) + p-XL-delim +
                 fill( " ", 4 ) + "Стоимость" + fill( " ", 4 ) + p-XL-delim
        sheetf.Excel-COlumn-Lable = sheetf.Excel-Column-Lable + string("Количество", "X(12)") + {&comma-char} +
                             fill( " ", 4 ) + "Стоимость" + fill( " ", 4 ) + {&comma-char}
        .
     END .
     assign
     StrBuf = StrBuf + fill( " ", 5 ) + "шт" + fill( " ", 5 ) + p-XL-delim +
              fill( " ", 4 ) + "Стоимость" + fill( " ", 4 ) + p-XL-delim +
              " " + "Кол-во" + fill( " ", 1 ) + p-XL-delim
     sheetf.Excel-Column-Lable = sheetf.Excel-COlumn-Lable + string("Количество", "X(12)") + {&comma-char} +
                          fill( " ", 4 ) + "Стоимость" + fill( " ", 4 ) + {&comma-char} +
                          " " + "Кол-во" + fill( " ", 1 ) + {&comma-char}

     .
     EXPORT stream PrnLibStream StrBuf .

     /*конец 2-ой строки шапки*/
     assign
     StrBuf = p-XL-delim + fill( " ", 15 ) + p-XL-delim
     sheetf.Excel-Column-Lable =  sheetf.Excel-Column-Lable + {&new-line} + string("месяца)", "X(15)") + {&comma-char}
     .
     FOR EACH prods :
      assign
       StrBuf = StrBuf + fill( " ", 12 ) + p-XL-delim + fill( " ", 6 ) +
       (if v-curr-r-b = {&r-b-rubl}
       then "{&abbr_rub_allshift}"
       else  string( caps( trim( base-type ) ), "x(3)" ))
               + fill( " ", 8 ) + p-XL-delim
       sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + fill( " ", 5 ) + "шт" + fill( " ", 5 ) + {&comma-char} +
                            fill( " ", 6 ) +
       (if v-curr-r-b = {&r-b-rubl}
       then "{&abbr_rub_allshift}"
       else  string( caps( trim( base-type ) ), "x(3)" ))
                            + fill( " ", 8 ) + {&comma-char}
       .

     END .
     assign
     StrBuf = StrBuf + fill( " ", 12 ) + p-XL-delim + fill( " ", 6 ) +
    (if v-curr-r-b = {&r-b-rubl}
    then "{&abbr_rub_allshift}"
    else  string( caps( trim( base-type ) ), "x(3)" ))
             + fill( " ", 8 ) + p-XL-delim + "  " + "чеков" + fill( " ", 1 ) + p-XL-delim
     sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + fill( " ", 5 ) + "шт" + fill( " ", 5 ) + {&comma-char} +
                          fill( " ", 6 ) +
    (if v-curr-r-b = {&r-b-rubl}
    then "{&abbr_rub_allshift}"
    else  string( caps( trim( base-type ) ), "x(3)" ))
    + fill( " ", 8 ) + {&comma-char} +
             "  " + "чеков" + fill( " ", 1 ) + {&comma-char}
     str3 = " "
     str2 = " "
     .
     run rep/extitle.p (1).
     /*конец 3-ой строки шапки*/
     EXPORT stream PrnLibStream StrBuf .
     PUT stream PrnLibStream "" skip .

     /*Run ExTitle.p.*/

     FOR EACH day_sum
         BREAK BY day_sum.day BY day_sum.prod-attr :

         if first-of( day_sum.day_ )
         then
         assign
         StrBuf = p-XL-delim + string( day_sum.day_, ">>>>9" ) + fill( " ", 10 ) +  p-XL-delim
         XLStrBuf = string( day_sum.day_, ">>>>9" ) + fill( " ", 10 ) +  {&tabulation}
         .
         ACCUMULATE
         day_sum.sale-sum ( SUB-TOTAL BY day_sum.day_ )
         day_sum.discnt-sum ( SUB-TOTAL BY day_sum.day_ )
         day_sum.prod-sum ( SUB-TOTAL BY day_sum.day_ )
         day_sum.prod-qnty ( SUB-TOTAL BY day_sum.day_ )
         .
         assign
         StrBuf = StrBuf + ( if day_sum.prod-qnty <> 0
                             then string( string( day_sum.prod-qnty, "->>>,>>9.<<<" ) , "x(12)" )
                              else fill( " ", 12 ) ) + p-XL-delim +
                              ( if day_sum.prod-sum <> 0
                                then string( day_sum.prod-sum - day_sum.discnt-sum, "->,>>>,>>>,>>9.99" )
                                else fill( " ", 17 ) ) + p-XL-delim
         XLStrBuf = XLStrBuf + ( if day_sum.prod-qnty <> 0
                             then string( string( day_sum.prod-qnty, "->>>,>>9.<<<" ) , "x(12)" )
                              else fill( " ", 12 ) ) + {&tabulation} +
                              ( if day_sum.prod-sum <> 0
                                then string( day_sum.prod-sum - day_sum.discnt-sum, "->,>>>,>>>,>>9.99" )
                                else fill( " ", 17 ) ) + {&tabulation}

         .
         if last-of( day_sum.day_ ) then do:
             FIND FIRST chk-day WHERE chk-day.day = day_sum.day_ .
             ACCUMULATE      chk-day.chk-qnty ( TOTAL ) .
             assign
             StrBuf = StrBuf + ( if ( ACCUM SUB-TOTAL BY day_sum.day_  day_sum.prod-qnty ) <> 0
                                 then string( string( ( ACCUM SUB-TOTAL BY day_sum.day_
                                                     day_sum.prod-qnty ), "->>>,>>9.<<<" ), "x(12)" )
                                 else fill( " ", 12 ) ) + p-XL-delim +
                               ( if ( ACCUM SUB-TOTAL BY day_sum.day_ day_sum.prod-sum ) <> 0
                                 then string( ( ACCUM SUB-TOTAL BY day_sum.day_
                                                 day_sum.prod-sum ) -
                                              ( ACCUM SUB-TOTAL BY day_sum.day_
                                                day_sum.discnt-sum ), "->,>>>,>>>,>>9.99" )
                                 else fill( " ", 17 ) ) + p-XL-delim +
                              ( if chk-day.chk-qnty <> 0
                                then string( chk-day.chk-qnty, ">>>>>>>9" )
                                else fill( " ", 8 ) ) + p-XL-delim
             XlStrBuf = XLStrBuf + ( if ( ACCUM SUB-TOTAL BY day_sum.day_  day_sum.prod-qnty ) <> 0
                                 then string( string( ( ACCUM SUB-TOTAL BY day_sum.day_
                                                     day_sum.prod-qnty ), "->>>,>>9.<<<" ), "x(12)" )
                                 else fill( " ", 12 ) ) + {&tabulation} +
                               ( if ( ACCUM SUB-TOTAL BY day_sum.day_ day_sum.prod-sum ) <> 0
                                 then string( ( ACCUM SUB-TOTAL BY day_sum.day_
                                                 day_sum.prod-sum ) -
                                              ( ACCUM SUB-TOTAL BY day_sum.day_
                                                day_sum.discnt-sum ), "->,>>>,>>>,>>9.99" )
                                 else fill( " ", 17 ) ) + {&tabulation} +
                              ( if chk-day.chk-qnty <> 0
                                then string( chk-day.chk-qnty, ">>>>>>>9" )
                                else fill( " ", 8 ) ) + {&tabulation}

             .
             EXPORT stream PrnLibStream StrBuf .
             {&PutExcel}
             XlStrBuf
             SKIP.
          end.
       END.
       assign
       StrBuf = p-XL-delim + string( "Итого( нетто )", "x(15)" ) + p-XL-delim
       XLStrBuf = string( "Итого( нетто )", "x(15)" ) + {&tabulation}
       .
       FOR EACH day_sum BREAK BY day_sum.prod-attr :
           ACCUMULATE
           day_sum.discnt-sum ( SUB-TOTAL BY day_sum.prod-attr )
           day_sum.prod-sum ( SUB-TOTAL BY day_sum.prod-attr )
           day_sum.prod-qnty ( SUB-TOTAL BY day_sum.prod-attr )
           day_sum.discnt-sum ( TOTAL )
           day_sum.prod-sum ( TOTAL )
           day_sum.prod-qnty ( TOTAL )
           day_sum.str-qnty ( TOTAL )
           .
       if last-of( day_sum.prod-attr )
       then
       assign
       StrBuf = StrBuf +
                string( string( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.prod-qnty,
                                  "->>>,>>9.<<<" ), "x(12)" ) + p-XL-delim +
                string( ( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.prod-sum ) -
                        ( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.discnt-sum ) ,
                        "->,>>>,>>>,>>9.99" ) + p-XL-delim
       XLStrBuf = XLStrBuf +
                string( string( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.prod-qnty,
                                  "->>>,>>9.<<<" ), "x(12)" ) + {&tabulation} +
                string( ( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.prod-sum ) -
                        ( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.discnt-sum ) ,
                        "->,>>>,>>>,>>9.99" ) + {&tabulation}
       .
     END.
     assign
     StrBuf = StrBuf +
              string( string( ACCUM TOTAL day_sum.prod-qnty, "->>>,>>9.<<<" ), "x(12)" )
                   + p-XL-delim +
              string( ( ACCUM TOTAL day_sum.prod-sum ) -
                         ( ACCUM TOTAL day_sum.discnt-sum ) , "->,>>>,>>>,>>9.99" ) + p-XL-delim +
              string( ACCUM TOTAL chk-day.chk-qnty, ">>>>>>>9" ) + p-XL-delim
     XLStrBuf = XLStrBuf +
              string( string( ACCUM TOTAL day_sum.prod-qnty, "->>>,>>9.<<<" ), "x(12)" )
                   + {&tabulation} +
              string( ( ACCUM TOTAL day_sum.prod-sum ) -
                         ( ACCUM TOTAL day_sum.discnt-sum ) , "->,>>>,>>>,>>9.99" ) + {&tabulation} +
              string( ACCUM TOTAL chk-day.chk-qnty, ">>>>>>>9" ) + {&tabulation}

     .
     EXPORT stream PrnLibStream StrBuf .
     PUT stream PrnLibStream "" skip .

     {&PutExcel}
     XlStrbuf
     SKIP.

     assign
     StrBuf = p-XL-delim + string( "Ошибки по кассе", "x(15)" ) + p-XL-delim
     XLStrBuf = string( "Ошибки по кассе", "x(15)" ) + {&tabulation}
     .
     FOR EACH day_sum BREAK BY day_sum.prod-attr :
        ACCUMULATE
        day_sum.discnt-sum ( SUB-TOTAL BY day_sum.prod-attr )
        day_sum.discnt-sum ( TOTAL )
        .
        if last-of( day_sum.prod-attr )
        then
        assign
        StrBuf = StrBuf + fill( " ", 12 ) + p-XL-delim +
                 string( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.discnt-sum,
                         "->,>>>,>>>,>>9.99" ) + p-XL-delim
        XLStrBuf = XlStrBuf + fill( " ", 12 ) + {&tabulation} +
                 string( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.discnt-sum,
                         "->,>>>,>>>,>>9.99" ) + {&tabulation}

        .
     END.

     assign
     StrBuf = StrBuf + fill( " ", 12 ) + p-XL-delim +
              string( ACCUM TOTAL day_sum.discnt-sum, "->,>>>,>>>,>>9.99" ) + p-XL-delim
     StrBuf = StrBuf + fill( " ", 8 ) + p-XL-delim
     XLStrBuf = XLStrBuf + fill( " ", 12 ) + {&tabulation} +
              string( ACCUM TOTAL day_sum.discnt-sum, "->,>>>,>>>,>>9.99" ) + {&tabulation}
     StrBuf = StrBuf + fill( " ", 8 ) + {&tabulation}
     .
     EXPORT stream PrnLibStream StrBuf .
     PUT stream PrnLibStream "" SKIP.
     {&PutExcel}
     XlStrBuf
     SKIP.
     assign
     StrBuf = p-XL-delim + string( "   ИТОГО", "x(15)" ) + p-XL-delim
     XLStrBuf = string( "   ИТОГО", "x(15)" ) + {&tabulation}
     .
     FOR EACH day_sum BREAK BY day_sum.prod-attr :
        ACCUMULATE
        day_sum.prod-qnty ( SUB-TOTAL BY day_sum.prod-attr )
        day_sum.prod-sum ( SUB-TOTAL BY day_sum.prod-attr )
        day_sum.discnt-sum ( TOTAL )
        day_sum.str-qnty ( TOTAL )
        .
        if last-of( day_sum.prod-attr )
        then
        assign
        StrBuf = StrBuf +
                 string( string( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.prod-qnty,
                                    "->>>,>>9.<<<" ), "x(12)" ) + p-XL-delim +
                 string(( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.prod-sum ) ,
                                    "->,>>>,>>>,>>9.99" ) + p-XL-delim
        XLStrBuf = XLStrBuf +
                 string( string( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.prod-qnty,
                                    "->>>,>>9.<<<" ), "x(12)" ) + {&tabulation} +
                 string(( ACCUM SUB-TOTAL BY day_sum.prod-attr day_sum.prod-sum ) ,
                                    "->,>>>,>>>,>>9.99" ) + {&tabulation}
        .
     END.
     assign
     StrBuf = StrBuf +
              string( string( ACCUM TOTAL day_sum.prod-qnty, "->>>,>>9.<<<" ), "x(12)" ) +
              p-XL-delim +
              string( ( ACCUM TOTAL day_sum.prod-sum ), "->,>>>,>>>,>>9.99" ) + p-XL-delim +
              string( ACCUM TOTAL chk-day.chk-qnty, ">>>>>>>9" ) + p-XL-delim
     XLStrBuf = XLStrBuf +
              string( string( ACCUM TOTAL day_sum.prod-qnty, "->>>,>>9.<<<" ), "x(12)" ) +
              {&tabulation} +
              string( ( ACCUM TOTAL day_sum.prod-sum ), "->,>>>,>>>,>>9.99" ) + {&tabulation} +
              string( ACCUM TOTAL chk-day.chk-qnty, ">>>>>>>9" ) + {&tabulation}
     .


     EXPORT stream PrnLibStream StrBuf .
     PUT stream PrnLibStream "" SKIP .

     {&PutExcel}
     XlStrBuf
     SKIP.
     run cur-time in this-procedure(output v-today, output v-time).
     PUT stream PrnLibStream space(70)
     "Итоговое кол-во покупок, шт "
     string( ACCUM TOTAL day_sum.prod-qnty, "->>>,>>9.<<<" ) AT 100 format "x(20)" skip
     space(58) "Коэффициент эффективности работы продавцов"
     string(round( ( ACCUM TOTAL chk-day.chk-qnty ) / ( ACCUM TOTAL day_sum.str-qnty ), 1 ),
            "->>>9.9" ) AT 103 format "x(20)" skip(2)
     space(10) "Директор магазина"   "Дата составления отчета" AT 60
     v-today format "99.99.9999" AT 90 skip(1)
     space(10) "Управляющий салоном"
     skip.
     output stream PrnLibStream CLOSE .
     {&CloseExcel}


     run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 11
                                          ).

     /*
     assign
     g#rep-tblname = ""
     g#rep-tblrid = -130
     g#rep-updflds = "Отчет по реализации|" + obj-list.obj-type +
                    string( obj-list.obj-code ) + "|" + string( vStartPoint ) + ".." + string( vEndPoint ) .
                    */
  end.
  else do:
      message "Не было никакой выручки на выбранных объектах" skip
              "в течение заданного Вами периода времени."
      view-as alert-box INFORMATION .
  end.
  FOR EACH day_sum :
      delete day_sum .
  END.
  FOR EACH prods  :
    delete prods .
  END.
  FOR EACH chk-day :
    delete chk-day  .
  END.

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
define variable     NotInc          as  log     no-undo.
run Assign-Frame in h_s-month.

Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.


For each obj-list no-lock:
 accumulate obj-list.obj-code (COUNT).
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
if (accum count obj-list.obj-code) > 1 then do:
    message "Выбрано больше одного объекта для отчета!"
    view-as alert-box ERROR.
    return.
end.
ReportNAme = "Помесячная реализация в магазине".
run gbl/numtomon.p ( month( vStartPoint ), output StrBuf ) .
run no-benqi(OUTPUT NotInc).
ReportHeader = "За " + StrBuf  + " " + ENTRY(NUm-entries(vStrBuf, " "), vStrBuf, " ")  + {&new-line} +
                if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " ".

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