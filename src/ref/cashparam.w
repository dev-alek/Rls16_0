&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-c-p


/* Temp-Table and Buffer definitions                                    */
define buffer buf-code for Code.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-c-p 
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Код ОКЕИ код ККТ

Автор: Рукавишников Вадим
Дата создания: 21/04/21
Author: Rukavishnikov Vadim
Creation date: 21/04/21

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

{ref/codepar.i}

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Параметры группы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/tmprecid.i }

/* Local Variable Definitions ---                                       */

define variable log-res  as log   no-undo.
define variable ri       as recid no-undo.
define variable v-rid    as recid no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define buffer b2-code for code .

find first b2-code where b2-code.parent eq iparent
                     and b2-code.code   eq icode
  no-lock no-error.
define variable mProcEdit as character no-undo init "ref/cashparamu.w".
mProcEdit = if entry(3,iParent,{&delim-par}) eq "2" then "ref/cashparamuk.w" else "ref/cashparamu.w".
&Scoped-define EditWhere and v-db-num = 0
&Scoped-define SearchTable  buf-code  
&Scoped-define SearchWhere  ~{&SearchTable~}.parent eq b2-code.parent + {&delim-par} + b2-code.code

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-c-p
&Scoped-define BROWSE-NAME BROWSE-Code

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf-code

/* Definitions for BROWSE BROWSE-Code                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-Code buf-code.misc1 buf-code.CodeValue 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-Code 
&Scoped-define QUERY-STRING-BROWSE-Code FOR EACH {&SearchTable} ~
      WHERE {&SearchWhere} no-lock by buf-code.code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-Code OPEN QUERY BROWSE-Code FOR EACH {&SearchTable} ~
      where {&SearchWhere} NO-LOCK by buf-code.code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-Code buf-code
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-Code buf-code


/* Definitions for DIALOG-BOX f-okei3                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-c-p ~
    ~{&OPEN-QUERY-BROWSE-Code}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-hist b-upd b-add b-del b-print ~
b-hist b-help BROWSE-Code 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-name-doc Dialog-Frame
function getStatus returns character
   ( imisc as char, istatus as int   )  forward.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
define button b-add 
   label "До&бавить" 
   size 10 by 1.

define button b-del
   label "Удалить"
   size 10 by 1.

define button b-exit auto-go 
   label "&Выход ":L 
   size 10 by 1.

define button b-help 
   label "Помо&щь":L 
   size 3 by 1.

define button b-hist 
   label "Ис&тория" 
   size 3 by 1.

/*DEFINE BUTTON b-print*/
/*   LABEL "Пе&чать":L */
/*   SIZE 3 BY 1.      */

define button b-sel
   label "Вы&бор ":L 
   size 10 by 1.

define button b-upd 
   label "&Изменить":L 
   size 10 by 1.
     
define variable mSearch   as character       format "x(60)":U 
   label "Поиск" 
   view-as fill-in 
   size 60 by 1 no-undo.
        
define menu POPUP-MENU-b-hist 
    menu-item mHistOne     label "История этой записи"
    menu-item mHistChiled  label "История потомков"
.   
/* Query definitions                                                    */
&ANALYZE-SUSPEND
define query BROWSE-Code for 
   buf-code scrolling.
&ANALYZE-RESUME

/* Browse definitions                                                   */
define browse BROWSE-Code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-Code f-c-p _STRUCTURED
   query BROWSE-Code no-lock display
   isSelect(buffer buf-code:handle)     @ fselect 
   buf-code.code format "x(20)":U column-label "Название параметра"
   buf-code.CodeName format "x(40)":U column-label "Описание параметра"
/*   buf-code.code  FORMAT "x(10)":U WIDTH 32*/
   buf-code.CodeValue format "x(15)":U 
   buf-code.misc1 format "x(10)":U  column-label "Доп.Знач"
   getStatus (buf-code.misc1,buf-code.status_) column-label "Текущий статус" format "x(20)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100.6 BY 20 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

define frame f-c-p
   b-exit at row 1 col 1
   b-sel at row 1 col 13.6
   b-upd at row 1 col 24.8
   b-add at row 1 col 36.6 widget-id 2
   b-del at row 1 col 48.2 widget-id 4
