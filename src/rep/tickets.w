&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Tickets
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Tickets
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор параметров печати ценников (этикеток)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT  PARAMETER Action      AS CHARACTER            NO-UNDO.
DEFINE INPUT  PARAMETER DocType AS CHARACTER            NO-UNDO.
/*doc-type бывает '':U 'bb-list'
при action "document" 'price'
при action "prod-bc" бывает "main" "part" "subs" */

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ rep/new-prn.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }

define variable ini-par as character no-undo.
define variable s       as character no-undo.
define variable v-today as date      no-undo.
define variable v-rb-is-base as logical no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable base-type as character no-undo .
define buffer buf_rep_currency for ub.currency.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Tickets

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-sel b-help RECT-3 RECT-Sort RECT-4 RECT-5 ~
RECT-1 RECT-2 qnty-type CurrTicket bcode-type price-type TickOnNulSale rate ~
OnlyChgPrice List-Sort-Type f-tick-ps
&Scoped-Define DISPLAYED-OBJECTS qnty-type CurrTicket bcode-type ~
TickOnWieght price-type TickOnNulSale rate List-Sort-Type f-tick-ps

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO DEFAULT
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-unit DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.

DEFINE VARIABLE CurrTicket AS CHARACTER FORMAT "X(256)":U INITIAL "Не печатать"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Не печатать"
     DROP-DOWN-LIST
     SIZE 27 BY 1 NO-UNDO.

DEFINE VARIABLE f-tick-ps AS CHARACTER FORMAT "X(8)":U
     LABEL "PS"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE rate AS DECIMAL FORMAT "->>,>>9.99<<":U INITIAL 0
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE unit-type AS CHARACTER FORMAT "X(3)":U INITIAL "шт"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE bcode-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Основной бар-код", "main",
"Бар-код партии", "part",
"Неосн. бар-код", "subs"
     SIZE 19.5 BY 3 NO-UNDO.

DEFINE VARIABLE List-Sort-Type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По коду", "1",
"По артикулу", "2",
"В порядке ввода", "3"
     SIZE 26 BY 2.67 NO-UNDO.

DEFINE VARIABLE price-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "текущий прайс-лист", "price",
"цена документа", "doc",
"прайс-лист на дату документа", "doc-pr"
     SIZE 31.38 BY 2.63 NO-UNDO.

DEFINE VARIABLE qnty-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по одному на товар", "один",
"по остаткам на объекте", "остаток",
"по кол-ву из списка", "список",
"по документу", "документ"
     SIZE 31 BY 4.17 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 33.25 BY 5.42.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 33.25 BY 5.5.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 29 BY 4.75.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 29 BY 2.5.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 29 BY 3.67.

DEFINE RECTANGLE RECT-Sort
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 29 BY 4.13.

DEFINE VARIABLE OnlyChgPrice AS LOGICAL INITIAL no
     LABEL "только с измен. ценой"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

DEFINE VARIABLE TickOnNulSale AS LOGICAL INITIAL no
     LABEL "в т.ч. с нулевыми ценами"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .83 NO-UNDO.

DEFINE VARIABLE TickOnSign AS LOGICAL INITIAL no
     LABEL "детально (по признакам)"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

DEFINE VARIABLE TickOnWieght AS LOGICAL INITIAL no
     LABEL "в т.ч. на весовой товар"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Tickets
     b-sel AT ROW 1 COL 2
     b-help AT ROW 1 COL 54
     qnty-type AT ROW 3.33 COL 32 NO-LABEL
     CurrTicket AT ROW 3.5 COL 3 NO-LABEL
     bcode-type AT ROW 5.17 COL 3 NO-LABEL
     unit-type AT ROW 7.17 COL 21.5 COLON-ALIGNED NO-LABEL
     b-unit AT ROW 7.17 COL 27.5
     TickOnWieght AT ROW 9 COL 3
     price-type AT ROW 9.04 COL 32 NO-LABEL
     TickOnNulSale AT ROW 10 COL 3
     TickOnSign AT ROW 11 COL 3
     rate AT ROW 11.83 COL 37.5 COLON-ALIGNED
     OnlyChgPrice AT ROW 12 COL 3 WIDGET-ID 2
     List-Sort-Type AT ROW 14.42 COL 3.75 NO-LABEL
     f-tick-ps AT ROW 15 COL 41.5 COLON-ALIGNED
     "Тип ценника (этикетки)" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 2.67 COL 5
     "Количества" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 2.67 COL 39.5
     "Цены" VIEW-AS TEXT
          SIZE 6 BY .67 AT ROW 8.08 COL 41.63
     "Сортировка" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 13.54 COL 7.63
     RECT-3 AT ROW 8.5 COL 2
     RECT-Sort AT ROW 13.25 COL 2
     RECT-4 AT ROW 2.33 COL 2
     RECT-5 AT ROW 4.83 COL 2
     RECT-1 AT ROW 2.33 COL 31
     RECT-2 AT ROW 7.75 COL 31
     SPACE(1.24) SKIP(4.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-sel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Tickets
   FRAME-NAME                                                           */
ASSIGN
       FRAME Tickets:SCROLLABLE       = FALSE
       FRAME Tickets:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-unit IN FRAME Tickets
   NO-ENABLE                                                            */
ASSIGN
       b-unit:HIDDEN IN FRAME Tickets           = TRUE.

/* SETTINGS FOR COMBO-BOX CurrTicket IN FRAME Tickets
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX OnlyChgPrice IN FRAME Tickets
   NO-DISPLAY                                                           */
/* SETTINGS FOR TOGGLE-BOX TickOnSign IN FRAME Tickets
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX TickOnWieght IN FRAME Tickets
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN unit-type IN FRAME Tickets
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       unit-type:HIDDEN IN FRAME Tickets           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Tickets
/* Query rebuild information for DIALOG-BOX Tickets
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Tickets */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Tickets
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tickets Tickets
ON WINDOW-CLOSE OF FRAME Tickets
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Tickets
ON CHOOSE OF b-sel IN FRAME Tickets /* Выбор */
DO:
  assign
    CurrTicket
    TickOnWieght
    TickOnSign
    TickOnNulSale
    qnty-type
    price-type
    unit-type
    bcode-type
    rate
    List-Sort-Type
    f-tick-ps
    OnlyChgPrice
    .
  assign
    TickOnN   = TickOnNulSale
    TickOnW   = TickOnWieght
    TickOnS   = TickOnSign
    QntyType  = qnty-type
    PriceType = price-type
    UnitName  = unit-type
    BCodeType = bcode-type
    curr-rate = rate
    List-sort = List-Sort-TYpe
    TickPS    = f-tick-ps
    OnlyChgPr = OnlyChgPrice
    .
  if CurrTicket <> "Не печатать" then
      do:
          DO i = 1 TO 1000:
              assign s = string( "Ticket" + trim( string( i, ">>>9" ) ) ).
              GET-KEY-VALUE SECTION "REP-SETS" KEY s VALUE ini-par.
              if entry( 1, ini-par, "#" ) = CurrTicket then
                  LEAVE.
          END.
          assign
              TicketName = entry( 2, ini-par, "#" )
              ScalePrice = decimal( entry( 3, ini-par, "#" ) )
              TicketType = entry( 4, ini-par, "#" )
              .
      end.
  else
      assign TicketName = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unit Tickets
ON CHOOSE OF b-unit IN FRAME Tickets
DO: /* Из таблицы os-norms выбрать и подставить код и норму амм-ции */
    def var unit-rec as recid no-undo.
    run ref/units.w ( input parparentproc, input yes, output unit-rec ).
    if unit-rec = ? then
        do:
            apply "entry" to unit-type in frame {&frame-name}.
            return no-apply.
        end.
    FIND ub.units WHERE recid (ub.units) = unit-rec NO-LOCK.
    assign unit-type = ub.units.unit-name.
    DISPLAY unit-type with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bcode-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bcode-type Tickets
ON VALUE-CHANGED OF bcode-type IN FRAME Tickets
DO:
    assign {&SELF-NAME}.
    assign TickOnSign = no.
    DISPLAY TickOnSign WITH FRAME {&FRAME-NAME}.
    if {&SELF-NAME} <> "part" AND v-cntxp-doc-prt AND Action <> "BCODE" AND Action <> "LIST" and Action <> "PROD-BC" then
        ENABLE TickOnSign WITH FRAME {&FRAME-NAME}.
    else
        DISABLE TickOnSign WITH FRAME {&FRAME-NAME}.

    if {&SELF-NAME} = "main" AND (Action = "SCALES" OR tick-w) then
        assign TickOnWieght = yes.
    else
        assign TickOnWieght = no.
    DISPLAY TickOnWieght WITH FRAME {&FRAME-NAME}.
    if {&SELF-NAME} = "main" AND Action = "ALL" then
        ENABLE TickOnWieght WITH FRAME {&FRAME-NAME}.
    else
        DISABLE TickOnWieght WITH FRAME {&FRAME-NAME}.

    CASE {&SELF-NAME}:
      WHEN "main" THEN do:
        if qnty-type:enable ( "по остаткам на объекте" ) then.
        if Action = "DOCUMENT" then do:
          if qnty-type:enable ( "по документу" )  then.
          if price-type:enable ( "цена документа" )  then.
          if price-type:enable ( "прайс-лист на дату документа" )  then.
        end.
        else do:
          if qnty-type:disable ( "по документу" )  then.
          if price-type:disable ( "цена документа" )  then.
          if price-type:disable ( "прайс-лист на дату документа" )  then.
        end.
        if Action = "LIST" then do:
          if qnty-type:enable ( "по кол-ву из списка" )  then.
        end.
        else do:
          if qnty-type:disable ( "по кол-ву из списка" )  then.
        end.
        DISABLE unit-type b-unit WITH FRAME {&FRAME-NAME}.
        HIDE unit-type b-unit IN FRAME {&FRAME-NAME}.
      end.
      WHEN "part" THEN do:
        if qnty-type:enable ( "по остаткам на объекте" )  then.
        if qnty-type:disable ( "по кол-ву из списка" )  then.

        if price-type:disable ( "цена документа" )  then.
        if price-type:disable ( "прайс-лист на дату документа" )  then.

        if Action = "DOCUMENT" then  do:
          if qnty-type:enable ( "по документу" )  then.
        end.
        else do:
          if qnty-type:disable ( "по документу" )  then.
        end.
        DISABLE unit-type b-unit WITH FRAME {&FRAME-NAME}.
        HIDE unit-type b-unit IN FRAME {&FRAME-NAME}.
      end.
      WHEN "subs" THEN do:
        if qnty-type:disable ( "по остаткам на объекте" )  then.
        if Action = "DOCUMENT" then do:
          if qnty-type:enable ( "по документу" )  then.
        end.
        else do:
          if qnty-type:disable ( "по документу" )  then.
        end.
        if price-type:disable ( "цена документа" )  then.
        if price-type:disable ( "прайс-лист на дату документа" )  then.
        ENABLE unit-type b-unit WITH FRAME {&FRAME-NAME}.
      end.
    END CASE.
    if doctype = "bb-list" then do:
      hide
      TickOnSign
      in frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME price-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL price-type Tickets
ON VALUE-CHANGED OF price-type IN FRAME Tickets
DO:
  assign price-type .
  if v-rb-is-base = true
     and v-base-code <> 0
     and DocType <> "price"
  then do:
    if price-type = "doc" or price-type = "doc-pr" then do:
      HIDE rate IN FRAME {&FRAME-NAME}.
    end.
    else do:
      ENABLE rate WITH FRAME {&FRAME-NAME}.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Tickets


/* ***************************  Main Block  *************************** */
{ rep/cur-rate.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/rbisbase.i
    v-rb-is-base
  }
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  { gbl/basecode.i v-host-code v-base-code }
  find first buf_rep_currency no-lock
    where buf_rep_currency.curr-code = v-base-code
    no-error .
    if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
                else base-type = "б.в." .

  DO i = 1 TO 1000:
      assign s = string( "Ticket" + trim( string( i, ">>>9" ) ) ).
      GET-KEY-VALUE SECTION "REP-SETS" KEY s VALUE ini-par.
      if ini-par = ? then
          LEAVE.
      else
          if CurrTicket:ADD-LAST( entry( 1, ini-par, "#" ) ) then.
  END.

  if v-rb-is-base = true
    and v-base-code <> 0
  then do:
    { gbl/curobjdt.i p-obj-type p-obj-code v-today }
    run proc-cur-rate( input p-obj-type, input p-obj-code, output Rubl_Coeff ).


    assign
      rate = Rubl_Coeff
    .
  end.
  assign
    List-Sort-Type:radio-buttons = "По коду"         + {&comma-char} + "b-code":U + {&comma-char} +
                                   "По артикулу"     + {&comma-char} + "artic":U +   {&comma-char} +
                                   "По наименованию" + {&comma-char} + "gds-name":U + {&comma-char} +
                                   "В порядке ввода" + {&comma-char} + "order-num":U
  .


  RUN enable_UI.

  if v-rb-is-base = true then do:
    if v-base-code = 0 OR (Action = "DOCUMENT" AND DocType <> "price" AND price-type = "doc" AND price-type = "doc-pr")
    then do:
      HIDE rate IN FRAME {&FRAME-NAME}.
    end.
  end.
  else do:
    HIDE rate IN FRAME {&FRAME-NAME}.
  end.
  if doctype = "bb-list" then do:
    assign
      qnty-type = "список"
      TickOnSign = yes
    .
    display
      qnty-type
      with frame {&frame-name}
      .
    hide
    bcode-type
    in frame {&frame-name} .
  end.
  if action <> "DOCUMENT"
    or ( action = "DOCUMENT":U
         and doctype <> "price":U
       )
  then do:
    disable
      OnlyChgPrice
      with frame {&frame-name} .
  end.
  if action = "PROD-BC" then do:
    DISABLE
    List-Sort-Type
    with frame {&frame-name}.
    if DocType = "main" then do:
      if bcode-type:disable ( "Бар-код партии" )  then.
      if bcode-type:disable ( "Неосн. бар-код" )  then.
    end.
    if DocType = "part" then do:
      if bcode-type:disable ( "Основной бар-код" )  then.
      if bcode-type:disable ( "Неосн. бар-код" )  then.
    end.
    if DocType = "subs" then do:
      if bcode-type:disable ( "Бар-код партии" )  then.
      if bcode-type:disable ( "Основной бар-код" )  then.
    end.
  end.
  else do:
    if Action <> "DOCUMENT"
    AND Action <> "LIST"
    AND Action <> "ALL" then  do:
      if bcode-type:disable ( "Бар-код партии" )  then.
      if bcode-type:disable ( "Неосн. бар-код" )  then.
    end.
  end.
  APPLY "VALUE-CHANGED" TO bcode-type IN FRAME {&FRAME-NAME}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cust Tickets
PROCEDURE cust :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Tickets  _DEFAULT-DISABLE
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
  HIDE FRAME Tickets.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Tickets  _DEFAULT-ENABLE
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
  DISPLAY qnty-type CurrTicket bcode-type TickOnWieght price-type TickOnNulSale
          rate List-Sort-Type f-tick-ps
      WITH FRAME Tickets.
  ENABLE b-sel b-help RECT-3 RECT-Sort RECT-4 RECT-5 RECT-1 RECT-2 qnty-type
         CurrTicket bcode-type price-type TickOnNulSale rate OnlyChgPrice
         List-Sort-Type f-tick-ps
      WITH FRAME Tickets.
  VIEW FRAME Tickets.
  {&OPEN-BROWSERS-IN-QUERY-Tickets}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME