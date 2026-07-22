&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_dis-propf FOR ub.dis-card-property.
DEFINE BUFFER X_dis-prop_ FOR ub.dis-card-property.
DEFINE BUFFER X_dis-prop_host FOR ub.dis-card-property.
DEFINE BUFFER X_dis-prop_obj FOR ub.dis-card-property.
DEFINE BUFFER X_prop-map_ FOR ub.prop-map.
DEFINE BUFFER X_prop-map_host FOR ub.prop-map.
DEFINE BUFFER X_prop-map_obj FOR ub.prop-map.
DEFINE BUFFER X_prop-ref_ FOR ub.prop-ref.
DEFINE BUFFER X_prop-ref_host FOR ub.prop-ref.
DEFINE BUFFER X_prop-ref_obj FOR ub.prop-ref.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список dis-card-property


Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
define input parameter p-curr-host-code as integer no-undo .
define input parameter p-curr-obj-type as character no-undo .
define input parameter p-curr-obj-code as integer no-undo .
define input parameter p-list-mode as character no-undo .
/*{&all} dtm-code dt-code dt-node-code node-code*/
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
define input parameter p-dtm-code as integer no-undo .
define input parameter p-dt-code as integer no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список dis-card-property".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/color.i }
{ cmp/operlist.i }
{ gbl/fltopend.i defproc }

DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable filter-point-label as character no-undo init "Свойства ДК" .
define variable filter-point0 as character no-undo init "discprps" .
define variable filter-point as character no-undo init "discprps" .
define variable v-list-mode as character no-undo .
define variable v-short-mode as logical no-undo .
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.

DEFINE VARIABLE v-ch_ AS WIDGET-HANDLE NO-UNDO EXTENT 5.
DEFINE VARIABLE v-ch_host AS WIDGET-HANDLE NO-UNDO EXTENT 5.
DEFINE VARIABLE v-ch_obj AS WIDGET-HANDLE NO-UNDO EXTENT 5.

&scoped-define label-clmn_character "Значение!(строковое)"
&scoped-define label-clmn_date "Значение!(Дата)"
&scoped-define label-clmn_decimal "Значение!(Десятичное)"
&scoped-define label-clmn_integer "Значение!(Целое)"
&scoped-define label-clmn_logical "Значение!(Логическое)"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-prop_

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-prop_ X_prop-ref_ X_prop-map_ ~
X_dis-prop_host X_prop-ref_host X_prop-map_host X_dis-prop_obj ~
X_prop-ref_obj X_prop-map_obj

/* Definitions for BROWSE br-dis-prop_                                  */
&Scoped-define FIELDS-IN-QUERY-br-dis-prop_ mark-string(recid(X_dis-prop_), v-rid-list) X_prop-ref_.sum-id X_prop-ref_.dtm-code X_dis-prop_.d-card X_prop-map_.node-name (IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-character} THEN display-character(X_dis-prop_.property-value-character, X_prop-map_.node-format) ELSE '':U) (IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-date} THEN STRING(X_dis-prop_.property-value-date, X_prop-map_.node-format) ELSE '':U) (IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-decimal} THEN STRING(X_dis-prop_.property-value-decimal, X_prop-map_.node-format) ELSE '':U) (IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-integer} THEN STRING(X_dis-prop_.property-value-integer, X_prop-map_.node-format) ELSE '':U) (IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-logical} THEN STRING(X_dis-prop_.property-value-logical, X_prop-map_.node-format) ELSE '':U) X_prop-ref_.caller_id   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-prop_   
&Scoped-define SELF-NAME br-dis-prop_
&Scoped-define QUERY-STRING-br-dis-prop_ FOR EACH X_dis-prop_ NO-LOCK, ~
           FIRST X_prop-ref_ NO-LOCK WHERE          X_prop-ref_.dt-code = X_dis-prop_.dt-code, ~
           FIRST X_prop-map_  WHERE          X_prop-map_.dtm-code = X_dis-prop_.dtm-code     AND X_prop-map_.node-code = X_dis-prop_.node-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-prop_ OPEN QUERY br-dis-prop_ FOR EACH X_dis-prop_ NO-LOCK, ~
           FIRST X_prop-ref_ NO-LOCK WHERE          X_prop-ref_.dt-code = X_dis-prop_.dt-code, ~
           FIRST X_prop-map_  WHERE          X_prop-map_.dtm-code = X_dis-prop_.dtm-code     AND X_prop-map_.node-code = X_dis-prop_.node-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-prop_ X_dis-prop_ X_prop-ref_ ~
X_prop-map_
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-prop_ X_dis-prop_
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-prop_ X_prop-ref_
&Scoped-define THIRD-TABLE-IN-QUERY-br-dis-prop_ X_prop-map_


/* Definitions for BROWSE br-dis-prop_host                              */
&Scoped-define FIELDS-IN-QUERY-br-dis-prop_host mark-string(recid(X_dis-prop_host), v-rid-list) X_prop-ref_host.sum-id X_prop-ref_host.dtm-code X_dis-prop_host.d-card X_dis-prop_host.host-code X_prop-map_host.node-name (IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-character} THEN display-character(X_dis-prop_host.property-value-character, X_prop-map_host.node-format) ELSE '':U) (IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-date} THEN STRING(X_dis-prop_host.property-value-date, X_prop-map_host.node-format) ELSE '':U) (IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-decimal} THEN STRING(X_dis-prop_host.property-value-decimal, X_prop-map_host.node-format) ELSE '':U) (IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-integer} THEN STRING(X_dis-prop_host.property-value-integer, X_prop-map_host.node-format) ELSE '':U) (IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-logical} THEN STRING(X_dis-prop_host.property-value-logical, X_prop-map_host.node-format) ELSE '':U) X_prop-ref_host.caller_id   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-prop_host   
&Scoped-define SELF-NAME br-dis-prop_host
&Scoped-define QUERY-STRING-br-dis-prop_host FOR EACH X_dis-prop_host NO-LOCK, ~
           FIRST X_prop-ref_host NO-LOCK WHERE          X_prop-ref_host.dt-code = X_dis-prop_host.dt-code , ~
           FIRST X_prop-map_host WHERE          X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code     AND X_prop-map_host.node-code = X_dis-prop_host.node-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-prop_host OPEN QUERY br-dis-prop_host FOR EACH X_dis-prop_host NO-LOCK, ~
           FIRST X_prop-ref_host NO-LOCK WHERE          X_prop-ref_host.dt-code = X_dis-prop_host.dt-code , ~
           FIRST X_prop-map_host WHERE          X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code     AND X_prop-map_host.node-code = X_dis-prop_host.node-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-prop_host X_dis-prop_host ~
X_prop-ref_host X_prop-map_host
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-prop_host X_dis-prop_host
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-prop_host X_prop-ref_host
&Scoped-define THIRD-TABLE-IN-QUERY-br-dis-prop_host X_prop-map_host


/* Definitions for BROWSE br-dis-prop_obj                               */
&Scoped-define FIELDS-IN-QUERY-br-dis-prop_obj mark-string(recid(X_dis-prop_obj), v-rid-list) X_prop-ref_obj.sum-id X_prop-ref_obj.dtm-code X_dis-prop_obj.d-card X_dis-prop_obj.obj-code X_dis-prop_obj.obj-type X_prop-map_obj.node-name (IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-character} THEN display-character(X_dis-prop_obj.property-value-character, X_prop-map_obj.node-format) ELSE '':U) (IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-date} THEN STRING(X_dis-prop_obj.property-value-date, X_prop-map_obj.node-format) ELSE '':U) (IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-decimal} THEN STRING(X_dis-prop_obj.property-value-decimal, X_prop-map_obj.node-format) ELSE '':U) (IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-integer} THEN STRING(X_dis-prop_obj.property-value-integer, X_prop-map_obj.node-format) ELSE '':U) (IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-logical} THEN STRING(X_dis-prop_obj.property-value-logical, X_prop-map_obj.node-format) ELSE '':U) X_prop-ref_obj.caller_id   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-prop_obj   
&Scoped-define SELF-NAME br-dis-prop_obj
&Scoped-define QUERY-STRING-br-dis-prop_obj FOR EACH X_dis-prop_obj NO-LOCK, ~
           FIRST X_prop-ref_obj NO-LOCK WHERE          X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code , ~
           FIRST X_prop-map_obj  WHERE           X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code       AND X_prop-map_obj.node-code = X_dis-prop_obj.node-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-prop_obj OPEN QUERY br-dis-prop_obj FOR EACH X_dis-prop_obj NO-LOCK, ~
           FIRST X_prop-ref_obj NO-LOCK WHERE          X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code , ~
           FIRST X_prop-map_obj  WHERE           X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code       AND X_prop-map_obj.node-code = X_dis-prop_obj.node-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-prop_obj X_dis-prop_obj ~
X_prop-ref_obj X_prop-map_obj
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-prop_obj X_dis-prop_obj
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-prop_obj X_prop-ref_obj
&Scoped-define THIRD-TABLE-IN-QUERY-br-dis-prop_obj X_prop-map_obj


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-dis-prop_}~
    ~{&OPEN-QUERY-br-dis-prop_host}~
    ~{&OPEN-QUERY-br-dis-prop_obj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel rs-region b-lkp b-card ~
b-sch B-print b-history B-Help b-dtm-code b-dt-code br-dis-prop_obj ~
br-dis-prop_host br-dis-prop_ mark-num 
&Scoped-Define DISPLAYED-OBJECTS rs-region f-dtm-code f-dtm-name f-dt-code ~
f-sum-id f-node-code f-node-label mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD display-character Dialog-Frame 
FUNCTION display-character RETURNS CHARACTER
  (  INPUT p-character AS CHARACTER, INPUT p-format AS CHARACTER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-card 
     LABEL "Карта" 
     SIZE 10 BY 1.

DEFINE BUTTON b-dt-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3" 
     SIZE 3 BY 1.

DEFINE BUTTON b-dtm-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3" 
     SIZE 3 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-history 
     LABEL "Ис&тория" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 4 BY 1.

DEFINE BUTTON b-node-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3" 
     SIZE 3 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Выбор" 
     SIZE 10 BY 1.

DEFINE VARIABLE f-dt-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Код среза" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dtm-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Код объекта" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dtm-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 72.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-node-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Код св-ва" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-node-label AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 72.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-sum-id AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 31.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE rs-region AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Объекты", "1",
"Фирмы", "2",
"Глобально", "3"
     SIZE 30 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-prop_ FOR
                X_dis-prop_,
                X_prop-ref_,
                X_prop-map_ SCROLLING.


DEFINE QUERY br-dis-prop_host FOR
                X_dis-prop_host,
                X_prop-ref_host,
                X_prop-map_host SCROLLING.


DEFINE QUERY br-dis-prop_obj FOR
                X_dis-prop_obj,
                X_prop-ref_obj,
                X_prop-map_obj SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-prop_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-prop_ Dialog-Frame _FREEFORM
  QUERY br-dis-prop_ NO-LOCK DISPLAY
      mark-string(recid(X_dis-prop_), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-ref_.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_prop-map_.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
(IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-character}
THEN display-character(X_dis-prop_.property-value-character, X_prop-map_.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_character} format "X(255)" WIDTH 40
(IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-date}
THEN STRING(X_dis-prop_.property-value-date,  X_prop-map_.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_date} format "X(10)"
(IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-decimal}
THEN STRING(X_dis-prop_.property-value-decimal, X_prop-map_.node-format)
ELSE '':U)  COLUMN-LABEL {&label-clmn_decimal} format "X(24)"
(IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-integer}
THEN STRING(X_dis-prop_.property-value-integer, X_prop-map_.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_integer} format "X(14)"
(IF entry(1, X_prop-map_.node-value-type) = {&abl-datatype-logical}
THEN STRING(X_dis-prop_.property-value-logical, X_prop-map_.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_logical} FORMAT "X(2)"
X_prop-ref_.caller_id COLUMN-LABEL "Доп!Идентификатор"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.87
         FONT 4 FIT-LAST-COLUMN.

DEFINE BROWSE br-dis-prop_host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-prop_host Dialog-Frame _FREEFORM
  QUERY br-dis-prop_host NO-LOCK DISPLAY
      mark-string(recid(X_dis-prop_host), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-ref_host.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_host.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_host.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-prop_host.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>9"
X_prop-map_host.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
(IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-character}
THEN display-character(X_dis-prop_host.property-value-character, X_prop-map_host.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_character} format "X(255)" WIDTH 40
(IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-date}
THEN STRING(X_dis-prop_host.property-value-date,  X_prop-map_host.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_date} format "X(10)"
(IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-decimal}
THEN STRING(X_dis-prop_host.property-value-decimal, X_prop-map_host.node-format)
ELSE '':U)  COLUMN-LABEL {&label-clmn_decimal} format "X(24)"
(IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-integer}
THEN STRING(X_dis-prop_host.property-value-integer, X_prop-map_host.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_integer} format "X(14)"
(IF entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-logical}
THEN STRING(X_dis-prop_host.property-value-logical, X_prop-map_host.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_logical} FORMAT "X(2)"
X_prop-ref_host.caller_id COLUMN-LABEL "Доп!Идентификатор"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.87
         FONT 4 FIT-LAST-COLUMN.

DEFINE BROWSE br-dis-prop_obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-prop_obj Dialog-Frame _FREEFORM
  QUERY br-dis-prop_obj NO-LOCK DISPLAY
      mark-string(recid(X_dis-prop_obj), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-ref_obj.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_obj.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_obj.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-prop_obj.obj-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>9"
X_dis-prop_obj.obj-type COLUMN-LABEL "Тип!объекта" FORMAT "X(3)"
X_prop-map_obj.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
(IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-character}
THEN display-character(X_dis-prop_obj.property-value-character, X_prop-map_obj.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_character} format "X(255)" WIDTH 40
(IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-date}
THEN STRING(X_dis-prop_obj.property-value-date,  X_prop-map_obj.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_date} format "X(10)"
(IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-decimal}
THEN STRING(X_dis-prop_obj.property-value-decimal, X_prop-map_obj.node-format)
ELSE '':U)  COLUMN-LABEL {&label-clmn_decimal} format "X(24)"
(IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-integer}
THEN STRING(X_dis-prop_obj.property-value-integer, X_prop-map_obj.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_integer} format "X(14)"
(IF entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-logical}
THEN STRING(X_dis-prop_obj.property-value-logical, X_prop-map_obj.node-format)
ELSE '':U) COLUMN-LABEL {&label-clmn_logical} FORMAT "X(2)"
X_prop-ref_obj.caller_id COLUMN-LABEL "Доп!Идентификатор"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.87
         FONT 4 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 21 WIDGET-ID 12
     b-sel AT ROW 1 COL 25 WIDGET-ID 10
     rs-region AT ROW 1 COL 35 NO-LABEL WIDGET-ID 26
     b-lkp AT ROW 1 COL 66 WIDGET-ID 6
     b-card AT ROW 1 COL 76 WIDGET-ID 16
     b-sch AT ROW 1 COL 86 WIDGET-ID 2
     B-print AT ROW 1 COL 89 WIDGET-ID 20
     b-history AT ROW 1 COL 92 WIDGET-ID 18
     B-Help AT ROW 1 COL 95
     f-dtm-code AT ROW 2 COL 1 WIDGET-ID 34
     b-dtm-code AT ROW 2 COL 22.5 WIDGET-ID 32
     f-dtm-name AT ROW 2 COL 25.5 NO-LABEL WIDGET-ID 30
     f-dt-code AT ROW 3 COL 3 WIDGET-ID 36
     b-dt-code AT ROW 3 COL 22.5 WIDGET-ID 38
     f-sum-id AT ROW 3 COL 25.5 NO-LABEL WIDGET-ID 40
     f-node-code AT ROW 4 COL 3 WIDGET-ID 44
     b-node-code AT ROW 4 COL 22.5 WIDGET-ID 42
     f-node-label AT ROW 4 COL 25.5 NO-LABEL WIDGET-ID 46
     br-dis-prop_obj AT ROW 5 COL 1.5 WIDGET-ID 100
     br-dis-prop_host AT ROW 5 COL 1.5 WIDGET-ID 200
     br-dis-prop_ AT ROW 5 COL 1.5 WIDGET-ID 300
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(78.50) SKIP(21.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_dis-propf B "?" ? ub dis-card-property
      TABLE: X_dis-prop_ B "?" ? ub dis-card-property
      TABLE: X_dis-prop_host B "?" ? ub dis-card-property
      TABLE: X_dis-prop_obj B "?" ? ub dis-card-property
      TABLE: X_prop-map_ B "?" ? ub prop-map
      TABLE: X_prop-map_host B "?" ? ub prop-map
      TABLE: X_prop-map_obj B "?" ? ub prop-map
      TABLE: X_prop-ref_ B "?" ? ub prop-ref
      TABLE: X_prop-ref_host B "?" ? ub prop-ref
      TABLE: X_prop-ref_obj B "?" ? ub prop-ref
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-prop_obj f-node-label Dialog-Frame */
/* BROWSE-TAB br-dis-prop_host br-dis-prop_obj Dialog-Frame */
/* BROWSE-TAB br-dis-prop_ br-dis-prop_host Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-node-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-dt-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-dtm-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-dtm-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-node-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-node-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-sum-id IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-prop_
/* Query rebuild information for BROWSE br-dis-prop_
     _START_FREEFORM
OPEN QUERY br-dis-prop_
FOR EACH X_dis-prop_ NO-LOCK,
    FIRST X_prop-ref_ NO-LOCK WHERE
         X_prop-ref_.dt-code = X_dis-prop_.dt-code,
    FIRST X_prop-map_  WHERE
         X_prop-map_.dtm-code = X_dis-prop_.dtm-code
    AND X_prop-map_.node-code = X_dis-prop_.node-code INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-dis-prop_ FOR
                X_dis-prop_,
                X_prop-ref_,
                X_prop-map_ SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-dis-prop_ */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-prop_host
/* Query rebuild information for BROWSE br-dis-prop_host
     _START_FREEFORM
OPEN QUERY br-dis-prop_host
FOR EACH X_dis-prop_host NO-LOCK,
    FIRST X_prop-ref_host NO-LOCK WHERE
         X_prop-ref_host.dt-code = X_dis-prop_host.dt-code ,
    FIRST X_prop-map_host WHERE
         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
    AND X_prop-map_host.node-code = X_dis-prop_host.node-code INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-dis-prop_host FOR
                X_dis-prop_host,
                X_prop-ref_host,
                X_prop-map_host SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-dis-prop_host */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-prop_obj
/* Query rebuild information for BROWSE br-dis-prop_obj
     _START_FREEFORM
OPEN QUERY br-dis-prop_obj
FOR EACH X_dis-prop_obj NO-LOCK,
    FIRST X_prop-ref_obj NO-LOCK WHERE
         X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code ,
    FIRST X_prop-map_obj  WHERE
          X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code
      AND X_prop-map_obj.node-code = X_dis-prop_obj.node-code INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-dis-prop_obj FOR
                X_dis-prop_obj,
                X_prop-ref_obj,
                X_prop-map_obj SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-dis-prop_obj */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-card Dialog-Frame
ON CHOOSE OF b-card IN FRAME Dialog-Frame /* Карта */
DO:
DEFINE VARIABLE v-d-card AS CHARACTER NO-UNDO.
DEFINE variable v-ri as recid no-undo .
define buffer buf_dis-card for ub.dis-card.
CASE rs-region:
  WHEN {&g___object} THEN DO:
    IF NOT AVAILABLE X_dis-prop_obj THEN RETURN NO-APPLY.
    v-d-card = X_dis-prop_obj.d-card.
  END.
  WHEN {&company} THEN DO:
    IF NOT AVAILABLE X_dis-prop_host THEN RETURN NO-APPLY.
    v-d-card = X_dis-prop_host.d-card.
  END.
  WHEN "global" THEN DO:
    IF NOT AVAILABLE X_dis-prop_ THEN RETURN NO-APPLY.
    v-d-card = X_dis-prop_.d-card.
  END.
END CASE.
find first buf_dis-card no-lock where
           buf_dis-card.d-card = v-d-card no-error .
if avail buf_dis-card then do:
  assign
  v-ri = recid( buf_dis-card )
 .
  run ref/dcardi.w (
                input parparentproc
              , input {&lookup}
              , input buf_dis-card.emitent-host-code
              , input p-curr-host-code
              , input p-curr-obj-type
              , input p-curr-obj-code
              , input ?
              , input-output v-ri ) .

END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dt-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dt-code Dialog-Frame
ON CHOOSE OF b-dt-code IN FRAME Dialog-Frame /* Btn 3 */
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
run ref/proprefs.w (
                input parparentproc
              ,input 'b-sel'
              ,input (if f-dtm-code = ?
                      then {&table_dis-card-property}
                      else "dtm-code")
              ,input (if f-dtm-code = ? then 0 else f-dtm-code)
              ,input '':U
              ,input '':U /*p-caller-id*/
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  v-list-mode = p-list-mode.
  assign
  f-dt-code = ?
  f-sum-id = '':U.
  DISPLAY
  f-sum-id
  f-dt-code
  WITH FRAME {&FRAME-NAME}.
  run openbr in this-procedure ( input yes, input no, input '':U).
  return.
end.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-ref-list) no-error.
if not available buf_prop-ref then return.
if buf_prop-ref.dt-code = f-dt-code then return no-apply.
ASSIGN
f-dt-code = buf_prop-ref.dt-code
f-sum-id = buf_prop-ref.sum-id.
DISPLAY
f-sum-id
f-dt-code
WITH FRAME {&FRAME-NAME}.
if f-node-code = ? then do:
  v-list-mode ="dt-code".
end.
else do:
  v-list-mode ="dt-node-code".
end.
run openbr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dtm-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dtm-code Dialog-Frame
ON CHOOSE OF b-dtm-code IN FRAME Dialog-Frame /* Btn 3 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
 run rul/prop-head-s.w ( INPUT parparentproc
                         ,INPUT "b-sel"
                         ,input "general-view"
                         ,input {&prop-head-gen-dc-prop}
                         ,input-output v-rid-list ) NO-ERROR.
 IF ERROR-STATUS:error OR v-rid-list = '':U THEN DO:
    UNDO, RETURN NO-APPLY.
 END.
 FIND FIRST buf_prop-head NO-LOCK WHERE
           recid(buf_prop-head) = INTEGER(v-rid-list) NO-ERROR.
 IF NOT AVAILABLE buf_prop-head  THEN DO:
    assign
    f-dt-code = ?
    f-sum-id = '':U
    f-dtm-code = ?
    f-dtm-name = '':U
    f-node-code = ?
    f-node-label = '':U
    .
    DISABLE
    b-node-code
    WITH FRAME {&FRAME-NAME}.
    DISPLAY
    f-sum-id
    f-dtm-code
    f-dtm-name
    f-dt-code
    f-node-code
    f-node-label
    WITH FRAME {&FRAME-NAME}.
   v-list-mode = p-list-mode.
   run openbr in this-procedure ( input yes, input no, input '':U).
   RETURN.
 END.
 if buf_prop-head.dtm-code = f-dtm-code then return no-apply.
 assign
 f-dtm-code = buf_prop-head.dtm-code
 f-dtm-name = buf_prop-head.prop-label
 .
 display
 f-dtm-code
 f-dtm-name
 with frame {&frame-name} .
 ENABLE
 b-node-code
 WITH FRAME {&FRAME-NAME}.
 v-list-mode = "dtm-code".
 run openbr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
define variable parref-list as character no-undo .
CASE rs-region:
  when {&g___object} then do:
    if available X_dis-prop_obj  then do:
      run ref/cdchist.w (
                        INPUT parparentproc
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input "":U
                        ,input "subject":U
                        ,input X_dis-prop_obj.d-card
                        ,input ? /*dis-card.card-num*/
                        ,input X_dis-prop_obj.obj-type
                        ,input X_dis-prop_obj.obj-code
                        ,input X_dis-prop_obj.host-code
                        ,input ? /*p-corr-user-db-num */
                        ,input "":U /*p-corr-user-name */
                        ,input {&table_dis-card-property} /*p-subject*/
                        ,input ? /*p-db-num */
                        /*записи в выборке*/
                        ,input-output parref-list
                    ) no-error .
        apply "entry" to br-dis-prop_obj.
     end.
   end.
   when {&company} then do:
     if available X_dis-prop_host then do:
      run ref/cdchist.w (
                          INPUT parparentproc
                          ,input p-curr-host-code
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input "":U
                          ,input "subject"
                          ,input X_dis-prop_host.d-card
                          ,input ? /*dis-card.card-num*/
                          ,input '':U
                          ,input 0
                          ,input X_dis-prop_host.host-code
                          ,input ? /*p-corr-user-db-num */
                          ,input "":U /*p-corr-user-name */
                          ,input {&table_dis-card-property} /*p-subject*/
                          ,input ? /*p-db-num */
                          /*записи в выборке*/
                          ,input-output parref-list
                      ) no-error .
        apply "entry" to br-dis-prop_host.
      end.
    end.
    when "global" then do:
     if available X_dis-prop_ then do:
      run ref/cdchist.w (
                          INPUT parparentproc
                          ,input p-curr-host-code
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input "":U
                          ,input "subject"
                          ,input X_dis-prop_.d-card
                          ,input ? /*dis-card.card-num*/
                          ,input '':U
                          ,input 0
                          ,input 0 /*host-code*/
                          ,input ? /*p-corr-user-db-num */
                          ,input "":U /*p-corr-user-name */
                          ,input {&table_dis-card-property} /*p-subject*/
                          ,input ? /*p-db-num */
                          /*записи в выборке*/
                          ,input-output parref-list
                      ) no-error .
        apply "entry" to br-dis-prop_host.
      end.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable v-rec as recid no-undo.
DEFINE VARIABLE v-d-card AS CHARACTER NO-UNDO.
DEFINE variable v-ri as recid no-undo .
define variable v-update-attr as logical no-undo .
define variable v-is-error as logical no-undo .
define buffer buf_dis-card for ub.dis-card.
CASE rs-region:
    WHEN {&g___object} THEN DO:
      IF NOT AVAILABLE X_dis-prop_obj THEN RETURN NO-APPLY.
      v-d-card = X_dis-prop_obj.d-card.
    END.
    WHEN {&company} THEN DO:
      IF NOT AVAILABLE X_dis-prop_host THEN RETURN NO-APPLY.
      v-d-card = X_dis-prop_host.d-card.
    END.
    WHEN "global" THEN DO:
      IF NOT AVAILABLE X_dis-prop_ THEN RETURN NO-APPLY.
      v-d-card = X_dis-prop_.d-card.
    END.
 END CASE.
find first buf_dis-card no-lock where
           buf_dis-card.d-card = v-d-card no-error .
if avail buf_dis-card then do:
  assign
  v-ri = recid( buf_dis-card )
 .
  if buf_dis-card.emitent-host-code = p-curr-host-code
  or buf_dis-card.emitent-host-code = 0 then do:
      run ref/dc-propr.p ( input parparentproc
                    ,input {&lookup}
                    ,input buf_dis-card.d-card
                    ,input buf_dis-card.emitent-host-code
                    ,input buf_dis-card.type
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input no /*update on exit*/
                    ,output v-update-attr
                    ,output v-is-error
                    ) no-error .
  end.
  else do:
      message "Данная дисконтная карта принадлежит другой фирме - просмотр запрещен!"
      view-as alert-box ERROR.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_dis-prop_obj then do:
 { gbl/markstrn.i X_dis-prop_obj v-rid-list }
  glog = br-dis-prop_obj:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-dis-prop_obj:select-next-row ().
      apply "VALUE-CHANGED" to br-dis-prop_obj in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-dis-prop_obj in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-node-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-node-code Dialog-Frame
ON CHOOSE OF b-node-code IN FRAME Dialog-Frame /* Btn 3 */
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
IF f-dtm-code = ?
OR f-dtm-code = 0  THEN DO:
  MESSAGE
  "Не выбран объект-операнд"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN NO-APPLY.
END.
run rul/prop-map-s.w (
                input parparentproc
              ,input 'b-sel'
              ,input "dtm-code"
              ,input f-dtm-code
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  v-list-mode = p-list-mode.
  assign
  f-node-code = ?
  f-node-label = '':U.
  DISPLAY
  f-node-code
  f-node-label
  WITH FRAME {&FRAME-NAME}.
  run openbr in this-procedure ( input yes, input no, input '':U).
  return.
end.
find first buf_prop-map no-lock where
          recid(buf_prop-map) = integer(v-ref-list) no-error.
if not available buf_prop-map then return.
if buf_prop-map.dtm-code = f-dtm-code
AND buf_prop-map.node-code = f-node-code then return no-apply.
ASSIGN
f-node-code = buf_prop-map.node-code
f-node-label = buf_prop-map.node-label.
DISPLAY
f-node-code
f-node-label
WITH FRAME {&FRAME-NAME}.
IF f-dt-code = ?
THEN DO:
  v-list-mode ="node-code".
END.
ELSE DO:
  v-list-mode ="dt-node-code".
END.
run openbr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable v-doc-rec as recid no-undo .
 CASE rs-region:
     WHEN {&g___object} THEN DO:
      v-doc-rec = recid( X_dis-prop_obj ).
      DO WHILE available X_dis-prop_obj :
        GET prev br-dis-prop_obj.
      END.
      run PrintProc IN THIS-PROCEDURE ( f-dtm-code, rs-region) .
      reposition br-dis-prop_obj to recid v-doc-rec no-error.
      apply "entry" to br-dis-prop_obj in frame {&frame-name}.
   END.
   WHEN {&company} THEN DO:
      v-doc-rec = recid( X_dis-prop_host ).
      DO WHILE available X_dis-prop_host :
          GET prev br-dis-prop_host.
      END.
      run PrintProc IN THIS-PROCEDURE ( f-dtm-code, rs-region) .
      reposition br-dis-prop_host to recid v-doc-rec no-error.
      apply "entry" to br-dis-prop_host in frame {&frame-name}.

  END.
  WHEN "global" THEN DO:
      v-doc-rec = recid( X_dis-prop_ ).
      DO WHILE available X_dis-prop_ :
          GET prev br-dis-prop_.
      END.
      run PrintProc IN THIS-PROCEDURE ( f-dtm-code, rs-region) .
      reposition br-dis-prop_ to recid v-doc-rec no-error.
      apply "entry" to br-dis-prop_ in frame {&frame-name}.

  END.
 END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE (INPUT rs-region) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_dis-prop_obj then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_dis-prop_obj ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-region
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-region Dialog-Frame
ON VALUE-CHANGED OF rs-region IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-region.
  v-list-mode = p-list-mode.
  RUN Openbr IN THIS-PROCEDURE ( input YES, INPUT NO, INPUT '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-prop_
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_dis-prop_obj).  ~
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-dis-prop_obj to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-dis-prop_obj. " }

{ gbl/app_help.i }
{ gbl/setfltnm.i }

ON ROW-DISPLAY OF br-dis-prop_ IN frame {&frame-name}
DO:
  IF AVAIL X_dis-prop_ THEN DO:
    RUN set-row-color_ IN THIS-PROCEDURE ( INPUT X_prop-map_.node-value-type).
  END.
END.
ON ROW-DISPLAY OF br-dis-prop_host IN frame {&frame-name}
DO:
  IF AVAIL X_dis-prop_host THEN DO:
    RUN set-row-color_host IN THIS-PROCEDURE ( INPUT X_prop-map_host.node-value-type).
  END.
END.
ON ROW-DISPLAY OF br-dis-prop_obj IN frame {&frame-name}
DO:
  IF AVAIL X_dis-prop_obj THEN DO:
    RUN set-row-color_obj IN THIS-PROCEDURE ( INPUT X_prop-map_obj.node-value-type).
  END.
END.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(p-list-mode, {&ALL} + {&comma-char} + "dtm-code" + {&comma-char} + "dt-code") = 0  THEN DO:
    MESSAGE
    vss-workfile vss-revision vss-description SKIP
    "Неверное значение параметра p-list-mode" p-list-mode
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
  if lookup(p-region, {&g___object} + {&comma-char} + {&company} + {&comma-char} + "global")  = 0 then do:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-region" p-region SKIP
        "Нет хранилища данных"  p-region
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
  end.
  IF p-list-mode = "dtm-code" THEN DO:

    FIND FIRST buf_prop-head NO-LOCK WHERE
              buf_prop-head.dtm-code = p-dtm-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-head THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dtm-code" p-dtm-code SKIP
        "Нет объекта-операнда c кодом"  p-dtm-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.

    END.
  END.
  IF p-list-mode = "dt-code"
  OR (p-list-mode = "dtm-code" AND p-dt-code > 0) THEN DO:

    FIND FIRST buf_prop-ref NO-LOCK WHERE
              buf_prop-ref.dt-code = p-dt-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-ref THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        "Нет среза c кодом"  p-dt-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.

    END.
    IF p-list-mode = "dtm-code"
    AND p-dtm-code <> buf_prop-ref.dtm-code THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        substitute("Код среза &1 соответствует  коду объекта &2, хотя p-dtm-code = &3"
                   , p-dt-code
                   , buf_prop-ref.dtm-code
                   , p-dtm-code)
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.


    END.
    FIND FIRST buf_prop-head NO-LOCK WHERE
              buf_prop-head.dtm-code = buf_prop-ref.dtm-code NO-ERROR.
  END.
  v-list-mode = p-list-mode.
  { gbl/getcntxt.i get }
  run Myenable in this-procedure .
  v-rid-list = p-rid-list.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY rs-region f-dtm-code f-dtm-name f-dt-code f-sum-id f-node-code 
          f-node-label mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel rs-region b-lkp b-card b-sch B-print b-history 
         B-Help b-dtm-code b-dt-code br-dis-prop_obj br-dis-prop_host 
         br-dis-prop_ mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE v-curr-r-b AS CHARACTER NO-UNDO.
{ gbl/curr-r-b.i v-curr-r-b }
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ch0 AS widget-handle NO-UNDO.
if p-list-mode =  "dtm-code"
or p-list-mode = "dt-code"
or p-list-mode = "dt-node-code"
or p-list-mode = "node-code" then do:
  assign
  X_prop-ref_.dtm-code:visible in browse br-dis-prop_ = no
  X_prop-ref_host.dtm-code:visible in browse br-dis-prop_host = no
  X_prop-ref_obj.dtm-code:visible in browse br-dis-prop_obj = no
  .
end.
ASSIGN
v-ch0 = br-dis-prop_:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&label-clmn_character} THEN
   v-ch_[1] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_date} THEN
   v-ch_[2] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_decimal} THEN
   v-ch_[3] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_integer} THEN
   v-ch_[4] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_logical} THEN
   v-ch_[5] = v-ch0.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