/*   b-print AT ROW 1 COL 62.4*/
   b-hist at row 1 col 65.4
   b-help at row 1 col 68.4
   mSearch at row 2.5 col 1
   BROWSE-Code at row 4 col 1 widget-id 200
   space(0.00) skip(0.04)
   with view-as dialog-box keep-tab-order 
   side-labels no-underline three-d  scrollable 
   title "Параметры группы":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: buf-code B "?" ? ub Code
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-c-p
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-Code b-help f-c-p */
assign 
   frame f-c-p:SCROLLABLE = false.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-Code
/* Query rebuild information for BROWSE BROWSE-Code
     _TblList          = "buf-code"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "buf-code.parent eq b2-code.parent + {&delim-par} + b2-code.code


"
     _FldNameList[1]   > Temp-Tables.buf-code.code
"buf-code.code" "Код" "x(20)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.buf-code.CodeValue
"buf-code.CodeValue" ? ? "character" ? ? ? ? ? ? no ? no no "58" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-Code */
&ANALYZE-RESUME



/* ************************  Control Triggers  ************************ */
&Scoped-define SELF-NAME mHistOne
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mHistOne f-c-p
on choose of menu-item mHistOne /* История однойзаписи */
do:
   define variable v-rid-list as character no-undo.
   if avail buf-code then  
   do:
      run ref/ccode.w (
                buf-code.parent, 
                buf-code.code,
                parparentproc,
                0,
                "",
                0,
                "",
                "one",
                ?,
                "",
                "" ,
                v-cntxt-db-num,
                ?,
                input-output v-rid-list ) .
   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME mHistChiled
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mHistChiled f-c-p
on choose of menu-item mHistChiled /* Отключить запрос Token */
do:
   define variable v-rid-list as character no-undo.
   if avail buf-code then  
   do:
      run ref/ccode.w (
                buf-code.parent, 
                buf-code.code,
                parparentproc,
                0,
                "",
                0,
                "",
                "parentBeg",
                ?,
                "",
                "" ,
                v-cntxt-db-num,
                ?,
                input-output v-rid-list ) .
   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-c-p
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-c-p f-c-p
on go of frame f-c-p /* Значение ЕМЦ */
   do:
/*      p-rid = v-rid.*/
   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add f-c-p
on choose of b-add in frame f-c-p /* Добавить */
   do:
      define buffer b-code   for code.
      define buffer btt-code for code.
      define variable vRec as recid   no-undo.

      ri = ?.
      run value(mProcEdit) (
         input parparentproc
         , input {&add-def}
         , input b2-code.parent + {&delim-par} + b2-code.code
         , input-output ri).
      if ri <> ? then  
      do:

         {&OPEN-QUERY-BROWSE-Code}
         reposition BROWSE-Code to recid ri no-error.
         apply "ENTRY" to BROWSE-Code.

      end.

   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del f-c-p
on choose of b-del in frame f-c-p /* Удалить */
   do:
      define buffer b-code for code.
      define variable v-ok       as logical no-undo.
      define variable recid-code as integer no-undo .

      if not avail buf-code then return.
      recid-code = recid(buf-code) .
      message "Удалить запись :" buf-code.code  "?"
         view-as alert-box question
         buttons yes-no
         title "Удаление"
         update v-ok .
      if not v-ok then return no-apply.
      do on error undo, return
   on stop undo, return:
         find first b-code of buf-code exclusive-lock no-wait no-error.
         if locked b-code then
         do:
            message
               vss-workfile vss-revision vss-description skip
               "Запись занята"
               view-as alert-box error .
            undo, return.
         end.
         if not available b-code then
         do:
            message
               vss-workfile vss-revision vss-description skip
               "Не найдена запись"
               view-as alert-box error .
            undo, return.
         end.

         delete b-code.
         {&OPEN-QUERY-BROWSE-Code}
         apply "ENTRY" to BROWSE-Code.
      end.
   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-Code f-c-p
on mouse-select-dblclick of BROWSE-Code in frame f-c-p
or return of {&SELF-NAME} in frame {&FRAME-NAME}
do:
   if     iMode eq {&update}
          {&EditWhere}
      and available buf-code
   then
      apply "choose" to b-upd in frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel f-c-p
on choose of b-sel in frame f-c-p /* Выбор  */
   do:
      if not avail buf-code then return.
      setSelect(buffer buf-code:handle).
    {&BROWSE-NAME}:refresh ().                   
   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd f-c-p
on choose of b-upd in frame f-c-p /* Изменить */
   do:
      define buffer b-code   for code.
      define buffer btt-code for code.
      define variable vRec as recid no-undo.
   
      if not avail buf-code then return.
     
      find first b-code of buf-code no-lock no-error.
      if not avail b-code then 
      do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найден параметр"
            view-as alert-box error .
         return no-apply.
      end.
      vRec = recid(b-code).
      run value(mProcEdit) (
         input parparentproc
         , input {&update}
         , input b2-code.parent + {&delim-par} + b2-code.code
         , input-output vRec).
      {&OPEN-QUERY-BROWSE-Code}
      reposition BROWSE-Code to recid vRec no-error .
      apply "ENTRY" to BROWSE-Code.

   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME mSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mSearch f-c-p
on ENTER of mSearch in frame {&frame-name}
do:
   &Scoped-define SearchTable  buf-code-search
   define buffer {&SearchTable} for ub.code.
   assign
     msearch
   .
   define variable vRec as recid no-undo init ?.
   block-code:
   for each {&SearchTable} where ({&SearchWhere} and {&SearchTable}.code     begins msearch) 
                              or ({&SearchWhere} and {&SearchTable}.CodeName begins msearch)
   no-lock:
      vRec = recid({&SearchTable}).
      leave block-code.
   end.
   &Scoped-define SearchTable  {&INTERNAL-TABLES} 
   if vRec eq ?
   then do:
      message "Запись не найдена"
      view-as alert-box.
   end.
   else do:
      {&OPEN-QUERY-BROWSE-Code}
      reposition BROWSE-Code to recid vRec no-error .
      apply "ENTRY" to BROWSE-Code.
   end. 
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define BROWSE-NAME BROWSE-Code
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-c-p 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
   then frame {&FRAME-NAME}:PARENT = active-window.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
on window-close of frame {&FRAME-NAME}
   apply "END-ERROR":U to self.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
   if imode eq {&select}
   then
      run rid-rest no-error.
   { gbl/getcntxt.i get }
   { gbl/curdbnum.i v-db-num }
   run enable_UI in this-procedure .
   buf-Code.misc1         :visible in browse BROWSE-Code = available b2-code and num-entries (b2-code.parent,{&delim-par}) eq 1  .
   buf-Code.codename      :visible in browse BROWSE-Code = entry(3,iparent,{&delim-par}) ne "2"  .
   fselect                :visible in browse BROWSE-Code = imode eq {&select}.
   apply "ENTRY" to BROWSE-Code.
   
   wait-for go of frame {&FRAME-NAME} focus {&browse-name}.
   if imode eq {&select}
   then
      run rid-keep no-error.
end.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-c-p  _DEFAULT-DISABLE
procedure disable_UI :
   /*------------------------------------------------------------------------------
     Purpose:     DISABLE the User Interface
     Parameters:  <none>
     Notes:       Here we clean-up the user-interface by deleting
                  dynamic widgets we have created and/or hide 
                  frames.  This procedure is usually called when
                  we are ready to "clean-up" after running.
   ------------------------------------------------------------------------------*/
   /* Hide all frames. */
   hide frame f-c-p.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-c-p 
procedure enable_UI :
   /* --------------------------------------------------------------------
           Purpose:     ENABLE the User Interface
           Parameters:  <none>
           Notes:       Here we display/view/enable the widgets in the
                        user-interface.  In addition, OPEN all queries
                        associated with each FRAME and BROWSE.
                        These statements here are based on the "Other
                        Settings" section of the widget Property Sheets.
            -------------------------------------------------------------------- */
   enable
      mSearch
      BROWSE-Code
      b-exit
      b-sel
      when iMode eq {&select}
      b-add
      when iMode eq {&update} {&EditWhere}
      b-del
      when iMode eq {&update} {&EditWhere}
      b-upd
      when iMode eq {&update} {&EditWhere}
      b-help
      b-hist
      with frame {&frame-name}.
    
   b-hist:POPUP-MENU in frame {&frame-name} = menu POPUP-MENU-b-hist:HANDLE.
   b-hist:MENU-MOUSE = 1.  
   fselect                :visible in browse {&BROWSE-NAME} = imode eq {&select}.
   {&OPEN-BROWSERS-IN-QUERY-f-c-p}

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getStatus f-c-p 
function getStatus returns character
   ( imisc as char, istatus as int   ):
   define buffer code for ub.code.
&SCOPE sts-current "Обязательный"
&SCOPE sts-del  "Необязательный"
  
   if istatus eq {&bef-deleted-status-int}
   then
      return {&sts-del}.
   else 
      return {&sts-current}.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
