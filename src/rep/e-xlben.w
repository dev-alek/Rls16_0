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

Помесячный оборот в ценах продаж

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
define variable vss-description as character no-undo init "Помесячный оборот в ценах продаж".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ rep/s-month.i NEW }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }
def work-table day_sum no-undo
    field obj-code  like ub.clients.obj-code
    field day          as   integer
    field tot-base   as   decimal
    field discnt      as   decimal
    field netto        as   decimal
    field price-list  as   decimal
    .
def work-table shops_ no-undo
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    .

def buffer cli-obj for ub.clients .
def buffer ret-doc for ub.trn-doc.
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
         SIZE 42 BY 11.88.


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
         WIDTH              = 40.25.
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
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .

{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.


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
       /* Position in AB:  ( 1.96 , 4.75 ) */
       /* Size in UIB:  ( 9.96 , 32.38 ) */

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
run Assign-Frame in h_s-month.
define variable     NotInc          as  log     no-undo.
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}


for each shops_:
    delete shops_.
end.
for each day_sum:
    delete day_sum.
end.
run My-var.
run no-benqi(output Notinc).

FOR EACH obj-list WHERE obj-list.obj-type = {&shop} NO-LOCK :

    FIND FIRST ub.clients WHERE
               ub.clients.obj-type = obj-list.obj-type AND
               ub.clients.obj-code = obj-list.obj-code NO-LOCK .
    CREATE shops_ .
    assign
    shops_.obj-code = ub.clients.obj-code
    shops_.obj-name = REPLACE(REPLACE(ub.clients.obj-name, {&comma-char}, ""), p-XL-delim, "")
    .

    DO ii = 1 TO vEndLastDay :
        CREATE day_sum .
        assign
        day_sum.obj-code = obj-list.obj-code
        day_sum.day = ii
        .
    END.
    FOR EACH ub.inkas No-LOCK WHERE
                      ub.inkas.obj-type = obj-list.obj-type AND
                      ub.inkas.obj-code = obj-list.obj-code AND
                      ub.inkas.doc-date >= vStartPoint AND
                      ub.inkas.doc-date <= vEndPoint /*AND
                      inkas.status_ = {&fact}*/
                BREAK
                BY ub.inkas.obj-type
                BY inkas.obj-code
                BY inkas.doc-date :
        ACCUMULATE ub.inkas.inkas-code (COUNT).
        FIND FIRST ub.trn-doc where ub.trn-doc.doc-code = ub.inkas.inkas-code no-lock no-error.
        FIND FIRST ret-doc where ret-doc.doc-code = ub.trn-doc.out-code no-lock no-error.

        ACCUMULATE
        ub.trn-doc.tot-fact ( SUB-TOTAL BY ub.inkas.doc-date ) /*сумма в продажных ценах*/
        ub.trn-doc.tot-calc ( SUB-TOTAL BY ub.inkas.doc-date ) /*скидка в продажных ценах*/
        ub.trn-doc.tot-ov ( SUB-TOTAL BY ub.inkas.doc-date ) /*разница с  прайс-листом*/
        ub.trn-doc.tot-sale ( SUB-TOTAL BY ub.inkas.doc-date ) /*сумма в продажных ценах*/
        ub.trn-doc.discnt-rubl ( SUB-TOTAL BY ub.inkas.doc-date )  /*скидка в продажных ценах*/

        .
        if available ret-doc then
        ACCUMULATE
        ret-doc.tot-fact ( SUB-TOTAL BY ub.inkas.doc-date ) /*сумма в продажных ценах*/
        ret-doc.tot-calc ( SUB-TOTAL BY ub.inkas.doc-date )  /*скидка в продажных ценах*/
        ret-doc.tot-ov  ( SUB-TOTAL BY ub.inkas.doc-date )  /*разница с  прайс-листом*/
        ret-doc.tot-sale ( SUB-TOTAL BY ub.inkas.doc-date ) /*сумма в продажных ценах*/
        ret-doc.discnt-rubl ( SUB-TOTAL BY ub.inkas.doc-date )  /*скидка в продажных ценах*/
        .


        if ( ( ACCUM COUNT ub.inkas.inkas-code ) modulo 10 ) = 0 AND
             ( ACCUM COUNT ub.inkas.inkas-code ) >= 10 then
        run waitfram-show in this-procedure ( obj-list.obj-type + " N" + string( obj-list.obj-code ) +
                        ", обработано отчетов по продажам : " +
                        string( ACCUM COUNT ub.inkas.inkas-code ) ) .
        if last-of( ub.inkas.doc-date ) then  do:
            CurrDay = day( ub.inkas.doc-date ) .
            FIND FIRST day_sum WHERE day_sum.day = CurrDay AND
                                     day_sum.obj-code = obj-list.obj-code .
        if v-curr-r-b = {&r-b-base} then do:
            assign
            day_sum.tot-base = ( ACCUM SUB-TOTAL BY ub.inkas.doc-date trn-doc.tot-fact ) -
                               ( ACCUM SUB-TOTAL BY ub.inkas.doc-date ret-doc.tot-fact )
            day_sum.discnt = ( ACCUM SUB-TOTAL BY ub.inkas.doc-date trn-doc.tot-calc ) -
                             ( ACCUM SUB-TOTAL BY ub.inkas.doc-date ret-doc.tot-calc )
            day_sum.netto =     day_sum.tot-base - day_sum.discnt
            day_sum.price-list = day_sum.tot-base +
                                 ( ACCUM SUB-TOTAL BY ub.inkas.doc-date trn-doc.tot-ov ) -
                                  ( ACCUM SUB-TOTAL BY ub.inkas.doc-date ret-doc.tot-ov )
            .
        end.
        else do:
            assign
            day_sum.tot-base = ( ACCUM SUB-TOTAL BY ub.inkas.doc-date trn-doc.tot-sale ) -
                               ( ACCUM SUB-TOTAL BY ub.inkas.doc-date ret-doc.tot-sale )
            day_sum.discnt = ( ACCUM SUB-TOTAL BY ub.inkas.doc-date trn-doc.discnt-rubl ) -
                             ( ACCUM SUB-TOTAL BY ub.inkas.doc-date ret-doc.discnt-rubl )
            day_sum.netto = day_sum.tot-base - day_sum.discnt
            day_sum.price-list = day_sum.tot-base +
                                ( ACCUM SUB-TOTAL BY ub.inkas.doc-date trn-doc.tot-ov ) -
                                ( ACCUM SUB-TOTAL BY ub.inkas.doc-date ret-doc.tot-ov )
            .
        end.
       end.
      END .
   END.
   run waitfram-hide in this-procedure .
   if can-find( first day_sum where day_sum.tot-base <> 0 ) then do:
      run gbl/numtomon.p ( month( vStartPoint ), output StrBuf ) .
      run prn-lib-open-stream  in this-procedure (
                                                  input my-handle
                                                  ,input 0
                                                  ,input yes /*p-is-stream*/
                                                  ,input no /*p-append*/
                                                  ).
      run waitfram-show in this-procedure (input "Ждите...").
      PUT stream PrnLibStream space(20)
      "Реализация товаров в магазинах" skip
      space(20) "в действовавших продажных ценах" skip(1)
      space(23) "за " StrBuf format "x(9)" string( year( vStartPoint ), ">>>9" ) format "x(4)"
      " года " skip(1)
      space(20) ( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ) format "x(40)" skip
      .

      /*if avail Sheetf then do:
      end.*/
      assign
      StrBuf = p-XL-delim + " Дата " + p-XL-delim
      sheetf.EXcel-Column-Lable = " Дата " + {&comma-char}
      sheetf.SizeS = "10" + {&comma-char}
      .
      FOR EACH shops_ BY shops_.obj-code :
         assign
         StrBuf = StrBuf +
                  string( "Маг.  N " + string ( shops_.obj-code, ">>>>>>9" ) +
                  p-XL-delim , "x(16)" )
         sheetf.EXcel-Column-Lable = sheetf.EXcel-Column-Lable +
                  string( "Маг.  N " + string ( shops_.obj-code, ">>>>>>9" ) +
                  {&comma-char} , "x(16)" )
         sheetf.Sizes = sheetf.SIzes + "16" + {&comma-char}
         .
      END .
      assign
      StrBuf = StrBuf + "     ИТОГО" + fill( " ", 5 ) + p-XL-delim
      sheetf.EXcel-Column-Lable = sheetf.EXcel-Column-Lable + "     ИТОГО" + fill( " ", 5 ) + {&comma-char}
      sheetf.Sizes = sheetf.SIzes + "16" + {&comma-char}
      .
      EXPORT stream PrnLibStream StrBuf p-XL-delim.
      ASSIGN
      StrBuf = p-XL-delim + fill( " ", 6 ) + p-XL-delim
      sheetf.EXcel-Column-Lable = sheetf.EXcel-Column-Lable + {&new-line} + {&comma-char}
      .
      FOR EACH shops_ BY shops_.obj-code :
         assign
         StrBuf = StrBuf + string( string( shops_.obj-name, "x(15)" ) + p-XL-delim , "x(16)" )
         sheetf.EXcel-Column-Lable = sheetf.EXcel-Column-Lable + string( replace(shops_.obj-name, {&comma-char}, "":U), "x(15)" ) + {&comma-char}
         .
      END .
      assign
      StrBuf = StrBuf + fill( " ", 15 ) + p-XL-delim
      sheetf.EXcel-Column-Lable = EXcel-Column-Lable + {&comma-char}
      str3 = " "
      .
      EXPORT stream PrnLibStream StrBuf .

      run rep/extitle.p (1).
      PUT stream PrnLibStream "" skip .
      {&PutExcel}
      SKIP
      .

      FOR EACH day_sum BREAK BY day_sum.day BY day_sum.obj-code :
         if first-of( day_sum.day )
         then
         assign
         StrBuf = p-XL-delim + string( day_sum.day, ">>>>9" ) + " " + p-XL-delim
         XlStrBuf = string( day_sum.day ) + " " + {&tabulation}
         .
         ACCUMULATE day_sum.tot-base ( SUB-TOTAL BY day_sum.day ) .
         assign
         StrBuf = StrBuf + ( if day_sum.tot-base <> 0
                             then string( day_sum.tot-base, "->>>,>>>,>>9.99" )
                             else fill( " ", 15 )
                            ) + p-XL-delim
         XLStrBuf = XLStrBuf + ( if day_sum.tot-base <> 0
                             then string( day_sum.tot-base)
                             else "":U
                            ) + {&tabulation}
         .
         if last-of( day_sum.day ) then do:
            assign
            StrBuf = StrBuf + ( if ( ACCUM SUB-TOTAL BY day_sum.day day_sum.tot-base ) <> 0
                                then string( ( ACCUM SUB-TOTAL BY day_sum.day day_sum.tot-base ), "->>>,>>>,>>9.99" )
                                else fill( " ", 15 )
                               ) + p-XL-delim
            XlStrBuf = XLStrBuf + ( if ( ACCUM SUB-TOTAL BY day_sum.day day_sum.tot-base ) <> 0
                                then string( ( ACCUM SUB-TOTAL BY day_sum.day day_sum.tot-base ))
                                else  "":U
                               ) + {&tabulation}
            .
            EXPORT stream PrnLibStream StrBuf .
            {&PutExcel}
            XLstrbuf
            skip
            .
         end.
      END.

      PUT stream PrnLibStream "" skip .
      {&PutExcel}
      ""
      SkIP.
      assign
      StrBuf = string( p-XL-delim + "Итого " + p-XL-delim )
      XLStrBuf = string( "Итого " + {&tabulation} )
      .
      FOR EACH day_sum BREAK BY day_sum.obj-code :
        ACCUMULATE
        day_sum.tot-base ( SUB-TOTAL BY day_sum.obj-code )
        day_sum.tot-base ( TOTAL )
        .
        if last-of( day_sum.obj-code )
        then
        assign
        StrBuf = StrBuf +
                 string( ACCUM SUB-TOTAL BY day_sum.obj-code day_sum.tot-base, "->>>,>>>,>>9.99" ) +
                 p-XL-delim
        XLStrBuf = XLStrBuf +
                 string( ACCUM SUB-TOTAL BY day_sum.obj-code day_sum.tot-base ) +
                 {&tabulation}
        .
      END.
      assign
      StrBuf = StrBuf +
               string( ACCUM TOTAL day_sum.tot-base, "->>>,>>>,>>9.99" ) + p-XL-delim
      XLStrBuf = XLStrBuf +
               string( ACCUM TOTAL day_sum.tot-base )+ {&tabulation}

      .

      EXPORT stream PrnLibStream StrBuf .
      PUT stream PrnLibStream " " SKIP.
      {&PutExcel}
      XlStrbuf
      SKIP
      .
      assign
      StrBuf = string( p-XL-delim + "Скидки" + p-XL-delim )
      XLStrBuf = string( "Скидки" + {&tabulation} )
      .
      FOR EACH day_sum BREAK BY day_sum.obj-code :
          ACCUMULATE
          day_sum.discnt ( SUB-TOTAL BY day_sum.obj-code )
          day_sum.discnt ( TOTAL )
          .
          if last-of( day_sum.obj-code )
          then
          assign
          StrBuf = StrBuf +
                   string( ACCUM SUB-TOTAL BY day_sum.obj-code day_sum.discnt, "->>>,>>>,>>9.99" ) +
                   p-XL-delim
          XLStrBuf = XLStrBuf +
                   string( ACCUM SUB-TOTAL BY day_sum.obj-code day_sum.discnt ) +
                   {&tabulation}
         .
      END.
      assign
      StrBuf = StrBuf +
               string( ACCUM TOTAL day_sum.discnt , "->>>,>>>,>>9.99" ) + p-XL-delim
      XLStrBuf = XLStrBuf +
               string( ACCUM TOTAL day_sum.discnt ) + {&tabulation}
      .

      EXPORT stream PrnLibStream StrBuf .
      PUT stream PrnLibStream " " SKIP.
      {&PutExcel}
      XlStrbuf
      SKIP
      .
      run waitfram-hide in this-procedure .

      output stream PrnLibStream CLOSE .
      {&CloseExcel}

      run prn-lib-prn-file in this-procedure (
                                                input my-handle
                                                ,input 11
                                                ).
      /*
      assign
      g#rep-tblname = ""
      g#rep-tblrid = -127
      g#rep-updflds = "Помесячный оборот по магазинам в ценах продаж|" +
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
FOR EACH day_sum :
    delete day_sum .
END.
FOR EACH shops_ :
    delete shops_ .
END.
run waitfram-hide in this-procedure .

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
define variable Strbuf as char No-undo.
define variable     NotInc          as  log     no-undo.
run Assign-Frame in h_s-month.

Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
assign
ReportNAme = "Помесячный оборот в ценах продаж"
.
run gbl/numtomon.p ( month( vStartPoint ), output StrBuf ) .
run no-benqi(output Notinc).
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