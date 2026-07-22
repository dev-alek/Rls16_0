&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define temp-table tt-shift no-undo
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field shift-name like ub.shift-obj.shift-name
.  

define temp-table tt-shift-1 no-undo
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field shift-name like ub.shift-obj.shift-name
.  

define temp-table tt-shift-2 no-undo
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field shift-name like ub.shift-obj.shift-name
. 

define temp-table tt-pl-gds no-undo
  field pl-code like ub.place.pl-code
  field loc1 like ub.place.loc1
  field gds-code like ub.goods.gds-code
  field gds-name like ub.goods.gds-name
.

define temp-table tt-place no-undo
  field pl-code like ub.place.pl-code
.

/* Parameters Definitions ---                                           */
define input parameter parparentproc as handle no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shift-periods.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-shift-periods.p $":U .
define variable vss-description as character no-undo init "Отчет Контроль плотности НП".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }
{ ref/gds-attr.i }
{ str/placelib.i }

define variable num-rvs as integer no-undo init 0 .
define variable choosed-shift-recid as recid no-undo init ? .
define variable shift-recid-list as character no-undo .
define variable gds-recid-list as character no-undo .
define variable pl-recid-list as character no-undo .
define variable gds-recid-list-full as character no-undo .
define variable pl-recid-list-full as character no-undo .

define buffer buf_shift-obj for ub.shift-obj .
define buffer prev_shift-obj for ub.shift-obj .
define buffer buf_place for ub.place .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_goods for ub.goods .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-pl-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES <record-phrase>

/* Definitions for BROWSE br-pl-gds                                     */
&Scoped-define FIELDS-IN-QUERY-br-pl-gds tt-pl-gds.loc1 tt-pl-gds.gds-name   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pl-gds   
&Scoped-define SELF-NAME br-pl-gds
&Scoped-define QUERY-STRING-br-pl-gds FOR EACH tt-pl-gds
&Scoped-define OPEN-QUERY-br-pl-gds OPEN QUERY {&SELF-NAME} FOR EACH tt-pl-gds by tt-pl-gds.loc1 .
&Scoped-define TABLES-IN-QUERY-br-pl-gds tt-pl-gds
&Scoped-define FIRST-TABLE-IN-QUERY-br-pl-gds tt-pl-gds


/* Definitions for BROWSE br-shift                                      */
&Scoped-define FIELDS-IN-QUERY-br-shift tt-shift.shift-date tt-shift.shift-num   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-shift   
&Scoped-define SELF-NAME br-shift
&Scoped-define QUERY-STRING-br-shift FOR EACH tt-shift
&Scoped-define OPEN-QUERY-br-shift OPEN QUERY {&SELF-NAME} FOR EACH tt-shift by tt-shift.shift-date desc by tt-shift.shift-num desc .
&Scoped-define TABLES-IN-QUERY-br-shift tt-shift
&Scoped-define FIRST-TABLE-IN-QUERY-br-shift tt-shift


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-pl-gds}~
    ~{&OPEN-QUERY-br-shift}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-3 RECT-4 Btn_OK ~
Btn_Cancel br-shift rs-shift b-shift-1 b-shift-2 rs-obj br-pl-gds rs-goods ~
b-goods rs-place b-place 
&Scoped-Define DISPLAYED-OBJECTS rs-shift rs-obj rs-goods rs-place 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD shift-name Dialog-Frame
function shift-name returns character 
  ( input p-shift-num like ub.shift-obj.shift-num, input p-shift-name  like ub.shift-obj.shift-name) forward.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME





/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-goods 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-goods" 
     SIZE 3 BY .86.

DEFINE BUTTON b-place 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-place" 
     SIZE 3 BY .86.

DEFINE BUTTON b-shift-1 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-shift-1" 
     SIZE 3 BY .86.

DEFINE BUTTON b-shift-2 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-shift-2" 
     SIZE 3 BY .86.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK
     LABEL "Выполнить" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE rs-goods AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 15 BY 2.14 NO-UNDO.

DEFINE VARIABLE rs-obj AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Текущий", 1
     SIZE 15 BY .95 NO-UNDO.

DEFINE VARIABLE rs-place AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 15 BY 2.14 NO-UNDO.

DEFINE VARIABLE rs-shift AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "По сменам", 1,
"Выборочно", 2
     SIZE 15 BY 2.14 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 3.33.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 1.71.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 3.33.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 3.33.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-pl-gds FOR 
      tt-pl-gds SCROLLING.

