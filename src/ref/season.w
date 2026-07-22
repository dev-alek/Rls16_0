&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-type-tmp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-type-tmp
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник сезонов

Автор: Чернова Светлана Александровна
Дата создания: 09/07/05
Author: Svetlana Chernova
Creation date: 09/07/05

Нужен для расчета темпа продаж в заказе

bttns =
  b-add
  b-sel
  b-mark

*/
using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter bttns  as character   no-undo .
define output parameter rid-list    as  character no-undo . /* список recid'ов выбранных аписей */


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник сезонов".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ cmp/r-pril.i new }
{ gbl/cur-time.i   }
{ cmp/operlist.i   }
{ gbl/waitfram.i   }
{ gbl/getcntxt.i get }
{ gbl/userobjs.i }
{ ref/chgdssea.i }


define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define variable v-sel-obj-list as character no-undo .
define variable v-sel-ok as character no-undo .
define variable g#report-num as integer   no-undo .
define shared variable g#db-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).
define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable v-log as logical   no-undo .
define variable v-user-select as logical no-undo .
define variable v-cur-time as character no-undo.


define temp-table tt-season no-undo
    field sea-code as integer format "->>>,>>>,>>9" /* код сезона */
    field db-num as integer  format ">>>>9"/* номер БД */
    field is-glob-sea as logical /* логич переменная для проверки глобальности сезона  */
    field attr-value as character format "X(30)" /*Значение атрибута*/

index pi as primary unique sea-code db-num
.



def stream ListStream .

define variable sort-column-name as character no-undo .

define buffer buf_gds-season for ub.gds-season.
define buffer buf_gds-season-attr for ub.gds-season-attr.
define buffer buf1_gds-season for ub.gds-season.
define buffer buf1_gds-season-attr for ub.gds-season-attr.
define buffer buf_season for ub.season.
define buffer buf_season-attr for ub.season-attr.
define buffer buf_goods for ub.goods.

define temp-table tt-line no-undo
    field sea-code as integer format "->>>,>>>,>>9" /* код сезона */
    field db-num as integer  format ">>>>9"/* номер БД */ 
    field sea-name as character /*Название сезона*/
    field sea-month-1 as integer  format ">9"
    field sea-month-2 as integer  format ">9"
    field attr-value as character
    
    index pi as primary unique sea-code db-num
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&glob check-no-error no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

&scop sel-obj ~
  ~{                       ~
    gbl/uobjsman.i        ~
    parparentproc         ~
    v-cntxt-db-num        ~
    v-cntxt-userid        ~
    v-cntxt-host-code-obj ~
    v-cntxt-obj-type      ~
    v-cntxt-obj-code      ~
    v-sel-ok        ~
  ~}  

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-type-tmp
&Scoped-define BROWSE-NAME br-season

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.season, tt-season

/* Definitions for BROWSE br-season                                     */
&Scoped-define FIELDS-IN-QUERY-br-season ~
(IF ( CAN-DO (rid-list, string( recid( season ) ) ) ) THEN ("*") ELSE (" ")) ~
ub.season.sea-code ub.season.sea-name date-func(season.sea-month-1) ~
date-func(season.sea-month-2) 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-season
&Scoped-define QUERY-STRING-br-season FOR EACH ub.season ~
      WHERE season.sea-month-1 <> 0 ~
 AND season.sea-month-2 <> 0 NO-LOCK
 
&Scoped-define OPEN-QUERY-br-season OPEN QUERY br-season FOR EACH ub.season ,~
      EACH tt-season ~
      WHERE season.sea-month-1 <> 0 ~
             AND season.sea-month-2 <> 0 ~
             AND tt-season.sea-code = season.sea-code ~
             AND tt-season.db-num = season.db-num ~
             AND tt-season.is-glob-sea = true ~
             NO-LOCK.
             
&Scoped-define OPEN-QUERY-br-season-loc OPEN QUERY br-season FOR EACH ub.season ,~
      EACH tt-season ~
      WHERE season.sea-month-1 <> 0 ~
             AND season.sea-month-2 <> 0 ~
             AND tt-season.sea-code = season.sea-code ~
             AND tt-season.db-num = season.db-num ~
             AND tt-season.is-glob-sea = false ~
             NO-LOCK.    
             
