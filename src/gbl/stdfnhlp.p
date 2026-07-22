block-level on error undo, throw.
/*

$Revision: 89462fe805e0, 527, rls $
$Author: EShklyar $
$Date: Thu Mar 17 18:42:35 2016 +0400 $
$Workfile: stdfnhlp.p $
$Archive: gbl/stdfnhlp.p $

Описание функций из std-func.i.

Автор: Булгаков Андрей Николаевич
Дата создания: 03/04/05
Author: Andrew Bulgakoff
Creation date: 03/04/05

*/

/* ********************************************************************************************************************* *\

Описание функций:
================

FUNCTION LastMonthDate     RETURNS DATE      ( INPUT i-date       AS DATE      ) - возвращает дату последнего дня месяца;
FUNCTION LastMonthDay      RETURNS INTEGER   ( INPUT i-date       AS DATE      ) - возвращает последний день месяца;
FUNCTION LastDay-MY        RETURNS INTEGER   ( INPUT i-month      AS INTEGER,
                                               INPUT i-year       AS INTEGER   ) - возвращает последний день месяца по месяцу и году;
FUNCTION LastDate-MY       RETURNS DATE      ( INPUT i-month      AS INTEGER,
                                               INPUT i-year       AS INTEGER   ) - возвращает дату последнего дня месяца по месяцу и году;
FUNCTION NextMonth         RETURNS INTEGER   ( INPUT i-date       AS DATE      ) - номер следующего месяца;
FUNCTION NextYear          RETURNS INTEGER   ( INPUT i-date       AS DATE      ) - год следующего месяца;
FUNCTION PrevMonth         RETURNS INTEGER   ( INPUT i-date       AS DATE      ) - номер предыдующего месяца;
FUNCTION PrevYear          RETURNS INTEGER   ( INPUT i-date       AS DATE      ) - год предыдующего месяца;
FUNCTION NextMonth-MY      RETURNS INTEGER   ( INPUT i-month      AS INTEGER   ) - номер следующего месяца по месяцу и году;
FUNCTION NextYear-MY       RETURNS INTEGER   ( INPUT i-month      AS INTEGER,
                                               INPUT i-year       AS INTEGER   ) - год следующего месяца по месяцу и году;
FUNCTION PrevMonth-MY      RETURNS INTEGER   ( INPUT i-month      AS INTEGER   ) - номер предыдующего месяца по месяцу и году;
FUNCTION PrevYear-MY       RETURNS INTEGER   ( INPUT i-month      AS INTEGER,
                                               INPUT i-year       AS INTEGER   ) - год предыдующего месяца по месяцу и году;
FUNCTION MonthNameRus      RETURNS CHARACTER ( INPUT i-month      AS INTEGER   ) - название месяца по-русски;
FUNCTION MonthNameRusGen   RETURNS CHARACTER ( INPUT i-month      AS INTEGER   ) - название месяца по-русски в родительном падеже;
FUNCTION MonthNameRusCase  RETURNS CHARACTER ( INPUT i-month      AS INTEGER,
                                               INPUT i-case       AS INTEGER   ) - название месяца по-русски в указанном падеже;
FUNCTION MonthNameEng      RETURNS CHARACTER ( INPUT i-month      AS INTEGER   ) - название месяца по-английски;
FUNCTION CalcMonthes       RETURNS INTEGER   ( INPUT i-date-from  AS DATE,
                                               INPUT i-date-till  AS DATE      ) - количество месяцев в интервале дат;
FUNCTION CalcMonth-MY      RETURNS INTEGER   ( INPUT i-year-from  AS INTEGER,
                                               INPUT i-month-from AS INTEGER,
                                               INPUT i-year-till  AS INTEGER,
                                               INPUT i-month-till AS INTEGER   ) - количество месяцев в интервале дат, заданных месяцами и годами;
FUNCTION DateTimeHeader    RETURNS CHARACTER ( INPUT i-date       AS DATE      ) - заголовок отчета; возвращает строку, содержащую текущие дату и время печати длиной 30 символов;
FUNCTION TimeStamp         RETURNS CHARACTER ( INPUT i-num        AS INTEGER   ) - заголовок отчета; возвращает строку, содержащую текущие дату, время печати и номер страницы длиной 50 символов;
FUNCTION Stamp57           RETURNS CHARACTER ( INPUT i-date       AS DATE,
                                               INPUT i-time       AS INTEGER,
                                               INPUT i-num        AS INTEGER   ) - заголовок отчета: возвращает строку, содержащую дату и время печати и номер страницы длиной 57 символов;
FUNCTION Round-M           RETURNS DECIMAL   ( INPUT i-sum        AS DECIMAL,
                                               INPUT i-ord        AS INTEGER   ) - округление действительного числа; отрицательный порядок - слева от десятичной точки;
FUNCTION Trunc-M           RETURNS DECIMAL   ( INPUT i-sum        AS DECIMAL,
                                               INPUT i-ord        AS INTEGER   ) - обрезание действительного числа; отрицательный порядок - слева от десятичной точки;
FUNCTION get-dec           RETURNS INTEGER   ( INPUT i-sum        AS DECIMAL   ) - возвращает дробную часть действительного числа в виде целого;
FUNCTION RedLine           RETURNS CHARACTER ( INPUT i-str        AS CHARACTER ) - красная строка - первая буква заглавная, остальные - прописные;
FUNCTION Int2Char          RETURNS CHARACTER ( INPUT i-num        AS INTEGER   ) - конвертация целого числа в строку с подавлением ведущих нулей и без разбивки на разряды;
FUNCTION PutAcc            RETURNS CHARACTER ( INPUT i-num        AS INTEGER,
                                               INPUT i-sub        AS INTEGER   ) - конвертация бухгалтерского счета и субсчета в строку;
FUNCTION Roubles           RETURNS CHARACTER ( INPUT i-sum        AS DECIMAL   ) - р у б л и  в сумме;
FUNCTION Copecks           RETURNS CHARACTER ( INPUT i-sum        AS DECIMAL   ) - к о п е й к и  в сумме;
FUNCTION get-decade-word   RETURNS CHARACTER ( INPUT i-dec        AS INTEGER,
                                               INPUT i-num        AS INTEGER   ) - разряд числа прописью (при разбивке на триады);
FUNCTION Word-Sum          RETURNS CHARACTER ( INPUT i-sum        AS DECIMAL   ) - возвращает сумму прописью от целой части числа;
FUNCTION Total-Word        RETURNS CHARACTER ( INPUT i-sum        AS DECIMAL,
                                               INPUT i-curr       AS CHARACTER,
                                               INPUT i-part       AS CHARACTER ) - возвращает сумму в валюте прописью;
FUNCTION Word-Sum-Eng      RETURNS CHARACTER ( INPUT i-sum        AS DECIMAL   ) - возвращает сумму в валюте прописью по-английски;
FUNCTION Word-Curr         RETURNS CHARACTER ( INPUT i-sum        AS DECIMAL,
                                               INPUT i-curr       AS CHARACTER,
                                               INPUT i-part       AS CHARACTER ) - возвращает сумму в валюте прописью;
FUNCTION PutInt            RETURNS CHARACTER ( INPUT i-num        AS INTEGER   ) - конвертация целого числа в строку;
FUNCTION PutSum            RETURNS CHARACTER ( INPUT i-sum        AS DECIMAL   ) - конвертация суммы в строку;
FUNCTION Rec2Char          RETURNS CHARACTER ( INPUT i-rec        AS RECID     ) - конвертация RECID'а записи в строку;
FUNCTION WeekDay-Full      RETURNS CHARACTER ( INPUT i-date       AS DATE      ) - день недели;
FUNCTION WeekDay-Short     RETURNS CHARACTER ( INPUT i-date       AS DATE      ) - двухбуквенный код дня недели;
FUNCTION WeekDay-Shrt3     RETURNS CHARACTER ( INPUT i-date       AS DATE      ) - трехбуквенный код дня недели;
FUNCTION WeekDay-Rus       RETURNS INTEGER   ( INPUT i-date       AS DATE      ) - порядковый номер дня недели, начиная с понедельника;
FUNCTION WeekDay-Full-Eng  RETURNS CHARACTER ( INPUT i-date       AS DATE      ) - день недели по-английски;
FUNCTION WeekDay-Eng2      RETURNS CHARACTER ( INPUT i-date       AS DATE      ) - двухбуквенный код дня недели по-английски;
FUNCTION WeekDay-Eng3      RETURNS CHARACTER ( INPUT i-date       AS DATE      ) - трехбуквенный код дня недели по-английски;
FUNCTION Week-Num          RETURNS INTEGER   ( INPUT i-date       AS DATE      ) - возвращает номер недели по дате;
FUNCTION Week-From         RETURNS DATE      ( INPUT i-num        AS INTEGER,
                                               INPUT i-year       AS INTEGER   ) - возвращает дату начала недели по номеру и году;
FUNCTION Week-Till         RETURNS DATE      ( INPUT i-num        AS INTEGER,
                                               INPUT i-year       AS INTEGER   ) - возвращает дату окончания недели по номеру и году;
FUNCTION Week-Date         RETURNS DATE      ( INPUT i-week       AS INTEGER,
                                               INPUT i-day        AS INTEGER,
                                               INPUT i-year       AS INTEGER   ) - возвращает дату по номеру недели, номеру дня в неделе (рус) и году;
FUNCTION Week-Date-Eng     RETURNS DATE      ( INPUT i-week       AS INTEGER,
                                               INPUT i-day        AS INTEGER,
                                               INPUT i-year       AS INTEGER   ) - возвращает дату по номеру недели, номеру дня в неделе и году;
FUNCTION DelEntry          RETURNS CHARACTER ( INPUT i-list       AS CHARACTER,
                                               INPUT i-item       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER ) - снять отметку "выбрано" с записи;
FUNCTION addl-list         RETURNS CHARACTER ( INPUT i-list       AS CHARACTER,
                                               INPUT i-item       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER ) - добавить новый элемент в список на последнее место;
FUNCTION addf-list         RETURNS CHARACTER ( INPUT i-list       AS CHARACTER,
                                               INPUT i-item       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER ) - добавить новый элемент в список на первое место;
FUNCTION addn-list         RETURNS CHARACTER ( INPUT i-list       AS CHARACTER,
                                               INPUT i-item       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER,
                                               INPUT i-num        AS INTEGER   ) - добавить новый элемент в список на указанное место;
FUNCTION super-pos         RETURNS CHARACTER ( INPUT i-lst1       AS CHARACTER,
                                               INPUT i-lst2       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER ) - суперпозиция двух множеств, заданных списками;
FUNCTION sets-union        RETURNS CHARACTER ( INPUT i-lst1       AS CHARACTER,
                                               INPUT i-lst2       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER ) - объединение двух множеств, заданных списками;
FUNCTION sets-intersection RETURNS CHARACTER ( INPUT i-lst1       AS CHARACTER,
                                               INPUT i-lst2       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER ) - пересечение двух множеств, заданных списками;
FUNCTION ChooseMark        RETURNS CHARACTER ( INPUT i-list       AS CHARACTER,
                                               INPUT i-item       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER ) - пометить/снять пометку в текущей записи;
FUNCTION is-marked         RETURNS LOGICAL   ( INPUT i-list       AS CHARACTER,
                                               INPUT i-item       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER ) - помечена запись или нет;
FUNCTION MarkSign          RETURNS CHARACTER ( INPUT i-list       AS CHARACTER,
                                               INPUT i-item       AS CHARACTER,
                                               INPUT i-dlmtr      AS CHARACTER ) - текущий знак помечено/свободно для записи;
FUNCTION Int2Hex           RETURNS CHARACTER ( INPUT i-int        AS INTEGER   ) - конвертация целого числа в 16-ричное;
FUNCTION Hex2Int           RETURNS INTEGER   ( INPUT i-hex        AS CHARACTER ) - конвертация 16-ричного числа в целое;
FUNCTION Int2Octal         RETURNS CHARACTER ( INPUT i-int        AS INTEGER   ) - конвертация целого числа в 8-ричное;
FUNCTION Oct2Int           RETURNS INTEGER   ( INPUT i-oct        AS CHARACTER ) - конвертация 8-ричного числа в целое;
FUNCTION Int2Bin           RETURNS CHARACTER ( INPUT i-int        AS INTEGER   ) - конвертация целого числа в двоичное;
FUNCTION Bin2Int           RETURNS INTEGER   ( INPUT i-bin        AS CHARACTER ) - конвертация двоичного числа в целое;
FUNCTION Int2Base          RETURNS CHARACTER ( INPUT i-int        AS INTEGER,
                                               INPUT i-base       AS INTEGER   ) - конвертация целого числа в число по заданному основанию (не больше 60-ти);
FUNCTION Base2Int          RETURNS INTEGER   ( INPUT i-hex        AS CHARACTER,
                                               INPUT i-base       AS INTEGER   ) - конвертация числа по заданному основанию (не больше 60-ти) в целого число;
FUNCTION Base2Int64        RETURNS INT64     ( INPUT i-hex        AS CHARACTER,
                                               INPUT i-base       AS INTEGER   ) - конвертация числа по заданному основанию (не больше 60-ти) в целого число;
FUNCTION NumDays           RETURNS INTEGER   ( INPUT i-date       AS DATE      ) - порядковый номер дня с начала года;
FUNCTION DateNum           RETURNS DATE      ( INPUT i-days       AS INTEGER,
                                               INPUT i-year       AS INTEGER   ) - дата по порядковому номеру дня и году;
FUNCTION KeyStamp          RETURNS CHARACTER                                     - ключ: дата и время;
FUNCTION Leap-Year         RETURNS LOGICAL   ( INPUT i-year       AS INTEGER   ) - возвращает, високосный ли год (по году);
FUNCTION Leap-Year-d       RETURNS LOGICAL   ( INPUT i-date       AS DATE      ) - возвращает, високосный ли год (по дате);
FUNCTION Sparse            RETURNS CHARACTER ( INPUT i-instring   AS CHARACTER ) - возвращает "разреженную" строку (буквы через пробел) для заголовков;
FUNCTION SparseSymbol      RETURNS CHARACTER ( INPUT i-instring   AS CHARACTER,
                                               INPUT i-symbol     AS CHARACTER ) - возвращает "разреженную" строку (буквы через символ);
FUNCTION Compress          RETURNS CHARACTER ( INPUT p-instring   AS CHARACTER ) - возвращает "спрессованную" строку (без лишних пробелов, обратная к функции Sparce);
FUNCTION CompressSymbol    RETURNS CHARACTER ( INPUT i-instring   AS CHARACTER,
                                               INPUT i-symbol     AS CHARACTER ) - возвращает "спрессованную" строку (без лишних символов, обратная к функции SparceSymbol с тем же символом);
FUNCTION Centering         RETURNS CHARACTER ( INPUT i-string     AS CHARACTER,
                                               INPUT i-length     AS INTEGER   ) - возвращает отцентрированную строку;
FUNCTION CenteringSymbol   RETURNS CHARACTER ( INPUT i-string     AS CHARACTER,
                                               INPUT i-symbol     AS CHARACTER,
                                               INPUT i-length     AS INTEGER   ) - возвращает отцентрированную заданным символом строку;
FUNCTION ShiftRight        RETURNS CHARACTER ( INPUT i-string     AS CHARACTER,
                                               INPUT i-length     AS INTEGER   ) - возвращает выравненную вправо строку;
FUNCTION ShiftRightSymbol  RETURNS CHARACTER ( INPUT i-string     AS CHARACTER,
                                               INPUT i-symbol     AS CHARACTER,
                                               INPUT i-length     AS INTEGER   ) - возвращает выравненную вправо строку (заданным символом);
FUNCTION Digital           RETURNS LOGICAL   ( INPUT i-string     AS CHARACTER ) - возвращает, состоит ли строка только из цифр и десятичной точки;

\* ********************************************************************************************************************* */

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter p-func-name as character no-undo .

/* Preprocessor Definitions ---                                         */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME             fr-D-FunctionHelp

/* Preprocessor Definitions ---                                         */
&scop Std-Func_addition-list 'get-decade-word,get-dec-word-eng':U
&scop editor                 view-as editor    scrollbar-vertical               size-chars 98.00 by 17.25
&scop combox                 view-as combo-box list-items '':U    inner-lines 1 size-chars 36.00 by  1.00 sort
&scop fillin                 view-as fill-in                                    size-chars 16.50 by  1.00

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision: 89462fe805e0, 527, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Mar 17 18:42:35 2016 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: stdfnhlp.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/stdfnhlp.p $":U .
define variable vss-description as character no-undo initial "Описание функций из std-func.i":U .

/* Global, Shared, Preprocessor Definitions ---                         */
{ cmp/vssrevis.i     }
{ gbl/std-func.i def }
{ cmp/showinf.i      }

/* ***********************  Control Definitions  ********************** */
define variable Help_Editor as character no-undo {&editor} .
define variable Func_Name   as character no-undo {&combox} format "x(32)":U .
define variable num_funcs   as integer   no-undo {&fillin} format "->,>>>,>>>,>>9.":U .
define variable j_func      as integer   no-undo {&fillin} format "->,>>>,>>>,>>9":U .

/* Button Definitions ---                                               */
define button Btn_Exit label "Вы&ход" size-chars 10.00 by 1.00 default auto-end-key .

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  Func_Name   at row  1.50 col  1.50    label "Функция"
  j_func      at row  1.50 col 47.00 no-label                 fgcolor  4
  num_funcs   at row  1.50 col 67.75    label "Всего функций" fgcolor  4
  Help_Editor at row  3.00 col  1.50 no-label                 bgcolor 15
  Btn_Exit    at row 20.75 col 44.00 skip( 0.25 )
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title "Описание функций" default-button Btn_Exit cancel-button Btn_Exit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign
  frame {&FRAME-NAME} :scrollable = no
.
assign
  Help_Editor :read-only in frame {&FRAME-NAME} = yes
.

/* ************************  Control Triggers  ************************ */
on value-changed of Func_Name in frame {&FRAME-NAME}
do:
  { gbl/stdbtn.i }

  assign
    Func_Name
  .
  assign
    j_func = Func_Name :lookup( Func_Name )
  .
  run GetFunctionHelp1 in this-procedure
    (  input Func_Name
    , output Help_Editor
    ) .
  display j_func Help_Editor with frame {&FRAME-NAME} .
end.

/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle( active-window ) and
   frame {&FRAME-NAME} :parent = ?
then do:
  frame {&FRAME-NAME} :parent = active-window .
end.

/* Restore the current-window if it is an icon. Otherwise the dialog box will be hidden */
if current-window :window-state = window-minimized
then do:
   current-window :window-state = window-normal .
end.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR */
on window-close of frame {&FRAME-NAME}
do:
  apply "END-ERROR":U to frame {&FRAME-NAME}.
end.

/* Main-Block ---                                                       */
Main-Block:
DO
on error   undo Main-Block, leave Main-Block
on end-key undo Main-Block, leave Main-Block
on stop    undo Main-Block, leave Main-Block
:
  assign
    Func_Name :list-items  = {&Std-Func_function-list} + ',' + {&Std-Func_addition-list}
    Func_Name :inner-lines = 9
  .
  assign
    num_funcs = num-entries( Func_Name :list-items )
    j_func    = Func_Name :lookup( p-func-name )
  .
  assign
    Func_Name = Func_Name :entry( ( if j_func > 0 then j_func else 1 ) )
  .
  assign
    j_func    = Func_Name :lookup( Func_Name )
  .
  display Func_Name Help_Editor num_funcs j_func with frame {&FRAME-NAME} .
  enable  Func_Name Help_Editor Btn_Exit         with frame {&FRAME-NAME} .
  apply   'VALUE-CHANGED':U  to Func_Name          in frame {&FRAME-NAME} .

  wait-for endkey of frame {&FRAME-NAME} .
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause .

/* **********************  Internal Procedures  *********************** */
procedure GetFunctionHelp1 :
  define  input parameter p-name as character no-undo .
  define output parameter p-help as character no-undo .

  case p-name :
    when 'LastMonthDate'
    then do: /* 1 */
      assign
        p-help = "Возвращает дату последнего дня текущего месяца." + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                  + {&new-line} +
                 "LastMonthDate RETURNS DATE ( INPUT DATE ) ."     + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                         + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l LastMonthDate"               + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                  + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE NO-UNDO ."   + {&new-line} +
                 "DEFINE VARIABLE t_last-date AS DATE NO-UNDO ."   + {&new-line} + {&new-line} +
                 "ASSIGN"                                          + {&new-line} +
                 "  t_curr-date = TODAY"                           + {&new-line} +
                 "  t_last-date = LastMonthDate( t_curr-date )"    + {&new-line} +
                 "."                                               + {&new-line} +
                 'MESSAGE'                                         + {&new-line} +
                 '  "Дата последнего дня месяца:" t_last-date'     + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                             + {&new-line}
      .
    end. /* LastMonthDate */
    when 'LastMonthDay'
    then do: /* 2 */
      assign
        p-help = "Возвращает последний день текущего месяца."       + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                   + {&new-line} +
                 "LastMonthDate RETURNS INTEGER ( INPUT DATE ) ."   + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                          + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l LastMonthDay"                 + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + {&new-line} +
                 "DEFINE VARIABLE j_last-day  AS INTEGER NO-UNDO ." + {&new-line} + {&new-line} +
                 "ASSIGN"                                           + {&new-line} +
                 "  t_curr-date = TODAY"                            + {&new-line} +
                 "  j_last-day  = LastMonthDay( t_curr-date )"      + {&new-line} +
                 "."                                                + {&new-line} +
                 'MESSAGE'                                          + {&new-line} +
                 '  "Последний день месяца:" j_last-day'            + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                              + {&new-line}
      .
    end. /* LastMonthDay */
    when 'LastDate-MY'
    then do: /* 3 */
      assign
        p-help = "Возвращает дату последнего дня текущего месяца по месяцу и году." + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                   + {&new-line} +
                 "LastDate-MY RETURNS INTEGER ( INPUT Month AS INTEGER,"            + {&new-line} +
                 "                              INPUT Year  AS INTEGER ) ."         + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                          + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l LastDate-MY"                                  + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                   + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."                 + {&new-line} +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."                 + {&new-line} +
                 "DEFINE VARIABLE curr-year   AS INTEGER NO-UNDO ."                 + {&new-line} +
                 "DEFINE VARIABLE t_last-date AS DATE    NO-UNDO ."                 + {&new-line} + {&new-line} +
                 "ASSIGN"                                                           + {&new-line} +
                 "  t_curr-date = TODAY"                                            + {&new-line} +
                 "  curr-month  = MONTH( t_curr-date )"                             + {&new-line} +
                 "  curr-year   = YEAR(  t_curr-date )"                             + {&new-line} +
                 "  t_last-date = LastDate-MY( curr-month, curr-year )"             + {&new-line} +
                 "."                                                                + {&new-line} +
                 'MESSAGE'                                                          + {&new-line} +
                 '  "Дата последнего дня месяца:" t_last-date'                      + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                              + {&new-line}
      .
    end. /* LastDate-MY */
    when 'LastDay-MY'
    then do: /* 4 */
      assign
        p-help = "Возвращает последний день текущего месяца по месяцу и году." + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                              + {&new-line} +
                 "LastDay-MY RETURNS INTEGER ( INPUT Month AS INTEGER,"        + {&new-line} +
                 "                             INPUT Year  AS INTEGER ) ."     + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                     + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l LastDay-MY"                              + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."            + {&new-line} +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."            + {&new-line} +
                 "DEFINE VARIABLE curr-year   AS INTEGER NO-UNDO ."            + {&new-line} +
                 "DEFINE VARIABLE t_last-day  AS INTEGER NO-UNDO ."            + {&new-line} + {&new-line} +
                 "ASSIGN"                                                      + {&new-line} +
                 "  t_curr-date = TODAY"                                       + {&new-line} +
                 "  curr-month  = MONTH( t_curr-date )"                        + {&new-line} +
                 "  curr-year   = YEAR(  t_curr-date )"                        + {&new-line} +
                 "  t_last-day  = LastDay-MY( curr-month, curr-year )"         + {&new-line} +
                 "."                                                           + {&new-line} +
                 'MESSAGE'                                                     + {&new-line} +
                 '  "Последний день месяца:" j_last-day'                       + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                         + {&new-line}
      .
    end. /* LastDay-MY */
    when 'NextMonth'
    then do: /* 5 */
      assign
        p-help = "Возвращает номер следующего месяца по дате."      + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                   + {&new-line} +
                 "NextMonth RETURNS INTEGER ( INPUT DATE ) ."       + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                          + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l NextMonth"                    + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + {&new-line} +
                 "DEFINE VARIABLE next-month  AS INTEGER NO-UNDO ." + {&new-line} + {&new-line} +
                 "ASSIGN"                                           + {&new-line} +
                 "  t_curr-date = TODAY"                            + {&new-line} +
                 "  next-month  = NextMonth( t_curr-date )"         + {&new-line} +
                 "."                                                + {&new-line} +
                 'MESSAGE'                                          + {&new-line} +
                 '  "Следующий месяц:" next-month'                  + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                              + {&new-line}
      .
    end. /* NextMonth */
    when 'NextMonth-MY'
    then do: /* 6 */
      assign
        p-help = "Возвращает номер следующего месяца по месяцу и году."   + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                         + {&new-line} +
                 "NextMonth RETURNS INTEGER ( INPUT Month AS INTEGER ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l NextMonth-MY"                       + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."       + {&new-line} +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."       + {&new-line} +
                 "DEFINE VARIABLE next-month  AS INTEGER NO-UNDO ."       + {&new-line} + {&new-line} +
                 "ASSIGN"                                                 + {&new-line} +
                 "  t_curr-date = TODAY"                                  + {&new-line} +
                 "  curr-month  = MONTH( t_curr-date )"                   + {&new-line} +
                 "  next-month  = NextMonth-MY( curr-month )"             + {&new-line} +
                 "."                                                      + {&new-line} +
                 'MESSAGE'                                                + {&new-line} +
                 '  "Следующий месяц:" next-month'                        + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                    + {&new-line}
      .
    end. /* NextMonth-MY */
    when 'NextYear'
    then do: /* 7 */
      assign
        p-help = "Возвращает год следующего месяца по дате."        + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                   + {&new-line} +
                 "NextYear RETURNS INTEGER ( INPUT DATE ) ."        + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                          + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l NextYear"                     + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + {&new-line} +
                 "DEFINE VARIABLE next-year   AS INTEGER NO-UNDO ." + {&new-line} + {&new-line} +
                 "ASSIGN"                                           + {&new-line} +
                 "  t_curr-date = TODAY"                            + {&new-line} +
                 "  next-year   = NextYear( t_curr-date )"          + {&new-line} +
                 "."                                                + {&new-line} +
                 'MESSAGE'                                          + {&new-line} +
                 '  "Год следующего месяца:" next-year'             + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                              + {&new-line}
      .
    end. /* NextYear */
    when 'NextYear-MY'
    then do: /* 8 */
      assign
        p-help = "Возвращает год следующего месяца по текущему месяцу и году." + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                              + {&new-line} +
                 "NextYear-MY RETURNS INTEGER ( INPUT Month AS INTEGER,"       + {&new-line} +
                 "                              INPUT Year  AS INTEGER ) ."    + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                     + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l NextYear-MY"                             + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."            + {&new-line} +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."            + {&new-line} +
                 "DEFINE VARIABLE curr-year   AS INTEGER NO-UNDO ."            + {&new-line} +
                 "DEFINE VARIABLE next-year   AS INTEGER NO-UNDO ."            + {&new-line} + {&new-line} +
                 "ASSIGN"                                                      + {&new-line} +
                 "  t_curr-date = TODAY"                                       + {&new-line} +
                 "  curr-month  = MONTH( t_curr-date )"                        + {&new-line} +
                 "  curr-year   = YEAR(  t_curr-date )"                        + {&new-line} +
                 "  next-year   = NextYear-MY( curr-month, curr-year )"        + {&new-line} +
                 "."                                                           + {&new-line} +
                 'MESSAGE'                                                     + {&new-line} +
                 '  "Год следующего месяца:" next-year'                        + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                         + {&new-line}
      .
    end. /* NextYear-MY */
    when 'PrevMonth'
    then do: /* 9 */
      assign
        p-help = "Возвращает номер предыдующего месяца по дате."    + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                   + {&new-line} +
                 "PrevMonth RETURNS INTEGER ( INPUT DATE ) ."       + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                          + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l PrevMonth"                    + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + {&new-line} +
                 "DEFINE VARIABLE prev-month  AS INTEGER NO-UNDO ." + {&new-line} + {&new-line} +
                 "ASSIGN"                                           + {&new-line} +
                 "  t_curr-date = TODAY"                            + {&new-line} +
                 "  prev-month  = PrevMonth( t_curr-date )"         + {&new-line} +
                 "."                                                + {&new-line} +
                 'MESSAGE'                                          + {&new-line} +
                 '  "Предыдующий месяц:" prev-month'                + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                              + {&new-line}
      .
    end. /* PrevMonth */
    when 'PrevMonth-MY'
    then do: /* 10 */
      assign
        p-help = "Возвращает номер предыдующего месяца по месяцу и году." + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                         + {&new-line} +
                 "PrevMonth RETURNS INTEGER ( INPUT Month AS INTEGER ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l PrevMonth-MY"                       + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."       + {&new-line} +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."       + {&new-line} +
                 "DEFINE VARIABLE prev-month  AS INTEGER NO-UNDO ."       + {&new-line} + {&new-line} +
                 "ASSIGN"                                                 + {&new-line} +
                 "  t_curr-date = TODAY"                                  + {&new-line} +
                 "  curr-month  = MONTH( t_curr-date )"                   + {&new-line} +
                 "  prev-month  = PrevMonth-MY( curr-month )"             + {&new-line} +
                 "."                                                      + {&new-line} +
                 'MESSAGE'                                                + {&new-line} +
                 '  "Предыдующий месяц:" prev-month'                      + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                    + {&new-line}
      .
    end. /* PrevMonth-MY */
    when 'PrevYear'
    then do: /* 11 */
      assign
        p-help = "Возвращает год предыдующего месяца по дате."      + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                   + {&new-line} +
                 "PrevYear RETURNS INTEGER ( INPUT DATE ) ."        + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                          + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l PrevYear"                     + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + {&new-line} +
                 "DEFINE VARIABLE prev-year   AS INTEGER NO-UNDO ." + {&new-line} + {&new-line} +
                 "ASSIGN"                                           + {&new-line} +
                 "  t_curr-date = TODAY"                            + {&new-line} +
                 "  prev-year   = PrevYear( t_curr-date )"          + {&new-line} +
                 "."                                                + {&new-line} +
                 'MESSAGE'                                          + {&new-line} +
                 '  "Год предыдующего месяца:" prev-year'           + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                              + {&new-line}
      .
    end. /* PrevYear */
    when 'PrevYear-MY'
    then do: /* 12 */
      assign
        p-help = "Возвращает год предыдующего месяца по месяцу и году."     + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                           + {&new-line} +
                 "PrevYear-MY RETURNS INTEGER ( INPUT Month AS INTEGER,"    + {&new-line} +
                 "                              INPUT Year  AS INTEGER ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                  + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l PrevYear-MY"                          + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                           + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."         + {&new-line} +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."         + {&new-line} +
                 "DEFINE VARIABLE curr-year   AS INTEGER NO-UNDO ."         + {&new-line} +
                 "DEFINE VARIABLE prev-year   AS INTEGER NO-UNDO ."         + {&new-line} + {&new-line} +
                 "ASSIGN"                                                   + {&new-line} +
                 "  t_curr-date = TODAY"                                    + {&new-line} +
                 "  curr-month  = MONTH( t_curr-date )"                     + {&new-line} +
                 "  curr-year   = YEAR(  t_curr-date )"                     + {&new-line} +
                 "  prev-year   = PrevYear-MY( curr-month, curr-year )"     + {&new-line} +
                 "."                                                        + {&new-line} +
                 'MESSAGE'                                                  + {&new-line} +
                 '  "Год предыдующего месяца:" prev-year'                   + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                      + {&new-line}
      .
    end. /* PrevYear-MY */
    when 'MonthNameRus'
    then do: /* 13 */
      assign
        p-help = "Возвращает название месяца по-русски."              + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                     + {&new-line} +
                 "MonthNameRus RETURNS CHARACTER ( INPUT INTEGER ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                            + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l MonthNameRus"                   + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                     + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE      NO-UNDO ." + {&new-line} +
                 "DEFINE VARIABLE curr-month  AS INTEGER   NO-UNDO ." + {&new-line} +
                 "DEFINE VARIABLE word-month  AS CHARACTER NO-UNDO ." + {&new-line} + {&new-line} +
                 "ASSIGN"                                             + {&new-line} +
                 "  t_curr-date = TODAY"                              + {&new-line} +
                 "  curr-month  = MONTH( t_curr-date )"               + {&new-line} +
                 "  word-month  = MonthNameRus( curr-month )"         + {&new-line} +
                 "."                                                  + {&new-line} +
                 'MESSAGE'                                            + {&new-line} +
                 '  "Название месяца:" word-month'                    + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                + {&new-line}
      .
    end. /* MonthNameRus */
    when 'MonthNameRusGen'
    then do: /* 14 */
      assign
        p-help = "Возвращает название месяца по-русски в родительном падеже."   + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                               + {&new-line} +
                 "MonthNameRusGen RETURNS CHARACTER ( INPUT INTEGER ) ."        + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                      + {&new-line} + {&new-line} +
                 '/* **************************************************** *\'   + {&new-line} +
                 ' *                                                      *'    + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'    + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )               +
                                                                         '*'    + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'    + {&new-line} +
                 ' *                                                      *'    + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'    + {&new-line} +
                 ' *                                                      *'    + {&new-line} +
                 '\* **************************************************** */'   + {&new-line} + {&new-line} +
                 "~&SCOP f-l MonthNameRusGen"                                   + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                               + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE      NO-UNDO ."           + {&new-line} +
                 "DEFINE VARIABLE curr-month  AS INTEGER   NO-UNDO ."           + {&new-line} +
                 "DEFINE VARIABLE word-month  AS CHARACTER NO-UNDO ."           + {&new-line} + {&new-line} +
                 "ASSIGN"                                                       + {&new-line} +
                 "  t_curr-date = TODAY"                                        + {&new-line} +
                 "  curr-month  = MONTH( t_curr-date )"                         + {&new-line} +
                 "  word-month  = MonthNameRusGen( curr-month )"                + {&new-line} +
                 "."                                                            + {&new-line} +
                 'MESSAGE'                                                      + {&new-line} +
                 '  "Число:" STRING( DAY( t_curr-date ), ">9":U ) + "-е"'       + {&new-line} +
                 '  word-month YEAR(      t_curr-date ) "года."'                + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                          + {&new-line}
      .
    end. /* MonthNameRusGen */
    when 'MonthNameEng'
    then do: /* 15 */
      assign
        p-help = "Возвращает название месяца по-английски."           + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                     + {&new-line} +
                 "MonthNameEng RETURNS CHARACTER ( INPUT INTEGER ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                            + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l MonthNameEng"                   + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                     + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE      NO-UNDO ." + {&new-line} +
                 "DEFINE VARIABLE curr-month  AS INTEGER   NO-UNDO ." + {&new-line} +
                 "DEFINE VARIABLE word-month  AS CHARACTER NO-UNDO ." + {&new-line} + {&new-line} +
                 "ASSIGN"                                             + {&new-line} +
                 "  t_curr-date = TODAY"                              + {&new-line} +
                 "  curr-month  = MONTH( t_curr-date )"               + {&new-line} +
                 "  word-month  = MonthNameEng( curr-month )"         + {&new-line} +
                 '.'                                                  + {&new-line} +
                 'MESSAGE'                                            + {&new-line} +
                 '  "Название месяца по-английски:" word-month'       + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                + {&new-line}
      .
    end. /* MonthNameEng */
    when 'CalcMonthes'
    then do: /* 16 */
      assign
        p-help = "Возвращает количество месяцев в интервале дат."                + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                + {&new-line} +
                 "CalcMonthes RETURNS INTEGER ( INPUT t_from AS DATE"            + {&new-line} +
                 "                            , INPUT t_till AS DATE"            + {&new-line} + {&new-line} +
                 "                            ) ."                               + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                       + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l LastMonthDate,CalcMonthes"                 + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."              + {&new-line} +
                 "DEFINE VARIABLE t_date-from AS DATE    NO-UNDO ."              + {&new-line} +
                 "DEFINE VARIABLE t_date-till AS DATE    NO-UNDO ."              + {&new-line} +
                 "DEFINE VARIABLE num-monthes AS INTEGER NO-UNDO ."              + {&new-line} + {&new-line} +
                 "ASSIGN"                                                        + {&new-line} +
                 "  t_curr-date = TODAY"                                         + {&new-line} +
                 "  t_date-from = DATE( MONTH( t_curr-date ), 1, YEAR(  t_curr-date ) - 1 )"   + {&new-line} +
                 "  t_date-till = LastMonthDate( t_curr-date )"                  + {&new-line} +
                 "  num-monthes = CalcMonthes( t_date-from, t_date-till )"       + {&new-line} +
                 '.'                                                             + {&new-line} +
                 'MESSAGE'                                                       + {&new-line} +
                 '  "Диапазон дат с:" t_date-from "по:" t_date-till SKIP( 0 )'   + {&new-line} +
                 '  "Количество месяцев:" num-monthes'                           + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                           + {&new-line}
      .
    end. /* CalcMonthes */
    when 'CalcMonth-MY'
    then do: /* 17 */
      assign
        p-help = "Возвращает количество месяцев в интервале дат, " +
                 "заданных через месяцы и годы."                                               + {&new-line} +
                                                                                                 {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                              + {&new-line} +
                 "CalcMonth-MY RETURNS INTEGER ( INPUT year-from  AS INTEGER"                  + {&new-line} +
                 "                             , INPUT month-from AS INTEGER"                  + {&new-line} +
                 "                             , INPUT year-till  AS INTEGER"                  + {&new-line} +
                 "                             , INPUT month_till AS INTEGER"                  + {&new-line} +
                 "                             ) ."                                            + {&new-line} +
                                                                                                 {&new-line} +
                 "ПРИМЕР:"                                                                     + {&new-line} +
                                                                                                 {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l CalcMonth-MY,MonthNameRus,MonthNameRusGen"               + {&new-line} +
                                                                                                 {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                              + {&new-line} +
                                                                                                 {&new-line} +
                 "DEFINE VARIABLE date_from   AS DATE    NO-UNDO ."                            + {&new-line} +
                 "DEFINE VARIABLE date_till   AS DATE    NO-UNDO ."                            + {&new-line} +
                 "DEFINE VARIABLE month_from  AS INTEGER NO-UNDO ."                            + {&new-line} +
                 "DEFINE VARIABLE year_from   AS INTEGER NO-UNDO ."                            + {&new-line} +
                 "DEFINE VARIABLE month_till  AS INTEGER NO-UNDO ."                            + {&new-line} +
                 "DEFINE VARIABLE year_till   AS INTEGER NO-UNDO ."                            + {&new-line} +
                 "DEFINE VARIABLE num-monthes AS INTEGER NO-UNDO ."                            + {&new-line} +
                                                                                                 {&new-line} +
                 "ASSIGN"                                                                      + {&new-line} +
                 "  date_from   = TODAY - 31"                                                  + {&new-line} +
                 "  date_till   = TODAY + 31"                                                  + {&new-line} +
                 "  month_from  = MONTH( date_from )"                                          + {&new-line} +
                 "  month_till  = MONTH( date_till )"                                          + {&new-line} +
                 "  year_from   = YEAR(  date_from ) - 1"                                      + {&new-line} +
                 "  year_till   = YEAR(  date_till ) + 1"                                      + {&new-line} +
                 "  num-monthes = CalcMonth-MY( year_from, month_from,year_till, month_till )" + {&new-line} +
                 "."                                                                           + {&new-line} +
                 'MESSAGE'                                                                     + {&new-line} +
                 '  "Диапазон дат:  с " MonthNameRusGen( month_from ) year_from'               + {&new-line} +
                 '               " по " MonthNameRus(    month_till ) year_till SKIP( 0 )'     + {&new-line} +
                 '  "Количество месяцев:" num-monthes'                                         + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                         + {&new-line}
      .
    end. /* CalcMonth-MY */
    when 'DateTimeHeader'
    then do: /* 18 */
      assign
        p-help = "Заголовок отчета. Возвращает строку, содержащую текущие дату и " +
                 "время печати длиной 30 символов."                  + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                    + {&new-line} +
                 "DateTimeHeader RETURNS CHARACTER ( INPUT DATE ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                           + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l DateTimeHeader"                + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                    + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE NO-UNDO ."     + {&new-line} + {&new-line} +
                 "ASSIGN"                                            + {&new-line} + {&new-line} +
                 "  t_curr-date = TODAY"                             + {&new-line} + {&new-line} +
                 "."                                                 + {&new-line} + {&new-line} +
                 'MESSAGE'                                           + {&new-line} +
                 '  DateTimeHeader( t_curr-date )'                   + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                               + {&new-line}
      .
    end. /* DateTimeHeader */
    when 'TimeStamp'
    then do: /* 19 */
      assign
        p-help = "Заголовок отчета. Возвращает строку, содержащую текущие дату, "  +
                 "время печати и номер страницы длиной 50 символов." + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                    + {&new-line} +
                 "TimeStamp RETURNS CHARACTER ( INPUT INTEGER ) ."   + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                           + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l TimeStamp"                     + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                    + {&new-line} + {&new-line} +
                 'MESSAGE'                                           + {&new-line} +
                 '  TimeStamp( 1 )'                                  + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                               + {&new-line}
      .
    end. /* TimeStamp */
    when 'Stamp57'
    then do: /* 20 */
      assign
        p-help = "Заголовок отчета. Возвращает строку, содержащую дату и "    +
                 "время печати и номер страницы длиной 57 символов."          + {&new-line}     +
                 "Если дата и/или время не заданы, то берутся текущие."       + {&new-line}     + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                             + {&new-line}     +
                 "Stamp57 RETURNS CHARACTER ( INPUT print-date AS DATE"       + {&new-line}     +
                 "                          , INPUT print-time AS INTEGER"    + {&new-line}     +
                 "                          , INPUT curr-page  AS INTEGER"    + {&new-line}     + {&new-line} +
                 "                           ) ."                             + {&new-line}     + {&new-line} +
                 "ПРИМЕР:"                                                    + {&new-line}     + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Stamp57"                                + {&new-line}     + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                             + {&new-line}     + {&new-line} +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."           + {&new-line}     +
                 "DEFINE VARIABLE j_curr-time AS INTEGER NO-UNDO ."           + {&new-line}     +
                 "DEFINE VARIABLE j_curr-page AS INTEGER NO-UNDO ."           + {&new-line}     + {&new-line} +
                 "ASSIGN"                                                     + {&new-line}     +
                 "  t_curr-date = TODAY"                                      + {&new-line}     +
                 "  j_curr-time = TIME + 120"                                 + {&new-line}     +
                 "  j_curr-page = 2"                                          + {&new-line}     + {&new-line} +
                 "."                                                          + {&new-line}     + {&new-line} +
                 "IF t_curr-date <> TODAY"                                    + {&new-line}     +
                 "THEN DO:"                                                   + {&new-line}     +
                 "  ASSIGN"                                                   + {&new-line}     +
                 "    t_curr-date = TODAY"                                    + {&new-line}     +
                 "    j_curr-time = TIME + 120"                               + {&new-line}     +
                 "  ."                                                        + {&new-line}     +
                 "END."                                                       + {&new-line}     + {&new-line} +
                 'MESSAGE'                                                    + {&new-line}     +
                 '  ~'"~' + Stamp57( ?,           ?,           ?           ) + ~'"~' SKIP( 0 )' + {&new-line} +
                 '  ~'"~' + Stamp57( t_curr-date, j_curr-time, j_curr-page ) + ~'"~''           + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                        + {&new-line}
      .
    end. /* Stamp57 */
    when 'Round-M'
    then do: /* 21 */
      assign
        p-help = "Возвращает округленное действительное число."                   + {&new-line} +
                 "Первый параметр - число, которое нужно округлить."              + {&new-line} +
                 "Второй параметр - порядок округления."                          + {&new-line} +
                 "Если порядок округления отрицательный, то округляются "         +
                 "цифры слева от десятичной точки, т.е.:"                         + {&new-line} +
                 "  Round-M( 123.0, -1 ) = 120.0, Round-M( 123.0, -2 ) = 100.0."  + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                 + {&new-line} +
                 "Round-M RETURNS DECIMAL ( INPUT decimal-number AS DECIMAL"      + {&new-line} +
                 "                        , INPUM round-order    AS INTEGER"      + {&new-line} +
                 "                        ) ."                                    + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                        + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Round-M"                                    + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL -1234.98765 ." + {&new-line} + {&new-line} +
                 'MESSAGE'                                                        + {&new-line} +
                 '  "Число:" d_num "округлено до:" Round-M( d_num, -3 )'          + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                            + {&new-line}
      .
    end. /* Round-M */
    when 'Trunc-M'
    then do: /* 22 */
      assign
        p-help = 'Возвращает "обрезанное" действительное число, т.е. отбрасывает "лишние" занки.' + {&new-line} +
                 "Первый параметр - число, которое нужно обрезать."               + {&new-line}   +
                 "Второй параметр - количество знаков, которые нужно отбросить."  + {&new-line}   +
                 "Если порядок отрицательный, то отбрасываются цифры слева от десятичной точки:"  + {&new-line} +
                 "  Trunc-M( 567.0, -1 ) = 560.0, Trunc-M( 567.0, -2 ) = 500.0."  + {&new-line}   + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                 + {&new-line}   +
                 "Trunc-M RETURNS DECIMAL ( INPUT decimal-number AS DECIMAL"      + {&new-line}   +
                 "                        , INPUM truncate-order AS INTEGER"      + {&new-line}   +
                 "                        ) ."                                    + {&new-line}   + {&new-line} +
                 "ПРИМЕР:"                                                        + {&new-line}   + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Trunc-M"                                    + {&new-line}   + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + {&new-line}   + {&new-line} +
                 "DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL -9876.12345 ." + {&new-line}   + {&new-line} +
                 'MESSAGE'                                                        + {&new-line}   +
                 '  "Число:" d_num "обрезано до:" Trunc-M( d_num, -3 )'           + {&new-line}   +
                 'VIEW-AS ALERT-BOX .'                                            + {&new-line}
      .
    end. /* Trunc-M */
    when 'get-dec'
    then do: /* 23 */
      assign
        p-help = 'Возвращает дробную часть действительного числа в виде целого.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                + {&new-line} +
                 "get-dec RETURNS INTEGER ( INPUT decimal_number AS DECIMAL ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                       + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l get-dec"                                   + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 123.967 ."    + {&new-line} + {&new-line} +
                 'MESSAGE'                                                       + {&new-line} +
                 '  "Число:"                  d_num   SKIP( 0 )'                 + {&new-line} +
                 '  "дробная часть:" get-dec( d_num )'                           + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                           + {&new-line}
      .
    end. /* get-dec */
    when 'RedLine'
    then do: /* 24 */
      assign
        p-help = 'Красная строка: первая буква заглавная, остальные - прописные.'          + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                          + {&new-line} +
                 "RedLine RETURNS CHARACTER ( INPUT CHARACTER ) ."                         + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                                 + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l RedLine"                                             + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                          + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_str AS CHARACTER NO-UNDO INITIAL "красная строка" .'   + {&new-line} + {&new-line} +
                 'MESSAGE'                                                                 + {&new-line} +
                 '        v_str   "-->" RedLine(       v_str )   SKIP( 0 )'                + {&new-line} +
                 '  CAPS( v_str ) "-->" RedLine( CAPS( v_str ) ) SKIP( 0 )'                + {&new-line} +
                 '  LC( SUBSTRING( v_str, 1, 1 ) ) + CAPS( SUBSTRING( v_str, 2 ) ) "-->"'                + {&new-line} +
                 '  RedLine( LC( SUBSTRING( v_str, 1, 1 ) ) + CAPS( SUBSTRING( v_str, 2 ) ) ) SKIP( 0 )' + {&new-line} +
                 '  CAPS( SUBSTRING( v_str, 1, 1 ) ) + LC( SUBSTRING( v_str, 2 ) ) "-->"'                + {&new-line} +
                 '  RedLine( CAPS( SUBSTRING( v_str, 1, 1 ) ) + LC( SUBSTRING( v_str, 2 ) ) ) SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                                   + {&new-line}
      .
    end. /* RedLine */
    when 'Int2Char'
    then do: /* 25 */
      assign
        p-help = 'Конвертация целого числа в строку с подавлением ведущих нулей ' +
                 'без разбивки на разряды.'                                       + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                 + {&new-line} +
                 "Int2Char RETURNS CHARACTER ( INPUT INTEGER ) ."                 + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                        + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Int2Char"                                   + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 12345 .'       + {&new-line} + {&new-line} +
                 'MESSAGE'                                                        + {&new-line} +
                 '            j_num   SKIP( 0 )'                                  + {&new-line} +
                 '  Int2Char( j_num ) SKIP( 0 )'                                  + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                            + {&new-line}
      .
    end. /* Int2Char */
    when 'PutInt'
    then do: /* 26 */
      assign
        p-help = 'Конвертация целого числа в строку с подавлением ведущих нулей ' +
                 'и разбивкой на разряды.'                                        + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                 + {&new-line} +
                 "PutInt RETURNS CHARACTER ( INPUT INTEGER ) ."                   + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                        + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l PutInt"                                     + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 12345 .'       + {&new-line} + {&new-line} +
                 'MESSAGE'                                                        + {&new-line} +
                 '          j_num   SKIP( 0 )'                                    + {&new-line} +
                 '  PutInt( j_num ) SKIP( 0 )'                                    + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                            + {&new-line}
      .
    end. /* PutInt */
    when 'PutSum'
    then do: /* 27 */
      assign
        p-help = 'Конвертация действительного числа в строку с подавлением ведущих ' +
                 'нулей и разбивкой на разряды.'                                     + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                    + {&new-line} +
                 "PutSum RETURNS CHARACTER ( INPUT INTEGER ) ."                      + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                           + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l PutSum"                                        + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                    + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL -12345678.967 ."  + {&new-line} + {&new-line} +
                 'MESSAGE'                                                           + {&new-line} +
                 '          d_num   SKIP( 0 )'                                       + {&new-line} +
                 '  PutSum( d_num ) SKIP( 0 )'                                       + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                               + {&new-line}
      .
    end. /* PutSum */
    when 'PutAcc'
    then do: /* 28 */
      assign
        p-help = 'Конвертация бухгалтерского счета и субсчета в строку.'               + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                      + {&new-line} +
                 "PutAcc RETURNS CHARACTER ( INPUT i-num AS INTEGER"                   + {&new-line} + {&new-line} +
                 "                         , INPUT i-sub AS INTEGER"                   + {&new-line} + {&new-line} +
                 "                         ) ."                                        + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                             + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l PutAcc"                                          + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                      + {&new-line} + {&new-line} +
                 'MESSAGE'                                                             + {&new-line} +
                 '  PutAcc( 42, 0 ) + ", " + PutAcc( 60, 2 )'                          + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                 + {&new-line} +
                 "ПРИМЕЧАНИЕ:"                                                         + {&new-line} +
                 'По функции "верхнего" уровня PutAcc "включается" ее функция "нижнего" уровня '     + {&new-line} +
                 'Int2Char (которая может "включаться" и самостоятельно).'             + {&new-line}
      .
    end. /* PutAcc */
    when 'Rec2Char'
    then do: /* 29 */
      assign
        p-help = "Конвертация RECID'а записи в строку."                  + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                        + {&new-line} +
                 "Rec2Char RETURNS CHARACTER ( INPUT RECID ) ."          + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                               + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Rec2Char"                          + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                        + {&new-line} + {&new-line} +
                 'FIND LAST ub.bgh-doc NO-LOCK NO-ERROR .'               + {&new-line} +
                 'IF AVAILABLE ub.bgh-doc'                               + {&new-line} +
                 'THEN DO:'                                              + {&new-line} +
                 '  MESSAGE'                                             + {&new-line} +
                 '    Rec2Char( RECID( ub.bgh-doc ) )'                   + {&new-line} +
                 '  VIEW-AS ALERT-BOX .'                                 + {&new-line} +
                 'END.'                                                  + {&new-line} +
                 'ELSE DO:'                                              + {&new-line} +
                 '  MESSAGE'                                             + {&new-line} +
                 '    "Запись ~~"Бухгалтерские проводки~~" не найдена!"' + {&new-line} +
                 '  VIEW-AS ALERT-BOX .'                                 + {&new-line} +
                 'END.'                                                  + {&new-line}
      .
    end. /* Rec2Char */
    when 'Roubles' or /* 30 */
    when 'Copecks'    /* 31 */
    then do:
      assign
        p-help = 'Слово ' + ( if p-name = "Roubles" then '"{&abbr_rubli}"' else '"{&abbr_kopeyki}"' )         +
                 ' в сумме.'                                                      + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                 + {&new-line} +
                 "Roubles RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) ."         + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                        + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Roubles,Copecks,get-dec"                    + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE d_num1 AS DECIMAL NO-UNDO INITIAL 789.65 ."     + {&new-line} +
                 "DEFINE VARIABLE d_num2 AS DECIMAL NO-UNDO INITIAL 562.41 ."     + {&new-line} +
                 "DEFINE VARIABLE d_num3 AS DECIMAL NO-UNDO INITIAL 341.23 ."     + {&new-line} + {&new-line} +
                 'MESSAGE'                                                        + {&new-line} +
                 '  d_num1 "-" TRUNCATE( d_num1, 0 ) Roubles( d_num1 )'           + {&new-line} +
                 '             get-dec(  d_num1    ) Copecks( d_num1 ) SKIP( 0 )' + {&new-line} +
                 '  d_num2 "-" TRUNCATE( d_num2, 0 ) Roubles( d_num2 )'           + {&new-line} +
                 '             get-dec(  d_num2    ) Copecks( d_num2 ) SKIP( 0 )' + {&new-line} +
                 '  d_num3 "-" TRUNCATE( d_num3, 0 ) Roubles( d_num3 )'           + {&new-line} +
                 '             get-dec(  d_num3    ) Copecks( d_num3 ) SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                            + {&new-line}
      .
    end. /* Roubles,Copecks */
    when 'get-decade-word'
    then do: /* 32 */
      assign
        p-help = "Возвращает разряд числа прописью при разбивке на триады (вспомогательная функция " + {&new-line} +
                 'для функции "число прописью").'                                      + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                      + {&new-line} +
                 "get-decade-word RETURNS CHARACTER ( INPUT i-dec AS INTEGER"          + {&new-line} +
                 "                                  , INPUT i-num AS INTEGER"          + {&new-line} +
                 "                                  ) ."                               + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                          + {&new-line} +
                 "i-dec - цифра, означающая разряд цифры:"                             + {&new-line} +
                 "        1 - единицы (от 0 до 9), третья цифра в триаде, в десятках - не 1;"        + {&new-line} +
                 "        2 - единицы (от 10 до 19), третья цифра в триаде, в десятках - 1;"         + {&new-line} +
                 "        3 - десятки (от 10 до 90), вторая цифра в триаде;"           + {&new-line} +
                 "        4 - сотни   (от 100 до 900), первая цифра в триаде;"         + {&new-line} +
                 "i-num - цифра (от 0 до 9), которая будет возвращена прописью."       + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                             + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Word-Sum"                                        + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                      + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v-list  AS CHARACTER NO-UNDO INITIAL "008,019,256":U .'            + {&new-line} +
                 'DEFINE VARIABLE v-triad AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE v-word  AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE jj      AS INTEGER   NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE j1      AS INTEGER   NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE j-digit AS INTEGER   NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE j-order AS INTEGER   NO-UNDO .'                      + {&new-line} + {&new-line} +
                 'DO jj = 1 TO NUM-ENTRIES( v-list ) :'                                + {&new-line} +
                 '  ASSIGN'                                                            + {&new-line} +
                 '    v-triad = ENTRY( jj, v-list )'                                   + {&new-line} +
                 '  .'                                                                 + {&new-line} +
                 '  REPEAT j1 = 1 TO 3 :'                                              + {&new-line} +
                 '    ASSIGN'                                                          + {&new-line} +
                 '      j-digit = INTEGER( SUBSTRING( v-triad, j1, 1 ) )'              + {&new-line} +
                 '      j-order = ( 5 - j1 ) -'                                        + {&new-line} +
                 '      ( IF j1 = 3 AND SUBSTRING( v-triad, 2, 1 ) <> "1" THEN 1 ELSE 0 )'           + {&new-line} +
                 '      v-word  = get-decade-word( j-order, j-digit )'                 + {&new-line} +
                 '    .'                                                               + {&new-line} +
                 '    DISPLAY'                                                         + {&new-line} +
                 '      jj      FORMAT ">>9.":U'                                       + {&new-line} +
                 '      v-triad FORMAT "x(3)":U'                                       + {&new-line} +
                 '      j-digit FORMAT "9":U'                                          + {&new-line} +
                 '      j-order FORMAT "9":U'                                          + {&new-line} +
                 '      v-word  FORMAT "x(30)":U'                                      + {&new-line} +
                 '    WITH NO-LABELS NO-UNDERLINE NO-BOX .'                            + {&new-line} +
                 '  END.'                                                              + {&new-line} +
                 'END.'                                                                + {&new-line} + {&new-line} +
                 "ПРИМЕЧАНИЕ:"                                                         + {&new-line} +
                 'Обратите внимание, что включается функция "Word-Sum" - функция "верхнего" уровня,' + {&new-line} +
                 '- по которой "включаются" все функции ее "нижнего" уровня, в том числе и функция ' + {&new-line} +
                 'get-decade-word.'                                                    + {&new-line}
      .
    end. /* get-decade-word */
    when 'get-dec-word-eng'
    then do: /* 33 */
      assign
        p-help = "Возвращает разряд числа прописью при разбивке на триады (вспомогательная функция " + {&new-line} +
                 'для функции "число прописью").'                                      + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                      + {&new-line} +
                 "get-dec-word-eng RETURNS CHARACTER ( INPUT i-dec AS INTEGER"         + {&new-line} +
                 "                                   , INPUT i-num AS INTEGER"         + {&new-line} +
                 "                                   ) ."                              + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                          + {&new-line} +
                 "i-dec - цифра, означающая разряд цифры:"                             + {&new-line} +
                 "        1 - единицы (от 0 до 9), третья цифра в триаде, в десятках - не 1;"        + {&new-line} +
                 "        2 - единицы (от 10 до 19), третья цифра в триаде, в десятках - 1;"         + {&new-line} +
                 "        3 - десятки (от 10 до 90), вторая цифра в триаде;"           + {&new-line} +
                 "        4 - сотни   (от 100 до 900), первая цифра в триаде;"         + {&new-line} +
                 "i-num - цифра (от 0 до 9), которая будет возвращена прописью."       + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                             + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Word-Sum-Eng"                                    + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                      + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v-list  AS CHARACTER NO-UNDO INITIAL "008,019,256":U .'            + {&new-line} +
                 'DEFINE VARIABLE v-triad AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE v-word  AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE jj      AS INTEGER   NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE j1      AS INTEGER   NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE j-digit AS INTEGER   NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE j-order AS INTEGER   NO-UNDO .'                      + {&new-line} + {&new-line} +
                 'DO jj = 1 TO NUM-ENTRIES( v-list ) :'                                + {&new-line} +
                 '  ASSIGN'                                                            + {&new-line} +
                 '    v-triad = ENTRY( jj, v-list )'                                   + {&new-line} +
                 '  .'                                                                 + {&new-line} +
                 '  REPEAT j1 = 1 TO 3 :'                                              + {&new-line} +
                 '    ASSIGN'                                                          + {&new-line} +
                 '      j-digit = INTEGER( SUBSTRING( v-triad, j1, 1 ) )'              + {&new-line} +
                 '      j-order = ( 5 - j1 ) -'                                        + {&new-line} +
                 '                ( IF j1 = 3 AND SUBSTRING( v-triad, 2, 1 ) <> "1" THEN 1 ELSE 0 )' + {&new-line} +
                 '      v-word  = get-dec-word-eng( j-order, j-digit )'                + {&new-line} +
                 '    .'                                                               + {&new-line} +
                 '    DISPLAY'                                                         + {&new-line} +
                 '      jj      FORMAT ">>9.":U'                                       + {&new-line} +
                 '      v-triad FORMAT "x(3)":U'                                       + {&new-line} +
                 '      j-digit FORMAT "9":U'                                          + {&new-line} +
                 '      j-order FORMAT "9":U'                                          + {&new-line} +
                 '      v-word  FORMAT "x(30)":U'                                      + {&new-line} +
                 '    WITH NO-LABELS NO-UNDERLINE NO-BOX .'                            + {&new-line} +
                 '  END.'                                                              + {&new-line} +
                 'END.'                                                                + {&new-line} + {&new-line} +
                 "ПРИМЕЧАНИЕ:"                                                         + {&new-line} +
                 'Обратите внимание, что включается функция "Word-Sum-Eng" - функция "верхнего" '    + {&new-line} +
                 'уровня, - по которой "включаются" все функции ее "нижнего" уровня, в том числе и ' + {&new-line} +
                 'функция get-dec-word-eng.'                                                         + {&new-line}
      .
    end. /* get-dec-word-eng */
    when 'Word-Sum'
    then do: /* 34 */
      assign
        p-help = 'Возвращает сумму прописью от целой части действительного числа.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                  + {&new-line} +
                 "Word-Sum RETURNS CHARACTER ( INPUT DECIMAL ) ."                  + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                         + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Word-Sum"                                    + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 12345 .'        + {&new-line} + {&new-line} +
                 'MESSAGE'                                                         + {&new-line} +
                 '            d_num   SKIP( 0 )'                                   + {&new-line} +
                 '  Word-Sum( d_num ) SKIP( 0 )'                                   + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                             + {&new-line}
      .
    end. /* Word-Sum */
    when 'Word-Sum-Eng'
    then do: /* 35 */
      assign
        p-help = 'Возвращает сумму прописью от целой части действительного числа.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                  + {&new-line} +
                 "Word-Sum-Eng RETURNS CHARACTER ( INPUT DECIMAL ) ."              + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                         + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Word-Sum-Eng"                                + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 12345 .'        + {&new-line} + {&new-line} +
                 'MESSAGE'                                                         + {&new-line} +
                 '                d_num   SKIP( 0 )'                               + {&new-line} +
                 '  Word-Sum-Eng( d_num ) SKIP( 0 )'                               + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                             + {&new-line}
      .
    end. /* Word-Sum-Eng */
    when 'Total-Word'
    then do: /* 36 */
      assign
        p-help = 'Возвращает строку с суммой в валюте прописью по-русски с указанием '       + {&new-line} +
                 'валюты и дробной части валюты.'                              + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                              + {&new-line} +
                 "Total-Word RETURNS CHARACTER ( INPUT i-sum  AS DECIMAL"      + {&new-line} +
                 "                             , INPUT i-curr AS CHARACTER"    + {&new-line} +
                 "                             , INPUT i-part AS CHARACTER"    + {&new-line} +
                 "                             ) ."                            + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                  + {&new-line} +
                 '  i-sum  - сумма в валюте;'                                  + {&new-line} +
                 '  i-curr - валюта;'                                          + {&new-line} +
                 '  i-part - название дробной части валюты.'                   + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                     + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Word-Sum,Total-Word"                     + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 753.84 .'   + {&new-line} + {&new-line} +
                 'MESSAGE'                                                     + {&new-line} +
                 '              d_num                 SKIP( 0 )'               + {&new-line} +
                 '  Total-Word( d_num, "USD", "cnt" ) SKIP( 0 )'               + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                         + {&new-line}
      .
    end. /* Total-Word */
    when 'Word-Curr'
    then do: /* 37 */
      assign
        p-help = 'Возвращает строку с суммой в валюте прописью на английском языке с указанием ' + {&new-line} +
                 'валюты и дробной части валюты.'                                  + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                  + {&new-line} +
                 "Word-Curr RETURNS CHARACTER ( INPUT i-sum  AS DECIMAL"           + {&new-line} +
                 "                            , INPUT i-curr AS CHARACTER"         + {&new-line} +
                 "                            , INPUT i-part AS CHARACTER"         + {&new-line} +
                 "                            ) ."                                 + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                      + {&new-line} +
                 '  i-sum  - сумма в валюте;'                                      + {&new-line} +
                 '  i-curr - валюта;'                                              + {&new-line} +
                 '  i-part - название дробной части валюты.'                       + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                         + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Word-Sum-Eng,Word-Curr"                      + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 753.84 .'       + {&new-line} + {&new-line} +
                 'MESSAGE'                                                         + {&new-line} +
                 '             d_num                 SKIP( 0 )'                    + {&new-line} +
                 '  Word-Curr( d_num, "USD", "cnt" ) SKIP( 0 )'                    + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                             + {&new-line}
      .
    end. /* Word-Curr */
    when 'WeekDay-Full'
    then do: /* 38 */
      assign
        p-help = 'Возвращает название дня недели по-русски по дате.'         + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                            + {&new-line} +
                 "WeekDay-Full RETURNS CHARACTER ( INPUT i-date AS DATE ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                   + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l WeekDay-Full"                          + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                            + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                  + {&new-line} + {&new-line} +
                 'ASSIGN'                                                    + {&new-line} +
                 '  t_date = TODAY'                                          + {&new-line} +
                 '.'                                                         + {&new-line} +
                 'MESSAGE'                                                   + {&new-line} +
                 '  "Сегодня:" LC( WeekDay-Full( t_date ) + ", " +'          + {&new-line} +
                 '  STRING( t_date, "99/99/9999":U ) + " г." )'              + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                       + {&new-line}
      .
    end. /* WeekDay-Full */
    when 'WeekDay-Short'
    then do: /* 39 */
      assign
        p-help = 'Возвращает короткое название (двухбуквенный код) дня недели по-русски '   +
                 'по дате.'                                                   + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                             + {&new-line} +
                 "WeekDay-Short RETURNS CHARACTER ( INPUT i-date AS DATE ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                    + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l WeekDay-Short"                          + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                             + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                   + {&new-line} + {&new-line} +
                 'ASSIGN'                                                     + {&new-line} +
                 '  t_date = TODAY'                                           + {&new-line} +
                 '.'                                                          + {&new-line} +
                 'MESSAGE'                                                    + {&new-line} +
                 '  "Сегодня:" LC( WeekDay-Short( t_date ) + ", " +'          + {&new-line} +
                 '  STRING( t_date, "99/99/9999":U ) + " г." )'               + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                        + {&new-line}
      .
    end. /* WeekDay-Short */
    when 'WeekDay-Rus'
    then do: /* 40 */
      assign
        p-help = 'Возвращает порядковый номер дня недели, начиная с понедельника.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                  + {&new-line} +
                 "WeekDay-Rus RETURNS INTEGER ( INPUT i-date AS DATE ) ."          + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                         + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l WeekDay-Rus"                                 + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                        + {&new-line} + {&new-line} +
                 'ASSIGN'                                                          + {&new-line} +
                 '  t_date = TODAY'                                                + {&new-line} +
                 '.'                                                               + {&new-line} +
                 'MESSAGE'                                                         + {&new-line} +
                 '  "Сегодня:" STRING( t_date, "99/99/9999":U ) + ","'             + {&new-line} +
                 '  STRING( WeekDay-Rus( t_date ) ) + "-й день недели"'            + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                             + {&new-line}
      .
    end. /* WeekDay-Rus */
    when 'WeekDay-Full-Eng'
    then do: /* 41 */
      assign
        p-help = 'Возвращает название дня недели по-английски по дате.'          + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                + {&new-line} +
                 "WeekDay-Full-Eng RETURNS CHARACTER ( INPUT i-date AS DATE ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                       + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l WeekDay-Full-Eng"                          + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                      + {&new-line} + {&new-line} +
                 'ASSIGN'                                                        + {&new-line} +
                 '  t_date = TODAY'                                              + {&new-line} +
                 '.'                                                             + {&new-line} +
                 'MESSAGE'                                                       + {&new-line} +
                 '  "Today" WeekDay-Full-Eng( t_date ) + ", " +'                 + {&new-line} +
                 '  STRING( t_date, "99/99/9999":U )'                            + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                           + {&new-line}
      .
    end. /* WeekDay-Full-Eng */
    when 'WeekDay-Eng2'
    then do: /* 42 */
      assign
        p-help = 'Возвращает короткое название (двухбуквенный код) дня недели ' +
                 'по-английски по дате.'                                        + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                               + {&new-line} +
                 "WeekDay-Eng2 RETURNS CHARACTER ( INPUT i-date AS DATE ) ."    + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                      + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l WeekDay-Eng2"                             + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                               + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                     + {&new-line} + {&new-line} +
                 'ASSIGN'                                                       + {&new-line} +
                 '  t_date = TODAY'                                             + {&new-line} +
                 '.'                                                            + {&new-line} +
                 'MESSAGE'                                                      + {&new-line} +
                 '  "Today" WeekDay-Eng2( t_date ) + ", " +'                    + {&new-line} +
                 '  STRING( t_date, "99/99/9999":U )'                           + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                          + {&new-line}
      .
    end. /* WeekDay-Eng2 */
    when 'WeekDay-Eng3'
    then do: /* 43 */
      assign
        p-help = 'Возвращает короткое название (трехбуквенный код) дня недели ' +
                 'по-английски по дате.'                                        + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                               + {&new-line} +
                 "WeekDay-Eng3 RETURNS CHARACTER ( INPUT i-date AS DATE ) ."    + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                      + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l WeekDay-Eng3"                             + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                               + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                     + {&new-line} + {&new-line} +
                 'ASSIGN'                                                       + {&new-line} +
                 '  t_date = TODAY'                                             + {&new-line} +
                 '.'                                                            + {&new-line} +
                 'MESSAGE'                                                      + {&new-line} +
                 '  "Today" WeekDay-Eng3( t_date ) + ", " +'                    + {&new-line} +
                 '  STRING( t_date, "99/99/9999":U )'                           + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                          + {&new-line}
      .
    end. /* WeekDay-Eng3 */
    when 'WeekDay-Shrt3'
    then do: /* 44 */
      assign
        p-help = 'Возвращает короткое название (трехбуквенный код) дня недели по-русски '   +
                 'по дате.'                                                   + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                             + {&new-line} +
                 "WeekDay-Shrt3 RETURNS CHARACTER ( INPUT i-date AS DATE ) ." + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                    + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l WeekDay-Shrt3"                          + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                             + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                   + {&new-line} + {&new-line} +
                 'ASSIGN'                                                     + {&new-line} +
                 '  t_date = TODAY'                                           + {&new-line} +
                 '.'                                                          + {&new-line} +
                 'MESSAGE'                                                    + {&new-line} +
                 '  "Сегодня:" WeekDay-Shrt3( t_date ) + ", " +'              + {&new-line} +
                 '  STRING( t_date, "99/99/9999":U ) + " г."'                 + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                        + {&new-line}
      .
    end. /* WeekDay-Shrt3 */
    when 'DelEntry'
    then do: /* 45 */
      assign
        p-help = 'Снять отметку "выбрано" с записи. Возвращает "новый" список (без удаленной '  +
                 'записи).'                                                       + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                 + {&new-line} +
                 "DelEntry RETURNS CHARACTER ( INPUT i-list      AS CHARACTER"    + {&new-line} +
                 "                           , INPUT i-item      AS CHARACTER"    + {&new-line} +
                 "                           , INPUT i-delimiter AS CHARACTER"    + {&new-line} +
                 "                           ) ."                                 + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                     + {&new-line} +
                 '  i-list      - список, из которого нужно удалить элемент;'     + {&new-line} +
                 '  i-item      - элемент, который нужно удалить из списка;'      + {&new-line} +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'  + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                        + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l DelEntry"                                   + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL "":U .'     + {&new-line} +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'     + {&new-line} + {&new-line} +
                 'ASSIGN'                                                         + {&new-line} +
                 '  v_list = "Aa,Bb,Cc,xx,Dd,Ee,Ff"'                              + {&new-line} +
                 '  v_item = "xx"'                                                + {&new-line} +
                 '.'                                                              + {&new-line} +
                 'MESSAGE'                                                        + {&new-line} +
                 '  "Список:"                   v_list              SKIP( 0 )'    + {&new-line} +
                 '  "Элемент:"                          v_item      SKIP( 1 )'    + {&new-line} +
                 '  "После удаления:" DelEntry( v_list, v_item, ? ) SKIP( 0 )'    + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                            + {&new-line}
      .
    end. /* DelEntry */
    when 'addl-list'
    then do: /* 46 */
      assign
        p-help = 'Добавить новый элемент в список на последнее место. Возвращает "новый" '      +
                 'список (с добавленной записью).'                                + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                 + {&new-line} +
                 "addl-list RETURNS CHARACTER ( INPUT i-list      AS CHARACTER,"  + {&new-line} +
                 "                              INPUT i-item      AS CHARACTER,"  + {&new-line} +
                 "                            , INPUT i-delimiter AS CHARACTER"   + {&new-line} +
                 "                            ) ."                                + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                     + {&new-line} +
                 '  i-list      - список, из которого нужно удалить элемент;'     + {&new-line} +
                 '  i-item      - элемент, который нужно удалить из списка;'      + {&new-line} +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'  + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                        + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l addl-list"                                  + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL "":U .'     + {&new-line} +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'     + {&new-line} + {&new-line} +
                 'ASSIGN'                                                         + {&new-line} +
                 '  v_list = "Aa,Bb,Cc,Dd,Ee,Ff"'                                 + {&new-line} +
                 '  v_item = "xx"'                                                + {&new-line} +
                 '.'                                                              + {&new-line} +
                 'MESSAGE'                                                        + {&new-line} +
                 '  "Список:"                      v_list              SKIP( 0 )' + {&new-line} +
                 '  "Элемент:"                             v_item      SKIP( 1 )' + {&new-line} +
                 '  "После добавления:" addl-list( v_list, v_item, ? ) SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                            + {&new-line}
      .
    end. /* addl-list */
    when 'addf-list'
    then do: /* 47 */
      assign
        p-help = 'Добавить новый элемент в список на первое место. Возвращает "новый" '         +
                 'список (с добавленной записью).'                                + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                 + {&new-line} +
                 "addf-list RETURNS CHARACTER ( INPUT i-list      AS CHARACTER,"  + {&new-line} +
                 "                              INPUT i-item      AS CHARACTER,"  + {&new-line} +
                 "                            , INPUT i-delimiter AS CHARACTER"   + {&new-line} +
                 "                            ) ."                                + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                     + {&new-line} +
                 '  i-list      - список, из которого нужно удалить элемент;'     + {&new-line} +
                 '  i-item      - элемент, который нужно удалить из списка;'      + {&new-line} +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'  + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                        + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l addf-list"                                  + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL "":U .'     + {&new-line} +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'     + {&new-line} + {&new-line} +
                 'ASSIGN'                                                         + {&new-line} +
                 '  v_list = "Aa,Bb,Cc,Dd,Ee,Ff"'                                 + {&new-line} +
                 '  v_item = "xx"'                                                + {&new-line} +
                 '.'                                                              + {&new-line} +
                 'MESSAGE'                                                        + {&new-line} +
                 '  "Список:"                      v_list              SKIP( 0 )' + {&new-line} +
                 '  "Элемент:"                             v_item      SKIP( 1 )' + {&new-line} +
                 '  "После добавления:" addf-list( v_list, v_item, ? ) SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX.'                                             + {&new-line}
      .
    end. /* addf-list */
    when 'addn-list'
    then do: /* 48 */
      assign
        p-help = 'Добавить новый элемент в список на указанную позицию. Возвращает "новый" список (с добавленной '  +
                 'записью).'                                                            + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                       + {&new-line} +
                 "addn-list RETURNS CHARACTER ( INPUT i-list      AS CHARACTER"         + {&new-line} +
                 "                            , INPUT i-item      AS CHARACTER"         + {&new-line} +
                 "                            , INPUT i-delimiter AS CHARACTER"         + {&new-line} +
                 "                            , INPUT i-pos       AS INTEGER"           + {&new-line} +
                 "                            ) ."                                      + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                           + {&new-line} +
                 '  i-list      - список, из которого нужно удалить элемент;'           + {&new-line} +
                 '  i-item      - элемент, который нужно удалить из списка;'            + {&new-line} +
                 '  i-delimiter - разделитель в списке; если не указан, то ",";'        + {&new-line} +
                 '  i-pos       - номер позиции, на которую нужно добавить элемент.'    + {&new-line} + {&new-line} +
                 'Если номер позиции не указан или равен "0", то элемент добавляется на 1-ю позицию.' + {&new-line} +
                 'Если количество элементов в списке меньше указанной позиции, то '     +
                 'список "расширяется" пустыми '                                        + {&new-line} +
                 'значениями, и элемент добавляется на последнюю позицию.'              + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                              + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l addn-list"                                        + {&new-line} + {&new-line} +
                 "~{ cmp/str-glbl.i        ~}"                                          + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE jj      AS INTEGER   NO-UNDO INITIAL 0 .'             + {&new-line} +
                 'DEFINE VARIABLE j1      AS INTEGER   NO-UNDO INITIAL 0 .'             + {&new-line} +
                 'DEFINE VARIABLE v_delim AS CHARACTER NO-UNDO INITIAL "":U .'          + {&new-line} +
                 'DEFINE VARIABLE v_list  AS CHARACTER NO-UNDO INITIAL "":U .'          + {&new-line} +
                 'DEFINE VARIABLE v_item  AS CHARACTER NO-UNDO INITIAL "":U .'          + {&new-line} + {&new-line} +
                 'ASSIGN'                                                               + {&new-line} +
                 '  v_list  = "Aa,Bb,Cc,Dd,Ee,Ff,Gg,Hh"'                                + {&new-line} +
                 '  v_item  = "xx"'                                                     + {&new-line} +
                 '  v_delim = ~{~&comma-char~}'                                         + {&new-line} +
                 '  j1      = NUM-ENTRIES( v_list, v_delim )'                           + {&new-line} +
                 '.'                                                                    + {&new-line} +
                 'MESSAGE'                                                              + {&new-line} +
                 '  "Список:"           v_list j1  SKIP( 0 )'                           + {&new-line} +
                 '  "Разделитель:"      v_delim    SKIP( 0 )'                           + {&new-line} +
                 '  "Элемент:"          v_item "?" SKIP( 1 )'                           + {&new-line} +
                 '  "После добавления:" addn-list( v_list, v_item, v_delim, ? )'        + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                  + {&new-line} +
                 'DO jj = 1 TO j1 + 1 :'                                                + {&new-line} +
                 '  MESSAGE'                                                            + {&new-line} +
                 '    "Список:"           v_list j1 SKIP( 0 )'                          + {&new-line} +
                 '    "Разделитель:"      v_delim   SKIP( 0 )'                          + {&new-line} +
                 '    "Элемент:"          v_item jj SKIP( 1 )'                          + {&new-line} +
                 '    "После добавления:" addn-list( v_list, v_item, v_delim, jj )'     + {&new-line} +
                 '  VIEW-AS ALERT-BOX .'                                                + {&new-line} +
                 'END.'                                                                 + {&new-line} +
                 'MESSAGE'                                                              + {&new-line} +
                 '  "Список:"           v_list  j1     SKIP( 0 )'                       + {&new-line} +
                 '  "Разделитель:"      v_delim        SKIP( 0 )'                       + {&new-line} +
                 '  "Элемент:"          v_item  j1 * 2 SKIP( 1 )'                       + {&new-line} +
                 '  "После добавления:" addn-list( v_list, v_item, v_delim, j1 * 2 )'   + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                  + {&new-line}
      .
    end. /* addn-list */
    when 'super-pos'
    then do: /* 49 */
      assign
        p-help = 'Суперпозиция двух множеств, заданных списками. '                      +
                 'Возвращает результирующее множество (список).'                        + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                       + {&new-line} +
                 "super-pos RETURNS CHARACTER ( INPUT i-list-1    AS CHARACTER"         + {&new-line} +
                 "                            , INPUT i-list-2    AS CHARACTER"         + {&new-line} +
                 "                            , INPUT i-delimiter AS CHARACTER"         + {&new-line} +
                 "                            ) ."                                      + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                           + {&new-line} +
                 '  i-list-1    - 1-й список, из которого вычитается 2-й;'              + {&new-line} +
                 '  i-list-2    - 2-й список, который вычитается из 1-го;'              + {&new-line} +
                 '  i-delimiter - разделитель в списках; если не указан, то ",".'       + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                              + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l super-pos"                                        + {&new-line} + {&new-line} +
                 "~{ cmp/str-glbl.i        ~}"                                          + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_list1 AS CHARACTER NO-UNDO INITIAL "":U .'          + {&new-line} +
                 'DEFINE VARIABLE v_list2 AS CHARACTER NO-UNDO INITIAL "":U .'          + {&new-line} +
                 'DEFINE VARIABLE v_delim AS CHARACTER NO-UNDO INITIAL "":U .'          + {&new-line} + {&new-line} +
                 'ASSIGN'                                                               + {&new-line} +
                 '  v_list1 = "Aa,Bb,Cc,Dd,Ee,Ff,Gg,Hh"'                                + {&new-line} +
                 '  v_list2 = "Ff,Gg,Hh,Ii,Jj,Kk,Ll,Mm"'                                + {&new-line} +
                 '  v_delim = ~{~&comma-char~}'                                         + {&new-line} +
                 '.'                                                                    + {&new-line} +
                 'MESSAGE'                                                              + {&new-line} +
                 '  "1-й список:"                v_list1                     SKIP( 0 )' + {&new-line} +
                 '  "2-й список:"                         v_list2            SKIP( 0 )' + {&new-line} +
                 '  "Суперпозиция 1:" super-pos( v_list1, v_list2, v_delim ) SKIP( 0 )' + {&new-line} +
                 '  "Суперпозиция 2:" super-pos( v_list2, v_list1, v_delim ) SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                  + {&new-line}
      .
    end. /* super-pos */
    when 'sets-union'
    then do: /* 50 */
      assign
        p-help = 'Объединение двух множеств, заданных списками. '                     +
                 'Возвращает результирующее множество (список).'                      + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                     + {&new-line} +
                 "sets-union RETURNS CHARACTER ( INPUT i-list-1    AS CHARACTER"      + {&new-line} +
                 "                             , INPUT i-list-2    AS CHARACTER"      + {&new-line} +
                 "                             , INPUT i-delimiter AS CHARACTER"      + {&new-line} +
                 "                             ) ."                                   + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                         + {&new-line} +
                 '  i-list-1    - 1-й список;'                                        + {&new-line} +
                 '  i-list-2    - 2-й список;'                                        + {&new-line} +
                 '  i-delimiter - разделитель в списках; если не указан, то ",".'     + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                            + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l sets-union"                                     + {&new-line} + {&new-line} +
                 "~{ cmp/str-glbl.i        ~}"                                        + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                     + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_list1 AS CHARACTER NO-UNDO INITIAL "":U .'        + {&new-line} +
                 'DEFINE VARIABLE v_list2 AS CHARACTER NO-UNDO INITIAL "":U .'        + {&new-line} +
                 'DEFINE VARIABLE v_delim AS CHARACTER NO-UNDO INITIAL "":U .'        + {&new-line} + {&new-line} +
                 'ASSIGN'                                                             + {&new-line} +
                 '  v_list1 = "Aa,Bb,Cc,Dd,Ee,Ff,Gg,Hh"'                              + {&new-line} +
                 '  v_list2 = "Ff,Gg,Hh,Ii,Jj,Kk,Ll,Mm"'                              + {&new-line} +
                 '  v_delim = ~{~&comma-char~}'                                       + {&new-line} +
                 '.'                                                                  + {&new-line} +
                 'MESSAGE'                                                            + {&new-line} +
                 '  "1-й список:"              v_list1                     SKIP( 0 )' + {&new-line} +
                 '  "2-й список:"                       v_list2            SKIP( 0 )' + {&new-line} +
                 '  "Объединение:" sets-union( v_list1, v_list2, v_delim ) SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                + {&new-line}
      .
    end. /* sets-union */
    when 'ChooseMark'
    then do: /* 51 */
      assign
        p-help = 'Пометить / снять отметку "выбрано" с записи. Возвращает "новый" список (соответственно, '  +
                 'с помеченной или без помеченной записи).'                      + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                + {&new-line} +
                 "ChooseMark RETURNS CHARACTER ( INPUT i-list      AS CHARACTER" + {&new-line} +
                 "                             , INPUT i-item      AS CHARACTER" + {&new-line} +
                 "                             , INPUT i-delimiter AS CHARACTER" + {&new-line} +
                 "                             ) ."                              + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                    + {&new-line} +
                 '  i-list      - список;'                                       + {&new-line} +
                 '  i-item      - элемент;'                                      + {&new-line} +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".' + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                       + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l ChooseMark"                                + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_lst1 AS CHARACTER NO-UNDO INITIAL "":U .'    + {&new-line} +
                 'DEFINE VARIABLE v_lst2 AS CHARACTER NO-UNDO INITIAL "":U .'    + {&new-line} +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'    + {&new-line} + {&new-line} +
                 'ASSIGN'                                                        + {&new-line} +
                 '  v_lst1 = "Aa,Bb,Cc,xx,Dd,Ee,Ff"'                             + {&new-line} +
                 '  v_lst2 = "Aa,Bb,Cc,Dd,Ee,Ff"'                                + {&new-line} +
                 '  v_item = "xx"'                                               + {&new-line} +
                 '.'                                                             + {&new-line} +
                 'MESSAGE'                                                       + {&new-line} +
                 '  "Список:"                v_lst1              SKIP( 0 )'      + {&new-line} +
                 '  "Элемент:"                       v_item      SKIP( 0 )'      + {&new-line} +
                 '  "Результат:" ChooseMark( v_lst1, v_item, ? ) SKIP( 1 )'      + {&new-line} +
                 '  "Список:"                v_lst2              SKIP( 0 )'      + {&new-line} +
                 '  "Элемент:"                       v_item      SKIP( 0 )'      + {&new-line} +
                 '  "Результат:" ChooseMark( v_lst2, v_item, ? ) SKIP( 0 )'      + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                           + {&new-line}
      .
    end. /* ChooseMark */
    when 'is-marked'
    then do: /* 52 */
      assign
        p-help = 'Возвращает - помечена запись или нет.'                               + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                      + {&new-line} +
                 "is-marked RETURNS LOGICAL ( INPUT i-list      AS CHARACTER"          + {&new-line} +
                 "                          , INPUT i-item      AS CHARACTER"          + {&new-line} +
                 "                          , INPUT i-delimiter AS CHARACTER"          + {&new-line} +
                 "                          ) ."                                       + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                          + {&new-line} +
                 '  i-list      - список;'                                             + {&new-line} +
                 '  i-item      - элемент;'                                            + {&new-line} +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'       + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                             + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l is-marked"                                       + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                      + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_list  AS CHARACTER NO-UNDO INITIAL "":U .'         + {&new-line} +
                 'DEFINE VARIABLE v_item1 AS CHARACTER NO-UNDO INITIAL "":U .'         + {&new-line} +
                 'DEFINE VARIABLE v_item2 AS CHARACTER NO-UNDO INITIAL "":U .'         + {&new-line} + {&new-line} +
                 'ASSIGN'                                                              + {&new-line} +
                 '  v_list  = "Aa,Bb,Cc,xx,Dd,Ee,Ff"'                                  + {&new-line} +
                 '  v_item1 = "yy"'                                                    + {&new-line} +
                 '  v_item2 = "xx"'                                                    + {&new-line} +
                 '.'                                                                   + {&new-line} +
                 'MESSAGE'                                                             + {&new-line} +
                 '  "Список:"  v_list                                               SKIP( 1 )'       + {&new-line} +
                 '  "Элемент:" v_item1 "Результат:" is-marked( v_list, v_item1, ? ) SKIP( 0 )'       + {&new-line} +
                 '  "Элемент:" v_item2 "Результат:" is-marked( v_list, v_item2, ? ) SKIP( 0 )'       + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                 + {&new-line}
      .
    end. /* is-marked */
    when 'MarkSign'
    then do: /* 53 */
      assign
        p-help = 'Возвращает текущий знак помечено или свободно для записи.'              + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                         + {&new-line} +
                 "MarkSign RETURNS CHARACTER ( INPUT i-list      AS CHARACTER"            + {&new-line} +
                 "                           , INPUT i-item      AS CHARACTER"            + {&new-line} +
                 "                           , INPUT i-delimiter AS CHARACTER"            + {&new-line} +
                 "                           ) ."                                         + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                             + {&new-line} +
                 '  i-list      - список;'                                                + {&new-line} +
                 '  i-item      - элемент;'                                               + {&new-line} +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'          + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                                + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l MarkSign"                                           + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                         + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_lst1 AS CHARACTER NO-UNDO INITIAL "":U .'             + {&new-line} +
                 'DEFINE VARIABLE v_lst2 AS CHARACTER NO-UNDO INITIAL "":U .'             + {&new-line} +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'             + {&new-line} + {&new-line} +
                 'ASSIGN'                                                                 + {&new-line} +
                 '  v_lst1 = "Aa,Bb,Cc,xx,Dd,Ee,Ff"'                                      + {&new-line} +
                 '  v_lst2 = "Aa,Bb,Cc,Dd,Ee,Ff"'                                         + {&new-line} +
                 '  v_item = "xx"'                                                        + {&new-line} +
                 '.'                                                                      + {&new-line} +
                 'MESSAGE'                                                                + {&new-line} +
                 '  "Список:"                     v_lst1                     SKIP( 0 )'   + {&new-line} +
                 '  "Элемент:"                            v_item             SKIP( 0 )'   + {&new-line} +
                 '  "Результат:" "~~"" + MarkSign( v_lst1, v_item, ? ) + "~~"" SKIP( 1 )' + {&new-line} +
                 '  "Список:"                     v_lst2                     SKIP( 0 )'   + {&new-line} +
                 '  "Элемент:"                            v_item             SKIP( 0 )'   + {&new-line} +
                 '  "Результат:" "~~"" + MarkSign( v_lst2, v_item, ? ) + "~~"" SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                    + {&new-line}
      .
    end. /* MarkSign */
    when 'NumDays'
    then do: /* 54 */
      assign
        p-help = 'Возвращает порядковый номер дня с начала года.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                 + {&new-line} +
                 "NumDays RETURNS INTEGER ( INPUT DATE ) ."       + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                        + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l NumDays"                    + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                 + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'       + {&new-line} + {&new-line} +
                 'ASSIGN'                                         + {&new-line} +
                 '  t_date = TODAY'                               + {&new-line} +
                 '.'                                              + {&new-line} +
                 'MESSAGE'                                        + {&new-line} +
                 '  "Сегодня:"       t_date                         SKIP( 0 )'  + {&new-line} +
                 '  STRING( NumDays( t_date ) ) + "-й день в году." SKIP( 0 )'  + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                            + {&new-line}
      .
    end. /* NumDays */
    when 'DateNum'
    then do: /* 55 */
      assign
        p-help = 'Возвращает дату по порядковому номеру дня в году и году.'    + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                              + {&new-line} +
                 "DateNum RETURNS INTEGER ( INPUT i-days AS INTEGER"           + {&new-line} +
                 "                        , INPUT i-year AS INTEGER"           + {&new-line} +
                 "                        ) ."                                 + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                     + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l DateNum"                                 + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE j_days AS INTEGER NO-UNDO .'                 + {&new-line} +
                 'DEFINE VARIABLE j_year AS INTEGER NO-UNDO .'                 + {&new-line} + {&new-line} +
                 'ASSIGN'                                                      + {&new-line} +
                 '  j_days = 365'                                              + {&new-line} +
                 '  j_year = YEAR( TODAY )'                                    + {&new-line} +
                 '.'                                                           + {&new-line} +
                 'MESSAGE'                                                     + {&new-line} +
                 '  STRING( j_days ) + "-й день в" j_year "году - " SKIP( 0 )' + {&new-line} +
                 '  "это:" DateNum( j_days, j_year )                SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                         + {&new-line}
      .
    end. /* DateNum */
    when 'KeyStamp'
    then do: /* 56 */
      assign
        p-help = 'Возвращает ключ на основании текущих даты и времени.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                       + {&new-line} +
                 "KeyStamp RETURNS CHARACTER ."                         + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                              + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l KeyStamp"                         + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                       + {&new-line} + {&new-line} +
                 'MESSAGE'                                              + {&new-line} +
                 '  KeyStamp( ) SKIP( 0 )'                              + {&new-line} +
                 '  "Подождите 5 секунд..."'                            + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                  + {&new-line} +
                 'MESSAGE'                                              + {&new-line} +
                 '  KeyStamp( )'                                        + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                  + {&new-line}
      .
    end. /* KeyStamp */
    when 'Int2Hex'
    then do: /* 57 */
      assign
        p-help = 'Конвертация целого числа в его 16-ричное представление.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                          + {&new-line} +
                 "Int2Hex RETURNS CHARACTER ( INPUT INTEGER ) ."           + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                 + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Int2Hex"                             + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                          + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 1025 .' + {&new-line} + {&new-line} +
                 'MESSAGE'                                                 + {&new-line} +
                 '  j_num "-->" "0x" + Int2Hex( j_num )'                   + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                     + {&new-line}
      .
    end. /* Int2Hex */
    when 'Hex2Int'
    then do: /* 58 */
      assign
        p-help = 'Конвертация 16-ричного целого числа в 10-тичное.'          + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                            + {&new-line} +
                 "Hex2Int RETURNS INTEGER ( INPUT CHARACTER ) ."             + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                   + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Hex2Int"                               + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                            + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c_num AS CHARACTER NO-UNDO INITIAL "FF" .' + {&new-line} + {&new-line} +
                 'MESSAGE'                                                   + {&new-line} +
                 '  "0x" + c_num "-->" Hex2Int( c_num )'                     + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                       + {&new-line}
      .
    end. /* Hex2Int */
    when 'Int2Base'
    then do: /* 59 */
      assign
        p-help = 'Конвертация целого числа в представление по заданному основанию.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                   + {&new-line} +
                 "Int2Base RETURNS CHARACTER ( INPUT i-num  AS INTEGER"             + {&new-line} +
                 "                           , INPUT i-base AS INTEGER"             + {&new-line} +
                 "                           ) ."                                   + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                       + {&new-line} +
                 '  i-num  - целое число, которое нужно сконвертировать;'           + {&new-line} +
                 '  i-base - основание, по которому нужно сконвертировать число.'   + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                          + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Int2Base"                                     + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                   + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE j_num  AS INTEGER NO-UNDO INITIAL 1000 .'         + {&new-line} +
                 'DEFINE VARIABLE j_base AS INTEGER NO-UNDO INITIAL   60 .'         + {&new-line} + {&new-line} +
                 'MESSAGE'                                                          + {&new-line} +
                 '  j_num "-->" Int2Base( j_num, j_base )'                          + {&new-line} +
                 '  "по основанию" j_base'                                          + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                              + {&new-line}
      .
    end. /* Int2Base */
    when 'Base2Int'
    then do: /* 60 */
      assign
        p-help = 'Конвертация целого числа в целое число по заданному основанию.'  + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                  + {&new-line} +
                 "Base2Int RETURNS INTEGER ( INPUT i-image AS CHARACTER"           + {&new-line} +
                 "                         , INPUT i-base  AS INTEGER"             + {&new-line} +
                 "                         ) ."                                    + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                      + {&new-line} +
                 '  i-image - целое число, которое нужно сконвертировать;'         + {&new-line} +
                 '  i-base  - основание, по которому нужно сконвертировать число.' + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                         + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Base2Int"                                    + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c_num  AS CHARACTER NO-UNDO INITIAL "GЖ" .'      + {&new-line} +
                 'DEFINE VARIABLE j_base AS INTEGER   NO-UNDO INITIAL 60 .'        + {&new-line} + {&new-line} +
                 'MESSAGE'                                                         + {&new-line} +
                 '  c_num "по основанию" j_base "-->"'                             + {&new-line} +
                 '  Base2Int( c_num, j_base )'                                     + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                             + {&new-line}
      .
    end. /* Base2Int */
    when 'Base2Int64'
    then do: /* 60 */
      assign
        p-help = 'Конвертация целого числа в целое число по заданному основанию.'  + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                  + {&new-line} +
                 "Base2Int64 RETURNS INT64 ( INPUT i-image AS CHARACTER"           + {&new-line} +
                 "                         , INPUT i-base  AS INTEGER"             + {&new-line} +
                 "                         ) ."                                    + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                      + {&new-line} +
                 '  i-image - целое число, которое нужно сконвертировать;'         + {&new-line} +
                 '  i-base  - основание, по которому нужно сконвертировать число.' + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                         + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Base2Int64"                                  + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c_num  AS CHARACTER NO-UNDO INITIAL "GЖ" .'      + {&new-line} +
                 'DEFINE VARIABLE j_base AS INTEGER   NO-UNDO INITIAL 60 .'        + {&new-line} + {&new-line} +
                 'MESSAGE'                                                         + {&new-line} +
                 '  c_num "по основанию" j_base "-->"'                             + {&new-line} +
                 '  Base2Int64( c_num, j_base )'                                   + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                             + {&new-line}
      .
    end. /* Base2Int64 */
    when 'Int2Octal'
    then do: /* 61 */
      assign
        p-help = 'Конвертация целого числа в его 8-ричное представление.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                         + {&new-line} +
                 "Int2Octal RETURNS CHARACTER ( INPUT INTEGER ) ."        + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Int2Octal"                          + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 493 .' + {&new-line} + {&new-line} +
                 'MESSAGE'                                                + {&new-line} +
                 '  j_num "-->" Int2Octal( j_num )'                       + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                    + {&new-line}
      .
    end. /* Int2Octal */
    when 'Oct2Int'
    then do: /* 62 */
      assign
        p-help = 'Конвертация 8-ричного целого числа в 10-тичное.'            + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                             + {&new-line} +
                 "Oct2Int RETURNS INTEGER ( INPUT CHARACTER ) ."              + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                    + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Oct2Int"                                + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                             + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c_num AS CHARACTER NO-UNDO INITIAL "377" .' + {&new-line} + {&new-line} +
                 'MESSAGE'                                                    + {&new-line} +
                 '  c_num "-->" Oct2Int( c_num )'                             + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                        + {&new-line}
      .
    end. /* Oct2Int */
    when 'Int2Bin'
    then do: /* 63 */
      assign
        p-help = 'Конвертация целого числа в его двоичное представление.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                         + {&new-line} +
                 "Int2Bin RETURNS CHARACTER ( INPUT INTEGER ) ."          + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Int2Bin"                            + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 15 .'  + {&new-line} + {&new-line} +
                 'MESSAGE'                                                + {&new-line} +
                 '  j_num "-->" Int2Bin( j_num )'                         + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                    + {&new-line}
      .
    end. /* Int2Bin */
    when 'Bin2Int'
    then do: /* 64 */
      assign
        p-help = 'Конвертация двоичного целого числа в 10-тичное.'              + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                               + {&new-line} +
                 "Bin2Int RETURNS INTEGER ( INPUT CHARACTER ) ."                + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                      + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Bin2Int"                                  + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                               + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c_num AS CHARACTER NO-UNDO INITIAL "11111" .' + {&new-line} + {&new-line} +
                 'MESSAGE'                                                      + {&new-line} +
                 '  c_num "-->" Bin2Int( c_num )'                               + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                          + {&new-line}
      .
    end. /* Bin2Int */
    otherwise do:
      run GetFunctionHelp2 in this-procedure
        (  input p-name
        , output p-help
        ) .
    end.
  end case. /* p-name */
end procedure. /* GetFunctionHelp1 */

procedure GetFunctionHelp2 :
  define  input parameter p-name as character no-undo .
  define output parameter p-help as character no-undo .

  case p-name :
    when 'sets-intersection'
    then do: /* 65 */
      assign
        p-help = 'Пересечение двух множеств, заданных списками. '                            +
                 'Возвращает результирующее множество (список).'                             + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                            + {&new-line} +
                 "sets-intersection RETURNS CHARACTER ( INPUT i-list-1    AS CHARACTER"      + {&new-line} +
                 "                                    , INPUT i-list-2    AS CHARACTER"      + {&new-line} +
                 "                                    , INPUT i-delimiter AS CHARACTER"      + {&new-line} +
                 "                                    ) ."                                   + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                                                + {&new-line} +
                 '  i-list-1    - 1-й список;'                                               + {&new-line} +
                 '  i-list-2    - 2-й список;'                                               + {&new-line} +
                 '  i-delimiter - разделитель в списках; если не указан, то ",".'            + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                                   + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l sets-intersection"                                     + {&new-line} + {&new-line} +
                 "~{ cmp/str-glbl.i        ~}"                                               + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                            + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE v_list1 AS CHARACTER NO-UNDO INITIAL "":U .'               + {&new-line} +
                 'DEFINE VARIABLE v_list2 AS CHARACTER NO-UNDO INITIAL "":U .'               + {&new-line} +
                 'DEFINE VARIABLE v_delim AS CHARACTER NO-UNDO INITIAL "":U .'               + {&new-line} + {&new-line} +
                 'ASSIGN'                                                                    + {&new-line} +
                 '  v_list1 = "Aa,Bb,Cc,Dd,Ee,Ff,Gg,Hh"'                                     + {&new-line} +
                 '  v_list2 = "Ff,Gg,Hh,Ii,Jj,Kk,Ll,Mm"'                                     + {&new-line} +
                 '  v_delim = ~{~&comma-char~}'                                              + {&new-line} +
                 '.'                                                                         + {&new-line} +
                 'MESSAGE'                                                                   + {&new-line} +
                 '  "1-й список:"                     v_list1                     SKIP( 0 )' + {&new-line} +
                 '  "2-й список:"                              v_list2            SKIP( 0 )' + {&new-line} +
                 '  "Пересечение:" sets-intersection( v_list1, v_list2, v_delim ) SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                       + {&new-line}
      .
    end. /* sets-union */
    when 'Week-Num'
    then do: /* 66 */
      assign
        p-help = 'Возвращает номер недели по дате.'                   + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                     + {&new-line} +
                 "Week-Num RETURNS INTEGER ( INPUT DATE ) ."          + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                            + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Week-Num"                       + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                     + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO INITIAL ? .' + {&new-line} + {&new-line} +
                 'ASSIGN'                                             + {&new-line} +
                 '  t_date = TODAY'                                   + {&new-line} +
                 '.'                                                  + {&new-line} +
                 'MESSAGE'                                            + {&new-line} +
                 '  "Дата:"                   t_date   SKIP( 0 )'     + {&new-line} +
                 '  "Номер недели:" Week-Num( t_date ) SKIP( 0 )'     + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                + {&new-line}
      .
    end. /* Week-Num */
    when 'Week-From'
    then do: /* 67 */
      assign
        p-help = 'Возвращает дату начала недели.'                        + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                        + {&new-line} +
                 "Week-From RETURNS DATE ( INPUT i-week AS INTEGER,"     + {&new-line} +
                 "                       , INPUT i-year AS INTEGER"      + {&new-line} +
                 "                       ) ."                            + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                            + {&new-line} +
                 '  i-week - номер недели в году;'                       + {&new-line} +
                 '  i-year - год; если не указан, то берется текущий.'   + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                               + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Week-Num,Week-From"                + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                        + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE    NO-UNDO INITIAL ? .' + {&new-line} +
                 'DEFINE VARIABLE j_week AS INTEGER NO-UNDO INITIAL 0 .' + {&new-line} + {&new-line} +
                 'ASSIGN'                                                + {&new-line} +
                 '  t_date = TODAY'                                      + {&new-line} +
                 '  j_week = Week-Num( t_date )'                         + {&new-line} +
                 '.'                                                     + {&new-line} +
                 'MESSAGE'                                               + {&new-line} +
                 '  "Дата начала текущей недели:"'                       + {&new-line} +
                 '  Week-From( j_week, YEAR( t_date ) ) SKIP( 1 )'       + {&new-line} +
                 '  "Номер недели:" Week-Num( t_date )  SKIP( 0 )'       + {&new-line} +
                 '  "Текущая дата:" t_date              SKIP( 0 )'       + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                   + {&new-line}
      .
    end. /* Week-From */
    when 'Week-Till'
    then do: /* 68 */
      assign
        p-help = 'Возвращает дату окончания недели.'                     + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                        + {&new-line} +
                 "Week-Till RETURNS DATE ( INPUT i-week AS INTEGER"      + {&new-line} +
                 "                       , INPUT i-year AS INTEGER"      + {&new-line} +
                 "                       ) ."                            + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                            + {&new-line} +
                 '  i-week - номер недели в году;'                       + {&new-line} +
                 '  i-year - год; если не указан, то берется текущий.'   + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                               + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Week-Num,Week-Till"                + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                        + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE    NO-UNDO INITIAL ? .' + {&new-line} +
                 'DEFINE VARIABLE j_week AS INTEGER NO-UNDO INITIAL 0 .' + {&new-line} + {&new-line} +
                 'ASSIGN'                                                + {&new-line} +
                 '  t_date = TODAY'                                      + {&new-line} +
                 '  j_week = Week-Num( t_date )'                         + {&new-line} +
                 '.'                                                     + {&new-line} +
                 'MESSAGE'                                               + {&new-line} +
                 '  "Дата окончания текущей недели:"'                    + {&new-line} +
                 '  Week-Till( j_week, YEAR( t_date ) ) SKIP( 1 )'       + {&new-line} +
                 '  "Номер недели:" Week-Num( t_date )  SKIP( 0 )'       + {&new-line} +
                 '  "Текущая дата:" t_date              SKIP( 0 )'       + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                   + {&new-line}
      .
    end. /* Week-Till */
    when 'Week-Date'
    then do: /* 69 */
      assign
        p-help = 'Возвращает дату по номеру недели в году, номеру дня в '   +
                 'неделе и году.'                                           + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                           + {&new-line} +
                 "Week-Date RETURNS DATE ( INPUT i-week AS INTEGER"         + {&new-line} +
                 "                       , INPUT i-day  AS INTEGER"         + {&new-line} +
                 "                       , INPUT i-year AS INTEGER"         + {&new-line} +
                 "                       ) ."                               + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                               + {&new-line} +
                 '  i-week - номер недели в году;'                          + {&new-line} +
                 '  i-day  - номер дня в неделе (русский вариант);'         + {&new-line} +
                 '  i-year - год; если не указан, то берется текущий.'      + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                  + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Week-Num,Week-Date"                   + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                           + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE    NO-UNDO INITIAL ? .'    + {&new-line} +
                 'DEFINE VARIABLE j_week AS INTEGER NO-UNDO INITIAL 0 .'    + {&new-line} + {&new-line} +
                 'ASSIGN'                                                   + {&new-line} +
                 '  t_date = TODAY'                                         + {&new-line} +
                 '  j_week = Week-Num( t_date )'                            + {&new-line} +
                 '.'                                                        + {&new-line} +
                 'MESSAGE "Пятница на текущей неделе:"'                     + {&new-line} +
                 'MESSAGE "Пятница на текущей неделе:"'                     + {&new-line} +
                 '        Week-Date( j_week, 5, YEAR( t_date ) ) SKIP( 1 )' + {&new-line} +
                 '        "Номер недели:" Week-Num( t_date )     SKIP( 0 )' + {&new-line} +
                 '        "Текущая дата:" t_date                 SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                      + {&new-line}
      .
    end. /* Week-Date */
    when 'Week-Date-Eng'
    then do: /* 70 */
      assign
        p-help = 'Возвращает дату по номеру недели в году, номеру дня в ' +
                 'неделе и году.'                                         + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                         + {&new-line} +
                 "Week-Date-Eng RETURNS DATE ( INPUT i-week AS INTEGER"   + {&new-line} +
                 "                           , INPUT i-day  AS INTEGER"   + {&new-line} +
                 "                           , INPUT i-year AS INTEGER"   + {&new-line} +
                 "                           ) ."                         + {&new-line} + {&new-line} +
                 "ПАРАМЕТРЫ:"                                             + {&new-line} +
                 '  i-week - номер недели в году;'                        + {&new-line} +
                 '  i-day  - номер дня в неделе (русский вариант);'       + {&new-line} +
                 '  i-year - год; если не указан, то берется текущий.'    + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Week-Num,Week-Date-Eng"             + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE t_date AS DATE    NO-UNDO INITIAL ? .'  + {&new-line} +
                 'DEFINE VARIABLE j_week AS INTEGER NO-UNDO INITIAL 0 .'  + {&new-line} + {&new-line} +
                 'ASSIGN'                                                 + {&new-line} +
                 '  t_date = TODAY'                                       + {&new-line} +
                 '  j_week = Week-Num( t_date )'                          + {&new-line} +
                 '.'                                                      + {&new-line} +
                 'MESSAGE'                                                + {&new-line} +
                 '  "Пятница на текущей неделе:"'                         + {&new-line} +
                 '  Week-Date-Eng( j_week, 6, YEAR( t_date ) ) SKIP( 1 )' + {&new-line} +
                 '  "Номер недели:" Week-Num( t_date )         SKIP( 0 )' + {&new-line} +
                 '  "Текущая дата:" t_date                     SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                    + {&new-line}
      .
    end. /* Week-Date-Eng */
    when 'Leap-Year'
    then do: /* 71 */
      assign
        p-help = 'Возвращает, високосный ли год (по году).'                             + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                       + {&new-line} +
                 "Leap-Year RETURNS LOGICAL ( INPUT INTEGER ) ."                        + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                              + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Leap-Year"                                        + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + {&new-line} + {&new-line} +
                 'MESSAGE'                                                              + {&new-line} +
                 '  "Нынче"'                                                            + {&new-line} +
                 '  STRING( Leap-Year( YEAR( TODAY ) ), "високосный/не високосный":U )' + {&new-line} +
                 '  "год."'                                                             + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                  + {&new-line}
      .
    end. /* Leap-Year */
    when 'Leap-Year-d'
    then do: /* 72 */
      assign
        p-help = 'Возвращает, високосный ли год (по дате).'                       + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                 + {&new-line} +
                 "Leap-Year RETURNS LOGICAL ( INPUT DATE ) ."                     + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                        + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Leap-Year-d"                                + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + {&new-line} + {&new-line} +
                 'MESSAGE'                                                        + {&new-line} +
                 '  "Нынче"'                                                      + {&new-line} +
                 '  STRING( Leap-Year-d( TODAY ), "високосный/не високосный":U )' + {&new-line} +
                 '  "год."'                                                       + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                            + {&new-line}
      .
    end. /* Leap-Year-d */
    when 'Sparse'
    then do: /* 73 */
      assign
        p-help = 'Возвращает "разреженную" строку (буквы через пробел) для заголовков.' + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                       + {&new-line} +
                 "Sparse RETURNS CHARACTER ( INPUT CHARACTER ) ."                       + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                              + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Sparse"                                           + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO INITIAL "":U .'           + {&new-line} +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO INITIAL "":U .'           + {&new-line} + {&new-line} +
                 'ASSIGN'                                                               + {&new-line} +
                 '  c-str1 = "отчет о состоянии запаса и продажах (оборотная ведомость)"'             + {&new-line} +
                 '  c-str2 = Sparse( c-str1 )'                                          + {&new-line} +
                 '.'                                                                    + {&new-line} +
                 'MESSAGE'                                                              + {&new-line} +
                 '  ~'"~' + c-str1 + ~'"~' LENGTH( c-str1 ) SKIP( 1 )'                  + {&new-line} +
                 '  ~'"~' + c-str2 + ~'"~' LENGTH( c-str2 ) SKIP( 0 )'                  + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                  + {&new-line}
      .
    end. /* Sparse */
    when 'SparseSymbol'
    then do: /* 74 */
      assign
        p-help = 'Возвращает "разреженную" строку (буквы через символ).'                + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                       + {&new-line} +
                 "SparseSymbol RETURNS CHARACTER ( INPUT i-string AS CHARACTER"         + {&new-line} +
                 "                               , INPUT i-symbol AS CHARACTER"         + {&new-line} +
                 "                               ) ."                                   + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                              + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l SparseSymbol"                                     + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO INITIAL "":U .'           + {&new-line} +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO INITIAL "":U .'           + {&new-line} + {&new-line} +
                 'ASSIGN'                                                               + {&new-line} +
                 '  c-str1 = "отчет о состоянии запаса и продажах (оборотная ведомость)"'             + {&new-line} +
                 '  c-str2 = SparseSymbol( c-str1, "_" )'                               + {&new-line} +
                 '.'                                                                    + {&new-line} +
                 'MESSAGE'                                                              + {&new-line} +
                 '  ~'"~' + c-str1 + ~'"~' LENGTH( c-str1 ) SKIP( 1 )'                  + {&new-line} +
                 '  ~'"~' + c-str2 + ~'"~' LENGTH( c-str2 ) SKIP( 0 )'                  + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                  + {&new-line}
      .
    end. /* SparseSymBol */
    when 'Compress'
    then do: /* 75 */
      assign
        p-help = 'Возвращает "спрессованную" строку (без лишних пробелов, обратная к функции Sparce).' + {&new-line} +
                                                                                                         {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                        + {&new-line} +
                 "Compress RETURNS CHARACTER ( INPUT CHARACTER ) ."                      + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                               + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Sparse,Compress"                                   + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                        + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO INITIAL "":U .'            + {&new-line} +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO INITIAL "":U .'            + {&new-line} +
                 'DEFINE VARIABLE c-str3 AS CHARACTER NO-UNDO INITIAL "":U .'            + {&new-line} + {&new-line} +
                 'ASSIGN'                                                                + {&new-line} +
                 '  c-str1 = "отчет о состоянии запаса и продажах (оборотная ведомость)"'              + {&new-line} +
                 '  c-str2 = Sparse(   c-str1 )'                                         + {&new-line} +
                 '  c-str3 = Compress( c-str2 )'                                         + {&new-line} +
                 '.'                                                                     + {&new-line} +
                 'MESSAGE'                                                               + {&new-line} +
                 '  ~'"~' +     c-str1   + ~'"~' LENGTH( c-str1 ) SKIP( 0 )'             + {&new-line} +
                 '  ~'"~' +     c-str2   + ~'"~' LENGTH( c-str2 ) SKIP( 1 )'             + {&new-line} +
                 '  ~'"~' + LC( c-str3 ) + ~'"~' LENGTH( c-str3 ) SKIP( 0 )'             + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                   + {&new-line}
      .
    end. /* Compress */
    when 'CompressSymbol'
    then do: /* 76 */
      assign
        p-help = 'Возвращает "спрессованную" строку (без лишних символов, '             +
                 'обратная к функции SparceSymbol).'                                    + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                       + {&new-line} +
                 "CompressSymbol RETURNS CHARACTER ( INPUT i-string AS CHARACTER"       + {&new-line} +
                 "                                 , INPUT i-symbol AS CHARACTER"       + {&new-line} +
                 "                                 ) ."                                 + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                              + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l SparseSymbol,CompressSymbol"                      + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c-symb AS CHARACTER NO-UNDO INITIAL "_":U .'          + {&new-line} +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO INITIAL "":U .'           + {&new-line} +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO INITIAL "":U .'           + {&new-line} +
                 'DEFINE VARIABLE c-str3 AS CHARACTER NO-UNDO INITIAL "":U .'           + {&new-line} +
                 'DEFINE VARIABLE c-str4 AS CHARACTER NO-UNDO INITIAL "":U .'           + {&new-line} + {&new-line} +
                 'ASSIGN'                                                               + {&new-line} +
                 '  c-str1 = "отчет о состоянии запаса и продажах (оборотная ведомость)"'             + {&new-line} +
                 '  c-str2 = SparseSymbol(   c-str1, c-symb        )'                   + {&new-line} +
                 '  c-str3 = CompressSymbol( c-str2, c-symb        )'                   + {&new-line} +
                 '  c-str4 = REPLACE(        c-str3, c-symb, " ":U )'                   + {&new-line} +
                 '.'                                                                    + {&new-line} +
                 'MESSAGE'                                                              + {&new-line} +
                 '  ~'"~' +     c-str1   + ~'"~' LENGTH( c-str1 ) SKIP( 0 )'            + {&new-line} +
                 '  ~'"~' +     c-str2   + ~'"~' LENGTH( c-str2 ) SKIP( 1 )'            + {&new-line} +
                 '  ~'"~' + LC( c-str3 ) + ~'"~' LENGTH( c-str3 ) SKIP( 0 )'            + {&new-line} +
                 '  ~'"~' + LC( c-str4 ) + ~'"~' LENGTH( c-str4 ) SKIP( 0 )'            + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                  + {&new-line}
      .
    end. /* CompressSymBol */
    when 'MonthNameRusCase'
    then do: /* 77 */
      assign
        p-help = "Возвращает название месяца по-русски в падеже, заданном номером:" + {&new-line} +
                 "  1 - именительный;"                                              + {&new-line} +
                 "  2 - родительный;"                                               + {&new-line} +
                 "  3 - дательный;"                                                 + {&new-line} +
                 "  4 - винительный;"                                               + {&new-line} +
                 "  5 - творительный;"                                              + {&new-line} +
                 "  6 - предложный."                                                + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                   + {&new-line} +
                 "MonthNameCaseRus RETURNS CHARACTER ( INPUT Month AS INTEGER"      + {&new-line} +
                 "                                   , INPUT Case  AS INTEGER"      + {&new-line} +
                 "                                   ) ."                           + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                          + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l MonthNameRusCase"                             + {&new-line} + {&new-line} +
                 "~{ cmp/str-glbl.i        ~}"                                      + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                   + {&new-line} + {&new-line} +
                 "DEFINE VARIABLE jCase      AS INTEGER   NO-UNDO ."                + {&new-line} +
                 "DEFINE VARIABLE curr-month AS INTEGER   NO-UNDO ."                + {&new-line} +
                 "DEFINE VARIABLE word-month AS CHARACTER NO-UNDO EXTENT 6 ."       + {&new-line} +
                 "DEFINE VARIABLE l_log      AS LOGICAL   NO-UNDO INITIAL YES ."    + {&new-line} + {&new-line} +
                 "DO curr-month = 1 TO 12 :"                                                      + {&new-line} +
                 "  DO jCase = 1 TO EXTENT( word-month ) :"                                       + {&new-line} +
                 "    ASSIGN"                                                                     + {&new-line} +
                 "      word-month[ jCase ] = MonthNameRusCase( curr-month, jCase )"              + {&new-line} +
                 "    ."                                                                          + {&new-line} +
                 "  END. /* jCase */"                                                             + {&new-line} +
                 '  MESSAGE'                                                                      + {&new-line} +
                 '    "Месяц:" curr-month                             SKIP( 1 )'                  + {&new-line} +
                 '    "1) именительный:" ~{~&tabulation~} word-month[ 1 ] SKIP( 0 )'              + {&new-line} +
                 '    "2) родительный:"  ~{~&tabulation~} word-month[ 2 ] SKIP( 0 )'              + {&new-line} +
                 '    "3) дательный:"    ~{~&tabulation~} word-month[ 3 ] SKIP( 0 )'              + {&new-line} +
                 '    "4) винительный:"  ~{~&tabulation~} word-month[ 4 ] SKIP( 0 )'              + {&new-line} +
                 '    "5) творительный:" ~{~&tabulation~} word-month[ 5 ] SKIP( 0 )'              + {&new-line} +
                 '    "6) предложный:"   ~{~&tabulation~} word-month[ 6 ] SKIP( 1 )'              + {&new-line} +
                 '  VIEW-AS ALERT-BOX BUTTONS OK-CANCEL UPDATE l_log .'                           + {&new-line} +
                 '  IF l_log <> YES'                                                              + {&new-line} +
                 '  THEN DO:'                                                                     + {&new-line} +
                 '    LEAVE .'                                                                    + {&new-line} +
                 '  END.'                                                                         + {&new-line} +
                 "END. /* curr-month */"                                                          + {&new-line}
      .
    end. /* MonthNameRusCase */
    when 'Centering'
    then do: /* 78 */
      assign
        p-help = 'Возвращает отцентрированную строку.'                              + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                   + {&new-line} +
                 "Centering RETURNS CHARACTER ( INPUT InString AS CHARACTER,"       + {&new-line} +
                 "                              INPUT Lenght   AS INTEGER ) ."      + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                          + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Centering"                                    + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                   + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c-str1   AS CHARACTER NO-UNDO .'                  + {&new-line} +
                 'DEFINE VARIABLE c-str2   AS CHARACTER NO-UNDO .'                  + {&new-line} +
                 'DEFINE VARIABLE c-str3   AS CHARACTER NO-UNDO .'                  + {&new-line} +
                 'DEFINE VARIABLE j-length AS INTEGER   NO-UNDO .'                  + {&new-line} + {&new-line} +
                 'ASSIGN'                                                           + {&new-line} +
                 '  c-str1   = "отцентрированная строка"'                           + {&new-line} +
                 '  j-length = LENGTH( c-str1 )'                                    + {&new-line} +
                 '  c-str2   = Centering( c-str1, j-length + 5 )'                   + {&new-line} +
                 '  c-str3   = Centering( c-str1, j-length + 6 )'                   + {&new-line} +
                 '.'                                                                + {&new-line} +
                 'MESSAGE'                                                          + {&new-line} +
                 '  ~'"~' + c-str1 + ~'"~' LENGTH( c-str1 ) SKIP( 0 )'              + {&new-line} +
                 '  ~'"~' + c-str2 + ~'"~' LENGTH( c-str2 ) "  L:" INDEX( c-str2, c-str1 ) - 1'   + {&new-line} +
                 '  "R:" LENGTH( c-str2 ) - ( j-length + INDEX( c-str2, c-str1 ) ) + 1 SKIP( 0 )' + {&new-line} +
                 '  ~'"~' + c-str3 + ~'"~' LENGTH( c-str3 )  " L:" INDEX( c-str3, c-str1 ) - 1'   + {&new-line} +
                 '  "R:" LENGTH( c-str3 ) - ( j-length + INDEX( c-str3, c-str1 ) ) + 1 SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                            + {&new-line}
      .
    end. /* Centering */
    when 'CenteringSymbol'
    then do: /* 79 */
      assign
        p-help = 'Возвращает отцентрированную заданным символом строку.'                + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                       + {&new-line} +
                 "CenteringSymbol RETURNS CHARACTER ( INPUT InString AS CHARACTER,"     + {&new-line} +
                 "                                    INPUT Symbol   AS CHARACTER,"     + {&new-line} +
                 "                                    INPUT Lenght   AS INTEGER ) ."    + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                              + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Centering,CenteringSymbol"                        + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c-str1   AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE c-str2   AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE c-str3   AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE j-length AS INTEGER   NO-UNDO .'                      + {&new-line} + {&new-line} +
                 'ASSIGN'                                                               + {&new-line} +
                 '  c-str1   = "отцентрированная строка"'                               + {&new-line} +
                 '  j-length = LENGTH( c-str1 )'                                        + {&new-line} +
                 '  c-str2   = CenteringSymbol( '                                       +
                              'Centering( c-str1, j-length + 5 ), "*", j-length + 10 )' + {&new-line} +
                 '  c-str3   = CenteringSymbol( '                                       +
                              'Centering( c-str1, j-length + 6 ), "*", j-length + 12 )' + {&new-line} +
                 '.'                                                                    + {&new-line} +
                 'MESSAGE'                                                              + {&new-line} +
                 '  ~'"~' + c-str1 + ~'"~' LENGTH( c-str1 ) SKIP( 0 )'                  + {&new-line} +
                 '  ~'"~' + c-str2 + ~'"~' LENGTH( c-str2 ) "  L:" INDEX( c-str2, c-str1 ) - 1'       + {&new-line} +
                 '  "R:" LENGTH( c-str2 ) - ( j-length + INDEX( c-str2, c-str1 ) ) + 1 SKIP( 0 )'     + {&new-line} +
                 '  ~'"~' + c-str3 + ~'"~' LENGTH( c-str3 )  " L:" INDEX( c-str3, c-str1 ) - 1'       + {&new-line} +
                 '  "R:" LENGTH( c-str3 ) - ( j-length + INDEX( c-str3, c-str1 ) ) + 1 SKIP( 0 )'     + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                                + {&new-line}
      .
    end. /* CenteringSymbol */
    when 'ShiftRight'
    then do: /* 80 */
      assign
        p-help = 'Возвращает отцентрированную строку.'                         + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                              + {&new-line} +
                 "ShiftRight RETURNS CHARACTER ( INPUT InString AS CHARACTER"  + {&new-line} +
                 "                             , INPUT Lenght   AS INTEGER"    + {&new-line} +
                 "                             ) ."                            + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                     + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l ShiftRight"                              + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c-str0   AS CHARACTER NO-UNDO .'             + {&new-line} +
                 'DEFINE VARIABLE c-str1   AS CHARACTER NO-UNDO .'             + {&new-line} +
                 'DEFINE VARIABLE c-str2   AS CHARACTER NO-UNDO .'             + {&new-line} +
                 'DEFINE VARIABLE c-str3   AS CHARACTER NO-UNDO .'             + {&new-line} +
                 'DEFINE VARIABLE j-length AS INTEGER   NO-UNDO .'             + {&new-line} + {&new-line} +
                 'ASSIGN'                                                      + {&new-line} +
                 '  c-str1   = "сдвинуть вправо"'                              + {&new-line} +
                 '  j-length = LENGTH( c-str1 )'                               + {&new-line} +
                 '  c-str2   = ShiftRight( c-str1, j-length + j-length     )'  + {&new-line} +
                 '  c-str3   = ShiftRight( c-str1, j-length + j-length + 1 )'  + {&new-line} +
                 '  c-str0   = ShiftRight( c-str1, 10                      )'  + {&new-line} +
                 '.'                                                           + {&new-line} +
                 'MESSAGE'                                                     + {&new-line} +
                 '  ~'"~' + c-str1 + ~'"~'      LENGTH( c-str1 ) '             +
                   '                            SKIP( 0 )'                     + {&new-line} +
                 '  ~'"~' + c-str2 + ~'"~' "  " LENGTH( c-str2 ) '             +
                   'INDEX( c-str2, c-str1 ) - 1 SKIP( 0 )'                     + {&new-line} +
                 '  ~'"~' + c-str3 + ~'"~' " "  LENGTH( c-str3 ) '             +
                   'INDEX( c-str3, c-str1 ) - 1 SKIP( 0 )'                     + {&new-line} +
                 '  ~'"~' + c-str0 + ~'"~'      LENGTH( c-str0 ) '             +
                   '                            SKIP( 0 )'                     + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                         + {&new-line}
      .
    end. /* ShiftRight */
    when 'ShiftRightSymbol'
    then do: /* 81 */
      assign
        p-help = 'Возвращает отцентрированную строку.'                               + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                    + {&new-line} +
                 "ShiftRightSymbol RETURNS CHARACTER ( INPUT InString AS CHARACTER"  + {&new-line} +
                 "                                   , INPUT Symbol   AS CHARACTER"  + {&new-line} +
                 "                                   , INPUT Lenght   AS INTEGER"    + {&new-line} + {&new-line} +
                 "                                   ) ."                            + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                           + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l ShiftRightSymbol"                              + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                    + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c-str1   AS CHARACTER NO-UNDO .'                   + {&new-line} +
                 'DEFINE VARIABLE c-str2   AS CHARACTER NO-UNDO .'                   + {&new-line} +
                 'DEFINE VARIABLE c-str3   AS CHARACTER NO-UNDO .'                   + {&new-line} +
                 'DEFINE VARIABLE j-length AS INTEGER   NO-UNDO .'                   + {&new-line} + {&new-line} +
                 'ASSIGN'                                                            + {&new-line} +
                 '  c-str1   = "сдвинуть вправо"'                                    + {&new-line} +
                 '  j-length = LENGTH( c-str1 )'                                     + {&new-line} +
                 '  c-str2   = ShiftRightSymbol( c-str1, "*", j-length + j-length     )'           + {&new-line} +
                 '  c-str3   = ShiftRightSymbol( c-str1, "*", j-length + j-length + 1 )'           + {&new-line} +
                 '.'                                                                 + {&new-line} +
                 'MESSAGE'                                                           + {&new-line} +
                 '  ~'"~' + c-str1 + ~'"~'      LENGTH( c-str1 ) '                   +
                   '                            SKIP( 0 )'                           + {&new-line} +
                 '  ~'"~' + c-str2 + ~'"~' "  " LENGTH( c-str2 ) '                   +
                   'INDEX( c-str2, c-str1 ) - 1 SKIP( 0 )'                           + {&new-line} +
                 '  ~'"~' + c-str3 + ~'"~' " "  LENGTH( c-str3 ) '                   +
                   'INDEX( c-str3, c-str1 ) - 1 SKIP( 0 )'                           + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                               + {&new-line}
      .
    end. /* ShiftRightSymbol */
    when 'Digital'
    then do: /* 82 */
      assign
        p-help = 'Возвращает, состоит ли строка только из цифр и десятичной точки.'   + {&new-line} + {&new-line} +
                 "ФОРМАТ ВЫЗОВА:"                                                     + {&new-line} +
                 "Digital RETURNS LOGICAL ( INPUT CHARACTER ) ."                      + {&new-line} + {&new-line} +
                 "ПРИМЕР:"                                                            + {&new-line} + {&new-line} +
                 '/* **************************************************** *\' + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Файл: stdfnhlp.p                                     *'  + {&new-line} +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + {&new-line} +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + {&new-line} +
                 ' *                                                      *'  + {&new-line} +
                 '\* **************************************************** */' + {&new-line} + {&new-line} +
                 "~&SCOPED-DEFINE f-l Digital"                                        + {&new-line} + {&new-line} +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                     + {&new-line} + {&new-line} +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE c-str3 AS CHARACTER NO-UNDO .'                      + {&new-line} +
                 'DEFINE VARIABLE c-str4 AS CHARACTER NO-UNDO .'                      + {&new-line} + {&new-line} +
                 'ASSIGN'                                                             + {&new-line} +
                 '  c-str1 = "-123456789.0"'                                          + {&new-line} +
                 '  c-str2 = "+123456789.0"'                                          + {&new-line} +
                 '  c-str3 = "0.987654321"'                                           + {&new-line} +
                 '  c-str4 = "1234567890-0987654321"'                                 + {&new-line} +
                 '.'                                                                  + {&new-line} +
                 'MESSAGE'                                                            + {&new-line} +
                 '  ~'"~' + c-str1 + ~'"~''                                           +
                  ' STRING( Digital( c-str1 ), "ЧИСЛО/СТРОКА":U )'                    + {&new-line} +
                 '  ( IF Digital( c-str1 ) THEN INTEGER( c-str1 ) ELSE ? ) SKIP( 0 )' + {&new-line} +
                 '  ~'"~' + c-str2 + ~'"~''                                           +
                  ' STRING( Digital( c-str2 ), "ЧИСЛО/СТРОКА":U )'                    + {&new-line} +
                 '  ( IF Digital( c-str2 ) THEN INTEGER( c-str2 ) ELSE ? ) SKIP( 0 )' + {&new-line} +
                 '  ~'"~' + c-str3 + ~'"~''                                           +
                  ' STRING( Digital( c-str3 ), "ЧИСЛО/СТРОКА":U )'                    + {&new-line} +
                 '  ( IF Digital( c-str3 ) THEN INTEGER( c-str3 ) ELSE ? ) SKIP( 0 )' + {&new-line} +
                 '  ~'"~' + c-str4 + ~'"~''                                           +
                  ' STRING( Digital( c-str4 ), "ЧИСЛО/СТРОКА":U )'                    + {&new-line} +
                 '  ( IF Digital( c-str4 ) THEN INTEGER( c-str4 ) ELSE ? ) SKIP( 0 )' + {&new-line} +
                 'VIEW-AS ALERT-BOX .'                                                + {&new-line}
      .
    end. /* Digital */
    when '':U or
    when ?
    then do:
      assign
        p-help = 'Не задано имя функции.'
      .
    end.
    otherwise do:
      assign
        p-help = substitute( 'Описание функции "&1" пока отсутствует.'
                           , p-name
                           )
      .
    end.
  end case. /* p-name */
end procedure. /* GetFunctionHelp2 */

/* $Workfile: stdfnhlp.p $   E n d */