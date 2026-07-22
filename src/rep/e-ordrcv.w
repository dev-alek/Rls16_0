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

График поставок (2-ой лист)

Автор: Комаров Иван Сергеевич
Дата создания: 10/07/10
Author: Ivan Komarov
Creation date: 10/07/10

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "График поставок".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ cmp/operlist.i  }
{ rep/rep-bt.i    }
{ gbl/twowin.i   }


CREATE WIDGET-POOL.
{ gbl/key-rec.i   }


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable State-source as  WIDGET-HANDLE.
define variable v-nn            as integer   no-undo .
define variable g#log           as logical   no-undo .
define variable post-grp_recids as character no-undo .
define variable ii              as integer   no-undo .

def buffer cli-post for clients .

def new  SHARED temp-table g#post NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.

def New SHARED temp-table g#post-f NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-code like ub.clients.grp-code
    field grp-name like ub.clients.grp-name
    field lvl-num like  ub.cli-grp.lvl-num
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code
    INDEX p1  obj-name
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RADPost PostName sort-by-name show-rcv
&Scoped-Define DISPLAYED-OBJECTS RADPost PostName sort-by-name show-rcv

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE PostName AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 2.17 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.

DEFINE VARIABLE RADPost AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все", 1,
"Выборочно", 2
     SIZE 12 BY 2.17 NO-UNDO.

DEFINE VARIABLE show-rcv AS LOGICAL INITIAL no
     LABEL "Показывать поставки"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 TOOLTIP "Выводит информацию по поставкам" NO-UNDO.

DEFINE VARIABLE sort-by-name AS LOGICAL INITIAL no
     LABEL "Сортировать поставщиков по имени"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 TOOLTIP "Выводит поставщиков по алфавиту" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RADPost AT ROW 2 COL 3 NO-LABEL WIDGET-ID 22
     PostName AT ROW 2 COL 15.38 NO-LABEL WIDGET-ID 20
     sort-by-name AT ROW 5.25 COL 3 WIDGET-ID 28
     show-rcv AT ROW 6.5 COL 3 WIDGET-ID 30
     "Выбор поставщика:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.25 COL 7.13 WIDGET-ID 26
          FGCOLOR 4
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.75
         WIDTH              = 75.
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
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE
       FRAME F-Main:PRIVATE-DATA     =
                "DLGCLOSE".

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

&Scoped-define SELF-NAME RADPost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADPost s-object
ON VALUE-CHANGED OF RADPost IN FRAME F-Main
DO:
  Assign RadPost.
  for each g#post-f : delete g#post-f. end.
  Case RAdPost :
    when 1 then do:
        Assign  Postname = {&all}.
        Display PostName with frame {&FRAME-NAME} .
    end.
    when 2 then do:
        run ref/cli-all.w
            ( my-handle
            , "b-sel,b-mark"
            , {&pro}
            , {&all}
            , {&current}
            , ?
            , ",,,,,,NO,,"
            ,?
            , output post-grp_recids ) .
        if post-grp_recids = "" then do:
            Assign  Postname = {&all} radpost = 1.
            Display PostName radpost with frame {&FRAME-NAME} .
        end.
        else do:
            assign
              Postname = ''
              v-nn  = num-entries( post-grp_recids )
            .
            do ii = 1 to v-nn :
                find cli-post where recid( cli-post ) = int(entry( ii, post-grp_recids )) no-lock no-error .
                find first cli-grp where cli-grp.node-code = cli-post.grp-code no-lock no-error .
                if available cli-post and available cli-grp then do:
                    create g#post-f.
                    assign
                      g#post-f.obj-type = cli-post.obj-type
                      g#post-f.obj-code = cli-post.obj-code
                      g#post-f.obj-name = cli-post.obj-name
                      g#post-f.grp-code = cli-post.grp-code
                      g#post-f.grp-name = cli-post.grp-name
                      g#post-f.lvl-num  = cli-grp.lvl-num
                      Postname = PostName + cli-post.obj-name + chr(10)
                    .
                end.
            end.
            display PostName with frame {&FRAME-NAME} .
        end.
    end.
  End case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

assign frame {&frame-name} PostName RADPost sort-by-name show-rcv .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
------------------------------------------------------------------------------*/

run rep/r-ordrcv.p
    (
     input my-handle
    ,input show-rcv
    ,input sort-by-name
    ,input Radpost
    ,input Postname
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

assign frame {&frame-name} RADPost sort-by-name show-rcv .
if RADPost = 0 or RADPost = 1 then PostName = {&all}.
  assign
    ReportHeader = "Отчет сформирован: " + string(today, "99/99/9999") + {&new-line} +
    "Сортировать поставщиков: " + (if sort-by-name then "по имени" else "по коду") + {&new-line} +
    (if show-rcv then "Показывать поставки" else "Не показывать поставки")         + {&new-line} +
    "Поставщики: " + {&new-line} + PostName
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME