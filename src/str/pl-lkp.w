&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-pl-form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-pl-form 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

редактирование складского места партии

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/13/06
Author: Dmitry Ukhanov
Creation date: 04/13/06

*/

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/* Local Variable Definitions ---                                       */
define input parameter parparentproc as widget-handle no-undo .
define input parameter v-parts-recid as recid         no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "редактирование складского места партии":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }

define shared variable list-mode as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-pl-form

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-help pl_code b-spr 
&Scoped-Define DISPLAYED-FIELDS ub.place.pl-name ub.place.loc1 ~
ub.place.loc2 ub.place.loc3 ub.place.loc4 ub.place.PS 
&Scoped-define DISPLAYED-TABLES ub.place
&Scoped-define FIRST-DISPLAYED-TABLE ub.place
&Scoped-Define DISPLAYED-OBJECTS pl_code 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Выход " 
     SIZE 10 BY 1.

DEFINE BUTTON b-spr 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .88.

DEFINE VARIABLE pl_code AS INTEGER FORMAT "99999999999":U INITIAL 0 
     LABEL "&Бар-код" 
     VIEW-AS FILL-IN 
     SIZE 17.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-pl-form
     b-quit AT ROW 1.25 COL 2.5
     b-help AT ROW 1.25 COL 12.5
     pl_code AT ROW 2.83 COL 11.5 COLON-ALIGNED
     b-spr AT ROW 2.83 COL 32.25
     ub.place.pl-name AT ROW 4.08 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE 
          SIZE 41 BY 1
     ub.place.loc1 AT ROW 5.33 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE 
          SIZE 11.63 BY 1
     ub.place.loc2 AT ROW 6.33 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE 
          SIZE 11.63 BY 1
     ub.place.loc3 AT ROW 7.33 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE 
          SIZE 11.63 BY 1
     ub.place.loc4 AT ROW 8.33 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE 
          SIZE 11.63 BY 1
     ub.place.PS AT ROW 9.58 COL 5.5 NO-LABEL
          VIEW-AS EDITOR
          SIZE 49.25 BY 2.58
     SPACE(0.24) SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Складское место".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-pl-form
   FRAME-NAME                                                           */
ASSIGN 
       FRAME d-pl-form:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN ub.place.loc1 IN FRAME d-pl-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.place.loc2 IN FRAME d-pl-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.place.loc3 IN FRAME d-pl-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.place.loc4 IN FRAME d-pl-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.place.pl-name IN FRAME d-pl-form
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR ub.place.PS IN FRAME d-pl-form
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-spr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spr d-pl-form
ON CHOOSE OF b-spr IN FRAME d-pl-form
DO:
  define variable rid-list as character no-undo .
  run ref/pl-list.w
    ( input        parparentproc
    , input        "b-sel"
    , input        '':U
    , input        0
    , input        {&all}
    , input-output rid-list
    ) .
  if rid-list = "cancel"
  then do :
    return no-apply .
  end .
  if rid-list <> "":U
  then do:
    find first ub.place no-lock where
        recid( ub.place ) = integer( entry( 1, rid-list ) ) no-error .
    if available ub.place
    then do:
      assign
        pl_code = ub.place.pl-code
      .
      run enable_UI in this-procedure .
    end.
  end.
  apply "ENTRY":U to pl_code in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-pl-form 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.


ON GO OF FRAME d-pl-form
DO:
  define variable v-ok as logical no-undo .

  define buffer buf_place for ub.place .

  if input frame {&FRAME-NAME} pl_code <> 0
  then do:
    find first ub.place no-lock where
               ub.place.obj-type = ub.parts.obj-type                 and
               ub.place.obj-code = ub.parts.obj-code                 and
               ub.place.pl-code  = input frame {&FRAME-NAME} pl_code no-error .
    if not available ub.place
    then do:
      message "На объекте" parts.obj-type parts.obj-code skip( 0 )
              "не существует складского места с кодом" input frame {&FRAME-NAME} pl_code skip( 0 )
              "Продолжить?" skip( 0 )
      view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> yes
      then do:
        return no-apply .
      end.
    end.
  end.
  assign
    ub.parts.pl-code = input frame {&FRAME-NAME} pl_code
  .
END.

ON RETURN OF pl_code IN FRAME {&FRAME-NAME}
DO:
  apply "CHOOSE":U to b-spr in frame {&FRAME-NAME} .
  return no-apply.
END.

ON END-ERROR, STOP OF FRAME {&FRAME-NAME}
DO:
  apply "CHOOSE":U to b-quit in frame {&frame-name} .
  return no-apply .
END.

MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  assign
    ub.place.PS :read-only = yes
  .
  find first ub.parts where
      recid( ub.parts ) = v-parts-recid no-error .
  if not available ub.parts
  then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка задания входных параметров" skip( 0 )
            "Не найдена партия" skip( 0 )
            "Код партии" v-parts-recid skip ( 0 )
    view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    pl_code = ub.parts.pl-code
  .
  find first ub.place no-lock where
             ub.place.obj-type = parts.obj-type and
             ub.place.obj-code = parts.obj-code and
             ub.place.pl-code  = parts.pl-code  no-error .
  RUN enable_UI in this-procedure .

  find first ub.gds-obj no-lock where
             ub.gds-obj.obj-type  = ub.parts.obj-type  and
             ub.gds-obj.obj-code  = ub.parts.obj-code  and
             ub.gds-obj.artic     = ub.parts.artic     and
             ub.gds-obj.prod-type = ub.parts.prod-type and
             ub.gds-obj.prod-code = ub.parts.prod-code no-error .
  if available ub.gds-obj and
     ub.gds-obj.place-rsrv = yes
  then do: /* товар резервируется по складским местам */
    assign
      pl_code :sensitive in frame {&FRAME-NAME} = no
      b-spr   :sensitive in frame {&FRAME-NAME} = no
    .
  end.

  frame {&FRAME-NAME} :title = substitute( 'Складское место на объекте : &1 &2 '
                                         , ub.parts.obj-type
                                         , ub.parts.obj-code
                                         ) .

  wait-for go of frame {&FRAME-NAME} focus pl_code.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-pl-form  _DEFAULT-DISABLE
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
  HIDE FRAME d-pl-form.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-pl-form  _DEFAULT-ENABLE
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
  DISPLAY pl_code 
      WITH FRAME d-pl-form.
  IF AVAILABLE ub.place THEN 
    DISPLAY ub.place.pl-name ub.place.loc1 ub.place.loc2 ub.place.loc3 
          ub.place.loc4 ub.place.PS 
      WITH FRAME d-pl-form.
  ENABLE b-quit b-help pl_code b-spr 
      WITH FRAME d-pl-form.
  {&OPEN-BROWSERS-IN-QUERY-d-pl-form}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

