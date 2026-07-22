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

Выбор колонок для отчета "Оборотная ведомость по всем типам"

Автор: Чернова Светлана Александровна
Дата создания: 08/30/01
Author: Svetlana Chernova
Creation date: 08/30/01

*/
define input parameter  p-filter as character no-undo.
define output parameter print-o  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор колонок для отчета Оборотная ведомость по всем типам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/r-page1.i  }
{ cmp/showinf.i  }
&scop max-col 28
&Scop List-2-t TOG-1,TOG-17, TOG-2, TOG-18 ,TOG-3, TOG-19, TOG-4, TOG-20, ~
TOG-5, TOG-21, TOG-22, TOG-6, TOG-7, TOG-8, TOG-9, TOG-10, TOG-11, TOG-12, TOG-13, ~
TOG-14, TOG-15, TOG-16 ,TOG-23, TOG-24, TOG-25, TOG-26, TOG-27, TOG-28


define variable  col-size  as integer no-undo .
define variable  s-column  as integer EXTENT   {&max-col}  no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-save B-mark B-unmark B-Help ~
RECT-10 RECT-11 RECT-12 RECT-13 RECT-14 RECT-15 RECT-17 RECT-9 TOG-1 TOG-17 ~
TOG-2 TOG-18 TOG-3 TOG-19 TOG-4 TOG-20 TOG-5 TOG-21 TOG-22 TOG-6 TOG-23 ~
TOG-7 TOG-24 TOG-8 TOG-9 TOG-25 TOG-10 TOG-11 TOG-27 TOG-12 TOG-13 TOG-14 ~
TOG-15 TOG-16 only-text-exel TOG-28 A-3 FILL-IN-17 FILL-IN-6 FILL-IN-18 ~
FILL-IN-7 FILL-IN-19 FILL-IN-15 FILL-IN-20 FILL-IN-16 FILL-IN-21 FILL-IN-8 ~
FILL-IN-22 FILL-IN-1 FILL-IN-9 FILL-IN-28 FILL-IN-10 FILL-IN-29 FILL-IN-11 ~
FILL-IN-30 FILL-IN-12 FILL-IN-31 FILL-IN-13 FILL-IN-32 FILL-IN-14 FILL-IN-2 ~
FILL-IN-3 FILL-IN-4 FILL-IN-27 FILL-IN-5 F-col-size FILL-IN-33 a3 a4-lansc ~
only-file A4-port
&Scoped-Define DISPLAYED-OBJECTS TOG-1 TOG-17 TOG-2 TOG-18 TOG-3 TOG-19 ~
TOG-4 TOG-20 TOG-5 TOG-21 TOG-22 TOG-6 TOG-23 TOG-7 TOG-24 TOG-8 TOG-9 ~
TOG-25 TOG-10 TOG-11 TOG-27 TOG-12 TOG-13 TOG-14 TOG-15 TOG-16 ~
only-text-exel TOG-28 FILL-IN-17 FILL-IN-6 FILL-IN-18 FILL-IN-7 FILL-IN-19 ~
FILL-IN-15 FILL-IN-20 FILL-IN-16 FILL-IN-21 FILL-IN-8 FILL-IN-22 FILL-IN-1 ~
FILL-IN-9 FILL-IN-28 FILL-IN-10 FILL-IN-29 FILL-IN-11 FILL-IN-30 FILL-IN-12 ~
FILL-IN-31 FILL-IN-13 FILL-IN-32 FILL-IN-14 FILL-IN-2 FILL-IN-3 FILL-IN-4 ~
FILL-IN-27 FILL-IN-5 F-col-size FILL-IN-33 a3 a4-lansc only-file A4-port

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 FILL-IN-17 FILL-IN-6 FILL-IN-18 FILL-IN-7 FILL-IN-19 ~
FILL-IN-15 FILL-IN-20 FILL-IN-16 FILL-IN-21 FILL-IN-8 FILL-IN-22 FILL-IN-1 ~
FILL-IN-9 FILL-IN-28 FILL-IN-10 FILL-IN-29 FILL-IN-11 FILL-IN-30 FILL-IN-12 ~
FILL-IN-31 FILL-IN-13 FILL-IN-32 FILL-IN-14 FILL-IN-2 FILL-IN-3 FILL-IN-4 ~
FILL-IN-5 FILL-IN-33
&Scoped-define List-2 TOG-1 TOG-17 TOG-2 TOG-18 TOG-3 TOG-19 TOG-4 TOG-20 ~
TOG-5 TOG-21 TOG-22 TOG-6 TOG-23 TOG-7 TOG-24 TOG-8 TOG-9 TOG-25 TOG-10 ~
TOG-26 TOG-11 TOG-27 TOG-12 TOG-13 TOG-14 TOG-15 TOG-16 TOG-28
&Scoped-define List-4 RECT-13 A4-port
&Scoped-define List-5 RECT-14 a4-lansc
&Scoped-define List-6 RECT-15 a3

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON A-3
     LABEL "A3"
     SIZE 4.25 BY 1.13.

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "Отметить *"
     SIZE 12 BY 1 TOOLTIP "Выбрать все колонки"
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-unmark
     LABEL "Снять *"
     SIZE 12 BY 1 TOOLTIP "Снять все отметки"
     BGCOLOR 8 .

