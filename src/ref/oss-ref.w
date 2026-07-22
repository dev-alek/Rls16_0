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

Справочник Операторов Сотовой Связи. Главное окно.

Автор: Шутилов Арнольд Валерьевич
Дата создания: 29/04/14
Author: Arnold Shutilov
Creation date: 29/04/14

--------------------------------------------------------------------------*/

using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.

define input parameter parParentProc as widget-handle no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-db-num as integer no-undo.
define output parameter p-rid-list as character no-undo. /* список recid'ов из таблицы ext-classif связка с таблицей выводимой в браузере (tt-oss-ref) */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник сезонов".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/extclass.i }

define variable rid-list as character no-undo. /* список recid'ов выбранных записей в браузере (по tt-oss-ref) */
define variable v-rowid as rowid no-undo.
define variable v-rowid-tt-oss-ref as rowid no-undo.
define variable v-log as logical no-undo.
define variable log-res as logical no-undo.
define variable v-cur-time as character no-undo.

define buffer buf_ext-classif for ub.ext-classif.

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
    field ext-classif-row as rowid     /* Ключ соотв. таблице ext-classif */

    index pi as primary unique oper-code
.

define buffer buf_tt-oss-ref for tt-oss-ref.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-oss

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-oss-ref

/* Definitions for BROWSE br-oss                                        */
&Scoped-define FIELDS-IN-QUERY-br-oss (if (can-do(rid-list, string(recid(tt-oss-ref)))) then ("*") else (" ")) /* tt-oss-ref.db-num */ /* tt-oss-ref.classif-subject /* Сущность */*/ tt-oss-ref.oper-code /* Первое (из трёх) ключевое поле справочника ОСС в таблице ext-classif */ tt-oss-ref.oper-name /* 1. Название Оператора Связи */ tt-oss-ref.oper-abbrev /* Второе (из трёх) ключевое поле справочника ОСС в таблице ext-classif */ tt-oss-ref.gds-group-in-cass /* Третье (из трёх) ключевое поле справочника ОСС в таблице ext-classif */ tt-oss-ref.min-digit-nums /* 2. Минимальное кол-во цифр для ввода номера сотового телефона */ tt-oss-ref.max-digit-nums /* 3. Максимальное кол-во цифр для ввода номера сотового телефона */ tt-oss-ref.min-sum /* 4. Минимальная сумма начисления */ tt-oss-ref.max-sum /* 5. Максимальная сумма начисления */ tt-oss-ref.warning-lim-sum /* 6. Порог суммы для выдачи предупреждения */ tt-oss-ref.type-comission /* 7. Типы ввода комиссии (цифры от 0 до 3) */ tt-oss-ref.comission-pcnt /* 8. % комиссии */ tt-oss-ref.comission-sum /* 9. Сумма комиссии */ tt-oss-ref.necessary-authorization /* 10. Авторизация неохбодима */ tt-oss-ref.necessary-slip /* 11. Печать слипа необходима */ tt-oss-ref.slip-file /* 12. Имя файла образа конечного слипа */ tt-oss-ref.billing-type /* 13. Тип расчёта с оператором */   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-oss   
&Scoped-define SELF-NAME br-oss
&Scoped-define QUERY-STRING-br-oss FOR EACH tt-oss-ref
&Scoped-define OPEN-QUERY-br-oss OPEN QUERY {&SELF-NAME} FOR EACH tt-oss-ref.
&Scoped-define TABLES-IN-QUERY-br-oss tt-oss-ref
&Scoped-define FIRST-TABLE-IN-QUERY-br-oss tt-oss-ref


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-oss}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-lookup b-hist b-help B-mark ~
b-add b-upd b-del b-print mark-num br-oss 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnc-cur-time-print Procedure
function fnc-cur-time-print returns character forward.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-hist 
     LABEL "Ис&тория" 
     SIZE 10 BY 1.

DEFINE BUTTON b-lookup 
     LABEL "Про&смотр":L 
     SIZE 10 BY 1.

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-print 
     LABEL "Пе&чать":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-upd 
     LABEL "&Изменить":L 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

/* Query definitions */
&ANALYZE-SUSPEND
define query br-oss for 
      tt-oss-ref scrolling.
&ANALYZE-RESUME

/* Browse definitions                                                   */
define browse br-oss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-oss Dialog-Frame _STRUCTURED
  query br-oss display
      (if (can-do(rid-list, string(recid(tt-oss-ref)))) then ("*") else (" ")) column-label "*" format "X(1)":U
/*    tt-oss-ref.db-num column-label "БД" format ">>>9":U                                                               */
/*    tt-oss-ref.classif-subject column-label "Сущность" format "X(8)":U                                  /* Сущность */*/
    tt-oss-ref.oper-code column-label "Код!Операт." format ">>9":U                                      /* Первое (из трёх) ключевое поле справочника ОСС в таблице ext-classif */
    tt-oss-ref.oper-name column-label "Наименование опер." format "X(15)":U                             /* 1. Название Оператора Связи */
    tt-oss-ref.oper-abbrev column-label "Аббревиат. опер." format "X(15)":U                             /* Второе (из трёх) ключевое поле справочника ОСС в таблице ext-classif */
    tt-oss-ref.gds-group-in-cass column-label "Код!товара" format ">>>>>>>>>>>9":U                      /* Третье (из трёх) ключевое поле справочника ОСС в таблице ext-classif */
    tt-oss-ref.min-digit-nums column-label "Мин. кол.!цифр телеф." format ">9":U                        /* 2. Минимальное кол-во цифр для ввода номера сотового телефона */
    tt-oss-ref.max-digit-nums column-label "Макс. кол.!цифр телеф." format ">9":U                       /* 3. Максимальное кол-во цифр для ввода номера сотового телефона */
    tt-oss-ref.min-sum column-label "Мин. сумма" format "->,>>>,>>>,>>>,>>9.99":U                       /* 4. Минимальная сумма начисления */
    tt-oss-ref.max-sum column-label "Макс. сумма" format "->,>>>,>>>,>>>,>>9.99":U                      /* 5. Максимальная сумма начисления */
    tt-oss-ref.warning-lim-sum column-label "Порог сумм. для предупр." format "->,>>>,>>>,>>>,>>9.99":U /* 6. Порог суммы для выдачи предупреждения */
    tt-oss-ref.type-comission column-label "Тип ввода комиссии" format ">9":U                           /* 7. Типы ввода комиссии (цифры от 0 до 3) */
    tt-oss-ref.comission-pcnt column-label "% комиссии" format "->>>9.99%":U                            /* 8. % комиссии */
    tt-oss-ref.comission-sum column-label "Сумма комиссии" format "->,>>>,>>>,>>>,>>9.99":U             /* 9. Сумма комиссии */
    tt-oss-ref.necessary-authorization column-label "Необх. авториз."                                   /* 10. Авторизация неохбодима */
    tt-oss-ref.necessary-slip column-label "Необх. печ. слипа"                                          /* 11. Печать слипа необходима */
    tt-oss-ref.slip-file column-label "Имя файла конеч. слипа" format "X(10)":U                         /* 12. Имя файла образа конечного слипа */
    tt-oss-ref.billing-type column-label "Тип расчёта с опер. пополн." format ">9":U                      /* 13. Тип расчёта с оператором */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100 BY 18 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 14
     b-lookup AT ROW 1 COL 24 WIDGET-ID 2
     b-hist AT ROW 1 COL 33 WIDGET-ID 8
     b-help AT ROW 1 COL 43
     B-mark AT ROW 2 COL 1
     b-add AT ROW 2 COL 4
     b-upd AT ROW 2 COL 14
     b-del AT ROW 2 COL 24
     b-print AT ROW 2 COL 43
     mark-num AT ROW 3.05 COL 41 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     br-oss AT ROW 4.1 COL 1 WIDGET-ID 100
     SPACE(1.00) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Операторы\эмитенты для пополнения счетов":L.


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
/* BROWSE-TAB br-oss mark-num Dialog-Frame */
assign 
       frame Dialog-Frame:SCROLLABLE       = false
       frame Dialog-Frame:HIDDEN           = true.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
