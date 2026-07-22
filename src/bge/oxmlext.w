&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список внешних подсистем OpenXML

Автор: Хныкин Павел Андреевич
Дата создания: 09/09/05
Author: Pavel Khnykin
Creation date: 09/09/05

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as widget-handle  no-undo.
define input parameter bttns                as character      no-undo.
define input parameter p-list-mode          as character      no-undo.
define input parameter p-db-num-imp         as integer        no-undo.
define input parameter p-db-num-exp         as integer        no-undo.
define input parameter p-status             as character      no-undo.
define input parameter p-esys-type          as integer        no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список внешних подсистем OpenXML".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ gbl/cur-time.i    }
{ cmp/library.i     }
{ bge/oxmlext.i     }
{ gbl/getcntxt.i def }
{ cmp/showinf.i     }
{ gbl/color.i       }
{ gbl/waitfram.i    }

    define temp-table temp_select no-undo
        field sel-key   as integer
        field esys-id   as integer
        field db-num    as integer
        field selected  as logical

        index pi is primary unique
            sel-key
    .
    define variable v-oxmlext-selected-mark     as logical      no-undo.
    define variable v-oxmlext-status            as character    no-undo.
    define variable v-oxmlext-date              as character    no-undo.
define variable v-doc-rec as recid no-undo .
define variable v-last-list-mode            as character no-undo .
define variable v-last-esys-type            as integer   no-undo .

define variable func as character no-undo .

