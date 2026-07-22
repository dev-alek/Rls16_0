&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-point-io FOR ub.c-point-io .
DEFINE BUFFER X_point-io FOR ub.point-io.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории пунктов отгрузки/доставки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/09
Author: Bakhtadze Natalya
Creation date: 09/29/09

Кочетков Михаил Юрьевич

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parParentProc   AS WIDGET-HANDLE NO-UNDO.
define input parameter p-db-num        as integer   no-undo .
define input parameter p-point-code    as integer   no-undo .
define input parameter bttns           as char      no-undo .
define input-output param p-rid-list   as char      no-undo .

/* Local Variable Definitions ---                                       */
DEF VAR vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
DEF VAR vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
DEF VAR vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
DEF VAR vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
DEF VAR vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
DEF VAR vss-description AS CHAR NO-UNDO INIT "Список истории пунктов отгрузки/доставки":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ cmp/library.i  }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
{ ref/tmpchgs.i  }

define variable filter-label0 as character no-undo init "Список истории пунктов отгрузки/доставки" .
define variable filter-point0 as character no-undo init "ptiohist" .
define variable filter-label as character no-undo init "Список истории пунктов отгрузки/доставки" .
define variable filter-point as character no-undo init "ptiohist" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable title0 as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

&Scoped-define line-num 7

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-point-io

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-point-io temp-changes

/* Definitions for BROWSE br-c-point-io                                 */
&Scoped-define FIELDS-IN-QUERY-br-c-point-io (mark-string(recid(X_c-point-io), p-rid-list)) X_point-io.point-type X_point-io.point-code X_point-io.point-name X_point-io.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-point-io ~
X_c-point-io.point-io-code
&Scoped-define ENABLED-TABLES-IN-QUERY-br-c-point-io X_c-point-io
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-c-point-io X_c-point-io
&Scoped-define OPEN-QUERY-br-c-point-io OPEN QUERY br-c-point-io FOR EACH X_c-point-io NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-c-point-io X_c-point-io
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-point-io X_c-point-io


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel  B-sch B-Help ~
br-c-point-io BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/*DEFINE BUTTON B-lookup*/
/*     LABEL "&Просмотр"*/
/*     SIZE 10 BY 1.*/

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-c-point-io FOR
      X_c-point-io SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-point-io
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-point-io Dialog-Frame _STRUCTURED
  QUERY br-c-point-io DISPLAY
      (mark-string(recid(X_c-point-io), p-rid-list)) COLUMN-LABEL "*" FORMAT "x(1)"
      X_c-point-io.corr-date                    COLUMN-LABEL "Дата!изменения"  FORMAT "99/99/99"
      string(X_c-point-io.corr-time,"HH:MM")    COLUMN-LABEL "Время!изменения" FORMAT "X(5)"
      usrfulnf(X_c-point-io.corr-user-name)               COLUMN-LABEL "Оператор"        FORMAT "X(18)"
      X_c-point-io.point-code FORMAT "9999999":U
      X_c-point-io.point-type COLUMN-LABEL "Пункт" FORMAT "X(8)":U
      X_c-point-io.point-name COLUMN-LABEL "Наименование" FORMAT "X(40)":U
      TRIM (X_c-point-io.cli-type + ' ' + STRING (X_c-point-io.cli-code) )  COLUMN-LABEL "Контрагент" FORMAT "X(13)":U
      X_c-point-io.is-default COLUMN-LABEL "У" FORMAT "+/ "
      X_c-point-io.address
      X_c-point-io.dist      COLUMN-LABEL "Километраж"
      X_c-point-io.status_ FORMAT "X(8)":U
      X_c-point-io.PS FORMAT "X(50)":U
    ENABLE
      X_c-point-io.point-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 13.71.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(35)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(40)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.88 BY 5.83.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
/*     B-lookup AT ROW 1 COL 31*/
     B-sch AT ROW 1 COL 41
     B-Help AT ROW 1 COL 86.25
     br-c-point-io AT ROW 2 COL 1.38
     BR-changes AT ROW 16.04 COL 1.38
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(77.49) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список договоров"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-point-io B "?" ? ub c-point-io
      TABLE: X_point-io B "?" ? ub point-io
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-c-point-io B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-c-point-io Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       br-c-point-io:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-point-io
/* Query rebuild information for BROWSE br-c-point-io
*/  /* BROWSE br-c-point-io */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* Список платежей */
DO:
    run gbl/markqwa.p ( input b-mark:sensitive, input p-rid-list) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&Scoped-define SELF-NAME B-lookup*/
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame*/
/*ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */*/
/*DO:*/
/*  if not available X_c-point-io then return no-apply.*/

/*  define variable ri as recid no-undo .*/
/*  ri = recid( X_c-point-io ).*/

/*  run str/contr.w ( input parParentProc,input p-host-code, input "history", input {&income}, input-output ri) no-error.*/
/*  if error-status:error then return no-apply.*/

/*END.*/

