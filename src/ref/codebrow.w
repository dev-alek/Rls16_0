&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-c-p

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf-code FOR Code.



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

{ ref/codepar.i}

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Код ОКЕИ код ККТ".
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
{ ref/code-func.i }
{gbl/tmprecid.i }
  
&Scoped-define CODE_PARENT mParent
&Scoped-define EditWhere and v-db-num = 0
&Scoped-define SearchTable  code  
&Scoped-define SearchWhere  ~{&SearchTable~}.parent = {&CODE_PARENT} 
/* Local Variable Definitions ---                                       */
define variable log-res     as log       no-undo.
define variable ri          as recid     no-undo.
define variable v-rid       as recid     no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable MaxLevel as integer no-undo.
function endLevel returns logical():

   return MaxLevel ne 0 and num-entries(iparent,{&delim-par})  eq  MaxLevel  .
end.
define variable startlevel as integer no-undo.
startlevel = num-entries(iparent,{&delim-par}) .
define variable mParent as character no-undo.
if    iparent eq ""
   or iparent eq ?
then
   mparent = icode.
else
   mparent = iparent + {&delim-par} + icode.  
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
&Scoped-define INTERNAL-TABLES Code

/* Definitions for BROWSE BROWSE-Code                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-Code Code.code Code.CodeName 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-Code 
&Scoped-define QUERY-STRING-BROWSE-Code FOR EACH {&SearchTable} ~
      where {&SearchWhere} NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-codebrow OPEN QUERY BROWSE-Code FOR EACH {&SearchTable} ~
      where {&SearchWhere} NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-Code Code
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-Code Code


/* Definitions for DIALOG-BOX f-c-p                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-c-p ~
    ~{&OPEN-QUERY-codebrow}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-hist b-add b-del b-upd b-help b-chiled 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-chiled 
     LABEL "&Открыть" 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-upd 
     LABEL "&Изменить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-look 
     LABEL "&Просмотр":L 
     SIZE 10 BY 1.
DEFINE BUTTON b-hist 
   LABEL "Ис&тория" 
   SIZE 3 BY 1.

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
DEFINE QUERY BROWSE-Code FOR 
      Code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-Code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-Code f-c-p _STRUCTURED
  QUERY BROWSE-Code NO-LOCK DISPLAY
      isSelect(buffer code:handle) @ fSelect
      Code.code FORMAT "x(20)":U
      Code.CodeName FORMAT "x(60)":U WIDTH 54.13
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100 BY 25 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */
 
DEFINE FRAME f-c-p
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-del AT ROW 1 COL 34 WIDGET-ID 2
     b-upd AT ROW 1 COL 44
     b-look AT ROW 1 COL 54
     b-help AT ROW 1 COL 81
     b-chiled AT ROW 1 COL 64 WIDGET-ID 10
     b-hist  AT ROW 1 COL 74
     mSearch AT ROW 2.5 col 1.2
     BROWSE-Code AT ROW 4 COL 1 WIDGET-ID 300
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE iTitle.


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
/* BROWSE-TAB BROWSE-Code b-chiled f-c-p */
ASSIGN 
       FRAME f-c-p:SCROLLABLE       = FALSE.

/* SETTINGS FOR BROWSE BROWSE-Code IN FRAME f-c-p
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-Code
/* Query rebuild information for BROWSE BROWSE-Code
     _TblList          = "ub.Code"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "Code.parent = {&CODE_PARENT}"
     _FldNameList[1]   = ub.Code.code
     _FldNameList[2]   > ub.Code.CodeName
"Code.CodeName" ? ? "character" ? ? ? ? ? ? no ? no no "54.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-Code */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */
&Scoped-define SELF-NAME mHistOne
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mHistOne f-c-p
on choose of menu-item mHistOne /* История однойзаписи */
do:
   define variable v-rid-list as character no-undo.
   if avail Code then  
   do:
      run ref/ccode.w (
                Code.parent, 
                Code.code,
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
   if avail Code then  
   do:
      run ref/ccode.w (
                Code.parent, 
                Code.code,
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
ON go OF FRAME f-c-p /* Группы параметров */
do:
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit f-c-p
ON choose OF b-exit IN FRAME f-c-p /* Добавить */
do:
   define variable vView as logical no-undo.
   run PrevLevel(output vView).
   if vView
   then do:
      {&OPEN-QUERY-codebrow}
      apply "ENTRY" to BROWSE-Code.
   end.
   else
      APPLY "GO" TO FRAME {&FRAME-NAME}.
   return.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add f-c-p
ON choose OF b-add IN FRAME f-c-p /* Добавить */
do:
   
   
   define buffer b-code for code.
   define variable vRec as recid no-undo.
   define variable v-ok as logical no-undo.

   define variable vProcNextLevel as character no-undo init "ref/codefrm.w".
   define variable vparent as character no-undo.
   define variable vcode as character no-undo.
   if available code
   then assign
      vparent = Code.parent
      vcode   = code.code
      .
   else  assign
         vparent = mparent
         vcode    = entry(num-entries(vparent,{&delim-par}),vparent,{&delim-par})
         entry(num-entries(vparent,{&delim-par}),vparent,{&delim-par}) = ""
         vparent = substring (vparent,1,length(vparent) - 1)
   no-error.
   find first b-code where b-code.parent eq vParent
                       and b-code.code   eq vcode
   no-lock no-error.
   vProcNextLevel = getproceditEx(buffer b-code:handle,vProcNextLevel).
   run value(vProcNextLevel) (
                            input parparentproc
                          , input {&add-def}
                          , input b-code.parent
                          , input-output ri).
   if ri <> ? then  do:

            {&OPEN-QUERY-codebrow}
            reposition BROWSE-Code to recid ri.
            apply "ENTRY" to BROWSE-Code.

   end.
   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-look
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-look f-c-p
ON choose OF b-look IN FRAME f-c-p /* Добавить */
do:
   
   
   define variable vRec as recid no-undo.
   define variable v-ok as logical no-undo.

   define variable vProcNextLevel as character no-undo init "ref/codefrm.w".
   
   if not avail code then return.

   vRec = recid(code).
   vProcNextLevel = getproceditEx(buffer code:handle,vProcNextLevel).
   run value(vProcNextLevel)
   (
                            input parparentproc
                          , input {&lookup}
                          , input {&CODE_PARENT}
                          , input-output vRec).
   if ri <> ? then  do:

            {&OPEN-QUERY-codebrow}
            reposition BROWSE-Code to recid ri.
            apply "ENTRY" to BROWSE-Code.

   end.
   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-chiled
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chiled f-c-p
ON choose OF b-chiled IN FRAME f-c-p /* Параметры */
do:
  run nextlevel.
   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-Code f-c-p
ON MOUSE-SELECT-DBLCLICK OF BROWSE-Code IN FRAME f-c-p
OR RETURN OF {&SELF-NAME} IN FRAME {&FRAME-NAME}
DO:
  apply "choose" to b-chiled in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del f-c-p
ON choose OF b-del IN FRAME f-c-p /* Удалить */
do:
   define buffer b1-code for code.
   if not avail code then return.
define variable v-ok as logical no-undo.
   message "Удалить запись группу параметров " code.code " (" code.codename ")?"
      view-as alert-box question
      buttons yes-no
      title "Удаление"
      update v-ok .
   if not v-ok then return no-apply.
   do on error undo, return
   on stop undo, return:
      find first b1-code of code exclusive-lock no-wait no-error.
      if locked b1-code then do:
         message
            vss-workfile vss-revision vss-description skip
            "Группа занята"
         view-as alert-box error .
         undo, return.
      end.
      if not available b1-code then do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись группы"
         view-as alert-box error .
         undo, return.
      end.
      delete b1-code.
      {&OPEN-QUERY-codebrow}
      apply "ENTRY" to BROWSE-Code.
   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel f-c-p
ON choose OF b-sel IN FRAME f-c-p /* Выбор  */
do:
   if not avail code then return.
   setSelect(buffer code:handle).
   {&BROWSE-NAME}:refresh ().
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd f-c-p
ON choose OF b-upd IN FRAME f-c-p /* Изменить */
do:
   define variable vRec as recid no-undo.
   
   if not avail code then return.
   define variable v-ok as logical no-undo.

   vRec = recid(code).
   define variable vProcNextLevel as character no-undo init "ref/codefrm.w".
         
   vProcNextLevel = getproceditEx(buffer code:handle,vProcNextLevel).
   run value(vProcNextLevel)
   (
                            input parparentproc
                          , input {&update}
                          , input Code.parent
                          , input-output vRec).

         {&OPEN-QUERY-codebrow}
         reposition BROWSE-Code to recid vRec.
         apply "ENTRY" to BROWSE-Code.
      end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME mSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mSearch f-c-p
on ENTER of mSearch in frame {&frame-name}
do:
   &Scoped-define SearchTable buf-code-search
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
  HIDE FRAME f-c-p.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-c-p 
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
  enable
    msearch
    BROWSE-Code
    b-exit
    b-chiled
    b-sel
    when imode eq {&select}
    b-add
    when imode eq {&update} {&edit-where}  
    
    b-del
    when imode eq {&update} {&edit-where}
    b-upd
    when imode eq {&update} {&edit-where}   
    b-help
    b-look
    b-hist
    with frame {&frame-name}.
   b-hist:POPUP-MENU in frame {&frame-name} = menu POPUP-MENU-b-hist:HANDLE.
   b-hist:MENU-MOUSE = 1.  
  fselect                :visible in browse {&BROWSE-NAME} = imode eq {&select}.
  {&OPEN-BROWSERS-IN-QUERY-f-c-p}

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE NextLevel  
PROCEDURE NextLevel:
   if available  code 
   then do:
      if code.procview ne ""
      then do:
         if imode eq {&select}
         then
            run rid-keep no-error.
         run value( code.procview) (  input parparentproc
                                    , input imode
                                    , input Code.parent
                                    , input Code.code
                                    , input Code.CodeName)no-error.
         if error-status:error
         then
            message "Ошибка при выполнение процедуры " code.procview skip
                    error-status:get-message (1) skip
                    return-value
            view-as alert-box.
         if imode eq {&select}
         then
            run rid-rest no-error.
      end.
      else do:
         if not endLevel ()
         then
            assign
               mparent  = code.parent + {&delim-par} + code.code
               mparent  = left-trim(mparent,{&delim-par})
            .
         {&OPEN-QUERY-codebrow}
         
      end.
   end.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrevLevel  
PROCEDURE PrevLevel:
   define output parameter oView as logical no-undo.
   if mparent ne ""
   then do:
      assign
         entry(num-entries(mparent,{&delim-par}),mparent,{&delim-par}) = ""
         mparent = substring (mparent,1,length(mParent) - 1)
      no-error.
         
      if mparent ne "" and num-entries(mparent,{&delim-par}) le  startlevel
      then do:
         if imode eq {&select}
         then do:
            for each tmprecid:
               delete tmprecid.
            end.  
            run gbl/rid-keep.p (input table tmprecid) no-error.
         end.
         oView = no.
         return.
      end.
      else do:   
            {&OPEN-QUERY-codebrow}
            oView = yes.
            return.
         end.
      end.
      
   end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