DEFINE VARIABLE only-text-exel AS CHARACTER INITIAL "На экране возможно отобразить только 320 символов. Полная информация возможна при выводе в Excel"
     VIEW-AS EDITOR NO-BOX
     SIZE 27.38 BY 2.83
     FGCOLOR 12 FONT 4 NO-UNDO.

DEFINE VARIABLE a3 AS CHARACTER FORMAT "X(256)":C6 INITIAL "A3"
      VIEW-AS TEXT
     SIZE 5.38 BY .58
     BGCOLOR 15 FGCOLOR 9 FONT 4 NO-UNDO.

DEFINE VARIABLE a4-lansc AS CHARACTER FORMAT "X(256)" INITIAL "A4"
      VIEW-AS TEXT
     SIZE 3.5 BY .96
     BGCOLOR 15 FGCOLOR 9 FONT 4 NO-UNDO.

DEFINE VARIABLE A4-port AS CHARACTER FORMAT "X(256)" INITIAL "A4"
      VIEW-AS TEXT
     SIZE 2.38 BY .58
     BGCOLOR 15 FGCOLOR 9 FONT 4 NO-UNDO.

DEFINE VARIABLE F-col-size AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Остаток на начало"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-10 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот приход перемещение"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-11 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот приход производство"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-12 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот расход внешний"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-13 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот расход перемещение"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-14 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот расход производство"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-15 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот инвентаризация"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-16 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот переоценка"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-17 AS CHARACTER FORMAT "X(256)":U INITIAL "Код"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-18 AS CHARACTER FORMAT "X(256)":U INITIAL "Артикул"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-19 AS CHARACTER FORMAT "X(256)":U INITIAL "Название товара"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот списание"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-20 AS CHARACTER FORMAT "X(256)":U INITIAL "Ед.изм"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-21 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип данных"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-22 AS CHARACTER FORMAT "X(256)":U INITIAL "Остаток на конец"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-27 AS CHARACTER FORMAT "X(256)" INITIAL "  Формат вывода на печать  "
      VIEW-AS TEXT
     SIZE 27.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-28 AS CHARACTER FORMAT "X(256)":U INITIAL "Эффективность"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-29 AS CHARACTER FORMAT "X(256)":U INITIAL "% наценки"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот касса продажа"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-30 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-31 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-32 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-33 AS CHARACTER FORMAT "X(256)":U INITIAL "Нумерация строк"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот касса возврат"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот возврат внешний"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот возврат поставщику"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот возврат перемещение"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "Скидка"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-9 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот приход внешний"
      VIEW-AS TEXT
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE only-file AS CHARACTER FORMAT "X(256)" INITIAL "  вывод в файл  "
      VIEW-AS TEXT
     SIZE 16 BY .67
     BGCOLOR 15 FGCOLOR 9  NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 10 BY 19.71.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 78.75 BY 18.58.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 10.25 BY 19.67.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 3.75 BY 1.75
     BGCOLOR 15 .

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 5.25 BY 1.25
     BGCOLOR 15 .

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 7.5 BY 1.75
     BGCOLOR 15 .

DEFINE RECTANGLE RECT-17
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 26.88 BY 2.75.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 78.75 BY 19.71.

DEFINE VARIABLE TOG-1 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-10 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-11 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-12 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-13 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-14 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-15 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-16 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-17 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-18 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-19 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-2 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-20 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-21 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-22 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-23 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-24 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-25 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-26 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-27 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-28 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-3 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-4 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-5 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-6 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-7 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-8 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-9 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL   2.25
     B-Cancel AT ROW 1 COL 14.25
          B-mark AT ROW 1 COL 26.25
     B-unmark AT ROW 1 COL 38.13
     B-Help AT ROW 1 COL 68.25
     TOG-1 AT ROW 4.5 COL 35.13 RIGHT-ALIGNED
     TOG-17 AT ROW 4.58 COL 74.5 RIGHT-ALIGNED
     TOG-2 AT ROW 5.5 COL 35.13 RIGHT-ALIGNED
     TOG-18 AT ROW 5.58 COL 74.5 RIGHT-ALIGNED
     TOG-3 AT ROW 6.5 COL 35.13 RIGHT-ALIGNED
     TOG-19 AT ROW 6.58 COL 74.5 RIGHT-ALIGNED
     TOG-4 AT ROW 7.5 COL 35.13 RIGHT-ALIGNED
     TOG-20 AT ROW 7.58 COL 74.5 RIGHT-ALIGNED
     TOG-5 AT ROW 8.5 COL 35.13 RIGHT-ALIGNED
     TOG-21 AT ROW 8.58 COL 74.5 RIGHT-ALIGNED
     TOG-22 AT ROW 9.54 COL 74.5 RIGHT-ALIGNED
     TOG-6 AT ROW 9.63 COL 35.13 RIGHT-ALIGNED
     TOG-23 AT ROW 10.58 COL 74.5 RIGHT-ALIGNED
     TOG-7 AT ROW 10.63 COL 35.13 RIGHT-ALIGNED
     TOG-24 AT ROW 11.58 COL 74.5 RIGHT-ALIGNED
     TOG-8 AT ROW 11.63 COL 35.13 RIGHT-ALIGNED
     TOG-9 AT ROW 12.63 COL 35.13 RIGHT-ALIGNED
     TOG-25 AT ROW 12.67 COL 74.5 RIGHT-ALIGNED
     TOG-10 AT ROW 13.63 COL 35.13 RIGHT-ALIGNED
     TOG-26 AT ROW 13.67 COL 74.5 RIGHT-ALIGNED
     TOG-11 AT ROW 14.63 COL 35.13 RIGHT-ALIGNED
     TOG-27 AT ROW 14.71 COL 74.5 RIGHT-ALIGNED
     TOG-12 AT ROW 15.63 COL 35.13 RIGHT-ALIGNED
     TOG-13 AT ROW 16.63 COL 35.13 RIGHT-ALIGNED
     TOG-14 AT ROW 17.63 COL 35.13 RIGHT-ALIGNED
     TOG-15 AT ROW 18.63 COL 35.13 RIGHT-ALIGNED
     TOG-16 AT ROW 19.63 COL 35.13 RIGHT-ALIGNED
     only-text-exel AT ROW 19.67 COL 42.13 NO-LABEL
     TOG-28 AT ROW 20.63 COL 35.13 RIGHT-ALIGNED
     A-3 AT ROW 21.29 COL 64.63
     FILL-IN-17 AT ROW 4.46 COL 2 NO-LABEL
     FILL-IN-6 AT ROW 4.54 COL 41.38 NO-LABEL
     FILL-IN-18 AT ROW 5.46 COL 2 NO-LABEL
     FILL-IN-7 AT ROW 5.54 COL 41.38 NO-LABEL
     FILL-IN-19 AT ROW 6.46 COL 2 NO-LABEL
     FILL-IN-15 AT ROW 6.54 COL 41.38 NO-LABEL
     FILL-IN-20 AT ROW 7.46 COL 2 NO-LABEL
     FILL-IN-16 AT ROW 7.54 COL 41.38 NO-LABEL
     FILL-IN-21 AT ROW 8.46 COL 2 NO-LABEL
     FILL-IN-8 AT ROW 8.54 COL 41.38 NO-LABEL
     FILL-IN-22 AT ROW 9.54 COL 41.38 NO-LABEL
     FILL-IN-1 AT ROW 9.58 COL 2 NO-LABEL
     FILL-IN-9 AT ROW 10.58 COL 2 NO-LABEL
     FILL-IN-28 AT ROW 10.58 COL 41.38 NO-LABEL
     FILL-IN-10 AT ROW 11.58 COL 2 NO-LABEL
     FILL-IN-29 AT ROW 11.58 COL 41.38 NO-LABEL
     FILL-IN-11 AT ROW 12.58 COL 2 NO-LABEL
     FILL-IN-30 AT ROW 12.67 COL 41.5 NO-LABEL
     FILL-IN-12 AT ROW 13.58 COL 2 NO-LABEL
     FILL-IN-31 AT ROW 13.67 COL 41.5 NO-LABEL
     FILL-IN-13 AT ROW 14.58 COL 2 NO-LABEL
     FILL-IN-32 AT ROW 14.71 COL 41.25 NO-LABEL
     FILL-IN-14 AT ROW 15.58 COL 2 NO-LABEL
     FILL-IN-2 AT ROW 16.58 COL 2 NO-LABEL
     FILL-IN-3 AT ROW 17.58 COL 2 NO-LABEL
     FILL-IN-4 AT ROW 18.58 COL 2 NO-LABEL
     FILL-IN-27 AT ROW 19 COL 39.75 COLON-ALIGNED NO-LABEL
     FILL-IN-5 AT ROW 19.58 COL 2 NO-LABEL
     F-col-size AT ROW 19.67 COL 69.75 COLON-ALIGNED NO-LABEL
     FILL-IN-33 AT ROW 20.58 COL 2 NO-LABEL
     a3 AT ROW 20.63 COL 50.75 COLON-ALIGNED NO-LABEL
     a4-lansc AT ROW 20.67 COL 51.63 COLON-ALIGNED NO-LABEL
     only-file AT ROW 20.75 COL 45 COLON-ALIGNED NO-LABEL
     A4-port AT ROW 20.79 COL 52.25 COLON-ALIGNED NO-LABEL
     "Колонки отчета ~"Оборотная ведомость по всем типам документов~"":C79 VIEW-AS TEXT
          SIZE 78.25 BY 1 AT ROW 2.17 COL 2.25
          BGCOLOR 3 FGCOLOR 15
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     "Показать":C8 VIEW-AS TEXT
          SIZE 8.88 BY .67 AT ROW 3.58 COL 31.5
          FGCOLOR 4
     "Колонки":C28 VIEW-AS TEXT
          SIZE 27.38 BY .67 AT ROW 3.58 COL 41.75
          FGCOLOR 4
     "Колонки":C28 VIEW-AS TEXT
          SIZE 27.38 BY .67 AT ROW 3.58 COL 3
          FGCOLOR 4
     "Показать":C8 VIEW-AS TEXT
          SIZE 8.88 BY .67 AT ROW 3.58 COL 70.75
          FGCOLOR 4
     RECT-10 AT ROW 3.29 COL 30.88
     RECT-11 AT ROW 4.42 COL 1.63
     RECT-12 AT ROW 3.33 COL 70.13
     RECT-13 AT ROW 20.21 COL 53.5
     RECT-14 AT ROW 20.5 COL 53.13
     RECT-15 AT ROW 20.17 COL 52
     RECT-17 AT ROW 19.71 COL 42.25
     RECT-9 AT ROW 3.29 COL 1.63
     SPACE(0.24) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор колонок для печати"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.


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

/* SETTINGS FOR FILL-IN a3 IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN a4-lansc IN FRAME Dialog-Frame
   5                                                                    */
/* SETTINGS FOR FILL-IN A4-port IN FRAME Dialog-Frame
   4                                                                    */
ASSIGN
       B-unmark:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-10 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-11 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-12 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-13 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-14 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-15 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-16 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-17 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-18 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-19 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-20 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-21 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-22 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-28 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-29 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-30 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN
       FILL-IN-30:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "{&bef-TDEDT_Corr_Acc_Price-full}".

/* SETTINGS FOR FILL-IN FILL-IN-31 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN
       FILL-IN-31:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "{&bef-TDEDT_Chg_Purch_Code-full}".

/* SETTINGS FOR FILL-IN FILL-IN-32 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN
       FILL-IN-32:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "Расход-Возврат".

/* SETTINGS FOR FILL-IN FILL-IN-33 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-4 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-5 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-6 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-7 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-8 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-9 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN
       only-text-exel:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-13 IN FRAME Dialog-Frame
   4                                                                    */
/* SETTINGS FOR RECTANGLE RECT-14 IN FRAME Dialog-Frame
   5                                                                    */
/* SETTINGS FOR RECTANGLE RECT-15 IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-1 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-10 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-11 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-12 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-13 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-14 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-15 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-16 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-17 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-18 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-19 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-2 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-20 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-21 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-22 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-23 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-24 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-25 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-26 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-R 2                                       */
ASSIGN
       TOG-26:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX TOG-27 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-28 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-3 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-4 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-5 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-6 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-7 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-8 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-9 IN FRAME Dialog-Frame
   ALIGN-R 2                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор колонок для печати */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME A-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL A-3 Dialog-Frame
