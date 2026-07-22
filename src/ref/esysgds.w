using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
/* &ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME */
/* Connected Databases
          ub               PROGRESS
*/
/* &Scoped-define WINDOW-NAME CURRENT-WINDOW */
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients FOR ub.clients.
define buffer x_goods	for ub.goods.


/* &ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame */
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Коды товаров внешней системы

Автор: Кабоев Валерий Асланович
Дата создания: 10/01/2013
Author: Kaboev Baleriy
Creation date: 10/01/13

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.

DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
define input parameter p-esys-id as integer no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Коды товаров внешней системы".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/mrk-strf.i }
{ ref/extclass.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ gbl/fltopend.i defproc }
{ ref/extclass.i }
define variable sort-column-name as character no-undo.
define shared variable loc-art  as character no-undo.
define variable filter-point     as character NO-UNDO INIT "esysclis".
define variable filter-label     as character NO-UNDO INIT "Коды объектов внешней системы".
define variable filter-point0     as character NO-UNDO INIT "esysclis".
define variable filter-label0     as character NO-UNDO INIT "Коды объектов внешней системы".
define variable esys-name 		as character no-undo.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable prid 			as recid.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
/* &Scoped-define INTERNAL-TABLES X_ext-classif X_clients             */





/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-add b-del b-cli b-esys ~
b-sch b-print B-Help br-esys-gds mark-num fill-in-code-system fill-in-code-th
&Scoped-Define DISPLAYED-OBJECTS mark-num fill-in-code-system fill-in-code-th

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */


function get-gds-name returns character 
 ( p-gds-code as integer,
   p-attr-code as integer ) forward.


/* ************************  Functions ********************** */

FUNCTION get-esys-name RETURNS CHARACTER
( INPUT p-esys-id AS INTEGER ) :
	DEFINE BUFFER buf_ext-system FOR ub.ext-system.
	FIND FIRST buf_ext-system NO-LOCK WHERE
			  buf_Ext-system.db-num = 0
		  AND buf_Ext-system.esys-id = p-esys-id NO-ERROR.
	IF AVAILABLE buf_ext-system THEN DO:
	   RETURN buf_ext-system.esys-name.
	END.
	RETURN "!!Неизвестная внешняя система".
END FUNCTION.