on choose of b-add in frame Dialog-Frame /* Добавить */
do:

    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_oss_add-chg-del':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        true
        v-log
    }

    if not v-log then return no-apply.

    run ref/oss-prop.w
        (input parParentProc,
        input {&add-def},
        input p-db-num,
        input-output v-rowid
        ) no-error.
        
        
 
    if v-rowid <> ? then
        do:
            {&open-query-br-oss}
            run fill-tt-oss-ref no-error.
            find first buf_ext-classif where rowid (buf_ext-classif) = v-rowid no-error .
            find first tt-oss-ref where rowid (buf_ext-classif) = tt-oss-ref.ext-classif-row no-error.
            v-rowid-tt-oss-ref = rowid (tt-oss-ref) no-error.
            {&open-query-br-oss}
            reposition br-oss to rowid v-rowid-tt-oss-ref no-error.
        end.
    else
        do:
            {&open-query-br-oss}
            reposition br-oss to rowid v-rowid-tt-oss-ref no-error.
        end.

    v-rowid = ?. /* Это для корректной обработки в блоке if, в случае, когда мы второй раз подряд нажимаем кнопку добавить, но далее - нажимаем отмена. Без этой строки, в случае отмены остался бы rowid чем-то наполненный и браузер выделил бы на экр. строку с "мусором", вместо того, чтобы "неподвижно" остаться на исходной (куда нужно вернуться после отмены). */

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
on choose of b-del in frame Dialog-Frame /* Удалить */
do:
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_oss_add-chg-del':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        true
        v-log
    }

    find first buf_ext-classif where rowid (buf_ext-classif) = tt-oss-ref.ext-classif-row no-error.
    v-rowid-tt-oss-ref = rowid (tt-oss-ref).
    if not v-log or not available buf_ext-classif then return no-apply.

    find current buf_ext-classif exclusive-lock no-error.
    if available buf_ext-classif then
        do:
            message "Удалить запись?" view-as alert-box question button yes-no update b as logical.
                if b then
                    do:
                        br-oss:select-prev-row ().
                        v-rowid-tt-oss-ref = rowid(tt-oss-ref).
                        delete buf_ext-classif.
                    end.
        end.
    run fill-tt-oss-ref no-error.
    find first tt-oss-ref no-error.
    {&open-query-br-oss}
    reposition br-oss to rowid v-rowid-tt-oss-ref no-error.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
on choose of b-hist in frame Dialog-Frame /* История */
do:
    if available tt-oss-ref then /* Выполнение только если tt-oss-ref не пустая или её буфер не пустой. */
        do:
            run ref/oss-hist.w
                (
                input parParentProc,
                input tt-oss-ref.oper-code,
                input tt-oss-ref.classif-subject,
                input p-db-num
                ).
        end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lookup Dialog-Frame
on choose of b-lookup in frame Dialog-Frame /* Просмотр */
do:
  /* new trigger */
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_oss_add-chg-del':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        true
        v-log
    }

    find first buf_ext-classif where rowid (buf_ext-classif) = tt-oss-ref.ext-classif-row no-error.
    if not v-log or not available buf_ext-classif then return no-apply.

    v-rowid = rowid(buf_ext-classif).
    run ref/oss-prop.w
        (parParentProc,
        {&Lookup},
        input p-db-num,
        input-output v-rowid
        ) no-error.
    {&open-query-br-oss}
    run fill-tt-oss-ref no-error.
    find first buf_ext-classif where rowid (buf_ext-classif) = v-rowid no-error.
    find first tt-oss-ref where rowid (buf_ext-classif) = tt-oss-ref.ext-classif-row no-error.
    v-rowid = rowid (tt-oss-ref).    
    {&open-query-br-oss}
    reposition br-oss to rowid v-rowid no-error.
    v-rowid = ?.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
on choose of B-mark in frame Dialog-Frame /* * */
do:
/*    find first*/
    if not available tt-oss-ref then return.

    { gbl/markstrn.i tt-oss-ref rid-list }

    v-log = br-oss:refresh() in frame {&frame-name}.

    if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then
    do:
        v-log = br-oss:select-next-row () in frame {&frame-name}.
        apply "value-changed" to br-oss in frame {&frame-name}.
    end.
    if num-entries (rid-list) = 0 then hide mark-num in frame {&frame-name}.
    else display num-entries (rid-list) @ mark-num with frame {&frame-name}.
    apply "entry" to br-oss in frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
on choose of b-print in frame Dialog-Frame /* Печать */
do:
    run proc-print-on-ie.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
on choose of b-sel in frame Dialog-Frame /* Выбор */
do:
    if rid-list <> "" then /* Если есть recid из временной таблицы, тогда1... */
    do:
        run fill-p-rid-list(input rid-list, output p-rid-list). /* ...тогда1 подтягиваем recid из ТН: ext-classif */
    end.
    if available tt-oss-ref and rid-list = "" then
    do:
        rid-list = string(recid(tt-oss-ref)).
        p-rid-list = string(tt-oss-ref.ext-classif-row).
    end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd Dialog-Frame
