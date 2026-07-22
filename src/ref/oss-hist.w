/*
26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История по объекту: Справочник ОСС.

Автор: Шутилов Арнольд Валерьевич
Дата создания: 29/04/14
Author: Arnold Shutilov
Creation date: 29/04/14

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc as widget-handle no-undo.
define input parameter p-oper-code as integer no-undo.
define input parameter p-classif-subject as character no-undo.
define input parameter p-db-num as integer no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник сезонов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
/*{ ref/extclass.i }*/

/* Local Variable Definitions ---                                       */
define variable v-recid1 as recid.
define variable v-recid as recid.

define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_c-ext-classif for ub.c-ext-classif.

define temp-table tt-c-oss-ref no-undo

    /* Ключевые поля */
    field oper-code as integer          /* Uniq for table: ext-classif. Первое и уникальное (из трёх) ключевое поле справочника ОСС в таблице ext-classif */
    field oper-abbrev as character      /* Второе (из трёх) ключевое поле справочника ОСС в таблице ext-classif */
    field gds-group-in-cass as integer  /* Третье (из трёх) ключевое поле справочника ОСС в таблице ext-classif */
    field chip-num as integer           /* Обычно эту "щепку" (цифру ветвления) отображаем в браузах истории. */

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

/*    index pi as primary unique oper-code /* Здесь проверка на уникальность не нужна (использую там, где ввод тек. данных, не история!) */*/
.

define temp-table tt-c-oss-ref-nohist no-undo like tt-c-oss-ref.


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

    index pi as primary unique oper-code /* Здесь проверка на уникальность не нужна (использую там, где ввод тек. данных, не история!) */
.

define temp-table tt-oss-hist no-undo
    field field-name as character
    field label-name as character
    field value-old as character
    field value-new as character.
/*index pi is unique primary field-name.*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

define buffer buf_tt-c-oss-ref for tt-c-oss-ref. /* "Разархивация" Истории Справочника ОСС из ub.c-ext-classif. Будет увязана с верхним браузером, показывающим полную запись, среди полей которой есть хоть одно Изменённое Поле. */

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-title-table-hist
&Scoped-define BROWSE-NAME br-val-chg-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help br-title-table-hist ~
br-val-chg-hist 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "В&ыход" 
     SIZE 10 BY 1.0
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.0
     BGCOLOR 8 .

/*Query definitions*/
define query br-title-table-hist for buf_tt-c-oss-ref scrolling.
define query br-val-chg-hist for tt-oss-hist scrolling.

/* Browse definitions                                                   */
DEFINE BROWSE br-title-table-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-title-table-hist Dialog-Frame _STRUCTURED
    query br-title-table-hist display
        buf_tt-c-oss-ref.chip-num column-label "Изменение №" format ">>>>>>>>>>9"
        buf_tt-c-oss-ref.oper-name column-label "Наименование оператора" format "X(30)"
        buf_tt-c-oss-ref.oper-abbrev column-label "Аббревиатура" format "X(20)"
        buf_tt-c-oss-ref.gds-group-in-cass column-label "Группа тов. на кассе"
/*        buf_tt-c-oss-ref.db-num column-label "Номер БД"*/

        buf_tt-c-oss-ref.min-digit-nums column-label "Мин. кол. цифр тел."
        buf_tt-c-oss-ref.max-digit-nums column-label "Макс. кол. цифр тел."
        buf_tt-c-oss-ref.min-sum column-label "Мин. сумма к опл."
        buf_tt-c-oss-ref.max-sum column-label "Макс. сумма к опл."
        buf_tt-c-oss-ref.warning-lim-sum column-label "Порог суммы для предупр."
        buf_tt-c-oss-ref.type-comission column-label "Тип комиссии"
        buf_tt-c-oss-ref.comission-pcnt column-label "% комиссии"
        buf_tt-c-oss-ref.comission-sum column-label "Сумма комиссии"
        buf_tt-c-oss-ref.necessary-authorization column-label "Необх. авториз."
        buf_tt-c-oss-ref.necessary-slip column-label "Необх. печать слипа" 
        buf_tt-c-oss-ref.slip-file column-label "Наим. слип-файла" 
        buf_tt-c-oss-ref.billing-type column-label "Тип расчёта с опер."

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 88 BY 7.62 FIT-LAST-COLUMN.

DEFINE BROWSE br-val-chg-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-val-chg-hist Dialog-Frame _STRUCTURED
    query br-val-chg-hist display
        tt-oss-hist.label-name column-label "Изменилось поле:" format "X(25)"
        tt-oss-hist.value-old column-label "Было" format "X(35)"
        tt-oss-hist.value-new column-label "Стало" format "X(35)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 88 BY 7.62 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.24 COL 3
     b-help AT ROW 1.24 COL 76
     br-title-table-hist AT ROW 2.91 COL 3 WIDGET-ID 200
     br-val-chg-hist AT ROW 11 COL 3 WIDGET-ID 300
     SPACE(1.19) SKIP(0.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История Справочника ОСС"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-title-table-hist b-help Dialog-Frame */
/* BROWSE-TAB br-val-chg-hist br-title-table-hist Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME




/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История  Справочника ОСС */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  /* new trigger */  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME b-help


&Scoped-define BROWSE-NAME br-title-table-hist
&Scoped-define SELF-NAME br-title-table-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-title-table-hist Dialog-Frame
ON VALUE-CHANGED OF br-title-table-hist IN FRAME Dialog-Frame /* Browse 1 */
DO:
/*        if available buf_tt-c-oss-ref then*/
/*find next buf_tt-c-oss-ref no-error.*/
        if available buf_tt-c-oss-ref then
            do:
                v-recid1 = recid (buf_tt-c-oss-ref).
                run proc-open-br-oss-hist-val no-error.
            end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define BROWSE-NAME br-val-chg-hist
&Scoped-define SELF-NAME br-val-chg-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-val-chg-hist Dialog-Frame
ON VALUE-CHANGED OF br-val-chg-hist IN FRAME Dialog-Frame /* Browse 2 */
DO:
/*    run proc-open-br-oss-hist-val.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define BROWSE-NAME br-title-table-hist
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
/*{ gbl/app_help.i }*/

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
/*  RUN enable_UI.*/
    run proc-my-enable-UI.
    run proc-fill-tt-oss-ref.
    run proc-fill-tt-c-oss-ref.
    run proc-open-br-oss-hist-title.
/*    run proc-open-br-oss-hist-val.*/

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
  ENABLE b-exit b-help 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&IF DEFINED(EXCLUDE-proc-fill-tt-oss-ref) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-fill-tt-oss-ref Include
procedure proc-fill-tt-c-oss-ref:

define variable v-ii as integer no-undo.
define variable v-value as character no-undo.
define variable v-list as character no-undo.

    for each buf_c-ext-classif where buf_c-ext-classif.classif-subject = "oss-ref":U no-lock:
            create tt-c-oss-ref.
            assign
                tt-c-oss-ref.oper-code = buf_c-ext-classif.Key#_One
/*                tt-c-oss-ref.oper-code = string(buf_c-ext-classif.uniq-key-rec)*/
                tt-c-oss-ref.oper-abbrev = buf_c-ext-classif.CharKey_One
                tt-c-oss-ref.gds-group-in-cass = integer(buf_c-ext-classif.Key#_Two)
                tt-c-oss-ref.db-num = p-db-num
                tt-c-oss-ref.classif-subject = buf_c-ext-classif.classif-subject /* Сущность */
                tt-c-oss-ref.classif-name = buf_c-ext-classif.classif-name /* Классификатор */
                tt-c-oss-ref.chip-num = buf_c-ext-classif.chip-num /* Обычно эту "щепку" (цифру ветвления) отображаем в браузах истории. */
                v-list = buf_c-ext-classif.CharKey_Two
            .

            do v-ii = 1 to 13: /* Линейно считываем параметры. Последовательность - см выше, в обявлении временной таблицы tt-oss-ref */
                do:
                    v-value = trim(string(entry(v-ii, v-list, {&delim-par}))).
                    case v-ii:
                        when 1 then tt-c-oss-ref.oper-name = v-value.
                        when 2 then tt-c-oss-ref.min-digit-nums = integer(v-value).
                        when 3 then tt-c-oss-ref.max-digit-nums = integer(v-value).
                        when 4 then tt-c-oss-ref.min-sum = decimal(v-value).
                        when 5 then tt-c-oss-ref.max-sum = decimal(v-value).
                        when 6 then tt-c-oss-ref.warning-lim-sum = decimal(v-value).
                        when 7 then tt-c-oss-ref.type-comission = integer(v-value).
                        when 8 then tt-c-oss-ref.comission-pcnt = decimal(v-value).
                        when 9 then tt-c-oss-ref.comission-sum = decimal(v-value).
                        when 10 then tt-c-oss-ref.necessary-authorization = logical(v-value).
                        when 11 then tt-c-oss-ref.necessary-slip = logical(v-value).
                        when 12 then tt-c-oss-ref.slip-file = v-value.
                        when 13 then tt-c-oss-ref.billing-type = integer(v-value).
                    end case.
                end.
            end. /* do v-ii = 1 to 13: */
    end. /* for each buf_ext-classif */

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF




&IF DEFINED(EXCLUDE-proc-fill-tt-oss-ref) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-fill-tt-oss-ref Include
procedure proc-fill-tt-oss-ref:

define variable v-ii as integer no-undo.
define variable v-value as character no-undo.
define variable v-list as character no-undo.

    for each buf_ext-classif where buf_ext-classif.classif-subject = "oss-ref":U no-lock:
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

            do v-ii = 1 to 13: /* Линейно считываем параметры. Последовательность - см выше, в обявлении временной таблицы tt-oss-ref */
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

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF



&IF DEFINED(EXCLUDE-proc-my-enable-UI) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-my-enable-UI Include
procedure proc-my-enable-UI:

    display
        b-exit
        b-help
    with frame Dialog-Frame.

    enable
        b-exit
        b-help
        br-title-table-hist
        br-val-chg-hist
    with frame Dialog-Frame.

    view frame Dialog-Frame.

    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


&IF DEFINED(EXCLUDE-proc-open-br-val-chg-hist) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-open-br-val-chg-hist Include
procedure proc-open-br-oss-hist-title:

    /* Выводим в браузер последнюю запись Справочника (не история), для которой есть хоть одна запись Истории и проверяем, чтобы остальные записи, у которых совсем нет истории - не выводились в брауз. */
    /* Передаём строку, на которой находимся в этом верхнем браузе (полная запись БД истории) в нижний брауз изменений (где показываем поля что и на что изменилось) */

    define buffer buf_tt2-oss-ref for tt-oss-ref.

    find first buf_tt2-oss-ref no-lock where
        buf_tt2-oss-ref.oper-code = p-oper-code and
        buf_tt2-oss-ref.classif-subject = p-classif-subject no-error.

        do:
            if available buf_tt2-oss-ref then
                do:
                    find first buf_tt-c-oss-ref no-lock where
                        buf_tt-c-oss-ref.oper-code = buf_tt2-oss-ref.oper-code and
                        buf_tt-c-oss-ref.classif-subject = buf_tt2-oss-ref.classif-subject no-error.
        
                    if available buf_tt-c-oss-ref then
                        do:
                            v-recid = recid(buf_tt-c-oss-ref).
                        end.
                end.
            else
                do:
                    v-recid = ?.
                end.
        end.

    open query br-title-table-hist for each buf_tt-c-oss-ref where
        buf_tt-c-oss-ref.oper-code = p-oper-code and
        buf_tt-c-oss-ref.classif-subject = p-classif-subject
        no-lock.


    run proc-open-br-oss-hist-val.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF



&IF DEFINED(EXCLUDE-proc-open-br-oss-hist-val) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-open-br-oss-hist-val Include
procedure proc-open-br-oss-hist-val:

    define variable v-chg-fields as character initial "" no-undo.
    define variable ii as integer no-undo.
    define buffer buf_tt-c-oss-ref-old for tt-c-oss-ref.
    define buffer buf_tt-oss-ref-cur for tt-oss-ref.

    for each tt-oss-hist:
        delete tt-oss-hist.
    end.

    if available buf_tt-c-oss-ref then
        do:

            find last buf_tt-c-oss-ref-old no-lock where
                buf_tt-c-oss-ref-old.classif-subject = buf_tt-c-oss-ref.classif-subject and
                buf_tt-c-oss-ref-old.oper-code = buf_tt-c-oss-ref.oper-code and
                buf_tt-c-oss-ref-old.chip-num < buf_tt-c-oss-ref.chip-num
            no-error.

            if available buf_tt-c-oss-ref-old then
                do:
                    buffer-compare buf_tt-c-oss-ref-old
                        except
                            chip-num
                            classif-name
                            classif-subject
                            db-num
                    to buf_tt-c-oss-ref save result in v-chg-fields.
                end.
            else /* Если не найдена более ранняя запись - то стоим на первосозданной записи. Тогда в таблице изменений tt-oss-hist нужно отобразить в колонке "с" - пустышки. */
                do:
                    find first buf_tt-oss-ref-cur no-lock where /* Берём из таблицы НЕ-истории(!): ub.ext-classif текущее (последнее, новейшее) значение. */
                        buf_tt-oss-ref-cur.classif-subject = buf_tt-c-oss-ref.classif-subject and /* Сравниваем ТЕК ЗНАЧ НЕ ИСТОРИИ(в ext-classif), со значением, что пришло в параметрах и открыло "верхний" браузер br-title-table-hist. */
                        buf_tt-oss-ref-cur.oper-code = buf_tt-c-oss-ref.oper-code
                    no-error.
                        do: /* Итак, мы не нашли более раннюю запись, но должны вывести в браузере все поля, чтобы показать изменения "с" = "" >> "на" = первозданная запись, а это связано с использованием переменной v-chg-fields. Заполняем её (всеми полями tt-oss-hist!) для CASE, который будет ниже: */
                            v-chg-fields = "oper-name,oper-abbrev,gds-group-in-cass,min-digit-nums,max-digit-nums,min-sum,max-sum,warning-lim-sum,type-comission,comission-pcnt,comission-sum,necessary-authorization,necessary-slip,slip-file,billing-type".
                        end.
                end.
        end.
    else
        do:
/* Если вывести эту строку, то в истории отобр строка, для которой ещё нет истории. Т.е. посчитается, что ПЕРВОЗДАННАЯ запись и есть история.           v-chg-fields = "oper-name,oper-abbrev,gds-group-in-cass,min-digit-nums,max-digit-nums,min-sum,max-sum,warning-lim-sum,type-comission,comission-pcnt,comission-sum,necessary-authorization,necessary-slip,slip-file,billing-type".*/
            open query br-val-chg-hist for each tt-oss-hist. /* Заполняем гарантировано пустышку и выходим. */
            return.
        end.

    define variable v-val as integer no-undo.
    v-val = num-entries(v-chg-fields).

    if v-val >= 0 then
        do: /* j */

            &scop ct ~
                when "~{&field-name-t}~" then~
                do:~
                    assign~
                        tt-oss-hist.label-name = ~{&field-label-t}~
                        tt-oss-hist.value-old = (if available buf_tt-c-oss-ref-old then string(buf_tt-c-oss-ref-old.~{&field-name-t}~) else "" ~)~
                        tt-oss-hist.value-new = string(buf_tt-c-oss-ref.~{&field-name-t}~)~
                    .~
                end.

            do ii = 1 to v-val: /* k */

                create tt-oss-hist.

                case entry(ii, v-chg-fields):

                    &scop field-name-t oper-name
                    &scop field-label-t "Наименование оператора"
                    {&ct}
                    &scop field-name-t oper-abbrev
                    &scop field-label-t "Аббревиатура"
                    {&ct}
                    &scop field-name-t gds-group-in-cass
                    &scop field-label-t "Группа тов. на кассе"
                    {&ct}
                    &scop field-name-t min-digit-nums
                    &scop field-label-t "Мин. кол. цифр тел."
                    {&ct}
                    &scop field-name-t max-digit-nums
                    &scop field-label-t "Макс. кол. цифр тел."
                    {&ct}
                    &scop field-name-t min-sum
                    &scop field-label-t "Мин. сумма к опл."
                    {&ct}
                    &scop field-name-t max-sum
                    &scop field-label-t "Макс. сумма к опл."
                    {&ct}
                    &scop field-name-t warning-lim-sum
                    &scop field-label-t "Порог суммы для предупр."
                    {&ct}
                    &scop field-name-t type-comission
                    &scop field-label-t "Тип комиссии"
                    {&ct}
                    &scop field-name-t comission-pcnt
                    &scop field-label-t "% комиссии"
                    {&ct}
                    &scop field-name-t comission-sum
                    &scop field-label-t "Сумма комиссии"
                    {&ct}
                    &scop field-name-t necessary-authorization
                    &scop field-label-t "Необх. авториз."
                    {&ct}
                    &scop field-name-t necessary-slip
                    &scop field-label-t "Необх. печать слипа"
                    {&ct}
                    &scop field-name-t slip-file
                    &scop field-label-t "Наимен. слип-файла"
                    {&ct}
                    &scop field-name-t billing-type
                    &scop field-label-t "Тип расчёта с опер."
                    {&ct}

                end case.
            end. /* k */
        end. /* j */

    open query br-val-chg-hist for each tt-oss-hist.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


*/