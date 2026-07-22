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

Запуск отчета "История действий пользователей"

Автор: Шкляр Елена
Дата создания: 15/09/10
Author: Shklyar Elena
Creation date: 05/10/10

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История действий пользователей".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ cmp/r-page1.i   }
{ cmp/operlist.i  }
{ rep/rep-bt.i    }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define temp-table tt-user-account no-undo
field user-id_ as character
field user_name as character
field db-num as integer
index pi db-num user-id_
.
 
define temp-table tt-objects  no-undo 
field name_ as character
field table_ as character
.

def var State-source as  WIDGET-HANDLE.



define variable all-gds as logical no-undo initial true.

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
&Scoped-Define ENABLED-OBJECTS user-name object-name 
&Scoped-Define DISPLAYED-OBJECTS user-name object-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE object-name AS CHARACTER 
     VIEW-AS SELECTION-LIST MULTIPLE SCROLLBAR-VERTICAL 
     SIZE 66 BY 5.5 NO-UNDO.

DEFINE VARIABLE user-name AS CHARACTER 
     VIEW-AS SELECTION-LIST MULTIPLE SCROLLBAR-VERTICAL 
     SIZE 66 BY 5.5 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     user-name AT ROW 2.5 COL 5 NO-LABEL WIDGET-ID 2
     object-name AT ROW 9.75 COL 5 NO-LABEL WIDGET-ID 4
     "Пользователи:" VIEW-AS TEXT
          SIZE 20.5 BY .67 AT ROW 1.5 COL 5 WIDGET-ID 6
     "Типы событий:" VIEW-AS TEXT
          SIZE 20.5 BY .67 AT ROW 8.67 COL 5 WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 .


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
         WIDTH              = 73.63.
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

&Scoped-define SELF-NAME object-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL object-name s-object
ON VALUE-CHANGED OF object-name IN FRAME F-Main
DO:
  assign object-name .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME user-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL user-name s-object
ON VALUE-CHANGED OF user-name IN FRAME F-Main
DO:
  assign user-name .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */
run inifields .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inifields s-object 
PROCEDURE inifields :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
------------------------------------------------------------------------------*/
for each obj-list :
for each user-obj no-lock where user-obj.obj-code = obj-list.obj-code and user-obj.obj-type = obj-list.obj-type,
    each ub.user-account no-lock where ub.user-account.user-id = user-obj.user-id:

      create tt-user-account .
      assign
      tt-user-account.db-num = user-obj.db-num
      tt-user-account.user-id_ = ub.user-account.user-id
      tt-user-account.user_name = "ID: " + ub.user-account.user-id + " ФИО: " + user-account.last-name + " " + user-account.first-name + " " + user-account.second-name
      .
end.      
end.  


if x-SelectObject = "firm" then user-name:list-item-pairs in frame {&frame-name} = "ВСЕ,-1" .
if x-SelectObject <> "firm" then do:
user-name:list-item-pairs in frame {&frame-name} = "ВСЕ,-1" .
for each tt-user-account no-lock by tt-user-account.user_name:
  assign
                user-name :list-item-pairs = substitute( "&2&1&3&1&4"
                                       , ","
                                       , user-name :list-item-pairs
                                       , tt-user-account.user_name
                                       , tt-user-account.user-id_
  )
  .
end.
End.

        define VARIABLE v-head-table as character no-undo .
  
        define BUFFER bf_c-user-log for ub.c-user-log .
        define variable v-user-table-name as character no-undo .
        define variable v-user-table      as character no-undo .
        define variable v-table           as character no-undo .

/*        for each tt-user-account,*/
        for each bf_c-user-log no-lock where 
/*        bf_c-user-log.corr-user-name = tt-user-account.user-id_ and*/
        bf_c-user-log.corr-date >= x-Date-Start
        and bf_c-user-log.corr-date <= x-Date-End by bf_c-user-log.head-table :
            v-table = bf_c-user-log.head-table .
            if v-table begins "c-" and v-table <> {&table_c-usr-hist} and v-table <> {&table_c-plc-hist} then 
            do:
                v-user-table = replace(v-table,"c-","").
            end.
            else v-user-table = v-table .    
            find first tt-objects where tt-objects.table_ = v-user-table no-error .
            if not AVAILABLE (tt-objects) then 
            do:
                { gbl/tblnmusr.i
                    v-user-table
                    v-user-table-name
                  }
                create tt-objects .
                assign
                    tt-objects.table_ = v-user-table 
                    tt-objects.name_  = v-user-table-name
                    .    
            end.  
        end.   


/* if x-SelectObject = "firm" then object-name:list-item-pairs in frame {&frame-name} = "ВСЕ,-1" .         */
/* if x-SelectObject <> "firm" then do: */
object-name:list-item-pairs in frame {&frame-name} = "ВСЕ,-1" .        
for each tt-objects no-lock by tt-objects.name_:
  assign
                object-name :list-item-pairs = substitute( "&2&1&3&1&4"
                                       , ","
                                       , object-name :list-item-pairs
                                       , tt-objects.name_
                                       , tt-objects.table_
                                                   )
  .
end.
/* end. */
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

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
------------------------------------------------------------------------------*/
define variable v-user-id as character no-undo .
define variable v-obj-list  as character no-undo .

run rep/r-hist-sysadm.p(input my-handle ,
input user-name,
                        input object-name) . 
/* run rep/r-amin.p ( all-gds ).*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???

------------------------------------------------------------------------------*/

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

