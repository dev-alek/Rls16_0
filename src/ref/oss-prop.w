/*

26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА

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

Справочник Операторов Сотовой Связи. Диалоговое окно.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc as widget-handle no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-db-num as integer no-undo.
define input-output parameter p-io-rowid as rowid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Свойства платежа Оператору сотовой связи".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ ref/gds-attr.i }
{ ref/ossprpdf.i }
{ ref/extclass.i }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getcntxt.i get }
define variable rid-list as character no-undo.
define variable v-gds-code as integer.

define buffer buf_ext-classif for ext-classif.
/*define buffer buf_sum-grp for sum-grp.*/
define buffer buf_goods for goods.
define temp-table tt-oss-ref no-undo

    /* Ключевые поля */
    field oper-code as integer          /* Uniq for table: ext-classif. Первое и уникальное (из трёх) ключевое поле справочника ОСС в таблице ext-classif */
    field oper-abbrev as character      /* Второе (из трёх) ключевое поле справочника ОСС в таблице ext-classif */
    field gds-group-in-cass as integer  /* Третье (из трёх) ключевое поле справочника ОСС в таблице ext-classif */

    /* Параметры из таблицы ext-classif, уложенные в одно поле CharKey_Two */
    field oper-name as character        /* 1. Название Оператора Связи */
    field min-digit-nums as integer     /* 2. Минимальное кол-во цифр для ввода номера сотового телефона */
    field max-digit-nums as integer     /* 3. Максимальное кол-во цифр для ввода номера сотового телефона */
    field min-sum as decimal            /* 4. Минимальная сумма начисления */
    field max-sum as decimal            /* 5. Максимальная сумма начисления */
    field warning-lim-sum as decimal    /* 6. Порог суммы для выдачи предупреждения */
    field type-comission as integer     /* 7. Типы ввода комиссии (цифры от 0 до 3) */
    field comission-pcnt as decimal     /* 8. % комиссии */
    field comission-sum as decimal      /* 9. Сумма комиссии */
    field necessary-authorization as logical /* 10. Авторизация неохбодима */
    field necessary-slip as logical     /* 11. Печать слипа необходима */
    field slip-file as character        /* 12. Имя файла образа конечного слипа */
    field billing-type as integer       /* 13. Тип расчёта с оператором */

    /* Параметры из др. таблиц дополнительно */
    field db-num as integer
    field classif-subject as character  /* Сущность */
    field classif-name as character     /* Классификатор */

    index pi as primary unique oper-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS f-name-gds-grp B-exit b-quit B-Help ~
f-gds-group-in-cass b-grp-gds f-oper-code f-oper-name f-oper-abbrev ~
f-min-digit-nums f-max-digit-nums f-min-sum f-max-sum f-warning-lim-sum ~
Rs-type-comission f-comission-pcnt f-comission-sum ~
t-necessary-authorization t-necessary-slip f-slip-file Rs-billing-type ~
RECT-1 RECT-2 
&Scoped-Define DISPLAYED-OBJECTS f-name-gds-grp f-gds-group-in-cass ~
f-oper-code f-oper-name f-oper-abbrev f-min-digit-nums f-max-digit-nums ~
f-min-sum f-max-sum f-warning-lim-sum Rs-type-comission f-comission-pcnt ~
f-comission-sum t-necessary-authorization t-necessary-slip f-slip-file ~
Rs-billing-type 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-grp-gds 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .71.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-comission-pcnt AS DECIMAL FORMAT ">9.99":U INITIAL 0 
     LABEL "% комиссии" 
     VIEW-AS FILL-IN 
     SIZE 13.25 BY 1 NO-UNDO.

DEFINE VARIABLE f-comission-sum AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Сумма комиссии" 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-gds-group-in-cass AS INTEGER FORMAT "->>>>>>>>>9":U INITIAL 0 
     LABEL "Код товара на кассе " 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-max-digit-nums AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "Максимальное кол-во цифр для ввода номера " 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 TOOLTIP "Максимальное кол-во цифр для ввода номера телефона или счета" NO-UNDO.

DEFINE VARIABLE f-max-sum AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Максимальная сумма начисления " 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 TOOLTIP "в национальной валюте" NO-UNDO.

DEFINE VARIABLE f-min-digit-nums AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "Минимальное кол-во цифр для ввода номера " 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 TOOLTIP "Минимальное кол-во цифр для ввода номера телефона или счета" NO-UNDO.