ON CHOOSE OF A-3 IN FRAME Dialog-Frame /* A3 */
DO:
  display
    {&list-6}
    with frame {&frame-name}.
  hide
    {&list-4}
    {&list-5}
    only-file
    in frame {&frame-name}.

  print-o = "A3-lansc":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* Отметить * */
DO:
Assign
   TOG-1:screen-value  in frame {&frame-name} = string( true )
   TOG-2:screen-value  in frame {&frame-name} = string( true )
   TOG-3:screen-value  in frame {&frame-name} = string( true )
   TOG-4:screen-value  in frame {&frame-name} = string( true )
   TOG-5:screen-value  in frame {&frame-name} = string( true )
   TOG-6:screen-value  in frame {&frame-name} = string( true )
   TOG-7:screen-value  in frame {&frame-name} = string( true )
   TOG-8:screen-value  in frame {&frame-name} = string( true )
   TOG-9:screen-value  in frame {&frame-name} = string( true )
   TOG-10:screen-value in frame {&frame-name} = string( true )
   TOG-11:screen-value in frame {&frame-name} = string( true )
   TOG-12:screen-value in frame {&frame-name} = string( true )
   TOG-13:screen-value in frame {&frame-name} = string( true )
   TOG-14:screen-value in frame {&frame-name} = string( true )
   TOG-15:screen-value in frame {&frame-name} = string( true )
   TOG-16:screen-value in frame {&frame-name} = string( true )
   TOG-17:screen-value in frame {&frame-name} = string( true )
   TOG-18:screen-value in frame {&frame-name} = string( true )
   TOG-19:screen-value in frame {&frame-name} = string( true )
   TOG-20:screen-value in frame {&frame-name} = string( true )
   TOG-21:screen-value in frame {&frame-name} = string( true )
   TOG-22:screen-value in frame {&frame-name} = string( true )
   TOG-23:screen-value in frame {&frame-name} = string( true )
   TOG-24:screen-value in frame {&frame-name} = string( true )
   TOG-25:screen-value in frame {&frame-name} = string( true )
   TOG-26:screen-value in frame {&frame-name} = string( false  )
   TOG-27:screen-value in frame {&frame-name} = string( true )
   TOG-28:screen-value in frame {&frame-name} = string( true )
  .
  /*
  Display
     only-text-exel
     with frame {&frame-name}.
  Hide
  only-file
  a-3
  {&list-4}
  {&list-5}
  {&list-6}
  in frame {&frame-name}.
  print-o = "to-file":U.
  */

   run Show-format .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:

define variable  l-ind as integer no-undo .
define buffer buf_usr-flt for ubflt.usr-flt  .

run eq-frame.

 find first buf_usr-flt exclusive-lock where
         buf_usr-flt.user-name    = g#userid and
         buf_usr-flt.call-point   = p-filter
         no-error .

  if not available  buf_usr-flt then  create buf_usr-flt.
  Assign
    buf_usr-flt.user-name    = g#userid
    buf_usr-flt.call-point   = p-filter
    buf_usr-flt.list_        = ""
    .
  repeat l-ind = 1 to {&max-col} :
      if   use-column[ l-ind ] =  true then
      buf_usr-flt.list_ = buf_usr-flt.list_  + string( l-ind ) + "," .
  End.
  buf_usr-flt.list_ = buf_usr-flt.list_  + string( "print-o=" + print-o ) + "," .