/* ***********************  Control Definitions  ********************** */
/* Definitions for BROWSE br-esys-gds                                 */
define query br-esys-gds-query for ext-classif.
define browse br-esys-gds query br-esys-gds-query
disp
mark-string(recid(ext-classif), v-rid-list) COLUMN-LABEL "" FORMAT "X(1)"
ext-classif.KEY#_two  COLUMN-LABEL "Код!внешней!системы" FORMAT ">>>>>>>>9"
get-esys-name (ext-classif.KEY#_two) @ esys-name COLUMN-LABEL "Внешняя система" FORMAT "X(30)"
ext-classif.charkey_one  COLUMN-LABEL "Код товара!во внешней!системе" FORMAT "X(20)"
ext-classif.key#_one COLUMN-LABEL "Код!товара" FORMAT ">>>>>>>>9"
get-gds-name(ext-classif.key#_one, ext-classif.key#_three) COLUMN-LABEL "Наименование товара" FORMAT "X(32)"
WITH NO-ROW-MARKERS SEPARATORS SIZE 98.3 BY 20.37 FIT-LAST-COLUMN.
/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cli
     LABEL "Товар"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-esys
     LABEL "ВС"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
     
DEFINE VARIABLE fill-in-code-system AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код товара во внешней системе" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO. 
     
DEFINE VARIABLE fill-in-code-th AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код товара в ТН" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.          

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.



/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 6
     b-add AT ROW 1 COL 31 WIDGET-ID 14
     b-del AT ROW 1 COL 41 WIDGET-ID 16
     b-cli AT ROW 1 COL 51 WIDGET-ID 2
     b-esys AT ROW 1 COL 61 WIDGET-ID 18
     b-sch AT ROW 1 COL 86 WIDGET-ID 12
     b-print AT ROW 1 COL 89 WIDGET-ID 10
     B-Help AT ROW 1 COL 95
     fill-in-code-system AT ROW 2.50 COL 33 COLON-ALIGNED WIDGET-ID 2
     fill-in-code-th AT ROW 2.50 COL 68 COLON-ALIGNED WIDGET-ID 2
     br-esys-gds AT ROW 4.00 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(79.30) SKIP(21.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_ext-classif B "?" ? ub ext-classif
      TABLE: X_ext-system B "?" ? ub ext-system
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-esys-gds B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli Dialog-Frame
ON CHOOSE OF b-cli IN FRAME Dialog-Frame /* Объект */
DO:
  define variable gdsrec as recid no-undo.
  define buffer buf_code for ub.code.
  IF NOT AVAILABLE ext-classif THEN RETURN NO-APPLY.
  for first goods no-lock where goods.gds-code = ext-classif.key#_one:
    gdsrec = recid(goods).
    run ref/gds-form.w (parparentproc, {&lookup}, v-cntxt-obj-type, v-cntxt-obj-code, input this-procedure:handle, input-output gdsrec).
  end.
  if not available goods then 
  do:
    /* если товар не найден, ищем сезон ДТ */
    for first buf_code no-lock where
              buf_code.parent = "DTSeasons"
          and buf_code.code = string(ext-classif.key#_one)
    :
      gdsrec = recid(buf_code).
      run ref/dtseasons-frm.w (
        input parparentproc
        , {&lookup}
        , input-output gdsrec).
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE ext-classif THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-esys
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-esys Dialog-Frame
ON CHOOSE OF b-esys IN FRAME Dialog-Frame
DO:
define variable v-have-rights    as logical        no-undo.
define variable v-success    as logical        no-undo.
define variable v-esys-id   as integer        no-undo.
 IF NOT AVAILABLE ext-classif THEN RETURN NO-APPLY.
 ASSIGN
 v-esys-id = ext-classif.key#_two.
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_openxml-subsystem_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    yes
    v-have-rights
    }
    if v-have-rights = yes
    then do:
                  run bge/oxmlspci.w (
                input parparentproc
              , input {&lookup}
              , input-output v-esys-id
              , input 0 /*v-db-num*/
              , output v-success
          ) no-error.
 end.

  APPLY "entry" TO br-esys-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available ext-classif then do:
    { gbl/markstrn.i ext-classif v-rid-list }
    loc#log = br-esys-gds:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-esys-gds:select-next-row ().
        apply "VALUE-CHANGED" to br-esys-gds in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-esys-gds in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available ext-classif ) then do:
    
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( ext-classif ) ) .
  end.
p-rid-list = v-rid-list .
END.


ON ENTER OF fill-in-code-system IN FRAME Dialog-Frame /* fill-in-code-system */
DO:
  /* new trigger */  
   find first ub.ext-classif no-lock  where 
                                        ub.ext-classif.CharKey_One = fill-in-code-system:screen-value 
                                        and (if fill-in-code-th:screen-value > "" then
                                             ub.ext-classif.Key#_One = integer(fill-in-code-th:screen-value) else true)
                                        and  ub.ext-classif.classif-subject = {&table_goods} 
                                        and  ub.ext-classif.classif-name = {&extclass_goods_esys} no-error.
                                        
  if available ub.ext-classif then reposition br-esys-gds-query to rowid rowid(ub.ext-classif).
                           else message "Указанный код товара во внешней системе отсутствует. ".
  apply "entry" to br-esys-gds in frame {&frame-name} .
  return no-apply.                    
  
END.

ON ENTER OF fill-in-code-th IN FRAME Dialog-Frame /* fill-in-code-th */
DO:
  /* new trigger */ 
  
  find first ub.ext-classif no-lock   where ub.ext-classif.Key#_One=integer(fill-in-code-th:screen-value) 
                                         and (if fill-in-code-system:screen-value>"" then
                                              ub.ext-classif.CharKey_One = fill-in-code-system:screen-value else true )
                                         and ub.ext-classif.classif-subject = {&table_goods} 
                                         and ub.ext-classif.classif-name = {&extclass_goods_esys}  no-error.                                         
  if available ub.ext-classif then reposition br-esys-gds-query to rowid rowid(ub.ext-classif).
                           else message "Указанный код товара в TH отсутствует. ".
  apply "entry" to br-esys-gds in frame {&frame-name} .  
  return no-apply.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  if not (p-list-mode = {&all}
         or
         p-list-mode = "one") then  do:
    message
    substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
    view-as alert-box error .
    undo, return error .
  end.

  if p-list-mode = "one" then do:
    find first ext-system no-lock where
              ext-system.db-num = 0
          and ext-system.esys-id = p-esys-id no-error.
    if not available ext-system then do:
      message
      substitute("Неверное значение параметра p-esys-id=&1&2" +
                  "Нет внешней системы &1 с db-num = 0"
                , p-esys-id)
      view-as alert-box error .
      undo, return error .
    end.
  end.
  RUN Myenable.
  run ui-on.
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


PROCEDURE UI-on :
/*
    open query br-esys-gds-query
	for each ext-classif no-lock
	where ext-classif.classif-subject = {&table_goods}
	.
    */
    /*
    define input  parameter p-open-query     as logical   no-undo .
    define input  parameter p-find-next      as logical   no-undo .
    define input  parameter p-find-condition as character no-undo . */
    define variable sort-column-phrase as character no-undo .
    define variable l-query-was-opened as logical no-undo .
    define variable title0 as character no-undo .
    define buffer buf_clients for clients.

	/* if prid <> ? then reposition br-esys-gds to recid prid no-error. */
    /* закинул фильтрацию с esysclis.w */
    &scop flt-open-debug-file
    &scop flt-open-open-query         OPEN QUERY br-esys-gds-query FOR EACH ext-classif
    &scop flt-open-dyn_open-query     FOR EACH ext-classif
    &scop flt-open-query-handle       QUERY br-esys-gds-query:handle
    /*
    &scop flt-open-open-query-tail  , FIRST goods NO-LOCK WHERE ~
                                      goods.gds-code = ext-classif.key#_one
                                      */
    &scop flt-open-query-was-opened   l-query-was-opened
    &scop flt-open-sort-column-phrase sort-column-phrase
    &scop flt-open-call-point         filter-point
    &scop flt-open-set-filter-name    set-filter-name
    &scop flt-open-indexed-reposition INDEXED-REPOSITION
    filter-point = filter-point0 + p-list-mode .
    case p-list-mode :
      when {&all} then do:
        title0 = "Товары всех внешних систем".
        ASSIGN
        frame {&frame-name}:title = substitute("&1", title0)
        filter-label = SUBSTITUTE("&1"
                                  , frame {&frame-name}:title
                                  )
        .
        { gbl/fltopend.i
          &where-cond = " ext-classif.classif-subject = ~{&table_goods~} ~
                        and ext-classif.classif-name = ~{&extclass_goods_esys~}"
          &dyn_where-cond = " substitute('ext-classif.classif-subject = &1&2&1 ~
                        and ext-classif.classif-name = &1&3&1 ~', ~{&double-quote~}, ~{&table_goods~}, ~{&extclass_goods_esys~})"
          &use-ind    = "  "
          &by         = "  " }
      end.
      when "one" then do:
        title0 = substitute("Товары внешней системы &1", p-esys-id).
        ASSIGN
        frame {&frame-name}:title = substitute("&1", title0)
        filter-label = SUBSTITUTE("&1"
                                  , frame {&frame-name}:title
                                  )
        .
        { gbl/fltopend.i
          &where-cond = " ext-classif.classif-subject = ~{&table_goods~} ~
                          and ext-classif.classif-name = ~{&extclass_goods_esys~} ~
                          AND ext-classif.key#_two = p-esys-id"
          &dyn_where-cond = " substitute('ext-classif.classif-subject = &1&2&1 ~
                          and ext-classif.classif-name = &1&4&1 ~
                          AND ext-classif.key#_two = &3', ~{&double-quote~}, ~{&table_goods~}, p-esys-id, ~{&extclass_goods_esys~})"

          &use-ind    = "  "
          &by         = "  " }

      end.
    end case.

END PROCEDURE.


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
  DISPLAY mark-num fill-in-code-system fill-in-code-th
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-del b-cli b-esys b-sch b-print B-Help
         br-esys-gds mark-num 
         fill-in-code-system fill-in-code-th
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ENABLE
b-quit
b-cli
b-print
B-mark when (lookup("b-mark", bttns) > 0 and not transaction)
b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction)
b-esys
b-sch
b-sel when (lookup("b-sel", bttns) > 0 and not transaction)
B-Help
br-esys-gds
fill-in-code-system
fill-in-code-th
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
	DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
	define variable v-rid as recid no-undo .
	DEFINE VARIABLE v-ok AS logical NO-UNDO.
	define variable v-esys-id as integer no-undo .
	define variable v-value-character as character no-undo init "".
	define variable v-uniq-key-rec as character no-undo .
	define variable v-esys-uniq-key-rec as character no-undo .
	define variable v-tbl-row as rowid no-undo .
	define variable v-tbl-name as character no-undo .
	define buffer buf_goods for ub.goods.
	define buffer buf_ext-system for ub.ext-system.
	define variable cursorr	 as integer no-undo init 0.
	/* параметры для goo-ref.w */
	define variable v-list 		as character no-undo.


run ref/code_system.w ( input  parparentproc  ,
            
                        output v-rid  ).
				if v-rid <> ? then do:
				  run ui-on in this-procedure.
				  reposition br-esys-gds-query to recid v-rid no-error .
				  apply "entry" to br-esys-gds in frame {&frame-name} .
				end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
	DEFINE VARIABLE v-rec AS RECID NO-UNDO.
	DEFINE VARIABLE glog AS logical NO-UNDO.
	IF NOT AVAILABLE ext-classif THEN UNDO, RETURN ERROR.
	v-rec = recid(ext-classif).
	MESSAGE
	"Вы действительно хотите удалить эту запись?"
	VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
	IF NOT glog THEN RETURN ERROR.
	for each ext-classif-attr exclusive-lock where ext-classif-attr.classif-subject = ext-classif.classif-subject
      and ext-classif-attr.classif-name = ext-classif.classif-name
      and ext-classif-attr.db-num = ext-classif.db-num
      and ext-classif-attr.Key#_One = ext-classif.key#_one
      and ext-classif-attr.Key#_two = ext-classif.key#_two
      and ext-classif-attr.Key#_three = ext-classif.key#_three
      and ext-classif-attr.CharKey_One = ext-classif.charkey_one
      and ext-classif-attr.CharKey_two = ext-classif.charkey_two
      and ext-classif-attr.CharKey_three = ext-classif.charkey_three
      and ext-classif-attr.nonunique = ext-classif.nonunique :
        delete ext-classif-attr .  
    end.
	run ref/extclas3.p ( INPUT NO /*p-silent*/
						,INPUT v-rec) NO-ERROR.
	if not error-status:error then do:
	    run ui-on in this-procedure.
	    reposition br-esys-gds-query to row 1 no-error .
	    apply "entry" to br-esys-gds in frame {&frame-name} .
	end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
    define buffer b-ext-classif for ub.ext-classif.
    define variable cnter as integer no-undo init 0.
    define variable xml_tmp as character no-undo.
    define variable xslt-path as character no-undo.
    define variable report as class ReportXml no-undo.
    define variable rep-out-unit    as class rep-out no-undo.
    define variable ckeythree as character no-undo init "".
    xml_tmp = string(session:temp-directory + "extgds-tmp.xml"). /* путь к временному xml файлу */
    report = new ReportXml(xml_tmp).
    report:worksheet("Лист 1").
    report:worksheet-header("start").   /* Начало шапки отчета */
    report:worksheet-header("Справочник соответствия товаров во внешней системе и TradeHouse.").
    report:worksheet-header("Дата печати: " + string(cur-time-date())).
    report:worksheet-header("end").     /*Конец шапки отчета*/
    report:table-columns("80,120,80,140,400").    /* Начало таблицы, задаем размеры колонок */
    report:table-types = "String,String,String,String,String".   /* Типы данных в таблице */
    report:table-header("Внешняя система|Код внешней системы|Код товара|Код товара во внешней системе|Наименование товара","40","4").    /* Шапка таблицы */
    for each b-ext-classif no-lock where b-ext-classif.classif-subject = {&table_goods} and b-ext-classif.classif-name = {&extclass_goods_esys} by b-ext-classif.key#_two:
        ckeythree = replace(b-ext-classif.charkey_three, "|", "\").
        ckeythree = replace(ckeythree,"<","[").
        ckeythree = replace(ckeythree,">","]").
        ckeythree = replace(ckeythree,"","*").
        report:table-row(   replace(get-esys-name (b-ext-classif.KEY#_two), "|", "/")
            + "|" +       string(b-ext-classif.key#_two)  /* код внешней системы */
            + "|" +       string(b-ext-classif.key#_one) /* код товара */
            + "|" +       replace(b-ext-classif.charkey_one, "|", "/")
            + "|" +       ckeythree
        ).
        cnter = cnter + 1.
    end.
    report:table-total("Итого|" + string(cnter) + "|||").
    report:worksheet("end").
    delete object report.
    xslt-path = search("exe\template.xsl").
    rep-out-unit = new rep-out ().
    rep-out-unit:office(xml_tmp, xslt-path).
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
    define variable v-ri as recid no-undo .
    assign
    v-ri = (if avail ext-classif then recid(ext-classif) else ?)
    .
    assign
    tbl = {&table_ext-classif}
    join-tbl = 'ext-classif'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    .

    run fltfield-add in this-procedure('key#_one', 'Код товара', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('key#_two', 'Код внешней системы', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('charkey_one', 'Код товара во внешней системе', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

    DO on stop undo, leave:
        run gbl/filter.w ( INPUT parparentproc
                         ,INPUT filter-point + {&delim-par} + filter-label
                         ,INPUT tbl
                         ,INPUT join-tbl
                         ,INPUT fld
                         ,INput lab
                         ,INPUT spr
                         ,INPUT  dim).
        run ui-on in this-procedure.
        if v-ri <> ? then do:
          reposition br-esys-gds-query to recid v-ri no-error.
        end.
        APPLY "ENTRY" to br-esys-gds in frame {&frame-name} .
        APPLY "VALUE-CHANGED" to br-esys-gds.
    END .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .
/* перемещение на первую, последнюю, предыдущую, следующую */
define buffer buf_ext for ub.ext-classif.
define buffer bgds      for ub.goods.
define query q-ext for buf_ext .
define variable v-rec as recid no-undo.


case p-direction :
  when "first":U
  then do:
    for first buf_ext:
        reposition br-esys-gds-query to recid recid(buf_ext).
        for first ub.goods no-lock where goods.gds-code = ext-classif.key#_one:
            p-recid = recid(goods).
        end.
   end.
   end.
  when "last":U
  then do:
        for first buf_ext:
        reposition br-esys-gds-query to recid recid(buf_ext).
        for first ub.goods no-lock where goods.gds-code = ext-classif.key#_one:
            p-recid = recid(goods).
        end.
   end.
  end.
  when "prev":U
  then do:
    reposition br-esys-gds-query backwards 0.
    if not available ext-classif then do:
      message
      "Это первый товар списка"
      view-as alert-box.
    end.
    else
        for first ub.goods no-lock where goods.gds-code = ext-classif.key#_one:
            p-recid = recid(goods).
        end.
  end.
  when "next":U
  then do:
   reposition br-esys-gds-query forwards 0.
    if not available  ext-classif then do:
      message
      "Это последний товар списка"
      view-as alert-box.
    end.
    else
        for first ub.goods no-lock where goods.gds-code = ext-classif.key#_one:
            p-recid = recid(goods).
        end.
  end.
end case . /* p-direction */



/*
 find first goods where RECID(goods) = p-recid no-lock.

  if not available goods then return .

open query q-ext for each buf_ext where buf_ext.key#_one = goods.gds-code.
get next q-ext no-lock.
  open br-esys-gds-query f.
  get next br-esys-gds-query.
case p-direction :
  when "first":U
  then do:
    get first q-ext.
  end.
  when "last":U
  then do:
    get last q-ext.
  end.
  when "prev":U
  then do:
    get prev q-ext.
    if not available buf_ext then do:
      message
      "Это первый товар списка"
      view-as alert-box.
    end.
  end.
  when "next":U
  then do:
    get next q-ext.
    if not available buf_ext then do:
      message
      "Это последний товар списка"
      view-as alert-box.
    end.
  end.
end case . /* p-direction */

for first ub.goods no-lock where
        ub.goods.gds-code = buf_ext.key#_one :
  p-recid = recid(ub.goods).
  reposition br-esys-gds-query to recid p-recid no-error.
end.
*/

END PROCEDURE.

/* ************************  Function Implementations ***************** */

function get-gds-name returns character 
 ( p-gds-code as integer ,
   p-attr-code as integer):
    define buffer bf_goods for ub.goods.
    define buffer bf_code for ub.code.

    find first bf_goods no-lock where bf_goods.gds-code = p-gds-code no-error. 
    
    if available bf_goods then
    do:
      if p-attr-code <> 0 then 
      do:
        find first bf_code where
                   bf_code.parent = "DTSeasons"
               and bf_code.code = string(p-attr-code) 
             no-lock no-error.
      end.
      return bf_goods.gds-name + if available bf_code then " : " + bf_code.codename else "".
    end.
    else return "".
    
end function.

