&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME fr-config
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS fr-config
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройки и конфигурация системы

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/
/*
Программа может вызывается как из интерфейса пользователя, так и для работы без коннекта к базе.

Для работы без коннекта с базой необходимо откомпилировать программу с установленным
флагом Stand-alone
*/

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U.
def var vss-date        as character no-undo init "$Date$":U.
def var vss-workfile    as character no-undo init "$Workfile$":U.
def var vss-archive     as character no-undo init "$Archive$":U.
def var vss-description as character no-undo init "Настройки и конфигурация системы".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i }

{ adm/cnf-inc.i &new=new }
{ adm/cfg-pr.i  &new=new }

{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }


&if defined (stand-alone) > 0 &then                           /* автономная работа */
  &if defined (new-conf-15_1) = 0 &then /* Кто-то пользуется старым каталогом tools */
    message
      substitute( "ОЧЕНЬ ПЛОХО, ЧТО ВЫ ПЫТАЕТЕСЬ ИСПОЛЬЗОВАТЬ НЕ ЛИЦЕНЗИОННУЮ КОПИЮ ПРОДУКТА!!!" ) skip
      view-as alert-box error
    .
    return error.
  &endif
  define new shared variable g#userid as character no-undo . /* login name пользователя */
  { gbl/conf-enc.i }
  { ibs-enc.i  }
  create alias ubflt for database ub .
&else
  define buffer buf-curr_db for ub.db.
&endif

define variable mark             as character   no-undo .
define variable mark-list        as character   no-undo .

define variable Cnf-hdl          as handle      no-undo .       /* ссылка на библиотеку работы с настройкой конфигурации*/
define variable db-hdl           as handle      no-undo .       /* ссылка на библиотеку работы с базой конфигурации*/
define variable CurCnf-hdl       as handle      no-undo .       /* ссылка на библиотеку работы с конфигурацией */
define variable fname            as character   no-undo .       /* определенное пользователем имя файла */

define variable v-cnf-rec          as recid no-undo.
define variable v-title0           as character no-undo init "Настройки и конфигурация системы" .
define variable v-sort-column-name as character no-undo .
define variable v-filter-pointr    as character no-undo init "Настройки и конфигурация системы" .
define variable v-filter-point0    as character no-undo init "b-config" .
define variable v-filter-point     as character no-undo .

define temp-table tt_cnf no-undo like cnf .


&scop label-clmn_1-br-dtl   '*'
&scop sort-clmn_1-br-dtl     mark
&scop label-clmn_2-br-dtl   '+'
&scop sort-clmn_2-br-dtl     (if Cnf.NotUsed   THEN '-' ELSE '+')
&scop label-clmn_3-br-dtl   'И'
&scop sort-clmn_3-br-dtl     (if Cnf.Is-Changed THEN 'X' ELSE ' ')
&scop label-clmn_4-br-dtl   'Т'
&scop sort-clmn_4-br-dtl     Cnf.Conf-Type
&scop label-clmn_5-br-dtl   'П'
&scop sort-clmn_5-br-dtl     attach-short()
&scop label-clmn_6-br-dtl   'БД'
&scop sort-clmn_6-br-dtl     string(Cnf.db-num)
&scop label-clmn_7-br-dtl   'Код'
&scop sort-clmn_7-br-dtl     Cnf.Param-Code
&scop label-clmn_8-br-dtl   'Название'
&scop sort-clmn_8-br-dtl     Cnf.Param-Name
&scop label-clmn_9-br-dtl   'Значение'
&scop sort-clmn_9-br-dtl     Cnf.Param-Value
&scop label-clmn_10-br-dtl  'Привязка'
&scop sort-clmn_10-br-dtl    attach-ext()
&scop label-clmn_11-br-dtl  'Примечание'
&scop sort-clmn_11-br-dtl    Cnf.Param-PS
&scop label-clmn_12-br-dtl  'Возможные значения'
&scop sort-clmn_12-br-dtl    cnf-struct.list-value
&scop label-clmn_13-br-dtl  'Значение по умолчанию'
&scop sort-clmn_13-br-dtl    cnf-struct.default-value
&scop label-clmn_14-br-dtl  ' Ош. '
&scop sort-clmn_14-br-dtl    String(Cnf.ErrorExist)
&scop label-clmn_15-br-dtl  ' Тип   параметра '
&scop sort-clmn_15-br-dtl    cnf-struct.data-type
&scop label-clmn_16-br-dtl  'Действует с'
&scop sort-clmn_16-br-dtl    (if cnf.beg-date <> {&beg-unlim-lcns} then string(cnf.beg-date,'99/99/9999') else 'неограничено' )
&scop label-clmn_17-br-dtl  'Действует по'
&scop sort-clmn_17-br-dtl    (if cnf.end-date <> {&end-unlim-lcns} then string(cnf.end-date,'99/99/9999') else 'неограничено.' )

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fr-config
&Scoped-define BROWSE-NAME br-config

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES <record-phrase>

/* Definitions for BROWSE br-config                                     */
&Scoped-define FIELDS-IN-QUERY-br-config {&sort-clmn_1-br-dtl} {&sort-clmn_2-br-dtl} {&sort-clmn_3-br-dtl} {&sort-clmn_4-br-dtl} {&sort-clmn_5-br-dtl} {&sort-clmn_6-br-dtl} {&sort-clmn_7-br-dtl} {&sort-clmn_8-br-dtl} {&sort-clmn_9-br-dtl} {&sort-clmn_10-br-dtl} {&sort-clmn_11-br-dtl} {&sort-clmn_12-br-dtl} {&sort-clmn_13-br-dtl} {&sort-clmn_14-br-dtl} {&sort-clmn_15-br-dtl} {&sort-clmn_16-br-dtl} {&sort-clmn_17-br-dtl}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-config
&Scoped-define SELF-NAME br-config
&Scoped-define QUERY-STRING-br-config FOR EACH <record-phrase>
&Scoped-define OPEN-QUERY-br-config OPEN QUERY {&SELF-NAME} FOR EACH <record-phrase>.
&Scoped-define TABLES-IN-QUERY-br-config <record-phrase>
&Scoped-define FIRST-TABLE-IN-QUERY-br-config <record-phrase>


/* Definitions for DIALOG-BOX fr-config                                 */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-lkp b-chg b-Tgle b-Exp b-Imp ~
b-Log b-sch b-hist b-help r-show-cnf r-cnf-encoded r-cnf-db r-find-in-br ~
sch-param br-config f-param-name
&Scoped-Define DISPLAYED-OBJECTS r-show-cnf r-cnf-encoded r-cnf-db ~
r-find-in-br sch-param f-param-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD attach-ext fr-config
FUNCTION attach-ext RETURNS CHARACTER
  ()  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD attach-short fr-config
FUNCTION attach-short RETURNS CHARACTER
  () FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD can-process fr-config
FUNCTION can-process RETURNS LOGICAL
  ( input mes as character, input param-type as character) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить значение и/или привязку параметра".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 10 BY 1 TOOLTIP "Сохранить изменения и выйти из режима".

DEFINE BUTTON b-Exp
     LABEL "&Экспорт":L
     SIZE 10 BY 1 TOOLTIP "Вывести в файл набор парметров".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория":L
     SIZE 3 BY 1.

DEFINE BUTTON b-Imp
     LABEL "И&мпорт":L
     SIZE 10 BY 1 TOOLTIP "Считать из файла набор параметров".

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1 TOOLTIP "Просмотр параметра".

DEFINE BUTTON b-Log
     LABEL "&Протокол":L
     SIZE 10 BY 1 TOOLTIP "Посмотреть протокол работы".

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1 TOOLTIP "Поставить/снять отметку записи".

DEFINE BUTTON b-save
     LABEL "&Сохранить":L
     SIZE 10 BY 1 TOOLTIP "Сохранить сделанные изменения".

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-Tgle
     LABEL "В&кл/выкл":L
     SIZE 10 BY 1 TOOLTIP "Поставить/снять отметку работы с параметром".

DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>9" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 6 BY .83 NO-UNDO.

DEFINE VARIABLE f-param-name AS CHARACTER FORMAT "X(85)"
     LABEL "Параметр"
      VIEW-AS TEXT
     SIZE 86 BY .67 NO-UNDO.

DEFINE VARIABLE sch-param AS CHARACTER FORMAT "X(80)":U
     VIEW-AS FILL-IN
     SIZE 46.5 BY .83 NO-UNDO.

DEFINE VARIABLE r-cnf-db AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Текущая", "curr-db",
"Выбранная", "sel-db"
     SIZE 31 BY .83 NO-UNDO.

DEFINE VARIABLE r-cnf-encoded AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выборочно", "sel-type"
     SIZE 20 BY .83 NO-UNDO.

DEFINE VARIABLE r-find-in-br AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "По коду", "param-code",
"По названию", "param-name",
"По значению", "param-value"
     SIZE 42 BY .83 NO-UNDO.

DEFINE VARIABLE r-show-cnf AS CHARACTER INITIAL "used"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Включенные", "used",
"Выключенные", "notused",
"Только с ошибками", "onlyerror"
     SIZE 57 BY .83 NO-UNDO.

DEFINE VARIABLE t-cnf-type-k AS LOGICAL INITIAL no
     LABEL "К"
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .83 NO-UNDO.

DEFINE VARIABLE t-cnf-type-notenc AS LOGICAL INITIAL no
     LABEL "Без кодировки"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 NO-UNDO.

DEFINE VARIABLE t-cnf-type-o AS LOGICAL INITIAL no
     LABEL "О"
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .83 NO-UNDO.

DEFINE VARIABLE t-cnf-type-s AS LOGICAL INITIAL no
     LABEL "П"
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY {&browse-name} FOR Cnf, cnf-struct SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-config
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-config fr-config _FREEFORM
  QUERY br-config DISPLAY
      {&sort-clmn_1-br-dtl}  COLUMN-LABEL {&label-clmn_1-br-dtl}  FORMAT "X(1)"
      {&sort-clmn_2-br-dtl}  COLUMN-LABEL {&label-clmn_2-br-dtl}  FORMAT "X(1)"
      {&sort-clmn_3-br-dtl}  COLUMN-LABEL {&label-clmn_3-br-dtl}  FORMAT "X(1)"
      {&sort-clmn_4-br-dtl}  COLUMN-LABEL {&label-clmn_4-br-dtl}  FORMAT "X(1)"
      {&sort-clmn_5-br-dtl}  COLUMN-LABEL {&label-clmn_5-br-dtl}  FORMAT "X(1)"
      {&sort-clmn_6-br-dtl}  COLUMN-LABEL {&label-clmn_6-br-dtl}
      {&sort-clmn_7-br-dtl}  COLUMN-LABEL {&label-clmn_7-br-dtl}
      {&sort-clmn_8-br-dtl}  COLUMN-LABEL {&label-clmn_8-br-dtl}  format "x(256)"
      {&sort-clmn_9-br-dtl}  COLUMN-LABEL {&label-clmn_9-br-dtl}
      {&sort-clmn_10-br-dtl} COLUMN-LABEL {&label-clmn_10-br-dtl} FORMAT "X(25)"
      {&sort-clmn_11-br-dtl} COLUMN-LABEL {&label-clmn_11-br-dtl}
      {&sort-clmn_12-br-dtl} COLUMN-LABEL {&label-clmn_12-br-dtl} FORMAT "X(18)"
      {&sort-clmn_13-br-dtl} COLUMN-LABEL {&label-clmn_13-br-dtl} FORMAT "X(15)"
      {&sort-clmn_14-br-dtl} COLUMN-LABEL {&label-clmn_14-br-dtl}
      {&sort-clmn_15-br-dtl} COLUMN-LABEL {&label-clmn_15-br-dtl} FORMAT "X(17)"
      {&sort-clmn_16-br-dtl} COLUMN-LABEL {&label-clmn_16-br-dtl} FORMAT "X(12)"
      {&sort-clmn_17-br-dtl} COLUMN-LABEL {&label-clmn_17-br-dtl} FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 97 BY 15.75 ROW-HEIGHT-CHARS .63.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fr-config
     b-exit AT ROW 1 COL 2 WIDGET-ID 4
     b-mark AT ROW 1 COL 12 WIDGET-ID 18
     b-save AT ROW 1 COL 15 WIDGET-ID 20
     b-lkp AT ROW 1 COL 25 WIDGET-ID 14
     b-chg AT ROW 1 COL 35 WIDGET-ID 2
     b-Tgle AT ROW 1 COL 45 WIDGET-ID 22
     b-Exp AT ROW 1 COL 55 WIDGET-ID 6
     b-Imp AT ROW 1 COL 65 WIDGET-ID 12
     b-Log AT ROW 1 COL 75 WIDGET-ID 16
     b-sch AT ROW 1 COL 90 WIDGET-ID 40
     b-hist AT ROW 1 COL 93 WIDGET-ID 10
     b-help AT ROW 1 COL 96 WIDGET-ID 8
     r-show-cnf AT ROW 2.5 COL 14.5 NO-LABEL WIDGET-ID 34
     r-cnf-encoded AT ROW 3.5 COL 14.5 NO-LABEL WIDGET-ID 50
     t-cnf-type-k AT ROW 3.5 COL 46 WIDGET-ID 56
     t-cnf-type-s AT ROW 3.5 COL 51 WIDGET-ID 58
     t-cnf-type-o AT ROW 3.5 COL 56 WIDGET-ID 60
     t-cnf-type-notenc AT ROW 3.5 COL 61 WIDGET-ID 62
     r-cnf-db AT ROW 4.5 COL 14.5 NO-LABEL WIDGET-ID 42
     f-db-num AT ROW 4.5 COL 44 COLON-ALIGNED NO-LABEL WIDGET-ID 66
     r-find-in-br AT ROW 5.75 COL 10.5 NO-LABEL WIDGET-ID 70
     sch-param AT ROW 5.75 COL 50.5 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     br-config AT ROW 6.75 COL 2 WIDGET-ID 200
     f-param-name AT ROW 22.75 COL 2 WIDGET-ID 32
     "Параметры:" VIEW-AS TEXT
          SIZE 12 BY .83 AT ROW 2.5 COL 2 WIDGET-ID 46
     "Поиск:" VIEW-AS TEXT
          SIZE 7 BY .83 AT ROW 5.75 COL 2 WIDGET-ID 68
     "Кодировка:" VIEW-AS TEXT
          SIZE 12 BY .83 AT ROW 3.5 COL 2 WIDGET-ID 64
     "БД:" VIEW-AS TEXT
          SIZE 5 BY .83 AT ROW 4.5 COL 9 WIDGET-ID 48
     SPACE(85.87) SKIP(18.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX fr-config
   FRAME-NAME                                                           */
/* BROWSE-TAB br-config sch-param fr-config */
ASSIGN
       FRAME fr-config:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-save IN FRAME fr-config
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-db-num IN FRAME fr-config
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f-db-num:HIDDEN IN FRAME fr-config           = TRUE.

/* SETTINGS FOR FILL-IN f-param-name IN FRAME fr-config
   ALIGN-L                                                              */
ASSIGN
       f-param-name:READ-ONLY IN FRAME fr-config        = TRUE.

/* SETTINGS FOR TOGGLE-BOX t-cnf-type-k IN FRAME fr-config
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       t-cnf-type-k:HIDDEN IN FRAME fr-config           = TRUE.

/* SETTINGS FOR TOGGLE-BOX t-cnf-type-notenc IN FRAME fr-config
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       t-cnf-type-notenc:HIDDEN IN FRAME fr-config           = TRUE.

/* SETTINGS FOR TOGGLE-BOX t-cnf-type-o IN FRAME fr-config
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       t-cnf-type-o:HIDDEN IN FRAME fr-config           = TRUE.

/* SETTINGS FOR TOGGLE-BOX t-cnf-type-s IN FRAME fr-config
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       t-cnf-type-s:HIDDEN IN FRAME fr-config           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-config
/* Query rebuild information for BROWSE br-config
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH <record-phrase>.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY {&browse-name} FOR Cnf, cnf-struct SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE br-config */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX fr-config
/* Query rebuild information for DIALOG-BOX fr-config
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX fr-config */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME fr-config
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fr-config fr-config
ON WINDOW-CLOSE OF FRAME fr-config
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg fr-config
ON CHOOSE OF b-chg IN FRAME fr-config /* Изменить */
DO:

  if not can-process("Параметр закодирован. Изменение не допускается", {&cnf-type-list-protect}) then do:
    return no-apply.
  end.

  run chg-param in this-procedure
    ( input recid( cnf )
    , input false
    ) .

  apply "entry" to browse {&browse-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit fr-config
ON CHOOSE OF b-exit IN FRAME fr-config /* Выход */
DO:

  define buffer buf-chg_cnf for cnf .

  &if defined (stand-alone) = 0 &then                           /* неавтономная работа */

    find first buf-chg_cnf
      where buf-chg_cnf.is-changed = true
      no-error .

    if available buf-chg_cnf then do:
      message
        "Завершение работы с конфигурацией."
        "Сохранить сделанные изменения?"
        view-as alert-box question buttons yes-no-cancel update go-ahead as logical.

      if go-ahead = true then do:
        run waitfram-show in this-procedure ("Сохранение набора параметров").
        run save-cfg in db-hdl
          ( input no
          ) no-error.     /* из интерфейса не разрешаем сохранять с ошибками */

        if error-status :error
          or return-value <> ""
        then do:
            message
              "Попытка сохранить изменения не удалась!" skip
              error-status :get-message(1) skip
              return-value skip
              "Выйти без сохранения?" skip
              view-as alert-box buttons yes-no update go-out as logical.
            if go-out = false then do:
              run waitfram-hide in this-procedure .
              return no-apply.
            end.
        end.
        run waitfram-hide in this-procedure .
      end.
    end.
  &endif
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Exp fr-config
ON CHOOSE OF b-Exp IN FRAME fr-config /* Экспорт */
DO:

  define variable v-err-code     as character no-undo .
  define variable v-qnty-exp-cnf as integer   no-undo .

  define buffer buf_cnf for cnf .

/*  &if defined (stand-alone) > 0 &then /* автономная работа */*/
/*    for each buf_cnf*/
/*      where lookup( buf_cnf.conf-type, {&cnf-type-list-protect} ) > 0*/
/*    on error undo, return no-apply*/
/*    :*/
/*      run conf-enc in this-procedure*/
/*        ( input  buf_cnf.db-num*/
/*        , input  buf_cnf.db-key*/
/*        , input  buf_cnf.param-code*/
/*        , input  buf_cnf.param-value*/
/*        , input  buf_cnf.beg-date*/
/*        , input  buf_cnf.end-date*/
/*        , output buf_cnf.param-encoded*/
/*        ) no-error.*/
/*      if error-status :error then do:*/
/*        message*/
/*          vss-workfile vss-revision vss-description skip*/
/*          substitute("Ошибка кодировки параметра &1 для БД &2", buf_cnf.param-code, buf_cnf.db-num ) skip*/
/*          error-status :get-message(1) skip*/
/*          return-value skip*/
/*          view-as alert-box error .*/
/*        return no-apply .*/
/*      end.*/
/*    end.*/
/*  &endif*/

  run export-cnf in CurCnf-hdl
    ( input this-procedure :handle
    , input (&if defined (stand-alone) = 0 &then /* неавтономная работа */ false &else true &endif)
    , input (if available cnf then recid( cnf ) else ? )
    , input mark-list
    , output v-qnty-exp-cnf
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Произошли ошибки при экспорте параметров!") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  else do:
    if v-qnty-exp-cnf <> ? then do:
      message
        "Экспорт параметров завершен!" skip
        substitute( "Выгружено &1 параметров", v-qnty-exp-cnf ) skip
        view-as alert-box information.
    end.
  end.

  apply "entry" to browse {&browse-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist fr-config
ON CHOOSE OF b-hist IN FRAME fr-config /* История */
DO:
   run adm/cfg-hist.w
    ( input parparentproc
     ,buffer cnf
    )
  .
  apply "entry" to browse {&browse-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Imp fr-config
ON CHOOSE OF b-Imp IN FRAME fr-config /* Импорт */
DO:
  define variable clearcnf   as logical   no-undo.
  define variable uselast    as logical   no-undo.
  define variable v-err-code as character no-undo .
  define variable v-db-load  as character no-undo .

  assign
    fname = {&cnf-file}
  .
  run adm/impi.w
    ( input-output fname
    , output clearcnf
    , output uselast
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске процедуры impi.w" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return no-apply.
  end.
  if fname = "":U then do:
    apply "entry" to browse {&browse-name}.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Импорт конфигурации").

  assign
    v-db-load = "":U
  .
  &if defined (stand-alone) = 0 &then                           /* неавтономная работа */
    if buf-curr_db.db-num > 0 then do:
      assign
        v-db-load = string( buf-curr_db.db-num )
      .
    end.
  &endif

  run toggle-mes in cnf-hdl
    ( input false
    ).

  run import in CurCnf-hdl
  ( input fname
  , input clearcnf
  , input uselast
  , input &if defined (stand-alone) = 0 &then  /* неавтономная работа */ false &else true &endif
  , input v-db-load
  ).

  run toggle-mes in cnf-hdl
    ( input true
    ).

  assign
    v-err-code = return-value
  .

  run chk-unref in curcnf-hdl
    ( input ?
    , input ?
    , input ?
    , input &if defined (stand-alone) = 0 &then  /* неавтономная работа */ false &else true &endif
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при создании недостающих параметров") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run waitfram-hide in this-procedure .
    return no-apply.
  end.

  run waitfram-hide in this-procedure .

  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition {&browse-name} to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .

  if v-err-code = "":U then do:
    message
      "Импорт параметров завершен"
      view-as alert-box information.
  end.
  else do:
    message
      "Параметры не загружены!!!" skip
      "Произошли ошибки при импорте параметров!" skip
      'Просмотреть ошибки можно по кнопке "протокол"'
      view-as alert-box error .
  end.
  apply "entry" to browse {&browse-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp fr-config
ON CHOOSE OF b-lkp IN FRAME fr-config /* Просмотр */
DO:

  define variable rid as integer no-undo.
  rid = recid (cnf).

  &if defined (stand-alone) > 0 &then                           /* автономная работа */
    run ibs-cnfi.p (parparentproc, curcnf-hdl, db-hdl, cnf-hdl, "lkp":U, input-output rid).
  &else
    run adm/cnfi.w (parparentproc, curcnf-hdl, db-hdl, cnf-hdl, "lkp":U, input-output rid).
  &endif

  apply "entry" to browse {&browse-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Log
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Log fr-config
ON CHOOSE OF b-Log IN FRAME fr-config /* Протокол */
DO:
  run adm/show-log.w .
  apply "entry" to browse {&browse-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark fr-config
ON CHOOSE OF b-mark IN FRAME fr-config /* * */
DO:

  define variable v-log as logical no-undo .

  if not available Cnf then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.

  { gbl/markstrn.i cnf mark-list }

  assign
    v-log = {&browse-name}:refresh() in frame {&frame-name}
    v-log = {&browse-name}:select-next-row () in frame {&frame-name}
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save fr-config
ON CHOOSE OF b-save IN FRAME fr-config /* Сохранить */
DO:
  &if defined (stand-alone) > 0 &then                           /* автономная работа */
    message "Не допускается сохранение при работе вне комплекса!".
    return no-apply.
  &else
    run waitfram-show in this-procedure ("Сохранение набора параметров").
    run save-cfg in db-hdl
      ( input no
      ) no-error .     /* из интерфейса не разрешаем сохранять с ошибками */
    if error-status :error
      or return-value <> ""
    then do:
      message
        substitute( "Попытка сохранить изменения не удалась." ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    else do:
      for each cnf
        where cnf.is-changed
      :
        assign
          cnf.is-changed = false
        .
      end.
      run reopen-query in this-procedure
        ( input true
        , input false
        , input '':U
        ) .
    end.

    run waitfram-hide in this-procedure .
    apply "entry" to browse {&browse-name}.
  &endif

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch fr-config
ON CHOOSE OF b-sch IN FRAME fr-config /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  apply "entry" to browse {&browse-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Tgle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Tgle fr-config
ON CHOOSE OF b-Tgle IN FRAME fr-config /* Вкл/выкл */
DO:

  if not can-process("Параметр кодированный. Включение/отключение не допускается", {&cnf-type-list-protect} )
    or ( cnf.NotUsed = false
         and not can-process("Параметр обязательный. Отключение не допускается", {&cnf-obl} )
       )
  then do:
    return no-apply.
  end.

  run chg-param in this-procedure
    ( input recid( cnf )
    , input true
    ) .

  apply "entry" to browse {&browse-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-config
&Scoped-define SELF-NAME br-config
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-config fr-config
ON ANY-PRINTABLE OF br-config IN FRAME fr-config
DO:
  assign
    sch-param:screen-value = sch-param:screen-value + last-event:label
  .
  apply "entry" to sch-param in frame {&frame-name}.
  apply "end" to sch-param in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-config fr-config
ON MOUSE-SELECT-DBLCLICK OF br-config IN FRAME fr-config
OR RETURN OF {&SELF-NAME} IN FRAME {&FRAME-NAME}
DO:
  apply "choose" to b-chg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-config fr-config
ON ROW-DISPLAY OF br-config IN FRAME fr-config
DO:

  if lookup( string( recid( cnf ) ), mark-list ) > 0 then do:
    assign
      mark = "*":U
    .
  end.
  else do:
    assign
      mark = "":U
    .
  end.

  case cnf.ErrorExist:
    when 0 then do:
       {&sort-clmn_7-br-dtl}:fgcolor in browse {&browse-name} = 0 .
    end.
    when 1 then do:
       {&sort-clmn_7-br-dtl}:fgcolor in browse {&browse-name} = 9 .
    end.
    when 2 then do:
       {&sort-clmn_7-br-dtl}:fgcolor in browse {&browse-name} = 12 .
    end.
  end case.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-config fr-config
ON VALUE-CHANGED OF br-config IN FRAME fr-config
DO:

  if available cnf then do:
    assign
      f-param-name :screen-value = cnf.param-name
    .
  end.
  else do:
    assign
      f-param-name :screen-value = "":U
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-db-num fr-config
ON RETURN OF f-db-num IN FRAME fr-config
DO:

  assign
    f-db-num
  .

  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition {&browse-name} to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cnf-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cnf-db fr-config
ON VALUE-CHANGED OF r-cnf-db IN FRAME fr-config
DO:

  assign
    r-cnf-db
  .
  disable
    f-db-num
    with frame {&frame-name}
  .
  hide
    f-db-num
    in frame {&frame-name}
  .

  case r-cnf-db :
    &if defined (stand-alone) = 0 &then  /* неавтономная работа */
      when "curr-db":U then do:
        if available buf-curr_db then do:
          assign
            f-db-num = buf-curr_db.db-num
          .
          display
            f-db-num
            with frame {&frame-name}
          .
        end.
      end.
    &endif
    when "sel-db":U then do:
      enable
        f-db-num
        with frame {&frame-name}
      .
      apply "entry" to f-db-num in frame {&frame-name}.
    end.
  end case.
  if lookup( r-cnf-db, "all,curr-db":U ) > 0 then do:
    if available cnf then do:
      assign
        v-cnf-rec = recid( cnf )
      .
    end.
    run reopen-query in this-procedure
      ( input true
      , input false
      , input '':U
      ) .
    reposition {&browse-name} to recid v-cnf-rec no-error .
    assign
      v-cnf-rec = ?
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cnf-encoded
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cnf-encoded fr-config
ON VALUE-CHANGED OF r-cnf-encoded IN FRAME fr-config
DO:
  assign
    r-cnf-encoded
  .
  if r-cnf-encoded = "all":U then do:
    hide
      t-cnf-type-k
      t-cnf-type-s
      t-cnf-type-o
      t-cnf-type-notenc
      in frame {&frame-name}
    .
  end.
  else do:
    enable
      t-cnf-type-k
      t-cnf-type-s
      t-cnf-type-o
      t-cnf-type-notenc
      with frame {&frame-name}
    .
  end.

  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition {&browse-name} to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-find-in-br
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-find-in-br fr-config
ON VALUE-CHANGED OF r-find-in-br IN FRAME fr-config
DO:
  assign
    r-find-in-br
  .
  case r-find-in-br :
    when "param-code":U then do:
      assign
        sch-param :format       = "X(12)"
        sch-param :width-chars = 13.0
      .
    end.
    when "param-name":U
      or when "param-vale":U
    then do:
      assign
        sch-param :format       = "X(80)"
        sch-param :width-chars = 46.5
      .
    end.
  end case.
  assign
    sch-param:screen-value = "":U
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-show-cnf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-show-cnf fr-config
ON VALUE-CHANGED OF r-show-cnf IN FRAME fr-config
DO:
  assign
    r-show-cnf
  .

  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition {&browse-name} to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-param fr-config
ON CTRL-J OF sch-param IN FRAME fr-config
DO:
  assign
    r-find-in-br
  .
  run find-param in this-procedure
    ( input true
    , input r-find-in-br
    , input ( input frame {&frame-name} sch-param )
    ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-param fr-config
ON RETURN OF sch-param IN FRAME fr-config
DO:
  assign
    r-find-in-br
  .
  run find-param in this-procedure
    ( input false
    , input r-find-in-br
    , input ( input frame {&frame-name} sch-param )
    ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-cnf-type-k
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-cnf-type-k fr-config
ON VALUE-CHANGED OF t-cnf-type-k IN FRAME fr-config /* К */
DO:
   assign
     t-cnf-type-k
   .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition {&browse-name} to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-cnf-type-notenc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-cnf-type-notenc fr-config
ON VALUE-CHANGED OF t-cnf-type-notenc IN FRAME fr-config /* Без кодировки */
DO:
  assign
    t-cnf-type-notenc
  .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition {&browse-name} to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-cnf-type-o
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-cnf-type-o fr-config
ON VALUE-CHANGED OF t-cnf-type-o IN FRAME fr-config /* О */
DO:
  assign
    t-cnf-type-o
  .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition {&browse-name} to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-cnf-type-s
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-cnf-type-s fr-config
ON VALUE-CHANGED OF t-cnf-type-s IN FRAME fr-config /* П */
DO:
  assign
    t-cnf-type-s
  .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition {&browse-name} to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK fr-config


/* ***************************  Main Block  *************************** */
&if defined (stand-alone) > 0 &then  /* неавтономная работа */
  /* нужно свое окошко */
  DEFINE VAR w-config AS WIDGET-HANDLE NO-UNDO.
  CREATE WINDOW w-config ASSIGN
         HIDDEN             = YES
         TITLE              = "IBS Trade House"
         MAX-HEIGHT         = 22.63
         MAX-WIDTH          = 98.88
         VIRTUAL-HEIGHT     = 22.63
         VIRTUAL-WIDTH      = 100
         RESIZE             = no
         SCROLL-BARS        = yes
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
  ASSIGN CURRENT-WINDOW             = w-config
         SESSION:SYSTEM-ALERT-BOXES = (CURRENT-WINDOW:MESSAGE-AREA = NO)
         session:three-d            = yes.
&ENDIF

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

run adm/cnf-str.p persistent set cnf-hdl no-error.
if not valid-handle (cnf-hdl)  then do:
   message
     vss-workfile vss-revision vss-description skip
     "Ошибка при попытке инициализировать работу со схемой конфигурации cnf-str.p" skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error .
   return.
end.
&if defined (stand-alone) = 0 &then  /* неавтономная работа */
  run adm/cnf-db.p persistent set db-hdl no-error.
  if not valid-handle (db-hdl)  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при попытке инициализировать работу со схемой конфигурации cnf-db.p" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return.
  end.
&endif
run adm/cnf-cnf.p persistent set CurCnf-hdl no-error.
if not valid-handle (CurCnf-hdl)  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при попытке инициализировать работу со схемой конфигурации cnf-cnf.p" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
   return.
end.

assign
  {&browse-name}:num-locked-columns in frame {&frame-name} = 7
  .

{ gbl/mv-clmn.i
 &ext-col = 15
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
 &table-name =  "cnf"
 &start-column = 8
}

{ gbl/srt-clmd.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name =  "cnf"
&ext-col = 17
&start-column  = 8
&label-clmn_1  = "{&label-clmn_1-br-dtl}"
&sort-clmn_1   = "{&sort-clmn_1-br-dtl}"
&label-clmn_2  = "{&label-clmn_2-br-dtl}"
&sort-clmn_2   = "{&sort-clmn_2-br-dtl}"
&label-clmn_3  = "{&label-clmn_3-br-dtl}"
&sort-clmn_3   = "{&sort-clmn_3-br-dtl}"
&label-clmn_4  = "{&label-clmn_4-br-dtl}"
&sort-clmn_4   = "{&sort-clmn_4-br-dtl}"
&label-clmn_5  = "{&label-clmn_5-br-dtl}"
&sort-clmn_5   = "{&sort-clmn_5-br-dtl}"
&label-clmn_6  = "{&label-clmn_6-br-dtl}"
&sort-clmn_6   = "{&sort-clmn_6-br-dtl}"
&label-clmn_7  = "{&label-clmn_7-br-dtl}"
&sort-clmn_7   = "{&sort-clmn_7-br-dtl}"
&label-clmn_8  = "{&label-clmn_8-br-dtl}"
&sort-clmn_8   = "{&sort-clmn_8-br-dtl}"
&label-clmn_9  = "{&label-clmn_9-br-dtl}"
&sort-clmn_9   = "substring({&sort-clmn_9-br-dtl},1,180)"
&label-clmn_10 = "{&label-clmn_10-br-dtl}"
&sort-clmn_10  = "{&sort-clmn_10-br-dtl}"
&label-clmn_11 = "{&label-clmn_11-br-dtl}"
&sort-clmn_11  = "substring({&sort-clmn_11-br-dtl},1,180)"
&label-clmn_12 = "{&label-clmn_12-br-dtl}"
&sort-clmn_12  = "substring({&sort-clmn_12-br-dtl},1,180)"
&label-clmn_13 = "{&label-clmn_13-br-dtl}"
&sort-clmn_13  = "{&sort-clmn_13-br-dtl}"
&label-clmn_14 = "{&label-clmn_14-br-dtl}"
&sort-clmn_14  = "{&sort-clmn_14-br-dtl}"
&label-clmn_15 = "{&label-clmn_15-br-dtl}"
&sort-clmn_15  = "{&sort-clmn_15-br-dtl}"
&label-clmn_16 = "{&label-clmn_16-br-dtl}"
&sort-clmn_16  = "{&sort-clmn_16-br-dtl}"
&label-clmn_17 = "{&label-clmn_17-br-dtl}"
&sort-clmn_17  = "{&sort-clmn_17-br-dtl}"

&open-query = "run reopen-query in this-procedure ( input true, input false, input '':U )."
&open-query-otherwise = "run reopen-query in this-procedure ( input true, input false, input '':U )."
&re-move-clmn = "yes"
&mv-brw-default = "yes"
&sort-column-name  = "v-sort-column-name"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i "v-cnf-rec = recid(cnf). ~
                  run reopen-query in this-procedure ( input yes, input no, input '':U). reposition br-config to recid v-cnf-rec no-error. ~
                  v-cnf-rec = ?. ~
                  apply 'value-changed' TO br-config. ~
                 " }

{ gbl/setfltnm.i }


{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-exit }

&if defined (stand-alone) > 0 &then
  { gbl/app_help.i &disable_diasize=true }
&else
  { gbl/app_help.i }
&endif


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define variable par-type as character         no-undo . /* Для считывания имени файла конфигурации */
  define variable ErrExist as integer initial 0 no-undo.
  define variable v-log    as logical           no-undo .

  &if defined (stand-alone) = 0 &then  /* неавтономная работа */
    define buffer buf_sys-ctrl for ub.sys-ctrl .
  &endif

  run waitfram-show in this-procedure ("Чтение схемы конфигурации").

  run init in cnf-hdl
    ( input ""
    , input no
    , input no
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при старте init in cnf-hdl" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    run waitfram-hide in this-procedure .
    return error.
  end.
  if return-value <> "" then do:
    assign
      ErrExist = max(integer (return-value), ErrExist)
    .
  end.
  &if defined (stand-alone) = 0 &then  /* неавтономная работа */
    run init in db-hdl
      ( input cnf-hdl
      ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при старте init in db-hdl" ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      run waitfram-hide in this-procedure .
      return error.
    end.
    if return-value <> "" then do:
      assign
        ErrExist = max(integer (return-value), ErrExist)
      .
    end.
  &endif
  run init in CurCnf-hdl
    ( input cnf-hdl
    , input db-hdl
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при старте init in CurCnf-hdl" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    run waitfram-hide in this-procedure .
    return error.
  end.
  if return-value <> "" then do:
    assign
      ErrExist = max(integer (return-value), ErrExist)
    .
  end.

  run fill-cnf-struct in this-procedure
    ( input {&cnf-struct-file}
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при старте fill-cnf-struct" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    run waitfram-hide in this-procedure .
    return error.
  end.

  if return-value <> "" then do:
    assign
      ErrExist = max(integer (return-value), ErrExist)
    .
  end.

&if defined (stand-alone) = 0 &then /* неавтономная работа */
  find first buf_sys-ctrl no-lock .
  find first buf-curr_db no-lock
    where buf-curr_db.db-num = buf_sys-ctrl.db-num
    no-error.
  if not available buf-curr_db then do:
    message
      "Ошибка при чтении списка баз данных" skip
      view-as alert-box error .
    undo, return error .
  end.
  assign
    v-title0 = substitute( "&1 (Текущая БД &2, ключ &3)", v-title0, buf-curr_db.db-num, buf-curr_db.db-key )
  .
  run LoadDB in db-hdl
    no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при чтении параметров из БД") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run waitfram-hide in this-procedure .
    return error.
  end.
  if return-value <> "" then do:
    assign
      ErrExist = max(integer (return-value), ErrExist)
    .
  end.
&endif

  run chk-unref in curcnf-hdl
    ( input ?
    , input ?
    , input ?
    , input &if defined (stand-alone) = 0 &then  /* неавтономная работа */ false &else true &endif
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при создании недостающих параметров") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run waitfram-hide in this-procedure .
    return error.
  end.

  run waitfram-hide in this-procedure .

  if ErrExist > 0 then do:
    message
      substitute("При загрузке параметров были ошибки.") skip
      substitute("Проверьте протокол работы.") skip
      view-as alert-box error .
  end.

  run enable_UI in this-procedure .

  &if defined (stand-alone) > 0 &then  /* автономная работа */
    assign
      v-log = r-cnf-db:disable( "Текущая" )
    .
  &endif

  apply "value-changed":u to r-find-in-br in frame {&frame-name} .

  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .

  assign
    {&sort-clmn_8-br-dtl}:resizable in browse {&browse-name} = true
    {&sort-clmn_8-br-dtl}:width in browse {&browse-name} = 30
    {&sort-clmn_9-br-dtl}:resizable in browse {&browse-name}  = true
    {&sort-clmn_9-br-dtl}:width in browse {&browse-name} = 30
  .

  run toggle-mes in cnf-hdl
    ( input true
    ).

  &if defined (stand-alone) = 0 &then  /* неавтономная работа */
    assign
      b-save:sensitive in frame {&frame-name} = true
    .
  &endif

  wait-for go of frame {&frame-name}.

end.
run disable_UI in this-procedure .

run kill in cnf-hdl.
run kill in curcnf-hdl.
&if defined (stand-alone) = 0 &then  /* неавтономная работа */
  run kill in db-hdl.
&endif
for each cnf
:
  delete cnf .
end.
for each cnf-struct
:
  delete cnf-struct .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-param fr-config
PROCEDURE chg-param :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-rid         as integer   no-undo . /* именоо int, а не recid */
  define input parameter p-turn-on-off as logical   no-undo .

  chg-block:
  do transaction
  on error  undo chg-block, return error substitute( "&1 (chg-param). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo chg-block, return error substitute( "&1 (chg-param). stop", vss-workfile )
  on endkey undo chg-block, return error substitute( "&1 (chg-param). endkey", vss-workfile )
  :

    define buffer buf_cnf      for cnf .
    define buffer buf-chg_cnf  for cnf .
    define buffer buf-all_cnf  for cnf .
    define buffer buf-next_cnf for cnf .

    define variable v-log           as logical   no-undo .
    define variable v-chg-db-num    as logical   no-undo .
    define variable v-chg-key       as logical   no-undo .
    define variable v-old-db-num    as integer   no-undo .
    define variable v-old-db-key    as character no-undo .

    find first buf_cnf
      where recid( buf_cnf ) = p-rid
      no-error .
    if not available buf_cnf then do:
      return .
    end.

    if p-turn-on-off = true
      and buf_cnf.NotUsed = false
    then do:
      assign
        buf_cnf.NotUsed = true
      .
    end.
    else do:
      if buf_cnf.db-num = ? then do:
        create buf-chg_cnf .
        buffer-copy buf_cnf to buf-chg_cnf .
        assign
          p-rid = recid( buf-chg_cnf )
        .
      end.
      else do:
        find first buf-chg_cnf
          where recid( buf-chg_cnf ) = p-rid
          .
      end.

      for each tt_cnf
      :
        delete tt_cnf .
      end.

      create tt_cnf .
      buffer-copy buf-chg_cnf to tt_cnf .

      assign
        v-old-db-num = buf-chg_cnf.db-num
        v-old-db-key = buf-chg_cnf.db-key
      .

      &if defined (stand-alone) > 0 &then /* автономная работа */
        run ibs-cnfi.p (parparentproc, curcnf-hdl, db-hdl, cnf-hdl, "edit":U, input-output p-rid).
      &else
        run adm/cnfi.w (parparentproc, curcnf-hdl, db-hdl, cnf-hdl, "edit":U, input-output p-rid).
      &endif

      buffer-compare tt_cnf except is-changed to buf-chg_cnf save result in v-log .

      if tt_cnf.host-code = 0
        and tt_cnf.obj-type = "":U
        and tt_cnf.obj-code = 0
        and tt_cnf.beg-date = {&beg-unlim-lcns}
        and tt_cnf.end-date = {&end-unlim-lcns}
        and ( tt_cnf.host-code <> buf-chg_cnf.host-code
              or tt_cnf.obj-type <> buf-chg_cnf.obj-type
              or tt_cnf.obj-code <> buf-chg_cnf.obj-code
              or tt_cnf.beg-date <> buf-chg_cnf.beg-date
              or tt_cnf.end-date <> buf-chg_cnf.end-date
              or tt_cnf.db-num   <> buf-chg_cnf.db-num
            )
      then do:
        create buf_cnf .
        buffer-copy tt_cnf to buf_cnf .
      end.

      for each tt_cnf
      :
        delete tt_cnf .
      end.

      if p-rid = ?                /* если была ошибка */
        or ( p-rid <> ?           /* или ничего не изменили */
             and p-rid > 0
             and v-log = true
           )
      then do:
        undo chg-block, return .
      end.

      if p-rid = -1               /* удалили после приведения в соответствие со схемой */
        and available buf-chg_cnf
      then do:
        delete buf-chg_cnf.
      end.

      if available buf-chg_cnf then do:
        run chk-param in curcnf-hdl
          ( buffer buf-chg_cnf
          ).

        assign
          buf-chg_cnf.errorexist = 0
          buf-chg_cnf.is-changed = true
        .
        &if defined (stand-alone) > 0 &then /* автономная работа */
          assign
            v-chg-key    = true  /* по умолчанию считаем, что ключ меняется */
            v-chg-db-num = false /* а вот номер БД по умолчению не меняем */
          .
          if v-old-db-num <> ?
            and v-old-db-num <> buf-chg_cnf.db-num
          then do:
            message
              substitute( "Был изменен номер БД для параметра." ) skip
              substitute( "Вы хотите произвести аналогичную замену во всем наборе параметров?" ) skip
              substitute( "cтарое значение '&1'", v-old-db-num ) skip
              substitute( "новое значение '&1'", buf-chg_cnf.db-num ) skip
              view-as alert-box question buttons yes-no update v-chg-db-num
              .
            if v-chg-db-num = true then do:
              for each buf-all_cnf
                where buf-all_cnf.db-num = v-old-db-num
              on error undo chg-block, return error return-value
              :
                find first buf-next_cnf no-lock
                  where buf-next_cnf.param-code = buf-all_cnf.param-code
                    and buf-next_cnf.host-code  = buf-all_cnf.host-code
                    and buf-next_cnf.obj-type   = buf-all_cnf.obj-type
                    and buf-next_cnf.obj-code   = buf-all_cnf.obj-code
                    and buf-next_cnf.beg-date   = buf-all_cnf.beg-date
                    and buf-next_cnf.end-date   = buf-all_cnf.end-date
                    and buf-next_cnf.db-num     = buf-chg_cnf.db-num
                  no-error .
                if available buf-next_cnf then do:
                  delete buf-all_cnf .
                end.
                else do:
                  assign
                    buf-all_cnf.db-num = buf-chg_cnf.db-num
                  .
                end.
              end.
            end.
          end.

          find first buf-next_cnf
            where buf-next_cnf.db-num = buf-chg_cnf.db-num
              and recid( buf-next_cnf ) <> recid( buf-chg_cnf )
            no-error .

          if not available buf-next_cnf then do:
            /* добавилась новая БД и для нее надо сгенерить остальные параметры */
            run chk-unref in curcnf-hdl
              ( input ?
              , input string( buf-chg_cnf.db-num )
              , input ?
              , input &if defined (stand-alone) = 0 &then  /* неавтономная работа */ false &else true &endif
              ) no-error.
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute("Ошибка при создании недостающих параметров") skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo chg-block, return error .
            end.
          end.
          else do:
            if v-old-db-num = ? then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute("Сюда не должны были попасть!") skip
                substitute("Это какая-то ошибка!") skip
                view-as alert-box error .

            end.

            for first buf-next_cnf
              where ( buf-next_cnf.db-num = buf-chg_cnf.db-num
                      and buf-next_cnf.db-key > buf-chg_cnf.db-key
                    )
                or ( buf-next_cnf.db-num = buf-chg_cnf.db-num
                    and buf-next_cnf.db-key < buf-chg_cnf.db-key
                  )
            on error undo chg-block, return error return-value
            :
              assign
                v-chg-key = false
              .
              message
                substitute( "Существуют параметры с Ключем БД отличным от заданного в текущем параметре." ) skip
                substitute( "Вы хотите произвести замену Ключей БД во всем наборе параметров" ) skip
                substitute( "для БД &1 на новое значение ключа '&2'?", buf-chg_cnf.db-num, buf-chg_cnf.db-key ) skip
                view-as alert-box question buttons yes-no update v-chg-key
                .
            end.
          end.

          if v-chg-key = true then do:
            for each buf-all_cnf
              where buf-all_cnf.db-num = buf-chg_cnf.db-num
            on error undo chg-block, return error return-value
            :
              assign
                buf-all_cnf.db-key = buf-chg_cnf.db-key
              .
            end.
          end.
        &endif
      end.
    end.
  end.

  if available buf-chg_cnf then do:
    assign
      v-cnf-rec = recid( buf-chg_cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition {&browse-name} to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .

  return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-param fr-config
PROCEDURE chk-param :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define parameter buffer b-cnf for cnf.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI fr-config  _DEFAULT-DISABLE
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
  HIDE FRAME fr-config.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI fr-config  _DEFAULT-ENABLE
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
  DISPLAY r-show-cnf r-cnf-encoded r-cnf-db r-find-in-br sch-param f-param-name
      WITH FRAME fr-config.
  ENABLE b-exit b-mark b-lkp b-chg b-Tgle b-Exp b-Imp b-Log b-sch b-hist b-help
         r-show-cnf r-cnf-encoded r-cnf-db r-find-in-br sch-param br-config
         f-param-name
      WITH FRAME fr-config.
  {&OPEN-BROWSERS-IN-QUERY-fr-config}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-param fr-config
PROCEDURE find-param :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-find-next as logical   no-undo .
  define input  parameter p-sch-type  as character no-undo .
  define input  parameter p-sch-code  as character no-undo .

  define variable v-add-where as character no-undo .

  assign
    p-sch-code = replace( p-sch-code, {&single-quote}, {&single-quote} + {&single-quote} )
  .
  case p-sch-type :
    when "param-code":U then do:
      assign
        v-add-where = substitute("and cnf.param-code begins &1&2&1", {&double-quote}, p-sch-code)
      .
    end.
    when "param-name":U then do:
      assign
        v-add-where = substitute("and cnf.param-name contains &1&2&1", {&double-quote}, p-sch-code)
      .
    end.
    when "param-vale":U then do:
      assign
        v-add-where = substitute("and cnf.param-name contains &1&2&1", {&double-quote}, p-sch-code)
      .
    end.
  end case.

  run reopen-query in this-procedure
    ( input false
    , input p-find-next
    , input v-add-where
    ) .
  apply "entry":u to sch-param in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch fr-config
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = substitute( "temp-handle#cnf#&1", buffer cnf:handle ) + {&comma-char} + substitute( "temp-handle#cnf-struct#&1", buffer cnf-struct:handle )
  join-tbl = 'cnf,cnf-struct':U
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .

run fltfield-add in this-procedure('NotUsed'    , '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('Is-Changed' , '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('param-code' , '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('param-name' , '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num'     , '', 'db'  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code'  , '', 'cli' , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('beg-date'   , '', 'date', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('end-date'   , '', 'date', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('param-value', '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
assign
  dim = dim + {&comma-char}
.
run fltfield-add in this-procedure('list-value', 'Возможные значения', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('default-value', 'Значение по умолчанию', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT v-filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query fr-config
PROCEDURE reopen-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened   as logical   no-undo .
  define variable v-sort-column-phrase as character no-undo .

  run waitfram-show in this-procedure ( input "Ждите...").

  case v-sort-column-name :
    when "" then do:
      assign
        v-sort-column-phrase = "":U
      .
    end.
    otherwise do:
      assign
        v-sort-column-phrase = substitute( "by &1", v-sort-column-name )
      .
    end.
  end case.

&scop flt-open-open-query OPEN QUERY br-config FOR EACH cnf
&scop flt-open-dyn_open-query  FOR EACH cnf
&scop flt-open-query-handle query br-config :handle
&scop flt-open-open-query-tail  , first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code
&scop flt-open-dyn_open-query-tail  substitute(', first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code' )
&scop flt-open-query-was-opened  l-query-was-opened
&scop flt-open-sort-column-phrase v-sort-column-phrase
&scop flt-open-call-point v-filter-point
&scop flt-open-set-filter-name set-filter-name
&scop flt-open-indexed-reposition indexed-reposition
&scop flt-open-query p-open-query
&scop flt-open-table-name cnf
&scop flt-open-search-option no-lock
&scop flt-open-find-next p-find-next
&scop flt-open-find-recid v-cnf-rec
&scop flt-open-find-condition p-find-condition
&scop flt-open-find-buffer-name cnf
&scop flt-open-waitfram false

  assign
    v-filter-point = v-filter-point0 + {&delim-par} + v-filter-pointr
    frame {&frame-name}:title = substitute( "&1", v-title0 )
  .

  case r-show-cnf :
    when "all":U then do:
      { gbl/fltopend.i
        &where-cond     = " ~
                           ( r-cnf-encoded = 'all':U ~
                             or ( t-cnf-type-k = true      and cnf.conf-type = {&cnf-enc} ) ~
                             or ( t-cnf-type-s = true      and cnf.conf-type = {&cnf-sal} ) ~
                             or ( t-cnf-type-o = true      and cnf.conf-type = {&cnf-obl} ) ~
                             or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       ) ~
                           ) ~
                           and
                           ( r-cnf-db = 'all':U ~
                             or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num ) ~
                           ) ~
                          "
        &dyn_where-cond = "substitute( '( &2 ~
                                              or ( &3 and cnf.conf-type = &1{&bef-cnf-enc}&1 ) ~
                                              or ( &4 and cnf.conf-type = &1{&bef-cnf-sal}&1 ) ~
                                              or ( &5 and cnf.conf-type = &1{&bef-cnf-obl}&1 ) ~
                                              or ( &6 and cnf.conf-type = &1&1   ) ~
                                            ) ~
                                        and ~
                                         (  &1&7&1 ~
                                           or ( not &7 and cnf.db-num = &1&8&1 ) ~
                                         )' ~
                                        ,~{&double-quote~} ~
                                        ,r-cnf-encoded = 'all':U ~
                                        ,t-cnf-type-k = true ~
                                        ,t-cnf-type-s = true ~
                                        ,t-cnf-type-o = true ~
                                        ,t-cnf-type-notenc = true ~
                                        ,r-cnf-db ='all':U ~
                                        ,f-db-num ~
                                     ) ~
                          "
        &use-ind        = " "
        &by             = " "
      }
/*        &by             = "by cnf.param-code"*/
    end.
    when "used":U then do:
      { gbl/fltopend.i
        &where-cond     = "cnf.notused = false ~
                           and ~
                           ( r-cnf-encoded = 'all':U ~
                             or ( t-cnf-type-k = true      and cnf.conf-type = {&cnf-enc} ) ~
                             or ( t-cnf-type-s = true      and cnf.conf-type = {&cnf-sal} ) ~
                             or ( t-cnf-type-o = true      and cnf.conf-type = {&cnf-obl} ) ~
                             or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       ) ~
                           ) ~
                           and
                           ( r-cnf-db = 'all':U ~
                             or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num ) ~
                           ) ~
                          "
        &dyn_where-cond = "substitute( 'cnf.notused = false ~
                                        and ( &2 ~
                                              or ( &3 and cnf.conf-type = &1{&bef-cnf-enc}&1 ) ~
                                              or ( &4 and cnf.conf-type = &1{&bef-cnf-sal}&1 ) ~
                                              or ( &5 and cnf.conf-type = &1{&bef-cnf-obl}&1 ) ~
                                              or ( &6 and cnf.conf-type = &1&1   ) ~
                                            ) ~
                                        and ~
                                         (  &1&7&1 ~
                                           or ( not &7 and cnf.db-num = &1&8&1 ) ~
                                         )' ~
                                        ,~{&double-quote~} ~
                                        ,r-cnf-encoded = 'all':U ~
                                        ,t-cnf-type-k = true ~
                                        ,t-cnf-type-s = true ~
                                        ,t-cnf-type-o = true ~
                                        ,t-cnf-type-notenc = true ~
                                        ,r-cnf-db ='all':U ~
                                        ,f-db-num ~
                                     ) ~
                          "
        &use-ind        = " "
        &by             = " "
      }
    end.
    when "notused":U then do:
      { gbl/fltopend.i
        &where-cond     = "cnf.notused = true ~
                           and ~
                           ( r-cnf-encoded = 'all':U ~
                             or ( t-cnf-type-k = true      and cnf.conf-type = {&cnf-enc} ) ~
                             or ( t-cnf-type-s = true      and cnf.conf-type = {&cnf-sal} ) ~
                             or ( t-cnf-type-o = true      and cnf.conf-type = {&cnf-obl} ) ~
                             or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       ) ~
                           ) ~
                           and
                           ( r-cnf-db = 'all':U ~
                             or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num ) ~
                           ) ~
                          "
        &dyn_where-cond = "substitute( 'cnf.notused = true ~
                                        and ( &2 ~
                                              or ( &3 and cnf.conf-type = &1{&bef-cnf-enc}&1 ) ~
                                              or ( &4 and cnf.conf-type = &1{&bef-cnf-sal}&1 ) ~
                                              or ( &5 and cnf.conf-type = &1{&bef-cnf-obl}&1 ) ~
                                              or ( &6 and cnf.conf-type = &1&1   ) ~
                                            ) ~
                                        and ~
                                         (  &1&7&1 ~
                                           or ( not &7 and cnf.db-num = &1&8&1 ) ~
                                         )' ~
                                        ,~{&double-quote~} ~
                                        ,r-cnf-encoded = 'all':U ~
                                        ,t-cnf-type-k = true ~
                                        ,t-cnf-type-s = true ~
                                        ,t-cnf-type-o = true ~
                                        ,t-cnf-type-notenc = true ~
                                        ,r-cnf-db ='all':U ~
                                        ,f-db-num ~
                                     ) ~
                          "
        &use-ind        = " "
        &by             = " "
      }
    end.
    when "onlyerror":U then do:
      { gbl/fltopend.i
        &where-cond     = "cnf.errorexist <> 0 ~
                           and ~
                           ( r-cnf-encoded = 'all':U ~
                             or ( t-cnf-type-k = true      and cnf.conf-type = {&cnf-enc} ) ~
                             or ( t-cnf-type-s = true      and cnf.conf-type = {&cnf-sal} ) ~
                             or ( t-cnf-type-o = true      and cnf.conf-type = {&cnf-obl} ) ~
                             or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       ) ~
                           ) ~
                           and
                           ( r-cnf-db = 'all':U ~
                             or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num ) ~
                           ) ~
                          "
        &dyn_where-cond = "substitute( 'cnf.errorexist <> 0 ~
                                        and ( &2 ~
                                              or ( &3 and cnf.conf-type = &1{&bef-cnf-enc}&1 ) ~
                                              or ( &4 and cnf.conf-type = &1{&bef-cnf-sal}&1 ) ~
                                              or ( &5 and cnf.conf-type = &1{&bef-cnf-obl}&1 ) ~
                                              or ( &6 and cnf.conf-type = &1&1   ) ~
                                            ) ~
                                        and ~
                                         (  &1&7&1 ~
                                           or ( not &7 and cnf.db-num = &1&8&1 ) ~
                                         )' ~
                                        ,~{&double-quote~} ~
                                        ,r-cnf-encoded = 'all':U ~
                                        ,t-cnf-type-k = true ~
                                        ,t-cnf-type-s = true ~
                                        ,t-cnf-type-o = true ~
                                        ,t-cnf-type-notenc = true ~
                                        ,r-cnf-db ='all':U ~
                                        ,f-db-num ~
                                     ) ~
                          "
        &use-ind        = " "
        &by             = " "
      }
    end.
  end case.


  if p-open-query = false
  then do:
    if v-cnf-rec <> ? then do:
      reposition {&browse-name} to recid v-cnf-rec no-error .
    end.
    else do:
      message
        substitute("Параметр по данному запросу не найден!") skip
        view-as alert-box information .
    end.
    if v-fltopend-rowid[1] <> ? then do:
      query br-config:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
    end.
  end.

  apply "value-changed" to {&browse-name} in frame {&frame-name}.
  apply "entry" to {&browse-name} in frame {&frame-name}.

  run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION attach-ext fr-config
FUNCTION attach-ext RETURNS CHARACTER
  () :

  define variable ret-value as character initial "":U no-undo .

  if cnf-struct.attach-type <> {&cnf-no} then do:
    assign
      ret-value = substr (cnf-struct.attach-type, 1, 3) + " "
    .
    case cnf-struct.attach-type:
      when {&cnf-company}
      or when {&cnf-object}
      then do:
        if cnf.host-code <> 0 then do:
          assign
            ret-value = ret-value + {&cnf-company} + " " + string(cnf.host-code)
          .
        end.
        if cnf.obj-code  <> 0 then do:
          assign
            ret-value = ret-value + ", " + cnf.obj-type + " " + string(cnf.obj-code)
          .
        end.
      end.
    end case.
  end.
  return ret-value.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION attach-short fr-config
FUNCTION attach-short RETURNS CHARACTER
  ():

  define variable ret-value as character initial "":U no-undo .

  if cnf.host-code <> 0 then do:
    if cnf.obj-code =  0 then do:
      assign
        ret-value = substr({&cnf-company}, 1, 1)
      .
    end.
    else do:
      assign
        ret-value = substr({&cnf-object}, 1, 1)
      .
    end.
  end.

  return ret-value.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION can-process fr-config
FUNCTION can-process RETURNS LOGICAL
  ( input mes as character, input param-type as character):

  if not available cnf then do:
    message
      substitute("Не выбран параметр!") skip
      view-as alert-box error .
    return false.
  end.
  if not available cnf-struct then do:
    message
      substitute("Нет описания параметра!") skip
      view-as alert-box error .
    return false.
  end.

  &if defined (stand-alone) = 0 &then  /* неавтономная работа */
    if lookup (cnf.conf-type, param-type) > 0 then do:
      message
        substitute( "&1", mes ) skip
        view-as alert-box error .
      return false.
    end.
  &endif
  return true.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME