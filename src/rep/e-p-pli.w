&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История изменения цен поставшика (закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 14/03/01
Author: Svetlana Chernova
Creation date: 14/03/01

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История изменения цен поставшика (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/operlist.i }
{ cmp/cli-list.i cli-list def "new shared" }
{ rep/rep-bt.i   }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable v-nn as integer   no-undo .
define variable State-source as  WIDGET-HANDLE.
define buffer cli-post for ub.clients .
define new  SHARED temp-table g#post NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.

define New SHARED temp-table g#post-f NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-code like ub.clients.grp-code
    field grp-name like ub.clients.grp-name
    field lvl-num like  ub.cli-grp.lvl-num
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code
    INDEX p1  obj-name
    .
define variable  post-grp_recids as character no-undo .
define variable ii as integer no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 RAD-type-rep RADPost PostName 
&Scoped-Define DISPLAYED-OBJECTS RAD-type-rep RADPost PostName 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE PostName AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 67.38 BY 10.92 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.

DEFINE VARIABLE RAD-type-rep AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "По приходным накладным", 1,
"По истории спецификации", 2
     SIZE 28 BY 2.71 NO-UNDO.

DEFINE VARIABLE RADPost AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Справочник", 2,
"Список", 3
     SIZE 15 BY 2.71 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71.88 BY 15.71.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RAD-type-rep AT ROW 2.75 COL 41 NO-LABEL WIDGET-ID 2
     RADPost AT ROW 2.96 COL 3.75 NO-LABEL
     PostName AT ROW 5.58 COL 3.63 NO-LABEL
     "Выбор поставщика:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.71 COL 4.75
          FGCOLOR 4
     "Выбор типа отчета:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 2 COL 42.5 WIDGET-ID 6
          FGCOLOR 4 
     RECT-7 AT ROW 1.29 COL 2.63
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.29
         WIDTH              = 74.38.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       PostName:READ-ONLY IN FRAME F-Main        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME RAD-type-rep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RAD-type-rep s-object
ON VALUE-CHANGED OF RAD-type-rep IN FRAME F-Main
DO:
  ASSIGN
     RAD-type-rep.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADPost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADPost s-object
ON VALUE-CHANGED OF RADPost IN FRAME F-Main
DO:
  Assign RadPost.
  for each g#post-f : delete g#post-f. end.
  Case RAdPost :
      when 3 then DO:
        run str/cli-list.w ( my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code ).
        Postname = "" .
        For each cli-list :

          find first ub.cli-grp where ub.cli-grp.node-code = cli-list.grp-code no-lock no-error .
          if available ub.cli-grp then do:
              create g#post-f.
              assign
                g#post-f.obj-type = cli-list.obj-type
                g#post-f.obj-code = cli-list.obj-code
                g#post-f.obj-name = cli-list.obj-name
                g#post-f.grp-code = cli-list.grp-code
                g#post-f.grp-name = cli-list.grp-name
                g#post-f.lvl-num  = ub.cli-grp.lvl-num
                Postname = Postname + cli-list.obj-name + chr(10)
                .
          end.
        End.
        Display PostName with frame {&FRAME-NAME} .
      END.

  when 1 then DO:
            For each ub.clients where ub.clients.obj-type = {&cmp} or ub.clients.obj-type = {&prs}:
            find first ub.cli-grp where ub.cli-grp.node-code = ub.clients.grp-code no-lock no-error .
            if available ub.cli-grp then do:
                create g#post-f.
                assign
                  g#post-f.obj-type = ub.clients.obj-type
                  g#post-f.obj-code = ub.clients.obj-code
                  g#post-f.obj-name = ub.clients.obj-name
                  g#post-f.grp-code = ub.clients.grp-code
                  g#post-f.grp-name = ub.clients.grp-name
                  g#post-f.lvl-num  = ub.cli-grp.lvl-num
                  .
            end.
          End.

          Assign  Postname = "Все".
          Display PostName with frame {&FRAME-NAME} .
       END.
  when 2 then
        do:
            run ref/cli-all.w
                (  my-handle
                , "b-sel,b-mark"
                , {&cmp}
                , {&all}
                , {&current}
                , ?
                , ",,,,,,NO,,"
                , ?
              , output post-grp_recids ) .

            if post-grp_recids = "" then do:
                 Assign  Postname = "" .
                 Display PostName radpost with frame {&FRAME-NAME} .
            end.
            else do:
                Assign  Postname = ''.
                v-nn = num-entries( post-grp_recids ) .
                DO ii = 1 TO v-nn :
                    find cli-post where recid( cli-post ) = int(entry( ii, post-grp_recids )) no-lock no-error .
                    find first ub.cli-grp where ub.cli-grp.node-code = cli-post.grp-code no-lock no-error .
                    if available cli-post and available ub.cli-grp then do:
                        create g#post-f.
                        assign
                          g#post-f.obj-type = cli-post.obj-type
                          g#post-f.obj-code = cli-post.obj-code
                          g#post-f.obj-name = cli-post.obj-name
                          g#post-f.grp-code = cli-post.grp-code
                          g#post-f.grp-name = cli-post.grp-name
                          g#post-f.lvl-num  = ub.cli-grp.lvl-num
                          Postname = PostName + cli-post.obj-name + chr(10)
                        .
                    end.
                END.
                 Display PostName with frame {&FRAME-NAME} .
            end.
        end.
  End case.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .
  apply "VALUE-CHANGED" to RADPost IN FRAME {&frame-name} .
  apply "VALUE-CHANGED" to RAD-type-rep IN FRAME {&frame-name} .

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
 run rep/r-p-pli.p(
         RAD-type-rep   /* тип формирования отчета  */ 
         ).   

 /* (
                        PostName,
                        RADPost
                         ) */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???

------------------------------------------------------------------------------*/
assign frame {&frame-name} PostName  RADPost  .
/* */ 
ASSIGN  
   ReportNAme = "ИСТОРИЯ ИЗМЕНЕНИЯ ЦЕН ТОВАРОВ"
   /* Добавим в заголовок тип отчета */ 
   + " " + 
   (IF RAD-type-rep = ? THEN "" ELSE   
       "(" + ENTRY((RAD-type-rep * 2) - 1, RAD-type-rep:RADIO-BUTTONS) + ")"  
   ).
 /* */    
 ReportHeader = "Поставщик : " + PostName + chr(10) .
 ReportHeader = ReportHeader + "с " + string( x-date-start , "99/99/9999" ) + " по " + string(x-date-end,"99/99/9999"  ) + chr(10) .
 sheetf.Excel-Column-Lable = "Код,Артикул,Название товара,Ед.изм" .
 sheetf.Sizes  = "10,16,60,7" .
 Sheetf.ColFOrmat = "2=@;3=@;4=@"  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.


  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      /* link-changed */
  END CASE.
  END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