&Scoped-define OPEN-QUERY-br-season-loc-cur OPEN QUERY br-season FOR EACH ub.season ,~
      EACH tt-season ~
      WHERE season.sea-month-1 <> 0 ~
             AND season.sea-month-2 <> 0 ~
             AND tt-season.sea-code = season.sea-code ~
             AND tt-season.db-num = season.db-num ~
             AND tt-season.is-glob-sea = false ~
             AND tt-season.attr-value = v-cntxt-obj-type + string( v-cntxt-obj-code ) ~
             NO-LOCK. 
             
&Scoped-define OPEN-QUERY-br-season-loc-obj OPEN QUERY br-season FOR EACH ub.season ,~
      EACH tt-season ~
      WHERE season.sea-month-1 <> 0 ~
             AND season.sea-month-2 <> 0 ~
             AND tt-season.sea-code = season.sea-code ~
             AND tt-season.db-num = season.db-num ~
             AND tt-season.is-glob-sea = false ~
             AND lookup(tt-season.attr-value, v-sel-obj-list) > 0 ~
             NO-LOCK.                                       
 

 
 

 
&Scoped-define TABLES-IN-QUERY-br-season ub.season, tt-season
&Scoped-define FIRST-TABLE-IN-QUERY-br-season ub.season
&Scoped-define SECOND-TABLE-IN-QUERY-br-season tt-season


/* Definitions for DIALOG-BOX d-type-tmp                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-type-tmp ~
    ~{&OPEN-QUERY-br-season}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RADIO-SET-1 RADIO-SET-2 b-exit b-sel b-goods b-copy b-hist b-help B-mark ~
b-add b-upd b-del mark-num b-print br-season
&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-1 RADIO-SET-2 mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD date-func d-type-tmp
FUNCTION date-func RETURNS DATE
( input date-int as int)  FORWARD.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 12 BY 1.

DEFINE BUTTON b-goods
     LABEL "Товары":L
     SIZE 10 BY 1.

DEFINE BUTTON b-copy
     LABEL "Копировать":L
     SIZE 12 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-upd
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Глобальные", 1,
          "Локальные", 2
     SIZE 15 BY 2 NO-UNDO.   
     
DEFINE VARIABLE RADIO-SET-2 AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
          "Текущий", 2,
          "Выборочно", 3
     SIZE 12 BY 2 NO-UNDO. 
     
/*DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор  смены на обьекте"
     BGCOLOR 8 .*/ 
     
    

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-season FOR
      ub.season,
      tt-season SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-season
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-season d-type-tmp _STRUCTURED
  QUERY br-season NO-LOCK DISPLAY
      (IF ( CAN-DO (rid-list, string( recid( ub.season ) ) ) ) THEN ("*") ELSE (" ")) COLUMN-LABEL "*" FORMAT "X(1)":U
      ub.season.sea-code COLUMN-LABEL "Код" FORMAT ">>>>>>>>>9":U
      date-func(ub.season.sea-month-1) COLUMN-LABEL "с" FORMAT "99/99/99":U
      date-func(ub.season.sea-month-2) COLUMN-LABEL "по" FORMAT "99/99/99":U
      ub.season.sea-name FORMAT "X(100)":U
      ub.season.db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 56 BY 18.46
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-type-tmp
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 13
     b-goods AT ROW 1 COL 23
     b-copy AT ROW 1 COL 33
     b-hist AT ROW 1 COL 33
     b-help AT ROW 1 COL 43
     B-mark AT ROW 2 COL 1
     b-add AT ROW 2 COL 4
     b-upd AT ROW 2 COL 13
     b-del AT ROW 2 COL 23
     RADIO-SET-1 AT ROW 3 COL 15 NO-LABEL
     RADIO-SET-2 AT ROW 3 COL 30 NO-LABEL
     "Сезоны" VIEW-AS TEXT
     SIZE 8 BY .62 AT ROW 3.5 COL 5 WIDGET-ID 8
     mark-num AT ROW 2 COL 34 NO-LABEL
     b-print AT ROW 2 COL 43
     br-season AT ROW 5.25 COL 1.5
/*     B-obj AT ROW 4.20 COL 41 WIDGET-ID 6*/
     SPACE(0.37) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сезоны":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-type-tmp
                                                                        */
/* BROWSE-TAB br-season b-print d-type-tmp */
ASSIGN
       FRAME d-type-tmp:SCROLLABLE       = FALSE.

ASSIGN
       br-season:NUM-LOCKED-COLUMNS IN FRAME d-type-tmp     = 3.

/* SETTINGS FOR FILL-IN mark-num IN FRAME d-type-tmp
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-season
/* Query rebuild information for BROWSE br-season
     _TblList          = "ub.season"
     _Options          = "NO-LOCK"
     _Where[1]         = "season.sea-month-1 <> 0
 AND season.sea-month-2 <> 0"
     _FldNameList[1]   > "_<CALC>"
"(IF ( CAN-DO (rid-list, string( recid( season ) ) ) ) THEN (""*"") ELSE ("" ""))" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > ub.season.sea-code
"sea-code" "Код" ">>>>>>>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > ub.season.sea-name
"sea-name" ? ? "character" ? ? ? ? ? ? no ":C20" no no ? yes no no "U" "" ""
     _FldNameList[4]   > "_<CALC>"
"date-func(season.sea-month-1)" "с" "X(10)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   > "_<CALC>"
"date-func(season.sea-month-2)" "по" "X(10)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE br-season */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-type-tmp
/* Query rebuild information for DIALOG-BOX d-type-tmp
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-type-tmp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-type-tmp
ON CHOOSE OF b-add IN FRAME d-type-tmp /* Добавить */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_season_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return no-apply .

 run ref/seasoni.w ( parParentProc , {&add-def}, input-output rr ).
 if rr <> ? then
    do:
        run open-br. /*{&OPEN-QUERY-br-season}*/
        reposition br-season to recid rr no-error.
        log-res  = br-season:select-focused-row( ) no-error.
        apply "ENTRY":U to br-season.
        apply "home"    to br-season.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-type-tmp
ON CHOOSE OF b-del IN FRAME d-type-tmp /* Удалить */
DO:

define variable g-log as logical   no-undo .
define variable v-recid as integer no-undo .
define variable ii as integer no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_season_deletion':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }

if not available ub.season or v-log = false then  return no-apply.

if not g#db-num = 0 and not can-find (buf_season-attr where buf_season-attr.sea-code = ub.season.sea-code
                                            and buf_season-attr.db-num = ub.season.db-num
                                            and buf_season-attr.attr-code = {&seaattr-obj})
then do:
  message "Нельзя удалить глобальный сезон в УБД."
          view-as alert-box information.
  return no-apply.
end.

message "Удалить запись ? При этом удаляется привязка товаров к сезону."
          view-as alert-box question
          buttons yes-no
          update g-log.
          if g-log = false then return no-apply.

find current ub.season exclusive-lock no-error .
if available ub.season then delete ub.season.