on choose of b-upd in frame Dialog-Frame /* Изменить */
do:
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_oss_add-chg-del':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        true
        v-log
    }
    find first buf_ext-classif where rowid (buf_ext-classif) = tt-oss-ref.ext-classif-row no-error.
    if not v-log or not available buf_ext-classif then return no-apply.

    v-rowid = rowid(buf_ext-classif).
    run ref/oss-prop.w
        (parParentProc,
        {&update},
        input p-db-num,
        input-output v-rowid
        ) no-error.
    {&open-query-br-oss}
    run fill-tt-oss-ref no-error.
    find first buf_ext-classif where rowid (buf_ext-classif) = v-rowid no-error.
    find first tt-oss-ref where rowid (buf_ext-classif) = tt-oss-ref.ext-classif-row no-error.
    v-rowid = rowid (tt-oss-ref).    
    {&open-query-br-oss}
    reposition br-oss to rowid v-rowid no-error.
    v-rowid = ?.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-oss
&Scoped-define SELF-NAME br-oss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-oss Dialog-Frame
on mouse-select-dblclick of br-oss in frame Dialog-Frame /* Browse 1 */
do:
    if p-db-num = 0 then
        do:
            apply "choose" to b-lookup in frame {&frame-name}.
            return no-apply.
        end.
    else
        do:
            apply "choose" to b-lookup in frame {&frame-name}.
            return no-apply.
        end. 
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-oss Dialog-Frame
on return of br-oss in frame Dialog-Frame
do:
    if p-db-num = 0 then
        do:
            apply "choose" to b-lookup in frame {&frame-name}.
            return no-apply.
        end.
    else
        do:
            apply "choose" to b-lookup in frame {&frame-name}.
            return no-apply.
        end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-oss Dialog-Frame
on value-changed of br-oss in frame Dialog-Frame /* Browse 1 */
do:
    v-rowid-tt-oss-ref = rowid (tt-oss-ref).
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
then frame {&FRAME-NAME}:PARENT = active-window.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN fill-tt-oss-ref IN THIS-PROCEDURE.
  RUN MyEnable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
procedure disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  hide frame Dialog-Frame.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
procedure enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  display mark-num 
      with frame Dialog-Frame.
  enable b-exit b-sel b-lookup b-hist b-help B-mark b-add b-upd b-del b-print 
         mark-num 
      with frame Dialog-Frame.
  view frame Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.
	
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

 		
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-p-rid-list Include
procedure fill-p-rid-list:
/* Получение recid ext-classif по recid-ам временной таблицы tt-oss-ref */
    define input parameter p-rid-list-tt as character no-undo.
    define output parameter p-rid-list_ext-classif as character no-undo.
    define variable v-i as integer no-undo.
    
    define buffer buf_tt-oss-ref for tt-oss-ref.

    do v-i = 1 to num-entries (p-rid-list-tt):
        for each buf_tt-oss-ref where
        recid(buf_tt-oss-ref) = integer(entry(v-i, p-rid-list-tt, ","))
        no-lock:
            if p-rid-list_ext-classif <> "" then
            do:
                p-rid-list_ext-classif = p-rid-list_ext-classif + "," + string(buf_tt-oss-ref.ext-classif-row). /* Если в переменной p-rid-list_ext-classif уже что-то содержится, ставим перед записью запятую-разделитель списка. */
            end.
            else
            do:
                p-rid-list_ext-classif = string(buf_tt-oss-ref.ext-classif-row). /* Если в переменной p-rid-list_ext-classif пусто, то перед первой записью запятую-разделитель списка не ставим. */
            end.
        end.
    end.

end procedure.
	
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt-oss-ref Dialog-Frame 
PROCEDURE fill-tt-oss-ref :
define variable v-ii as integer no-undo.
define variable v-i-cnt as integer initial 0 no-undo.
define variable v-value as character no-undo.
define variable v-list as character no-undo.
    do:
        find first tt-oss-ref no-lock no-error.
        
        if available tt-oss-ref then
            do:
                for each tt-oss-ref no-lock:
                    delete tt-oss-ref.
                end.
            end.
        for each buf_ext-classif where buf_ext-classif.classif-subject = {&extclass_oss-ref} no-lock:
                create tt-oss-ref.
                assign
                    tt-oss-ref.oper-code = buf_ext-classif.Key#_One
