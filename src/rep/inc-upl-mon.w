&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
def input param parParentProc as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Мониторинг СПН".

def var v-sort-desc as logical no-undo.
def var v-sort-column as char no-undo.

{ cmp/vssrevis.i }
{ cmp/showinf.i }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ gbl/userobjs.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

def temp-table tt-obj no-undo
    field db-num as int format ">>,>>9" COLUMN-LABEL "БД"
    field obj-type as char format "x(3)" COLUMN-LABEL "Тип"
    field obj-code as int format ">>,>>9" COLUMN-LABEL "Код"
    field obj-name as char format "x(30)" COLUMN-LABEL "Название"
    field last-upload-date as char COLUMN-LABEL "Последняя!выгруженная!дата"
    field last-upload-shift as char COLUMN-LABEL "Последняя!выгруженная!смена"
    field date-delta as int format ">>,>>9" COLUMN-LABEL "Дельта!по дате"
    field obj-date as date format "99/99/9999" COLUMN-LABEL "Текущая!дата"
    field obj-shift as char format "x(20)" COLUMN-LABEL "Текущая!смена"
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-obj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-obj

/* Definitions for BROWSE br-obj                                        */
&Scoped-define FIELDS-IN-QUERY-br-obj tt-obj.db-num tt-obj.obj-type tt-obj.obj-code tt-obj.obj-name tt-obj.last-upload-date tt-obj.last-upload-shift tt-obj.date-delta tt-obj.obj-date tt-obj.obj-shift   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-obj   
&Scoped-define SELF-NAME br-obj
&Scoped-define QUERY-STRING-br-obj FOR EACH tt-obj
&Scoped-define OPEN-QUERY-br-obj OPEN QUERY {&SELF-NAME} FOR EACH tt-obj.
&Scoped-define TABLES-IN-QUERY-br-obj tt-obj
&Scoped-define FIRST-TABLE-IN-QUERY-br-obj tt-obj


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-obj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b_OK RECT-1 RECT-2 b-print b-refresh ~
sel-obj-type allow-days br-obj 
&Scoped-Define DISPLAYED-OBJECTS sel-obj-type allow-days 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-print 
     LABEL "Печать" 
     SIZE 7 BY 1.

DEFINE BUTTON b-refresh 
     LABEL "Обновить" 
     SIZE 9 BY 1.

DEFINE BUTTON b-sel-objs 
     LABEL "Выбор" 
     SIZE 7 BY 1.

DEFINE BUTTON b_OK AUTO-GO 
     LABEL "Выход" 
     SIZE 7 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE allow-days AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 1 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE sel-obj-type AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "№ объектов", 1,
"Все", 2
     SIZE 16 BY 2 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 24 BY 2.14.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 40 BY 2.14.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-obj FOR 
      tt-obj SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-obj Dialog-Frame _FREEFORM
  QUERY br-obj DISPLAY
      tt-obj.db-num
      tt-obj.obj-type
      tt-obj.obj-code
      tt-obj.obj-name
      tt-obj.last-upload-date
      tt-obj.last-upload-shift
      tt-obj.date-delta
      tt-obj.obj-date
      tt-obj.obj-shift
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 104 BY 15.71 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b_OK AT ROW 1 COL 1
     b-print AT ROW 1 COL 9 WIDGET-ID 2
     b-refresh AT ROW 1 COL 16 WIDGET-ID 4
     sel-obj-type AT ROW 2.24 COL 2 NO-LABEL WIDGET-ID 10
     b-sel-objs AT ROW 2.38 COL 17 WIDGET-ID 8
     allow-days AT ROW 2.67 COL 53.4 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     br-obj AT ROW 4.33 COL 1 WIDGET-ID 100
     "Допустимое кол-во дней" VIEW-AS TEXT
          SIZE 27 BY 1 AT ROW 2.24 COL 25.4 WIDGET-ID 22
     "от последней даты выгрузки" VIEW-AS TEXT
          SIZE 30 BY 1 AT ROW 3.14 COL 25.4 WIDGET-ID 24
     RECT-1 AT ROW 2.19 COL 1 WIDGET-ID 14
     RECT-2 AT ROW 2.19 COL 25 WIDGET-ID 16
     SPACE(39.99) SKIP(15.80)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Мониторниг инкрементальной выгрузки"
         DEFAULT-BUTTON b_OK.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box Template
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-obj allow-days Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-sel-objs IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       br-obj:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3
       br-obj:ALLOW-COLUMN-SEARCHING IN FRAME Dialog-Frame = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-obj
/* Query rebuild information for BROWSE br-obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-obj.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-obj */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Мониторниг инкрементальной выгрузки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  message "Печать пока не предусмотрена!" view-as alert-box. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-refresh Dialog-Frame
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame /* Обновить */
DO:
  assign frame {&FRAME-NAME} sel-obj-type allow-days.
  run prepare-rows.
  run update-br("obj-code", false).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-objs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-objs Dialog-Frame
ON CHOOSE OF b-sel-objs IN FRAME Dialog-Frame /* Выбор */
DO:
def var v-sel as logical no-undo.
run userobjs_select-many(
    parParentProc,
    g#db-num,
    g#userid,
    v-cntxt-host-code-obj,
    v-cntxt-obj-type,
    v-cntxt-obj-code,
    output v-sel
).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-obj
&Scoped-define SELF-NAME br-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-obj Dialog-Frame
ON ROW-DISPLAY OF br-obj IN FRAME Dialog-Frame
DO:
  if tt-obj.date-delta > allow-days then do:
      tt-obj.date-delta:FGCOLOR in browse br-obj = 12.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-obj Dialog-Frame
ON START-SEARCH OF br-obj IN FRAME Dialog-Frame
DO:
  def var curr-col as char no-undo.

  curr-col = browse br-obj:CURRENT-COLUMN:NAME.
  v-sort-column = curr-col.
  if curr-col = v-sort-column then do:
    v-sort-desc = not v-sort-desc.
  end.
  run update-br(curr-col, v-sort-desc).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sel-obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sel-obj-type Dialog-Frame
ON VALUE-CHANGED OF sel-obj-type IN FRAME Dialog-Frame
DO:
  assign frame {&FRAME-NAME} sel-obj-type.
  if sel-obj-type = 1 then do:
      enable b-sel-objs with frame {&FRAME-NAME}.
  end.
  else do:
      disable b-sel-objs with frame {&FRAME-NAME}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    
  { gbl/diasize.i
    &browse-name="br-obj"
  }

  run diasize_init in this-procedure.

  RUN enable_UI.  
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY sel-obj-type allow-days 
      WITH FRAME Dialog-Frame.
  ENABLE b_OK RECT-1 RECT-2 b-print b-refresh sel-obj-type allow-days br-obj 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prepare-row Dialog-Frame 
PROCEDURE prepare-row :
def param buffer bf_clients for ub.clients.

def var v-bge-incr-last-shift-date as char no-undo.
def var v-bge-incr-last-shift-num as char no-undo.
def var v-type as char no-undo.
def var v-obj-date as date no-undo.
def var v-obj-shift as logical no-undo.
def var v-shift-date as date no-undo.
def var v-shift-num as int no-undo.
def var v-shift-name as char no-undo.

if (bf_clients.obj-type = {&shop} or bf_clients.obj-type = {&stock})
    and bf_clients.stts = 0 /* не удалена */ then do:
    
    /* включены ли смены на объекте? */
    { gbl/objat.i
      bf_clients.obj-type
      bf_clients.obj-code
      "'shift-on=request'"
      v-obj-shift
      no-error
    }
    if error-status:error or not v-obj-shift then return.

    /* Дата последней выгруженной смены */
    run clntattr-value(
        bf_clients.obj-type,
        bf_clients.obj-code,
        {&attr-bge-incr-last-shift-date},
        output v-bge-incr-last-shift-date,
        output v-type
    ).
    
    /* Номер последней выгруженной смены */
    run clntattr-value(
        bf_clients.obj-type,
        bf_clients.obj-code,
        {&attr-bge-incr-last-shift-num},
        output v-bge-incr-last-shift-num,
        output v-type
    ).
    
    /* если хотя бы одного атрибута нет, то пропускаем */
    if v-bge-incr-last-shift-date = "" or v-bge-incr-last-shift-num = "" then return.
    
    /* текущая дата на объекте */
    { gbl/curobjdt.i
      bf_clients.obj-type
      bf_clients.obj-code
      v-obj-date
      no-error
    }
    if error-status:error then return.
    
    /* текущая смена на объекте */
    { gbl/curshift.i
      bf_clients.obj-type
      bf_clients.obj-code
      v-shift-date
      v-shift-num
      v-shift-name
      no-error
    }
    if error-status:error then return.
    
    create tt-obj.
    assign
        tt-obj.db-num = bf_clients.db-num
        tt-obj.obj-code = bf_clients.obj-code
        tt-obj.obj-type = bf_clients.obj-type
        tt-obj.obj-name = bf_clients.obj-name
        tt-obj.last-upload-date = v-bge-incr-last-shift-date
        tt-obj.last-upload-shift = v-bge-incr-last-shift-num
        tt-obj.obj-date = v-obj-date
        tt-obj.obj-shift = substitute("&1 &2", v-shift-date, v-shift-num)
        tt-obj.date-delta = interval(v-obj-date, date(v-bge-incr-last-shift-date), "days").
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prepare-rows Dialog-Frame 
PROCEDURE prepare-rows :
def buffer bf_clients for ub.clients.

run waitfram-show("Обновление...").

EMPTY TEMP-TABLE tt-obj.

if sel-obj-type = 2 then do: /* все */
    for each bf_clients
        where (bf_clients.obj-type = {&shop} or bf_clients.obj-type = {&stock})
        and bf_clients.stts = 0
        no-lock:
    
        run prepare-row(buffer bf_clients).
    end.
end.
else do: /* выбранные */
    for each userobjs_temp-user-obj no-lock:        
        find first bf_clients
            where bf_clients.obj-type = userobjs_temp-user-obj.obj-type
            and bf_clients.obj-code = userobjs_temp-user-obj.obj-code
            no-lock.
        run prepare-row(buffer bf_clients).
    end.
end.

run waitfram-hide.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-br Dialog-Frame 
PROCEDURE update-br :
def input param p-sort-field as char no-undo.
def input param p-sort-desc as logical no-undo.

def var str as char no-undo init "for each tt-obj no-lock by ".

str = str + p-sort-field.
if p-sort-desc then
    str = str + " DESC".

query br-obj:QUERY-CLOSE ().
query br-obj:QUERY-PREPARE(str).
query br-obj:QUERY-OPEN().

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