run open-br.  /*{&OPEN-QUERY-br-season}*/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods d-type-tmp
ON CHOOSE OF b-goods IN FRAME d-type-tmp /* Товары */
DO:
  if not available ub.season then return no-apply.
  run ref/seagdsl.w
    ( input Parparentproc,
      input ub.season.sea-code,
      input ub.season.db-num,
      input ub.season.sea-name
      ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy d-type-tmp
ON CHOOSE OF b-copy IN FRAME d-type-tmp /* Копировать */
DO:

  define variable v-user-select as logical   no-undo .
  define variable v-ok as logical no-undo.
  define variable v-seaobj as character no-undo.
  define variable v-sea-code as integer no-undo.
  define variable v-db-num as integer no-undo.
  define variable v-longchar as longchar no-undo .
  
  if not available ub.season then return no-apply.

  { gbl/uobjsman.i
    parParentProc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
  }

  
  
  if v-user-select then do:
    _foreach-userobj:
    for each userobjs_temp-user-obj no-lock:
      
      for each buf_gds-season no-lock where buf_gds-season.sea-code = ub.season.sea-code
        and buf_gds-season.db-num = ub.season.db-num:
        run chk-gdssea in this-procedure 
          ( input buf_gds-season.gds-code,
            input userobjs_temp-user-obj.obj-type + string (userobjs_temp-user-obj.obj-code),
            input ub.season.sea-month-1,
            input ub.season.sea-month-2,
            input ?,
            output v-sea-code,
            output v-db-num,
            output v-ok) no-error.
        if not v-ok then do:
          find first buf_goods no-lock where buf_goods.gds-code = buf_gds-season.gds-code no-error.
          find first buf_season no-lock where buf_season.sea-code = v-sea-code
            and buf_season.db-num = v-db-num
          no-error.
          assign
            v-longchar = v-longchar +
              substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v-sea-code, buf_season.sea-name, {&new-line})
            v-ok = true
            .
        end.
      end.
      if v-longchar <> "" then do:
        assign
          v-longchar = v-longchar +
            substitute ("Сезон &1 &2 не скопирован для объекта &3.&4",
                        ub.season.sea-code, 
                        buf_season.sea-name, 
                        userobjs_temp-user-obj.obj-type + string (userobjs_temp-user-obj.obj-code), 
                        {&new-line}
                        ).
        next _foreach-userobj.
      end.
      
      do transaction:
        create buf_season.
        assign 
          buf_season.sea-code = next-value ( s-casm , {&db-name_schema} )
          buf_season.db-num = v-cntxt-db-num
          .
        buffer-copy ub.season except ub.season.sea-code ub.season.db-num ub.season.sea-name to buf_season.
        buf_season.sea-name = ub.season.sea-name + " " + userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
        create buf_season-attr.
        assign
          buf_season-attr.sea-code = buf_season.sea-code 
          buf_season-attr.db-num = buf_season.db-num
          buf_season-attr.attr-code = {&seaattr-obj}
          buf_season-attr.attr-value = userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code)
          .
        for each buf_gds-season where buf_gds-season.sea-code = ub.season.sea-code
          and buf_gds-season.db-num = ub.season.db-num:
          create buf1_gds-season.
          assign 
            buf1_gds-season.sea-code = buf_season.sea-code
            buf1_gds-season.db-num = buf_season.db-num
            .
          buffer-copy buf_gds-season except buf_gds-season.sea-code buf_gds-season.db-num to buf1_gds-season.       
          for each buf_gds-season-attr where buf_gds-season-attr.sea-code = ub.season.sea-code
            and buf_gds-season-attr.db-num = ub.season.db-num
            and buf_gds-season-attr.gds-code = buf1_gds-season.gds-code:
            create buf1_gds-season-attr.
            assign 
              buf1_gds-season-attr.sea-code = buf_season.sea-code
              buf1_gds-season-attr.db-num = buf_season.db-num
              .
            buffer-copy buf_gds-season-attr except buf_gds-season-attr.sea-code buf_gds-season-attr.db-num to buf1_gds-season-attr.        
          end.
        end.
      end.
    end.
  end.
  if v-longchar <> "" then do:
    run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
          + 'title=Проверка товарного наполнения сезона: при копировании сезона возникли пересечения\':u
          + 'Editor_col=1\':u
          + 'Editor_width=96\':u
          + 'Editor_height=21\':u
          + 'readonly=yes\':u
        ,input-output v-longchar
        ,output v-ok ) no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "4"
          view-as alert-box error
        .
    assign
      v-longchar = "".
  end.
