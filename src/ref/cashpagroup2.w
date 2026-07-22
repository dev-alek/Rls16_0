&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-c-p


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf-code-func FOR Code.
DEFINE BUFFER buf-code-param FOR Code.



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
{ cmp/str-glbl.i  }
{ ref/codepar.i}

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Код ОКЕИ код ККТ".
{ cmp/vssrevis.i }

{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/tmprecid.i }
&Scoped-define CODE_PARENT iparent + {&delim-par} + icode
&Scoped-define EditWhere and v-db-num = 0
&Scoped-define SearchTable1  buf-code-func  
&Scoped-define SearchWhere1  ~{&SearchTable1~}.parent = {&CODE_PARENT}
&Scoped-define SearchTable2  buf-code-param  
&Scoped-define SearchWhere2  ~{&SearchTable2~}.parent =  ~{&SearchTable1~}.parent + {&delim-par} + ~{&SearchTable1~}.code

/* Local Variable Definitions ---                                       */
define variable log-res     as log       no-undo.
define variable ri          as recid     no-undo.
define variable v-rid       as recid     no-undo .
define variable v-db-num like ub.db.db-num no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-c-p
&Scoped-define BROWSE-NAME cashpg

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf-code-func buf-code-param

/* Definitions for BROWSE cashpg                                      */
&Scoped-define FIELDS-IN-QUERY-cashpg buf-code-func.code ~
buf-code-func.misc1 buf-code-param.code buf-code-param.CodeValue ~
buf-code-param.status_ buf-code-param.CodeName 
&Scoped-define ENABLED-FIELDS-IN-QUERY-cashpg 
&Scoped-define QUERY-STRING-cashpg FOR EACH {&SearchTable1} ~
      WHERE {&SearchWhere1} NO-LOCK, ~
      EACH  {&SearchTable2} WHERE {&SearchWhere2} no-lock by getKeyName(buf-code-func.code) + " (" + buf-code-func.code + ")"  INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-cashpg OPEN QUERY cashpg FOR EACH {&SearchTable1} ~
      WHERE {&SearchWhere1} NO-LOCK, ~
      EACH  {&SearchTable2} WHERE {&SearchWhere2} NO-LOCK by getKeyName(buf-code-func.code) + " (" + buf-code-func.code + ")" INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-cashpg buf-code-func buf-code-param
&Scoped-define FIRST-TABLE-IN-QUERY-cashpg buf-code-func
&Scoped-define SECOND-TABLE-IN-QUERY-cashpg buf-code-param


/* Definitions for DIALOG-BOX f-c-p                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-c-p ~
    ~{&OPEN-QUERY-cashpg}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-hist b-add b-del b-upd b-help 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getKeyName f-c-p 
FUNCTION getKeytype RETURNS CHARACTER
   ( iCode as char) FORWARD.
FUNCTION getKeyName RETURNS CHARACTER
   ( iCode as char) FORWARD.
FUNCTION getStatus RETURNS CHARACTER
   ( imisc as char, istatus as int   )  FORWARD.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel  
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-upd 
     LABEL "&Изменить":L 
     SIZE 10 BY 1.
define button b-hist 
     label "Ис&тория":L 
     size 10 by 1.
     
define menu POPUP-MENU-b-hist 
    menu-item mHistOne     label "История этой записи"
    menu-item mHistChiled  label "История потомков"
.
define variable mSearch   as character       format "x(60)":U 
   label "Поиск" 
   view-as fill-in 
   size 60 by 1 no-undo.
   
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY cashpg FOR 
      buf-code-func, 
      buf-code-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE cashpg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS cashpg f-c-p _STRUCTURED
  QUERY cashpg NO-LOCK DISPLAY
      isSelect(buffer buf-code-param:handle)     @ fselect 
      getKeyName(buf-code-func.code) + " (" + buf-code-func.code + ")" @ buf-code-func.code COLUMN-LABEL "Наименование функции клавиши" FORMAT "x(30)":U
      getKeytype(buf-code-func.code) @ buf-code-func.misc1 COLUMN-LABEL "" FORMAT "x(3)":U
      buf-code-param.code COLUMN-LABEL "Дополнительное значение" FORMAT "x(23)":U
            WIDTH 23
      buf-code-param.CodeValue COLUMN-LABEL "Степень защиты" FORMAT "x(20)":U
            WIDTH 15
      getStatus (buf-code-param.misc1,buf-code-param.status_) COLUMN-LABEL "Cтатус" format "x(20)"
      buf-code-param.CodeName COLUMN-LABEL "Описание клавиши" FORMAT "x(60)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90 BY 20 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-c-p
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-del AT ROW 1 COL 34 WIDGET-ID 2
     b-upd AT ROW 1 COL 44.13
     b-hist AT ROW 1 COL 54.13
     b-help AT ROW 1 COL 71
     mSearch  AT ROW 2.5 col 1.2
     cashpg AT ROW 4 COL 1 WIDGET-ID 300
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки клавиатур":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: buf-code-func B "?" ? ub Code
      TABLE: buf-code-param B "?" ? ub Code
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-c-p
   FRAME-NAME                                                           */