define buffer buf_init_ext-system for ext-system.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_init_ext-system

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table get-selected-mark ( buf_init_ext-system.esys-id, buf_init_ext-system.db-num ) @ v-oxmlext-selected-mark buf_init_ext-system.esys-id ( if buf_init_ext-system.esys-status = -1 then substitute( "новая&1", ( if buf_init_ext-system.esys-type > integer({&openxml-type-ordinal}) then " (сп)" else "" ) ) else ( if buf_init_ext-system.esys-status = 1 then substitute( "в работе&1", ( if buf_init_ext-system.esys-type > integer({&openxml-type-ordinal}) then " (сп)" else "" ) ) else substitute( "останов&1", ( if buf_init_ext-system.esys-type > integer({&openxml-type-ordinal}) then " (сп)" else "" ) ) ) ) @ v-oxmlext-status substring( string( buf_init_ext-system.esys-date-change, "99/99/9999" ), 1, 10 ) @ v-oxmlext-date buf_init_ext-system.esys-have-export buf_init_ext-system.esys-db-num-exp buf_init_ext-system.esys-have-import buf_init_ext-system.esys-db-num-imp buf_init_ext-system.esys-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define SELF-NAME br-table
&Scoped-define OPEN-QUERY-br-table /* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_ext-system no-lock . */ run Openbr in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-table buf_init_ext-system
&Scoped-define FIRST-TABLE-IN-QUERY-br-table buf_init_ext-system


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help filt-radio filt-1 filt-combo ~
b-add b-lkp b-chg b-del bt-on-off bt-export br-table ed-desc
&Scoped-Define DISPLAYED-OBJECTS filt-radio filt-1 filt-combo ed-desc

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-selected-mark Dialog-Frame
FUNCTION get-selected-mark returns logical
  ( p-esys-id as integer, p-db-num as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE MENU MENU-B-func
       MENU-ITEM m_exp-kontur  LABEL "Экспорт информации о структуре"     .
       
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
     
DEFINE BUTTON b-func
     LABEL "&Функции"
     SIZE 10 BY 1.     

DEFINE BUTTON b-sel
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON b-select
     LABEL "В&ыбор"
     SIZE 10 BY 1.

DEFINE BUTTON bt-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON bt-on-off
     LABEL "&Стоп"
     SIZE 10 BY 1.

DEFINE VARIABLE filt-combo AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Тип ВС"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "Item 1",0
     DROP-DOWN-LIST
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE ed-desc AS CHARACTER
     VIEW-AS EDITOR
     SIZE 98 BY 2.19 NO-UNDO.

DEFINE VARIABLE filt-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 19 BY .95 NO-UNDO.

DEFINE VARIABLE filt-radio AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Код", 1,
"Название", 2,
"БД импорта", 3,
"БД экспорта", 4
     SIZE 42 BY .95 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      buf_init_ext-system SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      get-selected-mark ( buf_init_ext-system.esys-id, buf_init_ext-system.db-num ) @ v-oxmlext-selected-mark   format " */  " column-label " * "
      buf_init_ext-system.esys-id
      ( if buf_init_ext-system.esys-status = -1
        then substitute( "новая&1", ( if buf_init_ext-system.esys-type > integer({&openxml-type-ordinal}) then " (сп)" else "" ) )
        else ( if buf_init_ext-system.esys-status = 1
               then substitute( "в работе&1", ( if buf_init_ext-system.esys-type > integer({&openxml-type-ordinal}) then " (сп)" else "" ) )
               else substitute( "останов&1", ( if buf_init_ext-system.esys-type > integer({&openxml-type-ordinal}) then " (сп)" else "" ) ) ) ) @ v-oxmlext-status                                                            FORMAT "X(15)"  column-label " Статус "
      substring( string( buf_init_ext-system.esys-date-change, "99/99/9999" ), 1, 10 ) @ v-oxmlext-date  FORMAT "X(10)"   COLUMN-LABEL "Дата"
      buf_init_ext-system.esys-have-export                                                                      format " +/ -"  column-label "Экс"
      buf_init_ext-system.esys-db-num-exp                                                                       format ">>>>9 " column-label "БДэкс"
      buf_init_ext-system.esys-have-import                                                                      format " +/ -"  column-label "Имп"
      buf_init_ext-system.esys-db-num-imp                                                                       format ">>>>9 " column-label "БДимп"
      buf_init_ext-system.esys-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.24.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-select AT ROW 1 COL 14
     b-help AT ROW 1 COL 95
     filt-radio AT ROW 2.19 COL 2 NO-LABEL
     filt-1 AT ROW 2.19 COL 43 COLON-ALIGNED NO-LABEL
     filt-combo AT ROW 2.19 COL 75 COLON-ALIGNED
     b-add AT ROW 3.62 COL 1
     b-lkp AT ROW 3.62 COL 11
     b-chg AT ROW 3.62 COL 21
     b-del AT ROW 3.62 COL 31
     b-func AT ROW 3.62 COL 41
     bt-on-off AT ROW 3.62 COL 41
     bt-export AT ROW 3.62 COL 51
     br-table AT ROW 4.81 COL 1
     ed-desc AT ROW 21.19 COL 1 NO-LABEL
     SPACE(0.59) SKIP(0.13)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список внешних подсистем OpenXML".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       B-func:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-func:HANDLE.
/* BROWSE-TAB br-table bt-export Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-select IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       ed-desc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_ext-system no-lock . */
run Openbr in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список внешних подсистем OpenXML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
    define variable v-have-rights    as logical        no-undo.
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_openxml-subsystem_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    yes
    v-have-rights
    }
    if v-have-rights = yes
    then do:
      if v-cntxt-db-num = 0 then do:
        if not (p-list-mode = "esys-type"
                or
                p-list-mode = "special")
        then do:
        define variable choice as integer no-undo .
        run gbl/d-askw.w (input "Добавление типа ВНЕШНЕЙ СИСТЕМЫ",
                          input  "Выбор типа ВНЕШНЕЙ СИСТЕМЫ",
                          input "|",
                          input "Внешняя система|Специальная|Отменить",
                          input "||",
                          input 1,
                          input 3,
                          output choice).
        if choice = 3
        then do:
            return no-apply.
        end.
      end.
      else do:
          if p-esys-type = integer({&openxml-type-ordinal}) then choice = 1.
          if p-esys-type > integer({&openxml-type-ordinal}) then choice = 2.
      end.
      end.
      else do:
        message
        "На текущий момент в УБД ВС добавлять запрещено"

        view-as alert-box error .
        return no-apply.
      end.
      run add-doc in this-procedure ( input integer((if choice = 1
                                                     then {&openxml-type-ordinal}
                                                     else {&openxml-type-special}))).
      run openbr in this-procedure .
      apply "value-changed" to br-table.
      apply "entry" to br-table.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_exp-kontur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_exp-kontur Dialog-Frame
ON CHOOSE OF MENU-ITEM m_exp-kontur /* Просмотр */
DO:
  assign
  func = "exp-kontur"
  .
  APPLY "CHOOSE" TO b-func IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-func
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-func Dialog-Frame
ON CHOOSE OF b-func IN FRAME Dialog-Frame /* Функции */
DO:
  if not available buf_init_ext-system THEN return no-apply.
  if func = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if func = "":U then do:
      return no-apply.
  end.
  if func = "exp-kontur" then do :
      if buf_init_ext-system.whole-send-news <> integer({&esys-dm-contour-edi}) then do :
          message "Данная функция доступна только для ВС с методом доставки " {&esys-dm-contour-edi-full} view-as alert-box .
      end.  
      else do :
          run waitfram-show in this-procedure ( input "Ждите... Идет экспорт информации в систему EDI" ).
          run cus/exp-clients_kontur.p (input parparentproc
                                       ,buffer buf_init_ext-system
                                       ) .
          run waitfram-hide in this-procedure .
          message "Экспорт завершен" view-as alert-box .                                       
      end.    
  end.    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable v-have-rights    as logical        no-undo.
define variable v-focused-row       as integer  no-undo.
define variable v-repositioned-row  as integer  no-undo.

  assign
  v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
  v-repositioned-row = current-result-row( "br-table" )
  .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_openxml-subsystem_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  yes
  v-have-rights
  }
  if v-have-rights = no
  then do:
      undo, return no-apply.
  end.
  if v-have-rights = yes
  and available buf_init_ext-system
  then do:
      run change-doc in this-procedure (
            input buf_init_ext-system.esys-id
          , input buf_init_ext-system.db-num
      ) no-error.
      if error-status :error
      then do:
          message
                    vss-workfile vss-revision vss-description
              skip "Ошибка изменения параметров внешней подсистемы."
              skip return-value
              skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply .
      end.
      apply "entry" to br-table.
      apply "value-changed" to br-table.
  end.
  run openbr in this-procedure .
  apply "value-changed" to br-table.
  apply "entry" to br-table.
  br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
  reposition br-table to row v-repositioned-row no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-can-delete        as logical  no-undo.

    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_openxml-subsystem_deletion':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    yes
    v-can-delete
    }
    if v-can-delete = no
    then do:
        undo, return no-apply.
    end.
    if v-can-delete = yes
    and available buf_init_ext-system
/*    and buf_init_ext-system.esys-status = 0*/
    then do:
        if buf_init_ext-system.esys-status <> 0
        and buf_init_ext-system.esys-type = integer({&openxml-type-ordinal})
        then do:
            message
                     "Для удаления внешней подсистемы"
                skip "надо сначала её остановить."
            view-as alert-box error.
            undo, return no-apply.
        end.
        assign
            v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-table" )
        .
        run delete-doc in this-procedure (
              input buf_init_ext-system.esys-id
            , input buf_init_ext-system.db-num
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка удаления информации о внешней подсистеме."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply.
        end.        /* if error-status :error */
        else do:
        end.        /* NOT ( if error-status :error ) */
        run openbr in this-procedure .
        apply "value-changed" to br-table.
        apply "entry" to br-table.
        if v-focused-row > 1
        then do:
            br-table :set-repositioned-row( v-focused-row - 1, "ALWAYS" ) in frame {&FRAME-NAME} .
            reposition br-table to row v-repositioned-row.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
or mouse-select-dblclick of br-table in frame dialog-frame
DO:
    define variable v-have-rights    as logical        no-undo.
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_openxml-subsystem_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    yes
    v-have-rights
    }
    if v-have-rights = yes
    and available buf_init_ext-system
    then do:
        run view-doc in this-procedure (
              input buf_init_ext-system.esys-id
            , input buf_init_ext-system.db-num
        ).
    end.        /* if available buf_init_ext-system */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON ROW-DISPLAY OF br-table IN FRAME Dialog-Frame
DO:
    if available buf_init_ext-system
    then do:
       if not ((p-list-mode = "esys-type"
               and buf_init_ext-system.esys-type > integer({&openxml-type-ordinal})
               )
               or
               p-list-mode = "special")
        then do:
            assign
                v-oxmlext-selected-mark                 :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-id             :bgcolor in browse br-table = gray_color
                v-oxmlext-status                        :bgcolor in browse br-table = gray_color
                v-oxmlext-date                          :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-have-export    :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-db-num-exp     :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-have-import    :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-db-num-imp     :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-name           :bgcolor in browse br-table = gray_color
            .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON VALUE-CHANGED OF br-table IN FRAME Dialog-Frame
DO:
    run manage-ed-desc in this-procedure.
    if available buf_init_ext-system
    then do:
       case buf_init_ext-system.esys-status
        :
            when 0
            then do:
                assign
                    bt-on-off :label = "&Пуск"
                .
            end.        /* when 0 */
            otherwise do:
                assign
                    bt-on-off :label = "&Стоп"
                .
            end.        /* otherwise */
        end case.       /* case buf_init_ext-system.esys-status */
        if buf_init_ext-system.esys-have-export = yes
        and buf_init_ext-system.esys-type = integer({&openxml-type-ordinal})  then do:
            enable
                bt-export
            with frame {&frame-name}.
        end.
        else do:
            disable
                bt-export
            with frame {&frame-name}.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-export Dialog-Frame
ON CHOOSE OF bt-export IN FRAME Dialog-Frame /* Экспорт */
DO:
    if available buf_init_ext-system
    then do:
        if buf_init_ext-system.esys-type > integer({&openxml-type-ordinal})  then do:
        message
        "Нелья экспортировать данные по ВС с типом СПЕЦИАЛЬНАЯ"
        view-as alert-box .
        return no-apply.
      end.
        run start-export in this-procedure (
              input buf_init_ext-system.esys-id
            , input buf_init_ext-system.db-num
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка экспорта по выбранной внешней подсистеме."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-on-off
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-on-off Dialog-Frame
ON CHOOSE OF bt-on-off IN FRAME Dialog-Frame /* Стоп */
DO:
    define variable v-have-rights    as logical        no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_openxml-subsystem_on-off':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    yes
    v-have-rights
    }
    if v-have-rights = yes
    and available buf_init_ext-system
    then do:
        assign
            v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-table" )
        .
        run on-off-doc in this-procedure (
              input buf_init_ext-system.esys-id
            , input buf_init_ext-system.db-num
        ).
        run openbr in this-procedure .
        apply "value-changed" to br-table.
        apply "entry" to br-table.
        br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
        reposition br-table to row v-repositioned-row no-error.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filt-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filt-1 Dialog-Frame
ON return OF filt-1 IN FRAME Dialog-Frame
DO:
    if filt-radio = 1 or filt-radio = 3 or filt-radio = 4 then do:
        int(filt-1:screen-value) no-error.
        if error-status:error then do:
            assign filt-1:screen-value = '' .
            return no-apply.
        end.
    end.

    assign filt-1 .

    run openbr in this-procedure .
    apply "value-changed" to br-table.
    apply "entry" to br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filt-combo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filt-combo Dialog-Frame
ON VALUE-CHANGED OF filt-combo IN FRAME Dialog-Frame /* Тип ВС */
DO:
    /*если меняется с нуля, то сохраняем p-list-mode*/
    if filt-combo = 0 then do:
        assign
        v-last-list-mode = p-list-mode
        v-last-esys-type = p-esys-type
        p-list-mode      = "esys-type"
        .
    end.

    /*присваиваем filt-combo новое значение*/
    assign filt-combo .

    if filt-combo > 0 then assign p-esys-type = filt-combo .
    else do:
        /*если меняем на ноль, то возвращаем p-list-mode и p-esys-type их значение*/
        assign
        p-esys-type = v-last-esys-type
        p-list-mode = v-last-list-mode
        .
    end.

    run openbr in this-procedure .
    apply "value-changed" to br-table.
    apply "entry" to br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filt-radio
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filt-radio Dialog-Frame
ON VALUE-CHANGED OF filt-radio IN FRAME Dialog-Frame
DO:
  assign filt-radio .

  run openbr in this-procedure .
  apply "value-changed" to br-table.
  apply "entry" to br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }
{ gbl/brwrefre.i " v-doc-rec = (if available buf_init_ext-system then recid(buf_init_ext-system) else ? ). run Openbr in this-procedure . ~
                  reposition br-table to recid v-doc-rec no-error. APPLY 'entry' to br-table.  " }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    IF LOOKUP(p-list-mode, {&ALL} + {&comma-char} + "esys-type" + {&comma-char} + "special") = 0 THEN DO:
       MESSAGE
       SUBSTITUTE("Неверное значение параметра p-list-mode= &1", p-list-mode)
       VIEW-AS ALERT-BOX ERROR.
       UNDO, RETURN ERROR.
    END.
    { gbl/getcntxt.i get  }
  RUN MyEnable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-doc Dialog-Frame
PROCEDURE add-doc :
define input parameter p-esys-type as integer no-undo .
    define variable v-esys-id    as integer      no-undo.
    define variable v-success    as logical      no-undo.

    define buffer buf_ext-system        for ub.ext-system.

do
for buf_ext-system
on error undo, return error
:
    do transaction
    on error undo, return error
    :
       case p-esys-type:
         when integer({&openxml-type-ordinal}) then do:
            run oxmlext-create in this-procedure (
                  input parparentproc
                , input v-cntxt-db-num
                , output v-esys-id
            ).
            run bge/oxmlextd.w (
                  input parparentproc
                , input this-procedure
                , input {&add-def}
                , input v-esys-id
                , input v-cntxt-db-num
                , input v-cntxt-db-num
                , output v-success
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания записи внешней подсистемы."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_ext-system exclusive-lock
                where buf_ext-system.esys-id = v-esys-id
                  and buf_ext-system.db-num  = v-cntxt-db-num
            no-error.
            if available buf_ext-system
            then do:
                if v-success = no
                then do:
                    delete buf_ext-system.
                end.
                else do:
                    { trg/btpr_upd.i
                        &btpr-status="create"
                        &btpr-type="{&btpr-type-oxml-new}"
                        &key#_one=buf_ext-system.esys-id
                        &key#_two=buf_ext-system.db-num
                        &btpr_user_id=v-cntxt-userid
                    }
                end.
            end.
            else do:
                if v-success = yes
                then do:
                    message
                            vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка (2) создания записи внешней подсистемы."
                        skip return-value
                        skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
          end.
          when integer({&openxml-type-special}) then do:
           run bge/oxmlspci.w (
                              input parparentproc
                            , input {&add-def}
                            , input-output v-esys-id
                            , input 0 /*p-db-num*/
                            , output v-success
                            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания записи внешней подсистемы."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
          end.
        end case.
    end.        /* do transaction */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-doc Dialog-Frame
PROCEDURE change-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    if available buf_init_ext-system
    then do:
      case buf_init_ext-system.esys-type :
       when integer({&openxml-type-ordinal}) then do:
        run bge/oxmlextd.w (
              input parparentproc
            , input this-procedure
            , input {&update}
            , input p-esys-id
            , input p-db-num
            , input v-cntxt-db-num
            , output v-success
        ) no-error.
       end.
       otherwise do:
        run bge/oxmlspci.w (
              input parparentproc
            , input {&update}
            , input-output p-esys-id
            , input p-db-num
            , output v-success
        ) no-error.

       end.
      end case.
      if error-status :error
      then do:
          message
                  vss-workfile vss-revision vss-description
              skip(1)
              skip "Ошибка изменения записи внешней подсистемы."
              skip return-value
              skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return error .
      end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear-mark Dialog-Frame
PROCEDURE clear-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

    define buffer buf_temp_select       for temp_select.
do
for buf_temp_select
on error undo, return error
:
    find first buf_temp_select
         where buf_temp_select.esys-id = p-esys-id
           and buf_temp_select.db-num  = p-db-num
    no-error.
    if available buf_temp_select
    then do:
        assign
            buf_temp_select.selected = no
        .
    end.
end.
END PROCEDURE. /* clear-mark */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-doc Dialog-Frame
PROCEDURE delete-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

    define variable v-yesno    as logical        no-undo.

    define buffer buf_ext-system       for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    no-error.
    if available buf_ext-system
    then do:
        assign
            v-yesno = no
        .
        message
                 "Удаление подсистемы."
            skip (1)
            skip "Внешняя подсистема:"
            skip "  номер   " buf_ext-system.esys-id
            skip "  БД номер" buf_ext-system.db-num
            skip "  имя     " buf_ext-system.esys-name
            skip (1)
            skip "Удалить внешнюю подсистему?"
        view-as alert-box information
        buttons yes-no
        title "Удаление подсистемы"
        update v-yesno.
        if v-yesno = yes
        then do:
           if buf_ext-system.esys-type > integer({&openxml-type-ordinal}) then do:
             run bge/extsyss3.p ( input no /*p-silent*/
                                 ,input recid(buf_ext-system)) no-error.
             if error-status :error then do:
               undo, return error ''.
             end.
           end.
           else do:
              define buffer buf_BatchProcess      for ub.BatchProcess.
              { trg/btpr_upd.i
                  &btpr-status="find"
                  &btpr-type="{&btpr-type-oxml-new}"
                  &btpr-table="buf_BatchProcess"
                  &btpr-lock-option="exclusive-lock"
                  &key#_one=buf_ext-system.esys-id
                  &key#_two=buf_ext-system.db-num
              }
              if available buf_BatchProcess
              then do:
                  delete buf_BatchProcess.
              end.
              delete buf_ext-system.
           end.
        end.        /* if v-yesno = yes */
    end.        /* if available buf_ext-system */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY filt-radio filt-1 filt-combo ed-desc
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help filt-radio filt-1 filt-combo b-add b-lkp b-chg b-del
         bt-on-off bt-export br-table ed-desc
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-mark Dialog-Frame
PROCEDURE get-mark :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
define output parameter p-mark      as logical          no-undo.

    define buffer buf_temp_select       for temp_select.
do
for buf_temp_select
on error undo, return error
:
    find first buf_temp_select
         where buf_temp_select.esys-id = p-esys-id
           and buf_temp_select.db-num  = p-db-num
    no-error.
    if available buf_temp_select
    then do:
        assign
            p-mark = buf_temp_select.selected
        .
    end.
    else do:
        assign
            p-mark = no
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-ed-desc Dialog-Frame
PROCEDURE manage-ed-desc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
    if available buf_init_ext-system
    then do:
        assign
            ed-desc :screen-value = buf_init_ext-system.esys-des
        .
    end.
end.
END PROCEDURE. /* manage-ed-desc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS integer NO-UNDO.

DISPLAY ed-desc
WITH FRAME {&frame-name}.
/*заполняем фильтр по типу ВС*/
do v-ii = 1 to num-entries({&openxml-special-type-list}):
  &scop openxml-type-code string(v-ii)
  assign
  filt-combo:list-item-pairs in frame {&frame-name} =
  (if v-ii = 1
  then ({&comma-char} + "0"  + {&comma-char} +  {&openxml-type-name}  + {&comma-char} +  entry(v-ii, {&openxml-special-type-list}))
  else (filt-combo:list-item-pairs + {&comma-char} +
         {&openxml-type-name}  + {&comma-char} +  entry(v-ii, {&openxml-special-type-list}))

  )
  .
end.

b-func:MENU-MOUSE IN frame {&FRAME-NAME} = 1 .

ENABLE
b-exit
b-help
b-add WHEN (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and not transaction)
b-lkp
b-func
b-chg WHEN (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and not transaction)
b-del WHEN (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and not transaction)
bt-on-off when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and not transaction)
bt-export  when  not transaction
br-table
filt-radio
ed-desc
filt-1
filt-combo
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.

/*если список выбран по типу ВС, то фильтр не нужен*/
if p-list-mode = "esys-type" then do:
   DISABLE
   filt-combo
   WITH FRAME {&FRAME-NAME}.
   HIDE
   filt-combo
   in FRAME {&FRAME-NAME}.
end.

IF (p-list-mode = "esys-type"
AND p-esys-type > integer({&openxml-type-ordinal}))
or p-list-mode = "special"
THEN DO:
   DISABLE
   bt-on-off
   bt-export
   WITH FRAME {&FRAME-NAME}.
   HIDE
   bt-on-off
   bt-export
   in FRAME {&FRAME-NAME}.
END.

/*инициализируем смешанный фильр*/
assign filt-radio .

run openbr in this-procedure .
apply "value-changed" to br-table.
apply "entry" to br-table.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE on-off-doc Dialog-Frame
PROCEDURE on-off-doc :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

    define variable v-yesno    as logical      no-undo.

    define buffer buf_ext-system        for ub.ext-system.
do
on error undo, return error
:
    find first buf_ext-system no-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 0
    then do:
        message
                    "Запуск подсистемы."
            skip (1)
            skip "Внешняя подсистема:"
            skip "  номер   " buf_ext-system.esys-id
            skip "  БД номер" buf_ext-system.db-num
            skip "  имя     " buf_ext-system.esys-name
            skip (1)
            skip "Запустить внешнюю подсистему?"
        view-as alert-box information
        buttons yes-no
        title "Запуск подсистемы"
        update v-yesno.
        if v-yesno = yes
        then do:
            run oxmlext-start-subsystem in this-procedure (
                  input p-esys-id
                , input p-db-num
            ).
        end.
    end.
    else do:
        message
                 "Остановка подсистемы."
            skip (1)
            skip "Внешняя подсистема:"
            skip "  номер   " buf_ext-system.esys-id
            skip "  БД номер" buf_ext-system.db-num
            skip "  имя     " buf_ext-system.esys-name
            skip (1)
            skip "Остановить внешнюю подсистему?"
        view-as alert-box information
        buttons yes-no
        title "Остановка подсистемы"
        update v-yesno.
        if v-yesno = yes
        then do:
            run oxmlext-stop-subsystem in this-procedure (
                  input p-esys-id
                , input p-db-num
            ).
        end.
    end.

end.
END PROCEDURE. /* on-off-doc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&ALL} THEN DO:
      if v-cntxt-db-num = 0
      then do:
          open query {&browse-name}
          for each buf_init_ext-system no-lock
         where { bge/oxmlext1.i }
          by buf_init_ext-system.esys-date-change descending
          .
      end.
      else do:
          open query {&browse-name}
          for each buf_init_ext-system no-lock
          where (buf_init_ext-system.esys-db-num-imp = v-cntxt-db-num
              or buf_init_ext-system.esys-db-num-exp = v-cntxt-db-num
              or buf_init_ext-system.esys-type = integer({&openxml-type-mercury}) )
            and { bge/oxmlext1.i }
          by buf_init_ext-system.esys-date-change descending
          .
      end.
  END.
  WHEN "esys-type" THEN DO:
      if v-cntxt-db-num = 0
      then do:
          open query {&browse-name}
          for each buf_init_ext-system no-lock
              WHERE buf_init_ext-system.esys-type = p-esys-type
            and { bge/oxmlext1.i }
          by buf_init_ext-system.esys-date-change descending
          .
      end.
      else do:
          open query {&browse-name}
          for each buf_init_ext-system no-lock
             WHERE buf_init_ext-system.esys-type = p-esys-type
          AND (buf_init_ext-system.esys-db-num-imp = v-cntxt-db-num
                or buf_init_ext-system.esys-db-num-exp = v-cntxt-db-num
                or buf_init_ext-system.esys-type = integer({&openxml-type-mercury}) )
          and { bge/oxmlext1.i }
          by buf_init_ext-system.esys-date-change descending
          .
      end.
    &scop openxml-type-code string(p-esys-type)
    assign
    frame {&frame-name}:title = substitute("Список внешних подсистем с типом &1", {&openxml-type-name}).
  END.
  WHEN "special" THEN DO:
    if v-cntxt-db-num = 0
    then do:
          open query {&browse-name}
          for each buf_init_ext-system no-lock
              WHERE buf_init_ext-system.esys-type > integer({&openxml-type-ordinal})
                and { bge/oxmlext1.i }
          by buf_init_ext-system.esys-date-change descending
          .
    end.
    else do:
        open query {&browse-name}
        for each buf_init_ext-system no-lock
          WHERE buf_init_ext-system.esys-type > integer({&openxml-type-ordinal})
            AND (buf_init_ext-system.esys-db-num-imp = v-cntxt-db-num
              or buf_init_ext-system.esys-db-num-exp = v-cntxt-db-num
              or buf_init_ext-system.esys-type = integer({&openxml-type-mercury})
              or buf_init_ext-system.esys-type = integer({&openxml-type-is_motp}) 
              or buf_init_ext-system.esys-type = integer({&openxml-type-special}))
            and { bge/oxmlext1.i }
        by buf_init_ext-system.esys-date-change descending
        .
    end.
    assign
    frame {&frame-name}:title = substitute("Список СПЕЦИАЛЬНЫХ внешних подсистем").

  END. /*WHEN "special" THEN DO:*/
END CASE.


 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-to-recid Dialog-Frame
PROCEDURE reposition-to-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-ext-system-recid  as recid        no-undo.
do
on error undo, return error
:
    if p-ext-system-recid <> ?
    then do:
        reposition br-table to recid p-ext-system-recid no-error .
    end.
    do with frame {&frame-name}
    :
        apply "entry":u to browse {&browse-name} .
    end. /* do with frame */

end.
END PROCEDURE. /* reposition-to-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-mark Dialog-Frame
PROCEDURE set-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

    define buffer buf_temp_select       for temp_select.
do
for buf_temp_select
on error undo, return error
:
    find first buf_temp_select
         where buf_temp_select.esys-id = p-esys-id
           and buf_temp_select.db-num  = p-db-num
    no-error.
    if available buf_temp_select
    then do:
        assign
            buf_temp_select.selected = yes
        .
    end.
end.
END PROCEDURE. /* set-mark */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE start-export Dialog-Frame
PROCEDURE start-export :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-cur-db-num    as integer      no-undo.
do
on error undo, return error
:
    { gbl/curdbnum.i
        v-cur-db-num
    }
    run str/diallog.w (
          input parparentproc
        , input this-procedure
        , input "bge/oxmlouta.p":U
        , input substitute( "&1,&2,&3", v-cur-db-num, p-esys-id, p-db-num )
        , input no
        , input "&Стоп"
        , input "Начальная выгрузка по внешней системе Open XML"
    ).
end.
END PROCEDURE. /* start-export */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-doc Dialog-Frame
PROCEDURE view-doc :
define input parameter p-esys-id    as character    no-undo.
define input parameter p-db-num     as integer          no-undo.

    define variable v-success    as logical      no-undo.
do
on error undo, return error
:

    if available buf_init_ext-system
    then do:
      case buf_init_ext-system.esys-type :
        when integer({&openxml-type-ordinal}) then do:
          run bge/oxmlextd.w (
                input parparentproc
              , input this-procedure
              , input {&lookup}
              , input p-esys-id
              , input p-db-num
              , input v-cntxt-db-num
              , output v-success
          ) no-error.
        end.
        otherwise do:
          run bge/oxmlspci.w (
                input parparentproc
              , input {&lookup}
              , input-output p-esys-id
              , input p-db-num
              , output v-success
          ) no-error.
        end.
      end case.
      if error-status :error
      then do:
          message
                  vss-workfile vss-revision vss-description
              skip(1)
              skip "Ошибка просмотра записи внешней подсистемы."
              skip return-value
              skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return error .
      end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-selected-mark Dialog-Frame
FUNCTION get-selected-mark returns logical
  ( p-esys-id as integer, p-db-num as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
    define variable v-mark  as logical    no-undo.

    run get-mark in this-procedure (
          input p-esys-id
        , input p-db-num
        , output v-mark  ).

    return v-mark.   /* Function return value. */

end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