ASSIGN
v-ch0 = br-dis-prop_host:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&label-clmn_character} THEN
   v-ch_host[1] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_date} THEN
   v-ch_host[2] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_decimal} THEN
   v-ch_host[3] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_integer} THEN
   v-ch_host[4] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_logical} THEN
   v-ch_host[5] = v-ch0.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
ASSIGN
v-ch0 = br-dis-prop_obj:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&label-clmn_character} THEN
   v-ch_obj[1] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_date} THEN
   v-ch_obj[2] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_decimal} THEN
   v-ch_obj[3] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_integer} THEN
   v-ch_obj[4] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_logical} THEN
   v-ch_obj[5] = v-ch0.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.

ASSIGN
rs-region:RADIO-BUTTONS IN FRAME {&FRAME-NAME}  = "Объекты" + {&comma-char} + {&g___object} + {&comma-char} +
                        "Фирмы" + {&comma-char} + {&company} + {&comma-char} +
                        "Глобально" + {&comma-char} + "global"
rs-region = (IF p-region = '':U
             THEN {&g___object}
             ELSE p-region)
.
if p-list-mode = "dtm-code"
or p-list-mode = "dt-code"
then do:
  assign
  f-dtm-code  = buf_prop-head.dtm-code
  f-dtm-name  = buf_prop-head.prop-label
  .
end.
else do:
  f-dtm-code = ?.
end.
if p-list-mode = "dt-code"
or (p-list-mode = "dtm-code" and p-dt-code > 0)
then do:
  assign
  f-dt-code  = buf_prop-ref.dtm-code
  f-sum-id   = buf_prop-ref.sum-id
  .
end.
else do:
  f-dt-code = ?.
end.
f-node-code = ?.
display
f-dtm-code
f-dtm-name
f-dt-code
f-sum-id
with frame {&frame-name} .
ENABLE
rs-region
b-quit
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-card
b-sch
b-print
b-history
b-dtm-code WHEN (p-list-mode <> "dtm-code")
b-dt-code WHEN (p-list-mode <> "dt-code"
                AND NOT (p-list-mode = "dtm-code" AND p-dt-code > 0)
                and NOT (p-list-mode = "dtm-code" AND p-dtm-code = 1)
                )
b-node-code WHEN (f-dtm-code <> 0 AND f-dtm-code <> ?)
br-dis-prop_obj
br-dis-prop_host
br-dis-prop_
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if available buf_prop-head then do:
  if buf_prop-head.storage-place = '':U
  or buf_prop-head.storage-place = {&question-mark}
  or buf_prop-head.storage-place = ? then do:
    rs-region:disable(radio-label("global", rs-region:radio-buttons)).
  end.
  if buf_prop-head.storage-place-host = '':U
  or buf_prop-head.storage-place-host = {&question-mark}
  or buf_prop-head.storage-place-host = ? then do:
    rs-region:disable(radio-label({&company}, rs-region:radio-buttons)).
  end.
  if buf_prop-head.storage-place-obj = '':U
  or buf_prop-head.storage-place-obj = {&question-mark}
  or buf_prop-head.storage-place-obj = ? then do:
    rs-region:disable(radio-label({&g___object}, rs-region:radio-buttons)).
  end.
end.

run Openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame 
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable v-datatype as logical no-undo extent 5.
define buffer buf_prop-map for ub.prop-map.
CASE rs-region:
  WHEN {&g___object} THEN DO:
    RUN Openbr_obj ( INPUT p-open-query
                    ,INPUT p-find-next
                    ,INPUT p-find-condition).
    br-dis-prop_obj:move-to-top() in frame {&frame-name} .
    if f-dtm-code > 0 then do:
      for each buf_prop-map no-lock where
              buf_prop-map.dtm-code = f-dtm-code:
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-character} then do:
          v-datatype[1] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-date} then do:
          v-datatype[2] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-decimal} then do:
          v-datatype[3] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-integer} then do:
          v-datatype[4] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-logical} then do:
          v-datatype[5] = yes.
        end.
      end.
      assign
      v-ch_obj[1]:visible = v-datatype[1]
      v-ch_obj[2]:visible = v-datatype[2]
      v-ch_obj[3]:visible = v-datatype[3]
      v-ch_obj[4]:visible = v-datatype[4]
      v-ch_obj[5]:visible = v-datatype[5]
      .
    end.
    else do:
      assign
      v-ch_obj[1]:visible = yes
      v-ch_obj[2]:visible = yes
      v-ch_obj[3]:visible = yes
      v-ch_obj[4]:visible = yes
      v-ch_obj[5]:visible = yes
      .

    end.
    apply "ENTRY" to br-dis-prop_obj.
    apply "VALUE-CHANGED" to br-dis-prop_obj.
  END.
  WHEN {&company} THEN DO:
    RUN Openbr_host ( INPUT p-open-query
                      ,INPUT p-find-next
                      ,INPUT p-find-condition).
    br-dis-prop_host:move-to-top().
    if f-dtm-code > 0 then do:
      for each buf_prop-map no-lock where
              buf_prop-map.dtm-code = f-dtm-code:
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-character} then do:
          v-datatype[1] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-date} then do:
          v-datatype[2] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-decimal} then do:
          v-datatype[3] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-integer} then do:
          v-datatype[4] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-logical} then do:
          v-datatype[5] = yes.
        end.
      end.
      assign
      v-ch_host[1]:visible = v-datatype[1]
      v-ch_host[2]:visible = v-datatype[2]
      v-ch_host[3]:visible = v-datatype[3]
      v-ch_host[4]:visible = v-datatype[4]
      v-ch_host[5]:visible = v-datatype[5]
      .

    end.
    else do:
      assign
      v-ch_obj[1]:visible = yes
      v-ch_obj[2]:visible = yes
      v-ch_obj[3]:visible = yes
      v-ch_obj[4]:visible = yes
      v-ch_obj[5]:visible = yes
      .

    end.
    apply "ENTRY" to br-dis-prop_host.
    apply "VALUE-CHANGED" to br-dis-prop_host.
  END.
  WHEN "global" THEN DO:
    RUN Openbr_ ( INPUT p-open-query
                      ,INPUT p-find-next
                      ,INPUT p-find-condition).
    br-dis-prop_:move-to-top().
    if f-dtm-code > 0 then do:
      for each buf_prop-map no-lock where
              buf_prop-map.dtm-code = f-dtm-code:
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-character} then do:
          v-datatype[1] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-date} then do:
          v-datatype[2] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-decimal} then do:
          v-datatype[3] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-integer} then do:
          v-datatype[4] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = {&abl-datatype-logical} then do:
          v-datatype[5] = yes.
        end.
      end.
      assign
      v-ch_[1]:visible = v-datatype[1]
      v-ch_[2]:visible = v-datatype[2]
      v-ch_[3]:visible = v-datatype[3]
      v-ch_[4]:visible = v-datatype[4]
      v-ch_[5]:visible = v-datatype[5]
      .

     end.
     else do:
      assign
      v-ch_obj[1]:visible = yes
      v-ch_obj[2]:visible = yes
      v-ch_obj[3]:visible = yes
      v-ch_obj[4]:visible = yes
      v-ch_obj[5]:visible = yes
      .
    end.
    apply "ENTRY" to br-dis-prop_.
    apply "VALUE-CHANGED" to br-dis-prop_.
  END.

END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr_ Dialog-Frame 
PROCEDURE Openbr_ :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-dis-prop_ FOR EACH X_dis-prop_ NO-LOcK

&scop flt-open-dyn_open-query FOR EACH X_dis-prop_ NO-LOcK

&scop flt-open-query-handle QUERY br-dis-prop_:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-prop_

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_dis-prop_

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + v-list-mode.
CASE v-list-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point-label = substitute("Все срезы по ДК по фирмам")
    frame {&frame-name}:title = filter-point-label
    .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_ NO-LOCK WHERE X_prop-ref_.dt-code = X_dis-prop_.dt-code ~
                                    , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code and ~
                                                                      X_prop-map_.dtm-code = X_dis-prop_.dtm-code

    { gbl/fltopend.i
        &where-cond = " X_dis-prop_.host-code = 0 "
        &use-ind    = "  "

        &by         = " by X_dis-prop_.d-card " }
    END.
    when "dtm-code" then do:
        assign
        filter-point-label = substitute("Все срезы по ДК по фирмам по объекту-операнду &1 (&2)"
                                         , f-dtm-code
                                         , buf_prop-head.prop-label
                                         )
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_ NO-LOCK WHERE ~
                                          X_prop-ref_.dt-code = X_dis-prop_.dt-code ~
                                     , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND ~
                                                                      X_prop-map_.dtm-code = X_dis-prop_.dtm-code
      { gbl/fltopend.i
        &where-cond = " X_dis-prop_.host-code = 0  ~
                        and X_dis-prop_.dtm-code = f-dtm-code"
        &dyn_where-cond = " substitute('X_dis-prop_.host-code = 0  ~
                        and X_dis-prop_.dtm-code = &1', f-dtm-code)"

        &use-ind    = "  "
        &by         = " by X_dis-prop_.d-card " }

  END.
  when "dt-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по фирмам по объекту-операнду &2 (&3)"
                                        , f-sum-id
                                        , f-dtm-code
                                        , buf_prop-head.prop-label
                                        )
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_ no-lock WHERE ~
                                           X_prop-ref_.dt-code = X_dis-prop_.dt-code ~
                                   , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND ~
                                                                    X_prop-map_.dtm-code = X_dis-prop_.dtm-code
        { gbl/fltopend.i
            &where-cond = "X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code "
            &dyn_where-cond = " substitute('X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = &1', f-dt-code) "
            &use-ind    = "  "
            &by         = "by X_dis-prop_.d-card " }

  END.
  when "dt-node-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по фирмам по объекту-операнду &2: &3"
                                        , f-sum-id
                                        , f-dtm-code
                                        , f-node-label
                                        )
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_ no-lock WHERE ~
                                           X_prop-ref_.dt-code = X_dis-prop_.dt-code ~
                                   , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND ~
                                                                    X_prop-map_.dtm-code = X_dis-prop_.dtm-code
        { gbl/fltopend.i
            &where-cond = "X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code  ~
                           and X_dis-prop_.node-code = f-node-code "
            &dyn_where-cond = " substitute('X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = &1  ~
                           and X_dis-prop_.node-code = &2 ', f-dt-code, f-node-code)"

            &use-ind    = "  "
            &by         = "by X_dis-prop_.d-card " }

  END.
  when "node-code" then do:
            assign
            filter-point-label = substitute("Все срезы по ДК по фирмам по объекту-операнду &1 (&3): &2"
                                            , f-dtm-code
                                            , f-node-label
                                            , buf_prop-head.prop-label
                                            )
            frame {&frame-name}:title = filter-point-label
            .
    &scop flt-open-open-query-tail      , FIRST X_prop-ref_ no-lock WHERE ~
                                               X_prop-ref_.dt-code = X_dis-prop_.dt-code ~
                                           , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND ~
                                                                        X_prop-map_.dtm-code = X_dis-prop_.dtm-code
    { gbl/fltopend.i
      &where-cond = "X_dis-prop_.host-code = 0  ~
                      and X_dis-prop_.dtm-code = f-dtm-code ~
                      and X_dis-prop_.node-code = f-node-code "
      &dyn_where-cond = " substitute( 'X_dis-prop_.host-code = 0  ~
                      and X_dis-prop_.dtm-code = &1 ~
                      and X_dis-prop_.node-code = &2 ', f-dtm-code, f-node-code)"

      &use-ind    = "  "
      &by         = "by X_dis-prop_.d-card " }

  END.
END CASE.
if not p-open-query then
REPOSITION br-dis-prop_ to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-prop_:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-dis-prop_.
APPLY "VALUE-CHANGED" TO br-dis-prop_ in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr_host Dialog-Frame 
PROCEDURE Openbr_host :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-dis-prop_host FOR EACH X_dis-prop_host NO-LOcK

&scop flt-open-dyn_open-query FOR EACH X_dis-prop_host NO-LOcK

&scop flt-open-query-handle  QUERY br-dis-prop_host:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-prop_host

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_dis-prop_host

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + v-list-mode + "_host".
CASE v-list-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point-label = substitute("Все срезы по ДК по фирмам")
    frame {&frame-name}:title = filter-point-label
    .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_host NO-LOCK WHERE X_prop-ref_host.dt-code = X_dis-prop_host.dt-code ~
                                    , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND ~
                                                                        X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
    { gbl/fltopend.i
        &where-cond = " X_dis-prop_host.host-code > 0  and X_dis-prop_host.obj-type = '':U and X_dis-prop_host.obj-code = 0"
        &dyn_where-cond = " substitute('X_dis-prop_host.host-code > 0  and X_dis-prop_host.obj-type = &1&1 and X_dis-prop_host.obj-code = 0 ', ~{&double-quote~})"
        &use-ind    = "  "

        &by         = " by X_dis-prop_host.d-card " }
    END.
    when "dtm-code" then do:
        assign
        filter-point-label = substitute("Все срезы по ДК по фирмам по объекту-операнду &1 (&2)"
                                      , f-dtm-code
                                      , buf_prop-head.prop-label
                                      )
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_host NO-LOCK WHERE ~
                                          X_prop-ref_host.dt-code = X_dis-prop_host.dt-code ~
                                    , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND ~
                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
      { gbl/fltopend.i
        &where-cond = " X_dis-prop_host.host-code > 0 ~
                       and X_dis-prop_host.obj-type = '':U ~
                       and X_dis-prop_host.obj-code = 0 ~
                       and X_dis-prop_host.dtm-code = f-dtm-code "
        &dyn_where-cond = " substitute('X_dis-prop_host.host-code > 0 ~
                       and X_dis-prop_host.obj-type = &1&1 ~
                       and X_dis-prop_host.obj-code = 0 ~
                       and X_dis-prop_host.dtm-code = &2', ~{&double-quote~}, f-dtm-code )"

        &use-ind    = "  "
        &by         = " by X_dis-prop_host.d-card " }

  END.
  when "dt-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по фирмам по объекту-операнду &2 (&3)"
                                        , f-sum-id
                                        , f-dtm-code
                                        , buf_prop-head.prop-label
                                        )
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_host WHERE ~
                                          X_prop-ref_host.dt-code = X_dis-prop_host.dt-code ~
                                    , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND ~
                                                                        X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
        { gbl/fltopend.i
          &where-cond = " X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U ~
                          and X_dis-prop_host.obj-code = 0 and  X_dis-prop_host.dt-code = f-dt-code "
          &dyn_where-cond = " substitute('X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = &1&1 ~
                          and X_dis-prop_host.obj-code = 0 and  X_dis-prop_host.dt-code = &2', ~{&double-quote~}, f-dt-code )"

          &use-ind    = "  "
          &by         = " by X_dis-prop_host.d-card " }

  END.
  when "dt-node-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по фирмам по объекту-операнду &2: &3"
                                        , f-sum-id
                                        , f-dtm-code
                                        , f-node-label
                                        )
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_host WHERE ~
                                          X_prop-ref_host.dt-code = X_dis-prop_host.dt-code ~
                                    , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND ~
                                                                        X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
        { gbl/fltopend.i
          &where-cond = " X_dis-prop_host.host-code > 0 ~
                          and X_dis-prop_host.obj-type = '':U ~
                          and X_dis-prop_host.obj-code = 0  ~
                          and X_dis-prop_host.dt-code = f-dt-code ~
                          and X_dis-prop_host.node-code = f-node-code "
          &dyn_where-cond = " substitute('X_dis-prop_host.host-code > 0 ~
                          and X_dis-prop_host.obj-type = &1&1 ~
                          and X_dis-prop_host.obj-code = 0  ~
                          and X_dis-prop_host.dt-code = &2 ~
                          and X_dis-prop_host.node-code = &3 ', ~{&double-quote~}, f-dt-code , f-node-code)"

          &use-ind    = "  "
          &by         = " by X_dis-prop_host.d-card " }

  END.
  when "node-code" then do:
      assign
      filter-point-label = substitute("Все срезы по ДК по фирмам по объекту-операнду &1 (&3): &2"
                                      , f-dtm-code
                                      , f-node-label
                                      , buf_prop-head.prop-label
                                      )
      frame {&frame-name}:title = filter-point-label
      .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_host WHERE ~
                                        X_prop-ref_host.dt-code = X_dis-prop_host.dt-code ~
                                  , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND ~
                                                                      X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
      { gbl/fltopend.i
        &where-cond = " X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U ~
                        and X_dis-prop_host.obj-code = 0 ~
                        and X_dis-prop_host.node-code = f-node-code ~
                        and X_dis-prop_host.dtm-code = f-dtm-code "
        &dyn_where-cond = " substitute('X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = &1&1 ~
                        and X_dis-prop_host.obj-code = 0 ~
                        and X_dis-prop_host.node-code = &2 ~
                        and X_dis-prop_host.dtm-code = &3', ~{&double-quote~}, f-node-code, f-dtm-code )"

        &use-ind    = "  "
        &by         = " by X_dis-prop_host.d-card " }

    END.

END CASE.
if not p-open-query then
REPOSITION br-dis-prop_host to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-prop_host:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-dis-prop_host.
APPLY "VALUE-CHANGED" TO br-dis-prop_host in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr_obj Dialog-Frame 
PROCEDURE Openbr_obj :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-dis-prop_obj FOR EACH X_dis-prop_obj NO-LOcK

&scop flt-open-dyn_open-query FOR EACH X_dis-prop_obj NO-LOcK

&scop flt-open-query-handle QUERY br-dis-prop_obj:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-prop_obj

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_dis-prop_obj

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + v-list-mode + "_obj".
CASE v-list-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point-label = substitute("Все срезы по ДК по объектам")
    frame {&frame-name}:title = filter-point-label
    .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_obj NO-LOCK WHERE X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code ~
                                    , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND ~
                                                                         X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code

    { gbl/fltopend.i
        &where-cond = " X_dis-prop_obj.obj-type > '':U "
        &where-cond = " substitute('X_dis-prop_obj.obj-type > &1&1', ~{&double-quote~}) "
        &use-ind    = "  "

        &by         = " by X_dis-prop_obj.d-card " }
    END.
    when "dtm-code" then do:
        assign
        filter-point-label = substitute("Все срезы по ДК по объектам по объекту-операнду &1 (&2)"
                                       , f-dtm-code
                                       , buf_prop-head.prop-label
                                       )
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_obj NO-LOCK WHERE ~
                                          X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code ~
                                    , FIRST X_prop-map_obj no-lock where ~
                                           X_prop-map_obj.node-code = X_dis-prop_obj.node-code  ~
                                        AND X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code
      { gbl/fltopend.i
        &where-cond = " X_dis-prop_obj.obj-type > '':U ~
                       AND X_dis-prop_obj.dtm-code = f-dtm-code "
        &dyn_where-cond = " substitute('X_dis-prop_obj.obj-type > &1&1 ~
                       AND X_dis-prop_obj.dtm-code = &2', ~{&double-quote~}, f-dtm-code )"

        &use-ind    = "  "
        &by         = " by X_dis-prop_obj.d-card " }

  END.
  when "dt-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по объектам по объекту-операнду &2 (&3)"
                                        , f-sum-id
                                        , f-dtm-code
                                        , buf_prop-head.prop-label
                                        )
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_obj WHERE ~
                                           X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code ~
                                           , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND ~
                                                                                X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code
    { gbl/fltopend.i
      &where-cond = " X_dis-prop_obj.obj-type > '':U ~
                  and X_dis-prop_obj.dt-code = f-dt-code "
      &dyn_where-cond = " substitute('X_dis-prop_obj.obj-type > &1&1 ~
                  and X_dis-prop_obj.dt-code = &2', ~{&double-quote~}, f-dt-code )"

      &use-ind    = "  "
      &by         = " by X_dis-prop_obj.d-card " }

  END.
  when "dt-node-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по объектам по объекту-операнду &2 (&4): &3"
                                        , f-sum-id
                                        , f-dtm-code
                                        , f-node-label
                                        , buf_prop-head.prop-label
                                        )
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_obj WHERE ~
                                           X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code ~
                                           , FIRST X_prop-map_obj no-lock where ~
                                               X_prop-map_obj.node-code = X_dis-prop_obj.node-code ~
                                           AND X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code

    { gbl/fltopend.i
      &where-cond = " X_dis-prop_obj.obj-type > '':U  ~
                      and X_dis-prop_obj.dt-code = f-dt-code ~
                      and X_dis-prop_obj.node-code = f-node-code "
      &dyn_where-cond = " substitute('X_dis-prop_obj.obj-type > &1&1  ~
                      and X_dis-prop_obj.dt-code = &2 ~
                      and X_dis-prop_obj.node-code = &3', ~{&double-quote~}, f-dt-code, f-node-code)"

      &use-ind    = "  "
      &by         = " by X_dis-prop_obj.d-card " }

  END.
    when "node-code" then do:
          assign
          filter-point-label = substitute("Все срезы по ДК по объектам по объекту-операнду &1 (&3): &2"
                                          , f-dtm-code
                                          , f-node-label
                                          , buf_prop-head.prop-label
                                          )
          frame {&frame-name}:title = filter-point-label
          .
  &scop flt-open-open-query-tail      , FIRST X_prop-ref_obj WHERE ~
                                             X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code ~
                                             , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND ~
                                                                                  X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code
      { gbl/fltopend.i
        &where-cond = " X_dis-prop_obj.obj-type > '':U  ~
                        AND X_dis-prop_obj.dtm-code = f-dtm-code ~
                        and X_dis-prop_obj.node-code = f-node-code "
        &dyn_where-cond = " substitute('X_dis-prop_obj.obj-type > &1&1  ~
                        AND X_dis-prop_obj.dtm-code = &2 ~
                        and X_dis-prop_obj.node-code = &3 ', ~{&double-quote~}, f-dtm-code, f-node-code)"

        &use-ind    = "  "
        &by         = " by X_dis-prop_obj.d-card " }

    END.

END CASE.
if not p-open-query then
REPOSITION br-dis-prop_obj to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-prop_obj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-dis-prop_obj.
APPLY "VALUE-CHANGED" TO br-dis-prop_obj in frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame 
PROCEDURE PrintProc :
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
define variable  date_string        as character no-undo.
define variable  Line               as character no-undo.
define variable  for-time           as character no-undo .
define variable  accum-count        as integer   no-undo .
define variable v-character as character no-undo .
Line = fill("-", {&A4_LS}).
date_string = cur-time-print() .
define frame dis-prop_
X_prop-ref_.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_prop-map_.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
X_dis-prop_.property-value-character COLUMN-LABEL "Значение" format "X(44)"
X_dis-prop_.property-value-date COLUMN-LABEL "Значение" format "99/99/9999"
X_dis-prop_.property-value-decimal COLUMN-LABEL "Значение" format "->>,>>>,>>>,>>>,>>>.99"
X_dis-prop_.property-value-integer COLUMN-LABEL "Значение" format "->,>>>,>>>,>>9"
X_dis-prop_.property-value-logical COLUMN-LABEL "Знач" format "+/"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

DEFINE frame dis-prop_host
X_prop-ref_host.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_host.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_host.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_host.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-prop_host.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>9"
X_prop-map_host.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
X_dis-prop_host.property-value-character COLUMN-LABEL "Значение" format "X(44)"
X_dis-prop_host.property-value-date COLUMN-LABEL "Значение" format "99/99/9999"
X_dis-prop_host.property-value-decimal COLUMN-LABEL "Значение" format "->>,>>>,>>>,>>>,>>>.99"
X_dis-prop_host.property-value-integer COLUMN-LABEL "Значение" format "->,>>>,>>>,>>9"
X_dis-prop_host.property-value-logical COLUMN-LABEL "Знач" format "+/"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

DEFINE frame dis-prop_obj
X_prop-ref_obj.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_obj.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_obj.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_obj.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-prop_obj.obj-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>9"
X_dis-prop_obj.obj-type COLUMN-LABEL "Тип!объекта" FORMAT "X(3)"
X_prop-map_obj.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
X_dis-prop_obj.property-value-character COLUMN-LABEL "Значение" format "X(44)"
X_dis-prop_obj.property-value-date COLUMN-LABEL "Значение" format "99/99/9999"
X_dis-prop_obj.property-value-decimal COLUMN-LABEL "Значение" format "->>,>>>,>>>,>>>,>>>.99"
X_dis-prop_obj.property-value-integer COLUMN-LABEL "Значение" format "->,>>>,>>>,>>9"
X_dis-prop_obj.property-value-logical COLUMN-LABEL "Знач" format "+/"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .


run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
PUT  STREAM PrnLibStream unformatted
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(0)
(if f-dtm-code <> 0 then f-dtm-name else '':U) skip(0)
(if f-dt-code <> ? then f-sum-id else '':U)
.
FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
CASE p-region:
  WHEN "global" THEN DO:
    FORM with FRAME dis-prop_ .
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-dis-prop_  no-lock.
    DO WHILE available X_dis-prop_:
      Display STREAM PrnLibStream
      X_prop-ref_.sum-id
      X_prop-ref_.caller_id
      X_prop-ref_.dtm-code
      X_dis-prop_.d-card
      X_prop-map_.node-name
      X_dis-prop_.property-value-character when entry(1, X_prop-map_.node-value-type) = {&abl-datatype-character}
      X_dis-prop_.property-value-date when entry(1, X_prop-map_.node-value-type) = {&abl-datatype-date}
      X_dis-prop_.property-value-decimal when entry(1, X_prop-map_.node-value-type) = {&abl-datatype-decimal}
      X_dis-prop_.property-value-integer when entry(1, X_prop-map_.node-value-type) = {&abl-datatype-integer}
      X_dis-prop_.property-value-logical when entry(1, X_prop-map_.node-value-type) = {&abl-datatype-logical}
      with FRAME dis-prop_ .
      DOWN STREAM PrnLibStream 1 with FRAME dis-prop_ .
      assign
      accum-count = accum-count + 1 .
      GET next br-dis-prop_ no-lock.
    END.
    UNDERLINE  STREAM PrnLibStream
    X_prop-ref_.sum-id
    X_prop-ref_.caller_id
    X_prop-ref_.dtm-code
    X_dis-prop_.d-card
    X_prop-map_.node-name
    X_dis-prop_.property-value-character
    X_dis-prop_.property-value-date
    X_dis-prop_.property-value-decimal
    X_dis-prop_.property-value-integer
    X_dis-prop_.property-value-logical
    with FRAME dis-prop_ .
    DISPLAY STREAM PrnLibStream
    "Итого" @ X_prop-ref_.sum-id
    accum-count @ X_dis-prop_.d-card
    with frame dis-prop_.
  END.
  WHEN {&company} THEN DO:
    FORM with FRAME dis-prop_host .
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-dis-prop_host  no-lock.
    DO WHILE available X_dis-prop_host:
      Display STREAM PrnLibStream
      X_prop-ref_host.sum-id
      X_prop-ref_host.caller_id
      X_prop-ref_host.dtm-code
      X_dis-prop_host.d-card
      X_prop-map_host.node-name
      X_dis-prop_host.property-value-character when entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-character}
      X_dis-prop_host.property-value-date when entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-date}
      X_dis-prop_host.property-value-decimal when entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-decimal}
      X_dis-prop_host.property-value-integer when entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-integer}
      X_dis-prop_host.property-value-logical when entry(1, X_prop-map_host.node-value-type) = {&abl-datatype-logical}
      with FRAME dis-prop_host .
      DOWN STREAM PrnLibStream 1 with FRAME dis-prop_host .
      assign
      accum-count = accum-count + 1.
      GET next br-dis-prop_host no-lock.
    END.
    UNDERLINE  STREAM PrnLibStream
    X_prop-ref_host.sum-id
    X_prop-ref_host.caller_id
    X_prop-ref_host.dtm-code
    X_dis-prop_host.d-card
    X_prop-map_host.node-name
    X_dis-prop_host.property-value-character
    X_dis-prop_host.property-value-date
    X_dis-prop_host.property-value-decimal
    X_dis-prop_host.property-value-integer
    X_dis-prop_host.property-value-logical
    with FRAME dis-prop_host .
    DISPLAY STREAM PrnLibStream
    "Итого" @ X_prop-ref_host.sum-id
    accum-count @ X_dis-prop_host.d-card
    with frame dis-prop_host.
  END.
  WHEN {&g___object} THEN DO:
    FORM with FRAME dis-prop_obj .
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-dis-prop_obj  no-lock.
    DO WHILE available X_dis-prop_obj:
      Display STREAM PrnLibStream
      X_prop-ref_obj.sum-id
      X_prop-ref_obj.caller_id
      X_prop-ref_obj.dtm-code
      X_dis-prop_obj.d-card
      X_prop-map_obj.node-name
      X_dis-prop_obj.property-value-character when entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-character}
      X_dis-prop_obj.property-value-date when entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-date}
      X_dis-prop_obj.property-value-decimal when entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-decimal}
      X_dis-prop_obj.property-value-integer when entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-integer}
      X_dis-prop_obj.property-value-logical when entry(1, X_prop-map_obj.node-value-type) = {&abl-datatype-logical}
      with FRAME dis-prop_obj .
      DOWN STREAM PrnLibStream 1 with FRAME dis-prop_obj .
      assign
      accum-count = accum-count + 1.
      GET next br-dis-prop_obj no-lock.
    END.
    UNDERLINE  STREAM PrnLibStream
    X_prop-ref_obj.sum-id
    X_prop-ref_obj.caller_id
    X_prop-ref_obj.dtm-code
    X_dis-prop_obj.d-card
    X_prop-map_obj.node-name
    X_dis-prop_obj.property-value-character
    X_dis-prop_obj.property-value-date
    X_dis-prop_obj.property-value-decimal
    X_dis-prop_obj.property-value-integer
    X_dis-prop_obj.property-value-logical
    with FRAME dis-prop_obj .
    DISPLAY STREAM PrnLibStream
    "Итого" @ X_prop-ref_obj.sum-id
    accum-count @ X_dis-prop_obj.d-card
    with frame dis-prop_obj.
  END.
end case.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame 
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE variable v-rid-list AS CHARACTER NO-undo.
CASE p-option:
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
define variable loc-point as character no-undo .
define variable loc-label as character no-undo .

CASE p-region:
  WHEN {&g___object} THEN DO:
    run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('host-code', 'Фирма', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    assign
      tbl = 'dis-card-property'
      join-tbl = 'X_dis-prop_obj'
      fld = ""
      lab = ""
      spr = ""
      dim = '0'
      loc-point = substitute('&1_obj', filter-point)
      loc-label = substitute('&1 ОБъект', filter-point-label)

      .

  END.
  WHEN {&company} THEN DO:
     run fltfield-add in this-procedure('host-code', 'Фирма', '',
     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
     assign
       tbl = 'dis-card-property'
       join-tbl = 'X_dis-prop_host'
       fld = ""
       lab = ""
       spr = ""
       dim = '0'
      loc-point = substitute('&1_host', filter-point)
      loc-label = substitute('&1 Фирма', filter-point-label)

       .
  END.
  WHEN "global" THEN DO:
      assign
        tbl = 'dis-card-property'
        join-tbl = 'X_dis-prop_'
        fld = ""
        lab = ""
        spr = ""
        dim = '0'
      loc-point = substitute('&1', filter-point)
      loc-label = substitute('&1', filter-point-label)

        .
  END.
END CASE.
run fltfield-add in this-procedure('d-card', '№ карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('node-code', 'Свойство', 'dcp-node-code',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-character', 'Значение(строковое)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-date', 'Значение(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-decimal', 'Значение(десятичное)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-integer', 'Значение(целое)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-logical', 'Значение(логич)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc
                   , INPUT (loc-point + {&delim-par} + loc-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color_ Dialog-Frame 
PROCEDURE set-row-color_ :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch_[1]:FGCOLOR = GREY_COLOR
v-ch_[1]:BGCOLOR = GREY_Color
v-ch_[1]:PFCOLOR = GREY_Color
v-ch_[2]:FGCOLOR = GREY_COLOR
v-ch_[2]:BGCOLOR = GREY_Color
v-ch_[2]:PFCOLOR = GREY_Color
v-ch_[3]:FGCOLOR = GREY_COLOR
v-ch_[3]:BGCOLOR = GREY_Color
v-ch_[3]:PFCOLOR = GREY_Color
v-ch_[4]:FGCOLOR = GREY_COLOR
v-ch_[4]:BGCOLOR = GREY_Color
v-ch_[4]:PFCOLOR = GREY_Color
v-ch_[5]:FGCOLOR = GREY_COLOR
v-ch_[5]:BGCOLOR = GREY_Color
v-ch_[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN {&ABL-datatype-character} THEN DO:
      ASSIGN
      v-ch_[1]:FGCOLOR = BLACK_COLOR
      v-ch_[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-decimal} THEN DO:
      ASSIGN
      v-ch_[3]:FGCOLOR = BLACK_COLOR
      v-ch_[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-integer} THEN DO:
      ASSIGN
      v-ch_[4]:FGCOLOR = BLACK_COLOR
      v-ch_[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-date} THEN DO:
      ASSIGN
      v-ch_[2]:FGCOLOR = BLACK_COLOR
      v-ch_[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN {&ABL-datatype-logical} THEN DO:
       ASSIGN
       v-ch_[5]:FGCOLOR = BLACK_COLOR
       v-ch_[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color_host Dialog-Frame 
PROCEDURE set-row-color_host :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch_host[1]:FGCOLOR = GREY_COLOR
v-ch_host[1]:BGCOLOR = GREY_Color
v-ch_host[1]:PFCOLOR = GREY_Color
v-ch_host[2]:FGCOLOR = GREY_COLOR
v-ch_host[2]:BGCOLOR = GREY_Color
v-ch_host[2]:PFCOLOR = GREY_Color
v-ch_host[3]:FGCOLOR = GREY_COLOR
v-ch_host[3]:BGCOLOR = GREY_Color
v-ch_host[3]:PFCOLOR = GREY_Color
v-ch_host[4]:FGCOLOR = GREY_COLOR
v-ch_host[4]:BGCOLOR = GREY_Color
v-ch_host[4]:PFCOLOR = GREY_Color
v-ch_host[5]:FGCOLOR = GREY_COLOR
v-ch_host[5]:BGCOLOR = GREY_Color
v-ch_host[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN {&ABL-datatype-character} THEN DO:
      ASSIGN
      v-ch_host[1]:FGCOLOR = BLACK_COLOR
      v-ch_host[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-decimal} THEN DO:
      ASSIGN
      v-ch_host[3]:FGCOLOR = BLACK_COLOR
      v-ch_host[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-integer} THEN DO:
      ASSIGN
      v-ch_host[4]:FGCOLOR = BLACK_COLOR
      v-ch_host[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-date} THEN DO:
      ASSIGN
      v-ch_host[2]:FGCOLOR = BLACK_COLOR
      v-ch_host[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN {&ABL-datatype-logical} THEN DO:
       ASSIGN
       v-ch_host[5]:FGCOLOR = BLACK_COLOR
       v-ch_host[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color_obj Dialog-Frame 
PROCEDURE set-row-color_obj :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch_[1]:FGCOLOR = GREY_COLOR
v-ch_[1]:BGCOLOR = GREY_Color
v-ch_[1]:PFCOLOR = GREY_Color
v-ch_[2]:FGCOLOR = GREY_COLOR
v-ch_[2]:BGCOLOR = GREY_Color
v-ch_[2]:PFCOLOR = GREY_Color
v-ch_[3]:FGCOLOR = GREY_COLOR
v-ch_[3]:BGCOLOR = GREY_Color
v-ch_[3]:PFCOLOR = GREY_Color
v-ch_[4]:FGCOLOR = GREY_COLOR
v-ch_[4]:BGCOLOR = GREY_Color
v-ch_[4]:PFCOLOR = GREY_Color
v-ch_[5]:FGCOLOR = GREY_COLOR
v-ch_[5]:BGCOLOR = GREY_Color
v-ch_[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN {&ABL-datatype-character} THEN DO:
      ASSIGN
      v-ch_[1]:FGCOLOR = BLACK_COLOR
      v-ch_[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-decimal} THEN DO:
      ASSIGN
      v-ch_[3]:FGCOLOR = BLACK_COLOR
      v-ch_[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-integer} THEN DO:
      ASSIGN
      v-ch_[4]:FGCOLOR = BLACK_COLOR
      v-ch_[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-date} THEN DO:
      ASSIGN
      v-ch_[2]:FGCOLOR = BLACK_COLOR
      v-ch_[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN {&ABL-datatype-logical} THEN DO:
       ASSIGN
       v-ch_[5]:FGCOLOR = BLACK_COLOR
       v-ch_[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION display-character Dialog-Frame 
FUNCTION display-character RETURNS CHARACTER
  (  INPUT p-character AS CHARACTER, INPUT p-format AS CHARACTER) :
DEFINE VARIABLE v-string AS CHARACTER NO-UNDO.

IF trim(p-format, "*") = "" THEN
v-string = string(p-character, p-format).
ELSE DO:
v-string = p-character.
END.

RETURN v-string.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