/*/* _UIB-CODE-BLOCK-END */*/
/*&ANALYZE-RESUME*/


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-point-io then do:
      if can-do( p-rid-list, string( recid( X_c-point-io ) ) ) then do:
          p-rid-list = replace( p-rid-list, {&comma-char} + string( recid( X_c-point-io ) ), "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-point-io ) ) + {&comma-char}, "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-point-io ) ), "") .
      end.
      else
      p-rid-list = p-rid-list + ( if p-rid-list = "" then "" else {&comma-char} ) + string( recid( X_c-point-io ) ) .
      loc#log = br-c-point-io:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = br-c-point-io:select-next-row ().
          apply "VALUE-CHANGED" to br-c-point-io in frame {&frame-name}.
      end.
      if num-entries( p-rid-list ) = 0 then hide mark-num in frame {&frame-name}.
      else disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-c-point-io in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
    tbl = 'c-point-io'
    join-tbl = 'X_c-point-io'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('db-num', 'БД', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-code', 'Код контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type', 'Тип объекта', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('point-type', 'Тип пункта', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('point-code', 'Код пункта', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('point-name', 'Название пункта', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Статус', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS', 'Примечание', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('is-default', 'По молчанию', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('address', 'Адрес', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('dist', 'Километраж', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
  DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
     ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
     ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
    run gbl/filter.w ( INPUT parparentproc
                    , INPUT (filter-point + {&delim-par} +
                            filter-label)
                     , INPUT tbl
                     , INPUT join-tbl
                     , INPUT fld
                     , INPUT lab
                     , INPUT spr
                     , INPUT dim ).
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-point-io ) AND ( p-rid-list = "" ) then  p-rid-list = string( recid( X_c-point-io ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-point-io
&Scoped-define SELF-NAME br-c-point-io
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-point-io Dialog-Frame
ON RETURN OF br-c-point-io IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-c-point-io IN FRAME Dialog-Frame
DO:
  if b-sel:sensitive in frame {&frame-name} then
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
    else                     apply "choose" to b-sel in frame {&frame-name}.
/*  else if b-lookup:sensitive then apply "choose" to b-lookup in frame {&frame-name}.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-point-io Dialog-Frame
ON VALUE-CHANGED OF br-c-point-io IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-point-io.point-code"
  &open-query     = "run OpenBr in this-procedure (input yes, input no, input no)."
  &open-query-otherwise = "run OpenBr in this-procedure (input yes, input no, input no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn = "no"
  &mv-brw-default = "no"
}
/*  &sort-clmn_2    = "X_c-point-io.corr-user-name"*/


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  find first X_point-io no-lock where
            X_point-io.point-code = p-point-code
        and X_point-io.db-num = p-db-num no-error .
  if not available X_point-io then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова "
    view-as alert-box ERROR.
    return.
  end.
  assign
  br-c-point-io:num-locked-columns = 1
  X_c-point-io.point-code:read-only in browse br-c-point-io = yes
  .
  RUN MyEnable in this-procedure .

  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if p-rid-list <> "":U then assign v-doc-rec = integer(entry(1, p-rid-list)) .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DISPLAY
mark-num
WITH FRAME {&frame-name} .
ENABLE
b-quit
b-sel  when  lookup( "b-sel", bttns ) > 0
B-mark when lookup( "b-mark", bttns) > 0
B-sch
B-Help
mark-num
br-c-point-io
BR-changes
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

def var l-query-was-opened as logical no-undo .
def var sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then assign sort-column-phrase = ""  .
  otherwise    assign sort-column-phrase = "by " + sort-column-name  .
end case.


&scop flt-open-open-query OPEN QUERY br-c-point-io FOR EACH X_c-point-io

&scop flt-open-dyn_open-query  FOR EACH X_c-point-io

&scop flt-open-query-handle query br-c-point-io:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-point-io

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-point-io

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .
filter-point = filter-point0 .

ASSIGN frame {&frame-name}:TITLE = title0 .
{ gbl/fltopend.i
  &where-cond = " X_c-point-io.db-num = p-db-num AND X_c-point-io.point-code  = p-point-code "
  &DYN_where-cond = " substitute(' X_c-point-io.db-num = &1 AND X_c-point-io.point-code  = &2 ', p-db-num, p-point-code) "
  &use-ind    = "  "
  &by         = "  "
}

REPOSITION br-c-point-io to recid v-doc-rec No-ERROR.
if error-status:error then REPOSITION br-c-point-io to row 1 No-ERROR.
else  REPOSITION br-c-point-io to row {&line-num} No-ERROR.
run proc-view-changes in this-procedure no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
define buffer new_c-point-io for ub.c-point-io.
define buffer current_point-io for ub.point-io.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.



for each temp-changes:
    delete temp-changes.
END.
if not available X_c-point-io then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

&scop fields-name-list "db-num,cli-type,cli-code,point-code,point-name,point-type,ps,is-defailt,address,dist,deliv-subj-code,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
 + "cli-type" + {&delim-par} + "Тип контрагента" + {&delim-par} + "" + {&delim-flf}
 + "cli-code" + {&delim-par} + "Код контрагента" + {&delim-par} + "" + {&delim-flf}
 + "point-code" + {&delim-par} + "Номер" + {&delim-par} + "" + {&delim-flf}
 + "point-name" + {&delim-par} + "Наименование" + {&delim-par} + "" + {&delim-flf}
 + "point-type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
 + "ps" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "is-default" + {&delim-par} + "По умолчанию" + {&delim-par} + "" + {&delim-flf}
 + "address" + {&delim-par} + "Адрес" + {&delim-par} + "" + {&delim-flf}
 + "dist" + {&delim-par} + "Километраж" + {&delim-par} + "" + {&delim-flf}
 + "deliv-subj-code" + {&delim-par} + "Код субъекта доставки" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-point-io:handle
                                            ,input  {&table_point-io}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


Open QUery br-changes for each temp-changes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME