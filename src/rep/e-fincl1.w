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

Форма №1-№3 взаиморасчет с контрагентами (ЗАКЛАДКА №2)

Автор: Хныкин Павел Андреевич
Дата создания: 08/23/07
Author: Pavel Khnykin
Creation date: 08/23/07

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Форма №1 взаиморасчет с контрагентами (ЗАКЛАДКА №2)".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i     }
{ cmp/operlist.i    }
{ cmp/cli-list.i cli-list def "new shared"}
{ rep/rep-bt.i      }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.


def buffer cli-post for ub.clients .
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
    field lvl-num  like ub.cli-grp.lvl-num
    field host-code like ub.clients.host-code
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code
    INDEX p1  obj-name
    index hc host-code
    .
define variable post-grp_recids     as character  no-undo .
define variable ii                  as integer    no-undo .
define variable v-report-proc-name  as character  no-undo .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 RADPost PostName
&Scoped-Define DISPLAYED-OBJECTS RADPost PostName

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE PostName AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 48.38 BY 11.79 TOOLTIP "Список выбранных поставщиков"
     FONT 4 NO-UNDO.

DEFINE VARIABLE RADPost AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Справочник", 2,
"Список", 3
     SIZE 16.63 BY 2.71 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 73 BY 16.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RADPost AT ROW 2.96 COL 3.75 NO-LABEL
     PostName AT ROW 2.96 COL 20.75 NO-LABEL
     "Выбор контрагента:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.71 COL 4.75
          FGCOLOR 4
     RECT-7 AT ROW 1.29 COL 1
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
         HEIGHT             = 16.75
         WIDTH              = 73.
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

&Scoped-define SELF-NAME RADPost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADPost s-object
ON VALUE-CHANGED OF RADPost IN FRAME F-Main
DO:
  define buffer buf_cli-grp   for ub.cli-grp.

  Assign RadPost.
  for each g#post-f : delete g#post-f. end.
  Case RAdPost :
      when 3 then DO:
        run str/cli-list.w (my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
        Postname = "" .
        For each cli-list :
          find first buf_cli-grp where buf_cli-grp.node-code = cli-list.grp-code no-lock no-error .
          if available buf_cli-grp then do:
              create g#post-f.
              assign
                g#post-f.obj-type   = cli-list.obj-type
                g#post-f.obj-code   = cli-list.obj-code
                g#post-f.obj-name   = cli-list.obj-name
                g#post-f.grp-code   = cli-list.grp-code
                g#post-f.grp-name   = cli-list.grp-name
                g#post-f.lvl-num    = buf_cli-grp.lvl-num
                g#post-f.host-code  = ?
                Postname            = Postname + cli-list.obj-name + chr(10)

                .
          end.
        End.
        Display PostName with frame {&FRAME-NAME} .
      END.
  when 1 then DO:
          Assign  Postname = "Все".
          Display PostName with frame {&FRAME-NAME} .
       END.
  when 2 then
        do:
            run ref/cli-all.w ( my-handle
                         , "b-sel,b-mark"
                         , {&cmp}
                         , {&all}
                         , {&current}
                         , ?
                         , ",,,,,,NO,,"
                         , ?
                        , output post-grp_recids ) .

            if post-grp_recids = "" then do:
                 Assign  Postname = {&all} radpost = 1.
                 Display PostName   radpost with frame {&FRAME-NAME}.
            end.
            else do:
                Assign  Postname = ''.
                DO ii = 1 TO num-entries( post-grp_recids ) :
                    find cli-post where recid( cli-post ) = int(entry( ii, post-grp_recids )) no-lock no-error .
                    if cli-post.obj-type = {&cmp}
                    or cli-post.obj-type = {&prs} then do:
                      find first buf_cli-grp where buf_cli-grp.node-code = cli-post.grp-code no-lock no-error .
                      if available cli-post and available buf_cli-grp then do:
                          create g#post-f.
                          assign
                            g#post-f.obj-type   = cli-post.obj-type
                            g#post-f.obj-code   = cli-post.obj-code
                            g#post-f.obj-name   = cli-post.obj-name
                            g#post-f.grp-code   = cli-post.grp-code
                            g#post-f.grp-name   = cli-post.grp-name
                            g#post-f.lvl-num    = buf_cli-grp.lvl-num
                            g#post-f.host-code  = ?
                            Postname            = PostName + cli-post.obj-name + chr(10)
                          .
                      end.
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
 define buffer buf_usr-flt for ubflt.usr-flt .
 define buffer buf_clients for ub.clients.

 define variable v-rad  as integer   no-undo .
 define variable v-i    as integer   no-undo .

  /* Code placed here will execute PRIOR to standard behavior. */
  if valid-handle( parent-handle ) and parent-handle :get-signature("get-report-proc-name") <> ""
  then do:
    run get-report-proc-name in parent-handle ( output v-report-proc-name ) .
  end.

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  find first buf_usr-flt no-lock
    where buf_usr-flt.user-name  = v-cntxt-userid
      and buf_usr-flt.call-point = v-report-proc-name
  no-error .
  if available buf_usr-flt then do:
    assign
      v-rad = integer( entry( 1, buf_usr-flt.list_ ) )
    no-error .
    if error-status :error then return.
    if v-rad = 1 then do:
      assign
        postname = "Все":U
      .
    end.
    if v-rad = 2 or v-rad = 3 then do:
      do v-i = 2 to num-entries( buf_usr-flt.list_ ) :
        find first buf_clients no-lock
          where recid(buf_clients) = integer( entry( v-i, buf_usr-flt.list_ ) )
        no-error .
        if available buf_clients then do:
          if buf_clients.stts = 0 then do:
            create g#post-f.
            assign
              g#post-f.obj-type   = buf_clients.obj-type
              g#post-f.obj-code   = buf_clients.obj-code
              g#post-f.obj-name   = buf_clients.obj-name
              g#post-f.host-code  = ?
              Postname            = PostName + buf_clients.obj-name + chr(10)
              radpost             = v-rad
            .
          end.
        end.
      end.
    end.
    display postname radpost with frame {&frame-name} .

  end. /* if available buf_usr-flt */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
 define buffer buf_usr-flt for ubflt.usr-flt .
 define buffer buf_clients for ub.clients.

  find first buf_usr-flt no-lock
    where buf_usr-flt.user-name  = v-cntxt-userid
      and buf_usr-flt.call-point = v-report-proc-name
  no-error .
  if not available buf_usr-flt
  then do:
    create buf_usr-flt .
    assign
      buf_usr-flt.user-name  = v-cntxt-userid
      buf_usr-flt.call-point = v-report-proc-name
    .
  end.

  find current buf_usr-flt exclusive-lock no-error .
  if available buf_usr-flt then do:
  end.

 case radpost:
  when 1 then do:
    assign
      buf_usr-flt.list_ = string(radpost)
    .
  end.
  when 2 or when 3 then do:
    assign
      buf_usr-flt.list_ = string(radpost)
    .
    for each g#post-f :
      find first buf_clients no-lock
        where buf_clients.obj-type =  g#post-f.obj-type
          and buf_clients.obj-code =  g#post-f.obj-code
      no-error .
      assign
        buf_usr-flt.list_  = buf_usr-flt.list_  + ',' + string(recid(buf_clients))
      .
    end.
  end.
 end case.

 run value(v-report-proc-name)
                    ( input my-handle
                    , input RADPost
                    )  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???

------------------------------------------------------------------------------*/
assign frame {&frame-name} PostName  RADPost .
/*ReportNAme = "СРАВНИТЕЛЬНЫЙ АНАЛИЗ ЦЕН ПОСТАВЩИКОВ" .*/

 ReportHeader = "Контрагенты : " + (if radpost = 1 then "Все" else PostName) + chr(10).
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