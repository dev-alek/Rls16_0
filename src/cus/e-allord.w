&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вторая закладка расчета потребности товара

Автор: Комаров Иван Сергеевич
Дата создания: 07/23/10
Author: Ivan Komarov
Creation date: 07/23/10

Автор1: Чернова Светлана Александровна
Дата создания1: 03/17/04 12:14
*/


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Вторая закладка расчета потребности товара    ".

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-page1.i      }
{ cus/df-zakaz.i NEW }
{ rep/rep-bt.i       }

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
&Scoped-Define ENABLED-OBJECTS date-ship date-p-1 date-p-2 g#type BUTTON-1 ~
EDITOR-1 T-grp radio-column B-neword T-artic B-newcol radio-gds-obj ~
tog-goods-from-am tog-det-post tog-det-prizn FILL-IN-1 FILL-IN-2 FILL-IN-3
&Scoped-Define DISPLAYED-OBJECTS date-ship date-p-1 date-p-2 g#type ~
EDITOR-1 T-grp radio-column T-artic radio-gds-obj tog-goods-from-am  ~
tog-det-post tog-det-prizn FILL-IN-1 FILL-IN-2 FILL-IN-3

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-newcol
     IMAGE-UP FILE "cmp/b-must.bmp":U
     LABEL ""
     SIZE 5.5 BY 1.75 TOOLTIP "Порядок колонок".

DEFINE BUTTON B-neword
     IMAGE-UP FILE "cmp/b-must.bmp":U
     LABEL ""
     SIZE 5.5 BY 1.75 TOOLTIP "Выбор колонок".

DEFINE BUTTON BUTTON-1
     LABEL "Параметры расчета количества заказа"
     SIZE 40.5 BY 1.13 TOOLTIP "Нажмите на кнопку для задания параметров расчета заказа".

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 92 BY 4 NO-UNDO.

DEFINE VARIABLE date-p-1 AS DATE FORMAT "99/99/9999":U
     LABEL "На период продаж с"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Период продаж" NO-UNDO.

DEFINE VARIABLE date-p-2 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Период продаж" NO-UNDO.

DEFINE VARIABLE date-ship AS DATE FORMAT "99/99/9999":U
     LABEL "Дата заказа"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Ориентировочная дата доставки" NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Сортировка товаров"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор типа печати"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип сортировки"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE g#type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3",
"Item 4", "4"
     SIZE 24.5 BY 2.75 NO-UNDO.

DEFINE VARIABLE radio-column AS LOGICAL
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Печать в формате импорта", yes,
"Произвольная форма", no
     SIZE 29.5 BY 4 NO-UNDO.

DEFINE VARIABLE radio-gds-obj AS LOGICAL
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Товар\Объект", yes,
"Объект\Товар", no
     SIZE 20 BY 2 TOOLTIP "Выводить отчет в выбранном разрезе" NO-UNDO.

DEFINE VARIABLE T-artic AS LOGICAL INITIAL no
     LABEL "По артикулу"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-grp AS LOGICAL INITIAL no
     LABEL "По группам товаров"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .83 NO-UNDO.

DEFINE VARIABLE tog-det-post AS LOGICAL INITIAL no
     LABEL "Детализация по поставщикам"
     VIEW-AS TOGGLE-BOX
     SIZE 31 BY .83 TOOLTIP "Выводить информацию по поставщикам товара" NO-UNDO.

DEFINE VARIABLE tog-goods-from-am AS LOGICAL INITIAL no
     LABEL "Товары из Асс.матрицы"
     VIEW-AS TOGGLE-BOX
     SIZE 25.5 BY .83 TOOLTIP "Только товары из Ассортиментной матрицы объекта" NO-UNDO.

DEFINE VARIABLE tog-det-prizn AS LOGICAL INITIAL no
     LABEL "Детализация по признакам"
     VIEW-AS TOGGLE-BOX
     SIZE 31 BY .83 TOOLTIP "Детализировать шкальные товары по признакам" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     date-ship AT ROW 1 COL 20.5 COLON-ALIGNED
     date-p-1 AT ROW 2 COL 20.5 COLON-ALIGNED
     date-p-2 AT ROW 2 COL 37.5 COLON-ALIGNED
     g#type AT ROW 2 COL 53 NO-LABEL
     BUTTON-1 AT ROW 3.25 COL 2
     EDITOR-1 AT ROW 4.75 COL 1 NO-LABEL
     T-grp AT ROW 10 COL 5
     radio-column AT ROW 10 COL 37 NO-LABEL WIDGET-ID 2
     B-neword AT ROW 10 COL 67
     T-artic AT ROW 11 COL 5
     B-newcol AT ROW 12 COL 67 WIDGET-ID 8
     radio-gds-obj AT ROW 13.25 COL 5.5 NO-LABEL WIDGET-ID 10
     tog-goods-from-am AT ROW 14.25 COL 37 WIDGET-ID 20
     tog-det-post AT ROW 15.5 COL 5.5 WIDGET-ID 18
     tog-det-prizn AT ROW 15.5 COL 37 WIDGET-ID 22
     FILL-IN-1 AT ROW 9.25 COL 2.5 COLON-ALIGNED NO-LABEL
     FILL-IN-2 AT ROW 9.25 COL 35 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     FILL-IN-3 AT ROW 12.5 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     "Тип заказов" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 1.25 COL 53
          FGCOLOR 4
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields,Query
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 18.92
         WIDTH              = 92.75.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       EDITOR-1:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME B-newcol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-newcol V-table-Win
