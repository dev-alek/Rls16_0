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

Расширеный оперативный отчет по закончившимся наименованиям (закладка № 2)

Автор: Хныкин Павел Андреевич
Дата создания: 02/12/10
Author: Pavel Khnykin
Creation date: 02/12/10

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Расширеный оперативный отчет по закончившимся наименованиям (закладка № 2)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var State-source as  WIDGET-HANDLE.

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/usr-flt.i  }

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
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-7 NullStr fi-days-absence ~
fi-critical-balance tg-absence-period fi-absence-period-from ~
fi-absence-period-to
&Scoped-Define DISPLAYED-OBJECTS NullStr fi-days-absence ~
fi-critical-balance tg-absence-period fi-absence-period-from ~
fi-absence-period-to

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE fi-absence-period-from AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE fi-absence-period-to AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE fi-critical-balance AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "Критический остаток товара"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE fi-days-absence AS INTEGER FORMAT ">>9":U INITIAL 1
     LABEL "Количество дней отсутствия товара"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 69.5 BY 12.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.5 BY 3.

DEFINE VARIABLE NullStr AS LOGICAL INITIAL no
     LABEL "Показать непроходившие товары"
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .83 NO-UNDO.

DEFINE VARIABLE tg-absence-period AS LOGICAL INITIAL no
     LABEL "Отсутствуют продажи за период"
     VIEW-AS TOGGLE-BOX
     SIZE 47.5 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     NullStr AT ROW 2 COL 3.5
     fi-days-absence AT ROW 3 COL 37 COLON-ALIGNED WIDGET-ID 2
     fi-critical-balance AT ROW 4 COL 37 COLON-ALIGNED WIDGET-ID 4
     tg-absence-period AT ROW 5 COL 3.5 WIDGET-ID 6
     fi-absence-period-from AT ROW 7 COL 6 COLON-ALIGNED WIDGET-ID 8
     fi-absence-period-to AT ROW 7 COL 22.5 COLON-ALIGNED WIDGET-ID 10
     RECT-6 AT ROW 1.5 COL 2
     RECT-7 AT ROW 6 COL 3.5 WIDGET-ID 12
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
         HEIGHT             = 16.88
         WIDTH              = 76.13.
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

&Scoped-define SELF-NAME tg-absence-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-absence-period s-object
ON VALUE-CHANGED OF tg-absence-period IN FRAME F-Main /* Отсуствуют продажи за период */
DO:
  run proc-tg-absence-period in this-procedure no-error .
  if error-status :error = yes
  then do:
    return no-apply. /* --->>>--- */
  end.
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
{ gbl/ed_date.i fi-absence-period-from  }
{ gbl/ed_date.i fi-absence-period-to    }

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

  /* Code placed here will execute AFTER standard behavior.    */
  define variable v-naim           as character        no-undo.
  define variable v-list           as character        no-undo.
  define variable v-print-graft    as logical          no-undo.
  define variable v-sort-gr        as logical          no-undo.
  define variable v-type-price     as logical          no-undo.
  define variable v-type-val       as logical          no-undo.

  run uf-get( input {&uf-e-eslg-e}
            , input v-cntxt-userid
            , output v-list
            , output v-naim
            , output v-print-graft
            , output v-sort-gr
            , output v-type-price
            , output v-type-val
            ) .
  if num-entries(v-list , {&delim-par}) = 6
  then do:
    assign
      NullStr                 = logical(entry(1 , v-list , {&delim-par}))
      fi-days-absence         = integer(entry(2 , v-list , {&delim-par}))
      fi-critical-balance     = integer(entry(3 , v-list , {&delim-par}))
      tg-absence-period       = logical(entry(4 , v-list , {&delim-par}))
      fi-absence-period-from  = date(entry(5 , v-list , {&delim-par}))
      fi-absence-period-to    = date(entry(6 , v-list , {&delim-par}))
    no-error .
    display
      NullStr
      fi-days-absence
      fi-critical-balance
      tg-absence-period
      fi-absence-period-from
      fi-absence-period-to
    with frame {&frame-name}.
    run proc-tg-absence-period in this-procedure .
  end. /* if num-entries(v-list) = 6 */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
define variable v-naim           as character        no-undo.
  define variable v-list           as character        no-undo.
  define variable v-print-graft    as logical          no-undo.
  define variable v-sort-gr        as logical          no-undo.
  define variable v-type-price     as logical          no-undo.
  define variable v-type-val       as logical          no-undo.
do
on error undo, return error return-value
:
  assign frame {&frame-name}
    NullStr
    fi-days-absence
    fi-critical-balance
    tg-absence-period
    fi-absence-period-from
    fi-absence-period-to
  .

  if  tg-absence-period = yes and
      fi-absence-period-from > fi-absence-period-to
  then do:
    message
      "Период отсутствия продаж задан некорректно!"
    view-as alert-box error.
    return. /* --->>>--- */
  end.

  assign
    v-list = substitute( "&2&1&3&1&4&1&5&1&6&1&7"
                       , {&delim-par}
                       , NullStr
                       , fi-days-absence
                       , fi-critical-balance
                       , tg-absence-period
                       , fi-absence-period-from
                       , fi-absence-period-to
                       )
  .
  run uf-set( input {&uf-e-eslg-e}
            , input v-cntxt-userid
            , input v-list
            , input v-naim
            , input v-print-graft
            , input v-sort-gr
            , input v-type-price
            , input v-type-val
            ) .

  run rep/r-eslg-e.p ( input NullStr
                     , input fi-days-absence
                     , input fi-critical-balance
                     , input tg-absence-period
                     , input fi-absence-period-from
                     , input fi-absence-period-to
                     ) .
end.

/*run rep/r-eslg-e.p ( NullStr ) .*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

  Assign frame {&frame-name} NullStr .

  /*строки в которых содержатся выбранные объекты */
  Assign
    STR-obj-type = ''
    STR-obj-code = ''
    STR-obj-name = ''
    STR-obj      = ''
  .

  For each obj-list no-lock:
    Assign
      STR-obj-type = STR-obj-type + obj-list.obj-type + ','
      STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
      STR-obj-name = STR-obj-name + obj-list.obj-name + ','
      STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ','
    .
  End.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-tg-absence-period s-object
PROCEDURE proc-tg-absence-period :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  assign frame {&frame-name}
    tg-absence-period
  .
  assign
    fi-absence-period-from :sensitive = tg-absence-period
    fi-absence-period-to :sensitive   = tg-absence-period
  .
end.
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
    when "link-changed":U then  DO:
         Run my-var.
         End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