/* BROWSE-TAB cashpg b-help f-c-p */
ASSIGN 
       FRAME f-c-p:SCROLLABLE       = FALSE.

/* SETTINGS FOR BROWSE cashpg IN FRAME f-c-p
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE cashpg
/* Query rebuild information for BROWSE cashpg
     _TblList          = "buf-code-func,buf-code-param WHERE buf-code-func  ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "buf-code-func.parent = {&CODE_PARENT}"
     _JoinCode[2]      = "buf-code-param.parent =  buf-code-func.parent + {&delim-par} + buf-code-func.code"
     _FldNameList[1]   > Temp-Tables.buf-code-func.code
"buf-code-func.code" "Наименование функции клавиши" "x(30)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.buf-code-func.misc1
"buf-code-func.misc1" "" "x(3)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.buf-code-param.code
"buf-code-param.code" "Дополнительное значение" "x(23)" "character" ? ? ? ? ? ? no ? no no "23" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.buf-code-param.CodeValue
"buf-code-param.CodeValue" "Степень защиты" ? "character" ? ? ? ? ? ? no ? no no "15" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = Temp-Tables.buf-code-param.status_
     _FldNameList[6]   = Temp-Tables.buf-code-param.CodeName
     _Query            is OPENED
*/  /* BROWSE cashpg */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */
&Scoped-define SELF-NAME mHistOne
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mHistOne f-c-p
on choose of menu-item mHistOne /* История однойзаписи */
do:
   define variable v-rid-list as character no-undo.
   if avail buf-code-param then  
   do:
      run ref/ccode.w (
                buf-code-param.parent, 
                buf-code-param.code,
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
   if avail buf-code-param then  
   do:
      run ref/ccode.w (
                buf-code-param.parent, 
                buf-code-param.code,
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
/*    p-rid = v-rid.*/
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add f-c-p
ON choose OF b-add IN FRAME f-c-p /* Добавить */
do:
   define variable vRec as recid no-undo.
 
   run ref/cashparamuk.w (
                            input parparentproc
                          , input {&add-def}
                          , input {&CODE_PARENT} + {&delim-par}
                          , input-output vRec).
   if vRec <> ? then  do:

         {&OPEN-QUERY-cashpg}
         define buffer bcode   for ub.code.
         define buffer bparent for ub.code.
         define variable vparent as character no-undo.
         define variable vcode   as character no-undo.
         find first bcode where recid(bcode) eq vRec no-lock no-error.
         assign
            vparent  = bcode.parent
            vcode    = entry(num-entries (vparent,{&delim-par}),vparent,{&delim-par})
            entry(num-entries (vparent,{&delim-par}),vparent,{&delim-par}) = ""
            vparent = substring (vparent,1,length (vparent) - 1)
         .
         find first bparent where bparent.parent eq vparent
                              and bparent.code eq vcode
         no-lock no-error.
         if available bparent
         then
            reposition cashpg to rowid rowid(bparent), rowid(bcode).
            apply "ENTRY" to cashpg.

   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del f-c-p
ON choose OF b-del IN FRAME f-c-p /* Удалить */
do:
   define buffer b1-code for code.
   if not avail buf-code-param or not avail buf-code-func then return.
   define variable v-ok as logical no-undo.

   message "Удалить запись параметра " getKeyName(buf-code-func.code) + " (" + buf-code-func.code + ")" " (" buf-code-param.code ")" "?"
      view-as alert-box question
      buttons yes-no
      title "Удаление"
      update v-ok .
   if not v-ok then return no-apply.
   do on error undo, return
   on stop undo, return:
      find first b1-code of buf-code-param exclusive-lock no-wait no-error.
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
      {&OPEN-QUERY-cashpg}
      apply "ENTRY" to cashpg.
   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel f-c-p
ON choose OF b-sel IN FRAME f-c-p /* Выбор  */
do:
   if not avail buf-code-param then return.
   setSelect(buffer buf-code-param:handle).
    {&BROWSE-NAME}:refresh (). 
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd f-c-p
ON choose OF b-upd IN FRAME f-c-p /* Изменить */
do:
   define variable vRec as recid no-undo.
   
   if not avail buf-code-param then return.
   define variable v-ok as logical no-undo.

   vRec = recid(buf-code-param).
   run ref/cashparamuk.w (
                            input parparentproc
                          , input {&update}
                          , input buf-code-param.parent
                          , input-output vRec).

         {&OPEN-QUERY-cashpg}
         define buffer bcode   for ub.code.
         define buffer bparent for ub.code.
         define variable vparent as character no-undo.
         define variable vcode   as character no-undo.
         find first bcode where recid(bcode) eq vRec no-lock no-error.
         assign
            vparent  = bcode.parent
            vcode    = entry(num-entries (vparent,{&delim-par}),vparent,{&delim-par})
            entry(num-entries (vparent,{&delim-par}),vparent,{&delim-par}) = ""
            vparent = substring (vparent,1,length (vparent) - 1)
         .
         find first bparent where bparent.parent eq vparent
                              and bparent.code eq vcode
         no-lock no-error.
         if available bparent
         then
            reposition cashpg to rowid rowid(bparent), rowid(bcode).
         apply "ENTRY" to cashpg.
      end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-Code f-c-p
on mouse-select-dblclick of cashpg in frame f-c-p
or return of {&SELF-NAME} in frame {&FRAME-NAME}
do:
   if iMode eq {&update} {&EditWhere}
      and available buf-code-param
   then
      apply "choose" to b-upd in frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mSearch f-c-p
on ENTER of mSearch in frame {&frame-name}
do:
   &Scoped-define SearchTable1  buf-code-search1
   define buffer {&SearchTable1} for ub.code.
   &Scoped-define SearchTable2  buf-code-search
   define buffer {&SearchTable2} for ub.code.
   assign
     msearch
   .
   define variable vRowid1 as rowid no-undo.
   define variable vRowid2 as rowid no-undo.
   
   block-code:
   for each {&SearchTable1} where {&SearchWhere1} no-lock
   ,first {&SearchTable2} where {&SearchWhere2} 
   no-lock:
      if               {&SearchTable1}.code  begins msearch 
         or getKeyName({&SearchTable1}.code) begins msearch
      then do:
         vRowid1 = rowid({&SearchTable1}).
         leave block-code.
      end.
      &Scoped-define SearchTable2  buf-code-search2
      define buffer {&SearchTable2} for ub.code.
   
      for each {&SearchTable2} where {&SearchWhere2} 
                                 and {&SearchTable2}.code begins msearch
      no-lock:
         vRowid1 = rowid({&SearchTable1}).
         vRowid2 = rowid({&SearchTable2}).
         leave block-code.
      end.
   end.
   &Scoped-define SearchTable  {&INTERNAL-TABLES} 
   if vRowid1 eq ?
   then do:
      message "Запись не найдена"
      view-as alert-box.
   end.
   else do:
      if vRowid2 eq ?
      then
         reposition cashpg to rowid vRowid1.
      else
         reposition cashpg to rowid vRowid1, vRowid2.
      apply "ENTRY" to cashpg.
   end. 
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME cashpg
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
    mSearch
    cashpg
    b-exit
/*    b-add2*/
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getKeytype f-c-p 
FUNCTION getKeytype RETURNS CHARACTER
   ( iCode as char):
   define buffer code for ub.code.
   find first code where code.parent eq "CashFunKey"
                     and code.code   eq iCode
   no-lock no-error.
   return if available code then code.misc1 else "".
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getStatus f-okei3 
FUNCTION getStatus RETURNS CHARACTER
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getStatus f-c-p 
FUNCTION getKeyName RETURNS CHARACTER
   ( iCode as char):
   define buffer code for ub.code.
   find first code where code.parent eq "CashFunKey"
                     and code.code   eq iCode
   no-lock no-error.
   return if available code then code.codename else "".
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


