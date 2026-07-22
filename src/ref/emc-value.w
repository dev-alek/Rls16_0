&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-okei3


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf-code FOR Code.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-okei3 
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

{ ref/codepar.i }

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

&Scoped-define CODE_PARENT "EMC2"

/* Local Variable Definitions ---                                       */

define variable log-res  as log   no-undo.
define variable ri       as recid no-undo.
define variable v-rid    as recid no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define buffer b2-code for code .

find first b2-code where b2-code.parent eq iparent
                     and b2-code.code   eq icode 
no-lock no-error.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-okei3
&Scoped-define BROWSE-NAME BROWSE-4

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf-code

/* Definitions for BROWSE BROWSE-4                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-4 buf-code.misc1 buf-code.CodeValue 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-4 
&Scoped-define QUERY-STRING-BROWSE-4 FOR EACH buf-code ~
      WHERE buf-code.parent eq b2-code.parent + {&delim-par} + b2-code.code ~
 ~
 ~
 NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-4 OPEN QUERY BROWSE-4 FOR EACH buf-code ~
      WHERE buf-code.parent eq b2-code.parent + {&delim-par} + b2-code.code ~
 ~
 ~
 NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-4 buf-code
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-4 buf-code


/* Definitions for DIALOG-BOX f-okei3                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-okei3 ~
    ~{&OPEN-QUERY-BROWSE-4}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-upd b-add b-del b-print ~
b-hist b-help BROWSE-4 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-name-doc Dialog-Frame
FUNCTION getStatus RETURNS CHARACTER
   ( imisc as char, istatus as int   )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
   LABEL "До&бавить" 
   SIZE 10 BY 1.

/*DEFINE BUTTON b-del*/
/*   LABEL "Удалить" */
/*   SIZE 10 BY 1.   */

DEFINE BUTTON b-exit AUTO-GO 
   LABEL "&Выход ":L 
   SIZE 10 BY 1.

DEFINE BUTTON b-help 
   LABEL "Помо&щь":L 
   SIZE 3 BY 1.

DEFINE BUTTON b-hist 
   LABEL "Ис&тория" 
   SIZE 3 BY 1.

DEFINE BUTTON b-print 
   LABEL "Пе&чать":L 
   SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
   LABEL "Вы&бор ":L 
   SIZE 10 BY 1.

DEFINE BUTTON b-upd 
   LABEL "&Изменить":L 
   SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-4 FOR 
   buf-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-4 f-okei3 _STRUCTURED
   QUERY BROWSE-4 NO-LOCK DISPLAY
/*buf-code.code FORMAT "x(10)":U*/
buf-code.misc1 COLUMN-LABEL "Дата н.а." FORMAT "x(10)":U
   buf-code.CodeValue FORMAT "x(20)":U WIDTH 32
   getStatus (buf-code.misc1,buf-code.status_) COLUMN-LABEL "Текущий статус" format "x(25)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 80.6 BY 10.52 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-okei3
   b-exit AT ROW 1 COL 1
   b-sel AT ROW 1 COL 13.6
   b-upd AT ROW 1 COL 24.8
   b-add AT ROW 1 COL 36.6 WIDGET-ID 2
/*   b-del AT ROW 1 COL 48.2 WIDGET-ID 4*/
   b-print AT ROW 1 COL 62.4
   b-hist AT ROW 1 COL 65.4
   b-help AT ROW 1 COL 68.4
   BROWSE-4 AT ROW 2.76 COL 1 WIDGET-ID 200
   SPACE(0.00) SKIP(0.04)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
   TITLE "Значение ЕМЦ":L.


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
/* SETTINGS FOR DIALOG-BOX f-okei3
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-4 b-help f-okei3 */
ASSIGN 
   FRAME f-okei3:SCROLLABLE = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-4
/* Query rebuild information for BROWSE BROWSE-4
     _TblList          = "buf-code"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "buf-code.parent eq b2-code.parent + {&delim-par} + b2-code.code


"
     _FldNameList[1]   > Temp-Tables.buf-code.misc1
"buf-code.misc1" "Дата н.а." "x(10)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.buf-code.CodeValue
"buf-code.CodeValue" ? ? "character" ? ? ? ? ? ? no ? no no "58" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-4 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME f-okei3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-okei3 f-okei3
ON GO OF FRAME f-okei3 /* Значение ЕМЦ */
   DO:
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add f-okei3
ON CHOOSE OF b-add IN FRAME f-okei3 /* Добавить */
   DO:
      define buffer b-code   for code.
      define buffer btt-code for code.
      define variable vRec as recid   no-undo.
      define variable v-ok as logical no-undo.

      if v-ok
         then 
      do:
         find first b-code where b-code.code = {&CODE_PARENT} no-lock no-error.
         if     avail b-code
            and not b-code.nwsgbd
            then 
         do trans:
            find first b-code where b-code.code = {&CODE_PARENT} exclusive-lock no-error.
            b-code.nwsgbd = yes.
         end.
      end.

      ri = ?.
      run ref/emcv-add.w (
         input parparentproc
         , input {&add-def}
         , input-output ri
         , input b2-code.parent + {&delim-par} + b2-code.code).
      if ri <> ? then  
      do:

         {&OPEN-QUERY-BROWSE-4}
         reposition BROWSE-4 to recid ri no-error.
         apply "ENTRY" to BROWSE-4.

      end.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&Scoped-define SELF-NAME b-del                                                                            */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del f-okei3                                                   */
/*ON choose OF b-del IN FRAME f-okei3 /* Удалить */                                                         */
/*   do:                                                                                                    */
/*      define buffer b-code for code.                                                                      */
/*      define variable v-ok       as logical no-undo.                                                      */
/*      define variable recid-code as integer no-undo .                                                     */
/*                                                                                                          */
/*      if not avail buf-code then return.                                                                  */
/*      recid-code = recid(buf-code) .                                                                      */
/*      message "Удалить запись Дата н.а.:" buf-code.code "Значение ЕМЦ:" buf-code.codevalue "?"            */
/*         view-as alert-box question                                                                       */
/*         buttons yes-no                                                                                   */
/*         title "Удаление"                                                                                 */
/*         update v-ok .                                                                                    */
/*      if not v-ok then return no-apply.                                                                   */
/*      do on error undo, return                                                                            */
/*   on stop undo, return:                                                                                  */
/*         find first b-code of buf-code exclusive-lock no-wait no-error.                                   */
/*         if locked b-code then                                                                            */
/*         do:                                                                                              */
/*            message                                                                                       */
/*               vss-workfile vss-revision vss-description skip                                             */
/*               "Запись <Дата н.а.> занята"                                                                */
/*               view-as alert-box error .                                                                  */
/*            undo, return.                                                                                 */
/*         end.                                                                                             */
/*         if not available b-code then                                                                     */
/*         do:                                                                                              */
/*            message                                                                                       */
/*               vss-workfile vss-revision vss-description skip                                             */
/*               "Не найдена запись <Дата н.а.>"                                                            */
/*               view-as alert-box error .                                                                  */
/*            undo, return.                                                                                 */
/*         end.                                                                                             */
/*                                                                                                          */
/*         find b-code where b-code.parent = b2-code.parent + chr(4) + b2-code.code exclusive-lock no-error.*/
/*         if avail b-code                                                                                  */
/*            and dec(b-code.CodeValue) eq 0                                                                */
/*            and date(b-code.misc1) < today                                                                */
/*            then                                                                                          */
/*            delete b-code.                                                                                */
/*         else                                                                                             */
/*         do:                                                                                              */
/*            find first b-code where b-code.parent = b2-code.parent + chr(4) + b2-code.code                */
/*               and recid(b-code) <> recid-code                                                            */
/*               and b-code.status_ <> {&bef-deleted-status-int} exclusive-lock no-error .                  */
/*            if not available (b-code) then                                                                */
/*               message "Значение нельзя удалить"                                                          */
/*                  view-as alert-box.                                                                      */
/*            else delete buf-code .                                                                        */
/*         end.                                                                                             */
/*                                                                                                          */
/*/*      run FillTT.*/                                                                                     */
/*         {&OPEN-QUERY-BROWSE-4}                                                                           */
/*         apply "ENTRY" to BROWSE-4.                                                                       */
/*      end.                                                                                                */
/*   end.                                                                                                   */
/*                                                                                                          */
/*/* _UIB-CODE-BLOCK-END */                                                                                 */
/*&ANALYZE-RESUME                                                                                           */


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel f-okei3
ON CHOOSE OF b-sel IN FRAME f-okei3 /* Выбор  */
   DO:
      define buffer b-code for code.
      if not avail buf-code then return.
      find first b-code of buf-code no-lock no-error.
      if avail b-code then
         v-rid = recid(b-code).
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd f-okei3
ON CHOOSE OF b-upd IN FRAME f-okei3 /* Изменить */
   DO:
      define buffer b-code   for code.
      define buffer btt-code for code.
      define variable vRec as recid no-undo.
   
      if not avail buf-code then return.
      define variable v-ok as logical no-undo.

      if v-ok 
         then 
      do:
         find first b-code where b-code.code = {&CODE_PARENT} no-lock no-error.
         if     avail b-code
            and not b-code.nwsgbd
            then 
         do trans:
            find first b-code where b-code.code = {&CODE_PARENT} exclusive-lock no-error.
            b-code.nwsgbd = yes.
         end.
      end.

      find first b-code of buf-code no-lock no-error.
      if not avail b-code then 
      do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись <Код ОКЕИ код ККТ>"
            view-as alert-box error .
         return no-apply.
      end.
      vRec = recid(b-code).
      run ref/emcv-add.w (
         input parparentproc
         , input {&update}
         , input-output vRec
         , input b2-code.parent + {&delim-par} + b2-code.code).
      {&OPEN-QUERY-BROWSE-4}
      reposition BROWSE-4 to recid vRec no-error .
      apply "ENTRY" to BROWSE-4.

   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-4
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-okei3 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
   THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME}
   APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   { gbl/getcntxt.i get }
   { gbl/curdbnum.i v-db-num }
   /*  run FillTT.*/
   run enable_UI in this-procedure .

   WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-okei3  _DEFAULT-DISABLE
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
   HIDE FRAME f-okei3.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-okei3 
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
   ENABLE
      BROWSE-4
      b-exit
      b-sel
      WHEN imode eq {&select}
      b-add
/*      WHEN imode eq {&update} and v-db-num = 0*/
/*      b-del*/
      when imode eq {&update} and v-db-num = 0
      b-upd
      WHEN imode eq {&update} and v-db-num = 0
      b-help
      WITH FRAME {&frame-name}.
    

   {&OPEN-BROWSERS-IN-QUERY-f-okei3}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getStatus f-okei3 
FUNCTION getStatus RETURNS CHARACTER
   ( imisc as char, istatus as int   ):
   define buffer code for ub.code.
&SCOPE sts-old "Устаревший"
&SCOPE sts-prev "Предыдущий"
&SCOPE sts-current "Текущий"
&SCOPE sts-next "Ожидает активации"
&SCOPE sts-del  "Деактивирован"
&SCOPE sts-error  "Ошибка"
   if istatus eq {&bef-deleted-status-int}
      then
      return {&sts-del}.
   else 
   do:
      def var vdate         as date no-undo.
      def var vdateiso      as char no-undo.
      def var vDateTodayIso as char no-undo.
     
      vdate = date(imisc) no-error.
      if error-status:error
         then
         return {&sts-error}.
      else 
      do:
         if vdate > today
         then
            return {&sts-next}.
         else if vdate = today
         then
            return {&sts-current}.
         
         else 
         do:
            vdateiso      = iso-date(vdate).
            vDateTodayIso = iso-date(today).
            find code where code.parent eq b2-code.parent + {&delim-par} + b2-code.code
               and code.code > vdateiso
               and code.code <= vDateTodayIso
               and code.status_ ne {&bef-deleted-status-int}

               no-lock no-error.
            if not avail code
            then do:
               return if ambig code then {&sts-old} else  {&sts-current}.
            end.
            else 
            do:
               DEF VAR vMonth   AS INT64.
               DEF VAR vYear    AS INT64.
               DEF VAR vDateNew AS DATE.
               DEF VAR vDay     AS INT64.

               vMonth = MONTH(today) -  3.
               vYear =  YEAR(today).
               if vMonth < 1
                  then assign
                     vMonth = vMonth + 12
                     vYear  = vYear - 1
                     . 
               vDateNew = DATE(vMonth,DAY(today),vYear) NO-ERROR.
               DO WHILE ERROR-STATUS:ERROR EQ YES:
                  VDay = vDay + 1.
                  vDateNew = DATE(vMonth,DAY(today) - vDay,vYear) NO-ERROR.
               END.
               if VDay > 0
                  then
                  vDateNew + 1.
               if vDateNew > Date(code.misc1)
                  then
                  return {&sts-old}.
               else
                  return {&sts-prev}.
            end.
         end.
      end.
   end.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

