&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать отчета о сертификатах

Автор: Чернова Светлана Александровна
Дата создания: 09/07/05
Author: Svetlana Chernova
Creation date: 09/07/05

*/
 define variable vss-revision    as character no-undo init "$Revision$":U .
 define variable vss-author      as character no-undo init "$Author$":U .
 define variable vss-date        as character no-undo init "$Date$":U .
 define variable vss-workfile    as character no-undo init "$Workfile$":U .
 define variable vss-archive     as character no-undo init "$Archive$":U .
 define variable vss-description as character no-undo init "Печать отчета о сертификатах".
  { cmp/vssrevis.i  }
  { cmp/str-glbl.i   }
  { cmp/r-pril.i new}
  { cmp/r-page1.i   }
  { rep/r-sym.i     }
  { gbl/cur-time.i  }
  { rep/rep-bt.i    }
  { rep/lkp-font.i  }

CREATE WIDGET-POOL.
    define variable rid-list as character no-undo.
    DEFINE STREAM Out-Stream .
    define variable Line      as      character    no-undo.
    define variable lastdate as date no-undo.

    define temp-table gds-sert no-undo
        field artic like goods.artic
        field prod-type like goods.prod-type
        field prod-code like goods.prod-code
        field gds-name like goods.gds-name
        field b-code like bar-code.b-code
        index pi as UNIQUE artic prod-type prod-code.

    define frame gds-srt
        sym1 column-label ":!:" format "X(1)" space(0)
        gds-sert.artic COLUMN-LABEL "Артикул" format "X(20)" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        gds-sert.gds-name COLUMN-LABEL "Наименование товара! " format "X(40)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        lastdate COLUMN-LABEL "Дата окончания"  space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
    HEADER
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) AT 120 format "X(13)" SKIP
        Line format "X(135)" AT 1
    with width {&DOS_CW} down stream-io.

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
&Scoped-Define ENABLED-OBJECTS cl-code cl-type B-cli r-s-type 
&Scoped-Define DISPLAYED-OBJECTS cl-code cl-type t-date cl-name r-s-type 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 2.5 BY 1 TOOLTIP "Выбор контрагента".

DEFINE VARIABLE cl-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0 
     LABEL "Код" 
     VIEW-AS FILL-IN 
     SIZE 10.25 BY 1 NO-UNDO.

DEFINE VARIABLE cl-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 62 BY 1 NO-UNDO.

DEFINE VARIABLE cl-type AS CHARACTER FORMAT "X(3)":U 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE cur-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE q-days AS INTEGER FORMAT "->,>>>,>>9":U INITIAL ? 
     LABEL "Количество дней" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE t-date AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE r-s-type AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Товары без сертификатов", 1,
"Товары (срок годности не позже указанной даты)", 2,
"Товары (срок годности не позже кол-ва дней от текущей даты)", 3
     SIZE 62 BY 2.63 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     cl-code AT ROW 1 COL 17.63 COLON-ALIGNED
     cl-type AT ROW 1 COL 28.25 COLON-ALIGNED NO-LABEL
     B-cli AT ROW 1 COL 34.75
     t-date AT ROW 1 COL 47 COLON-ALIGNED NO-LABEL
     cl-name AT ROW 2.13 COL 1 NO-LABEL
     r-s-type AT ROW 3.54 COL 1 NO-LABEL
     cur-date AT ROW 6.5 COL 5 COLON-ALIGNED
     q-days AT ROW 6.5 COL 39.5 COLON-ALIGNED
     "Контрагент:" VIEW-AS TEXT
          SIZE 13 BY 1 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


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
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 8.33
         WIDTH              = 63.5.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN cl-name IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN cur-date IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN q-days IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN t-date IN FRAME F-Main
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

&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli V-table-Win
ON CHOOSE OF B-cli IN FRAME F-Main
DO:
  run ref/cli-all.w (my-handle,  "{&lookup},b-sel", ?, ?, ?, ?, ?, ?, output rid-list).
  find clients where recid(clients) = integer(rid-list) no-lock no-error.
  if not available clients then do:
    message "Контрагент не выбран!" view-as alert-box warning.
    return no-apply.
  end.
  if clients.obj-type = {&shop} or clients.obj-type = {&stock} then do:
    message "Склады и магазины не могут иметь сертификаты" view-as alert-box error.
    return no-apply.
  end.
  assign
      cl-type = clients.obj-type
      cl-code = clients.obj-code
      cl-name  = clients.obj-name.
  disp
      cl-type
      cl-code
      cl-name
      with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-s-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-s-type V-table-Win
