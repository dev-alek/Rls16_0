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

Выбор колонок для отчета "Детализированная оборотная ведомость По АПТЕКЕ"

Автор: Чернова Светлана Александровна
Дата создания: 02/11/10
Author: Svetlana Chernova
Creation date: 02/11/10


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter       p-type   as integer   no-undo . /* 0 - детал, 1 -дет с призн , 3 c партиями */
define input-output parameter prod-zen as logical no-undo .
define output parameter       print-o  as character no-undo .


/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Поля для расширенной оборотки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/rep-bt.i }

define variable parparentproc     as widget-handle no-undo.
assign parparentproc =  my-handle .

define variable g#userid as character no-undo .
run get-userid  in parparentproc ( output g#userid ).

&scop max-col 120

define variable col-size as integer no-undo .
define variable s-column  as integer EXTENT   {&max-col}  no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-quit B-exit B-mark B-unmark B-help TOG-97 ~
TOG-98 TOG-99 TOG-100 TOG-101 TOG-102 TOG-103 TOG-104 TOG-105 TOG-106 ~
TOG-107 TOG-108 TOG-109 TOG-110 TOG-111 TOG-112 TOG-113 TOG-114 TOG-115 ~
TOG-116 TOG-117 TOG-118 only-text-exel A-3 FILL-IN-97 FILL-IN-98 FILL-IN-99 ~
FILL-IN-100 FILL-IN-101 FILL-IN-102 FILL-IN-103 FILL-IN-104 FILL-IN-105 ~
FILL-IN-106 FILL-IN-107 FILL-IN-108 FILL-IN-109 FILL-IN-110 FILL-IN-111 ~
FILL-IN-112 FILL-IN-113 FILL-IN-114 FILL-IN-115 FILL-IN-116 FILL-IN-117 ~
FILL-IN-118 FILL-IN-51 F-col-size a3 A4-port a4-lansc only-file 
&Scoped-Define DISPLAYED-OBJECTS TOG-97 TOG-98 TOG-99 TOG-100 TOG-101 ~
TOG-102 TOG-103 TOG-104 TOG-105 TOG-106 TOG-107 TOG-108 TOG-109 TOG-110 ~
TOG-111 TOG-112 TOG-113 TOG-114 TOG-115 TOG-116 TOG-117 TOG-118 ~
only-text-exel FILL-IN-97 FILL-IN-98 FILL-IN-99 FILL-IN-100 FILL-IN-101 ~
FILL-IN-102 FILL-IN-103 FILL-IN-104 FILL-IN-105 FILL-IN-106 FILL-IN-107 ~
FILL-IN-108 FILL-IN-109 FILL-IN-110 FILL-IN-111 FILL-IN-112 FILL-IN-113 ~
FILL-IN-114 FILL-IN-115 FILL-IN-116 FILL-IN-117 FILL-IN-118 FILL-IN-51 ~
F-col-size a3 A4-port a4-lansc only-file 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-2 TOG-97 TOG-98 TOG-99 TOG-100 TOG-101 TOG-102 TOG-103 ~
TOG-104 TOG-105 TOG-106 TOG-107 TOG-108 TOG-109 TOG-110 TOG-111 TOG-112 ~
TOG-113 TOG-114 TOG-115 TOG-116 TOG-117 TOG-118 
&Scoped-define List-4 A4-port
&Scoped-define List-5 a4-lansc
&Scoped-define List-6 a3

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON A-3
     LABEL "A3"
     SIZE 4.25 BY 1.13.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "Ввод"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помощь"
     SIZE 10.38 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "Отметить *"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-unmark
     LABEL "Снять *"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE only-text-exel AS CHARACTER INITIAL "На экране возможно отобразить ограниченное число символов. Полная информация возможна при выводе в Excel"
     VIEW-AS EDITOR NO-BOX
     SIZE 27.38 BY 1.83
     FGCOLOR 12 FONT 4 NO-UNDO.

DEFINE VARIABLE a3 AS CHARACTER FORMAT "X(256)":C6 INITIAL "A3"
      VIEW-AS TEXT
     SIZE 8.13 BY 1.58
     BGCOLOR 15 FGCOLOR 9 FONT 4 NO-UNDO.

DEFINE VARIABLE a4-lansc AS CHARACTER FORMAT "X(256)" INITIAL "A4"
      VIEW-AS TEXT
     SIZE 5.38 BY .96
     BGCOLOR 15 FGCOLOR 9 FONT 4 NO-UNDO.

DEFINE VARIABLE A4-port AS CHARACTER FORMAT "X(256)" INITIAL "A4"
      VIEW-AS TEXT
     SIZE 3.13 BY 1.46
     BGCOLOR 15 FGCOLOR 9 FONT 4 NO-UNDO.

DEFINE VARIABLE F-col-size AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-100 AS CHARACTER FORMAT "X(256)":U INITIAL "НДС производителя, %"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-101 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена поставщика без НДС"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-102 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена поставщика с НДС"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-103 AS CHARACTER FORMAT "X(256)":U INITIAL "НДС поставщика, сумма"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-104 AS CHARACTER FORMAT "X(256)":U INITIAL "НДС поставщика, %"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-105 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер оптовой надбавки, сумма"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-106 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер оптовой надбавки, %"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-107 AS CHARACTER FORMAT "X(256)":U INITIAL "Розничная цена партии с НДС"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-108 AS CHARACTER FORMAT "X(256)":U INITIAL "Розничная цена без НДС"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-109 AS CHARACTER FORMAT "X(256)":U INITIAL "Сумма НДС"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-110 AS CHARACTER FORMAT "X(256)":U INITIAL "Ставка НДС, %"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-111 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер розничной надбавки (от цен без НДС), сумма" 
      VIEW-AS TEXT 
     SIZE 51.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-112 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер розничной надбавки (от цен без НДС), %" 
      VIEW-AS TEXT 
     SIZE 51.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-113 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер общей надбавки (от цен без НДС), сумма" 
      VIEW-AS TEXT 
     SIZE 51.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-114 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер общей надбавки (от цен без НДС), %" 
      VIEW-AS TEXT 
     SIZE 51.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-115 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер розничной надбавки (от цен с НДС), сумма" 
      VIEW-AS TEXT
     SIZE 51.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-116 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер розничной надбавки (от цен с НДС), %" 
      VIEW-AS TEXT
     SIZE 52 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-117 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер общей надбавки (от цен с НДС), сумма" 
      VIEW-AS TEXT
     SIZE 52 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-118 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер общей надбавки (от цен с НДС), %" 
      VIEW-AS TEXT
     SIZE 51.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-51 AS CHARACTER FORMAT "X(256)" INITIAL "  Формат вывода на печать  "
      VIEW-AS TEXT
     SIZE 27 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-97 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена производителя без НДС"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-98 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена производителя с НДС"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-99 AS CHARACTER FORMAT "X(256)":U INITIAL "НДС производителя, сумма"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE only-file AS CHARACTER FORMAT "X(256)" INITIAL "  вывод в файл  "
      VIEW-AS TEXT
     SIZE 16 BY .67
     BGCOLOR 15 FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE TOG-100 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-101 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-102 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-103 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-104 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-105 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-106 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-107 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-108 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-109 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-110 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-111 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-112 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-113 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-114 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-115 AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-116 AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-117 AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-118 AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-97 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-98 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE TOG-99 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME dialog-Frame
     B-quit AT ROW 1 COL 2.25
     B-exit AT ROW 1 COL 14.25
     B-mark AT ROW 1 COL 26.25
     B-unmark AT ROW 1 COL 38.13
     B-help AT ROW 1 COL 50.25
     TOG-97 AT ROW 2.75 COL 55.63 RIGHT-ALIGNED
     TOG-98 AT ROW 3.42 COL 55.63 RIGHT-ALIGNED WIDGET-ID 4
     TOG-99 AT ROW 4.29 COL 55.63 RIGHT-ALIGNED WIDGET-ID 18
     TOG-100 AT ROW 4.96 COL 55.63 RIGHT-ALIGNED WIDGET-ID 20
     TOG-101 AT ROW 5.96 COL 55.63 RIGHT-ALIGNED WIDGET-ID 24
     TOG-102 AT ROW 6.71 COL 55.63 RIGHT-ALIGNED WIDGET-ID 28
     TOG-103 AT ROW 7.79 COL 55.63 RIGHT-ALIGNED WIDGET-ID 32
     TOG-104 AT ROW 8.58 COL 55.63 RIGHT-ALIGNED WIDGET-ID 36
     TOG-105 AT ROW 9.63 COL 55.63 RIGHT-ALIGNED WIDGET-ID 40
     TOG-106 AT ROW 10.38 COL 55.63 RIGHT-ALIGNED WIDGET-ID 44
     TOG-107 AT ROW 11.33 COL 55.63 RIGHT-ALIGNED WIDGET-ID 48
     TOG-108 AT ROW 12.13 COL 55.63 RIGHT-ALIGNED WIDGET-ID 52
     TOG-109 AT ROW 13.08 COL 55.63 RIGHT-ALIGNED WIDGET-ID 56
     TOG-110 AT ROW 13.83 COL 55.63 RIGHT-ALIGNED WIDGET-ID 60
     TOG-111 AT ROW 14.75 COL 55.63 RIGHT-ALIGNED WIDGET-ID 66
     TOG-112 AT ROW 15.5 COL 55.63 RIGHT-ALIGNED WIDGET-ID 68
     TOG-113 AT ROW 16.5 COL 55.63 RIGHT-ALIGNED WIDGET-ID 74
     TOG-114 AT ROW 17.25 COL 55.63 RIGHT-ALIGNED WIDGET-ID 76
     TOG-115 AT ROW 18.25 COL 55.63 RIGHT-ALIGNED WIDGET-ID 102
     TOG-116 AT ROW 19 COL 55.63 RIGHT-ALIGNED WIDGET-ID 104
     TOG-117 AT ROW 20 COL 55.63 RIGHT-ALIGNED WIDGET-ID 106
     TOG-118 AT ROW 20.75 COL 55.63 RIGHT-ALIGNED WIDGET-ID 108
     only-text-exel AT ROW 22.92 COL 4.38 NO-LABEL
     A-3 AT ROW 24.54 COL 26.88
     FILL-IN-97 AT ROW 2.75 COL 1.5 NO-LABEL
     FILL-IN-98 AT ROW 3.38 COL 1.5 NO-LABEL WIDGET-ID 2
     FILL-IN-99 AT ROW 4.25 COL 1.5 NO-LABEL WIDGET-ID 14
     FILL-IN-100 AT ROW 4.88 COL 1.5 NO-LABEL WIDGET-ID 16
     FILL-IN-101 AT ROW 5.88 COL 1.5 NO-LABEL WIDGET-ID 22
     FILL-IN-102 AT ROW 6.63 COL 1.5 NO-LABEL WIDGET-ID 26
     FILL-IN-103 AT ROW 7.71 COL 1.5 NO-LABEL WIDGET-ID 30
     FILL-IN-104 AT ROW 8.5 COL 1.5 NO-LABEL WIDGET-ID 34
     FILL-IN-105 AT ROW 9.54 COL 1.5 NO-LABEL WIDGET-ID 38
     FILL-IN-106 AT ROW 10.29 COL 1.5 NO-LABEL WIDGET-ID 42
     FILL-IN-107 AT ROW 11.25 COL 1.5 NO-LABEL WIDGET-ID 46
     FILL-IN-108 AT ROW 12.04 COL 1.5 NO-LABEL WIDGET-ID 50
     FILL-IN-109 AT ROW 13 COL 1.5 NO-LABEL WIDGET-ID 54
     FILL-IN-110 AT ROW 13.75 COL 1.5 NO-LABEL WIDGET-ID 58
     FILL-IN-111 AT ROW 14.75 COL 1.5 NO-LABEL WIDGET-ID 62
     FILL-IN-112 AT ROW 15.5 COL 1.5 NO-LABEL WIDGET-ID 64
     FILL-IN-113 AT ROW 16.5 COL 1.5 NO-LABEL WIDGET-ID 70
     FILL-IN-114 AT ROW 17.25 COL 1.5 NO-LABEL WIDGET-ID 72
     FILL-IN-115 AT ROW 18.25 COL 1.5 NO-LABEL WIDGET-ID 94
     FILL-IN-116 AT ROW 19 COL 1.5 NO-LABEL WIDGET-ID 96
     FILL-IN-117 AT ROW 20 COL 1.5 NO-LABEL WIDGET-ID 98
     FILL-IN-118 AT ROW 20.75 COL 1.5 NO-LABEL WIDGET-ID 100
     FILL-IN-51 AT ROW 22 COL 4 NO-LABEL
     F-col-size AT ROW 22 COL 32 COLON-ALIGNED NO-LABEL
     a3 AT ROW 23.58 COL 12.5 COLON-ALIGNED NO-LABEL
     A4-port AT ROW 23.75 COL 15.38 COLON-ALIGNED NO-LABEL
     a4-lansc AT ROW 23.92 COL 13.88 COLON-ALIGNED NO-LABEL
     only-file AT ROW 24 COL 7.25 COLON-ALIGNED NO-LABEL
     "Показать":C8 VIEW-AS TEXT
          SIZE 8.88 BY .67 AT ROW 2 COL 51.5
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME dialog-Frame
     "Колонки":C28 VIEW-AS TEXT
          SIZE 27.38 BY .67 AT ROW 2.08 COL 2.25
          FGCOLOR 4
     SPACE(32.24) SKIP(23.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор колонок для печати партий по АПТЕКЕ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME dialog-Frame:SCROLLABLE       = FALSE
       FRAME dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       A-3:HIDDEN IN FRAME dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN a3 IN FRAME dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN a4-lansc IN FRAME dialog-Frame
   5                                                                    */
/* SETTINGS FOR FILL-IN A4-port IN FRAME dialog-Frame
   4                                                                    */
ASSIGN
       B-help:HIDDEN IN FRAME dialog-Frame           = TRUE.

ASSIGN
       B-unmark:HIDDEN IN FRAME dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-100 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-101 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-102 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-103 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-104 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-105 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-106 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-107 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-108 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-109 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-110 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-111 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-112 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-113 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-114 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-115 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-116 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-117 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-118 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-51 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-97 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-98 IN FRAME dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-99 IN FRAME dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       only-text-exel:READ-ONLY IN FRAME dialog-Frame        = TRUE.

/* SETTINGS FOR TOGGLE-BOX TOG-100 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-101 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-102 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-103 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-104 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-105 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-106 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-107 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-108 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-109 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-110 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-111 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-112 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-113 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-114 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-115 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-116 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-117 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-118 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-97 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-98 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* SETTINGS FOR TOGGLE-BOX TOG-99 IN FRAME dialog-Frame
   ALIGN-R 2                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL dialog-Frame dialog-Frame
ON WINDOW-CLOSE OF FRAME dialog-Frame /* Выбор колонок для печати партий по АПТЕКЕ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME A-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL A-3 dialog-Frame
ON CHOOSE OF A-3 IN FRAME dialog-Frame /* A3 */
DO:
  Display {&list-6}  with frame {&frame-name}.
  Hide  {&list-4}  {&list-5}  only-file  in frame {&frame-name}.
  print-o = "A3-lansc":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit dialog-Frame
ON CHOOSE OF B-exit IN FRAME dialog-Frame /* Ввод */
DO:
  define variable l-ind as integer no-undo .
  run eq-frame.

 find first ubflt.usr-flt exclusive-lock
   where ubflt.usr-flt.user-name  = g#userid
     and ubflt.usr-flt.call-point = "e-obort3":U
   no-error .

    if not available ubflt.usr-flt then do:
      create ubflt.usr-flt.
      assign
      ubflt.usr-flt.user-name = g#userid
      ubflt.usr-flt.call-point   = "e-obort3":u
      ubflt.usr-flt.list_ = "" .
    end.

   repeat l-ind = 97 to {&max-col} :
     if   use-column[ l-ind ] =  true then ubflt.usr-flt.list_ = ubflt.usr-flt.list_  + string( l-ind ) + "," .
   End.
   ubflt.usr-flt.list_ = ubflt.usr-flt.list_  + string( "print-o=" + print-o ) + ",prod-zen=" + string( prod-zen ) + "," .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark dialog-Frame
ON CHOOSE OF B-mark IN FRAME dialog-Frame /* Отметить * */
DO:
  Assign
     TOG-97:screen-value  in frame {&frame-name} = string( true )
     TOG-98:screen-value  in frame {&frame-name} = string( true )
     TOG-99:screen-value  in frame {&frame-name} = string( true )
    TOG-100:screen-value  in frame {&frame-name} = string( true )
    TOG-101:screen-value  in frame {&frame-name} = string( true )
    TOG-102:screen-value  in frame {&frame-name} = string( true )
    TOG-103:screen-value  in frame {&frame-name} = string( true )
    TOG-104:screen-value  in frame {&frame-name} = string( true )
    TOG-105:screen-value  in frame {&frame-name} = string( true )
    TOG-106:screen-value  in frame {&frame-name} = string( true )
    TOG-107:screen-value  in frame {&frame-name} = string( true )
    TOG-108:screen-value  in frame {&frame-name} = string( true )
    TOG-109:screen-value  in frame {&frame-name} = string( true )
    TOG-110:screen-value  in frame {&frame-name} = string( true )
    TOG-111:screen-value  in frame {&frame-name} = string( true )
    TOG-112:screen-value  in frame {&frame-name} = string( true )
    TOG-113:screen-value  in frame {&frame-name} = string( true )
    TOG-114:screen-value  in frame {&frame-name} = string( true )
    TOG-115:screen-value  in frame {&frame-name} = string( true )
    TOG-116:screen-value  in frame {&frame-name} = string( true )
    TOG-117:screen-value  in frame {&frame-name} = string( true )
    TOG-118:screen-value  in frame {&frame-name} = string( true )
    .
  Assign
     TOG-97 =  true
     TOG-98 =  true
     TOG-99 =  true
    TOG-100 =  true
    TOG-101 =  true
    TOG-102 =  true
    TOG-103 =  true
    TOG-104 =  true
    TOG-105 =  true
    TOG-106 =  true
    TOG-107 =  true
    TOG-108 =  true
    TOG-109 =  true
    TOG-110 =  true
    TOG-111 =  true
    TOG-112 =  true
    TOG-113 =  true
    TOG-114 =  true
    TOG-115 =  true
    TOG-116 =  true
    TOG-117 =  true
    TOG-118 =  true

  .

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

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-unmark dialog-Frame
ON CHOOSE OF B-unmark IN FRAME dialog-Frame /* Снять * */
DO:
  Assign
    TOG-97:screen-value  in frame {&frame-name} = string( false  )
    TOG-98:screen-value  in frame {&frame-name} = string( false  )
    TOG-99:screen-value  in frame {&frame-name} = string( false  )
    TOG-100:screen-value  in frame {&frame-name} = string( false )
    TOG-101:screen-value  in frame {&frame-name} = string( false )
    TOG-102:screen-value  in frame {&frame-name} = string( false )
    TOG-103:screen-value  in frame {&frame-name} = string( false )
    TOG-104:screen-value  in frame {&frame-name} = string( false )
    TOG-105:screen-value  in frame {&frame-name} = string( false )
    TOG-106:screen-value  in frame {&frame-name} = string( false )
    TOG-107:screen-value  in frame {&frame-name} = string( false )
    TOG-108:screen-value  in frame {&frame-name} = string( false )
    TOG-109:screen-value  in frame {&frame-name} = string( false )
    TOG-110:screen-value  in frame {&frame-name} = string( false )
    TOG-111:screen-value  in frame {&frame-name} = string( false )
    TOG-112:screen-value  in frame {&frame-name} = string( false )
    TOG-113:screen-value  in frame {&frame-name} = string( false )
    TOG-114:screen-value  in frame {&frame-name} = string( false )
    TOG-115:screen-value  in frame {&frame-name} = string( false )
    TOG-116:screen-value  in frame {&frame-name} = string( false )
    TOG-117:screen-value  in frame {&frame-name} = string( false )
    TOG-118:screen-value  in frame {&frame-name} = string( false )

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
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK dialog-Frame 


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
define variable  all-empty  as integer no-undo init 0 .
define variable  ii  as integer no-undo init 0 .

 find first ubflt.usr-flt no-lock
   where ubflt.usr-flt.user-name  = g#userid
     and ubflt.usr-flt.call-point = "e-obort3":U
   no-error .
 if NOT available ubflt.usr-flt then do:
    create ubflt.usr-flt.
    Assign
      ubflt.usr-flt.user-name = g#userid
      ubflt.usr-flt.call-point   = "e-obort3":U
      ubflt.usr-flt.list_ = "" .
 end.

  repeat ii = 97 to {&max-col} :
    use-column[ii] = false  .
    all-empty = 0.
  end.
  repeat ii = 97 to {&max-col} :
    if lookup( string(ii)  , ubflt.usr-flt.list_ ) > 0 then  do:
      use-column[ii] = true .
    end.
    if use-column[ii] then all-empty  = all-empty + 1 .
  end.


 if all-empty =0 then do:
    apply "CHOOSE" TO B-mark IN FRAME {&frame-name}.
 end.
 Else
 Assign
    TOG-97 = use-column[97]
    TOG-98 = use-column[98]
    TOG-99 = use-column[99]
    TOG-100 = use-column[100]
    TOG-101 = use-column[101]
    TOG-102 = use-column[102]
    TOG-103 = use-column[103]
    TOG-104 = use-column[104]
    TOG-105 = use-column[105]
    TOG-106 = use-column[106]
    TOG-107 = use-column[107]
    TOG-108 = use-column[108]
    TOG-109 = use-column[109]
    TOG-110 = use-column[110]
    TOG-111 = use-column[111]
    TOG-112 = use-column[112]
    TOG-113 = use-column[113]
    TOG-114 = use-column[114]
    TOG-115 = use-column[115]
    TOG-116 = use-column[116]
    TOG-117 = use-column[117]
    TOG-118 = use-column[118]
  .

  display
    TOG-97
    TOG-98
    TOG-99
    TOG-100
    TOG-101
    TOG-102
    TOG-103
    TOG-104
    TOG-105
    TOG-106
    TOG-107
    TOG-108
    TOG-109
    TOG-110
    TOG-111
    TOG-112
    TOG-113
    TOG-114
    TOG-115
    TOG-116
    TOG-117
    TOG-118
    with frame {&frame-name}
  .


  Assign
    s-column[1 ] =  9
    s-column[2 ] =  16
    s-column[3 ] =  38
    s-column[4 ] =  3
    s-column[5 ] =  10
    s-column[6 ] =  10
    s-column[7 ] =  10
    s-column[8 ] =  10
    s-column[9 ] =  10
    s-column[10] =  14
    s-column[11] =  10
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
    s-column[28] =  14
    s-column[29] =  14
    s-column[30] =  14
    s-column[31] =  14
    s-column[32] =  14
    s-column[33] =  14
    s-column[34] =  14
    s-column[35] =  14
    s-column[36] =  14
    s-column[37] =  14
    s-column[38] =  14
    s-column[39] =  14
    s-column[40] =  14
    s-column[41] =  14
    s-column[42] =  14
    s-column[43] =  14
    s-column[44] =  14
    s-column[45] =  14
    s-column[46] =  14
    s-column[47] =  14
    s-column[48] =  14
    s-column[49] =  14
    s-column[50] =  14
    s-column[51] =  14
    s-column[52] =  14
    s-column[53] =  14
    s-column[54] =  14
    s-column[55] =  14
    s-column[56] =  14
    s-column[57] =  14
    s-column[58] =  14
    s-column[59] =  14
    s-column[60] =  14
    s-column[61] =  14
    s-column[62] =  14
    s-column[63] =  14
    s-column[64] =  14
    s-column[65] =  14
    s-column[66] =  14
    s-column[67] =  14
    s-column[68] =  14
    s-column[69] =  14
    s-column[70] =  14
    s-column[71] =  14
    s-column[72] =  14
    s-column[73] =  14
    s-column[74] =  14
    s-column[75] =  14
    s-column[76] =  14
    s-column[77] =  14
    s-column[78] =  14
    s-column[79] =  14
    s-column[80] =  14
    s-column[81] =  14
    s-column[82] =  14
    s-column[83] =  14
    s-column[84] =  14
    s-column[85] =  14
    s-column[86] =  14
    s-column[87] =  14
    s-column[88] =  14
    s-column[89] =  14
    s-column[90] =  14
    s-column[91] =  14
    s-column[92] =  14
    s-column[93] =  14
    s-column[94] =  14
    s-column[95] =  14
    s-column[96] =  14
    s-column[97] =  14
    s-column[98] =  14
    s-column[99] =  14
    s-column[100] =  14
    s-column[101] =  14
    s-column[102] =  14
    s-column[103] =  14
    s-column[104] =  14
    s-column[105] =  14
    s-column[106] =  14
    s-column[107] =  14
    s-column[108] =  14
    s-column[109] =  14
    s-column[110] =  14
    s-column[111] =  14
    s-column[112] =  14
    s-column[113] =  14
    s-column[114] =  14
    s-column[115] =  14
    s-column[116] =  14
    s-column[117] =  14
    s-column[118] =  14
/*    s-column[119] =  14*/
/*    s-column[120] =  14*/
  .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  define variable Log-Res1 as logical   no-undo .
  define variable Log-Res2 as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-cost':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    yes
    Log-Res1
  }
  if not Log-Res1 then do:

  end.

/* 'actn_document-reports-sale_print':U*/

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-crsa':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    yes
    Log-Res2
  }
  if not Log-Res2 then do:

  end.




  enable  tog-97 tog-98 tog-99 tog-100
     TOG-101
     TOG-102
     TOG-103
     TOG-104
     TOG-105
     TOG-106
     TOG-107
     TOG-108
     TOG-109
     TOG-110
     TOG-111
     TOG-112
     TOG-113
     TOG-114
     TOG-115
     TOG-116
     TOG-117
     TOG-118
  with frame {&frame-name}.

  display  tog-97 tog-98 tog-99 tog-100
     TOG-101
     TOG-102
     TOG-103
     TOG-104
     TOG-105
     TOG-106
     TOG-107
     TOG-108
     TOG-109
     TOG-110
     TOG-111
     TOG-112
     TOG-113
     TOG-114
     TOG-115
     TOG-116
     TOG-117
     TOG-118
  with frame {&frame-name}.

  RUN Show-format.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY TOG-97 TOG-98 TOG-99 TOG-100 TOG-101 TOG-102 TOG-103 TOG-104 TOG-105
          TOG-106 TOG-107 TOG-108 TOG-109 TOG-110 TOG-111 TOG-112 TOG-113
          TOG-114 TOG-115 TOG-116 TOG-117 TOG-118 only-text-exel FILL-IN-97 
          FILL-IN-98 FILL-IN-99 FILL-IN-100 FILL-IN-101 FILL-IN-102 FILL-IN-103 
          FILL-IN-104 FILL-IN-105 FILL-IN-106 FILL-IN-107 FILL-IN-108 
          FILL-IN-109 FILL-IN-110 FILL-IN-111 FILL-IN-112 FILL-IN-113 
          FILL-IN-114 FILL-IN-115 FILL-IN-116 FILL-IN-117 FILL-IN-118 FILL-IN-51 
          F-col-size a3 A4-port a4-lansc only-file 
      WITH FRAME dialog-Frame.
  ENABLE B-quit B-exit B-mark B-unmark B-help TOG-97 TOG-98 TOG-99 TOG-100
         TOG-101 TOG-102 TOG-103 TOG-104 TOG-105 TOG-106 TOG-107 TOG-108
         TOG-109 TOG-110 TOG-111 TOG-112 TOG-113 TOG-114 TOG-115 TOG-116 
         TOG-117 TOG-118 only-text-exel A-3 FILL-IN-97 FILL-IN-98 FILL-IN-99 
         FILL-IN-100 FILL-IN-101 FILL-IN-102 FILL-IN-103 FILL-IN-104 
         FILL-IN-105 FILL-IN-106 FILL-IN-107 FILL-IN-108 FILL-IN-109 
         FILL-IN-110 FILL-IN-111 FILL-IN-112 FILL-IN-113 FILL-IN-114 
         FILL-IN-115 FILL-IN-116 FILL-IN-117 FILL-IN-118 FILL-IN-51 F-col-size 
         a3 A4-port a4-lansc only-file 
      WITH FRAME dialog-Frame.
  VIEW FRAME dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Show-format dialog-Frame 
PROCEDURE Show-format :
define variable ij as integer no-undo .
  run eq-frame.
  col-size = 0.

  repeat ij = 1 to {&max-col} :
    if use-column[ij] then col-size = col-size + s-column[ij] + 1 .
  End.

  F-col-size:screen-value in frame {&frame-name} = string( col-size).
  F-col-size = string(col-size).
  Display F-col-size with frame {&frame-name}.

  If col-size >= 1 and col-size <= 136 Then DO:
    Display {&list-4} a-3  with frame {&frame-name}.
    Hide {&list-5} {&list-6} only-file only-text-exel in frame {&frame-name}.
    print-o = "A4-port":U.
  End.

  If col-size > 136 and col-size <= 198 Then DO:
    Display  {&list-5} a-3  with frame {&frame-name}.
    Hide {&list-4} {&list-6} only-file only-text-exel in frame {&frame-name}.
    print-o = "A4-lansc":U.
  End.

  If col-size > 198 and col-size <= 235 Then DO:
    Display {&list-6} a-3  with frame {&frame-name}.
    Hide {&list-4} {&list-5} only-text-exel  only-file in frame {&frame-name}.
    print-o = "A3-lansc":U.
  End.

  If col-size > 235 Then DO:
    Display only-file a-3 with frame {&frame-name}.
    Hide {&list-4} {&list-5} {&list-6} only-text-exel in frame {&frame-name}.
    print-o = "to-file":U.
  End.

  If col-size > 550 Then DO:
    Display  only-text-exel  with frame {&frame-name}.
    Hide only-file a-3 {&list-4} {&list-5} {&list-6} in frame {&frame-name}.
    print-o = "to-file":U.
  End.

END PROCEDURE.

procedure eq-frame:
  Assign frame {&frame-name}  {&list-2} .

  Assign
    use-column[97]  =  TOG-97
    use-column[98]  =  TOG-98
    use-column[99]  =  TOG-99
    use-column[100] =  TOG-100
    use-column[101]  =  TOG-101
    use-column[102]  =  TOG-102
    use-column[103]  =  TOG-103
    use-column[104]  =  TOG-104
    use-column[105]  =  TOG-105
    use-column[106]  =  TOG-106
    use-column[107]  =  TOG-107
    use-column[108]  =  TOG-108
    use-column[109]  =  TOG-109
    use-column[110]  =  TOG-110
    use-column[111]  =  TOG-111
    use-column[112]  =  TOG-112
    use-column[113]  =  TOG-113
    use-column[114]  =  TOG-114
    use-column[115]  =  TOG-115
    use-column[116]  =  TOG-116
    use-column[117]  =  TOG-117
    use-column[118]  =  TOG-118


  .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

