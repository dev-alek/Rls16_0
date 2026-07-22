&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog

/* Temp-Table and Buffer definitions                                    */
DEFINE SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE SHARED TEMP-TABLE tt-goods NO-UNDO LIKE ub.goods.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Главный экран архивов

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define new shared variable varparentproc like parparentproc no-undo.
assign
  varparentproc = parparentproc
    .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Главный экран архивов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ gbl/clntattr.i }
{ gbl/userobjs.i }
{ gbl/getcntxt.i def }

define variable v_shift         as character no-undo .
define variable par-type        as character no-undo .
define variable varext-doc-type as character no-undo .
define variable v-today         as date      no-undo .
define variable v-time          as integer   no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

/*Для передачи в печать*/
{ cmp/r-page1.i new }
 my-handle = parparentproc .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME D-Dialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-arh b-print b-start-date b-goods ~
b-object b-help vared-goods vardate-start vardate-end vared-obj r-rb ~
fi-description-1
&Scoped-Define DISPLAYED-OBJECTS vared-goods varis-calend vardate-start ~
vardate-end vared-obj r-rb fi-description-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_b-otlina AS HANDLE NO-UNDO.
DEFINE VARIABLE h_folder AS HANDLE NO-UNDO.
DEFINE VARIABLE h_main-arc AS HANDLE NO-UNDO.
DEFINE VARIABLE h_v-gdsobj AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-arh
     LABEL "Пр&осмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON b-goods
     LABEL "Товары"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON b-object
     LABEL "О&бъекты"
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 10 BY 1.

DEFINE BUTTON b-start-date
     LABEL "&Начало"
     SIZE 10 BY 1.

DEFINE VARIABLE vared-goods AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 26.88 BY 1.54
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE vared-obj AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 26.63 BY 1.29
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE fi-description-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE vardate-end AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE vardate-start AS DATE FORMAT "99/99/9999":U
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 TOOLTIP "Дата ~"C~"" NO-UNDO.

DEFINE VARIABLE varshift-end AS INTEGER FORMAT ">9":U INITIAL 1
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Номер смены <<По>>" NO-UNDO.

DEFINE VARIABLE varshift-start AS INTEGER FORMAT ">9":U INITIAL 1
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Номер смены <<C>>" NO-UNDO.

DEFINE VARIABLE r-rb AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&abbr_rub_firstshift", 1,
"&Вал", 2
     SIZE 18.88 BY .88
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varis-calend AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Календ.", 1,
"&Смен.", 2
     SIZE 16.63 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varis-shift-num AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 1.63 BY .75 TOOLTIP "Указать порядок смен" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     b-exit AT ROW 1 COL 1
     b-arh AT ROW 1 COL 11
     b-print AT ROW 1 COL 21
     b-start-date AT ROW 1 COL 31
     b-goods AT ROW 1 COL 41
     b-object AT ROW 1 COL 51
     b-help AT ROW 1 COL 61
     vared-goods AT ROW 2 COL 72.13 NO-LABEL
     varis-calend AT ROW 2.17 COL 1.13 NO-LABEL
     vardate-start AT ROW 2.21 COL 21.25 COLON-ALIGNED
     varshift-start AT ROW 2.21 COL 33.25 COLON-ALIGNED NO-LABEL
     vardate-end AT ROW 2.21 COL 41.5 COLON-ALIGNED
     varshift-end AT ROW 2.21 COL 54 COLON-ALIGNED NO-LABEL
     varis-shift-num AT ROW 2.33 COL 18.25
     vared-obj AT ROW 3.79 COL 72.25 NO-LABEL
     r-rb AT ROW 3.25 COL 1.13 NO-LABEL
     fi-description-1 AT ROW 3.42 COL 19.25 COLON-ALIGNED NO-LABEL
     SPACE(29.00) SKIP(19.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Складской архив по товарам на объектах".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Design Page: 1
   Temp-Tables and Buffers:
      TABLE: tt-clients T "SHARED" NO-UNDO ub clients
      TABLE: tt-goods T "SHARED" NO-UNDO ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
                                                                        */
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* SETTINGS FOR RADIO-SET varis-calend IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX varis-shift-num IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varis-shift-num:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN varshift-end IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN varshift-start IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON END-ERROR OF FRAME D-Dialog /* Складской архив по товарам на объектах */
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON ENDKEY OF FRAME D-Dialog /* Складской архив по товарам на объектах */
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Складской архив по товарам на объектах */
DO:
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-arh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-arh D-Dialog
ON CHOOSE OF b-arh IN FRAME D-Dialog /* Просмотр */
DO:
  run read-arh in this-procedure no-error.
  if error-status :error then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods D-Dialog
ON CHOOSE OF b-goods IN FRAME D-Dialog /* Товары */
DO:
  run select-goods-list in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-object D-Dialog
ON CHOOSE OF b-object IN FRAME D-Dialog /* Объекты */
DO:
  run select-object-list in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print D-Dialog
ON CHOOSE OF b-print IN FRAME D-Dialog /* Печать */
DO:
  define variable varbase-type like ub.currency.curr-abbr no-undo.
  define variable varbase-code like ub.currency.curr-code no-undo.

    { gbl/basecode.i v-host-code varbase-code }

  find first ub.currency no-lock
    where ub.currency.curr-code = varbase-code
    .
  assign
    varbase-type = ub.currency.curr-abbr
    varbase-code = ub.currency.curr-code
  .

  run read-arh in this-procedure  no-error.
  if error-status :error then do:
    return no-apply.
  end.
  for each gds-list
  :
    delete gds-list.
  end.
  for each obj-list
  :
    delete obj-list.
  end.
  for each tt-goods
  :
    create gds-list.
    buffer-copy tt-goods to gds-list .
  end.
  for each tt-clients
  :
    { cmp/cr-objls.i
      tt-clients.obj-type
      tt-clients.obj-code
      no-error
    }
  end.

  /* установка разделяемых переменных для печати */
  assign
    x-date-end     = vardate-end
    x-date-start   = vardate-start
    x-tog-shift    = (if varis-calend = 2
                      then yes
                      else no
                     )
    x-shift-end    = (if varis-calend = 2
                      then (if varis-shift-num
                            then varshift-end
                            else ?
                           )
                      else ?
                     )
    x-shift-start  = (if varis-calend = 2
                      then (if varis-shift-num
                            then varshift-start
                            else ?
                           )
                      else ?
                     )
    x-set_val_type = r-rb
  .

  run rep/r-o-good.p
    (input  p-curr-obj-code
    ,input  p-curr-obj-type
    ,input  varbase-type
    ,input  varbase-code
    ,input  {&all}
    ,input  no
    ,input  "no-classify":u
    ,input  ""
    ,input  "goods,no":u
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-start-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start-date D-Dialog
ON CHOOSE OF b-start-date IN FRAME D-Dialog /* Начало */
DO:
  define variable v-first-date-oper as date no-undo .
  run first-date-oper in this-procedure
    (output v-first-date-oper
    ).

  define variable v-ok as logical   no-undo .
  message
    "По выбранным объектам имеются архивы с даты" string(v-first-date-oper, '99/99/9999':u) skip
    "Подставить эту дату в экранную форму?"
    view-as alert-box question buttons yes-no update v-ok .

  if v-ok = true
  then do:
    assign
      vardate-start = v-first-date-oper
    .
    display
      vardate-start with frame {&frame-name}
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-rb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-rb D-Dialog
ON VALUE-CHANGED OF r-rb IN FRAME D-Dialog
DO:
  assign
    frame {&frame-name} r-rb
  .
  run need-read-arh in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vardate-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vardate-end D-Dialog
ON LEAVE OF vardate-end IN FRAME D-Dialog /* По */
DO:
  if vardate-end <> input frame {&frame-name} vardate-end
  then do:
    assign
      frame {&frame-name} vardate-end
    .

    run need-read-arh in this-procedure .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vardate-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vardate-start D-Dialog
ON LEAVE OF vardate-start IN FRAME D-Dialog /* С */
DO:
  if vardate-start <> input frame {&frame-name} vardate-start
  then do:
    assign
      frame {&frame-name} vardate-start
    .

    run need-read-arh in this-procedure .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varis-calend
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varis-calend D-Dialog
ON VALUE-CHANGED OF varis-calend IN FRAME D-Dialog
DO:
  assign
    frame {&frame-name} varis-calend
    .
  if varis-calend = 1
  then do:
    assign
      varis-shift-num = false
    .
    display
      varis-shift-num with frame {&frame-name}.
    hide varis-shift-num varshift-start varshift-end in frame {&frame-name}.
  end.
  else do:
    view varis-shift-num in frame {&frame-name}.
    display varis-shift-num with frame {&frame-name}.
    enable varis-shift-num with frame {&frame-name}.
    run val-chg-is-shift-num in this-procedure .
  end.

  run need-read-arh in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varis-shift-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varis-shift-num D-Dialog
ON VALUE-CHANGED OF varis-shift-num IN FRAME D-Dialog
DO:
  if varis-shift-num <> input frame {&frame-name} varis-shift-num
  then do:
    assign
      frame {&frame-name} varis-shift-num
    .

    if varis-shift-num = yes
    then do:
      assign
        varshift-start = 1
        varshift-end   = 1
      .
    end.

    run val-chg-is-shift-num in this-procedure
      no-error .
    if error-status :error then do:
      return no-apply.
    end.

    run need-read-arh in this-procedure .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varshift-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varshift-end D-Dialog
ON LEAVE OF varshift-end IN FRAME D-Dialog
DO:
  if varshift-end <> input frame {&frame-name} varshift-end
  then do:
    assign
      frame {&frame-name} varshift-end
    .

    run need-read-arh in this-procedure .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varshift-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varshift-start D-Dialog
ON LEAVE OF varshift-start IN FRAME D-Dialog
DO:
  if varshift-start <> input frame {&frame-name} varshift-start
  then do:
    assign
      frame {&frame-name} varshift-start
    .

    run need-read-arh in this-procedure .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog


/* ***************************  Main Block  *************************** */

assign
  r-rb :radio-buttons = "&{&abbr_rub_firstshift}" + {&comma-char} + '1'
                      + {&comma-char} + "&Вал" + {&comma-char} + '2'
.
{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
{ gbl/getcntxt.i get }

assign
  v_shift = "yes"
.

if v_shift = "yes"
then do:
  enable
    varis-calend
    with frame {&frame-name} .
end.
else do:
  disable
    varis-calend
    with frame {&frame-name} .
end.

run cur-time in this-procedure
  (output v-today
  ,output v-time
  ).
assign
  vardate-start = date( month( v-today ), 1, year( v-today ) )
  vardate-end   = v-today
.
run pre-display   in this-procedure .
run need-read-arh in this-procedure .

{ gbl/app_help.i }
{ gbl/ed_date.i vardate-start }
{ gbl/ed_date.i vardate-end }

{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog  _ADM-CREATE-OBJECTS
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
             INPUT  'adm/objects/folder.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'FOLDER-LABELS = ':U + 'Осн. архивы|Документы|Тек. сост.' + ',
                     FOLDER-TAB-TYPE = 1':U ,
             OUTPUT h_folder ).
       RUN set-position IN h_folder ( 4.29 , 1.00 ) NO-ERROR.
       RUN set-size IN h_folder ( 19.33 , 98.88 ) NO-ERROR.

       /* Links to SmartFolder h_folder. */
       RUN add-link IN adm-broker-hdl ( h_folder , 'Page':U , THIS-PROCEDURE ).

    END. /* Page 0 */

    WHEN 1 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'arc/main-arc.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_main-arc ).
       RUN set-position IN h_main-arc ( 5.25 , 1.00 ) NO-ERROR.
       RUN set-size IN h_main-arc ( 18.21 , 98.25 ) NO-ERROR.

       /* Links to SmartObject h_main-arc. */
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'date-price':U , h_main-arc ).
       RUN add-link IN adm-broker-hdl ( h_main-arc , 'doctype':U , THIS-PROCEDURE ).

    END. /* Page 1 */

    WHEN 2 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'arc/b-otlina.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_b-otlina ).
       RUN set-position IN h_b-otlina ( 5.50 , 1.00 ) NO-ERROR.
       RUN set-size IN h_b-otlina ( 17.92 , 98.88 ) NO-ERROR.

       /* Initialize other pages that this page requires. */
       RUN init-pages IN THIS-PROCEDURE ('1':U) NO-ERROR.

       /* Links to SmartObject h_b-otlina. */
       RUN add-link IN adm-broker-hdl ( h_folder , 'State':U , h_b-otlina ).
       RUN add-link IN adm-broker-hdl ( h_main-arc , 'detail':U , h_b-otlina ).
       RUN add-link IN adm-broker-hdl ( h_main-arc , 'State':U , h_b-otlina ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'date-price':U , h_b-otlina ).
       RUN add-link IN adm-broker-hdl ( h_b-otlina , 'doctype':U , THIS-PROCEDURE ).

    END. /* Page 2 */

    WHEN 3 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'arc/v-gdsobj.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_v-gdsobj ).
       RUN set-position IN h_v-gdsobj ( 7.88 , 9.63 ) NO-ERROR.
       /* Size in UIB:  ( 8.00 , 80.13 ) */

       /* Adjust the tab order of the smart objects. */
    END. /* Page 3 */

  END CASE.
  /* Select a Startup page. */
  IF adm-current-page eq 0
  THEN RUN select-page IN THIS-PROCEDURE ( 1 ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-date D-Dialog
PROCEDURE check-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter parcheck-shift      as logical no-undo.
  define input parameter parcheck-shift-date as logical no-undo.

  define variable varmemdate-start as date      no-undo .
  define variable varmemdate-end   as date      no-undo .
  define variable varresult        as logical   no-undo .
  define variable varmoreone       as logical   no-undo .
  define variable v-comment        as character no-undo .
  define variable v-can-print      as logical   no-undo .

  do
  on error undo, return error return-value
  :
    find tt-clients no-error.
    if ambiguous tt-clients
    then do:
      assign varmoreone = yes.
    end.
    else do:
      assign varmoreone = no.
    end.

    assign
      varmemdate-start = input frame {&frame-name} vardate-start
      varmemdate-end   = input frame {&frame-name} vardate-end
    .

    if input frame {&frame-name} vardate-start = ?
    then do:
      message
        "Не указана дата 'C'" skip
        view-as alert-box information .
      apply 'entry':u to vardate-start in frame {&frame-name} .
      return error.
    end.
    if input frame {&frame-name} vardate-end = ?
    then do:
      message
        "Не указана дата 'По'" skip
        view-as alert-box information.
      apply 'entry':u to vardate-end in frame {&frame-name} .
      return error.
    end.
    if input frame {&frame-name} vardate-start > input frame {&frame-name} vardate-end
    then do:
      message
        "Дата 'По' не может быть меньше даты 'C'" skip
        view-as alert-box information .
      apply 'entry':u to vardate-start in frame {&frame-name} .
      return error.
    end.

    if  parcheck-shift
    and parcheck-shift-date
    then do:
      if input frame {&frame-name} varshift-start < 1
      then do:
        message
          "Не указан номер смены 'C'"
          view-as alert-box information .
        apply 'entry':u to varshift-start in frame {&frame-name} .
        return error.
      end.
      if input frame {&frame-name} varshift-end < 1
      then do:
        message
          "Не указан номер смены 'По'"
          view-as alert-box information .
        apply 'entry':u to varshift-end in frame {&frame-name} .
        return error.
      end.
      if  input frame {&frame-name} vardate-start = input frame {&frame-name} vardate-end
      and input frame {&frame-name} varshift-start > input frame {&frame-name} varshift-end
      then do:
        message
          "Смена 'C' не может быть больше смены 'По'"
          view-as alert-box information.
        apply 'entry':u to varshift-start in frame {&frame-name} .
        return error.
      end.
    end.


    for each tt-clients
    :
      run rep/chk-ahz.p
        (input        tt-clients.obj-type /* p-obj-type          */
        ,input        tt-clients.obj-code /* p-obj-code          */
        ,input        false               /* p-verify-detail     */
        ,input        yes                 /* p-verify-arh        */
        ,input        no                  /* p-verify-ahsp       */
        ,input        no                  /* p-verify-aht        */
        ,input        yes                 /* p-check-act         */
        ,input        v-cntxt-db-num      /* p-check-act-db-num  */
        ,input        v-cntxt-userid      /* p-check-act-user-id */
        ,input-output varmemdate-start    /* p-date-start        */
        ,input-output varmemdate-end      /* p-date-end          */
        ,output       varresult           /* p-archive-ok        */
        ,output       v-comment           /* p-comment           */
        ,output       v-can-print         /* p-can-print         */
        ) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове программы chk-ahz.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return error .
      end.
      if not varresult
      then do:
        if varmoreone
        then do:
          message
            "Объект" tt-clients.obj-type tt-clients.obj-code skip
            "Просмотр архива невозможен" skip
            v-comment skip
            view-as alert-box information .
          apply 'entry':u to vardate-start in frame {&frame-name} .
          return error.
/*            display*/
/*              varmemdate-start @ vardate-start*/
/*              varmemdate-end   @ vardate-end*/
/*              with frame {&frame-name}.*/

        end.
        else do:
          if v-can-print = true
          then do:
            define variable v-ok as logical   no-undo .
            message
              "Внимание!" skip
              v-comment skip
              "Продолжить просмотр архивов?" skip
              view-as alert-box information buttons yes-no update v-ok .
            if v-ok <> true
            then do:
              apply 'entry':u to vardate-start in frame {&frame-name} .
              return error .
            end.
          end.
          else do:
            message
              "Объект" tt-clients.obj-type tt-clients.obj-code skip
              "Просмотр архива невозможен" skip
              v-comment skip
              view-as alert-box information .
            apply 'entry':u to vardate-start in frame {&frame-name} .
            return error .
          end.
        end.
      end.
    end.

    assign frame {&frame-name}
      varis-calend
      varis-shift-num
      vardate-start
      vardate-end
      varshift-start
      varshift-end
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog  _DEFAULT-DISABLE
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
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-goods-list D-Dialog
PROCEDURE display-goods-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    assign
      vared-goods = ""
    .
    for each tt-goods
    by tt-goods.artic
    :
      assign
        vared-goods = vared-goods
                    + (if vared-goods <> '' then ', ':u else '')
                    + tt-goods.artic
      .
      if length(vared-goods) > 10000
      then do:
        assign
          vared-goods = vared-goods + " ..."
        .
        leave .
      end.
    end.
    assign
      vared-goods = "Товары: " + vared-goods
    .
    display
      vared-goods
      with frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-object-list D-Dialog
PROCEDURE display-object-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    assign
      vared-obj   = ""
    .
    for each tt-clients
    by tt-clients.obj-type
    by tt-clients.obj-code
    :
      assign
        vared-obj = vared-obj
                  + (if vared-obj <> "" then ', ':u else '':u)
                  + tt-clients.obj-type + " " + string(tt-clients.obj-code)
      .
      if length(vared-obj) > 10000
      then do:
        assign
          vared-obj = vared-obj + " ..."
        .
        leave .
      end.
    end.

    assign
      vared-obj   = "Объекты: " + vared-obj
    .

    display
      vared-obj
      with frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog  _DEFAULT-ENABLE
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
  DISPLAY vared-goods varis-calend vardate-start vardate-end vared-obj r-rb
          fi-description-1
      WITH FRAME D-Dialog.
  ENABLE b-exit b-arh b-print b-start-date b-goods b-object b-help vared-goods
         vardate-start vardate-end vared-obj r-rb fi-description-1
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE first-date-oper D-Dialog
PROCEDURE first-date-oper :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define output parameter parfirst-date as date initial ? no-undo.

  define variable v-attr-value      as character no-undo .
  define variable v-attr-type       as character no-undo .
  define variable v-arh-detail-date as date      no-undo .
  define variable v-arh-start-date  as date      no-undo .
  define variable v-start-date      as date      no-undo .

  define buffer buf_stk-tot for ub.stk-tot .

  for each tt-clients
  :
    run clntattr-value in this-procedure
      (input  tt-clients.obj-type     /* p-obj-type */
      ,input  tt-clients.obj-code     /* p-obj-code */
      ,input  {&attr-arh-detail-date} /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-arh-detail-date = date(v-attr-value)
    .

    run clntattr-value in this-procedure
      (input  tt-clients.obj-type    /* p-obj-type */
      ,input  tt-clients.obj-code    /* p-obj-code */
      ,input  {&attr-arh-start-date} /* p-code     */
      ,output v-attr-value           /* p-value    */
      ,output v-attr-type            /* p-type     */
      ) .
    assign
      v-arh-start-date = date(v-attr-value)
    .

    assign
      v-start-date = ?
    .

    if v-arh-start-date <> ?
    then do:
      assign
        v-start-date = v-arh-start-date
      .
    end.
    else do:
      find first buf_stk-tot no-lock
        where buf_stk-tot.obj-type  = tt-clients.obj-type
          and buf_stk-tot.obj-code  = tt-clients.obj-code
        no-error .
      if available buf_stk-tot
      then do:
        assign
          v-start-date = buf_stk-tot.fact-date
        .
      end.
    end.

    if v-start-date <> ?
    and (parfirst-date = ?
         or v-start-date < parfirst-date
        )
    then do:
      assign
        parfirst-date = v-start-date
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE need-read-arh D-Dialog
PROCEDURE need-read-arh :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    assign
      fi-description-1 = "Нажмите кнопку Просмотр"
    .

    display
      fi-description-1
      with frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pre-display D-Dialog
PROCEDURE pre-display :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run display-goods-list in this-procedure .

  run display-object-list in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-arh D-Dialog
PROCEDURE read-arh :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if input frame {&frame-name} varis-calend = 2
  then do:
    if  input frame {&frame-name} varis-shift-num  <> ""
    and input frame {&frame-name} varis-shift-num  <> "no"
    then do:
      run check-date in this-procedure
        (input  yes
        ,input  yes
        ) no-error.
      if error-status :error
      then do:
        return error.
      end.
    end.
    else do:
      run check-date in this-procedure
        (input  yes
        ,input  no
        ) no-error.
      if error-status :error
      then do:
        return error.
      end.
    end.
  end.
  else do:
    run check-date in this-procedure
      (input  no
      ,input  no
      ) no-error.
    if error-status :error
    then do:
      return error.
    end.
  end.

  assign
    frame {&frame-name} r-rb
    .
  if varext-doc-type = ""
  or varext-doc-type = ?
  then do:
    assign
      varext-doc-type = "all"
    .
  end.
  run set-attribute-list ('main-handle=' + string(this-procedure)).
  run set-attribute-list ('varis-calend=' + string(varis-calend)).
  run set-attribute-list ('varis-shift-num=' + string(varis-shift-num)).
  run set-attribute-list ('vardate-start=' + string(vardate-start)).
  run set-attribute-list ('vardate-end=' + string(vardate-end)).
  run set-attribute-list ('varshift-start=' + string(varshift-start)).
  run set-attribute-list ('varshift-end=' + string(varshift-end)).
  run set-attribute-list ('varext-doc-type=' + string(varext-doc-type)).
  run set-attribute-list ('rubl-base=' + string(r-rb)).
  run notify ('show_arh,date-price-target':u).

  assign
    fi-description-1 = substitute("&1 &2 С &3 &4 По &5 &6"
                                 ,(if r-rb = 1 then "{&abbr_rub_firstshift}" else "Вал")
                                 ,(if varis-shift-num then "по сменам" else "" )
                                 ,string(vardate-start, '99/99/9999':u)
                                 ,(if varis-shift-num then string(varshift-start) else "" )
                                 ,string(vardate-end, '99/99/9999':u)
                                 ,(if varis-shift-num then string(varshift-end) else "" )
                                 )
  .

  display
    fi-description-1
    with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read_doc-type D-Dialog
PROCEDURE read_doc-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
&scop is-error-get  if return-value = "" or return-value = ? then do: ~
                       message "Нет атрибута для получения данных." view-as alert-box error.~
                       return error.~
                    end.
  RUN get-attribute IN h_main-arc (INPUT 'varext-doc-type':U).
  {&is-error-get}
  assign varext-doc-type = return-value.
  run read-arh in this-procedure .
  RUN select-page (INPUT 2).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read_doc-type-all D-Dialog
PROCEDURE read_doc-type-all :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    varext-doc-type = "all"
  .
  run read-arh in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-goods-list D-Dialog
PROCEDURE select-goods-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_tt-goods for tt-goods .

  do
  on error undo, return error return-value
  :
    for each gds-list
    :
      delete gds-list .
    end.

    for each buf_tt-goods
    :
      find first ub.goods no-lock
        where ub.goods.artic     = buf_tt-goods.artic
          and ub.goods.prod-type = buf_tt-goods.prod-type
          and ub.goods.prod-code = buf_tt-goods.prod-code
        .

      { cmp/gds-list.i gds-list assign }
    end.

    run str/gds-list.w (
                     input parparentproc
                    ,input v-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code)  .

    find first gds-list
      no-error .
    if available gds-list
    then do:
      for each buf_tt-goods
      :
        delete buf_tt-goods .
      end.

      for each gds-list
      :
        find first goods no-lock
          where goods.artic     = gds-list.artic
            and goods.prod-type = gds-list.prod-type
            and goods.prod-code = gds-list.prod-code
          .
        create buf_tt-goods .
        buffer-copy goods to buf_tt-goods .
      end.

      run display-goods-list in this-procedure .
    end.
    else do:
      message
        "Товар не выбран" skip
        view-as alert-box information .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-object-list D-Dialog
PROCEDURE select-object-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    { gbl/uobjclr.i }

    for each tt-clients
    :
      { gbl/uobjapnd.i
        tt-clients.obj-type
        tt-clients.obj-code
      }
    end.

    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select = true
    then do:
      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

      for each tt-clients
      :
        delete tt-clients .
      end.

      for each buf_userobjs_temp-user-obj
      on error undo, return error return-value
      :
        create tt-clients .
        assign
          tt-clients.obj-type = buf_userobjs_temp-user-obj.obj-type
          tt-clients.obj-code = buf_userobjs_temp-user-obj.obj-code
        .
      end.

      run display-object-list in this-procedure .
      run need-read-arh in this-procedure .
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartDialog, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-chg-is-shift-num D-Dialog
PROCEDURE val-chg-is-shift-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign frame {&frame-name} varis-shift-num.
  if varis-shift-num
  then do:
    view varshift-start varshift-end in frame {&frame-name}.
    display varshift-start varshift-end with frame {&frame-name}.
    enable varshift-start varshift-end with frame {&frame-name}.
  end.
  else do:
    hide varshift-start varshift-end in frame {&frame-name}.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME