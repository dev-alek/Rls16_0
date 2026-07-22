&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Параметры файла импорта товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER iOnlyfile     as logical no-undo.
DEFINE INPUT PARAMETER vattaxcd      as integer no-undo.
DEFINE INPUT PARAMETER slttaxcd      as integer no-undo.
define input parameter custvalue     as character no-undo .
define input parameter tnvedimp      as logical no-undo .
DEFINE OUTPUT PARAMETER v_os-file    AS CHAR    NO-UNDO INIT "".
DEFINE OUTPUT PARAMETER choice       AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-artic      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-prod       AS integer NO-UNDO.  /*в виде орг5 или чел182*/
DEFINE OUTPUT PARAMETER p-name       AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-engl-name  AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-unit-base  AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-VAT-code   AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-SLT-code   AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-struct     AS integer NO-UNDO.
define output parameter p-tnved      as integer no-undo .
define output parameter p-attrib     as integer no-undo .
define output parameter p-destin     as integer no-undo .
define output parameter p-sert       as integer no-undo .
define output parameter p-user-rule  as integer no-undo .
define output parameter p-alpha1     as integer no-undo .
define output parameter p-grp-code   as integer no-undo .
define output parameter p-service    as integer no-undo .
define output parameter p-gds-code   as integer no-undo .
define output parameter p-mark       as integer no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Параметры файла импорта товаров" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/usr-flt.i }
{ gbl/getcntxt.i def }

define variable  conf-par as character no-undo.                  /* для чтения параметра конфигурации */
define variable  par-type as character no-undo.
define variable v-init-dir as character no-undo .

DEFINE stream gds-file.
&SCOPED-DEFINE p-artic 1
&SCOPED-DEFINE p-name 2
&SCOPED-DEFINE p-engl-name 3
&SCOPED-DEFINE p-SLT-code 4
&SCOPED-DEFINE p-unit-base 5
&SCOPED-DEFINE p-VAT-code 6
&SCOPED-DEFINE p-struct 7
&SCOPED-DEFINE p-tnved 8
&SCOPED-DEFINE p-attrib 9
&SCOPED-DEFINE p-destin 10
&SCOPED-DEFINE p-sert 11
&SCOPED-DEFINE p-user-rule 12
&SCOPED-DEFINE p-prod 13
&SCOPED-DEFINE p-alpha1 14
&SCOPED-DEFINE p-grp-code 15
&SCOPED-DEFINE p-service 16
&SCOPED-DEFINE p-gds-code 17
&SCOPED-DEFINE p-mark 18

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-atribut B-exit b-quit B-check B-Help ~
B-file file-name RS-codir T-engl-name T-unit-base T-VAT-code T-SLT-code ~
T-struct T-tnved T-destin T-attrib T-user-rule T-sert T-prod T-grp-code T-service T-gds-code ~
T-mark text-string
&Scoped-Define DISPLAYED-OBJECTS file-name T-artic RS-codir T-name ~
T-engl-name T-unit-base T-VAT-code T-SLT-code T-struct T-tnved T-destin ~
T-attrib T-user-rule T-sert T-prod T-alpha1 T-grp-code T-service T-gds-code text-string T-mark

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-check
     LABEL "&Проверка"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл импорта"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE ii AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "Строчка N"
      VIEW-AS TEXT
     SIZE 16.25 BY .67
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE text-string AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 61 BY .67
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE RS-codir AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "1251", 1,
"KOI8-R", 2
     SIZE 15.25 BY 2.63 NO-UNDO.

DEFINE RECTANGLE RECT-atribut
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.75 BY 18.83.

DEFINE VARIABLE T-alpha1 AS LOGICAL INITIAL yes
     LABEL "Страна"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-artic AS LOGICAL INITIAL yes
     LABEL "Артикул"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
     
DEFINE VARIABLE T-grp-code AS LOGICAL INITIAL yes
     LABEL "Код группы"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
     
DEFINE VARIABLE T-service AS LOGICAL INITIAL yes
     LABEL "Услуга"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.   
     