ON VALUE-CHANGED OF r-s-type IN FRAME F-Main
DO:
  assign r-s-type.
  case r-s-type:
    when 1 then do:
        disable cur-date q-days with frame {&frame-name}.
        hide cur-date q-days .
    end.
    when 2 then do:
        disable q-days with frame {&frame-name}.
        hide q-days .
        enable cur-date with frame {&frame-name}.
        disp cur-date with frame {&frame-name}.
    end.
    when 3 then do:
        disable cur-date with frame {&frame-name}.
        hide cur-date .
        enable q-days with frame {&frame-name}.
        disp q-days with frame {&frame-name}.
    end.
   end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  &ENDIF
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  run cur-time in this-procedure ( output t-date
                                 , output v-time
                                 ).
  assign
    Line = fill("-", 135)
  .
  disp t-date with frame {&frame-name}.

  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report V-table-Win 
PROCEDURE my-report :
run print-cert (buffer clients).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var V-table-Win 
PROCEDURE my-var :
assign frame {&frame-name}
          r-s-type cl-type cl-code q-days cur-date.
  find clients where clients.obj-type = cl-type  and clients.obj-code = cl-code  no-lock no-error.
  if not available clients then do:
    message "Не выбран контрагент!" view-as alert-box error.
    return no-apply.
  end.
  if clients.is-prod = yes or clients.sup-gds = yes then.
  else do:
    message "Клиент должен быть поставщиком или (и) производителем!" view-as alert-box error.
    return no-apply.
  end.
  if r-s-type = 2 and cur-date = ? then do:
    message "Надо ввести дату окончания срока действия сертификатов" view-as alert-box error.
    return no-apply.
  end.
  if r-s-type = 3 and q-days = ? then do:
    message "Надо ввести количество дней срока действия сертификатов" view-as alert-box error.
    return no-apply.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-cert V-table-Win 
PROCEDURE print-cert :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define parameter buffer b-cli for clients.
    define variable sup-type as character format "x(25)" no-undo.
    if clients.is-prod = yes then sup-type = "Производитель".
    if clients.sup-gds = yes then sup-type = "Поставщик".
    if clients.sup-gds = yes and clients.is-prod = yes then sup-type = "Поставщик/Производитель".
    for each gds-sert:
        delete gds-sert.
    end.
    if session:set-wait-state("compiler") then.
    { cmp/open-out.i STREAM Out-Stream " " ReportPageHeight}
    case r-s-type:
        when 1 then
            put stream out-stream
                " Товары без сертификатов " format "x(30)" skip
                sup-type format "x(25)" b-cli.obj-name format "x(50)"  skip.
        when 2 then
            put stream out-stream
                " Товары со сроком годности не позднее " format "x(40)" string(cur-date)  skip
                sup-type format "x(25)" b-cli.obj-name format "x(50)"  skip.
        when 3 then
            put stream out-stream
                " Товары со сроком годности заканчивающимся не позднее чем через " format "x(60)" string(q-days)  " дней" skip
                sup-type format "x(25)" b-cli.obj-name format "x(50)"  skip.
    end case.
    FORM HEADER
        Line format "X(135)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX.
    VIEW stream out-stream FRAME BottomFrame .
    Line = fill("-", 135) .
    if b-cli.sup-gds = yes then do: /* заполним для поставщика список товаров */
        for each cli-gds where cli-gds.cli-type = b-cli.obj-type and cli-gds.cli-code = b-cli.obj-code no-lock:
            find gds-sert where gds-sert.artic = cli-gds.artic and
                                            gds-sert.prod-type = cli-gds.prod-type and
                                            gds-sert.prod-code = cli-gds.prod-code no-error.
            if  not available gds-sert then do:
                find goods where goods.artic = cli-gds.artic and
                                            goods.prod-type  = cli-gds.prod-type and
                                            goods.prod-code = cli-gds.prod-code no-lock.
                FIND ub.gds-prt WHERE ub.gds-prt.upper-code = goods.prt-root NO-LOCK .
                find bar-code where   bar-code.gds-code = goods.gds-code
                                                    AND bar-code.node-code = gds-prt.node-code
                                                    AND bar-code.part-code = ""
                                                    AND bar-code.in-code = ""
                                                    AND bar-code.unit-cli = goods.unit-base no-lock.
                create gds-sert.
                assign
                    gds-sert.artic = goods.artic
                    gds-sert.prod-type = goods.prod-type
                    gds-sert.prod-code = goods.prod-code
                    gds-sert.b-code = bar-code.b-code
                    gds-sert.gds-name = goods.gds-name.
            end.
        end.
    end.
    if b-cli.is-prod = yes then do: /* заполним для производителя список товаров */
        for each goods where goods.prod-type = b-cli.obj-type and goods.prod-code = b-cli.obj-code no-lock:
            find gds-sert where gds-sert.artic = goods.artic and
                                            gds-sert.prod-type = goods.prod-type and
                                            gds-sert.prod-code = goods.prod-code no-error.
            if  not available gds-sert then do:
                FIND ub.gds-prt WHERE ub.gds-prt.upper-code = goods.prt-root NO-LOCK .
                find bar-code where   bar-code.gds-code = goods.gds-code
                                                    AND bar-code.node-code = gds-prt.node-code
                                                    AND bar-code.part-code = ""
                                                    AND bar-code.in-code = ""
                                                    AND bar-code.unit-cli = goods.unit-base no-lock.
                create gds-sert.
                assign
                    gds-sert.artic = goods.artic
                    gds-sert.prod-type = goods.prod-type
                    gds-sert.prod-code = goods.prod-code
                    gds-sert.b-code = bar-code.b-code
                    gds-sert.gds-name = goods.gds-name.
            end.
        end.
    end.
    /*
    if r-s-type <> 1 then do: /* заполним для товаров по которым еще не было приходов а сертификаты уже есть */
        for each sert where sert.cli-type = b-cli.obj-type and sert.cli-code  = b-cli.obj-code no-lock:
            for each sert-join where sert-join.
            find gds-sert where gds-sert.artic = goods.artic and
                                            gds-sert.prod-type = goods.prod-type and
                                            gds-sert.prod-code = goods.prod-code no-error.
            if  not available gds-sert then do:
                create gds-sert.
                assign
                    gds-sert.artic = goods.artic
                    gds-sert.prod-type = goods.prod-type
                    gds-sert.prod-code = goods.prod-code.
            end.
        end.
    end.
*/
    if session:set-wait-state("COMPILER") then.
    FORM with frame gds-srt .
        case r-s-type:
            when 1 then do:
                for each gds-sert no-lock:
                    if not can-find( first sert-join where sert-join.b-code = gds-sert.b-code) then
                        disp stream out-stream sym1 gds-sert.artic sym2 gds-sert.gds-name sym3
                        with frame gds-srt.
                    DOWN stream out-stream 1 with frame gds-srt .
                end.
            end.
            when 2 then do:
                for each gds-sert no-lock:
                    for each sert-join where sert-join.b-code = gds-sert.b-code and
                                                           sert-join.cli-type = b-cli.obj-type and
                                                           sert-join.cli-code = b-cli.obj-code:
                        find sert of sert-join no-lock.
                        if sert.last-date <= cur-date then do:
                            lastdate = sert.last-date.
                            disp stream out-stream sym1 gds-sert.artic sym2 gds-sert.gds-name sym3
                            lastdate  sym4
                            with frame gds-srt.
                            DOWN stream out-stream 1 with frame gds-srt .
                        end.
                    end.
                end.
            end.
            when 3 then do:
                for each gds-sert no-lock:
                    for each sert-join where sert-join.b-code = gds-sert.b-code and
                                                           sert-join.cli-type = b-cli.obj-type and
                                                           sert-join.cli-code = b-cli.obj-code:
                        find sert of sert-join no-lock.
                        run cur-time in this-procedure ( output v-today
                                                       , output v-time
                                                       ).
                        if sert.last-date <= v-today + q-days then do:
                            lastdate = sert.last-date.
                            disp stream out-stream sym1 gds-sert.artic sym2 gds-sert.gds-name sym3
                            lastdate sym4
                            with frame gds-srt.
                            DOWN stream out-stream 1 with frame gds-srt .
                        end.
                    end.
                end.
            end.
        end case.
    HIDE stream out-stream FRAME BottomFrame .
    PUT stream out-stream Line format "X(135)" SKIP .
    output stream out-stream CLOSE .

define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
define variable v-orient-page as character no-undo .

run How-name in this-procedure (
    input ReportPageHeight,
    input ReportPageWidth,
    output v-orient-page )
    .

if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                               else DisabledOptions = 0 .

run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  ,input  reportFontNum
  ,output v-user-action
  ,output v-printed
  ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