run open-br.  /*{&OPEN-QUERY-br-season}*/
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-type-tmp
ON CHOOSE OF b-hist IN FRAME d-type-tmp /* История */
DO:
  find current ub.season no-lock no-error .
  if available ub.season THEN
      run ref/seasonh.w
      ( input parParentProc ,
        input ub.season.sea-code,
        input ub.season.db-num
        ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark d-type-tmp
ON CHOOSE OF B-mark IN FRAME d-type-tmp /* * */
DO:
  if not available ub.season then return.
  { gbl/markstrn.i ub.season rid-list }
    v-log = br-season :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
      v-log = br-season:select-next-row () in frame {&frame-name}.
      apply "iteration-changed" to br-season in frame {&frame-name}.
  end.

  if num-entries (rid-list) = 0 then
     hide mark-num in frame {&frame-name}.
  else
    disp num-entries (rid-list) @ mark-num
    with frame {&frame-name}.

  apply "entry" to br-season in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-type-tmp
ON CHOOSE OF b-print IN FRAME d-type-tmp /* Печать */
DO: /* Тут печать только в html, на экран печать ниже, в комментариях*/
   for each tt-line no-lock :
   delete tt-line.
   end.
   
   v-cur-time = cur-time-print ().

  
   define variable v-file-name as character no-undo.
   
   /*Глобальные*/ 
   if RADIO-SET-1:screen-value = "1" then do: 
     
      FOR EACH ub.season ,EACH tt-season
      WHERE season.sea-month-1 <> 0
             AND season.sea-month-2 <> 0
             AND tt-season.sea-code = season.sea-code
             AND tt-season.db-num = season.db-num
             AND tt-season.is-glob-sea = true:
     create tt-line.         
     tt-line.sea-code = tt-season.sea-code.
     tt-line.db-num = tt-season.db-num. 
     tt-line.sea-name = season.sea-name.
     tt-line.sea-month-1 = season.sea-month-1.
     tt-line.sea-month-2 = season.sea-month-2.
     tt-line.attr-value = "глоб".   
     end. 
     
   end. 
     
     
     /*Локальные - все*/
   if RADIO-SET-1:screen-value in frame {&FRAME-NAME} = "2" 
  AND RADIO-SET-2:screen-value in frame {&FRAME-NAME} = "1"  then do:
    
     FOR EACH ub.season ,EACH tt-season
      WHERE season.sea-month-1 <> 0
             AND season.sea-month-2 <> 0
             AND tt-season.sea-code = season.sea-code
             AND tt-season.db-num = season.db-num
             AND tt-season.is-glob-sea = false:
     create tt-line.         
     tt-line.sea-code = tt-season.sea-code.
     tt-line.db-num = tt-season.db-num. 
     tt-line.sea-name = season.sea-name.
     tt-line.sea-month-1 = season.sea-month-1.
     tt-line.sea-month-2 = season.sea-month-2. 
     tt-line.attr-value  = tt-season.attr-value.   
     end. 
    
    end.  
    
   /*Локальные - текущий*/
   if RADIO-SET-1:screen-value in frame {&FRAME-NAME} = "2" 
  AND RADIO-SET-2:screen-value in frame {&FRAME-NAME} = "2"  then do:
    
     FOR EACH ub.season ,EACH tt-season
      WHERE season.sea-month-1 <> 0
             AND season.sea-month-2 <> 0
             AND tt-season.sea-code = season.sea-code
             AND tt-season.db-num = season.db-num
             AND tt-season.is-glob-sea = false
             AND tt-season.attr-value = v-cntxt-obj-type + string( v-cntxt-obj-code ):
     create tt-line.         
     tt-line.sea-code = tt-season.sea-code.
     tt-line.db-num = tt-season.db-num. 
     tt-line.sea-name = season.sea-name.
     tt-line.sea-month-1 = season.sea-month-1.
     tt-line.sea-month-2 = season.sea-month-2.  
     tt-line.attr-value  = tt-season.attr-value.   
     end. 
     
   end.
     
   /*Локальные - выборочно*/
   if RADIO-SET-1:screen-value in frame {&FRAME-NAME} = "2" 
  AND RADIO-SET-2:screen-value in frame {&FRAME-NAME} = "3"  then do:
    
     FOR EACH ub.season ,EACH tt-season
      WHERE season.sea-month-1 <> 0
             AND season.sea-month-2 <> 0
             AND tt-season.sea-code = season.sea-code
             AND tt-season.db-num = season.db-num
             AND tt-season.is-glob-sea = false
             AND lookup(tt-season.attr-value, v-sel-obj-list) > 0:
     create tt-line.         
     tt-line.sea-code = tt-season.sea-code.
     tt-line.db-num = tt-season.db-num. 
     tt-line.sea-name = season.sea-name.
     tt-line.sea-month-1 = season.sea-month-1.
     tt-line.sea-month-2 = season.sea-month-2. 
     tt-line.attr-value  = tt-season.attr-value.    
     end. 
    
    end.  
     
     
           
  
            
  
   run create-rep(output v-file-name).
   if v-file-name = ? then
        MESSAGE "Не удалось создать html-файл"
        VIEW-AS ALERT-BOX.
    else
        run open-ie(v-file-name).   
  
/*  Печать только в txt формате.
define variable sym1 as character init ":"   no-undo.
define variable sym2 as character init ":"   no-undo.
define variable sym3 as character init ":"   no-undo.
define variable sym4 as character init ":"   no-undo.
define variable sym5 as character init ":"   no-undo.

define variable Line                    as character         no-undo.

define variable ii      as integer   no-undo.
define variable StartRecid      as integer   no-undo.

DEFINE FRAME List
    sym1 column-label ":" format "x(1)"
    ub.season.sea-code column-label {&g___code} format ">>>>>>>>>>>>9"
    sym2 column-label ":" format "x(1)"
    ub.season.sea-name column-label "Наименование" format "x(69)"
    sym3 column-label ":" format "x(1)"
    ub.season.sea-month-1
    sym4 column-label ":" format "x(1)"
    ub.season.sea-month-2
    sym5 column-label ":" format "x(1)"
    HEADER
        cur-time-print () format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( ListStream ) , ">>9") )
                AT 86 format "X(15)" SKIP
        Line format "x(110)" AT 1
    with width {&A4_CW} down use-text stream-io no-box .

/* if num-results( "br-season" ) = 0 then
    do:
        message "Список  П У С Т !" skip view-as alert-box information .
        return no-apply .
    end.
  */
run waitfram-show in this-procedure ("Ждите...").
Line = fill( "-" , 140 ) .
/*
Это из-за того, что в QUERY br-season используется index reposition и,
как следствие, не работает GET first br-season  ( ошибка 3157 )
*/
StartRecid = recid (season).
run open-br. /* {&OPEN-QUERY-br-season} */
ii = 1 .
{ cmp/open-out.i stream ListStream }

FORM HEADER
    Line format "X(130)" SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
VIEW stream ListStream FRAME CliBottomFrame .
PUT stream ListStream space(20)
    "С П И С О К  С Е З О Н О В "
    format "X(100)" SKIP(2) .
FORM with frame List .
  DO WHILE available ub.season :
      DISPLAY stream ListStream
            sym1 ub.season.sea-code
            sym2 ub.season.sea-name
            sym3 date(ub.season.sea-month-1) @ ub.season.sea-month-1
            sym4 date(ub.season.sea-month-2) @ ub.season.sea-month-2
            sym5    with frame List .
      DOWN stream ListStream 1 with frame List .
      ii =  ii + 1 .
      if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
      run waitfram-show in this-procedure ( "Просмотрено строк : " + string( ii ) ) .
      GET next br-season .
  END.
PUT stream ListStream Line format "X(110)" SKIP.
HIDE stream ListStream FRAME CliBottomFrame .
output stream ListStream close .

define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = 0 .
run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .
  reposition br-season to recid StartRecid NO-ERROR .

run waitfram-hide in this-procedure . */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-type-tmp
ON CHOOSE OF b-sel IN FRAME d-type-tmp /* Выбор  */
DO:
    if ( available ub.season ) AND ( rid-list = "" ) then
        rid-list = string( recid( ub.season ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd d-type-tmp
ON CHOOSE OF b-upd IN FRAME d-type-tmp /* Изменить */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_season_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }

    if not available ub.season or v-log = false then  return no-apply.


        rr = recid( ub.season ).
        run ref/seasoni.w
            (parParentProc , {&update}, input-output rr ).
            
            
      
        run open-br. /*{&open-query-br-season}*/
        reposition br-season to recid rr .


 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj s-object
/*ON CHOOSE OF B-obj IN FRAME d-type-tmp /* BUTTON-select */
DO: 

  {&sel-obj}
  if v-sel-ok = 'yes' then do:
    v-sel-obj-list = "".
    for each userobjs_temp-user-obj  :
      v-sel-obj-list = v-sel-obj-list + "," + userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
    end.
    v-sel-obj-list = trim (v-sel-obj-list, ",").
    {&OPEN-QUERY-br-season-loc-obj}
    apply "entry" to br-season in frame {&frame-name}.
  end.
  

END.
*/

ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME d-type-tmp
DO:
  /* new trigger */

RADIO-SET-2:screen-value in frame {&FRAME-NAME} = "1".  
if RADIO-SET-1:screen-value = "1" then do:  DISABLE RADIO-SET-2 WITH FRAME  {&frame-name}. 
                                            run open-br.
                                       end.        
if RADIO-SET-1:screen-value = "2" then do: ENABLE RADIO-SET-2 WITH FRAME  {&frame-name}. 
                                           run open-br. 
                                                                     
                                       end.


END. 

ON VALUE-CHANGED OF RADIO-SET-2 IN FRAME d-type-tmp
DO:
  /* new trigger */
 
if RADIO-SET-2:screen-value = "1" then run open-br.
if RADIO-SET-2:screen-value = "2" then run open-br.  
    if RADIO-SET-2:screen-value = "3"  then run open-br-when-b-obj.                                     
END.


&Scoped-define BROWSE-NAME br-season
&Scoped-define SELF-NAME br-season
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-season d-type-tmp
ON DEFAULT-ACTION OF br-season IN FRAME d-type-tmp
DO:
  case yes:
      when  b-upd:sensitive THEN apply "CHOOSE":U to b-upd.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-season d-type-tmp
ON MOUSE-SELECT-DBLCLICK OF br-season IN FRAME d-type-tmp
DO:
    if lookup ( "b-sel", bttns ) > 0  then
        do:
            apply "choose" to b-sel in frame {&frame-name} .
            return no-apply .
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-season d-type-tmp
ON RETURN OF br-season IN FRAME d-type-tmp
DO:
    if Lookup( "b-sel",  bttns ) > 0 then
        do:
            apply "choose" to b-sel in frame {&frame-name} .
            return no-apply .
        end.
    else
        apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-type-tmp


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &browse-name="br-season" }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    run enable_ui.
    APPLY "VALUE-CHANGED":U TO br-season in frame {&frame-name}.
    ub.season.sea-name:RESIZABLE in  browse {&browse-name}   = true .

    if num-entries (rid-list) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp
        num-entries (rid-list) @ mark-num
        with frame {&frame-name}.
    run open-br.    
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-type-tmp  _DEFAULT-DISABLE
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
  HIDE FRAME d-type-tmp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-type-tmp
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
   
    RADIO-SET-1:screen-value in frame {&FRAME-NAME} = "1".
    RADIO-SET-2:screen-value in frame {&FRAME-NAME} = "1".  
    ENABLE
        br-season
        b-exit
        b-copy
        b-add WHEN  (lookup  ( "b-add" , bttns) > 0 )
        b-sel WHEN  (lookup  ( "b-sel" , bttns) > 0 )
        b-mark when (lookup  ( "b-mark", bttns) > 0 )
        b-upd WHEN  (lookup  ( "b-add" , bttns) > 0 )
        b-del WHEN  (lookup  ( "b-add" , bttns) > 0 )
        b-print
        b-hist
        b-help
        b-goods
        RADIO-SET-1

        WITH FRAME  {&frame-name}.
    {&OPEN-BROWSERS-IN-QUERY-d-season}
    if available ub.season then
        log-res  = br-season:select-focused-row( ) in frame {&frame-name}.

    run open-br.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
PROCEDURE open-br-when-b-obj :
  {&sel-obj}
  if v-sel-ok = 'yes' then do:
    v-sel-obj-list = "".
    for each userobjs_temp-user-obj  :
      v-sel-obj-list = v-sel-obj-list + "," + userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
    end.
    v-sel-obj-list = trim (v-sel-obj-list, ",").
    {&OPEN-QUERY-br-season-loc-obj}
    apply "entry" to br-season in frame {&frame-name}.
  end.
 
  
END PROCEDURE.  

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-br d-type-tmp
PROCEDURE open-br :

for each tt-season no-lock :
  delete tt-season.
end.

FOR EACH ub.season 
WHERE season.sea-month-1 <> 0 
AND season.sea-month-2 <>  0 :
  create tt-season.    
  tt-season.sea-code = season.sea-code.
  tt-season.db-num = season.db-num.
  tt-season.is-glob-sea = not can-find ( buf_season-attr where buf_season-attr.sea-code = ub.season.sea-code
                       and buf_season-attr.db-num = ub.season.db-num
                       and buf_season-attr.attr-code = {&seaattr-obj} ).
  find first ub.season-attr no-lock where season-attr.sea-code = season.sea-code
                                    and season-attr.db-num = season.db-num no-error.
  if available  season-attr then tt-season.attr-value = season-attr.attr-value.

END.

/*If RADIO-SET-1:screen-value IN FRAME {&FRAME-NAME} = "2" AND RADIO-SET-2:screen-value IN FRAME {&FRAME-NAME} = "3"
    then  enable B-obj with frame {&FRAME-NAME} .
    Else Disable B-obj with frame {&FRAME-NAME} .*/
    

if RADIO-SET-1:screen-value in frame {&FRAME-NAME} = "1" then {&OPEN-QUERY-br-season}

if RADIO-SET-1:screen-value in frame {&FRAME-NAME} = "2" 
  AND RADIO-SET-2:screen-value in frame {&FRAME-NAME} = "1"  then 
  {&OPEN-QUERY-br-season-loc}

  
if RADIO-SET-1:screen-value in frame {&FRAME-NAME} = "2" 
  AND RADIO-SET-2:screen-value in frame {&FRAME-NAME} = "2"  then 
  {&OPEN-QUERY-br-season-loc-cur} 

 if RADIO-SET-1:screen-value in frame {&FRAME-NAME} = "2" 
  AND RADIO-SET-2:screen-value in frame {&FRAME-NAME} = "3"  then 
  {&OPEN-QUERY-br-season-loc-obj} 

 



    
apply "entry" to br-season in frame {&frame-name}.    




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION date-func d-type-tmp
FUNCTION date-func RETURNS DATE
( input date-int as int) :
 define variable date-res as date no-undo.
   if  date-int <= 12 then return error.
   assign date-res = date (date-int) no-error.
 RETURN date-res.   /* Function return value. */

END FUNCTION.



procedure create-rep:
    define output parameter p-filename as character no-undo.
        
    define variable v-rls-file as character no-undo.
    define variable v-data-file as character no-undo.
    define variable v-xsl-file as character no-undo.
    define variable v-tmp-file as character no-undo.
    define variable hw as handle no-undo.
    define variable rep-out as class Rep-Out no-undo.
    
    assign
        v-xsl-file = search("exe/season.xsl.html")
        v-data-file = session:temp-directory + string(time) + ".xml"
        v-tmp-file = session:temp-directory + string(time) + ".html"
    .
    
    
    create sax-writer hw.
    hw:formatted = true.
    hw:set-output-destination ("file", v-data-file).
    
    
    run write-data(hw) .
    rep-out = new rep-out().
    v-rls-file = rep-out:xsl-transform(v-data-file, v-xsl-file).    
    os-delete value(v-tmp-file).
    os-copy value(v-rls-file) value(v-tmp-file).  
    os-delete value(v-rls-file).
    delete object rep-out.
  
    p-filename = v-tmp-file.
    
end.

procedure write-data:
    define input parameter hw as handle no-undo.
        hw:start-document ().
        hw:start-element ("rep").
        hw:start-element ("card").
        
        hw:insert-attribute ("time", if v-cur-time = ? then "" else v-cur-time ).
       
        for each tt-line no-lock:
        hw:start-element ("line").
        hw:insert-attribute ("sea-code",if tt-line.sea-code = ? then "" else string(tt-line.sea-code)). /**/
        hw:insert-attribute ("db-num",if tt-line.db-num = ? then "" else string(tt-line.db-num)). /**/
        hw:insert-attribute ("sea-name",if tt-line.sea-name = ? then "" else string(tt-line.sea-name)).
        hw:insert-attribute ("sea-month-1",if tt-line.sea-month-1 = ? then "" else string(date(tt-line.sea-month-1), "99/99/99")).
        hw:insert-attribute ("sea-month-2",if tt-line.sea-month-2 = ? then "" else string(date(tt-line.sea-month-2),"99/99/99")).
        hw:insert-attribute ("attr-value",if tt-line.attr-value = ? then "" else string(tt-line.attr-value)).
        hw:end-element ("line").
        end.        
       
       
       
        hw:end-element ("card").
        hw:end-element ("rep").
        
        
        
        hw:end-document ().

end.

procedure open-ie:
    define input parameter p-filename as character no-undo.
    
    define variable o-IE as com-handle no-undo.
   
    
    create "InternetExplorer.Application" o-IE.
    /* o-IE:menubar = false. */
    o-IE:addressbar = false.
    o-IE:Navigate(p-filename).
    o-IE:visible = true.
    release object o-IE.

end.


/* _UIB-CODE-BLOCK-END */