DEFINE QUERY br-shift FOR 
      tt-shift SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-pl-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pl-gds Dialog-Frame _FREEFORM
  QUERY br-pl-gds DISPLAY
      tt-pl-gds.loc1 format "X(2)" column-label "Резервуар"
    tt-pl-gds.gds-name format "X(30)" column-label "НП"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 26.4 BY 7.38 ROW-HEIGHT-CHARS .57 FIT-LAST-COLUMN.

DEFINE BROWSE br-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-shift Dialog-Frame _FREEFORM
  QUERY br-shift DISPLAY
      tt-shift.shift-date format "99.99.9999" column-label "Дата"
      shift-name (tt-shift.shift-num, tt-shift.shift-name) format "X(6)" column-label "Номер"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 26.4 BY 5.19 ROW-HEIGHT-CHARS .57 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.24 COL 2
     Btn_Cancel AT ROW 1.24 COL 17
     br-shift AT ROW 2.95 COL 33 WIDGET-ID 300
     rs-shift AT ROW 3.62 COL 5.8 NO-LABEL WIDGET-ID 4
     b-shift-1 AT ROW 3.67 COL 21.6 WIDGET-ID 32
     b-shift-2 AT ROW 4.71 COL 21.6 WIDGET-ID 34
     rs-obj AT ROW 7.43 COL 5.6 NO-LABEL WIDGET-ID 12
     br-pl-gds AT ROW 9.1 COL 33 WIDGET-ID 200
     rs-goods AT ROW 9.86 COL 5.4 NO-LABEL WIDGET-ID 20
     b-goods AT ROW 11 COL 21.2 WIDGET-ID 36
     rs-place AT ROW 13.86 COL 5.4 NO-LABEL WIDGET-ID 26
     b-place AT ROW 15.05 COL 21.2 WIDGET-ID 38
     " Выбор периода" VIEW-AS TEXT
          SIZE 16.4 BY .62 AT ROW 2.57 COL 8.6 WIDGET-ID 2
          FGCOLOR 12 
     " Выбор резервуаров НП" VIEW-AS TEXT
          SIZE 22.6 BY .62 AT ROW 12.86 COL 5 WIDGET-ID 30
          FGCOLOR 12 
     " Выбор объекта" VIEW-AS TEXT
          SIZE 16.4 BY .62 AT ROW 6.52 COL 7.6 WIDGET-ID 10
          FGCOLOR 12 
     " Выбор топливных товаров" VIEW-AS TEXT
          SIZE 25 BY .62 AT ROW 8.86 COL 4.4 WIDGET-ID 18
          FGCOLOR 12 
     RECT-1 AT ROW 2.91 COL 3 WIDGET-ID 8
     RECT-2 AT ROW 6.91 COL 3 WIDGET-ID 14
     RECT-3 AT ROW 9.19 COL 3 WIDGET-ID 16
     RECT-4 AT ROW 13.19 COL 3 WIDGET-ID 24
     SPACE(30.39) SKIP(0.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Отчет Контроль плотности НП"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-shift Btn_Cancel Dialog-Frame */
/* BROWSE-TAB br-pl-gds rs-obj Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pl-gds
/* Query rebuild information for BROWSE br-pl-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH <record-phrase>.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-pl-gds */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-shift
/* Query rebuild information for BROWSE br-shift
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH <record-phrase>.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-shift */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Отчет Контроль плотности НП */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON CHOOSE OF b-goods IN FRAME Dialog-Frame /* b-goods */
DO:
  assign rs-goods = 2 .
  display rs-goods with frame {&frame-name} .
  run select-gds .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-place Dialog-Frame
ON CHOOSE OF b-place IN FRAME Dialog-Frame /* b-place */
DO:
  define variable ii as integer no-undo .
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .
  define variable tmp-pl-list as character no-undo .
  
  assign rs-place = 2 .
  display rs-place with frame {&frame-name} .
  
  assign tmp-pl-list = pl-recid-list-full .
  empty temp-table tt-place .
  run ref/pl-list.w (
     input parparentproc
    ,input "b-sel,b-mark"
    ,input p-obj-type
    ,input p-obj-code
    ,input {&g___object} + {&delim-par} + "np-list"
    ,input-output tmp-pl-list).
  if tmp-pl-list = "cancel"
  then do :
    return no-apply .
  end .
  assign
    pl-recid-list = tmp-pl-list
    pl-recid-list-full = pl-recid-list
  .
  
  do ii = 1 to num-entries(pl-recid-list) :
    find first buf_place no-lock where recid(buf_place) = integer(entry(ii, pl-recid-list)) no-error .
    if available buf_place
    then do :
      create tt-place .
      assign tt-place.pl-code = buf_place.pl-code .
    end .
  end .
  empty temp-table tt-pl-gds .
  do ii = 1 to num-entries(gds-recid-list) :
    find first buf_goods no-lock where recid(buf_goods) = integer(entry(ii, gds-recid-list)) no-error .
    if available buf_goods
    then do :
      for each buf_pl-gds no-lock where buf_pl-gds.gds-code = buf_goods.gds-code
                                    and buf_pl-gds.obj-type = p-obj-type
                                    and buf_pl-gds.obj-code = p-obj-code,
        first buf_place where buf_place.pl-code = buf_pl-gds.pl-code
      :
        &scop proc-name gds-attr-value
        {&run_proc_attr-lib}
          (input  buf_pl-gds.gds-code
          ,input  {&attr-fuel-type}
          ,output v-value
          ,output v-type) no-error.
        if v-value = "lgas"
        or v-value = "metan"
        or v-value = "propan"
        then next .
        
        run placelib_get-attr  ( input {&place-com-tanks}
                                ,input buf_place.obj-code
                                ,input buf_place.obj-type
                                ,input buf_place.pl-code
                                ,output v-value
                                ,output v-ok      ) no-error.
        if v-ok
        and v-value > ""
        then do :
          run placelib_get-attr  ( input {&place-is-main}
                                  ,input buf_place.obj-code
                                  ,input buf_place.obj-type
                                  ,input buf_place.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          and logical(v-value)
          then do :
          end .
          else do :
            next .
          end .
        end .
        create tt-pl-gds .
        assign
          tt-pl-gds.pl-code  = buf_place.pl-code
          tt-pl-gds.loc1     = buf_place.loc1
          tt-pl-gds.gds-code = buf_goods.gds-code
          tt-pl-gds.gds-name = buf_goods.gds-name
        .
      end .
    end .
  end .
  for each tt-pl-gds :
    find first tt-place where tt-place.pl-code = tt-pl-gds.pl-code no-error .
    if not available tt-place
    then delete tt-pl-gds .
  end .
  run find-old-pl-gds .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-shift-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-shift-1 Dialog-Frame
ON CHOOSE OF b-shift-1 IN FRAME Dialog-Frame /* b-shift-1 */
DO:
  assign rs-shift = 1 .
  display rs-shift with frame {&frame-name} .
  
  run str/sht-all.w
                  ( input parparentproc
                   ,input p-obj-type /*p-curr-obj-type*/
                   ,input p-obj-code /*p-curr-obj-code*/
                   ,input "b-sel"
                   ,input "obj":U
                   ,input p-obj-type   /*p-obj-type*/
                   ,input p-obj-code   /*p-obj-code*/
                   ,input ""
                   ,input-output shift-recid-list ).
  if error-status:error 
  then do :
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при выборе смены"  skip
      error-status :get-message( 1 ) skip
      return-value skip
      view-as alert-box error
    .
    return no-apply.
  end.
  if shift-recid-list =  "":U
  then do :
    return no-apply .
  end.
  empty temp-table tt-shift-1 .
  assign choosed-shift-recid = integer (shift-recid-list) .
  find first buf_shift-obj where recid (buf_shift-obj) = choosed-shift-recid no-lock.
  if buf_shift-obj.status_ <> {&sht-closed}
  then do :
    message "Выберите закрытую смену!" view-as alert-box .
    return no-apply .
  end .
  
  create tt-shift-1 .
  assign
    tt-shift-1.shift-date = buf_shift-obj.shift-date
    tt-shift-1.shift-num  = buf_shift-obj.shift-num
    tt-shift-1.shift-name = buf_shift-obj.shift-name
    num-rvs = 1
  .
  
  for each prev_shift-obj no-lock where prev_shift-obj.obj-type = p-obj-type
                                    and prev_shift-obj.obj-code = p-obj-code
                                    and prev_shift-obj.status_  = {&sht-closed}
                                    and ( prev_shift-obj.shift-date < buf_shift-obj.shift-date
                                      or prev_shift-obj.shift-date = buf_shift-obj.shift-date
                                        and prev_shift-obj.shift-num  < buf_shift-obj.shift-num
                                    )
                                    by prev_shift-obj.fact-order desc
  :
    create tt-shift-1 .
    assign
      tt-shift-1.shift-date = prev_shift-obj.shift-date
      tt-shift-1.shift-num  = prev_shift-obj.shift-num
      tt-shift-1.shift-name = prev_shift-obj.shift-name
      num-rvs = num-rvs + 1
    .
    if num-rvs = 7
    then leave .
  end .
  empty temp-table tt-shift .
  for each tt-shift-1 : 
    create tt-shift .
    buffer-copy tt-shift-1 to tt-shift .
  end .
  run find-old-pl-gds .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-shift-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-shift-2 Dialog-Frame
ON CHOOSE OF b-shift-2 IN FRAME Dialog-Frame /* b-shift-2 */
DO:
  define variable ii as integer no-undo .
  
  assign rs-shift = 2 .
  display rs-shift with frame {&frame-name} .
  
  run str/sht-all.w
                  ( input parparentproc
                   ,input p-obj-type /*p-curr-obj-type*/
                   ,input p-obj-code /*p-curr-obj-code*/
                   ,input "b-sel,b-mark"
                   ,input "obj":U
                   ,input p-obj-type   /*p-obj-type*/
                   ,input p-obj-code   /*p-obj-code*/
                   ,input ""
                   ,input-output shift-recid-list ).
  if error-status:error 
  then do :
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при выборе смены"  skip
      error-status :get-message( 1 ) skip
      return-value skip
      view-as alert-box error
    .
    return no-apply.
  end.
  if shift-recid-list =  "":U
  then do :
    return no-apply .
  end.
  
  empty temp-table tt-shift-2 .
  do ii = 1 to num-entries(shift-recid-list) :
    find first buf_shift-obj no-lock where recid(buf_shift-obj) = integer(entry(ii, shift-recid-list)) no-error .
    if available buf_shift-obj
    and buf_shift-obj.status_ = {&sht-closed}
    then do :
      create tt-shift-2 .
      assign
        tt-shift-2.shift-date = buf_shift-obj.shift-date
        tt-shift-2.shift-num  = buf_shift-obj.shift-num
        tt-shift-2.shift-name = buf_shift-obj.shift-name
      .
    end .
    if available buf_shift-obj
    and not buf_shift-obj.status_ = {&sht-closed}
    then do :
      message "Выберите закрытую смену!" view-as alert-box .
    end .
  end .
  empty temp-table tt-shift .
  for each tt-shift-2 : 
    create tt-shift .
    buffer-copy tt-shift-2 to tt-shift .
  end .
  run find-old-pl-gds .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выполнить */
DO:
  empty temp-table tt-shift .
  case rs-shift :
    when 1
    then do :
      find first tt-shift-1 no-error .
      if not available tt-shift-1
      then do :
        message "Не выбрана ни одна смена!" view-as alert-box .
        return no-apply .
      end .
      for each tt-shift-1 : 
        create tt-shift .
        buffer-copy tt-shift-1 to tt-shift .
      end .
    end .
    when 2
    then do :
      find first tt-shift-2 no-error .
      if not available tt-shift-2
      then do :
        message "Не выбрана ни одна смена!" view-as alert-box .
        return no-apply .
      end .
      for each tt-shift-2 : 
        create tt-shift .
        buffer-copy tt-shift-2 to tt-shift .
      end .
    end .
  end case .
  find first tt-pl-gds no-error .
  if not available tt-pl-gds
  then do :
    message "Список товаров/резервуаров пуст!" view-as alert-box .
    return no-apply .
  end .
  run rep/r-shift-periods.p (input parparentproc,
                             input table tt-shift,
                             input table tt-pl-gds)
                             .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-goods Dialog-Frame
ON VALUE-CHANGED OF rs-goods IN FRAME Dialog-Frame
DO:
  define variable ii as integer no-undo .
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .
  
  assign rs-goods .
  
  assign rs-place = 1 .
  display rs-place with frame {&frame-name} .
  
  if rs-goods = 1
  then do :
    run init-pl-gds .
  end .
  
  if rs-goods = 2
  then do :
    empty temp-table tt-pl-gds .
    do ii = 1 to num-entries(gds-recid-list):
      find first buf_goods where recid(buf_goods) = integer(entry(ii, gds-recid-list)) no-lock no-error.
      if available buf_goods
      then do:
        for each buf_pl-gds no-lock where buf_pl-gds.gds-code = buf_goods.gds-code
                                      and buf_pl-gds.obj-type = p-obj-type
                                      and buf_pl-gds.obj-code = p-obj-code,
          first buf_place where buf_place.pl-code = buf_pl-gds.pl-code
        :
          &scop proc-name gds-attr-value
          {&run_proc_attr-lib}
            (input  buf_pl-gds.gds-code
            ,input  {&attr-fuel-type}
            ,output v-value
            ,output v-type) no-error.
          if v-value = "lgas"
          or v-value = "metan"
          or v-value = "propan"
          then next .
          
          run placelib_get-attr  ( input {&place-com-tanks}
                                  ,input buf_place.obj-code
                                  ,input buf_place.obj-type
                                  ,input buf_place.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          then do :
            run placelib_get-attr  ( input {&place-is-main}
                                    ,input buf_place.obj-code
                                    ,input buf_place.obj-type
                                    ,input buf_place.pl-code
                                    ,output v-value
                                    ,output v-ok      ) no-error.
            if v-ok
            and v-value > ""
            and logical(v-value)
            then do :
            end .
            else do :
              next .
            end .
          end .
    
          create tt-pl-gds .
          assign
            tt-pl-gds.pl-code  = buf_place.pl-code
            tt-pl-gds.loc1     = buf_place.loc1
            tt-pl-gds.gds-code = buf_goods.gds-code
            tt-pl-gds.gds-name = buf_goods.gds-name
          .
        end .
      end.
    end.
    run find-old-pl-gds .
  end .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-place Dialog-Frame
ON VALUE-CHANGED OF rs-place IN FRAME Dialog-Frame
DO:
  define variable ii as integer no-undo .
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .
  
  assign rs-place .
  
  if rs-place = 1
  then do :
    empty temp-table tt-pl-gds .
    do ii = 1 to num-entries(gds-recid-list) :
      find first buf_goods no-lock where recid(buf_goods) = integer(entry(ii, gds-recid-list)) no-error .
      if available buf_goods
      then do :
        for each buf_pl-gds no-lock where buf_pl-gds.gds-code = buf_goods.gds-code
                                      and buf_pl-gds.obj-type = p-obj-type
                                      and buf_pl-gds.obj-code = p-obj-code,
          first buf_place where buf_place.pl-code = buf_pl-gds.pl-code
        :
          &scop proc-name gds-attr-value
          {&run_proc_attr-lib}
            (input  buf_pl-gds.gds-code
            ,input  {&attr-fuel-type}
            ,output v-value
            ,output v-type) no-error.
          if v-value = "lgas"
          or v-value = "metan"
          or v-value = "propan"
          then next .
          
          run placelib_get-attr  ( input {&place-com-tanks}
                                  ,input buf_place.obj-code
                                  ,input buf_place.obj-type
                                  ,input buf_place.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          then do :
            run placelib_get-attr  ( input {&place-is-main}
                                    ,input buf_place.obj-code
                                    ,input buf_place.obj-type
                                    ,input buf_place.pl-code
                                    ,output v-value
                                    ,output v-ok      ) no-error.
            if v-ok
            and v-value > ""
            and logical(v-value)
            then do :
            end .
            else do :
              next .
            end .
          end .
          create tt-pl-gds .
          assign
            tt-pl-gds.pl-code  = buf_place.pl-code
            tt-pl-gds.loc1     = buf_place.loc1
            tt-pl-gds.gds-code = buf_goods.gds-code
            tt-pl-gds.gds-name = buf_goods.gds-name
          .
        end .
      end .
    end .
    assign
      pl-recid-list-full = pl-recid-list
      pl-recid-list = ""
    .
    for each tt-pl-gds no-lock break by tt-pl-gds.pl-code :
      if first-of(tt-pl-gds.pl-code)
      then do :
        for first place where place.pl-code = tt-pl-gds.pl-code :
          assign pl-recid-list = pl-recid-list + string(recid(place)) + "," .
        end .
      end .
    end .
    assign pl-recid-list = trim(pl-recid-list, ",") .
  end .
  
  if rs-place = 2
  then do :
    empty temp-table tt-place .
    do ii = 1 to num-entries(pl-recid-list) :
      find first buf_place no-lock where recid(buf_place) = integer(entry(ii, pl-recid-list)) no-error .
      if available buf_place
      then do :
        create tt-place .
        assign tt-place.pl-code = buf_place.pl-code .
      end .
    end .
    for each tt-pl-gds :
      find first tt-place where tt-place.pl-code = tt-pl-gds.pl-code no-error .
      if not available tt-place
      then delete tt-pl-gds .
    end .
  end .
  
  run find-old-pl-gds .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-shift Dialog-Frame
ON VALUE-CHANGED OF rs-shift IN FRAME Dialog-Frame
DO:
  assign rs-shift .
  
  if rs-shift = 1
  then do :
    empty temp-table tt-shift .
    for each tt-shift-1 : 
      create tt-shift .
      buffer-copy tt-shift-1 to tt-shift .
    end .
  end .
  
  if rs-shift = 2
  then do :
    empty temp-table tt-shift .
    for each tt-shift-2 : 
      create tt-shift .
      buffer-copy tt-shift-2 to tt-shift .
    end .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-pl-gds
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
  run init_ .
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
  DISPLAY rs-shift rs-obj rs-goods rs-place 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 RECT-3 RECT-4 Btn_OK Btn_Cancel br-shift rs-shift 
         b-shift-1 b-shift-2 rs-obj br-pl-gds rs-goods b-goods rs-place b-place 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-old-pl-gds Dialog-Frame 
PROCEDURE find-old-pl-gds :
  define variable ii as integer no-undo .
  
  define buffer buf_shift-period for ub.shift-period .
  define buffer buf_goods for ub.goods .
  define buffer buf_place for ub.place .
   
  for each tt-shift :
    for each buf_shift-period no-lock where buf_shift-period.obj-type = p-obj-type
                                        and buf_shift-period.obj-code = p-obj-code
                                        and buf_shift-period.shift-date = tt-shift.shift-date
                                        and buf_shift-period.shift-num  = tt-shift.shift-num
    :
      find first tt-pl-gds where tt-pl-gds.gds-code = buf_shift-period.gds-code
                             and tt-pl-gds.pl-code  = buf_shift-period.pl-code
                             no-error .
      if available tt-pl-gds then next .
      
      do ii = 1 to num-entries(gds-recid-list-full):
        find first buf_goods where recid(buf_goods) = integer(entry(ii, gds-recid-list-full)) no-lock no-error.
        if available buf_goods
        and buf_goods.gds-code = buf_shift-period.gds-code
        then do :
          create tt-pl-gds .
          assign
            tt-pl-gds.gds-code = buf_goods.gds-code
            tt-pl-gds.gds-name = buf_goods.gds-name
          .
          for first buf_place no-lock where buf_place.obj-type = p-obj-type
                                        and buf_place.obj-code = p-obj-code
                                        and buf_place.pl-code  = buf_shift-period.pl-code
          :
            assign
              tt-pl-gds.pl-code = buf_place.pl-code
              tt-pl-gds.loc1    = buf_place.loc1
            .
          end .
        end .
      end . /*  do ii = 1 to num-entries(gds-recid-list-full) */
      
      find first tt-pl-gds where tt-pl-gds.gds-code = buf_shift-period.gds-code
                             and tt-pl-gds.pl-code  = buf_shift-period.pl-code
                             no-error .
      if available tt-pl-gds then next .
      
      do ii = 1 to num-entries(pl-recid-list-full):
        find first buf_place where recid(buf_place) = integer(entry(ii, pl-recid-list-full)) no-lock no-error.
        if available buf_place
        and buf_place.obj-type = buf_shift-period.obj-type
        and buf_place.obj-code = buf_shift-period.obj-code
        and buf_place.pl-code  = buf_shift-period.pl-code
        then do :
          create tt-pl-gds .
          assign
            tt-pl-gds.pl-code = buf_place.pl-code
            tt-pl-gds.loc1    = buf_place.loc1
          .
          for first buf_goods no-lock where buf_goods.gds-code  = buf_shift-period.gds-code
          :
            assign
              tt-pl-gds.gds-code = buf_goods.gds-code
              tt-pl-gds.gds-name = buf_goods.gds-name
            .
          end .
        end .
      end . /*  do ii = 1 to num-entries(pl-recid-list-full) */
    end .
  end .  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-pl-gds Dialog-Frame 
PROCEDURE init-pl-gds :
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .
  
  define buffer place for ub.place .
  define buffer goods for ub.goods .
  
  empty temp-table tt-pl-gds .
  assign
    pl-recid-list = ""
    gds-recid-list = ""
  .
  for each buf_place no-lock where buf_place.obj-type = p-obj-type
                               and buf_place.obj-code = p-obj-code
  :
    find first buf_pl-gds no-lock where buf_pl-gds.pl-code = buf_place.pl-code no-error .
    if not available buf_pl-gds
    then do :
      assign pl-recid-list-full = pl-recid-list-full + string(recid(buf_place)) + "," .
      next .
    end .
    &scop proc-name gds-attr-value
    {&run_proc_attr-lib}
      (input  buf_pl-gds.gds-code
      ,input  {&attr-fuel-type}
      ,output v-value
      ,output v-type) no-error.
    if v-value = "lgas"
    or v-value = "metan"
    or v-value = "propan"
    then next .
    
    run placelib_get-attr  ( input {&place-com-tanks}
                            ,input buf_place.obj-code
                            ,input buf_place.obj-type
                            ,input buf_place.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
    if v-ok
    and v-value > ""
    then do :
      run placelib_get-attr  ( input {&place-is-main}
                              ,input buf_place.obj-code
                              ,input buf_place.obj-type
                              ,input buf_place.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      if v-ok
      and v-value > ""
      and logical(v-value)
      then do :
      end .
      else do :
        next .
      end .
    end .
    
    assign pl-recid-list-full = pl-recid-list-full + string(recid(buf_place)) + "," .
    
    create tt-pl-gds .
    assign
      tt-pl-gds.pl-code  = buf_place.pl-code
      tt-pl-gds.loc1     = buf_place.loc1
      tt-pl-gds.gds-code = buf_pl-gds.gds-code
    .
    for first buf_goods no-lock where buf_goods.gds-code = buf_pl-gds.gds-code :
      assign tt-pl-gds.gds-name = buf_goods.gds-name .
    end .
  end .
  assign pl-recid-list-full = trim(pl-recid-list-full, ",") .
  
  for each tt-pl-gds no-lock break by tt-pl-gds.pl-code :
    if first-of(tt-pl-gds.pl-code)
    then do :
      for first place where place.pl-code = tt-pl-gds.pl-code :
        assign pl-recid-list = pl-recid-list + string(recid(place)) + "," .
      end .
    end .
  end .
  assign pl-recid-list = trim(pl-recid-list, ",") .
  
  for each tt-pl-gds no-lock break by tt-pl-gds.gds-code :
    if first-of(tt-pl-gds.gds-code)
    then do :
      for first goods where goods.gds-code = tt-pl-gds.gds-code :
        assign gds-recid-list = gds-recid-list + string(recid(goods)) + "," .
      end .
    end .
  end .
  assign
    gds-recid-list = trim(gds-recid-list, ",")
    gds-recid-list-full = gds-recid-list
  .
  
  run find-old-pl-gds .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init_ Dialog-Frame 
PROCEDURE init_ :
  empty temp-table tt-shift-1 .
  empty temp-table tt-shift-2 .
  
  find last buf_shift-obj no-lock where buf_shift-obj.obj-type = p-obj-type
                                    and buf_shift-obj.obj-code = p-obj-code
                                    and buf_shift-obj.status_  = {&sht-closed}
                                    use-index stts
                                    no-error.
  if not available buf_shift-obj
  then do :
    message "Нет закрытой смены на объекте!" view-as alert-box .
    apply "choose" to Btn_Cancel in frame {&frame-name} .
  end .
  
  create tt-shift-1 .
  assign
    tt-shift-1.shift-date = buf_shift-obj.shift-date
    tt-shift-1.shift-num  = buf_shift-obj.shift-num
    tt-shift-1.shift-name = buf_shift-obj.shift-name
    choosed-shift-recid = recid(buf_shift-obj)
    num-rvs = 1
  .
  
  for each prev_shift-obj no-lock where prev_shift-obj.obj-type = p-obj-type
                                    and prev_shift-obj.obj-code = p-obj-code
                                    and prev_shift-obj.status_  = {&sht-closed}
                                    and ( prev_shift-obj.shift-date < buf_shift-obj.shift-date
                                      or prev_shift-obj.shift-date = buf_shift-obj.shift-date
                                        and prev_shift-obj.shift-num  < buf_shift-obj.shift-num
                                    )
                                    by prev_shift-obj.fact-order desc
  :
    create tt-shift-1 .
    assign
      tt-shift-1.shift-date = prev_shift-obj.shift-date
      tt-shift-1.shift-num  = prev_shift-obj.shift-num
      tt-shift-1.shift-name = prev_shift-obj.shift-name
      num-rvs = num-rvs + 1
    .
    if num-rvs = 7
    then leave .
  end .
  
  for each tt-shift-1 : 
    create tt-shift .
    buffer-copy tt-shift-1 to tt-shift .
  end .
  
  run init-pl-gds .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-gds Dialog-Frame 
PROCEDURE select-gds :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define buffer goods for goods.
  define buffer pl-gds for pl-gds.
  define buffer place for place.
  
  define variable vRecId        as recid     no-undo.
  define variable vAnswer       as logical   no-undo.
  define variable vI            as integer   no-undo.
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .

  run ref/gds-ref.p (
                     input parparentproc
                    ,input "b-mark,b-sel"
                    ,input {&all}           /*p-stat */
                    ,input "only-np"        /*p-list  */
                    ,input ?                /*p-cond  */
                    ,input ?                /*p-rec   */
                    ,input ?                /*p-grp   */
                    ,input ?                /*p-cli-type */
                    ,input ?                /*p-cli-code  */
                    ,input p-obj-type       /*p-obj-type  */
                    ,input p-obj-code       /*p-obj-code  */
                    ,input ?                /*p-other     */
                    ,output gds-recid-list).
  if gds-recid-list = "" and can-find(first tt-pl-gds) then do:
    message "Не было выбрано ни одного товара. Очистить список ранее выбранных товаров?"
    view-as alert-box QUESTION buttons YES-NO update vAnswer.
    if not vAnswer then return .
  end.
  empty temp-table tt-pl-gds .
  do vI = 1 to num-entries(gds-recid-list):
    vRecId = integer(entry(vI, gds-recid-list)).
    find first goods where recid(goods) = vRecId no-lock no-error.
    if available goods
    then do:
      for each pl-gds no-lock where pl-gds.gds-code = goods.gds-code
                                and pl-gds.obj-type = p-obj-type
                                and pl-gds.obj-code = p-obj-code,
        first place where place.pl-code = pl-gds.pl-code
      :
        &scop proc-name gds-attr-value
        {&run_proc_attr-lib}
          (input  pl-gds.gds-code
          ,input  {&attr-fuel-type}
          ,output v-value
          ,output v-type) no-error.
        if v-value = "lgas"
        or v-value = "metan"
        or v-value = "propan"
        then next .
        
        run placelib_get-attr  ( input {&place-com-tanks}
                                ,input place.obj-code
                                ,input place.obj-type
                                ,input place.pl-code
                                ,output v-value
                                ,output v-ok      ) no-error.
        if v-ok
        and v-value > ""
        then do :
          run placelib_get-attr  ( input {&place-is-main}
                                  ,input place.obj-code
                                  ,input place.obj-type
                                  ,input place.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          and logical(v-value)
          then do :
          end .
          else do :
            next .
          end .
        end .
    
        create tt-pl-gds .
        assign
          tt-pl-gds.pl-code  = place.pl-code
          tt-pl-gds.loc1     = place.loc1
          tt-pl-gds.gds-code = goods.gds-code
          tt-pl-gds.gds-name = goods.gds-name
        .
      end .
    end.
  end.
  assign pl-recid-list = "" .
  for each tt-pl-gds no-lock break by tt-pl-gds.pl-code :
    if first-of(tt-pl-gds.pl-code)
    then do :
      for first place where place.pl-code = tt-pl-gds.pl-code :
        assign pl-recid-list = pl-recid-list + string(recid(place)) + "," .
      end .
    end .
  end .
  assign
    pl-recid-list = trim(pl-recid-list, ",")
    pl-recid-list-full = pl-recid-list
  .
  
  assign
    gds-recid-list-full = gds-recid-list
    gds-recid-list = ""
  .
  for each tt-pl-gds no-lock break by tt-pl-gds.gds-code :
    if first-of(tt-pl-gds.gds-code)
    then do :
      for first goods where goods.gds-code = tt-pl-gds.gds-code :
        assign gds-recid-list = gds-recid-list + string(recid(goods)) + "," .
      end .
    end .
  end .
  assign gds-recid-list = trim(gds-recid-list, ",") .
  
  run find-old-pl-gds .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION shift-name Dialog-Frame
function shift-name returns character 
  ( input p-shift-num like ub.shift-obj.shift-num, input p-shift-name  like ub.shift-obj.shift-name ):
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
  define variable result as character no-undo.
    
  result = string(p-shift-num, ">9") + " (" + p-shift-name + ")" .

  return result.

end function.
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