release buf_usr-flt no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка  release"
  view-as alert-box error
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-unmark Dialog-Frame
ON CHOOSE OF B-unmark IN FRAME Dialog-Frame /* Снять * */
DO:
  Assign
   TOG-1:screen-value  in frame {&frame-name} = string( false  )
   TOG-2:screen-value  in frame {&frame-name} = string( false  )
   TOG-3:screen-value  in frame {&frame-name} = string( false  )
   TOG-4:screen-value  in frame {&frame-name} = string( false  )
   TOG-5:screen-value  in frame {&frame-name} = string( false  )
   TOG-6:screen-value  in frame {&frame-name} = string( false  )
   TOG-7:screen-value  in frame {&frame-name} = string( false  )
   TOG-8:screen-value  in frame {&frame-name} = string( false  )
   TOG-9:screen-value  in frame {&frame-name} = string( false  )
   TOG-10:screen-value in frame {&frame-name} = string( false  )
   TOG-11:screen-value in frame {&frame-name} = string( false  )
   TOG-12:screen-value in frame {&frame-name} = string( false  )
   TOG-13:screen-value in frame {&frame-name} = string( false  )
   TOG-14:screen-value in frame {&frame-name} = string( false  )
   TOG-15:screen-value in frame {&frame-name} = string( false  )
   TOG-16:screen-value in frame {&frame-name} = string( false  )
   TOG-17:screen-value in frame {&frame-name} = string( false  )
   TOG-18:screen-value in frame {&frame-name} = string( false  )
   TOG-19:screen-value in frame {&frame-name} = string( false  )
   TOG-20:screen-value in frame {&frame-name} = string( false  )
   TOG-21:screen-value in frame {&frame-name} = string( false  )
   TOG-22:screen-value in frame {&frame-name} = string( false  )
   TOG-23:screen-value in frame {&frame-name} = string( false  )
   TOG-24:screen-value in frame {&frame-name} = string( false  )
   TOG-25:screen-value in frame {&frame-name} = string( false  )
   TOG-26:screen-value in frame {&frame-name} = string( false  )
   TOG-27:screen-value in frame {&frame-name} = string( false  )
   TOG-28:screen-value in frame {&frame-name} = string( false  )
  .

  Display
  {&list-4}
  with frame {&frame-name}.

  hide
  only-text-exel
  only-file
  {&list-5}
  {&list-6}
  in frame {&frame-name}.
  run Show-format .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RECT-9
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RECT-9 Dialog-Frame
ON MOUSE-SELECT-CLICK OF RECT-9 IN FRAME Dialog-Frame
DO:

END.

ON VALUE-CHANGED OF {&List-2-t}
    IN FRAME Dialog-Frame
DO:
  RUN Show-format.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
define variable   all-empty  as integer no-undo init 0 .
define variable   ii  as integer no-undo init 0 .
repeat ii = 1 to {&max-col} :
  if use-column[ii ] then all-empty  = all-empty + 1 .
End.
 if all-empty =0 then
    apply "CHOOSE" TO B-mark IN FRAME Dialog-Frame.
 Else
Assign
  TOG-1   = use-column[1 ]
  TOG-2   = use-column[2 ]
  TOG-3   = use-column[3 ]
  TOG-4   = use-column[4 ]
  TOG-5   = use-column[5 ]
  TOG-6   = use-column[6 ]
  TOG-7   = use-column[7 ]
  TOG-8   = use-column[8 ]
  TOG-9   = use-column[9 ]
  TOG-10  = use-column[10]
  TOG-11  = use-column[11]
  TOG-12  = use-column[12]
  TOG-13  = use-column[13]
  TOG-14  = use-column[14]
  TOG-15  = use-column[15]
  TOG-16  = use-column[16]
  TOG-17  = use-column[17]
  TOG-18  = use-column[18]
  TOG-19  = use-column[19]
  TOG-20  = use-column[20]
  TOG-21  = use-column[21]
  TOG-22  = use-column[22]
  TOG-23  = use-column[23]
  TOG-24  = use-column[24]
  TOG-25  = use-column[25]
  TOG-26  = use-column[26]
  TOG-27  = use-column[27]
  TOG-28  = use-column[28]
 .

  Assign
  s-column[1 ] =  9
  s-column[2 ] =  16
  s-column[3 ] =  ( IF p-filter = "r-ptrlot":U THEN 36 ELSE 38 )
  s-column[4 ] =  3
  s-column[5 ] =  9
  s-column[6 ] =  14
  s-column[7 ] =  14
  s-column[8 ] =  14
  s-column[9 ] =  14

  s-column[10] =  14
  s-column[11] =  14
  s-column[12] =  14
  s-column[13] =  14
  s-column[14] =  14
  s-column[15] =  14
  s-column[16] =  14
  s-column[17] =  14
  s-column[18] =  14
  s-column[19] =  14
  s-column[20] =  14
  s-column[21] =  14
  s-column[22] =  14
  s-column[23] =  14
  s-column[24] =  14
  s-column[25] =  14
  s-column[26] =  14
  s-column[27] =  14
  s-column[28] =  9
  .


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   FILL-IN-30 =  FILL-IN-30:PRIVATE-DATA IN FRAME Dialog-Frame.
   /*FILL-IN-31 =  FILL-IN-31:PRIVATE-DATA IN FRAME Dialog-Frame. */
   FILL-IN-32 =  FILL-IN-32:PRIVATE-DATA IN FRAME Dialog-Frame.

  RUN enable_UI.

  RUN Show-format.
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
  DISPLAY TOG-1 TOG-17 TOG-2 TOG-18 TOG-3 TOG-19 TOG-4 TOG-20 TOG-5 TOG-21
          TOG-22 TOG-6 TOG-23 TOG-7 TOG-24 TOG-8 TOG-9 TOG-25 TOG-10 TOG-11
          TOG-27 TOG-12 TOG-13 TOG-14 TOG-15 TOG-16 only-text-exel TOG-28
          FILL-IN-17 FILL-IN-6 FILL-IN-18 FILL-IN-7 FILL-IN-19 FILL-IN-15
          FILL-IN-20 FILL-IN-16 FILL-IN-21 FILL-IN-8 FILL-IN-22 FILL-IN-1
          FILL-IN-9 FILL-IN-28 FILL-IN-10 FILL-IN-29 FILL-IN-11 FILL-IN-30
          FILL-IN-12 FILL-IN-31 FILL-IN-13 FILL-IN-32 FILL-IN-14 FILL-IN-2
          FILL-IN-3 FILL-IN-4 FILL-IN-27 FILL-IN-5 F-col-size FILL-IN-33 a3
          a4-lansc only-file A4-port
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-save B-mark B-unmark B-Help RECT-10 RECT-11 RECT-12 RECT-13
         RECT-14 RECT-15 RECT-17 RECT-9 TOG-1 TOG-17 TOG-2 TOG-18 TOG-3 TOG-19
         TOG-4 TOG-20 TOG-5 TOG-21 TOG-22 TOG-6 TOG-23 TOG-7 TOG-24 TOG-8 TOG-9
         TOG-25 TOG-10 TOG-11 TOG-27 TOG-12 TOG-13 TOG-14 TOG-15 TOG-16
         only-text-exel TOG-28 A-3 FILL-IN-17 FILL-IN-6 FILL-IN-18 FILL-IN-7
         FILL-IN-19 FILL-IN-15 FILL-IN-20 FILL-IN-16 FILL-IN-21 FILL-IN-8
         FILL-IN-22 FILL-IN-1 FILL-IN-9 FILL-IN-28 FILL-IN-10 FILL-IN-29
         FILL-IN-11 FILL-IN-30 FILL-IN-12 FILL-IN-31 FILL-IN-13 FILL-IN-32
         FILL-IN-14 FILL-IN-2 FILL-IN-3 FILL-IN-4 FILL-IN-27 FILL-IN-5
         F-col-size FILL-IN-33 a3 a4-lansc only-file A4-port
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Petrol_UI Dialog-Frame
PROCEDURE Petrol_UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*
IF p-filter = "r-ptrlot":U THEN DO:
  assign
    tog-8  = false
    tog-9  = false
    tog-11 = false
    tog-12 = false
    tog-17 = false
    tog-18 = false
    tog-21 = false
    tog-23 = false
    tog-24 = false
    tog-25 = false
    tog-27 = false
  .
    disable  tog-8  tog-9  tog-11 tog-12 tog-17
             tog-18 tog-21 tog-23 tog-24 tog-25 tog-27
             fill-in-7
             fill-in-6
             fill-in-8
             fill-in-10
             fill-in-11
             fill-in-13
             fill-in-14
             fill-in-28
             fill-in-29
             fill-in-30
             fill-in-32
    with frame {&frame-name}.
    hide  tog-8  tog-9  tog-11 tog-12 tog-17
             tog-18 tog-21 tog-23 tog-24 tog-25 tog-27
             fill-in-7
             fill-in-6
             fill-in-8
             fill-in-10
             fill-in-11
             fill-in-13
             fill-in-14
             fill-in-28
             fill-in-29
             fill-in-30
             fill-in-32
    in frame {&frame-name}.
END.
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Show-format Dialog-Frame
PROCEDURE Show-format :
define variable  ij as integer no-undo .

run eq-frame.
col-size = 0.

repeat ij = 1 to {&max-col} :
 if use-column[ij] then col-size = col-size + s-column[ij] + 1 .
End.

 F-col-size:screen-value in frame {&frame-name} = string(col-size).

 F-col-size = string(col-size).
 Display F-col-size with frame {&frame-name}.

If col-size >= 0 and col-size <= 139 Then DO:
  Display
  {&list-4} a-3
     with frame {&frame-name}.
  Hide
  {&list-5}
  {&list-6}
  only-file
  only-text-exel
  in frame {&frame-name}.
  print-o = "A4-port":U.
End.

If col-size > 139 and col-size <= 198 Then DO:
  Display
  {&list-5} a-3
     with frame {&frame-name}.
  Hide
  {&list-4}
  {&list-6}
  only-file
  only-text-exel
  in frame {&frame-name}.
  print-o = "A4-lansc":U.
End.

If col-size > 198 and col-size <= 278 Then DO:
  Display
  {&list-6} a-3
     with frame {&frame-name}.
  Hide
  {&list-4}
  {&list-5}
  only-text-exel
  only-file
  in frame {&frame-name}.
  print-o = "A3-lansc":U.
End.


If col-size > 278 Then DO:
  Display
    only-file a-3
     with frame {&frame-name}.
  Hide
  {&list-4}
  {&list-5}
  {&list-6}
  only-text-exel
  in frame {&frame-name}.
  print-o = "to-file":U.
End.


If col-size > 320 Then DO:
  Display
     only-text-exel
     with frame {&frame-name}.
  Hide
  only-file
  a-3
  {&list-4}
  {&list-5}
  {&list-6}
  in frame {&frame-name}.
  print-o = "to-file":U.
End.

END PROCEDURE.

procedure eq-frame:
  Assign frame {&frame-name}  {&list-2} .
  /* run Petrol_UI in this-procedure . */
  Assign
  use-column[1 ] =  TOG-1
  use-column[2 ] =  TOG-2
  use-column[3 ] =  TOG-3
  use-column[4 ] =  TOG-4
  use-column[5 ] =  TOG-5
  use-column[6 ] =  TOG-6
  use-column[7 ] =  TOG-7
  use-column[8 ] =  TOG-8
  use-column[9 ] =  TOG-9
  use-column[10] =  TOG-10
  use-column[11] =  TOG-11
  use-column[12] =  TOG-12
  use-column[13] =  TOG-13
  use-column[14] =  TOG-14
  use-column[15] =  TOG-15
  use-column[16] =  TOG-16
  use-column[17] =  TOG-17
  use-column[18] =  TOG-18
  use-column[19] =  TOG-19
  use-column[20] =  TOG-20
  use-column[21] =  TOG-21
  use-column[22] =  TOG-22
  use-column[23] =  TOG-23
  use-column[24] =  TOG-24
  use-column[25] =  TOG-25
  use-column[26] =  TOG-26
  use-column[27] =  TOG-27
  use-column[28] =  TOG-28
  .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