DEFINE VARIABLE T-gds-code AS LOGICAL INITIAL yes
     LABEL "Код товара"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.   

DEFINE VARIABLE T-attrib AS LOGICAL INITIAL no
     LABEL "Характеристики товара"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-destin AS LOGICAL INITIAL no
     LABEL "Назначение товара"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-engl-name AS LOGICAL INITIAL yes
     LABEL "Англ. название"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-name AS LOGICAL INITIAL yes
     LABEL "Название"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-prod AS LOGICAL INITIAL yes
     LABEL "Произ-ль (например орг176)"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-sert AS LOGICAL INITIAL no
     LABEL "Сертификат товара"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-SLT-code AS LOGICAL INITIAL no
     LABEL "Код НП"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-struct AS LOGICAL INITIAL no
     LABEL "Состав сырья"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-tnved AS LOGICAL INITIAL no
     LABEL "Код ТНВЭД"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-unit-base AS LOGICAL INITIAL yes
     LABEL "Основная единица измерения"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-user-rule AS LOGICAL INITIAL no
     LABEL "Правила эксплуатации"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-VAT-code AS LOGICAL INITIAL yes
     LABEL "Код НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-Mark AS LOGICAL INITIAL yes
     LABEL "Тип маркировки"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-check AT ROW 1 COL 21
     B-Help AT ROW 1 COL 54.88
     B-file AT ROW 2.88 COL 43.13
     file-name AT ROW 2.92 COL 3.38
     T-artic AT ROW 5.08 COL 24.25
     RS-codir AT ROW 5.38 COL 3.38 NO-LABEL
     T-name AT ROW 6.08 COL 24.5
     T-engl-name AT ROW 7.08 COL 24.5
     T-unit-base AT ROW 8.08 COL 24.5
     T-VAT-code AT ROW 9.08 COL 24.5
     T-SLT-code AT ROW 10.08 COL 24.5
     T-struct AT ROW 11.08 COL 24.5
     T-tnved AT ROW 12.08 COL 24.5
     T-destin AT ROW 13.08 COL 24.5
     T-attrib AT ROW 14.08 COL 24.5
     T-user-rule AT ROW 15.08 COL 24.5
     T-sert AT ROW 16.08 COL 24.5
     T-prod AT ROW 17.08 COL 24.5
     T-alpha1 AT ROW 18.08 COL 24.5
     T-grp-code AT ROW 19.08 COL 24.5
     T-service AT ROW 20.08 COL 24.5
     T-gds-code AT ROW 21.08 COL 24.5
     T-Mark AT ROW 22.08 COL 24.5
     ii AT ROW 23.1 COL 2
     text-string AT ROW 24.1 COL 2.13 NO-LABEL
     "Кодировка" VIEW-AS TEXT
          SIZE 15.75 BY .92 AT ROW 4.21 COL 3.38
     "Импортируемые поля" VIEW-AS TEXT
          SIZE 19.25 BY .88 AT ROW 4 COL 26.25
          FGCOLOR 3
     RECT-atribut AT ROW 4.42 COL 21.13
     SPACE(2.24) SKIP(3.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры файла импорта"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN file-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ii IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       ii:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-artic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN text-string IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры файла импорта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-check
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-check Dialog-Frame
ON CHOOSE OF B-check IN FRAME Dialog-Frame /* Проверка */
DO:
  define variable NEN as integer No-UNDO.
  define variable p-text as char no-undo.
  define variable p-int as integer no-undo.
  define variable vars as integer no-undo EXTENT 18.
  define variable lok as logical no-undo.
  define buffer buf_country for ub.country.
  define buffer buf_gds-grp for ub.gds-grp .
  
  assign
  file-name
  v_os-file = file-name
  RS-codir
  choice = RS-codir
  T-artic
  t-prod
  T-engl-name
  T-name
  T-SLT-code
  T-unit-base
  T-VAT-code
  T-struct
  T-tnved
  T-attrib
  T-destin
  T-sert
  T-user-rule
  T-alpha1
  T-grp-code
  T-service
  T-gds-code
  T-Mark
  NEN = NEN + integer(T-artic)
  vars[{&p-artic}] = NEN
  p-artic = vars[{&p-artic}]
  NEN = NEN + integer(T-name)
  vars[{&p-name}] = if T-name then NEN else 0
  p-name = vars[{&p-name}]
  NEN = NEN + integer(T-engl-name)
  vars[{&p-engl-name}] = if T-engl-name then NEN else 0
  p-engl-name = vars[{&p-engl-name}]
  NEN = NEN + integer(T-unit-base)
  vars[{&p-unit-base}] = if T-unit-base then NEN else 0
  p-unit-base = vars[{&p-unit-base}]
  NEN = NEN + integer(T-VAT-code)
  vars[{&p-VAT-code}] = if T-VAT-code then NEN else 0
  p-VAT-code = vars[{&p-VAT-code}]
  NEN = NEN + integer(T-SLT-code)
  vars[{&p-SLT-code}] = if T-SLT-code then NEN else 0
  p-SLT-code = vars[{&p-SLT-code}]
  NEN = NEN + integer(T-Struct)
    vars[{&p-struct}] = if T-struct then NEN else 0
    p-struct = vars[{&p-struct}]
  NEN = NEN + integer(T-Tnved)
    vars[{&p-tnved}] = if T-tnved then NEN else 0
    p-tnved = vars[{&p-tnved}]
  NEN = NEN + integer(T-destin)
    vars[{&p-destin}] = if T-destin then NEN else 0
    p-destin = vars[{&p-destin}]
  NEN = NEN + integer(T-attrib)
    vars[{&p-attrib}] = if T-attrib then NEN else 0
    p-attrib = vars[{&p-attrib}]
  NEN = NEN + integer(T-user-rule)
    vars[{&p-user-rule}] = if T-user-rule then NEN else 0
    p-user-rule = vars[{&p-user-rule}]
  NEN = NEN + integer(T-sert)
    vars[{&p-sert}] = if T-sert then NEN else 0
    p-sert = vars[{&p-sert}]
  NEN = NEN + integer(T-prod)
  vars[{&p-prod}] = if T-prod then NEN else 0
  p-prod = vars[{&p-prod}]
  NEN = NEN + integer(T-alpha1)
    vars[{&p-alpha1}] = if T-alpha1 then NEN else 0
    p-alpha1 = vars[{&p-alpha1}]
   NEN = NEN + integer(T-grp-code)
    vars[{&p-grp-code}] = if T-grp-code then NEN else 0
    p-grp-code = vars[{&p-grp-code}]
   NEN = NEN + integer(T-service)
    vars[{&p-service}] = if T-service then NEN else 0
    p-service = vars[{&p-service}]
   NEN = NEN + integer(T-gds-code)
    vars[{&p-gds-code}] = if T-gds-code then NEN else 0
    p-gds-code = vars[{&p-gds-code}]
 NEN = NEN + integer(T-mark)
    vars[{&p-mark}] = if T-mark then NEN else 0
    p-mark = vars[{&p-mark}]
  
  .
  IF v_os-file = "" or v_os-file = ? then do:
    message "Не определен файл импорта!" view-as alert-box ERROR.
    return no-apply.
  END.
  if substring(v_os-file, length(v_os-file) - 2) = "xls"
  or substring(v_os-file, length(v_os-file) - 3) = "xlsx"
  then do :
      message "Для файлов Excel проверка не возможна" view-as alert-box.
      return no-apply .
  end.
  IF (T-SLT-code OR T-VAt-code) AND NOT T-unit-base then do:
    message "Невозможно импортировать код НДС и/или код НП" SKIP
            "без импорта основной единицы измерения" view-as alert-box ERROR.
    return no-apply.
  end.

  CASE choice:
        WHEN 1 then do:
            input stream gds-file from value (v_os-file) convert source "1251".
        END.
        WHEN 2 then do:
            input stream gds-file from value (v_os-file) convert source "KOI8-R".
        END.
  END CASE.
  ii = 0.
  VIEW
  ii
  IN FRAME {&frame-name}.
  _stroka:
    REPEAT:
    IMPORT stream gds-file UNFORMATTED text-string NO-ERROR.
    ii = ii + 1.
    DISPLAY
    text-string
    ii
    WITH frame {&frame-name}.
    if NUm-ENTRIES(text-string, ";") <> NEN then do:
        message "В строчке N " ii "неверное кол-во полей - " NUm-ENTRIES(text-string, ";") skip
            "должно быть" NEN
        view-as alert-box ERROR
        buttons OK-Cancel update lok
        .
        if NOT lok then return no-apply.
        else NEXT _stroka.
    end.
    if vars[{&p-unit-base}] > 0 then do:
        FIND FIRST ub.units NO-LOCK where
                   ub.units.unit-name = ENTRY(vars[{&p-unit-base}], text-string, ";")
                   No-ERROR.
        IF NOT avail ub.units then do:
            message "Нет в БД единицы измерения "
                    ENTRY(vars[{&p-unit-base}], text-string, ";") skip
                    " - поле N " vars[{&p-unit-base}]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.
        END.
    end.
    if vars[{&p-SLT-code}] > 0 then do:
        assign
        p-int = integer(ENTRY(vars[{&p-SLT-code}], text-string, ";"))
        no-error.
        if error-status:error then do:
            message "Неверное значение кода ставки НП "
                    ENTRY(vars[{&p-SLT-code}], text-string, ";") skip
                    " - поле N " vars[{&p-SLT-code}]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.

        end.
        else do:
            FIND FIRST ub.tax-rate NO-LOCK where
                       ub.tax-rate.rate-code = p-int
                       No-ERROR.
            IF NOT avail ub.tax-rate then do:
                message "Нет в БД ставки налога с кодом "
                        ENTRY(vars[{&p-SLT-code}], text-string, ";") skip
                        " - поле N " vars[{&p-SLT-code}]
                        "   строчка N " ii
                view-as alert-box ERROR
                buttons OK-Cancel update lok
                .
                if NOT lok then return no-apply.

            END.
            ELSE DO:
                if tax-rate.tax-code <> slttaxcd then do:
                    message "Для ставки налога с кодом "
                            ENTRY(vars[{&p-SLT-code}], text-string, ";")
                            "код налога отличается от кода НП" skip
                            " - поле N " vars[{&p-SLT-code}]
                            "   строчка N " ii
                    view-as alert-box ERROR
                    buttons OK-Cancel update lok
                    .
                    if NOT lok then return no-apply.
                end.
            END.

        end.
    end. /*if vars[{&p-SLT-code}] > 0 */
    if vars[{&p-vat-code}] > 0 then do:
        assign
        p-int = integer(ENTRY(vars[{&p-vat-code}], text-string, ";"))
        no-error.
        if error-status:error then do:
            message "Неверное значение кода ставки НДС "
                    ENTRY(vars[{&p-vat-code}], text-string, ";") skip
                    " - поле N " vars[{&p-vat-code}]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.
        end.
        else do:
            FIND FIRST tax-rate NO-LOCK where
                       tax-rate.rate-code = p-int
                       No-ERROR.
            IF NOT avail tax-rate then do:
                message "Нет в БД ставки налога с кодом "
                        ENTRY(vars[{&p-vat-code}], text-string, ";") skip
                        " - поле N " vars[{&p-vat-code}]
                        "   строчка N " ii
                view-as alert-box ERROR
                buttons OK-Cancel update lok
                .
                if NOT lok then return no-apply.
            END.
            ELSE DO:
                if tax-rate.tax-code <> vattaxcd then do:
                    message "Для ставки налога с кодом "
                            ENTRY(vars[{&p-vat-code}], text-string, ";")
                            "код налога отличается от кода НДС" skip
                            " - поле N " vars[{&p-vat-code}]
                            "   строчка N " ii
                    view-as alert-box ERROR
                    buttons OK-Cancel update lok
                    .
                    if NOT lok then return no-apply.
                end.
            END.

        end.
    end. /*if vars[{&p-vat-code}] > 0 */
    if vars[{&p-alpha1}] > 0 then do:
        FIND FIRST buf_country NO-LOCK where
                   buf_country.alpha1 = ENTRY(vars[{&p-alpha1}], text-string, ";")
                   No-ERROR.
        IF NOT avail buf_country then do:
            message "Нет в БД страны "
                    ENTRY(vars[{&p-alpha1}], text-string, ";") skip
                    " - поле N " vars[{&p-alpha1}]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.
        END.
    end.
    if vars[{&p-grp-code}] > 0 then do:
        FIND FIRST buf_gds-grp NO-LOCK where
                   buf_gds-grp.node-code = integer(ENTRY(vars[{&p-grp-code}], text-string, ";"))
                   No-ERROR.
        IF NOT avail buf_gds-grp then do:
            message "Нет в БД группы товаров с вн. номером "
                    ENTRY(vars[{&p-grp-code}], text-string, ";") skip
                    " - поле N " vars[{&p-grp-code}]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.
        END.
    end.

  END.
  HIDE
  ii
  text-string
  IN FRAME {&frame-name}.
  input stream gds-file close.
  message "Проверка завершена" view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  define variable NEN as integer No-UNDO.
  define variable vars as integer no-undo EXTENT 18.
  assign
  file-name
  v_os-file = file-name
  RS-codir
  choice = RS-codir
  T-artic
  T-prod
  T-engl-name
  T-name
  T-SLT-code
  T-unit-base
  T-VAT-code
  T-struct
  T-tnved
  T-attrib
  T-destin
  T-sert
  T-user-rule
  T-alpha1
  T-grp-code
  T-service
  T-gds-code
  T-mark
  NEN = NEN + integer(T-artic)
  vars[{&p-artic}] = NEN
  p-artic = vars[{&p-artic}]
  NEN = NEN + integer(T-name)
  vars[{&p-name}] = if T-name then NEN else 0
  p-name = vars[{&p-name}]
  NEN = NEN + integer(T-engl-name)
  vars[{&p-engl-name}] = if T-engl-name then NEN else 0
  p-engl-name = vars[{&p-engl-name}]
  NEN = NEN + integer(T-unit-base)
  vars[{&p-unit-base}] = if T-unit-base then NEN else 0
  p-unit-base = vars[{&p-unit-base}]
  NEN = NEN + integer(T-VAT-code)
  vars[{&p-VAT-code}] = if T-VAT-code then NEN else 0
  p-VAT-code = vars[{&p-VAT-code}]
  NEN = NEN + integer(T-SLT-code)
  vars[{&p-SLT-code}] = if T-SLT-code then NEN else 0
  p-SLT-code = vars[{&p-SLT-code}]
  NEN = NEN + integer(T-Struct)
  vars[{&p-Struct}] = if T-Struct then NEN else 0
  p-Struct = vars[{&p-Struct}]
  NEN = NEN + integer(T-tnved)
  vars[{&p-tnved}] = if T-tnved then NEN else 0
  p-tnved = vars[{&p-tnved}]

  NEN = NEN + integer(T-destin)
  vars[{&p-destin}] = if T-destin then NEN else 0
  p-destin = vars[{&p-destin}]
  NEN = NEN + integer(T-attrib)
  vars[{&p-attrib}] = if T-attrib then NEN else 0
  p-attrib = vars[{&p-attrib}]
  NEN = NEN + integer(T-user-rule)
  vars[{&p-user-rule}] = if T-user-rule then NEN else 0
  p-user-rule = vars[{&p-user-rule}]
  NEN = NEN + integer(T-sert)
  vars[{&p-sert}] = if T-sert then NEN else 0
  p-sert = vars[{&p-sert}]
  NEN = NEN + integer(T-prod)
  vars[{&p-prod}] = if T-prod then NEN else 0
  p-prod = vars[{&p-prod}]
  NEN = NEN + integer(T-alpha1)
  vars[{&p-alpha1}] = if T-alpha1 then NEN else 0
  p-alpha1 = vars[{&p-alpha1}]
  NEN = NEN + integer(T-grp-code)
  vars[{&p-grp-code}] = if T-grp-code then NEN else 0
  p-grp-code = vars[{&p-grp-code}]
  NEN = NEN + integer(T-service)
  vars[{&p-service}] = if T-service then NEN else 0
  p-service = vars[{&p-service}]
  NEN = NEN + integer(T-gds-code)
  vars[{&p-gds-code}] = if T-gds-code then NEN else 0
  p-gds-code = vars[{&p-gds-code}]
 NEN = NEN + integer(T-mark)
    vars[{&p-mark}] = if T-mark then NEN else 0
    p-mark = vars[{&p-mark}]
  .
  if vars[{&p-gds-code}] eq 0
     and  vars[{&p-prod}] eq 0
  then do:
      message
      "В загрузке обязательно должен быть код товара или производитель."
      view-as alert-box WARNING.
      return no-apply.
  end.
  if p-tnved > 0 then do:
    if custvalue = "no"  then do:
      message
      "В Вашей системе не включен настроечный параметр ТАМОЖНЯ," skip
      "поэтому проверить корректность импортируемых кодов ТНВЭД будет невозможно"
      view-as alert-box WARNING.
    end.
  end.
  IF v_os-file = "" or v_os-file = ? then do:
    message "Не определен файл импорта!" view-as alert-box ERROR.
    return no-apply.
  END.
  IF (T-SLT-code OR T-VAt-code) AND NOT T-unit-base then do:
    message "Невозможно импортировать код НДС и/или код НП" SKIP
            "без импорта основной единицы измерения" view-as alert-box ERROR.
    return no-apply.
  end.

  CASE choice:
        WHEN 1 then do:
            input stream gds-file from value (v_os-file) convert source "1251".
        END.
        WHEN 2 then do:
            input stream gds-file from value (v_os-file) convert source "KOI8-R".
        END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:

define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .


    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
        FILTERS
          " Текстовые файлы (*.gim) " "*.gim",
          " Текстовые файлы (*.txt) " "*.txt",
          " Текстовые файлы (*.csv) " "*.csv",
          " MS Excel (*.xls,*.xlsx) " "*.xls,*.xlsx",
          " Все файлы (*.*) "                      "*.*"
        INITIAL-DIR v-init-dir
        /*return-to-start-dir*/
        must-exist
        update ll_commit
        default-extension "gim"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name WITH FRAME {&FRAME-NAME}.
  run gbl/filename.p (
                          input  file-name
                          ,output v-full-path
                          ,output v-path
                          ,output v-file-name
                          ,output v-file-name-no-ext
                          ,output v-file-name-ext
                          ) no-error .
  if not error-status:error then v-init-dir = v-path.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отказ */
DO:
    assign v_os-file = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл импорта */
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
/*велючен ли параметр импорта ТНВЭД*/
 run fill-by-usr-flt in this-procedure  no-error .
 RUN enable_UI.
 if not tnvedimp and custvalue <> "yes" then do:
    assign
    t-tnved = no.
    disable
    T-tnved
    with frame {&frame-name} .
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  assign
  v-uf-list_ =
               string(T-artic)       + {&delim-par} +
               string(T-name)        + {&delim-par} +
               string(t-engl-name )  + {&delim-par} +
               string(t-unit-base)   + {&delim-par} +
               string(t-VAT-code)    + {&delim-par} +
               string(t-SLT-code)    + {&delim-par} +
               string(t-struct)      + {&delim-par} +
               string(t-tnved)       + {&delim-par} +
               string(t-attrib)      + {&delim-par} +
               string(t-destin)      + {&delim-par} +
               string(t-sert)        + {&delim-par} +
               string(t-user-rule)   + {&delim-par} +
               string(t-prod)        + {&delim-par} +
               string(t-alpha1)      + {&delim-par} +
               string(t-grp-code)    + {&delim-par} +
               string(t-service)     + {&delim-par} +
               string(t-gds-code)    + {&delim-par} +
               string(t-mark)
  v-uf-Naim  = v-init-dir
 .
  run uf-set in this-procedure(
    input  {&uf-imp-goods}
    ,input v-cntxt-userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .

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
  DISPLAY file-name T-artic RS-codir T-name T-engl-name T-unit-base T-VAT-code
          T-SLT-code T-struct T-tnved T-destin T-attrib T-user-rule T-sert
          T-prod T-alpha1 T-grp-code T-service T-gds-code t-mark text-string
      WITH FRAME Dialog-Frame.
  if iOnlyfile
  then
     ENABLE RECT-atribut B-exit b-quit B-check B-Help B-file file-name RS-codir
         
      WITH FRAME Dialog-Frame.
  else
     ENABLE RECT-atribut B-exit b-quit B-check B-Help B-file file-name RS-codir
         T-engl-name T-unit-base T-VAT-code T-SLT-code T-struct T-tnved
         T-destin T-attrib T-user-rule T-sert T-prod T-grp-code T-service T-gds-code t-mark text-string
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-by-usr-flt Dialog-Frame
PROCEDURE fill-by-usr-flt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run uf-get in this-procedure(
     input  {&uf-imp-goods}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
  if num-entries(v-uf-List_, {&delim-par}) >= 12 then
  assign
  T-artic       =  logical(entry({&p-artic}     ,      v-uf-list_, {&delim-par}))
  T-name        =  logical(entry({&p-name}      ,      v-uf-list_, {&delim-par}))
  t-engl-name   =  logical(entry({&p-engl-name} ,      v-uf-list_, {&delim-par}))
  t-unit-base   =  logical(entry({&p-SLT-code}  ,      v-uf-list_, {&delim-par}))
  t-VAT-code    =  logical(entry({&p-unit-base} ,      v-uf-list_, {&delim-par}))
  t-SLT-code    =  logical(entry({&p-VAT-code}  ,      v-uf-list_, {&delim-par}))
  t-struct      =  logical(entry({&p-struct}    ,      v-uf-list_, {&delim-par}))
  t-tnved       =  logical(entry({&p-tnved}     ,      v-uf-list_, {&delim-par}))
  t-attrib      =  logical(entry({&p-attrib}    ,      v-uf-list_, {&delim-par}))
  t-destin      =  logical(entry({&p-destin}    ,      v-uf-list_, {&delim-par}))
  t-sert        =  logical(entry({&p-sert}      ,      v-uf-list_, {&delim-par}))
  t-user-rule   =  logical(entry({&p-user-rule} ,      v-uf-list_, {&delim-par}))
  no-error.
  if num-entries(v-uf-List_, {&delim-par}) >= 13 then
  assign
  T-prod       =  logical(entry({&p-prod}     ,      v-uf-list_, {&delim-par}))
  no-error
  .
  if num-entries(v-uf-List_, {&delim-par}) >= 14 then
  assign
  T-alpha1       =  logical(entry({&p-alpha1}     ,      v-uf-list_, {&delim-par}))
  no-error
  .
  if num-entries(v-uf-List_, {&delim-par}) >= 15 then
  assign
  T-grp-code     =  logical(entry({&p-grp-code}     ,      v-uf-list_, {&delim-par}))
  no-error
  .
  if num-entries(v-uf-List_, {&delim-par}) >= 16 then
  assign
  T-service     =  logical(entry({&p-service}     ,      v-uf-list_, {&delim-par}))
  no-error
  .
  if num-entries(v-uf-List_, {&delim-par}) >= 17 then
  assign
  T-gds-code     =  logical(entry({&p-gds-code}     ,      v-uf-list_, {&delim-par}))
  no-error
  .
  if num-entries(v-uf-List_, {&delim-par}) >= 18 then
  assign
  T-mark     =  logical(entry({&p-mark}     ,      v-uf-list_, {&delim-par}))
  no-error
  .

  assign
  file-info:file-name = v-uf-naim
  .
  assign
  v-init-dir   = ( if file-info:file-type <> ?
                   and index( file-info:file-type, "D":U ) <> 0
                   then v-uf-naim
                   else ".")
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME