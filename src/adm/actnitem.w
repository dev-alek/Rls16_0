&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список прав системы

Автор: Белоусов Илья Александрович
Дата создания: 11/16/07
Author: Ilia Belousov
Creation date: 11/16/07

Input:

Output:


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter       parparentproc  as widget-handle no-undo .
define input parameter  p-buttons            as character        no-undo.
define input-output parameter rid-list         as character        no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список прав системы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/color.i    }
{ gbl/getcntxt.i def }
{ gbl/onewin.i   }
{gbl/waitfram.i}
{ gbl/prn-lib.i "new shared" }

define temp-table temp_filter-fields no-undo
    field action-item-code as integer
    field record-on        as logical

    index pi is primary unique
        action-item-code
.

define temp-table temp_actnrole-user no-undo
    field user-id       as character
    field nik           as character
    field lastName      as character
    field firstName     as character
    field secondName    as character

    index pi is primary unique
        user-id
.

define temp-table temp_actnrole no-undo
    field action-role-name    as character
    field action-role-code    as integer
    field action-role-context as character

    index pi is primary unique
        action-role-code
.


define buffer br_action-item    for ub.action-item .
define buffer br_action-group   for ub.action-group .
define buffer buf_action-item-attr for ub.action-item-attr .
define buffer br_temp_filter-fields for temp_filter-fields .

define stream OutStr-html.

define stream OutStr-html.
define variable actr-print as character no-undo.
define variable v-context  as character no-undo column-label "Привязка"        format "x(15)":u  .
define variable v-brws-mark      as character no-undo COLUMN-LABEL "*"        FORMAT "X(1)":U  .
define variable v-on-gbl    as logical      no-undo.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-item

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES br_action-item br_action-group ~
br_temp_filter-fields

/* Definitions for BROWSE BROWSE-item                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-item (IF ( INDEX (rid-list, string( recid( br_action-item ) ) ) > 0 ) THEN ("*") ELSE (" ")) @ v-brws-mark br_action-item.action-item-name br_action-group.action-group-name br_action-item.action-item-id context(br_action-item.action-item-context) @ v-context br_action-item.action-item-description chek-action-gds-group(br_action-item.action-item-code)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-item br_action-item.action-item-description   
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-item br_action-item
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-item br_action-item
&Scoped-define SELF-NAME BROWSE-item
&Scoped-define OPEN-QUERY-BROWSE-item /* OPEN QUERY {&SELF-NAME} FOR EACH br_action-item NO-LOCK, ~
       FIRST br_action-group NO-LOCK, ~
       LAST br_temp_filter-fields NO-LOCK       INDEXED-REPOSITION. */ run local-open-query-item in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-item br_action-item br_action-group ~
br_temp_filter-fields
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-item br_action-item
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-item br_action-group
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-item br_temp_filter-fields


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-item}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-mark b-sel b-group b-user b-filter ~
v-filter b-help tb-filter cb-group rs-scope b-print BROWSE-item item-EDITOR 
&Scoped-Define DISPLAYED-OBJECTS v-filter tb-filter cb-group rs-scope ~
item-EDITOR 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD context Dialog-Frame 
FUNCTION context RETURNS CHARACTER
  ( INPUT p-context AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD context Dialog-Frame
FUNCTION chek-action-gds-group RETURNS character
 ( INPUT p-action-item-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-filter 
     LABEL "&ФПоиск" 
     SIZE 10 BY 1 TOOLTIP "Поиск с фильтрацией".

DEFINE BUTTON b-group 
     LABEL "&Группы" 
     SIZE 10 BY 1 TOOLTIP "Группы прав, включающие право".

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-mark 
     LABEL "*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-print 
     LABEL "Печать" 
     SIZE 9.5 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "&Выбор" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-user 
     LABEL "&Польз" 
     SIZE 10 BY 1 TOOLTIP "Список пользователей с выбранным правом".

DEFINE VARIABLE cb-group AS INTEGER FORMAT "->>>>9":U INITIAL 0 
     LABEL "Тема" 
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEM-PAIRS "0",1
     DROP-DOWN-LIST
     SIZE 25 BY 1 TOOLTIP "Тема, к которой относится право" NO-UNDO.

DEFINE VARIABLE item-EDITOR AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 97 BY 1.5 NO-UNDO.

DEFINE VARIABLE v-filter AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 31.38 BY 1 NO-UNDO.

DEFINE VARIABLE rs-scope AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", 1,
"Без привязки", 2,
"Фирма", 3,
"Объект", 4
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-item FOR 
      br_action-item, 
      br_action-group, 
      br_temp_filter-fields
      scrolling.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-item Dialog-Frame _FREEFORM
  QUERY BROWSE-item NO-LOCK DISPLAY
      (IF ( INDEX (rid-list, string( recid( br_action-item ) ) ) > 0 ) THEN ("*") ELSE (" ")) @ v-brws-mark
      br_action-item.action-item-name FORMAT "X(60)":U
      br_action-group.action-group-name FORMAT "X(20)":U COLUMN-LABEL "Тема"
      br_action-item.action-item-id FORMAT "X(55)":U
      context(br_action-item.action-item-context) @ v-context
      br_action-item.action-item-description FORMAT "X(60)":U
      chek-action-gds-group(br_action-item.action-item-code) FORMAT "X(7)":U COLUMN-LABEL "Тов.гр."
      enable  br_action-item.action-item-description
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11 WIDGET-ID 22
     b-sel AT ROW 1 COL 14
     b-group AT ROW 1 COL 24 WIDGET-ID 4
     b-user AT ROW 1 COL 34 WIDGET-ID 6
     b-filter AT ROW 1 COL 44 WIDGET-ID 8
     v-filter AT ROW 1 COL 52 COLON-ALIGNED NO-LABEL WIDGET-ID 10 NO-TAB-STOP 
     b-help AT ROW 1 COL 88.5
     b-print AT ROW 2.25 COL 88.5 WIDGET-ID 22
     tb-filter AT ROW 1.08 COL 86.13 WIDGET-ID 12
     cb-group AT ROW 2.25 COL 8.5 COLON-ALIGNED WIDGET-ID 20
     rs-scope AT ROW 2.25 COL 41 HELP
          "Привязка права" NO-LABEL WIDGET-ID 14
     b-print AT ROW 2.25 COL 88.5 WIDGET-ID 24
     BROWSE-item AT ROW 3.5 COL 1.5 WIDGET-ID 200
     item-EDITOR AT ROW 21.25 COL 1.5 NO-LABEL WIDGET-ID 2
     SPACE(0.50) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Список прав системы"
         DEFAULT-BUTTON b-sel CANCEL-BUTTON b-quit WIDGET-ID 100.


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
/* BROWSE-TAB BROWSE-item b-print Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-quit IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       b-quit:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       item-EDITOR:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       v-filter:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-item
/* Query rebuild information for BROWSE BROWSE-item
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH br_action-item NO-LOCK, FIRST br_action-group NO-LOCK, LAST br_temp_filter-fields NO-LOCK
      INDEXED-REPOSITION.
*/
run local-open-query-item in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ", FIRST"
     _OrdList          = "ub.action-item.action-head-code|yes,ub.action-item.action-group-code|yes,ub.action-item.action-item-name|yes"
     _Where[1]         = "action-item.action-head-code = {&action-head-code-main}"
     _JoinCode[2]      = "action-group.action-head-code = action-item.action-head-code
  AND action-group.action-group-code = action-item.action-group-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-item */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список прав системы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-filter Dialog-Frame
ON CHOOSE OF b-filter IN FRAME Dialog-Frame /* ФПоиск */
DO:
     define variable v-ok    as logical      no-undo.
      run adm/role-sf.w (
          input-output v-filter
        , output v-ok
    ) no-error.
   if error-status :error
   then do:
      message
               vss-workfile vss-revision vss-description
         skip(1)
         skip "?????? ????????? ???????."
         skip return-value
         skip trim( error-status :get-message( 1 ) )
               trim( error-status :get-message( 2 ) )
      view-as alert-box error.
      undo, return no-apply.
   end.
   IF NOT v-ok then do:
      RETURN NO-APPLY.
   end.

   if v-filter = "":U
   then do:
      assign
            tb-filter               = no
            tb-filter :sensitive    = no
      .
      assign
            v-filter :bgcolor   = GREY_COLOR
            b-filter :bgcolor = GREY_COLOR
      .
   end.
   else do:
      assign
            tb-filter = yes
            tb-filter :sensitive    = yes
      .
      assign
            v-filter :bgcolor = RED_COLOR
            b-filter :bgcolor = RED_COLOR
      .
   end.

   display
      v-filter
      tb-filter
   with frame {&frame-name}.

   { gbl/working.i }
   RUN enable_UI.
   RUN post_enable_UI.
   { gbl/stopwork.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-group Dialog-Frame
ON CHOOSE OF b-group IN FRAME Dialog-Frame /* Группы */
DO:
   if available br_action-item
   then do:
      run show-roles-for-item in this-procedure (
           input br_action-item.action-head-code
         , input br_action-item.action-item-code
         , input br_action-item.action-item-name
      ).
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
   define variable v-ok as logical no-undo .

   if not available br_action-item then do:
      return no-apply.
   end.

   { gbl/markstrn.i br_action-item rid-list }

   v-ok = {&browse-name}:select-next-row ().
   v-ok = {&browse-name}:refresh( )  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame




ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
   IF  available br_action-item
   AND rid-list = ""
   then DO:
      assign
         rid-list = string( recid( br_action-item ) )
      .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO: 
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + {&DF_Name} +  "actnitem1.html".
  
 run waitfram-show in this-procedure ( input "Ждите...").
  output stream OutStr-html to value(v-act-file) convert target 'UTF-8'/*no-convert*/.
        put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
                        
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .              
              
  put stream OutStr-html unformatted
    '<body>' skip
    '<table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">'skip
    '<thead>' skip
    .

        put stream OutStr-html unformatted
            '<tr class="set_columns">' skip                       
            '<td style="width:200px"></td>' skip
            '<td style="width:130px"></td>' skip
            '<td style="width:170px"></td>' skip
            '<td style="width:140px"></td>' skip
            '<td style="width:300px"></td>' skip
            '</tr>' skip
            .                    
                   
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="5" style="front-weight: bold; text-align: center;">Список прав</td>' skip
        '</tr>' skip
        '</thead>' skip
        '<tbody>' skip
        '<tr>' skip
        '<th>Имя права</th>' skip
        '<th>Тема</th>' skip
        '<th>Идентификатор права</th>' skip 
        '<th>Привязка</th>' skip
        '<th>Описания права</th>' skip
        '</tr>'
        .
        
                get first BROWSE-item.
                do while available  br_action-item:
                
     put stream OutStr-html unformatted

     '<tr style="height: 60px;">' skip
       '<td text_wrap="true">' + br_action-item.action-item-name + '</td>' skip
       '<td text_wrap="true">' + br_action-group.action-group-name + '</td>' skip
       '<td text_wrap="true">' + br_action-item.action-item-id + '</td>' skip
       '<td text_wrap="true">' + context(br_action-item.action-item-context) + '</td>' skip
       '<td text_wrap="true">' + br_action-item.action-item-description + '</td>' skip
      '</tr>' skip
      .       
     get next BROWSE-item.

     end.
       put stream OutStr-html unformatted
    '</tbody>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
                run waitfram-hide in this-procedure. 
                
    output stream OutStr-html close.   
    run prn-lib-reportviewer-report-name in this-procedure (
                                                          input parParentProc
                                                          ,input v-act-file
                                                          ).
        
END.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-user
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-user Dialog-Frame
ON CHOOSE OF b-user IN FRAME Dialog-Frame /* Польз */
DO:
   if available br_action-item
   then do:
      run show-users-for-item in this-procedure (
           input v-cntxt-db-num
         , input br_action-item.action-head-code
         , input br_action-item.action-item-code
         , input br_action-item.action-item-name
      ).
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-item
&Scoped-define SELF-NAME BROWSE-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-item Dialog-Frame
ON MOUSE-SELECT-CLICK OF BROWSE-item IN FRAME Dialog-Frame
DO:
  /*
  message
   "X"  BROWSE-item:current-column:label
   skip BROWSE-item:current-column:name
   skip BROWSE-item:current-column:table
   skip BROWSE-item:current-column:DATA-TYPe
   skip BROWSE-item:current-column:format
   skip
  view-as alert-box information.
  assign
   BROWSE-item:current-column:SORT-ASCENDING = YES
   BROWSE-item:current-column:SORT-NUMBER = 1
  .
  */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-item Dialog-Frame
ON VALUE-CHANGED OF BROWSE-item IN FRAME Dialog-Frame
DO:
    if available br_action-item then do:
    assign
        item-editor = br_action-item.action-item-description
    .
    display
      item-editor
    with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-group Dialog-Frame
ON VALUE-CHANGED OF cb-group IN FRAME Dialog-Frame /* Тема */
DO:
    assign
        cb-group
    .
    RUN enable_UI.
    RUN post_enable_UI.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-scope
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-scope Dialog-Frame
ON VALUE-CHANGED OF rs-scope IN FRAME Dialog-Frame
DO:
    assign
        rs-scope
    .
    assign
        v-context = entry( rs-scope, substitute( "&1,&2,&3,&4",'All', {&cntxt-global}, {&cntxt-firm}, {&cntxt-object} ) )
    .
    RUN enable_UI.
    RUN post_enable_UI.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-filter Dialog-Frame
ON VALUE-CHANGED OF tb-filter IN FRAME Dialog-Frame
DO:
     assign
      tb-filter
   .
   if tb-filter = yes
   then do:
      assign
         v-filter :bgcolor = RED_COLOR
         b-filter :bgcolor = RED_COLOR
      .
   end.
   else do:
      assign
         v-filter :bgcolor = GREY_COLOR
         b-filter :bgcolor = GREY_COLOR
      .
   end.
   RUN enable_UI.
   RUN post_enable_UI.

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

   define buffer buf_action-group for ub.action-group.

   { gbl/getcntxt.i get }
   { gbl/app_help.i }
   
   { adm/actn-gbl.i
    v-on-gbl
    no-error
   }
    assign
        cb-group :list-item-pairs = substitute( "<Все>,&1", -1 )
    .
    for each buf_action-group no-lock
    on error undo, return error
    :
        assign
            cb-group :list-item-pairs = substitute( "&1,&2,&3", cb-group :list-item-pairs, buf_action-group.action-group-name, buf_action-group.action-group-code)
        .
    end.        /* for each buf_group */
    assign
        cb-group = -1
    .

  RUN enable_UI.
  RUN post_enable_UI.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-filter-mark Dialog-Frame 
PROCEDURE assign-filter-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-name-filter    as character        no-undo.

define buffer buf_action-group         for ub.action-group .
define buffer buf_action-item          for ub.action-item .
define buffer buf_temp_filter-fields      for temp_filter-fields .

do
on error undo, return error
:
    FOR EACH  buf_action-item
        WHERE buf_action-item.action-head-code = {&action-head-code-main}
        NO-LOCK
        ,
        FIRST buf_action-group
        WHERE (buf_action-group.action-head-code  = buf_action-item.action-head-code
          AND buf_action-group.action-group-code = buf_action-item.action-group-code)

           OR (buf_action-group.action-head-code  = buf_action-item.action-head-code
          AND buf_action-group.action-group-id   = buf_action-item.action-group-id)
        NO-LOCK
        :

      find first buf_temp_filter-fields
            where buf_temp_filter-fields.action-item-code = buf_action-item.action-item-code
      no-error.
      if not available buf_temp_filter-fields
      then do:
         create buf_temp_filter-fields.
         assign
               buf_temp_filter-fields.action-item-code = buf_action-item.action-item-code
               buf_temp_filter-fields.record-on = no
         .

      end.

      IF ( p-name-filter = "":U )
      OR index( buf_action-item.action-item-name, p-name-filter ) <> 0
      or index( buf_action-item.action-item-description, p-name-filter ) <> 0
      or index( buf_action-group.action-group-name, p-name-filter ) <> 0
      or index( buf_action-item.action-item-id, p-name-filter ) <> 0
      then do:
         assign
            buf_temp_filter-fields.record-on = yes
         .
      end.
      else do:
         assign
            buf_temp_filter-fields.record-on = NO
         .
      end.
    end. /* FOR EACH  buf_action-item */
end. /* do on error */
END PROCEDURE. /* assign-filter-mark */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY v-filter tb-filter cb-group rs-scope item-EDITOR 
      WITH FRAME Dialog-Frame.
  ENABLE b-mark b-sel b-group b-user b-filter v-filter b-help tb-filter 
         cb-group rs-scope b-print BROWSE-item item-EDITOR 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-item Dialog-Frame 
PROCEDURE local-open-query-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return
:
   if tb-filter = yes then do:
      run assign-filter-mark IN THIS-PROCEDURE
                     ( input v-filter
                     ) .
   end.
   else do:
      run assign-filter-mark IN THIS-PROCEDURE
                     ( input ""
                     ) .
   end.

   case v-context:
   WHEN {&cntxt-global} OR
   WHEN {&cntxt-firm}   OR
   WHEN {&cntxt-object} THEN DO:
      OPEN QUERY BROWSE-item
      FOR EACH br_action-item
         WHERE br_action-item.action-head-code = {&action-head-code-main}
         AND br_action-item.action-item-context = v-context
         NO-LOCK
         ,
         FIRST br_action-group
         WHERE (br_action-group.action-head-code  = br_action-item.action-head-code
            AND br_action-group.action-group-code  = br_action-item.action-group-code)
            OR (br_action-group.action-head-code   = br_action-item.action-head-code
            AND br_action-group.action-group-id    = br_action-item.action-group-id)
            AND (br_action-group.action-group-code = cb-group
             OR cb-group = -1)
         NO-LOCK
         ,
         FIRST br_temp_filter-fields
         WHERE br_temp_filter-fields.action-item-code   = br_action-item.action-item-code
            and br_temp_filter-fields.record-on          = YES
         NO-LOCK
            BY br_action-item.action-head-code
            BY br_action-item.action-group-code
            BY br_action-item.action-item-name
            INDEXED-REPOSITION
            .
   END.
   OTHERWISE DO:
      OPEN QUERY BROWSE-item
      FOR EACH br_action-item
         WHERE br_action-item.action-head-code = {&action-head-code-main}
         NO-LOCK
         ,
         FIRST br_action-group
         WHERE (br_action-group.action-head-code  = br_action-item.action-head-code
            AND br_action-group.action-group-code  = br_action-item.action-group-code)
            OR (br_action-group.action-head-code   = br_action-item.action-head-code
            AND br_action-group.action-group-id    = br_action-item.action-group-id)
            AND (br_action-group.action-group-code = cb-group
             OR cb-group = -1)
         NO-LOCK
         ,
         FIRST br_temp_filter-fields
         WHERE br_temp_filter-fields.action-item-code   = br_action-item.action-item-code
            and br_temp_filter-fields.record-on          = YES
         NO-LOCK
            BY br_action-item.action-head-code
            BY br_action-item.action-group-code
            BY br_action-item.action-item-name
            INDEXED-REPOSITION
            .
   END.
   end case.

   if available br_action-item then do:
      assign
         item-editor = br_action-item.action-item-description
      .
      display
         item-editor
      with frame {&frame-name}.
   end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mark-string Dialog-Frame 
PROCEDURE mark-string :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:

end.  /* do on error */
END PROCEDURE. /* mark-string */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_UI Dialog-Frame 
PROCEDURE post_enable_UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    disable
        b-sel
        b-mark
        b-quit
    WITH FRAME  {&frame-name}.

    IF ((lookup( "b-sel" , p-buttons) > 0 ) OR (lookup( "b-mark", p-buttons) > 0 ))
    THEN b-quit:LABEL IN FRAME  {&frame-name}  = "&Отмена".
    ELSE b-quit:LABEL IN FRAME  {&frame-name}  = "&Выход".

    ENABLE
        b-quit
        b-sel  WHEN  ((lookup( "b-sel" , p-buttons) > 0 ) OR (lookup( "b-mark", p-buttons) > 0 ))
        b-mark when  (lookup( "b-mark", p-buttons) > 0 )
    WITH FRAME  {&frame-name}.

    IF ((lookup( "b-sel" , p-buttons) > 0 ) OR (lookup( "b-mark", p-buttons) > 0 ))
    THEN b-quit:LABEL IN FRAME  {&frame-name}  = "&Отмена".
    ELSE b-quit:LABEL IN FRAME  {&frame-name}  = "&Выход".

end.  /* do on error */
END PROCEDURE. /* post_enable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-roles-for-item Dialog-Frame 
PROCEDURE show-roles-for-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-action-head-code   as integer          no-undo.
define input parameter p-action-item-code   as integer          no-undo.
define input parameter p-action-item-name   as character        no-undo.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.

    define buffer buf_action-role-item          for ub.action-role-item.
    define buffer buf_action-role               for ub.action-role.
    define buffer buf_temp_actnrole             for temp_actnrole.

do
for buf_action-role-item
  , buf_action-role
on error undo, return error
:
    run onewin_clear in this-procedure.

    empty temp-table buf_temp_actnrole.

    for each buf_action-role-item
       where buf_action-role-item.action-head-code = p-action-head-code
         and buf_action-role-item.action-item-code = p-action-item-code
         no-lock
         ,
         FIRST buf_action-role
         where buf_action-role.action-head-code    = buf_action-role-item.action-head-code
           and buf_action-role.action-role-code    = buf_action-role-item.action-role-code
         no-lock
         on error undo, return error
         :

         find first buf_temp_actnrole
               where buf_temp_actnrole.action-role-code = buf_action-role.action-role-code
         no-error.
         if not available buf_temp_actnrole
         then do:
               create buf_temp_actnrole.
               assign
                  buf_temp_actnrole.action-role-code = buf_action-role.action-role-code
                  buf_temp_actnrole.action-role-Name   = buf_action-role.action-role-name
                  buf_temp_actnrole.action-role-context = buf_action-role.action-role-context
               .
         end.
    end.        /* for each buf_action-role-item */
    for each buf_temp_actnrole
    on error undo, return error
    :
        run onewin_add-item in this-procedure (
              input buf_temp_actnrole.action-role-code
            , buf_temp_actnrole.action-role-name
            , context(buf_temp_actnrole.action-role-context)
            , input no
        ).
    end.        /* for each buf_temp_actnrole-user */
    run gbl/onewin.w (
          input parparentproc
        , input 0
        , input substitute( "Список групп для права < &1 >", p-action-item-name )
        , input "":U
        , input "&Тест"
        , input table temp_onewin_items
        , output table temp_onewin_itemsSelected
        , output v-cur-ext-key
        , output v-accepted
    ).
end.
END PROCEDURE. /* show-roles-for-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-users-for-item Dialog-Frame 
PROCEDURE show-users-for-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-db-num             as integer          no-undo.
define input parameter p-action-head-code   as integer          no-undo.
define input parameter p-action-item-code   as integer          no-undo.
define input parameter p-action-item-name   as character        no-undo.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.

    define buffer buf_action-role-item          for ub.action-role-item.
    define buffer buf_user-login-action-role    for ub.user-login-action-role.
    define buffer buf_temp_actnrole-user        for temp_actnrole-user.
    define buffer buf_user-account              for ub.user-account.
    define buffer buf_user-login                for ub.user-login.
do
for buf_action-role-item
  , buf_user-login-action-role
  , buf_temp_actnrole-user
  , buf_user-account
  , buf_user-login
on error undo, return error
:
    run onewin_clear in this-procedure.

    empty temp-table buf_temp_actnrole-user.

    for each buf_action-role-item no-lock
       where buf_action-role-item.db-num           = (if v-on-gbl then 0 else p-db-num)
         and buf_action-role-item.action-head-code = p-action-head-code
         and buf_action-role-item.action-item-code = p-action-item-code
    on error undo, return error
    :
        for each buf_user-login-action-role no-lock
           where buf_user-login-action-role.db-num              = p-db-num
             and buf_user-login-action-role.action-head-code    = buf_action-role-item.action-head-code
             and buf_user-login-action-role.action-role-code    = buf_action-role-item.action-role-code
        use-index ie03
        on error undo, return error
        :
            find first buf_temp_actnrole-user
                 where buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
            no-error.
            if not available buf_temp_actnrole-user
            then do:
                create buf_temp_actnrole-user.
                assign
                    buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
                .
                find first buf_user-account no-lock
                    where buf_user-account.user-id = buf_user-login-action-role.user-id
                .
                assign
                    buf_temp_actnrole-user.nik        = buf_user-account.nik
                    buf_temp_actnrole-user.lastName   = buf_user-account.last-name
                    buf_temp_actnrole-user.firstName  = buf_user-account.first-name
                    buf_temp_actnrole-user.secondName = buf_user-account.second-name
                .
            end.
        end.        /* for each buf_user-login-action-role */
    end.        /* for each buf_action-role-item */
    for each buf_temp_actnrole-user
    on error undo, return error
    :
        run onewin_add-item in this-procedure (
              input buf_temp_actnrole-user.user-id
            , input ( if buf_temp_actnrole-user.nik = "":U
                      then buf_temp_actnrole-user.lastName else buf_temp_actnrole-user.nik )
            , input substitute( "&1 &2 &3 (&4)"
                    , buf_temp_actnrole-user.lastName
                    , buf_temp_actnrole-user.firstName
                    , buf_temp_actnrole-user.secondName
                    , buf_temp_actnrole-user.user-id )
            , input no
        ).
    end.        /* for each buf_temp_actnrole-user */
    run gbl/onewin.w (
          input parparentproc
        , input 0
        , input substitute( "Список пользователей для права < &1 >", p-action-item-name )
        , input "":U
        , input "&Тест"
        , input table temp_onewin_items
        , output table temp_onewin_itemsSelected
        , output v-cur-ext-key
        , output v-accepted
    ).
end.
END PROCEDURE. /* show-users-for-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION context Dialog-Frame 
FUNCTION context RETURNS CHARACTER
  ( INPUT p-context AS character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  CASE p-context:
  WHEN  {&cntxt-global} THEN DO:
              RETURN "Без привязки".
  END.
  WHEN  {&cntxt-firm} THEN DO:
              RETURN "Фирма".
  END.
  WHEN  {&cntxt-object} THEN DO:
              RETURN "Объект".
  END.
  OTHERWISE DO:
              RETURN "":U.
  END.
  end case.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD context Dialog-Frame
FUNCTION chek-action-gds-group RETURNS character
   ( INPUT p-action-item-code AS integer ):

find first ub.global-state no-lock .

if can-find ( first ub.global-state-attr no-lock
     where ub.global-state-attr.gls-id = ub.global-state.gls-id
       and ub.global-state-attr.attr-code = "action-gds-groups"
        and logical(ub.global-state-attr.attr-value ) = true)
then do :
  find first buf_action-item-attr no-lock
       where buf_action-item-attr.attr-code = "Linking"
         and buf_action-item-attr.action-item-code = br_action-item.action-item-code no-error.
  if available buf_action-item-attr then do :
    if lookup( buf_action-item-attr.attr-value , "gds-grp" ) <> 0
    then do :
      return "   +   " .
    end.
  end.
  else do :
    return "   -   " .
  end.
end.
else do :
  return "   -   " .
end.


END FUNCTION.