DEFINE VARIABLE f-min-sum AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Минимальная сумма начисления " 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 TOOLTIP "В национальной валюте" NO-UNDO.

DEFINE VARIABLE f-name-gds-grp AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 29 BY .96 NO-UNDO.

DEFINE VARIABLE f-oper-abbrev AS CHARACTER FORMAT "X(50)":U 
     LABEL "Аббревиатура Оператора пополнения счета" 
     VIEW-AS FILL-IN 
     SIZE 47.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-oper-code AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Код Оператора пополнения счета" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 TOOLTIP "Присваивается Системой приема платежей" NO-UNDO.

DEFINE VARIABLE f-oper-name AS CHARACTER FORMAT "X(50)":U 
     LABEL "Название Оператора Связи           " 
     VIEW-AS FILL-IN 
     SIZE 47.63 BY 1 TOOLTIP "Для печати на слипе" NO-UNDO.

DEFINE VARIABLE f-slip-file AS CHARACTER FORMAT "X(19)":U 
     LABEL "Имя файла образа конечного слипа " 
     VIEW-AS FILL-IN 
     SIZE 46.38 BY 1 NO-UNDO.

DEFINE VARIABLE f-warning-lim-sum AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Порог суммы для выдачи предупреждения " 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 TOOLTIP "в национальной валюте" NO-UNDO.

DEFINE VARIABLE Rs-billing-type AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Оплата Сотовой Связи", 1,
"Оплата по договору", 2,
"Оплата Счёта", 3,
"Начисление на карту", 4
     SIZE 39.38 BY 3.38 NO-UNDO.

DEFINE VARIABLE Rs-type-comission AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Без комиссии", 0,
"Расчёт по % комиссии от вводимой суммы", 1,
"Расчёт по % комиссии от суммы начисления", 2,
"Расчёт по сумме комиссии от вводимой суммы", 3
     SIZE 56.25 BY 4.5 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 5.13.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 87.88 BY 4.04.

DEFINE VARIABLE t-necessary-authorization AS LOGICAL INITIAL no 
     LABEL "Авторизация необходима" 
     VIEW-AS TOGGLE-BOX
     SIZE 30.38 BY 1.08 NO-UNDO.

DEFINE VARIABLE t-necessary-slip AS LOGICAL INITIAL no 
     LABEL "Печать слипа необходима" 
     VIEW-AS TOGGLE-BOX
     SIZE 30.38 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     f-name-gds-grp AT ROW 2.5 COL 57 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.75
     f-gds-group-in-cass AT ROW 2.5 COL 39 COLON-ALIGNED WIDGET-ID 2
     b-grp-gds AT ROW 2.67 COL 55 WIDGET-ID 12
     f-oper-code AT ROW 3.63 COL 39 COLON-ALIGNED
     f-oper-name AT ROW 4.71 COL 39 COLON-ALIGNED
     f-oper-abbrev AT ROW 5.79 COL 40 COLON-ALIGNED WIDGET-ID 10
     f-min-digit-nums AT ROW 6.92 COL 50.38 COLON-ALIGNED
     f-max-digit-nums AT ROW 8 COL 50.38 COLON-ALIGNED
     f-min-sum AT ROW 9.08 COL 50.38 COLON-ALIGNED
     f-max-sum AT ROW 10.21 COL 50.38 COLON-ALIGNED
     f-warning-lim-sum AT ROW 11.29 COL 50.38 COLON-ALIGNED
     Rs-type-comission AT ROW 13.58 COL 4.63 NO-LABEL
     f-comission-pcnt AT ROW 15.92 COL 73 COLON-ALIGNED
     f-comission-sum AT ROW 17 COL 73 COLON-ALIGNED
     t-necessary-authorization AT ROW 19 COL 4.63
     t-necessary-slip AT ROW 20.08 COL 4.63
     f-slip-file AT ROW 21.21 COL 39.63 COLON-ALIGNED
     Rs-billing-type AT ROW 23.5 COL 4.63 NO-LABEL
     "Тип ввода используемой комиссии" VIEW-AS TEXT
          SIZE 31.38 BY .96 AT ROW 12.79 COL 32.63 WIDGET-ID 6
     "Тип расчета с Оператором пополнения счетов" VIEW-AS TEXT
          SIZE 31 BY .79 AT ROW 22.67 COL 33.75
     RECT-1 AT ROW 13.29 COL 2.63 WIDGET-ID 4
     RECT-2 AT ROW 23.13 COL 2.63 WIDGET-ID 8
     SPACE(1.28) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки платежа оператора пополнения счетов"
         CANCEL-BUTTON b-quit.


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
   FRAME-NAME Custom                                                    */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки платежа оператора пополнения счетов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
 define variable flag-oss as logical init no.
 
    find first  goods-attr where goods-attr.gds-code = v-gds-code and goods-attr.attr-value = 'oss-pay' 
    AND goods-attr.attr-code = {&attr-office-type}  no-lock no-error.
    
            
/*    if goods-attr.attr-value = 'oss-pay'                   */
/*    AND goods-attr.attr-code = {&attr-office-type} then do:*/
   
    run proc-chck-min-max-fields-all-widgets2 no-error.
    if error-status:error then return no-apply.
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    /*
        if available goods-attr then do: 
/*    flag-oss = yes.*/
    end.
/*    if flag-oss = no then do:*/
else do: 
    
        message "У данной услуги нет типа услуги oss-pay" view-as alert-box error.
    
    end.
/*    end.*/
/*    else do:                                                                      */
/*        message "У данной услуги нет типа услуги oss-pay" view-as alert-box error.*/
/*                                                                                  */
/*        end.                                                                      */
*/
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-grp-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-grp-gds Dialog-Frame
ON CHOOSE OF b-grp-gds IN FRAME Dialog-Frame
DO:

     define variable ri-list         as char no-undo .

  run ref/gds-ref.p   (  parparentproc
      ,'b-sel'
      ,?             /*p-stat */
      ,?             /*p-list  */
      ,?             /*p-cond  */
      ,?             /*p-rec   */
      ,?             /*p-grp   */
      ,?             /*p-cli-type */
      ,?             /*p-cli-code  */
      ,v-cntxt-obj-type    /*p-obj-type  */
      ,v-cntxt-obj-code     /*p-obj-code  */
      ,?             /*p-other     */
      , output ri-list) .




   find first buf_goods where recid(buf_goods) = integer (ri-list) no-lock no-error.
        if available buf_goods then
            do:

                f-gds-group-in-cass:screen-value = string(buf_goods.gds-code).
                f-name-gds-grp:screen-value = buf_goods.gds-name.
          v-gds-code = buf_goods.gds-code.
            end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-gds-group-in-cass
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-gds-group-in-cass Dialog-Frame
ON LEAVE OF f-gds-group-in-cass IN FRAME Dialog-Frame /* Код товара на кассе  */
DO:
    assign f-gds-group-in-cass.
    find first buf_goods where buf_goods.gds-code = f-gds-group-in-cass no-lock no-error.
        if available buf_goods then
            do:
                f-name-gds-grp:screen-value = string(buf_goods.gds-name).
            end.
        else
            do:
                f-name-gds-grp:screen-value = "".
            end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-type-comission
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-type-comission Dialog-Frame
ON VALUE-CHANGED OF Rs-type-comission IN FRAME Dialog-Frame
DO:
    ASSIGN
        rs-type-comission.
    case rs-type-comission:
    when 0 then do:
        assign
            f-comission-pcnt = 0
            f-comission-sum = 0
        .
        display
            f-comission-pcnt
            f-comission-sum
        with frame {&FRAME-NAME}.
        disable
            f-comission-pcnt
            f-comission-sum
        with frame {&FRAME-NAME}.
        hide
            f-comission-pcnt
            f-comission-sum
        in frame {&frame-name}.
    end.
    when 1 then do:
        assign
            f-comission-pcnt
            f-comission-sum = 0
        .
        display
            f-comission-pcnt
            f-comission-sum
        with frame {&FRAME-NAME}.
        disable
            f-comission-pcnt
            f-comission-sum
        with frame {&FRAME-NAME}.
        enable
            f-comission-pcnt
        with frame {&FRAME-NAME}.
        hide
            f-comission-sum
        in frame {&frame-name}.
    end.
    when 2 then do:
        assign
            f-comission-pcnt
            f-comission-sum = 0
        .
        display
            f-comission-pcnt
            f-comission-sum
        with frame {&FRAME-NAME}.
        disable
            f-comission-pcnt
            f-comission-sum
        with frame {&FRAME-NAME}.
        enable
            f-comission-pcnt
        with frame {&FRAME-NAME}.
        hide
            f-comission-sum
        in frame {&frame-name}.
    end.
    when 3 then do:
        assign
            f-comission-pcnt = 0
            f-comission-sum
        .
        display
            f-comission-pcnt
            f-comission-sum
        with frame {&FRAME-NAME}.
        disable
            f-comission-pcnt
            f-comission-sum
        with frame {&FRAME-NAME}.
        enable
            f-comission-sum
        with frame {&FRAME-NAME}.
        hide
            f-comission-pcnt
        in frame {&frame-name}.
    end.

  end CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-necessary-slip
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-necessary-slip Dialog-Frame
ON VALUE-CHANGED OF t-necessary-slip IN FRAME Dialog-Frame /* Печать слипа необходима */
DO:
    assign
        t-necessary-slip
    .
    if t-necessary-slip then
        do:
            enable
                f-slip-file
            with frame {&FRAME-NAME}.
        end.
    else
        do:
            assign
                f-slip-file = '':U
            .
            display
                f-slip-file
            with frame {&FRAME-NAME}.
            disable
                f-slip-file
            with frame {&FRAME-NAME}.
        end.
end.

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
  RUN fill-tt-oss-ref IN THIS-PROCEDURE.
  RUN MyEnable IN THIS-PROCEDURE.
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
  DISPLAY f-name-gds-grp f-gds-group-in-cass f-oper-code f-oper-name 
          f-oper-abbrev f-min-digit-nums f-max-digit-nums f-min-sum f-max-sum 
          f-warning-lim-sum Rs-type-comission f-comission-pcnt f-comission-sum 
          t-necessary-authorization t-necessary-slip f-slip-file Rs-billing-type 
      WITH FRAME Dialog-Frame.
  ENABLE f-name-gds-grp B-exit b-quit B-Help f-gds-group-in-cass b-grp-gds 
         f-oper-code f-oper-name f-oper-abbrev f-min-digit-nums 
         f-max-digit-nums f-min-sum f-max-sum f-warning-lim-sum 
         Rs-type-comission f-comission-pcnt f-comission-sum 
         t-necessary-authorization t-necessary-slip f-slip-file Rs-billing-type 
         RECT-1 RECT-2 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt-oss-ref Dialog-Frame 
PROCEDURE fill-tt-oss-ref :
define variable v-ii as integer no-undo.
define variable v-i-cnt as integer initial 0 no-undo.
define variable v-value as character no-undo.
define variable v-list as character no-undo.

    for each buf_ext-classif where buf_ext-classif.classif-subject = {&extclass_oss-ref} no-lock:
            create tt-oss-ref.
            assign
                tt-oss-ref.oper-code = buf_ext-classif.Key#_One
/*                tt-oss-ref.oper-code = string(buf_ext-classif.uniq-key-rec)*/
                tt-oss-ref.oper-abbrev = buf_ext-classif.CharKey_One
                tt-oss-ref.gds-group-in-cass = integer(buf_ext-classif.Key#_Two)
                tt-oss-ref.db-num = p-db-num
                tt-oss-ref.classif-subject = buf_ext-classif.classif-subject /* Сущность */
                tt-oss-ref.classif-name = buf_ext-classif.classif-name /* Классификатор */
                v-list = buf_ext-classif.CharKey_Two
            .

            do v-ii = 1 to 13: /* Линейно распаковываем аттрибуты Оператора Сотовой Связи во временную таблицу. Последовательность - см выше, в обявлении временной таблицы tt-oss-ref */
                do:
                    v-value = trim(string(entry(v-ii, v-list, {&delim-par}))).
                    case v-ii:
                        when 1 then tt-oss-ref.oper-name = v-value.
                        when 2 then tt-oss-ref.min-digit-nums = integer(v-value).
                        when 3 then tt-oss-ref.max-digit-nums = integer(v-value).
                        when 4 then tt-oss-ref.min-sum = decimal(v-value).
                        when 5 then tt-oss-ref.max-sum = decimal(v-value).
                        when 6 then tt-oss-ref.warning-lim-sum = decimal(v-value).
                        when 7 then tt-oss-ref.type-comission = integer(v-value).
                        when 8 then tt-oss-ref.comission-pcnt = decimal(v-value).
                        when 9 then tt-oss-ref.comission-sum = decimal(v-value).
                        when 10 then tt-oss-ref.necessary-authorization = logical(v-value).
                        when 11 then tt-oss-ref.necessary-slip = logical(v-value).
                        when 12 then tt-oss-ref.slip-file = v-value.
                        when 13 then tt-oss-ref.billing-type = integer(v-value).
                    end case.
                end.
            end. /* do v-ii = 1 to 13: */
    end. /* for each buf_ext-classif */
    {&OPEN-QUERY-br-oss}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
if Lookup(p-mode, {&add-def} + "," + {&Lookup} + "," +  {&update}) = 0 then return error.

    define variable v-value as character no-undo.
    define variable v-list as character no-undo.
    define variable v-ii as integer no-undo.    

    if p-mode = {&update} or p-mode = {&Lookup} then                        /* Режим "Изменение сущ. данных" */
        do: /* a */
            
            find first buf_ext-classif where rowid (buf_ext-classif) = p-io-rowid.  /* Проверка: ext-classif не пустая табл? */
            if available buf_ext-classif then                               /* Проверка: ext-classif не пустая табл? */
                do: /* b */
                    find first buf_goods where buf_goods.gds-code = buf_ext-classif.Key#_Two no-lock no-error. /* Прилепим "на лету" в интерфейсе расшифровку к имени группы товаров, т.к. оно не хранится в нашем справочнике, но думаю, будет полезным. */
                        if available buf_goods then
                            do:
                                f-name-gds-grp = buf_goods.gds-name.
                            end.
                        else
                            do:
                                f-name-gds-grp = "".
                            end.

                    assign
                        f-oper-code = buf_ext-classif.Key#_One
/*                        f-oper-code = integer(buf_ext-classif.uniq-key-rec)*/
                        f-oper-abbrev = buf_ext-classif.CharKey_One
                        f-gds-group-in-cass = integer(buf_ext-classif.Key#_Two)
                        v-list = buf_ext-classif.CharKey_Two
                    .
                    do v-ii = 1 to 13:                                      /* Считывание упакованной переменной по указателю p-io-rowid (передаваемой из главного окна) на экранную форму заполнения диалогового окна. */
                        v-value = trim(string(entry(v-ii, v-list, {&delim-par}))).
                        case v-ii:
                            when 1 then f-oper-name = v-value.
                            when 2 then f-min-digit-nums = integer(v-value).
                            when 3 then f-max-digit-nums = integer(v-value).
                            when 4 then f-min-sum = decimal(v-value).
                            when 5 then f-max-sum = decimal(v-value).
                            when 6 then f-warning-lim-sum = decimal(v-value).
                            when 7 then rs-type-comission = integer(v-value).
                            when 8 then f-comission-pcnt = decimal(v-value).
                            when 9 then f-comission-sum = decimal(v-value).
                            when 10 then t-necessary-authorization = logical(v-value).
                            when 11 then t-necessary-slip = logical(v-value).
                            when 12 then f-slip-file = v-value.
                            when 13 then rs-billing-type = integer(v-value).
                        end case.
                    end. /* do v-ii = 1 to 13: */
                end. /* b */
        end. /* a */

    if p-mode = {&add-def} then
        do: /* e */
            assign
                f-oper-code = 0
                f-oper-abbrev = ""
                f-gds-group-in-cass = 0
                f-name-gds-grp = ""
                v-list = ""
                f-oper-name = ""
                f-min-digit-nums = 0
                f-max-digit-nums = 0
                f-min-sum = 0
                f-max-sum = 0
                f-warning-lim-sum = 0
                rs-type-comission = 0
                f-comission-pcnt = 0
                f-comission-sum = 0
                t-necessary-authorization = false
                t-necessary-slip = false
                f-slip-file = ""
                rs-billing-type = 1.
            .
        end. /* e */

    display
        f-oper-code
        f-oper-abbrev
        f-gds-group-in-cass
        f-name-gds-grp
        f-oper-name
        f-min-digit-nums
        f-max-digit-nums
        f-min-sum
        f-max-sum
        f-warning-lim-sum
        Rs-type-comission
        f-comission-pcnt
        f-comission-sum
        t-necessary-authorization
        t-necessary-slip
        f-slip-file
        Rs-billing-type
    with frame Dialog-Frame.
    view frame Dialog-Frame.

    enable
        B-exit
        b-quit
        B-Help
        f-oper-code
        f-oper-abbrev
        f-gds-group-in-cass
        b-grp-gds
        f-oper-name
        f-min-digit-nums
        f-max-digit-nums
        f-min-sum
        f-max-sum
        f-warning-lim-sum
        Rs-type-comission
        f-comission-pcnt
        f-comission-sum
        t-necessary-authorization
        t-necessary-slip
        f-slip-file
        Rs-billing-type
        RECT-1
        RECT-2
    with frame Dialog-Frame.
    view frame Dialog-Frame.

    disable
        f-name-gds-grp
    with frame Dialog-Frame.
    view frame Dialog-Frame.

    apply "VALUE-CHANGED" to Rs-type-comission in frame Dialog-Frame.
    apply "VALUE-CHANGED" to t-necessary-slip in frame Dialog-Frame.

    if p-mode = {&update} then
        do:
            disable
                f-oper-code /* Устранение ошибки: т.к. новости работают только с режимами "Добавить" и "Удалить" запись в справочник ОСС и не работают с режимом "Изменить", то запрещаем пользователю изменять запись. Т.е. пользователю придётся удалить оператора с неправильным кодом и добавить заново - с правильным. Арн. 07.07.2014г */
                f-oper-abbrev
            with frame Dialog-Frame.
        end.

    if p-mode = {&Lookup} then /* Теперь выключим для режима "Чтение данных" только нужные виджеты. */
        do: /* g */
            disable
                B-exit
                /* b-quit */
                B-Help
                f-oper-code
                f-oper-abbrev
                f-gds-group-in-cass
                b-grp-gds
                f-name-gds-grp
                f-oper-name
                f-min-digit-nums
                f-max-digit-nums
                f-min-sum
                f-max-sum
                f-warning-lim-sum
                Rs-type-comission
                f-comission-pcnt
                f-comission-sum
                t-necessary-authorization
                t-necessary-slip
                f-slip-file
                Rs-billing-type
                RECT-1
                RECT-2
            with frame Dialog-Frame.
            view frame Dialog-Frame.
        end. /* g */

    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chck-min-max-fields-all-widgets1 Dialog-Frame 
PROCEDURE proc-chck-min-max-fields-all-widgets1 :
/*/* *** */                                                                                                                                                                                                                                                                                                                                           */
/*    /* "Лёгкая" (предварительная) проверка значений мин и макс для виджета "Мин/Макс кол-во цифр тлф", когда пользователь скачет по полям и пока допускаем ввод Макс значений = 0 без ругани (как бы ждём, что пользователь ещё сам вернётся к правильному вводу). Жёсткая проверка будет по нажатию на "сохранить", тут уже нули не допускаются! */*/
/*    if decimal(f-min-digit-nums:screen-value in frame Dialog-frame) > decimal(f-max-digit-nums:screen-value in frame Dialog-frame)                                                                                                                                                                                                                  */
/*        and decimal(f-max-digit-nums:screen-value in frame Dialog-frame) <> 0 then                                                                                                                                                                                                                                                                  */
/*            do:                                                                                                                                                                                                                                                                                                                                     */
/*                message 'Поле "Минимальное кол-во цифр телефона" не может быть больше поля "Максимальное кол-во цифр телефона"' skip                                                                                                                                                                                                                */
/*                "Введите корректные значения." view-as alert-box error.                                                                                                                                                                                                                                                                             */
/*/*                apply "entry" to f-max-digit-nums in frame Dialog-frame.*/                                                                                                                                                                                                                                                                        */
/*                undo, return error.                                                                                                                                                                                                                                                                                                                 */
/*            end.                                                                                                                                                                                                                                                                                                                                    */
/*    /* "Лёгкая" (предварительная) проверка значений мин и макс для виджета "Мин/Макс суммы", когда пользователь скачет по полям и пока допускаем ввод Макс значений = 0 без ругани (как бы ждём, что пользователь ещё сам вернётся к правильному вводу). Жёсткая проверка будет по нажатию на "сохранить", тут уже нули не допускаются! */          */
/*    if decimal(f-min-sum:screen-value in frame Dialog-frame) > decimal(f-max-sum:screen-value in frame Dialog-frame)                                                                                                                                                                                                                                */
/*        and decimal(f-max-sum:screen-value in frame Dialog-frame) <> 0 then                                                                                                                                                                                                                                                                         */
/*            do:                                                                                                                                                                                                                                                                                                                                     */
/*                message 'Поле "Минимальная сумма" не может быть больше поля "Максимальная сумма"' skip                                                                                                                                                                                                                                              */
/*                "Введите корректные значения." view-as alert-box error.                                                                                                                                                                                                                                                                             */
/*/*                apply "entry" to f-max-sum in frame Dialog-frame.*/                                                                                                                                                                                                                                                                               */
/*                undo, return error.                                                                                                                                                                                                                                                                                                                 */
/*            end.                                                                                                                                                                                                                                                                                                                                    */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chck-min-max-fields-all-widgets2 Dialog-Frame 
PROCEDURE proc-chck-min-max-fields-all-widgets2 :
/* *** */
    define variable v-msg-digit-nums as character no-undo.
    define variable v-msg-sum as character no-undo.
    
    /* "Полная" проверка значений мин и макс для виджета "Мин/Макс кол-во цифр тлф", когда пользователь скачет по полям и пока допускаем ввод Макс значений = 0 без ругани (как бы ждём, что пользователь ещё сам вернётся к правильному вводу). Жёсткая проверка будет по нажатию на "сохранить", тут уже нули не допускаются! */
    if decimal(f-min-digit-nums:screen-value in frame Dialog-frame) > decimal(f-max-digit-nums:screen-value in frame Dialog-frame) then
        do:
            v-msg-digit-nums = 'Поле "Минимальное кол-во цифр телефона" не может быть больше поля "Максимальное кол-во цифр телефона"!'.
/*            message "Поле ""Минимальное кол-во цифр телефона"" не может быть больше поля ""Максимальное кол-во цифр телефона""" skip*/
/*            "Введите корректные значения." view-as alert-box error.                                                                 */
/*            return error.*/
        end.
    /* "Полная" (предварительная) проверка значений мин и макс для виджета "Мин/Макс суммы", когда пользователь скачет по полям и пока допускаем ввод Макс значений = 0 без ругани (как бы ждём, что пользователь ещё сам вернётся к правильному вводу). Жёсткая проверка будет по нажатию на "сохранить", тут уже нули не допускаются! */
    if decimal(f-min-sum:screen-value in frame Dialog-frame) > decimal(f-max-sum:screen-value in frame Dialog-frame) then
        do:
            v-msg-sum = 'Поле "Минимальная сумма" не может быть больше поля "Максимальная сумма"!'.
/*            message "Поле ""Минимальная сумма"" не может быть больше поля ""Максимальная сумма""!" skip*/
/*            "Введите корректные значения." view-as alert-box error.*/
/*            return error.*/
        end.

/*    v-msg-digit-nums = (if v-msg-digit-nums <> "" and v-msg-digit-nums <> ? then v-msg-digit-nums else "")                          */
/*                     + (if v-msg-digit-nums <> "" and v-msg-digit-nums <> ? and v-msg-sum <> "" and v-msg-sum <> ? then " " else "")*/
/*                     + (if v-msg-sum <> "" and v-msg-sum <> ? then v-msg-sum else "").                                              */
    if v-msg-digit-nums <> "" and v-msg-digit-nums <> ? or v-msg-sum <> "" and v-msg-sum <> ? then
        do:
            message v-msg-digit-nums skip v-msg-sum skip
            "Введите корректные значения и повторите попытку." view-as alert-box error.
            undo, return error.
        end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-collect-par-1 AS character no-undo. /* Переменная, в которую собираем "коллекцию" параметров (суммы мин/макс, типы платежей сот. операт., и т.д. разделённых через delim-par. */
    define variable v-ii as integer no-undo.
    define variable v-i-cnt as integer initial 0 no-undo.
    define variable v-value as character no-undo.
    define variable v-list as character no-undo.

    assign
        frame {&FRAME-NAME}
        f-oper-code
        f-oper-abbrev
        f-gds-group-in-cass
        f-oper-name
        f-min-digit-nums
        f-max-digit-nums
        f-min-sum
        f-max-sum
        f-warning-lim-sum
        Rs-type-comission
        f-comission-pcnt
        f-comission-sum
        t-necessary-authorization
        t-necessary-slip
        f-slip-file
        Rs-billing-type
    .

    assign
    v-collect-par-1 =
        trim(string(f-oper-name)) + {&delim-par} +
        trim(string(f-min-digit-nums)) + {&delim-par} +
        trim(string(f-max-digit-nums)) + {&delim-par} +
        trim(string(f-min-sum)) + {&delim-par} +
        trim(string(f-max-sum)) + {&delim-par} +
        trim(string(f-warning-lim-sum)) + {&delim-par} +
        trim(string(rs-type-comission)) + {&delim-par} +
        trim(string(f-comission-pcnt)) + {&delim-par} +
        trim(string(f-comission-sum)) + {&delim-par} +
        trim(string(t-necessary-authorization)) + {&delim-par} +
        trim(string(t-necessary-slip)) + {&delim-par} +
        trim(string(f-slip-file)) + {&delim-par} +
        trim(string(rs-billing-type))
    .

    if p-mode = {&add-def} then
        do:

            /* Перед записью проверим: в вводимом поле "Код оператора" <f-oper-code> находится значение,
            которое уже есть в тек БД, т.е. это дубликат? Если да, то запрещаем записывать в БД вообще ни единого поля!*/

            find first buf_ext-classif where
                buf_ext-classif.Key#_One = f-oper-code and
                buf_ext-classif.classif-subject = {&extclass_oss-ref}
                no-lock no-error.
                if available buf_ext-classif then
                    do:
                        message "Внимание, запись в Базу Данных невозможна!" skip
                        "Запись с кодом оператора = " f-oper-code "уже существует" skip
                        "для оператора = " trim(string(entry(1, buf_ext-classif.CharKey_Two, {&delim-par}))) skip (2)
                        "Код номера каждого оператора связи должен быть уникальным!"
                        view-as alert-box error.
                        undo, return error.
                    end.
            /* _______________________________________________________________________________________________________ */
            create buf_ext-classif.

            assign
                buf_ext-classif.classif-subject = {&extclass_oss-ref}
                buf_ext-classif.classif-name = {&extclass_oss-ref}
                buf_ext-classif.db-num = p-db-num
                buf_ext-classif.Key#_One = f-oper-code
/*                buf_ext-classif.uniq-key-rec = string(f-oper-code)*/
                buf_ext-classif.Key#_Two = f-gds-group-in-cass
                buf_ext-classif.CharKey_One = f-oper-abbrev
                buf_ext-classif.CharKey_Two = v-collect-par-1
              
            no-error
            .
              p-io-rowid = rowid(buf_ext-classif).
            release   buf_ext-classif    no-error
            .
        end.

    if p-mode = {&update} then
        do:
            find first buf_ext-classif where rowid (buf_ext-classif) = p-io-rowid no-error.
            assign
                f-oper-code = buf_ext-classif.Key#_One
                f-oper-abbrev = buf_ext-classif.CharKey_One
                f-gds-group-in-cass = integer(buf_ext-classif.Key#_Two)
                v-list = buf_ext-classif.CharKey_Two
            .
            do v-ii = 1 to 13:
                v-value = trim(string(entry(v-ii, v-list, {&delim-par}))).
                    case v-ii:
                        when 1 then f-oper-name = v-value.
                        when 2 then f-min-digit-nums = integer(v-value).
                        when 3 then f-max-digit-nums = integer(v-value).
                        when 4 then f-min-sum = decimal(v-value).
                        when 5 then f-max-sum = decimal(v-value).
                        when 6 then f-warning-lim-sum = decimal(v-value).
                        when 7 then rs-type-comission = integer(v-value).
                        when 8 then f-comission-pcnt = decimal(v-value).
                        when 9 then f-comission-sum = decimal(v-value).
                        when 10 then t-necessary-authorization = logical(v-value).
                        when 11 then t-necessary-slip = logical(v-value).
                        when 12 then f-slip-file = v-value.
                        when 13 then rs-billing-type = integer(v-value).
                    end case.
            end.

            assign
                frame {&FRAME-NAME}
                f-oper-code
                f-oper-abbrev
                f-gds-group-in-cass
                f-oper-name
                f-min-digit-nums
                f-max-digit-nums
                f-min-sum
                f-max-sum
                f-warning-lim-sum
                Rs-type-comission
                f-comission-pcnt
                f-comission-sum
                t-necessary-authorization
                t-necessary-slip
                f-slip-file
                Rs-billing-type
            .

            assign
                buf_ext-classif.classif-subject = {&extclass_oss-ref}
                buf_ext-classif.classif-name = {&extclass_oss-ref}
                buf_ext-classif.db-num = p-db-num
/*                buf_ext-classif.uniq-key-rec = string(f-oper-code)*/
                buf_ext-classif.Key#_One = f-oper-code
                buf_ext-classif.Key#_Two = f-gds-group-in-cass
                buf_ext-classif.CharKey_One = f-oper-abbrev
                buf_ext-classif.CharKey_Two = v-collect-par-1
                p-io-rowid = rowid(buf_ext-classif)
            .
            end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

*/