ON CHOOSE OF B-newcol IN FRAME F-Main
DO:
  run cus/secoallo.w (input my-handle).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-neword
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-neword V-table-Win
ON CHOOSE OF B-neword IN FRAME F-Main
DO:
  run cus/seqeallo.w .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 V-table-Win
ON CHOOSE OF BUTTON-1 IN FRAME F-Main /* Параметры расчета количества заказа */
DO:

  run cus/ord-m.w
     ( input my-handle , input "all-ord":u , g#type ) .
  editor-1 = e-method .
  display editor-1 with frame {&frame-name} .

find first ubflt.usr-flt  no-lock where                                  /* Детализация по признакам только для среднесуточного метода */
         ubflt.usr-flt.user-name    = v-cntxt-userid and
         ubflt.usr-flt.call-point   = "all-ord":U    no-error .
         if not avail ubflt.usr-flt  then do:
            message error-status :get-message(1) .
         end.
if integer(entry(2,(entry(3,ubflt.usr-flt.list_)), "=" )) = 1 and radio-column:screen-value = "no" then do :        /*   if  R-algoritm = 1  */
    enable tog-det-prizn with frame {&frame-name}.
end.
else do :
    hide tog-det-prizn .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME radio-column
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL radio-column V-table-Win
ON VALUE-CHANGED OF radio-column IN FRAME F-Main
DO:
    if radio-column:screen-value = "yes" then do :
        enable b-neword with frame {&frame-name} .
      hide b-newcol radio-gds-obj fill-in-3 tog-det-post tog-det-prizn.

    end.
    else do :
      find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name    = v-cntxt-userid and
         ubflt.usr-flt.call-point   = "all-ord":U    no-error .
         if not avail ubflt.usr-flt  then do:
            message error-status :get-message(1) .
         end.
        enable b-newcol radio-gds-obj fill-in-3 with frame {&frame-name} .
        hide b-neword .
        if radio-gds-obj:screen-value = "no" then do :
          enable tog-det-post with frame {&frame-name}.
        end.
      if (integer(entry(2,(entry(3,ubflt.usr-flt.list_)), "=" )) = 1) then do :              /* Детализация по признакам только для среднесуточного метода */
          enable tog-det-prizn with frame {&frame-name}.
      end.
    end.
    run save-usr-flt.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME radio-gds-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL radio-gds-obj V-table-Win
ON VALUE-CHANGED OF radio-gds-obj IN FRAME F-Main
DO:
  if radio-gds-obj:screen-value = "yes" then do :
      hide tog-det-post .
  end.
  else do :
      enable tog-det-post with frame {&frame-name}.
            end.
  run save-usr-flt.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-det-post
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-det-post V-table-Win
ON VALUE-CHANGED OF tog-det-post IN FRAME F-Main /* Детализация по поставщикам */
DO:
  run save-usr-flt.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-goods-from-am
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-goods-from-am V-table-Win
ON VALUE-CHANGED OF tog-goods-from-am IN FRAME F-Main /* Товары из Асс.матрицы */
DO:
  run save-usr-flt.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-det-prizn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-det-prizn V-table-Win
ON VALUE-CHANGED OF tog-det-prizn IN FRAME F-Main /* Товары из Асс.матрицы */
DO:
  run save-usr-flt.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win


/* ***************************  Main Block  *************************** */
  { gbl/personly.i }
  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  &ENDIF

    { gbl/ed_date.i date-ship}
    { gbl/ed_date.i date-p-1 }
    { gbl/ed_date.i date-p-2 }
    RUN my_init.
  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report V-table-Win
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

x-tog-artic = T-artic .
x-tog-grp   = T-grp   .
if radio-column then tog-det-prizn = false.
run cus/r-aord.p ( g#type ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var V-table-Win
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

ASSIGN frame {&frame-name} g#type T-grp T-artic
    date-p-1 date-p-2 date-ship .
    if date-p-1  > date-p-2 then do:
    message "Не верно введен интервал дат!" view-as alert-box error .
    return no-apply .
    end.
ASSIGN
    x-date-alone = date-ship
    x-date-start = date-p-1
    x-date-end   = date-p-2
    .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_init V-table-Win
PROCEDURE my_init :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-ii as integer no-undo.

    assign
    date-p-1  = TODAY + 1
    date-p-2  = TODAY + 31
    date-ship = TODAY + 1
    .

    run value-order-type in parent-handle (output g#type) .
    apply "choose" to button-1 in frame {&frame-name} .

    g#type:radio-buttons = "{&bef-o-p-full},{&bef-o-p},{&bef-o-f-full},{&bef-o-f},{&bef-f-p-full},{&bef-f-p},{&bef-o-o-full},{&bef-o-o}".
    run value-order-type in parent-handle (output g#type) .

    /*выставим начальные установки*/
    assign
      radio-column:screen-value = "yes"
      radio-gds-obj:screen-value = "yes"
      tog-det-post:screen-value = "yes"
      tog-goods-from-am:screen-value = "no"
      tog-det-prizn:screen-value = "no"
    .

    find first ubflt.usr-flt where
            ubflt.usr-flt.user-name    = v-cntxt-userid and
            ubflt.usr-flt.call-point   = "selrdallo":U
            no-error .
    if available ubflt.usr-flt then do:
      DO v-ii = 1 TO NUM-ENTRIES( ubflt.usr-flt.list_, {&delim-par}):
        CASE v-ii:
            WHEN 1 THEN DO:
              radio-column:screen-value      = ENTRY(v-ii, ubflt.usr-flt.list_, {&delim-par}).
            END.
            WHEN 2 THEN DO:
              radio-gds-obj:screen-value     = ENTRY(v-ii, ubflt.usr-flt.list_, {&delim-par}).
            END.
            WHEN 3 THEN DO:
              tog-det-post:screen-value      = ENTRY(v-ii, ubflt.usr-flt.list_, {&delim-par}).
            END.
            WHEN 4 THEN DO:
              tog-goods-from-am:screen-value = ENTRY(v-ii, ubflt.usr-flt.list_, {&delim-par}).
            END.
            WHEN 5 THEN DO:
              tog-det-prizn:screen-value     = ENTRY(v-ii, ubflt.usr-flt.list_, {&delim-par}).
            END.
        end case.
      end.
    end. /*if available ubflt.usr-flt */

    apply "value-changed" to radio-column in frame {&frame-name}.
DISPLAY date-p-1 date-p-2 date-ship EDITOR-1 g#type  FILL-IN-1 FILL-IN-2 FILL-IN-3 tog-det-post tog-det-prizn WITH FRAME {&FRAME-NAME}.
if radio-gds-obj:screen-value = "yes" then do :
    hide tog-det-post .
end.
else do :
    enable tog-det-post with frame {&frame-name}.
end.
if radio-column:screen-value = "yes" then hide FILL-IN-3 tog-det-post tog-det-prizn.
find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name    = v-cntxt-userid and
         ubflt.usr-flt.call-point   = "all-ord":U    no-error .
         if not avail ubflt.usr-flt  then do:
            message error-status :get-message(1) .
         end.
if integer(entry(2,(entry(3,ubflt.usr-flt.list_)), "=" )) = 1 and radio-column:screen-value = "no" then do :
    enable tog-det-prizn with frame {&frame-name}.
end.
else do :
    hide tog-det-prizn .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-usr-flt V-table-Win
PROCEDURE save-usr-flt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign frame {&frame-name}
   radio-column
   radio-gds-obj
   tog-det-post
   tog-goods-from-am
   tog-det-prizn
.
find first ubflt.usr-flt where
        ubflt.usr-flt.user-name    = v-cntxt-userid and
        ubflt.usr-flt.call-point   = "selrdallo":U
        no-error .
        if not available ubflt.usr-flt  then do:
              create  ubflt.usr-flt.
              assign
                ubflt.usr-flt.user-name  = v-cntxt-userid
                ubflt.usr-flt.call-point = "selrdallo":U
              .
        end.
        assign
            ubflt.usr-flt.list_ = string(radio-column)  + {&delim-par}
                                + string(radio-gds-obj) + {&delim-par}
                                + string(tog-det-post)  + {&delim-par}
                                + string(tog-goods-from-am) + {&delim-par}
                                + string(tog-det-prizn)
        .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME