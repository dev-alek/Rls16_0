&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_Filter FOR ubflt.filter.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование фильтров

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

/* ***************************  Definitions  ************************** */


/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter  c-point     as character no-undo .
define input-output parameter  p-naim       as character no-undo.
define input parameter  p-save-in-filter as logical no-undo .
define input parameter  p-enable-sorting as logical no-undo .
define input parameter  p-save-to-file   as logical no-undo .
define input parameter  p-enable-name-changing as logical no-undo .
define input parameter  list-tabls  as character no-undo .
define input parameter  list-buf    as character no-undo .
define input parameter  list-fields as character no-undo .
define input parameter  list-labels as character no-undo .
define input parameter  list-spr    as character no-undo .
define input parameter  list-dim    as character no-undo .
define input-output parameter p-where-ysl as character no-undo .
define input-output parameter p-where-ysl-rus as character no-undo .
define input-output parameter p-fields-sort as character no-undo .
define input-output parameter p-fields-sort-rus as character no-undo .
define input-output parameter p-lst-cend  as character no-undo .
define input parameter  kl          as integer   no-undo .
define output parameter ident       as recid     no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование фильтров".
{ cmp/vssrevis.i substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,c-point,list-tabls,list-buf,list-fields,list-labels,list-spr,list-dim,kl)"}
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-shar.i }
{ trg/factord.i  }
{ cmp/yearofst.i }


def new shared var undo_ as logical initial no.

define variable select3 AS CHARACTER INITIAL "" no-undo.

/* Local Variable Definitions ---                                       */
define variable lst-fld as char no-undo.
define variable lst-type as char no-undo.
define variable lst-lab as char no-undo.
define variable lst-lab-delim as char no-undo.
define variable lst-wordidx as char no-undo.

define variable kriteria as character no-undo.
define variable kriteria_rus as character no-undo.
define variable MethodReturn AS LOGICAL no-undo.
define variable und AS LOGICAL INITIAL yes no-undo.
define variable ii AS INTEGER no-undo.
define variable jj AS INTEGER no-undo.
define variable kk AS INTEGER no-undo.
define variable ll AS INTEGER no-undo.
define variable id AS RECID no-undo.
define variable v-str AS CHARACTER no-undo.
define variable str_rus AS CHARACTER no-undo.
define variable znak AS CHARACTER no-undo.
define variable znak_rus AS CHARACTER no-undo.
define variable join_ as character no-undo.
define variable join_r as character no-undo.
define variable join-tbl AS CHARACTER INITIAL " AND " no-undo.
define variable join_rus AS CHARACTER INITIAL "  И " no-undo.
define variable not-tbl AS CHARACTER INITIAL "" no-undo.
define variable not_rus AS CHARACTER INITIAL "" no-undo.
define variable join_list AS CHARACTER no-undo.
define variable join_list_rus AS CHARACTER no-undo.
define variable cur_x AS INTEGER INITIAL 1 no-undo.
define variable cur_y AS INTEGER INITIAL 1 no-undo.
define variable cur_pos AS INTEGER INITIAL 1 no-undo.
define variable x AS INTEGER no-undo.
define variable y AS INTEGER no-undo.
define variable chr1 AS CHARACTER no-undo.
define variable chr2 AS CHARACTER no-undo.
define variable date1 AS DATE no-undo format "99/99/9999".
define variable date2 AS DATE no-undo format "99/99/9999".
define variable dt AS DATE no-undo format "99/99/9999".
define variable int1 AS INTEGER no-undo.
define variable int2 AS INTEGER no-undo.
define variable dec1 AS DECIMAL no-undo.
define variable dec2 AS DECIMAL no-undo.
define variable list-descend AS CHARACTER INITIAL '' no-undo.
define variable data-type LIKE _DATA-TYPE no-undo.
define variable file-name LIKE _FILE-NAME no-undo.
define variable field-name LIKE _FIELD-NAME no-undo.

define variable fld-name   as character no-undo .
define variable fld-lab    as character no-undo .
define variable table-name as character no-undo .

define variable v-ind-idx        as integer   no-undo .
define variable v-ind-fld        as integer   no-undo .
define variable v-inform         as character no-undo .
define variable v-idx-field-qnty as integer   no-undo .


define variable file-name_field-name as character no-undo .

define variable lab LIKE _LABEL no-undo.
define variable spr as char no-undo.
define variable spr_ as char no-undo.
define variable lab-delim as char no-undo.
define variable fld-delim as char no-undo.
define variable wordidx as char no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help RECT-1 f-Naim ~
rs-sorting B-addfield SELECT-1 SELECT-2 btn-EQ btn-NE SELECT-3 btn-Begins ~
btn-Matches btn-LT btn-GT btn-List btn-Range btn-LE btn-GE btn-contains ~
btn-del SELECT-9 N_NOT AND-OR SELECT-8
&Scoped-Define DISPLAYED-OBJECTS f-Naim rs-sorting FILL-IN-1 FILL-IN-3 ~
FILL-IN-4 FILL-IN-2 SELECT-9 N_NOT SELECT-8

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-addfield
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Сформировать критерий по  выбранному полю".

DEFINE BUTTON b-down
     LABEL "Вни&з":L
     SIZE 8.75 BY 1.17 TOOLTIP "Понизить порядок выбранного поля".

DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "&Ввод":L
     SIZE 10 BY 1 TOOLTIP "Сохранить сформированный фильтр"
     BGCOLOR 8 .

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 10.5 BY 1.17
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Выход без изменений"
     BGCOLOR 8 .

DEFINE BUTTON b-up
     LABEL "Ввер&х":L
     SIZE 8.75 BY 1.17 TOOLTIP "Повысить порядок выбранного поля".

DEFINE BUTTON btn-add
     LABEL "&Добавить":L
     SIZE 8.5 BY 1.25 TOOLTIP "Добавить поле в список сортируемых полей".

DEFINE BUTTON btn-Begins
     LABEL "&Начиная":L
     SIZE 10 BY 1.17 TOOLTIP "Ввести начальные символы добавляемого поля".

DEFINE BUTTON btn-contains
     LABEL "Содер&жит":L
     SIZE 9.5 BY 1.17 TOOLTIP "Ввести символы, содержащиеся в добавляемом поле".

DEFINE BUTTON btn-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить ранее сформированный критерий".

DEFINE BUTTON btn-EQ
     LABEL "=":L
     SIZE 5 BY 1.17 TOOLTIP "Ввести условие равенства значению"
     BGCOLOR 8 .

DEFINE BUTTON btn-GE
     LABEL ">=":L
     SIZE 5 BY 1.17 TOOLTIP "Ввести значение, начиная с которого произведется отбор".

DEFINE BUTTON btn-GT
     LABEL ">":L
     SIZE 5 BY 1.17 TOOLTIP "Ввести значение, после которого произведется отбор".

DEFINE BUTTON btn-LE
     LABEL "<=":L
     SIZE 5 BY 1.17 TOOLTIP "Ввести значение, до которого включительно произведется отбор".

DEFINE BUTTON btn-List
     LABEL "С&писок":L
     SIZE 9.75 BY 1.17 TOOLTIP "Ввести возможные варианты содержимого добавляемого поля".

DEFINE BUTTON btn-LT
     LABEL "<":L
     SIZE 5 BY 1.17 TOOLTIP "Ввести значение, до которого произведется отбор".

DEFINE BUTTON btn-Matches
     LABEL "В&ключая":L
     SIZE 9.75 BY 1.17 TOOLTIP "Ввести символы, содержащиеся в добавляемом поле".

DEFINE BUTTON btn-NE
     LABEL "<>":L
     SIZE 5 BY 1.17 TOOLTIP "Ввести условие неравенства значению".

DEFINE BUTTON btn-Range
     LABEL "&Границы":L
     SIZE 9.75 BY 1.17 TOOLTIP "Ввести границы отбора добавляемого поля".

DEFINE BUTTON btn-remove
     LABEL "У&брать":L
     SIZE 8.75 BY 1.17 TOOLTIP "Убрать поле из списка сортируемых полей".

DEFINE BUTTON btn-UNDO
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Отменить формирование критерия".

DEFINE VARIABLE f-Naim AS CHARACTER FORMAT "X(255)"
     LABEL "Имя фильтра"
     VIEW-AS FILL-IN
     SIZE 59.5 BY 1 TOOLTIP "Введите имя создаваемого фильтра"
     BGCOLOR 15 .

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 27 BY 1
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 65 BY 1
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 28 BY 1
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 27 BY 1
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE AND-OR AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&И", 1,
"И&ЛИ", 2
     SIZE 28 BY .75 NO-UNDO.

DEFINE VARIABLE rs-asc-desc AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Воз&растающая", 0,
"Уб&ывающая", 1
     SIZE 28.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-sorting AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Фильтр", 1,
"Сор&тировка", 2
     SIZE 74.75 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 75.5 BY 2
     BGCOLOR 8 FGCOLOR 8 .

DEFINE VARIABLE SELECT-1 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE
     SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 27 BY 6
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE SELECT-2 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE
     SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 28 BY 11
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE SELECT-3 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE
     SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 27 BY 11
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE SELECT-8 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE
     SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE SELECT-9 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE
     SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 65 BY 3.75
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE N_NOT AS LOGICAL INITIAL no
     LABEL "НЕТ":L
     VIEW-AS TOGGLE-BOX
     SIZE 9.5 BY 1.17
     BGCOLOR 8 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 66
     f-Naim AT ROW 2.75 COL 3
     rs-sorting AT ROW 4.5 COL 2 NO-LABEL
     B-addfield AT ROW 5.54 COL 37
     FILL-IN-1 AT ROW 5.75 COL 1.5 NO-LABEL
     FILL-IN-3 AT ROW 5.75 COL 2 COLON-ALIGNED NO-LABEL
     FILL-IN-4 AT ROW 5.75 COL 46 COLON-ALIGNED NO-LABEL
     SELECT-1 AT ROW 6.75 COL 1.5 NO-LABEL
     SELECT-2 AT ROW 6.75 COL 4 NO-LABEL
     btn-EQ AT ROW 6.75 COL 37
     btn-NE AT ROW 6.75 COL 43
     SELECT-3 AT ROW 6.75 COL 48 NO-LABEL
     btn-Begins AT ROW 7.25 COL 51
     btn-Matches AT ROW 7.25 COL 62.5
     btn-add AT ROW 8.25 COL 34.5
     btn-LT AT ROW 8.25 COL 37
     btn-GT AT ROW 8.25 COL 43
     btn-List AT ROW 8.75 COL 51
     btn-Range AT ROW 8.75 COL 62.5
     btn-remove AT ROW 9.5 COL 34.5
     btn-LE AT ROW 9.75 COL 37
     btn-GE AT ROW 9.75 COL 43
     btn-contains AT ROW 10.25 COL 57
     btn-del AT ROW 11.17 COL 37
     btn-UNDO AT ROW 11.17 COL 47
     b-up AT ROW 11.75 COL 34.5
     FILL-IN-2 AT ROW 13 COL 2 NO-LABEL
     b-down AT ROW 13 COL 34.5
     SELECT-9 AT ROW 14 COL 2 NO-LABEL
     N_NOT AT ROW 17.79 COL 34
     AND-OR AT ROW 18 COL 4 NO-LABEL
     rs-asc-desc AT ROW 18 COL 48 NO-LABEL
     SELECT-8 AT ROW 19.08 COL 67 NO-LABEL
     RECT-1 AT ROW 2.25 COL 1
     SPACE(0.99) SKIP(15.83)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "":L
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: locked_Filter B "?" ? ub ubflt.filter
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
                                                                        */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR RADIO-SET AND-OR IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-down IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-up IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON btn-add IN FRAME DIALOG-1
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR BUTTON btn-Begins IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-del IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-EQ IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-GE IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-GT IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-LE IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-List IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-LT IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-Matches IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-NE IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-Range IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-remove IN FRAME DIALOG-1
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR BUTTON btn-UNDO IN FRAME DIALOG-1
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN f-Naim IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-4 IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET rs-asc-desc IN FRAME DIALOG-1
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR SELECTION-LIST SELECT-1 IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR SELECTION-LIST SELECT-2 IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR SELECTION-LIST SELECT-3 IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX DIALOG-1
/* Query rebuild information for DIALOG-BOX DIALOG-1
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX DIALOG-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME AND-OR
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL AND-OR DIALOG-1
ON VALUE-CHANGED OF AND-OR IN FRAME DIALOG-1
DO:
  ASSIGN and-or N_NOT.
  CASE and-or
  :
    WHEN 1
    THEN DO:
            join-tbl = " AND " + not-tbl.
            join_rus = "  И  " + not_rus.
    END.
    WHEN 2
    THEN DO:
            join-tbl = " OR " + not-tbl.
            join_rus = "ИЛИ " + not_rus.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-addfield
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-addfield DIALOG-1
ON CHOOSE OF B-addfield IN FRAME DIALOG-1 /* Добавить */
DO:
/*
  APPLY "ENTRY" to select-1.
  ASSIGN select-1 = Select-1:screen-value.
  */
  APPLY "VALUE-CHANGED" to select-1.

  APPLY "MOUSE-SELECT-DBLCLICK" TO SELECT-1.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down DIALOG-1
ON CHOOSE OF b-down IN FRAME DIALOG-1 /* Вниз */
DO:
  assign select-3.
  if select-3 = ? then return no-apply.
  ll = select-3:lookup(select-3).
  if ll = select-3:num-items then return.
  v-str = substring (list-descend, ll * 2 - 1,1).
  substring (list-descend, ll * 2 - 1, 1) = substring (list-descend, (ll + 1) * 2 - 1, 1).
  substring (list-descend, (ll + 1) * 2 - 1,1) = v-str.

  v-str = entry(ll + 1,select3).
  substring (Select3, index(Select3, entry(ll + 1, select3)), length(entry(ll + 1,Select3))) =
                                                                                                         entry(ll, select3).
  substring (Select3, index(Select3, entry(ll, select3)), length(entry(ll, Select3))) = v-str.

  v-str = entry(ll + 1,select-3:list-items).
  methodreturn = select-3:replace(select-3,entry(ll + 1,select-3:list-items)).
  methodreturn = select-3:replace(v-str,select-3).
  assign select-3:screen-value = select-3.
  if select-3:lookup(select-3) = 1 then disable b-up with frame {&frame-name}.
                                                   else enable b-up with frame {&frame-name}.
  if select-3:lookup(select-3) = select-3:num-items then disable b-down with frame {&frame-name}.
                                                   else enable b-down with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit DIALOG-1
ON CHOOSE OF b-exit IN FRAME DIALOG-1 /* Ввод */
DO:
  if p-save-in-filter
  and
  ((can-find(ubflt.filter where ubflt.filter.call-point = c-point
        and ubflt.filter.naim = input frame {&frame-name} f-naim) and new(locked_filter))
  or
        input frame {&frame-name} f-naim = "")
  then do:
    if input frame {&frame-name} f-naim = ""
    then do:
            message "Пустое имя фильтра недопустимо".
    end.
    else do:
      message "Фильтр с таким именем уже сущестует".
    end.
    apply "entry" to f-naim.
    return no-apply.
  end.
  if p-save-in-filter then do:
    id = recid(locked_filter).
    flt-rec = recid(locked_filter).
    IDENT = RECID(locked_Filter).
    locked_Filter.naim = input frame {&frame-name} f-naim.
    locked_Filter.call-point = c-point.
    locked_Filter.Tbl = List-Tabls.
    locked_Filter.Flds = List-Fields.
    locked_Filter.Where-ysl = select-8:list-items.
    locked_Filter.Where-ysl-rus = select-9:list-items.
    locked_Filter.Fields-sort = SELECT3.
    locked_Filter.Fields-sort-rus = SELECT-3:list-items.
    locked_Filter.lst-cend = list-descend.
  end.
  else do:
    assign
    ident = 0
    .
  end.
  assign
  p-naim = input frame {&frame-name} f-naim
  p-Where-ysl = select-8:list-items
  p-Where-ysl-rus = select-9:list-items
  p-Fields-sort = SELECT3
  p-Fields-sort-rus = SELECT-3:list-items
  p-lst-cend = list-descend
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up DIALOG-1
ON CHOOSE OF b-up IN FRAME DIALOG-1 /* Вверх */
DO:
  assign select-3.
  if select-3 = ? then return no-apply.
  ll = select-3:lookup(select-3).
  if ll = 1 then return no-apply.
  v-str = substring (list-descend,(ll - 1) * 2 - 1,1).
  substring (list-descend, (ll - 1) * 2 - 1,1) = substring (list-descend, ll * 2 - 1,1).
  substring (list-descend, ll * 2 - 1,1) = v-str.

  v-str = entry(ll, select3).
  substring (Select3, index(Select3, entry(ll, select3)),length(entry(ll, Select3))) =
                                                                                       entry(ll - 1, select3).
  substring (Select3, index(Select3, entry(ll - 1,select3)),length(entry(ll - 1, Select3))) = v-str.

  methodreturn = select-3:replace(entry(ll - 1, select-3:list-items), select-3).
  methodreturn = select-3:replace(select-3, entry(ll - 1, select-3:list-items)).
  assign select-3:screen-value = select-3.
  if select-3:lookup(select-3) = 1 then disable b-up with frame {&frame-name}.
                                                   else enable b-up with frame {&frame-name}.
  if select-3:lookup(select-3) = select-3:num-items then disable b-down with frame {&frame-name}.
                                                   else enable b-down with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-add DIALOG-1
ON CHOOSE OF btn-add IN FRAME DIALOG-1 /* Добавить */
DO:
  ASSIGN SELECT-2.
  ASSIGN SELECT-3.
  if select-2 = ? then return no-apply.
  kk = LOOKUP(Select-2, lst-lab).
  data-type = entry(kk, lst-type).
  lab = entry(kk, lst-lab).
  MethodReturn = SELECT-3:ADD-LAST(lab).
  MethodReturn = SELECT-2:DELETE(SELECT-2).
  IF select3 = ""
  THEN DO:
          select3 = select3 + entry(kk, lst-fld).
          list-descend = "0".
  END.
  ELSE DO:
          select3 = select3 + ',' + entry(kk, lst-fld).
          list-descend = list-descend + ",0".
  END.
  assign select-2.
  if select-2:num-items = 0 then disable btn-add with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-Begins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-Begins DIALOG-1
ON CHOOSE OF btn-Begins IN FRAME DIALOG-1 /* Начиная */
DO:
do on error undo, leave:
znak = "BEGINS".
znak_rus = "нач. с".
RUN arifm.
end.
spr_ = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-contains
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-contains DIALOG-1
ON CHOOSE OF btn-contains IN FRAME DIALOG-1 /* Содержит */
DO:
do on error undo, return:
znak = "CONTAINS".
znak_rus = "contains".
RUN arifm.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-del DIALOG-1
ON CHOOSE OF btn-del IN FRAME DIALOG-1 /* Удалить */
DO:
assign select-8 select-9.
  cur_pos = select-9:lookup(select-9).
  if cur_pos > 0
  then do:
     MethodReturn=select-8:DELETE(cur_pos).
     MethodReturn=select-9:DELETE(cur_pos).
     IF cur_pos = 1
     and select-9:num-items > 0
     THEN DO:
       MethodReturn=
        select-8:replace(substring(select-8:entry(1),5,length(select-8:entry(1)) - 4),select-8:entry(1)).
       MethodReturn=
        select-9:replace(substring(select-9:entry(1),5,length(select-9:entry(1)) - 4),select-9:entry(1)).
     end.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-EQ
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-EQ DIALOG-1
ON CHOOSE OF btn-EQ IN FRAME DIALOG-1 /* = */
DO:
do on error undo, return:
znak = "=".
znak_rus = "=".
RUN arifm.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-GE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-GE DIALOG-1
ON CHOOSE OF btn-GE IN FRAME DIALOG-1 /* >= */
DO:
do on error undo, return:
znak = ">=".
znak_rus = ">=".
RUN arifm.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-GT
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-GT DIALOG-1
ON CHOOSE OF btn-GT IN FRAME DIALOG-1 /* > */
DO:
do on error undo, return:
znak = ">".
znak_rus = ">".
RUN arifm.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-LE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-LE DIALOG-1
ON CHOOSE OF btn-LE IN FRAME DIALOG-1 /* <= */
DO:
do on error undo, return:
znak = "<=".
znak_rus = "<=".
RUN arifm.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-List DIALOG-1
ON CHOOSE OF btn-List IN FRAME DIALOG-1 /* Список */
DO:
do on error undo, return:
RUN LST.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-LT
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-LT DIALOG-1
ON CHOOSE OF btn-LT IN FRAME DIALOG-1 /* < */
DO:
do on error undo, return:
znak = "<".
znak_rus = "<".
RUN arifm.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-Matches
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-Matches DIALOG-1
ON CHOOSE OF btn-Matches IN FRAME DIALOG-1 /* Включая */
DO:
do on error undo, return:
znak = "MATCHES".
znak_rus = "включ.".
RUN arifm.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-NE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-NE DIALOG-1
ON CHOOSE OF btn-NE IN FRAME DIALOG-1 /* <> */
DO:
do on error undo, return:
znak = "<>".
znak_rus = "<>".
RUN arifm.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-Range
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-Range DIALOG-1
ON CHOOSE OF btn-Range IN FRAME DIALOG-1 /* Границы */
DO:
do on error undo, return:
  RUN bound.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-remove
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-remove DIALOG-1
ON CHOOSE OF btn-remove IN FRAME DIALOG-1 /* Убрать */
DO:
  ASSIGN SELECT-2.
  ASSIGN SELECT-3.

  if select-3 = ?
  then do:
    return no-apply.
  end.

  kk = LOOKUP(Select-3,lst-lab).
  data-type = entry(kk, lst-type).
  lab = entry(kk, lst-lab).

  M1:
  DO:
    DO ll = 1 TO SELECT-2:NUM-ITEMS
    :
      assign
        jj = LOOKUP(SELECT-2:ENTRY(ll), lst-lab)
      .
      IF kk < jj
      THEN DO:
        assign
          MethodReturn = SELECT-2:INSERT(SELECT-3, SELECT-2:ENTRY(ll))
        .
        LEAVE m1.
      END.
    END.
    IF SELECT-2:NUM-ITEMS = 0
    then do:
          MethodReturn = SELECT-2:ADD-FIRST(SELECT-3).
    end.
    else do:
      MethodReturn = SELECT-2:ADD-LAST(SELECT-3).
    end.
  END.
  MethodReturn = SELECT-3:DELETE(SELECT-3).

  v-str = entry(kk, lst-fld).
  if  LOOKUP(v-Str,Select3) * 2 - 1 = 1 then ii = 0. else ii = 1.
  SUBSTRING (list-descend,LOOKUP(v-Str,Select3) * 2 - 1 - ii, 2) = "".
  SUBSTRING (Select3,INDEX(Select3,v-str) - ii,
             LENGTH(ENTRY(LOOKUP(v-Str,Select3),Select3)) + 1) = "".

  assign select-3.
  if select-3:num-items = 0 then disable btn-remove with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-UNDO
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-UNDO DIALOG-1
ON CHOOSE OF btn-UNDO IN FRAME DIALOG-1 /* Отмена */
DO:
assign select-8 select-9.
  if select-8:num-items > 0
  then do:
     MethodReturn=select-8:DELETE(select-8:num-items).
     MethodReturn=select-9:DELETE(select-9:num-items).
     end.
  DISABLE btn-undo WITH FRAME {&frame-name}.
  RUN enable-select-where.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME N_NOT
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL N_NOT DIALOG-1
ON VALUE-CHANGED OF N_NOT IN FRAME DIALOG-1 /* НЕТ */
DO:
ASSIGN N_NOT.
if N_NOT then
assign
not-tbl = "NOT "
not_rus = "НЕТ ".
else
assign
not-tbl = ""
not_rus = "".
assign
join-tbl = join-tbl + not-tbl.
join_rus = join_rus + not_rus.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-asc-desc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-asc-desc DIALOG-1
ON VALUE-CHANGED OF rs-asc-desc IN FRAME DIALOG-1
DO:
  ASSIGN rs-asc-desc.
  ASSIGN SELECT-3.
  kk = LOOKUP(Select-3, lst-lab).
  v-str = entry(kk, lst-fld).
  SUBSTRING (list-descend,LOOKUP(v-Str,Select3) * 2 - 1 ,1) = STRING(rs-asc-desc).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-sorting
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-sorting DIALOG-1
ON VALUE-CHANGED OF rs-sorting IN FRAME DIALOG-1
DO:
assign rs-sorting.
case rs-sorting:
        when 1
        then do:
            assign
                fill-in-3:visible = no
                fill-in-4:visible = no
                select-2:visible = no
                select-3:visible = no
                btn-add:visible = no
                btn-remove:visible = no
                b-up:visible = no
                b-down:visible = no
                rs-asc-desc:visible = no
                fill-in-1:visible = yes
                select-1:visible = yes
                b-addfield:visible = yes
                btn-eq:visible = yes
                btn-ne:visible = yes
                btn-lt:visible = yes
                btn-gt:visible = yes
                btn-le:visible = yes
                btn-ge:visible = yes
                btn-begins:visible = yes
                btn-matches:visible = yes
                btn-contains:visible = yes
                btn-list:visible = yes
                btn-range:visible = yes
                fill-in-2:visible = yes
                select-9:visible = yes
                btn-del:visible = yes
                btn-undo:visible = yes
                and-or:visible = yes
                N_NOT:visible = yes.
                select-1:screen-value = ENTRY(1, sELECT-1:list-items).
        end.
        when 2 then
            assign
                fill-in-3:visible = yes
                fill-in-4:visible = yes
                select-2:visible = yes
                select-3:visible = yes
                btn-add:visible = yes
                btn-remove:visible = yes
                b-up:visible = yes
                b-down:visible = yes
                rs-asc-desc:visible = yes
                fill-in-1:visible = no
                select-1:visible = no
                b-addfield:visible = no
                btn-eq:visible = no
                btn-ne:visible = no
                btn-lt:visible = no
                btn-gt:visible = no
                btn-le:visible = no
                btn-ge:visible = no
                btn-begins:visible = no
                btn-matches:visible = no
                btn-contains:visible = no
                btn-list:visible = no
                btn-range:visible = no
                fill-in-2:visible = no
                select-9:visible = no
                btn-del:visible = no
                btn-undo:visible = no
                and-or:visible = no
                N_NOT:visible = no.
       end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SELECT-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SELECT-1 DIALOG-1
ON MOUSE-SELECT-DBLCLICK OF SELECT-1 IN FRAME DIALOG-1
DO:
kriteria = ''. kriteria_rus = ''.
  ASSIGN SELECT-1 select-8 select-9.
  if select-1 = ? then return no-apply.
  DISABLE SELECT-1 b-exit N_NOT WITH FRAME {&frame-name}.
  kk = LOOKUP(Select-1, Select-1:LIST-ITEMS).

/*  file-name =  entry(1,,'.').*/
/*  field-name = entry(2,entry(k,lst-fld),'.').*/
  assign
    file-name_field-name = entry(kk, lst-fld)
    data-type            = entry(kk, lst-type)
    fld-delim            = entry(kk, lst-fld)
    lab-delim            = entry(kk, lst-lab-delim)
    lab                  = entry(kk, lst-lab)
    spr                  = entry(kk, List-spr)
    wordidx              = entry(kk, lst-wordidx)
  .
  IF select-8:num-items > 0 THEN
  DO:
    assign
    kriteria     = join-tbl
    kriteria_rus = join_rus
    .
  END.
  if kriteria = ""
  then do:
    assign
    kriteria = not-tbl
    .
  end.
  if kriteria_rus = ""
  then do:
    assign
    kriteria_rus = not_rus
    .
  end.
  kriteria = kriteria + file-name_field-name + " ".
  kriteria_rus = kriteria_rus + lab + " ".
  MethodReturn=select-8:add-last(kriteria).
  MethodReturn=select-9:add-last(kriteria_rus).
  select-9:screen-value = ENTRY(NUM-ENTRIES(sELECT-9:list-items), sELECT-9:list-items).

  disable
  b-addfield
  btn-del
  with frame {&frame-name}.
  enable btn-undo WITH FRAME {&frame-name}.
  if lookup(spr, "trn-stat,trn-type,order-status-all,order-type-all,ext-doc-type,pr-stat,fbr-stat,gds-type,cli,gds,db,pay,curr,unit,prt,country,~
actions,tbl-name,fin-doc-stat,fin-doc-type,fin-ext-doc-type,~
gds-hist-subject,cli-hist-subject,hist-action,hist-source-type,~
contract-type,usl-opl,db-rec-attr-type,db-rec-attr-cmd,db,sht,usr,rcv-type-all,wth-ext-type,gop"
  ) > 0
  then do:
         ENABLE btn-EQ btn-NE btn-List
                    WITH FRAME {&frame-name}.
  end.
  else
  CASE DATA-TYPE
  :
    WHEN "INTEGER"
    OR WHEN "DATE"
    OR WHEN "DECIMAL"
    THEN do:
      ENABLE btn-EQ btn-NE btn-LT btn-GT btn-LE btn-GE
            btn-List btn-Range
                WITH FRAME {&frame-name}.
    end.
    WHEN "CHARACTER"
    THEN do:
      ENABLE btn-EQ btn-NE btn-LT btn-GT btn-LE btn-GE
            btn-BEGINS btn-MATCHES btn-List btn-Range
                WITH FRAME {&frame-name}.
      if wordidx = '1' then enable btn-contains with frame {&frame-name}.
    end.
    WHEN "LOGICAL"
    THEN do:
      ENABLE btn-EQ btn-NE
                WITH FRAME {&frame-name}.
    end.
    OTHERWISE do:
      ENABLE btn-EQ btn-NE btn-List
                WITH FRAME {&frame-name}.
    end.
  END CASE.
  if spr = "time":U
  or spr = "fact-order-d"
  then do:
    DISABLE btn-EQ btn-NE btn-list btn-range
    WITH FRAME {&frame-name}.
  end.
  if spr = 'usr' or
     spr = 'gop'
  then do:
    disable
      btn-list
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SELECT-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SELECT-2 DIALOG-1
ON MOUSE-SELECT-DBLCLICK OF SELECT-2 IN FRAME DIALOG-1
DO:
  assign select-2.
  if select-2 = ? then return no-apply.
  APPLY "CHOOSE" TO btn-add IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SELECT-2 DIALOG-1
ON VALUE-CHANGED OF SELECT-2 IN FRAME DIALOG-1
DO:
     assign select-2.
     enable btn-add with frame {&frame-name}.
     disable btn-remove b-up b-down with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SELECT-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SELECT-3 DIALOG-1
ON MOUSE-SELECT-DBLCLICK OF SELECT-3 IN FRAME DIALOG-1
DO:
  assign select-3.
  if select-3 = ? then return no-apply.
  APPLY "CHOOSE" TO btn-remove IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SELECT-3 DIALOG-1
ON VALUE-CHANGED OF SELECT-3 IN FRAME DIALOG-1
DO:
  ASSIGN SELECT-3.
  disable btn-add with frame {&frame-name}.
  enable btn-remove with frame {&frame-name}.
  if select-3:lookup(select-3) = 1 then disable b-up with frame {&frame-name}.
                                                   else enable b-up with frame {&frame-name}.
  if select-3:lookup(select-3) = select-3:num-items then disable b-down with frame {&frame-name}.
                                                   else enable b-down with frame {&frame-name}.
  kk = LOOKUP(Select-3, lst-lab).
  v-str = entry(kk, lst-fld).
  rs-asc-desc = INTEGER (ENTRY(LOOKUP(v-Str, Select3), list-descend)).
  disable rs-asc-desc WITH FRAME {&frame-name}.
  ENABLE rs-asc-desc WITH FRAME {&frame-name}.
  DISPLAY rs-asc-desc WITH FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */
ON ENTRY OF SELECT-2 , btn-add , btn-remove
DO:
     DISABLE rs-asc-desc WITH FRAME {&frame-name}.
END.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

ON alt-shift-F6 anywhere do:
  message
    v-str skip
    view-as alert-box information .
end.


/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
  fill-in-1 = 'Доступные поля'.
  fill-in-2 = 'Критерий выбора'.
  fill-in-3 = 'Доступные поля'.
  fill-in-4 = 'Выбранные поля'.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

define variable tt_h      as handle    no-undo .
define variable v-num-tbl as integer   no-undo .
define variable v-num-fld as integer   no-undo .

IF Kl <> 0
THEN DO:
   if p-save-in-filter then  do:
      FIND FIRST locked_Filter WHERE Num-flt = Kl.
      select-8:list-items = locked_Filter.Where-ysl.
      select-9:list-items = locked_Filter.Where-ysl-rus.
      select3 = locked_Filter.Fields-sort.
      list-descend = locked_Filter.lst-cend.
      f-naim = locked_filter.naim.
   end.
   else do:
    assign
    f-naim = p-naim
    select-8:list-items = p-Where-ysl
    select-9:list-items = p-Where-ysl-rus
    select3 = p-Fields-sort
    list-descend = p-lst-cend.
  end.
END.
ELSE DO:
   if p-save-in-filter then  do:
    CREATE locked_Filter.
    Kl = locked_filter.Num-flt.
   end.
   else do:
    assign
    f-naim = p-naim
    select-8:list-items = p-Where-ysl
    select-9:list-items = p-Where-ysl-rus
    select3 = p-Fields-sort
    list-descend = p-lst-cend
    .
  end.
END.
assign
  jj             = 0
  lst-fld       = ""
  lst-type      = ""
  lst-lab-delim = ""
  lst-wordidx   = ""
.

assign
  v-num-tbl = num-entries(List-Tabls)
.

list-tabls_block:
do ii = 1 to v-num-tbl
:
  assign
    table-name = entry(ii, List-Tabls)
  .
  list-dim_block:
  do kk = jj + 1 to jj + int(entry(ii, List-dim))
  :
    assign
      file-name = if entry(ii, List-Buf) <> "" then entry(ii, List-Buf) else table-name.
    .
    assign
      data-type  = ""
      field-name = ""
      lab        = ""
      wordidx    = '0'
    .
    if entry(kk, list-spr) begins "function_"
    then do:
      assign
        field-name = entry(kk, List-Fields)
        data-type  = entry(2, entry(kk, list-spr), '_')
        wordidx    = '0'
        lab        = entry(kk, List-Labels)
      .
      assign
        lst-lab-delim = lst-lab-delim + ',' + lab
      .
    end.
    else do:
      case entry( 1, table-name, "#":U ) :
        when "temp-handle":U then do:
          assign
            tt_h = handle( entry( 3, table-name, "#":U ) )
          .
        end.
        otherwise do:
          find first _File
            where _File-Name = table-name
            .
          assign
            id = recid(_File)
          .
        end.
      end case.
      assign
        v-num-fld = num-entries(entry(kk, List-Fields),'{&delim-flt}')
      .
      do ll = 1 to v-num-fld :

        assign
          fld-name   = entry(ll, entry(kk, List-Fields),'{&delim-flt}')
          field-name = field-name + '{&delim-flt}' + file-name + '.' + fld-name
        .
        case entry( 1, table-name, "#":U ) :
          when "temp-handle":U then do:
            if tt_h:buffer-field( fld-name ) = ? then do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестное поле" fld-name skip
                "Таблица" table-name
                view-as alert-box error .
              next list-dim_block .
            end.
            assign
              fld-lab = tt_h:buffer-field( fld-name ):label
            .
            if fld-lab = ?
              or fld-lab = fld-name
            then do:
              assign
                fld-lab = tt_h:buffer-field( fld-name ):column-label
              .
            end.

            assign
              data-type = data-type + '{&delim-flt}' + tt_h:buffer-field( fld-name ):data-type
              lab       = lab + '{&delim-flt}' + fld-lab
              v-ind-idx = 1
              v-inform  = "":U
            .
            block_dyn_idx:
            do while v-inform <> ? /* пройдемся по индексам */
            on error undo, return error
            :
              assign
                v-inform  = tt_h:index-information( v-ind-idx )
                v-ind-idx = v-ind-idx + 1
              .
              if entry( 4, v-inform, ",":U ) = "1":U
                and num-entries( v-inform ) - 4 >= 2
              then do:
                assign
                  v-idx-field-qnty = num-entries( v-inform ) - 4
                .
                do v-ind-fld = 1 to v-idx-field-qnty by 2
                on error undo, return error
                :
                  if entry( 4 + v-ind-fld, v-inform, ",":U ) = fld-name then do:
                    assign
                      wordidx = '1'
                    .
                    leave block_dyn_idx.
                  end.
                end.
              end.
            end.
          end.
          otherwise do:
            find _Field no-lock
              where _Field._Field-name =  fld-name
                and _Field._File-Recid = id
              no-error .
            if not available _Field
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестное поле" fld-name skip
                "Таблица" table-name
                view-as alert-box error .
              next list-dim_block .
            end.
            for each _index-field
              where _index-field._field-recid = recid(_field)
            ,each _index
              where recid(_index) = _index-field._index-recid
                and _wordidx = 1
            :
              wordidx = '1'.
              leave.
            end.

            assign
              data-type = data-type + '{&delim-flt}' + _data-type
            .

            if _label = ? then do:
              assign
                lab = lab + '{&delim-flt}' + '?'
              .
            end.
        else do:
          if current-language = "english"
          or current-language = "romanian"
          then do:
            if current-language = "english"
            then do:
              assign
                lab = lab + '{&delim-flt}' + (if entry(2, _field._desc, "`") <> ? then entry(2, _field._desc, "`") else '?')
              .
            end.
            else do:
              assign
                lab = lab + '{&delim-flt}' + (if entry(3, _field._desc, "`") <> ? then entry(3, _field._desc, "`") else '?')
              .
            end.
          end.
          else do:
            assign
              lab = lab + '{&delim-flt}' + (if _label <> ? then _label else '?')
            .
          end.
        end.
      end.
        end case.
      end.

      if v-num-fld > 1 then do:
        assign
          wordidx = '0'
        .
      end.
      assign
        substr(field-name, 1 ,1) = ""
        substr(data-type, 1 ,1)  = ""
        substr(lab, 1 ,1)        = ""
        lst-lab-delim = lst-lab-delim + ',' + lab
      .
    end.

    if entry(kk, List-Labels) <> ""
    then do:
      assign
        lab = entry(kk, List-Labels)
      .
    end.
    if lookup(lab, select-1:list-items) > 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        'Поля ' entry(lookup(lab,select-1:list-items) + 1, lst-fld)
        'и' field-name skip
        'имеют одну и туже метку - "' lab '"'
        view-as alert-box error .
      undo,return.
    end.

    assign
      lst-fld      = lst-fld + ',' + field-name
      lst-type     = lst-type + ',' + data-type
      lst-wordidx  = lst-wordidx + ',' + wordidx
      methodReturn = Select-1:add-last(lab)
      methodReturn = Select-2:add-last(lab)
    .
  end. /** do k **/
  jj = jj + int(entry(ii, List-dim)).
end. /** do i **/
lst-lab = select-1:list-items.
substr(lst-fld, 1 ,1) = "".
substr(lst-type, 1 ,1) = "".
substr(lst-lab-delim, 1 ,1) = "".
substr(lst-wordidx, 1 ,1) = "".

do ii = 1 to num-entries(select3):
     lab = entry(lookup(entry(ii, select3), lst-fld), lst-lab).
     methodReturn = Select-2:delete(lab).
     methodReturn = Select-3:add-last(lab).
end.
  RUN enable_UI.
  apply "value-changed" to rs-sorting in frame {&frame-name}.
  if not p-enable-sorting then do:
    disable
    rs-sorting
    with frame {&frame-name}.
    hide
    rs-sorting
    in frame {&frame-name}.
  end.
  if not p-enable-name-changing
  then
  disable f-naim
  with frame {&frame-name}
  .
  select-8:visible = no.
DISABLE btn-EQ btn-NE btn-LT btn-GT btn-LE btn-GE
        btn-BEGINS btn-MATCHES btn-List btn-Range btn-contains
            WITH FRAME {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus select-1.
  if undo_ then undo,retry.
/******************************************************************/
if p-save-to-file then do:
  output to value(string(g#report-num) + ".whr") /* "where.flp" */.
  put.
  if num-entries(select-8:list-items) > 0 then put unformatted 'and '.
  do ii = 1 to num-entries(select-8:list-items):
      put unformatted entry(ii, select-8:list-items) skip.
      end.
  output close.
  /******************************************************************/
  output to value(string(g#report-num) + ".srt"). /*'sort.flp'*/.
  put.
  DO ii = 1 TO NUM-ENTRIES(select3)
  :
    IF  ENTRY(ii, Select3) <> ""
    THEN DO:
        put  unformatted " by " + ENTRY(ii, Select3) .
        IF ENTRY(ii, list-descend) = '1'
        THEN do:
            put " descending".
        end.
    END.
  END.
  output close.
end.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE arifm DIALOG-1
PROCEDURE arifm :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable str_val as char no-undo.
define variable str_val_rus as char no-undo.
define variable s as char no-undo.
define variable otr as char no-undo.
define variable vhour as int no-undo.
define variable vmin as int no-undo.
define variable v-fact-date as date no-undo .
define variable v-fact-order as decimal no-undo .

DO on error undo,return error:
      if lookup(data-type, "character,integer,date,decimal,logical") > 0
         and spr <> 'usr'
      then do:
              if  data-type = "integer":U
              and spr = "time":U
              then do:
                run gbl/time-ref.w (output vhour, output vmin).
                if NOT return-value = "error":U
                then do:
                    assign
                    str_val = string(3600 * vhour + 60 * vmin + 59)
                    str_val_rus = string(vhour, "99") + ":":U + string(vmin, "99")
                    .
                end.
              end.
              else do:
                if  data-type = "decimal":U
                and spr = "fact-order-d":U
                then do:
                  run gbl/f-const.w
                    (input  parparentproc /* parparentproc */
                    ,input  "":U          /* spr           */
                    ,input  "date"        /* type          */
                    ,output str_val       /* str           */
                    ,output str_val_rus   /* str_rus       */
                    ).
                  if not return-value = "error":U
                  then do:
                    assign
                    v-fact-date = date(integer(substr(str_val, 1, 2)),
                                      integer(substr(str_val, 4, 2)),

                                      yearofst(
                                      integer(substr(str_val, 7, 4))
                                               )
                                       )
                    .
                    CASE znak:
                      when "<"
                      then do:
                        run day-begin-fact-order in this-procedure (
                                                  input v-fact-date
                                                  ,output v-fact-order ) .
                      end.
                      when ">"
                      then do:
                        run factord-end-day in this-procedure (
                                                  input v-fact-date
                                                  ,output v-fact-order ) .

                      end.
                      when "<="
                      then do:
                        run day-begin-fact-order in this-procedure (
                                                  input (v-fact-date + 1)
                                                  ,output v-fact-order ) .

                      end.
                      when ">="
                      then do:
                        run factord-end-day in this-procedure (
                                                  input (v-fact-date - 1)
                                                  ,output v-fact-order ) .
                      end.
                    END CASE.
                    assign
                    str_val = string(v-fact-order, "9999999999999999999999.9999999999":U)
                    .
                  end.
                end.
                else do:
                  run gbl/f-const.w
                    (input  parparentproc /* parparentproc */
                    ,input  spr           /* spr           */
                    ,input  data-type     /* type          */
                    ,output str_val       /* str           */
                    ,output str_val_rus   /* str_rus       */
                    ).
                end.
              end.

              assign
                otr = ""
              .
              if lookup(spr, "cligrp,gdsgrp") > 0
              then do:
                if znak = "="
                then do:
                  assign
                    znak = " BEGINS "
                    znak_rus = " нач. с "
                  .
                end.
                if znak = "<>"
                then do:
                  assign
                    otr = " NOT "
                    znak = " BEGINS "
                    znak_rus = " не нач. с "
                  .
                end.
              end.
              if data-type = "CHARACTER"
              then do:
                assign
                  s = '"'
                .
                run replace-special-char in this-procedure
                  (input  str_val
                  ,output str_val
                  ) .
              end.
              else do:
                assign
                  s = ''
                .
              end.

              str_rus =  znak_rus + ' ' + s + str_val_rus + s.
              if znak = 'matches' then str_val = '*' + str_val + '*'.
              v-str = znak + ' ' + s + str_val + s.
              run enable-select-where.
              enable select-8 select-9 with frame {&frame-name}.
              select-8:visible = no.
              if select-8 :num-items  > 1
              then do:
                 v-str = join-tbl + otr + file-name_field-name + " " + v-str.
              end.
              else do:
                 v-str = not-tbl + otr + file-name_field-name + " " + v-str.
              end.
              methodReturn = select-8 :replace(v-str,kriteria).
              methodReturn = select-9 :replace(kriteria_rus + str_rus,kriteria_rus).
      end.
      else do:
        define variable v-spr       as character no-undo .
        define variable v-data-type as character no-undo .
        define variable v-lab-delim as character no-undo .

        if spr begins "function_"
        then do:
          assign
            v-spr       = entry(2, spr, "_")
            v-data-type = entry(3, spr, "_")
            v-lab-delim = entry(4, spr, "_")
          .
        end.
        else do:
          assign
            v-spr       = spr
            v-data-type = data-type
            v-lab-delim = lab-delim
          .
        end.
        if entry(1, v-spr, {&delim-par}) = 'sht':U then do:
          run gbl/f-shift.w
            (input  parparentproc /* parparentproc */
            ,input  v-spr         /*  spr          */
            ,input  znak          /*  znak         */
            ,input  lab           /*  lab_user     */
            ,input  fld-delim     /*  fld          */
            ,input  v-lab-delim   /*  lab          */
            ,input  v-data-type   /*  type         */
            ,output str_val       /*  str          */
            ,output str_val_rus   /*  str_rus      */
            ).

        end.
        else do:
          case spr :
            when 'usr' then do:
              run gbl/f-user.p
                (input  parparentproc /* parparentproc */
                ,input  v-spr         /*  spr          */
                ,input  znak          /*  znak         */
                ,input  lab           /*  lab_user     */
                ,input  fld-delim     /*  fld          */
                ,input  v-lab-delim   /*  lab          */
                ,input  v-data-type   /*  type         */
                ,output str_val       /*  str          */
                ,output str_val_rus   /*  str_rus      */
                ).
            end.
            otherwise do:
              run gbl/f-constm.w
                (input  parparentproc /* parparentproc */
                ,input  v-spr         /*  spr          */
                ,input  znak          /*  znak         */
                ,input  lab           /*  lab_user     */
                ,input  fld-delim     /*  fld          */
                ,input  v-lab-delim   /*  lab          */
                ,input  v-data-type   /*  type         */
                ,output str_val       /*  str          */
                ,output str_val_rus   /*  str_rus      */
                ).
            end.
          end case.
        end.
        run enable-select-where.
        enable select-8 select-9 with frame {&frame-name}.
        select-8:visible = no.
        if select-8:num-items  > 1
        then do:
            join_ = join-tbl.  join_r = join_rus.
        end.
        else do:
          join_ = not-tbl. join_r = not_rus.
        end.
        methodReturn=select-8:replace(join_ + str_val,kriteria).
        methodReturn=select-9:replace(join_r + str_val_rus,kriteria_rus).
      end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE bound DIALOG-1
PROCEDURE bound :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable up_   as character no-undo .
  define variable down_ as character no-undo .
  define variable incl  as logical   no-undo .
  define variable s     as character no-undo .

  do
  on error undo, return error return-value
  :
      run gbl/f-bound.w
        (input  data-type
        ,output down_
        ,output up_
        ,output incl
        ).
      if data-type = "CHARACTER"
      then do:
        assign
          s = '"'
        .
        run replace-special-char in this-procedure
          (input  down_
          ,output down_
          ) .
        run replace-special-char in this-procedure
          (input  up_
          ,output up_
          ) .
      end.
      else do:
        assign
          s = ''
        .
      end.

     assign
       znak = (if incl then "=" else "")
     .
     assign
      v-str = " >" + znak + ' ' + s +
                  (if data-type = "DATE"
                  then 'date(':u + string(month(date(down_)))
                                  + '~~054':u + string(day(date(down_)))
                                  + '~~054':u + string(year(date(down_)))
                                  + ')':u
                  else down_
                  )
                  + s + " AND "
                  + file-name_field-name + " <"
                  + znak + ' ' + s +
                  (if data-type = "DATE"
                  then 'date(':u + string(month(date(up_)))
                                  + '~~054':u + string(day(date(up_)))
                                  + '~~054':u + string(year(date(up_)))
                                  + ')':u
                    else up_)
                    + s + ")"
      str_rus = " >" + znak + ' ' + s + down_ + s + " И "
                  + lab + " <" + znak + ' ' + s + up_ + s + ")"
     .
end.
RUN enable-select-where.
ENABLE select-8 select-9 WITH FRAME {&frame-name}.
select-8:visible = no.
if select-8:num-items  > 1
then do:
   join_ = join-tbl.
   join_r = join_rus.
end.
else do:
   join_ = not-tbl.
   join_r = not_rus.
end.
methodReturn=select-8:replace(join_ + '(' + file-name_field-name + v-str,kriteria).
methodReturn=select-9:replace(join_r + '(' + lab +  str_rus,kriteria_rus).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-select-where DIALOG-1
PROCEDURE enable-select-where :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  ENABLE SELECT-1 b-addfield btn-del b-exit N_NOT WITH FRAME {&frame-name}.
  DISABLE btn-undo btn-EQ btn-NE btn-LT btn-GT btn-LE btn-GE
          btn-BEGINS btn-MATCHES btn-List btn-Range btn-contains
              WITH FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY f-Naim rs-sorting FILL-IN-1 FILL-IN-3 FILL-IN-4 FILL-IN-2 SELECT-9
          N_NOT SELECT-8
      WITH FRAME DIALOG-1.
  ENABLE b-exit b-quit b-help RECT-1 f-Naim rs-sorting B-addfield SELECT-1
         SELECT-2 btn-EQ btn-NE SELECT-3 btn-Begins btn-Matches btn-LT btn-GT
         btn-List btn-Range btn-LE btn-GE btn-contains btn-del SELECT-9 N_NOT
         AND-OR SELECT-8
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lst DIALOG-1
PROCEDURE lst :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable sel_list as character no-undo.
define variable sel_list-rus as character no-undo.
define variable incl as logical no-undo.
define variable str_val as char no-undo.
define variable str_val_rus as char no-undo.
define variable s as char no-undo.
define variable otr as char no-undo.
define variable code_name as char no-undo.
define variable code_name-rus as character no-undo .

do on error undo,return error:
     s = if data-type = "CHARACTER" then '"' else ''.
      if lookup(data-type, "character,integer,date,decimal,logical") > 0
      then do:
          run gbl/f-list.w
            (input  parparentproc /* parparentproc */
            ,input  spr           /* spr           */
            ,input  data-type     /* type          */
            ,output sel_list      /* sel_list      */
            ,output sel_list-rus  /* sel_list_rus  */
            ,output incl          /* incl          */
            ).
          if incl
          then do:
             if lookup(spr, "cligrp,gdsgrp") > 0
             then do:
                otr = "". znak = " BEGINS ".  znak_rus = " нач. с ".
             end.
             else do:
                otr = "". znak = " = ". znak_rus = " = ".
             end.
             join_list = " OR ".  join_list_rus = " ИЛИ ".
          end.
          else do:
             if lookup(spr, "cligrp,gdsgrp") > 0
             then do:
               assign
                 otr = " NOT "
                 znak = " BEGINS "
                 znak_rus = " не нач. с "
               .
             end.
             else do:
               assign
                 otr = ""
                 znak = " <> "
                 znak_rus = " <> "
               .
             end.
            join_list = not-tbl + " AND ". join_list_rus = not_rus + " И ".
          end.
          v-str = "". str_rus = "".
          do ii = 1 to num-entries(sel_list):
               if ii > 1
               then do:
                  v-str = v-str + join_list + otr + file-name_field-name + " ".
                  str_rus = str_rus + join_list_rus + lab + " ".
               end.
               v-str = v-str + znak + " "
                       + s +
                       (if data-type = "DATE"
                       then (if ENTRY(ii, sel_list) = {&question-mark}
                             then {&question-mark}
                             else 'date(':u + string(month(date(entry(ii, sel_list))))
                                  + '~~054':u + string(day(date(entry(ii, sel_list))))
                                  + '~~054':u + string(year(date(entry(ii, sel_list))))
                                  + ')':u
                            )
                       else ENTRY(ii, sel_list)
                       )
                       + s.
               case spr:
                   when 'pay'
                   then do:
                      find ub.pay-type where ub.pay-type.obj-code = int(ENTRY(ii, sel_list)) no-lock no-error.
                      if available ub.pay-type then
                      assign
                      code_name = ub.pay-type.obj-name
                      code_name-rus = ub.pay-type.obj-name
                      .
                   end.
                   when 'curr'
                   then do:
                      find ub.currency where ub.currency.curr-code = int(ENTRY(ii, sel_list))  no-lock.
                      if available ub.currency then
                      assign
                      code_name = ub.currency.curr-abbr
                      code_name-rus = ub.currency.curr-abbr
                      .
                   end.
                   when 'prt'
                   then do:
                      find  ub.gds-prt where ub.gds-prt.upper-code = int(ENTRY(ii, sel_list))  no-lock.
                      if available ub.gds-prt then
                      assign
                      code_name = ub.gds-prt.node-name
                      code_name-rus = ub.gds-prt.node-name
                      .
                   end.
                   when 'db' then do:
                      find ub.db where ub.db.db-num = int(ENTRY(ii, sel_list)) no-lock no-error.
                      if available ub.db then
                      assign
                      code_name = substitute("&1", ub.db.db-num)
                      code_name-rus = substitute("&1", ub.db.db-num)
                      .
                   end.
                   otherwise do:
                    assign
                    code_name = ENTRY(ii, sel_list) .
                    code_name-rus = ENTRY(ii, sel_list-rus) no-error .
                   end.
               end.
               str_rus = str_rus + znak_rus + " "
                            + s + code_name-rus + s.
          end.
          v-str = v-str + ")".
          str_rus = str_rus + ")".
          run enable-select-where.
          enable select-8 select-9 with frame {&frame-name}.
          select-8:visible = no.
          if select-8:num-items  > 1
          then do:
             join_ = join-tbl.  join_r = join_rus.
          end.
          else do:
            join_ = not-tbl. join_r = not_rus.
          end.
          methodReturn=select-8:replace(join_ + '(' + otr + file-name_field-name + v-str,kriteria).
          methodReturn=select-9:replace(join_r + '(' + lab +  str_rus,kriteria_rus).
     end.
     else do:
          run gbl/f-listm.w
            (input  parparentproc /* parparentproc */
            ,input  spr           /* spr           */
            ,input  lab           /* lab_user      */
            ,input  fld-delim     /* fld           */
            ,input  lab-delim     /* lab           */
            ,input  data-type     /* type          */
            ,output str_val       /* str           */
            ,output str_val_rus   /* str_rus       */
            ).
          run enable-select-where.
          enable select-8 select-9 with frame {&frame-name}.
          select-8:visible = no.
          if select-8:num-items  > 1
          then do:
             join_ = join-tbl.  join_r = join_rus.
          end.
          else do:
            join_ = not-tbl. join_r = not_rus.
          end.
          methodReturn=select-8:replace(join_ + str_val,kriteria).
          methodReturn=select-9:replace(join_r + str_val_rus,kriteria_rus).
     end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE replace-special-char DIALOG-1
PROCEDURE replace-special-char :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-in-string    as character no-undo .
  define output parameter p-out-string   as character no-undo .

  define variable v-out-string   as character no-undo .
  define variable v-enclose-char as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-out-string   = p-in-string
      v-enclose-char = '"'
    .
    if index(v-out-string, '"') > 0
    then do:
      /* если в строке была двойная кавычка, */
      /* то она меняется на своё представление через код */
      /* двойная кавычка должна меняться первой */
      assign
        v-out-string = replace(v-out-string, '"', v-enclose-char + ' + chr(' + string(asc('"')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '~~') > 0
    then do:
      /* если в строке была тильда, */
      /* то она меняется на своё представление через код */
      assign
        v-out-string = replace(v-out-string, '~~', v-enclose-char + ' + chr(' + string(asc('~~')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, ',') > 0
    then do:
      /* если в строке была запятая, */
      /* то она меняется на своё представление через код */
      assign
        v-out-string = replace(v-out-string, ',', v-enclose-char + ' + chr(' + string(asc(',')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, "'") > 0
    then do:
      /* если в строке была одинарная кавычка, */
      /* то она меняется на своё представление через код */
      assign
        v-out-string = replace(v-out-string, "'", v-enclose-char + ' + chr(' + string(asc("'")) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '/') > 0
    then do:
      /* если в строке был символ наклонной черты, */
      /* то он меняется на своё представление через код */
      /* это делается для того, чтобы в строке случайно не возникло символа */
      /* начала комментария */
      assign
        v-out-string = replace(v-out-string, '/', v-enclose-char + ' + chr(' + string(asc('/')) + ') + ' + v-enclose-char)
      .
    end.

    assign
      p-out-string = v-out-string
    .
  end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME