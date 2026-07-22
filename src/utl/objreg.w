&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-objreg


/* Temp-Table and Buffer definitions                                    */
{utl/objregtt.i}


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-objreg 
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
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Процедура просмотра объектов зарегистрированых в ObjSRV".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i }
{ gbl/objsrv.i }

objsrv:GetTableObjTh(output table tt-objth).
define variable mParent as character no-undo.
mParent = objsrv:ToString().

/* Local Variable Definitions ---                                       */

function getPath returns character (input iobjname as char):
   define buffer buf-objth for tt-objth.
   define variable oPath as character no-undo.
   bloch-tt-obj:
   do while true:
      find first buf-objth where buf-objth.objname = iobjname no-lock no-error.
      if not available buf-objth
      then
         leave bloch-tt-obj.
      else do:
         oPath =  ":" + buf-objth.propname + oPath.
         iobjname = buf-objth.objparent.
      end.
   end.
   oPath = "ObjSrv" + oPath.
   return oPath.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-objreg
&Scoped-define BROWSE-NAME BROWSE-objreg

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-objth

/* Definitions for BROWSE BROWSE-objreg                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-objreg tt-objth.iNum tt-objth.propname tt-objth.objname tt-objth.objparent tt-objth.procparent 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-objreg 
&Scoped-define QUERY-STRING-BROWSE-objreg FOR EACH tt-objth ~
      WHERE if mParent eq "" then true else tt-objth.objparent eq mParent NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-objreg OPEN QUERY BROWSE-objreg FOR EACH tt-objth ~
      WHERE if mParent eq "" then true else tt-objth.objparent eq mParent NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-objreg tt-objth
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-objreg tt-objth


/* Definitions for DIALOG-BOX f-objreg                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-objreg ~
    ~{&OPEN-QUERY-BROWSE-objreg}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-copy b-all b-parent b-child 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-all 
     LABEL "Все\Ирархия":L 
     SIZE 15 BY 1.

DEFINE BUTTON b-child 
     LABEL "Потомоки" 
     SIZE 10 BY 1.

DEFINE BUTTON b-parent 
     LABEL "Родитель":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.


DEFINE BUTTON b-copy
     LABEL "В буфер ":L 
     SIZE 10 BY 1.


/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-objreg FOR 
      tt-objth SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-objreg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-objreg f-objreg _STRUCTURED
  QUERY BROWSE-objreg NO-LOCK DISPLAY
  tt-objth.propname FORMAT "x(20)"  Label "Имя проперти"
  tt-objth.label_  FORMAT "x(20)"  Label "Описание"
  tt-objth.objname FORMAT "x(40)" Label "Имя объекта"
  tt-objth.objparent FORMAT "x(40)" Label "Имя родителя"
  tt-objth.procparent FORMAT "x(40)" Label "Процедура создания"
  
  
  WIDTH 100
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 104 BY 11 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-objreg
     b-exit AT ROW 1 COL 1
     b-copy AT ROW 1 COL 14
     b-all AT ROW 1 COL 24
     b-parent AT ROW 1 COL 39 WIDGET-ID 10
     b-child AT ROW 1 COL 49 WIDGET-ID 12
     BROWSE-objreg AT ROW 2.15 COL 1 WIDGET-ID 300
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Объекты objreg":L.


/* *********************** Procedure Settings ************************ */




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-objreg
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-objreg b-child f-objreg */
ASSIGN 
       FRAME f-objreg:SCROLLABLE       = true.

/* SETTINGS FOR BROWSE BROWSE-objreg IN FRAME f-objreg
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME f-objreg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-objreg f-objreg
ON go OF FRAME f-objreg /* Тип ЕМЦ */
do:
   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-all f-objreg
ON choose OF b-all IN FRAME f-objreg /* Добавить */
do:
if mParent = ""
then
   mParent = objsrv:ToString().
else
   mParent = "".
/*      if ri <> ? then  do:*/

            {&OPEN-QUERY-BROWSE-objreg}
/*            reposition BROWSE-objreg to recid ri.*/
/*            apply "ENTRY" to BROWSE-objreg.*/

/*   end.*/
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-child
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-child f-objreg
ON choose OF b-child IN FRAME f-objreg /* Значение ЕМЦ */
do:
   if available tt-objth
   then do:
      mParent = tt-objth.objname.
      {&OPEN-QUERY-BROWSE-objreg}
   end.
   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL {&browse-name} f-objreg
on ENTER of {&browse-name} in frame f-objreg
anywhere
do:
  apply "choose" to b-child IN FRAME f-objreg.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL {&browse-name} f-objreg
on end-error of {&browse-name} in frame f-objreg
anywhere
do:
  if     available tt-objth
     and tt-objth.objparent ne objsrv:ToString()
     and mParent ne ""
  then do:
     apply "choose" to b-parent IN FRAME f-objreg.
     return no-apply.
  end.
  else
     APPLY "GO" TO FRAME {&FRAME-NAME}.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-child f-objreg
ON choose OF b-copy IN FRAME f-objreg /* Значение ЕМЦ */
do:
   define variable vpathObj as character no-undo.
   if available tt-objth
   then do:
      vpathObj = getPath(tt-objth.objname).
      run gbl/clipbrd.p (vpathObj).
      message "Скопироваано в буфер обмена:" skip vpathObj
         view-as alert-box.
   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-parent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-child f-objreg
ON choose OF b-parent IN FRAME f-objreg /*  */
do:
   define buffer buf-objth for tt-objth.
   if available tt-objth
   then do:
      find first buf-objth where buf-objth.objname eq tt-objth.objparent no-lock no-error.
    
   end.
   else
      find first buf-objth where buf-objth.objname eq mParent no-lock no-error.
   if available buf-objth
   then
      mParent = buf-objth.objparent.
       
   {&OPEN-QUERY-BROWSE-objreg}
   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-objreg
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-objreg 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
  then frame {&FRAME-NAME}:PARENT = active-window.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
on window-close of frame {&FRAME-NAME}
  apply "END-ERROR":U to self.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK
      :


  run enable_UI in this-procedure .

  wait-for go of frame {&FRAME-NAME} focus {&browse-name}.
end.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-objreg  _DEFAULT-DISABLE
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
  HIDE FRAME f-objreg.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-objreg 
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
    BROWSE-objreg
    b-exit
    b-child
    b-all
    b-copy
    b-parent
    with frame {&frame-name}.

  {&OPEN-BROWSERS-IN-QUERY-f-objreg}

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