/*                    tt-oss-ref.oper-code = string(buf_ext-classif.uniq-key-rec)*/
                    tt-oss-ref.oper-abbrev = buf_ext-classif.CharKey_One
                    tt-oss-ref.gds-group-in-cass = integer(buf_ext-classif.Key#_Two)
                    tt-oss-ref.db-num = p-db-num
                    tt-oss-ref.classif-subject = buf_ext-classif.classif-subject /* Сущность */
                    tt-oss-ref.classif-name = buf_ext-classif.classif-name /* Классификатор */
                    tt-oss-ref.ext-classif-row = rowid(buf_ext-classif)
                    v-list = buf_ext-classif.CharKey_Two
                .
                do v-ii = 1 to 13: /* Линейно распаковываем аттрибуты Оператора Сотовой Связи во временную таблицу.. Последовательность - см выше, в обявлении временной таблицы tt-oss-ref */
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
                v-i-cnt = v-i-cnt + 1.
        end. /* for each buf_ext-classif */
        if v-i-cnt = 0 then
            do:
              message "Информационно:" skip "Справочник Операторов/эмитентов для пополнения счетов" skip "не имеет ни одной записи!"
              view-as alert-box.
/*              return error.*/
            end.
        {&OPEN-QUERY-br-oss}
    end.
end procedure. /* procedure fill-tt-oss-ref */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    display
        br-oss b-exit b-sel b-hist b-help B-mark b-add b-upd b-del b-print B-mark b-lookup br-oss 
    with frame Dialog-Frame.

    enable
        br-oss
        b-exit
        b-sel when (lookup("v-sel", p-mode) > 0)
        b-hist
        b-help
        b-mark when (lookup("v-sel", p-mode) > 0)
        b-add
/*        b-upd*/ /* ТН-3133. 2014г. Арн. Устранение конфликта: Новости при каждом изменении перебрасывают данные правильно, но создают каждый раз уникальные записи, по этому получается задваивание ключевых полей! Отключаем пока корректировку! Соглас с Рук. */
        b-del
        b-print
        b-lookup
        br-oss 
    with frame Dialog-Frame.

    if num-entries (rid-list) = 0 then hide mark-num in frame {&frame-name}.
    else display num-entries (rid-list) @ mark-num with frame {&frame-name}.

    if p-db-num <> 0 then
        do:
            disable
                b-add b-upd b-del
            with frame Dialog-Frame.
        end.
  view frame Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-create-file-rep Dialog-Frame
procedure proc-create-file-rep:
define output parameter p-filename as character no-undo.
    define variable v-rls-file as character no-undo.
    define variable v-data-file as character no-undo.
    define variable v-xsl-file as character no-undo.
    define variable v-tmp-file as character no-undo.
    define variable h-hw as handle no-undo.
    define variable cls-rep-out as class Rep-Out no-undo.

    assign
        v-xsl-file = search("exe/oss-ref.xsl.html")
        v-data-file = session:temp-directory + string(time) + ".xml"
        v-tmp-file = session:temp-directory + string(time) + ".html"
    .

    create sax-writer h-hw.
    h-hw:formatted = true.
    h-hw:set-output-destination("file", v-data-file).

    run proc-write-data(h-hw).
    cls-rep-out = new rep-out().
    v-rls-file = cls-rep-out:xsl-transform(v-data-file, v-xsl-file).
    os-delete value(v-tmp-file).
    os-copy value(v-rls-file) value(v-tmp-file).
    os-delete value(v-rls-file).
    delete object cls-rep-out.

    p-filename = v-tmp-file.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cur-time Dialog-Frame
procedure proc-cur-time:
do on error undo, return error:

        define output parameter p-today as date no-undo.
        define output parameter p-time as integer no-undo.

        define variable v-date1 as date no-undo.
        define variable v-date2 as date no-undo.
        define variable v-time as integer no-undo.

        assign
          v-date1 = today
          v-time = time
          v-date2 = today
        .

        if v-date1 <> v-date2 then
            do:
                /* если вызов функции происходил в момент смены даты, */
                /* то необходимо сделать повторный запрос */
                assign
                    v-date1 = today
                    v-time  = v-time
                    v-date2 = today
                .
            end.

        assign
            p-today = v-date1
            p-time  = v-time
        .
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-open-ie Dialog-Frame
procedure proc-open-ie:
define input parameter p-filename as character no-undo.
    define variable c-h-IE as com-handle no-undo.

    create "InternetExplorer.Application" c-h-IE.
    c-h-IE:addressbar = false.
    c-h-IE:navigate(p-filename).
    c-h-IE:visible = true.
    release object c-h-IE.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-on-ie Dialog-Frame
procedure proc-print-on-ie:
define buffer buf_tt-oss-ref-print for tt-oss-ref.
    define variable v-file-name as character no-undo.

    v-cur-time = fnc-cur-time-print().

    run proc-create-file-rep(output v-file-name).

    if v-file-name = ? then
        do:
            message "Не удалось создать html-файл!" view-as alert-box error.
        end.
    else
        do:
            run proc-open-ie(input v-file-name).
        end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-write-data Dialog-Frame
procedure proc-write-data:
define input parameter p-i-hw as handle no-undo.

    p-i-hw:start-document().
    p-i-hw:start-element("rep").
    p-i-hw:start-element("card").

    p-i-hw:insert-attribute("time", if v-cur-time = ? then "" else v-cur-time).

    for each buf_tt-oss-ref no-lock:
        p-i-hw:start-element("line").
/*        p-i-hw:insert-attribute("db-num", if buf_tt-oss-ref.db-num = ? then "" else string(buf_tt-oss-ref.db-num)).                           */
/*        p-i-hw:insert-attribute("classif-subject", if buf_tt-oss-ref.classif-subject = ? then "" else string(buf_tt-oss-ref.classif-subject)).*/
        p-i-hw:insert-attribute("oper-code", if buf_tt-oss-ref.oper-code = ? then "" else string(buf_tt-oss-ref.oper-code)).
        p-i-hw:insert-attribute("oper-abbrev", if buf_tt-oss-ref.oper-abbrev = ? then "" else string(buf_tt-oss-ref.oper-abbrev)).
        p-i-hw:insert-attribute("gds-group-in-cass", if buf_tt-oss-ref.gds-group-in-cass = ? then "" else string(buf_tt-oss-ref.gds-group-in-cass)).
        p-i-hw:insert-attribute("oper-name", if buf_tt-oss-ref.oper-name = ? then "" else string(buf_tt-oss-ref.oper-name)).
        p-i-hw:insert-attribute("min-digit-nums", if buf_tt-oss-ref.min-digit-nums = ? then "" else string(buf_tt-oss-ref.min-digit-nums)).
        p-i-hw:insert-attribute("max-digit-nums", if buf_tt-oss-ref.max-digit-nums = ? then "" else string(buf_tt-oss-ref.max-digit-nums)).
        p-i-hw:insert-attribute("min-sum", if buf_tt-oss-ref.min-sum = ? then "" else string(buf_tt-oss-ref.min-sum)).
        p-i-hw:insert-attribute("max-sum", if buf_tt-oss-ref.max-sum = ? then "" else string(buf_tt-oss-ref.max-sum)).
        p-i-hw:insert-attribute("warning-lim-sum", if buf_tt-oss-ref.warning-lim-sum = ? then "" else string(buf_tt-oss-ref.warning-lim-sum)).
        p-i-hw:insert-attribute("type-comission", if buf_tt-oss-ref.type-comission = ? then "" else string(buf_tt-oss-ref.type-comission)).
        p-i-hw:insert-attribute("comission-pcnt", if buf_tt-oss-ref.comission-pcnt = ? then "" else string(buf_tt-oss-ref.comission-pcnt)).
        p-i-hw:insert-attribute("comission-sum", if buf_tt-oss-ref.comission-sum = ? then "" else string(buf_tt-oss-ref.comission-sum)).
        p-i-hw:insert-attribute("necessary-authorization", if buf_tt-oss-ref.necessary-authorization = ? then "" else string(buf_tt-oss-ref.necessary-authorization)).
        p-i-hw:insert-attribute("necessary-slip", if buf_tt-oss-ref.necessary-slip = ? then "" else string(buf_tt-oss-ref.necessary-slip)).
        p-i-hw:insert-attribute("slip-file", if buf_tt-oss-ref.slip-file = ? then "" else string(buf_tt-oss-ref.slip-file)).
        p-i-hw:insert-attribute("billing-type", if buf_tt-oss-ref.billing-type = ? then "" else string(buf_tt-oss-ref.billing-type)).
        p-i-hw:end-element("line").
    end.

    p-i-hw:end-element("card").
    p-i-hw:end-element("rep").

    p-i-hw:end-document().

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fnc-cur-time-print) = 0 &THEN
		
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnc-cur-time-print Dialog-Frame
function fnc-cur-time-print returns character: 

    /* возвращает текущую дату и время печати */
    /* длина строки 33 символа */

    define variable v-date as date no-undo.
    define variable v-time as integer no-undo.

    run proc-cur-time(output v-date, output v-time).

    return "Дата печати: " + string(v-date, "99.99.9999":U) + ", " + string(v-time, "HH:MM":U).

end function.
	
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


*/