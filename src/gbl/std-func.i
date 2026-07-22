/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

стандартные функции

Автор: Булгаков Андрей Николаевич
Дата создания: 09/08/05
Author: Andrew Bulgakoff
Creation date: 09/08/05

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
+FUNCTION Sparse            RETURNS CHARACTER ( INPUT i-instring   AS CHARACTER ) - возвращает "разреженную" строку (буквы через пробел) для заголовков;
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

  &IF DEFINED( Std-Func_i ) = 0 &THEN

    &IF DEFINED( str-glbl_i ) = 0 &THEN
{ cmp/str-glbl.i }
    &ENDIF

/* ************************  Definitions  ************************ */
/* Preprocessor Definitions */
&GLOB Std-Func_i
&GLOB Std-Func_vss-revision    '$Revision$ ':U
&GLOB Std-Func_vss-author      '$Author$ ':U
&GLOB Std-Func_vss-date        '$Date$ ':U
&GLOB Std-Func_vss-workfile    '$Workfile$ ':U
&GLOB Std-Func_vss-archive     '$Archive$ ':U
&GLOB Std-Func_vss-description 'стандартные функции ':U

&IF DEFINED( Std-Func_function-number ) <> 0 &THEN
  &UNDEF Std-Func_function-number
&ENDIF
&IF DEFINED( Std-Func_function-list ) <> 0 &THEN
  &UNDEF Std-Func_function-list
&ENDIF

&GLOB Std-Func_function-number 80
&GLOB Std-Func_function-list   'LastMonthDate,LastMonthDay,LastDay-MY,LastDate-MY,NextMonth,NextYear,PrevMonth,PrevYear,NextMonth-MY,NextYear-MY,MonthNameRus,MonthNameRusGen,MonthNameRusCase,CalcMonthes,CalcMonth-MY,DateTimeHeader,PrevMonth-MY,PrevYear-MY,MonthNameEng,TimeStamp,Round-M,Trunc-M,get-dec,RedLine,Word-Sum,Total-Word,PutAcc,Roubles,Copecks,Word-Sum-Eng,Word-Curr,Int2Char,PutInt,PutSum,Stamp57,WeekDay-Full,WeekDay-Short,WeekDay-Shrt3,WeekDay-Rus,WeekDay-Full-Eng,WeekDay-Eng2,WeekDay-Eng3,Week-Num,Week-From,Week-Till,Week-Date,Week-Date-Eng,Rec2Char,DelEntry,addl-list,addf-list,addn-list,super-pos,sets-union,sets-intersection,ChooseMark,is-marked,MarkSign,Int2Hex,Hex2Int,Int2Octal,Oct2Int,Int2Bin,Bin2Int,Int2Base,Base2Int,Base2Int64,DateNum,NumDays,KeyStamp,Leap-Year,Leap-Year-d,Sparse,SparseSymbol,Compress,CompressSymbol,Centering,CenteringSymbol,ShiftRight,ShiftRightSymbol,Digital'
&SCOP Std-Func_function-used    LastMonthDate,LastMonthDay,LastDay-MY,LastDate-MY,NextMonth,NextYear,PrevMonth,PrevYear,NextMonth-MY,NextYear-MY,MonthNameRus,MonthNameRusGen,CalcMonthes,CalcMonth-MY,DateTimeHeader
&SCOP Std-Func_func_not_used   ^Word-Sum,^TimeStamp,^RedLine,^get-dec,^Trunc-M,^Round-M,^MonthNameEng,^PrevMonth-MY,^PrevYear-MY,^Total-Word,^PutAcc,^Roubles,^Copecks,^Word-Sum-Eng,^Word-Curr,^Int2Char,^PutInt,^PutSum,^Stamp57,^WeekDay-Full,^WeekDay-Short,^WeekDay-Shrt3,^WeekDay-Rus,^WeekDay-Full-Eng,^WeekDay-Eng2,^WeekDay-Eng3,^Week-Num,^Week-From,^Week-Till,^Week-Date,^Week-Date-Eng,^Rec2Char,^DelEntry,^addl-list,^addf-list,^addn-list,^super-pos,^sets-union,^sets-intersection,^ChooseMark,^is-marked,^MarkSign,^Int2Hex,^Hex2Int,^Int2Octal,^Oct2Int,^Int2Bin,^Bin2Int,^Int2Base,^Base2Int,^Base2Int64,^DateNum,^NumDays,^KeyStamp,Leap-Year,Leap-Year-d,^Sparse,^SparseSymbol,^Compress,^CompressSymbol,^MonthNameRusCase,^Centering,^CenteringSymbol,^ShiftRight,^ShiftRightSymbol,^Digital

  &IF DEFINED( Std-Func_defined-list ) = 0 &THEN
&IF "{1}" = "" &THEN
  &SCOP Std-Func_defined-list '{&Std-Func_function-used},{&Std-Func_func_not_used}'
&ELSEIF "{1}" = "def" OR "{1}" = "help" &THEN
  &SCOP Std-Func_defined-list ' '
&ELSE
  &SCOP Std-Func_defined-list '{1}'
&ENDIF
  &ENDIF

&IF "{1}" = "help" &THEN
  run gbl/stdfnhlp.p ( INPUT &IF "{2}" <> "" &THEN "{2}" &ELSE ? &ENDIF ).
&ENDIF

&SCOP MinMaxDay 28
&SCOP MinDelta   4

&SCOP  SELF-NAME LastMonthDate
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION LastMonthDate RETURNS DATE    ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE t_date AS DATE NO-UNDO.

  RUN get-last-month-date IN THIS-PROCEDURE ( INPUT i-date, OUTPUT t_date ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE t_date ).
END FUNCTION. /* LastMonthDate */
    &ENDIF

PROCEDURE get-last-month-date :
  DEFINE  INPUT PARAMETER p-curr-date AS DATE NO-UNDO.
  DEFINE OUTPUT PARAMETER p-last-date AS DATE NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-last-date = DATE( MONTH( p-curr-date ), {&MinMaxDay},  YEAR( p-curr-date ) ).
    ASSIGN p-last-date = p-last-date - DAY( p-last-date + {&MinDelta} ) + {&MinDelta}.
  END. /* ON ERROR */
END PROCEDURE. /* get-last-month-date */

  &ENDIF

&UNDEF SELF-NAME

&SCOP  SELF-NAME LastMonthDay
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION LastMonthDay  RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_day AS INTEGER NO-UNDO.

  RUN get-last-month-day IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_day ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_day ).
END FUNCTION. /* LastMonthDay */
    &ENDIF

PROCEDURE get-last-month-day :
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-day  AS INTEGER NO-UNDO.

  DEFINE VARIABLE t_date AS DATE NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN t_date = DATE( MONTH( p-date ), {&MinMaxDay},  YEAR( p-date ) ).
    ASSIGN p-day  = DAY( t_date - DAY( t_date + {&MinDelta} ) + {&MinDelta} ).
  END. /* ON ERROR */
END PROCEDURE. /* get-last-month-day */

  &ENDIF

&UNDEF SELF-NAME

&SCOP  SELF-NAME LastDay-MY
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION LastDay-MY  RETURNS INTEGER ( INPUT i-month AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE j_day AS INTEGER NO-UNDO.

  RUN get-last-day-MY IN THIS-PROCEDURE ( INPUT i-month, INPUT i-year, OUTPUT j_day ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_day ).
END FUNCTION. /* LastDay-MY */
    &ENDIF

PROCEDURE get-last-day-MY :
  DEFINE  INPUT PARAMETER p-month AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year  AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-day   AS INTEGER NO-UNDO.

  DEFINE VARIABLE t_date AS DATE NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN t_date = DATE( p-month, {&MinMaxDay}, p-year ).
    ASSIGN p-day  = DAY( t_date - DAY( t_date + {&MinDelta} ) + {&MinDelta} ).
  END. /* ON ERROR */
END PROCEDURE. /* get-last-day-MY */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME LastDate-MY
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION LastDate-MY RETURNS DATE    ( INPUT i-month AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE t_date AS DATE NO-UNDO.

  RUN get-last-date-MY IN THIS-PROCEDURE ( INPUT i-month, INPUT i-year, OUTPUT t_date ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE t_date ).
END FUNCTION. /* LastDate-MY */
    &ENDIF

PROCEDURE get-last-date-MY :
  DEFINE  INPUT PARAMETER p-month AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year  AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-date  AS DATE    NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-date = DATE( p-month, {&MinMaxDay}, p-year ).
    ASSIGN p-date = p-date - DAY( p-date + {&MinDelta} ) + {&MinDelta}.
  END. /* ON ERROR */
END PROCEDURE. /* get-last-date-MY */

  &ENDIF

&UNDEF SELF-NAME

&UNDEF MinMaxDay
&UNDEF MinDelta

&SCOP  SELF-NAME NextMonth
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION NextMonth RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_month AS INTEGER NO-UNDO.

  RUN get-next-month IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_month ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month ).
END FUNCTION. /* NextMonth */
    &ENDIF

PROCEDURE get-next-month :
  DEFINE  INPUT PARAMETER p-date  AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-month AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-month = ( MONTH( p-date ) MODULO 12 ) + 1.
  END. /* ON ERROR */
END PROCEDURE. /* get-next-month */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME NextYear
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION NextYear  RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_year AS INTEGER NO-UNDO.

  RUN get-next-year IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_year ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_year ).
END FUNCTION. /* NextYear */
    &ENDIF

PROCEDURE get-next-year :
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-year AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-year = YEAR( p-date ) + ( IF MONTH( p-date ) < 12 THEN 0 ELSE 1 ).
  END. /* ON ERROR */
END PROCEDURE. /* get-next-year */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME PrevMonth
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION PrevMonth RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_month AS INTEGER NO-UNDO.

  RUN get-prev-month IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_month ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month ).
END FUNCTION. /* PrevMonth */
    &ENDIF

PROCEDURE get-prev-month :
  DEFINE  INPUT PARAMETER p-date  AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-month AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-month = ( ( ( MONTH( p-date ) + 10 ) MODULO 12 ) MODULO 12 ) + 1.
  END. /* ON ERROR */
END PROCEDURE. /* get-prev-month */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME PrevYear
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION PrevYear  RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j_year AS INTEGER NO-UNDO.

  RUN get-prev-year IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_year ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_year ).
END FUNCTION. /* PrevYear */
    &ENDIF

PROCEDURE get-prev-year :
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-year AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-year = YEAR( p-date ) + ( IF MONTH( p-date ) = 1 THEN -1 ELSE 0 ).
  END. /* ON ERROR */
END PROCEDURE. /* get-prev-year */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME NextMonth-MY
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION NextMonth-MY RETURNS INTEGER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE j_month AS INTEGER NO-UNDO.

  RUN get-next-month-MY IN THIS-PROCEDURE ( INPUT i-month, OUTPUT j_month ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month ).
END FUNCTION. /* NextMonth-MY */
    &ENDIF

PROCEDURE get-next-month-MY :
  DEFINE  INPUT PARAMETER p-curr-month AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-next-month AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-next-month = ( p-curr-month MODULO 12 ) + 1.
  END. /* ON ERROR */
END PROCEDURE. /* get-next-month-MY */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME NextYear-MY
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION NextYear-MY  RETURNS INTEGER ( INPUT i-month AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE j_year AS INTEGER NO-UNDO.

  RUN get-next-year-MY IN THIS-PROCEDURE ( INPUT i-month, INPUT i-year, OUTPUT j_year ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_year ).
END FUNCTION. /* NextYear-MY */
    &ENDIF

PROCEDURE get-next-year-MY :
  DEFINE  INPUT PARAMETER p-curr-month AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr-year  AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-next-year  AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-next-year = p-curr-year + ( IF p-curr-month < 12 THEN 0 ELSE 1 ).
  END. /* ON ERROR */
END PROCEDURE. /* get-next-year-MY */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME MonthNameRus
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION MonthNameRus RETURNS CHARACTER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.

  RUN get-month-name-rus IN THIS-PROCEDURE ( INPUT i-month, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION. /* MonthNameRus */
    &ENDIF

PROCEDURE get-month-name-rus :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO INITIAL "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь".

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-name = ( IF p-month >= 1 AND p-month <= 12 THEN ENTRY( p-month, v-list ) ELSE ? ).
  END. /* ON ERROR */
END PROCEDURE. /* get-month-name-rus */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME MonthNameRusGen
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION MonthNameRusGen RETURNS CHARACTER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.

  RUN get-month-name-gen IN THIS-PROCEDURE ( INPUT i-month, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION. /* MonthNameRusGen */
    &ENDIF

PROCEDURE get-month-name-gen :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO INITIAL "Января,Февраля,Марта,Апреля,Мая,Июня,Июля,Августа,Сентября,Октября,Ноября,Декабря".

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-name = ( IF p-month >= 1 AND p-month <= 12 THEN ENTRY( p-month, v-list ) ELSE ? ).
  END. /* ON ERROR */
END PROCEDURE. /* get-month-name-gen */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME MonthNameRusCase
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION MonthNameRusCase RETURNS CHARACTER ( INPUT i-month AS INTEGER, INPUT i-case AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.

  RUN get-month-name-case IN THIS-PROCEDURE ( INPUT i-month, INPUT i-case, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION. /* MonthNameRusCase */
    &ENDIF

PROCEDURE get-month-name-case :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-case  AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO EXTENT 6 INITIAL
    [ "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь",
      "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря",
      "Январю,Февралю,Марту,Апрелю,Маю,Июню,Июлю,Августу,Сентябрю,Октябрю,Ноябрю,Декабрю",
      "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь",
      "Январем,Февралем,Мартом,Апрелем,Маем,Июнем,Июлем,Августом,Сентябрем,Октябрем,Ноябрем,Декабрем",
      "Январе,Феврале,Марте,Апреле,Мае,Июне,Июле,Августе,Сентябре,Октябре,Ноябре,Декабре"              ].

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-month < 1 OR p-month > 12 OR
       p-case  < 1 OR p-case  >  6 THEN DO:
      ASSIGN p-name = ?.
    END.                           ELSE DO:
      ASSIGN p-name = ENTRY( p-month, v-list[ p-case ] ).
    END.
  END. /* ON ERROR */
END PROCEDURE. /* get-month-name-case */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME CalcMonthes
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION CalcMonthes  RETURNS INTEGER ( INPUT i-date-from AS DATE, INPUT i-date-till AS DATE ) :
  DEFINE VARIABLE j_month-num AS INTEGER NO-UNDO.

  RUN get-month-number IN THIS-PROCEDURE ( INPUT i-date-from, INPUT i-date-till, OUTPUT j_month-num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month-num ).
END FUNCTION. /* CalcMonthes */
    &ENDIF

PROCEDURE get-month-number :
  DEFINE  INPUT PARAMETER p-date-from AS DATE    NO-UNDO.
  DEFINE  INPUT PARAMETER p-date-till AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-month-num AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-month-num = ( YEAR(  p-date-till ) - YEAR(  p-date-from ) ) * 12 +
                           MONTH( p-date-till ) - MONTH( p-date-from )   +  1 .
  END. /* ON ERROR */
END PROCEDURE. /* get-month-number */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME CalcMonth-MY
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION CalcMonth-MY RETURNS INTEGER ( INPUT i-year-from  AS INTEGER,
                                        INPUT i-month-from AS INTEGER,
                                        INPUT i-year-till  AS INTEGER,
                                        INPUT i-month-till AS INTEGER  ) :
  DEFINE VARIABLE j_month-num AS INTEGER NO-UNDO.

  RUN get-month-num-MY IN THIS-PROCEDURE (  INPUT i-year-from,
                                            INPUT i-month-from,
                                            INPUT i-year-till,
                                            INPUT i-month-till,
                                           OUTPUT j_month-num   ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month-num ).
END FUNCTION. /* CalcMonth-MY */
    &ENDIF

PROCEDURE get-month-num-MY :
  DEFINE  INPUT PARAMETER p-year-from  AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-month-from AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year-till  AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-month-till AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-month-num  AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-month-num = ( p-year-till - p-year-from ) * 12 + p-month-till - p-month-from + 1.
  END. /* ON ERROR */
END PROCEDURE. /* get-month-num-MY */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME DateTimeHeader
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION DateTimeHeader RETURNS CHARACTER ( INPUT i-date AS DATE ) : /* возвращает текущую дату и время печати; длина 30 */
  DEFINE VARIABLE v-header AS CHARACTER NO-UNDO.

  RUN get-date-time-header IN THIS-PROCEDURE ( INPUT i-date, OUTPUT v-header ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-header ).
END FUNCTION. /* DateTimeHeader */
    &ENDIF

PROCEDURE get-date-time-header :
  DEFINE  INPUT PARAMETER p-date AS DATE      NO-UNDO.
  DEFINE OUTPUT PARAMETER p-head AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END.
    ASSIGN p-head = "Дата печати: " + STRING( p-date, "99.99.9999":U ) + ", ":U + STRING( TIME, "HH:MM":U ).
  END. /* ON ERROR */
END PROCEDURE. /* get-date-time-header */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME PrevMonth-MY
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION PrevMonth-MY RETURNS INTEGER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE j_month AS INTEGER NO-UNDO.

  RUN get-prev-month-MY IN THIS-PROCEDURE ( INPUT i-month, OUTPUT j_month ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_month ).
END FUNCTION. /* PrevMonth-MY */
    &ENDIF

PROCEDURE get-prev-month-MY :
  DEFINE  INPUT PARAMETER p-curr-month AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-prev-month AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-prev-month = ( ( ( p-curr-month + 10 ) MODULO 12 ) MODULO 12 ) + 1.
  END. /* ON ERROR */
END PROCEDURE. /* get-prev-month-MY */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME PrevYear-MY
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION PrevYear-MY  RETURNS INTEGER ( INPUT i-month AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE j_year AS INTEGER NO-UNDO.

  RUN get-prev-year-MY IN THIS-PROCEDURE ( INPUT i-month, INPUT i-year, OUTPUT j_year ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_year ).
END FUNCTION. /* PrevYear-MY */
    &ENDIF

PROCEDURE get-prev-year-MY :
  DEFINE  INPUT PARAMETER p-curr-month AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr-year  AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-prev-year  AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-prev-year = p-curr-year + ( IF p-curr-month = 1 THEN -1 ELSE 0 ).
  END. /* ON ERROR */
END PROCEDURE. /* get-prev-year-MY */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME MonthNameEng
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION MonthNameEng RETURNS CHARACTER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.

  RUN get-month-name-eng IN THIS-PROCEDURE ( INPUT i-month, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION. /* MonthNameEng */
    &ENDIF

PROCEDURE get-month-name-eng :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO INITIAL "January,February,March,April,May,June,July,August,September,October,November,December".

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-name = ( IF p-month >= 1 AND p-month <= 12 THEN ENTRY( p-month, v-list ) ELSE ? ).
  END. /* ON ERROR */
END PROCEDURE. /* get-month-name-eng */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Round-M
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Round-M RETURNS DECIMAL ( INPUT i-sum AS DECIMAL, INPUT i-ord AS INTEGER ) :
  DEFINE VARIABLE d-res AS DECIMAL NO-UNDO.

  RUN get-round-m IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-ord, OUTPUT d-res ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE d-res ).
END FUNCTION. /* Round-M */
    &ENDIF

PROCEDURE get-round-m :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL NO-UNDO.
  DEFINE  INPUT PARAMETER p-ord AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS DECIMAL NO-UNDO.

  DEFINE VARIABLE j_ord AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN j_ord = ( IF p-ord < 0 THEN EXP( 10, ABS( p-ord ) ) ELSE 1 ).
    ASSIGN p-res = ROUND( p-sum / j_ord, ( IF p-ord < 0 THEN 0 ELSE p-ord ) ) * j_ord.
  END. /* ON ERROR */
END PROCEDURE. /* get-round-m */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Trunc-M
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Trunc-M RETURNS DECIMAL ( INPUT i-sum AS DECIMAL, INPUT i-ord AS INTEGER ) :
  DEFINE VARIABLE d-res AS DECIMAL NO-UNDO.

  RUN get-trunc-m IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-ord, OUTPUT d-res ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE d-res ).
END FUNCTION. /* Trunc-M */
    &ENDIF

PROCEDURE get-trunc-m :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL NO-UNDO.
  DEFINE  INPUT PARAMETER p-ord AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS DECIMAL NO-UNDO.

  DEFINE VARIABLE j_ord AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN j_ord = ( IF p-ord < 0 THEN EXP( 10, ABS( p-ord ) ) ELSE 1 ).
    ASSIGN p-res = TRUNCATE( p-sum / j_ord, ( IF p-ord < 0 THEN 0 ELSE p-ord ) ) * j_ord.
  END. /* ON ERROR */
END PROCEDURE. /* get-trunc-m */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME get-dec
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION get-dec RETURNS INTEGER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE j-dec AS INTEGER NO-UNDO.

  RUN get-decimals IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT j-dec ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j-dec ).
END FUNCTION. /* get-dec */
    &ENDIF

PROCEDURE get-decimals :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS INTEGER NO-UNDO.

  DEFINE VARIABLE d-sum AS DECIMAL NO-UNDO.
  DEFINE VARIABLE j-len AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN d-sum = TRUNCATE( p-sum, 0 )       /* ....+....1....+....2....+....3....+....4....+....5 */
           j-len = LENGTH( TRIM( STRING( p-sum, "->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>9.9<<<<<<<<<":U ) ) ) -
                   LENGTH( TRIM( STRING( d-sum, "->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>9.":U           ) ) ).
    ASSIGN p-res = INTEGER( ( p-sum - d-sum ) * EXP( 10, ABS( j-len ) ) ).
  END. /* ON ERROR */
END PROCEDURE. /* get-decimals */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME RedLine
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION RedLine RETURNS CHARACTER ( INPUT i-str AS CHARACTER ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.

  RUN get-red-line IN THIS-PROCEDURE ( INPUT i-str, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-str ELSE v-str ).
END FUNCTION. /* RedLine */
    &ENDIF

PROCEDURE get-red-line :
  DEFINE  INPUT PARAMETER p-str AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-res = CAPS( SUBSTRING( p-str, 1, 1 ) ) + LC( SUBSTRING( p-str, 2 ) ).
  END. /* ON ERROR */
END PROCEDURE. /* get-red-line */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME TimeStamp
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION TimeStamp RETURNS CHARACTER ( INPUT i-num AS INTEGER ) : /* длина 50 */
  DEFINE VARIABLE v-header AS CHARACTER NO-UNDO.

  RUN get-time-stamp IN THIS-PROCEDURE ( INPUT i-num, OUTPUT v-header ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-header ).
END FUNCTION. /* TimeStamp */
    &ENDIF

PROCEDURE get-time-stamp :
  DEFINE  INPUT PARAMETER p-num  AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-head AS CHARACTER NO-UNDO.

  DEFINE VARIABLE t_date AS DATE    NO-UNDO.
  DEFINE VARIABLE j_time AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN t_date = TODAY
           j_time = TIME.
    IF t_date <> TODAY THEN DO:
      ASSIGN t_date = TODAY
             j_time = TIME.
    END.
    ASSIGN p-head = "Дата печати: "  + STRING( t_date, "99.99.9999":U ) + ", ":U + STRING( j_time, "HH:MM":U ) +
                    ".   Страница: " + STRING( p-num,  "z,zz9":U      ) + ".".
  END. /* ON ERROR */
END PROCEDURE. /* get-time-stamp */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Stamp57
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
/* Возвращает строку даты, времени и номера страницы длиной 57 символов */
FUNCTION Stamp57 RETURNS CHARACTER ( INPUT i-date AS DATE, INPUT i-time AS INTEGER, INPUT i-num AS INTEGER ) :
  DEFINE VARIABLE v-head AS CHARACTER NO-UNDO.

  RUN get-stamp57 IN THIS-PROCEDURE ( INPUT i-date, INPUT i-time, INPUT i-num, OUTPUT v-head ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-head ).
END FUNCTION. /* Stamp57 */
    &ENDIF

PROCEDURE get-stamp57 :
  DEFINE  INPUT PARAMETER p-date AS DATE      NO-UNDO.
  DEFINE  INPUT PARAMETER p-time AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-num  AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-head AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? OR p-time = ? OR p-time = 0 THEN DO:
      ASSIGN p-date = TODAY
             p-time = TIME.
      IF p-date <> TODAY THEN DO:
        ASSIGN p-date = TODAY
               p-time = TIME.
      END. /* p-date <> TODAY */
    END. /* p-date = ? OR p-time = ? */
    IF p-num = ? OR p-num < 1 THEN DO: ASSIGN p-num = 1. END.
    ASSIGN p-head = "Дата печати: "  + STRING( p-date, "99.99.9999":U ) + ", время: ":U + STRING( p-time, "HH:MM":U ) +
                    ".   Страница: " + STRING( p-num,  "z,zz9":U      ) + ".".
  END. /* ON ERROR */
END PROCEDURE. /* get-stamp57 */

  &ENDIF
&UNDEF SELF-NAME

&SCOP Std_Func_Int2Char ~
    &IF "{2}" <> "procedure-only" &THEN ~
FUNCTION Int2Char RETURNS CHARACTER ( INPUT i-num AS INTEGER ) : ~
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO. ~
~
  RUN conv-int-to-char IN THIS-PROCEDURE ( INPUT i-num, OUTPUT v-str ) NO-ERROR. ~
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-str ). ~
END FUNCTION. /* Int2Char */ ~
    &ENDIF ~
~
PROCEDURE conv-int-to-char : ~
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO. ~
  DEFINE OUTPUT PARAMETER p-str AS CHARACTER NO-UNDO. ~
~
  DO ON ERROR UNDO, RETURN ERROR : ~
    ASSIGN p-str = TRIM( STRING( p-num, "->>>>>>>>>>>>":U ) ). ~
  END. /* ON ERROR */ ~
END PROCEDURE. /* conv-int-to-char */

&SCOP  SELF-NAME Int2Char
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

{&Std_Func_Int2Char}

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME PutAcc
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

&IF DEFINED( delim-grp ) = 0 &THEN
  &SCOP delim-grp CHR( 47 )
&ENDIF

&SCOP  SELF-NAME Int2Char
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 AND
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 &THEN

{&Std_Func_Int2Char}

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME PutAcc

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION PutAcc RETURNS CHARACTER ( INPUT i-num AS INTEGER, INPUT i-sub AS INTEGER ) :
  DEFINE VARIABLE v-acc AS CHARACTER NO-UNDO.

  RUN show-account IN THIS-PROCEDURE ( INPUT i-num, INPUT i-sub, OUTPUT v-acc ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "???" + {&delim-grp} + "??" ELSE v-acc ).
END FUNCTION. /* PutAcc */
    &ENDIF

PROCEDURE show-account :
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-sub AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-acc AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
                 &SCOP  SELF-NAME Int2Char
    ASSIGN p-acc =
                 &IF LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN
                   TRIM( STRING(
                 &ELSE
                   Int2Char(
                 &ENDIF
                   p-num
                 &IF LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN
                   , ">>9":U )
                 &ENDIF
                   ) + ( IF p-sub = 0 THEN "":U ELSE ( {&delim-grp} +
                 &IF LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN
                   TRIM( STRING(
                 &ELSE
                   Int2Char(
                 &ENDIF
                   p-sub
                 &IF LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN
                   , ">>":U )
                 &ENDIF
                   ) ) ).
                 &UNDEF SELF-NAME
                 &SCOP  SELF-NAME PutAcc
  END. /* ON ERROR */
END PROCEDURE. /* show-account */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Roubles
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Roubles RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Rouble AS CHARACTER NO-UNDO.

  RUN get-roubles IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Rouble ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Rouble ).
END FUNCTION. /* Roubles */
    &ENDIF

PROCEDURE get-roubles :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rub AS CHARACTER NO-UNDO.

  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
                                        /* ....+....1....+....2....+....3....+....4....+....5 */
    ASSIGN Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
           jj     = LENGTH( Word )
           j_last = INTEGER( SUBSTRING( Word, jj - 3, 1 ) )
           l_prev =        ( SUBSTRING( Word, jj - 4, 1 ) = "1" ).
    IF      j_last = 1                THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "{&abbr_rubley}" ELSE "{&abbr_rublz}" ).  END.
    ELSE IF j_last > 1 AND j_last < 5 THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "{&abbr_rubley}" ELSE "{&abbr_rublya}" ). END.
                                      ELSE DO: ASSIGN p-rub = "{&abbr_rubley}". END.
  END. /* ON ERROR */
END PROCEDURE. /* get-roubles */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Copecks
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Copecks RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Copeck AS CHARACTER NO-UNDO.

  RUN get-copecks IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Copeck ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Copeck ).
END FUNCTION. /* Copecks */
    &ENDIF

PROCEDURE get-copecks :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-kop AS CHARACTER NO-UNDO.

  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
                                         /* ....+....1....+....2....+....3....+....4....+....5 */
    ASSIGN  Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
            jj     = LENGTH( Word )
            j_last = INTEGER( SUBSTRING( Word, jj,     1 ) )
            l_prev =        ( SUBSTRING( Word, jj - 1, 1 ) = "1" ).
    IF           j_last = 1                THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "{&abbr_kopeek}" ELSE "{&abbr_kopeyka}" ).
    END. ELSE IF j_last > 1 AND j_last < 5 THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "{&abbr_kopeek}" ELSE "{&abbr_kopeyki}" ).
    END.                                   ELSE DO:
      ASSIGN p-kop = "{&abbr_kopeek}".
    END.
  END. /* ON ERROR */
END PROCEDURE. /* get-copecks */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Word-Sum
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

{ gbl/word-sum.i }

&SCOP  SELF-NAME Total-Word
       &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
           LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
           LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Total-Word RETURNS CHARACTER ( INPUT i-sum AS DECIMAL, INPUT i-curr AS CHARACTER, INPUT i-part AS CHARACTER ) :
  DEFINE VARIABLE word_sum AS CHARACTER NO-UNDO.

  RUN get-total-word IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-curr, INPUT i-part, OUTPUT word_sum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE word_sum ).
END FUNCTION. /* Total-Word */
    &ENDIF

PROCEDURE get-total-word :
  DEFINE  INPUT PARAMETER p-sum  AS DECIMAL   NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-part AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-word AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-word = Word-Sum( p-sum ).
           &SCOP  SELF-NAME RedLine
    ASSIGN p-word = ( IF p-sum < 0 THEN "- " ELSE "":U ) + TRIM(
               &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
                   LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
                   LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN
                      RedLine( p-word )
               &ELSE           p-word
               &ENDIF                                            ) +
                      " ":U + p-curr + " ":U +
                                                     /* ....+....1....+....2....+....3....+....4....+....5 */
                      SUBSTRING( STRING( ABS( p-sum ), "999999999999999999999999999999.99" ), 32, 2 ) +
                      " ":U + p-part + ".".
           &UNDEF SELF-NAME
           &SCOP  SELF-NAME Total-Word
  END. /* ON ERROR */
END PROCEDURE. /* get-total-word */

       &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Word-Sum
  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Word-Sum-Eng
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

&SCOP unity   ",one,two,three,four,five,six,seven,eight,nine"
&SCOP decade  ",,twenty,thirty,forty,fifty,sixty,seventy,eighty,ninety"
&SCOP teens   "ten,eleven,twelve,thirteen,fourteen,fifteen,sixteen,seventeen,eigteen,nineteen"
&SCOP hundred ",one hundred,two hundred,three hundred,four hundred,five hundred,six hundred,seven hundred,eight hundred,nine hundred"

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION get-dec-word-eng RETURNS CHARACTER ( INPUT i-dec AS INTEGER, INPUT i-num AS INTEGER ) :
  DEFINE VARIABLE v-grade AS CHARACTER NO-UNDO.

  RUN get-num-grade-eng IN THIS-PROCEDURE ( INPUT i-dec, INPUT i-num, OUTPUT v-grade ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-grade ).
END FUNCTION. /* get-dec-word-eng */

FUNCTION Word-Sum-Eng RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) : /* возвращает сумму прописью от целой части числа */
  DEFINE VARIABLE OutSum AS CHARACTER NO-UNDO.

  RUN conv-sum-to-eng IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT OutSum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE OutSum ).
END FUNCTION. /* Word-Sum-Eng */
    &ENDIF

PROCEDURE conv-sum-to-eng :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.

  DEFINE VARIABLE Formatted  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE OutSum     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER   NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Formatted = STRING( ABS( p-sum ), "999999999999999.99":U ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
      ASSIGN p-res = ?.
      UNDO, RETURN ERROR.
    END.
    DO jj = ( LENGTH( Formatted ) - 3 ) TO 3 BY -3 :
      IF SUBSTRING( Formatted, jj - 2, 3 ) = "000" THEN DO: NEXT. END.
      IF jj < 15 THEN DO:
        ASSIGN Word = ENTRY( jj, ",,trillion,,,billion,,,million,,,thousend" ).
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      END. /* jj < 15 */
      IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO:
        IF      jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "1" THEN DO: ASSIGN Word = "one". END.
        ELSE IF jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "2" THEN DO: ASSIGN Word = "two". END.
        ELSE DO:
    &IF "{2}" <> "procedure-only" &THEN
          ASSIGN Word = get-dec-word-eng( 1, INTEGER( SUBSTRING( Formatted, jj, 1 ) ) ).
    &ELSE
          RUN get-num-grade-eng IN THIS-PROCEDURE (  INPUT 1,
                                                     INPUT INTEGER( SUBSTRING( Formatted, jj, 1 ) ),
                                                    OUTPUT Word                                      ) NO-ERROR.
    &ENDIF
        END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
    &IF "{2}" <> "procedure-only" &THEN
        ASSIGN Word = get-dec-word-eng( 3, INTEGER( SUBSTRING( Formatted, jj - 1, 1 ) ) ).
    &ELSE
        RUN get-num-grade-eng IN THIS-PROCEDURE (  INPUT 3,
                                                   INPUT INTEGER( SUBSTRING( Formatted, jj - 1, 1 ) ),
                                                  OUTPUT Word                                          ) NO-ERROR.
    &ENDIF
      END.                                        ELSE DO:
    &IF "{2}" <> "procedure-only" &THEN
        ASSIGN Word = get-dec-word-eng( 2, INTEGER( SUBSTRING( Formatted, jj,     1 ) ) ).
    &ELSE
        RUN get-num-grade-eng IN THIS-PROCEDURE (  INPUT 2,
                                                   INPUT INTEGER( SUBSTRING( Formatted, jj,     1 ) ),
                                                  OUTPUT Word                                          ) NO-ERROR.
    &ENDIF
      END.
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
    &IF "{2}" <> "procedure-only" &THEN
      ASSIGN Word = get-dec-word-eng( 4, INTEGER( SUBSTRING( Formatted, jj - 2, 1 ) ) ).
    &ELSE
        RUN get-num-grade-eng IN THIS-PROCEDURE (  INPUT 4,
                                                   INPUT INTEGER( SUBSTRING( Formatted, jj - 2, 1 ) ),
                                                  OUTPUT Word                                          ) NO-ERROR.
    &ENDIF
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
    END. /* DO jj */
    ASSIGN OutSum = CAPS( SUBSTRING( OutSum, 1, 1 ) ) + SUBSTRING( OutSum, 2 ).
    IF OutSum = "":U AND TRUNCATE( p-sum, 0 ) = 0 THEN DO: ASSIGN OutSum = "Null". END.
    ASSIGN p-res = TRIM( OutSum ).
  END. /* ON ERROR */
END PROCEDURE. /* conv-sum-to-eng */

PROCEDURE get-num-grade-eng :
  DEFINE  INPUT PARAMETER p-dec AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF      p-dec = 1 THEN DO: ASSIGN v-list = {&unity}.    END.
    ELSE IF p-dec = 2 THEN DO: ASSIGN v-list = {&teens}.    END.
    ELSE IF p-dec = 3 THEN DO: ASSIGN v-list = {&decade}.   END.
    ELSE IF p-dec = 4 THEN DO: ASSIGN v-list = {&hundred}.  END.
                      ELSE DO: ASSIGN v-list = ",,,,,,,,,". END.
    ASSIGN p-res = ENTRY( p-num + 1, v-list ).
  END. /* ON ERROR */
END PROCEDURE. /* get-num-grade-eng */

&SCOP  SELF-NAME Word-Curr
       &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
           LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
           LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Word-Curr RETURNS CHARACTER ( INPUT i-sum AS DECIMAL, INPUT i-curr AS CHARACTER, INPUT i-part AS CHARACTER ) :
  DEFINE VARIABLE word_sum AS CHARACTER NO-UNDO.

  RUN get-word-curr IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-curr, INPUT i-part, OUTPUT word_sum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE word_sum ).
END FUNCTION. /* Word-Curr */
    &ENDIF

PROCEDURE get-word-curr :
  DEFINE  INPUT PARAMETER p-sum  AS DECIMAL   NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-part AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-word AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-word = Word-Sum-Eng( p-sum ).
           &SCOP  SELF-NAME RedLine
    ASSIGN p-word = ( IF p-sum < 0 THEN "- " ELSE "":U ) + TRIM(
    &IF "{2}" <> "procedure-only" &THEN
               &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
                   LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
                   LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN
                      RedLine( p-word )
               &ELSE           p-word
               &ENDIF
    &ELSE                      p-word
    &ENDIF                                                     ) +
                      " ":U + p-curr + " ":U +
                                                     /* ....+....1....+....2....+....3....+....4....+....5 */
                      SUBSTRING( STRING( ABS( p-sum ), "999999999999999999999999999999.99" ), 32, 2 ) +
                      " ":U + p-part + ".".
           &UNDEF SELF-NAME
           &SCOP  SELF-NAME Word-Curr
  END. /* ON ERROR */
END PROCEDURE. /* get-word-curr */

       &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Word-Sum-Eng
  &ENDIF
&UNDEF SELF-NAME

  &ENDIF

&SCOP  SELF-NAME PutInt
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION PutInt RETURNS CHARACTER ( INPUT i-num AS INTEGER ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.

  RUN conv-int-to-str IN THIS-PROCEDURE ( INPUT i-num, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-str ).
END FUNCTION. /* PutInt */
    &ENDIF

PROCEDURE conv-int-to-str :
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-str AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-str = TRIM( STRING( p-num, "->,>>>,>>>,>>9":U ) ).
  END. /* ON ERROR */
END PROCEDURE. /* conv-int-to-str */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME PutSum
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION PutSum RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.

  RUN conv-dec-to-str IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-str ).
END FUNCTION. /* PutSum */
    &ENDIF

PROCEDURE conv-dec-to-str :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-str AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
                                      /* ....+....1....+....2....+....3....+....4....+....5 */
    ASSIGN p-str = TRIM( STRING( p-sum, "->>>,>>>,>>>,>>>,>>>,>>9.99":U ) ).
  END. /* ON ERROR */
END PROCEDURE. /* conv-dec-to-str */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME WeekDay-Full
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION WeekDay-Full RETURNS CHARACTER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE week-day-name AS CHARACTER NO-UNDO.

  RUN get-weekday-full-rus IN THIS-PROCEDURE ( INPUT i-date, OUTPUT week-day-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE week-day-name ).
END FUNCTION. /* WeekDay-Full */
    &ENDIF

PROCEDURE get-weekday-full-rus :
  DEFINE  INPUT PARAMETER p-date AS DATE      NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END.
    ASSIGN p-name = ENTRY( WEEKDAY( p-date ), "Воскресенье,Понедельник,Вторник,Среда,Четверг,Пятница,Суббота" ).
  END. /* ON ERROR */
END PROCEDURE. /* get-weekday-full-rus */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME WeekDay-Short
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION WeekDay-Short RETURNS CHARACTER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE week-day-name AS CHARACTER NO-UNDO.

  RUN get-weekday-short2-rus IN THIS-PROCEDURE ( INPUT i-date, OUTPUT week-day-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE week-day-name ).
END FUNCTION. /* WeekDay-Short */
    &ENDIF

PROCEDURE get-weekday-short2-rus :
  DEFINE  INPUT PARAMETER p-date AS DATE      NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END.
    ASSIGN p-name = ENTRY( WEEKDAY( p-date ), "Вс,Пн,Вт,Ср,Чт,Пт,Сб" ).
  END. /* ON ERROR */
END PROCEDURE. /* get-weekday-short2-rus */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME WeekDay-Shrt3
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION WeekDay-Shrt3 RETURNS CHARACTER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE week-day-name AS CHARACTER NO-UNDO.

  RUN get-weekday-short3-rus IN THIS-PROCEDURE ( INPUT i-date, OUTPUT week-day-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE week-day-name ).
END FUNCTION. /* WeekDay-Shrt3 */
    &ENDIF

PROCEDURE get-weekday-short3-rus :
  DEFINE  INPUT PARAMETER p-date AS DATE      NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END.
    ASSIGN p-name = ENTRY( WEEKDAY( p-date ), "Вск,Пнд,Втр,Срд,Чтв,Птн,Суб" ).
  END. /* ON ERROR */
END PROCEDURE. /* get-weekday-short3-rus */

  &ENDIF
&UNDEF SELF-NAME

&SCOP Std_Func_WeekDay-Rus ~
    &IF "{2}" <> "procedure-only" &THEN ~
FUNCTION WeekDay-Rus RETURNS INTEGER ( INPUT i-date AS DATE ) : ~
  DEFINE VARIABLE j-weekday AS INTEGER NO-UNDO. ~
~
  RUN get-weekday-num-rus IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j-weekday ) NO-ERROR. ~
  RETURN ( IF ERROR-STATUS :ERROR THEN WEEKDAY( i-date ) ELSE j-weekday ). ~
END FUNCTION. /* WeekDay-Rus */ ~
    &ENDIF ~
~
PROCEDURE get-weekday-num-rus : ~
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO. ~
  DEFINE OUTPUT PARAMETER p-code AS INTEGER NO-UNDO. ~
~
  DO ON ERROR UNDO, RETURN ERROR : ~
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END. ~
    ASSIGN p-code = ( ( WEEKDAY( p-date ) + 5 ) MODULO 7 ) + 1. ~
  END. /* ON ERROR */ ~
END PROCEDURE. /* get-weekday-num-rus */ ~

&SCOP  SELF-NAME WeekDay-Rus
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

{&Std_Func_WeekDay-Rus}

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME WeekDay-Full-Eng
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION WeekDay-Full-Eng RETURNS CHARACTER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE week-day-name AS CHARACTER NO-UNDO.

  RUN get-weekday-full-eng IN THIS-PROCEDURE ( INPUT i-date, OUTPUT week-day-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE week-day-name ).
END FUNCTION. /* WeekDay-Full-Eng */
    &ENDIF

PROCEDURE get-weekday-full-eng :
  DEFINE  INPUT PARAMETER p-date AS DATE      NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END.
    ASSIGN p-name = ENTRY( WEEKDAY( p-date ), "Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday" ).
  END. /* ON ERROR */
END PROCEDURE. /* get-weekday-full-eng */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME WeekDay-Eng2
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION WeekDay-Eng2 RETURNS CHARACTER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE week-day-name AS CHARACTER NO-UNDO.

  RUN get-weekday-short2-eng IN THIS-PROCEDURE ( INPUT i-date, OUTPUT week-day-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE week-day-name ).
END FUNCTION. /* WeekDay-Eng2 */
    &ENDIF

PROCEDURE get-weekday-short2-eng :
  DEFINE  INPUT PARAMETER p-date AS DATE      NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END.
    ASSIGN p-name = ENTRY( WEEKDAY( p-date ), "Su,Mo,Tu,We,Th,Fr,Sa" ).
  END. /* ON ERROR */
END PROCEDURE. /* get-weekday-short2-eng */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME WeekDay-Eng3
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION WeekDay-Eng3 RETURNS CHARACTER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE week-day-name AS CHARACTER NO-UNDO.

  RUN get-weekday-short3-eng IN THIS-PROCEDURE ( INPUT i-date, OUTPUT week-day-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE week-day-name ).
END FUNCTION. /* WeekDay-Eng3 */
    &ENDIF

PROCEDURE get-weekday-short3-eng :
  DEFINE  INPUT PARAMETER p-date AS DATE      NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END.
    ASSIGN p-name = ENTRY( WEEKDAY( p-date ), "Sun,Mon,Tue,Wed,Thu,Fri,Sat" ).
  END. /* ON ERROR */
END PROCEDURE. /* get-weekday-short3-eng */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Rec2Char
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Rec2Char RETURNS CHARACTER ( INPUT i-rec AS RECID ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.

  RUN conv-rec-to-char IN THIS-PROCEDURE ( INPUT i-rec, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-str ).
END FUNCTION. /* Rec2Char */
    &ENDIF

PROCEDURE conv-rec-to-char :
  DEFINE  INPUT PARAMETER p-rec AS RECID     NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-res = TRIM( STRING( p-rec, "->>>>>>>>>>>9":U ) ).
  END. /* ON ERROR */
END PROCEDURE. /* conv-rec-to-char */

  &ENDIF
&UNDEF SELF-NAME

&IF DEFINED( comma-char ) = 0 &THEN
  &SCOP comma-char CHR( 44 )
&ENDIF

&SCOP Std_Func_DelEntry ~
    &IF "{2}" <> "procedure-only" &THEN ~
FUNCTION DelEntry RETURNS CHARACTER ( INPUT i-list  AS CHARACTER, ~
                                      INPUT i-item  AS CHARACTER, ~
                                      INPUT i-dlmtr AS CHARACTER ) : ~
  DEFINE VARIABLE v_out-list AS CHARACTER NO-UNDO. ~
  ~
  RUN delete-from-list IN THIS-PROCEDURE ( INPUT i-list, INPUT i-item, INPUT i-dlmtr, OUTPUT v_out-list ) NO-ERROR. ~
  RETURN ( IF ERROR-STATUS :ERROR THEN i-list ELSE v_out-list ). ~
END FUNCTION. /* DelEntry */ ~
    &ENDIF ~
~
PROCEDURE delete-from-list : ~
  DEFINE  INPUT PARAMETER p-in-list      AS CHARACTER NO-UNDO. ~
  DEFINE  INPUT PARAMETER p-deleted-item AS CHARACTER NO-UNDO. ~
  DEFINE  INPUT PARAMETER p-delimiter    AS CHARACTER NO-UNDO. ~
  DEFINE OUTPUT PARAMETER p-out-list     AS CHARACTER NO-UNDO. ~
~
  DEFINE VARIABLE j_num-item AS INTEGER NO-UNDO. ~
  ~
  DO ON ERROR UNDO, RETURN ERROR : ~
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END. ~
    ASSIGN j_num-item = LOOKUP(   p-deleted-item, p-in-list, p-delimiter ). ~
    IF j_num-item > 0 THEN DO: ENTRY( j_num-item, p-in-list, p-delimiter ) = "":U. END. ~
    ASSIGN p-out-list = TRIM( REPLACE( p-in-list, p-delimiter + p-delimiter, p-delimiter ), p-delimiter ). ~
  END. /* ON ERROR */ ~
END PROCEDURE. /* delete-from-list */

&SCOP  SELF-NAME DelEntry
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

{&Std_Func_DelEntry}

  &ENDIF
&UNDEF SELF-NAME

&SCOP Std_Func_addl-list ~
    &IF "{2}" <> "procedure-only" &THEN ~
FUNCTION addl-list RETURNS CHARACTER ( INPUT i-list  AS CHARACTER, ~
                                       INPUT i-item  AS CHARACTER, ~
                                       INPUT i-dlmtr AS CHARACTER  ) : ~
  DEFINE VARIABLE v_out-list AS CHARACTER NO-UNDO. ~
  ~
  RUN add-last-to-list IN THIS-PROCEDURE ( INPUT i-list, INPUT i-item, INPUT i-dlmtr, OUTPUT v_out-list ) NO-ERROR. ~
  RETURN ( IF ERROR-STATUS :ERROR THEN i-list ELSE v_out-list ). ~
END FUNCTION. /* addl-list */ ~
    &ENDIF ~
~
PROCEDURE add-last-to-list : ~
  DEFINE  INPUT PARAMETER p-in-list    AS CHARACTER NO-UNDO. ~
  DEFINE  INPUT PARAMETER p-added-item AS CHARACTER NO-UNDO. ~
  DEFINE  INPUT PARAMETER p-delimiter  AS CHARACTER NO-UNDO. ~
  DEFINE OUTPUT PARAMETER p-out-list   AS CHARACTER NO-UNDO. ~
~
  DO ON ERROR UNDO, RETURN ERROR : ~
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END. ~
    ASSIGN p-out-list = p-in-list + ( IF p-in-list = "":U THEN "":U ELSE p-delimiter ) + p-added-item. ~
  END. /* ON ERROR */ ~
END PROCEDURE. /* add-last-to-list */

&SCOP  SELF-NAME addl-list
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF DEFINED( Std_Func_addl-list_defined ) = 0 &THEN
&GLOB Std_Func_addl-list_defined yes
{&Std_Func_addl-list}
    &ENDIF

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME addf-list
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION addf-list RETURNS CHARACTER (  INPUT i-list  AS CHARACTER,
                                        INPUT i-item  AS CHARACTER,
                                        INPUT i-dlmtr AS CHARACTER ) :
  DEFINE VARIABLE v_out-list AS CHARACTER NO-UNDO.

  RUN add-first-to-list IN THIS-PROCEDURE ( INPUT i-list, INPUT i-item, INPUT i-dlmtr, OUTPUT v_out-list ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-list ELSE v_out-list ).
END FUNCTION. /* addf-list */
    &ENDIF

PROCEDURE add-first-to-list :
  DEFINE  INPUT PARAMETER p-in-list    AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-added-item AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-delimiter  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-out-list   AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END.
    ASSIGN p-out-list = p-added-item + ( IF p-in-list = "":U THEN "":U ELSE p-delimiter ) + p-in-list.
  END. /* ON ERROR */
END PROCEDURE. /* add-first-to-list */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME addn-list
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION addn-list RETURNS CHARACTER ( INPUT i-list  AS CHARACTER,
                                       INPUT i-item  AS CHARACTER,
                                       INPUT i-dlmtr AS CHARACTER,
                                       INPUT i-num   AS INTEGER    ) :
  DEFINE VARIABLE v_out-list AS CHARACTER NO-UNDO.

  RUN add-item-to-list IN THIS-PROCEDURE (  INPUT i-list,
                                            INPUT i-item,
                                            INPUT i-dlmtr,
                                            INPUT i-num,
                                           OUTPUT v_out-list ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-list ELSE v_out-list ).
END FUNCTION. /* addn-list */
    &ENDIF

PROCEDURE add-item-to-list :
  DEFINE  INPUT PARAMETER p-in-list    AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-added-item AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-delimiter  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-num        AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-out-list   AS CHARACTER NO-UNDO.

  DEFINE VARIABLE j_entries AS INTEGER NO-UNDO.
  DEFINE VARIABLE jj        AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END.
    IF p-in-list = ? THEN DO: ASSIGN p-in-list = "":U. END.
    IF p-num = ? OR p-num < 1 THEN DO: ASSIGN p-num = 1. END.
    ASSIGN j_entries = NUM-ENTRIES( p-in-list, p-delimiter ).
    IF j_entries < p-num THEN DO: ASSIGN p-in-list = p-in-list + FILL( p-delimiter, p-num - j_entries ). END.
                         ELSE DO: ASSIGN p-in-list = p-in-list + p-delimiter. END.
    ASSIGN j_entries = NUM-ENTRIES( p-in-list, p-delimiter ).
    DO jj = j_entries TO p-num + 1 BY -1 :
      ENTRY( jj, p-in-list, p-delimiter ) = ENTRY( jj - 1, p-in-list, p-delimiter ).
    END.
    ENTRY( p-num, p-in-list, p-delimiter ) = p-added-item.
    ASSIGN p-out-list = p-in-list.
  END. /* ON ERROR */
END PROCEDURE. /* add-item-to-list */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME super-pos
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

  &IF LOOKUP(  'addl-list',    {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '^addl-list',    {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 &THEN

    &IF DEFINED( Std_Func_addl-list_defined ) = 0 &THEN
&GLOB Std_Func_addl-list_defined yes
{&Std_Func_addl-list}
    &ENDIF

  &ENDIF

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION super-pos RETURNS CHARACTER (  INPUT i-lst1  AS CHARACTER,
                                        INPUT i-lst2  AS CHARACTER,
                                        INPUT i-dlmtr AS CHARACTER ) :
  DEFINE VARIABLE v_out-list AS CHARACTER NO-UNDO.

  RUN get-superposition IN THIS-PROCEDURE ( INPUT i-lst1, INPUT i-lst2, INPUT i-dlmtr, OUTPUT v_out-list ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v_out-list ).
END FUNCTION. /* super-pos */
    &ENDIF

PROCEDURE get-superposition :
  DEFINE  INPUT PARAMETER p-minuend     AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-subtrahend  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-delimiter   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-result-list AS CHARACTER NO-UNDO.

  DEFINE VARIABLE jndex  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE v_item AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END.
    DO jndex = 1 TO NUM-ENTRIES( p-minuend, p-delimiter ) :
      ASSIGN v_item = ENTRY( jndex, p-minuend, p-delimiter ).
      IF LOOKUP( v_item, p-subtrahend, p-delimiter ) = 0 THEN DO:
    &IF "{2}" <> "procedure-only" &THEN
        ASSIGN p-result-list = addl-list( p-result-list, v_item, p-delimiter ).
    &ELSE
        RUN add-last-to-list IN THIS-PROCEDURE (  INPUT p-result-list,
                                                  INPUT v_item,
                                                  INPUT p-delimiter,
                                                 OUTPUT p-result-list ) NO-ERROR.
    &ENDIF
      END.
    END.
  END. /* ON ERROR */
END PROCEDURE. /* get-superposition */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME sets-union
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

  &IF LOOKUP(  'addl-list',    {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '^addl-list',    {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 &THEN

    &IF DEFINED( Std_Func_addl-list_defined ) = 0 &THEN
&GLOB Std_Func_addl-list_defined yes
{&Std_Func_addl-list}
    &ENDIF

  &ENDIF

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION sets-union RETURNS CHARACTER ( INPUT i-lst1  AS CHARACTER,
                                        INPUT i-lst2  AS CHARACTER,
                                        INPUT i-dlmtr AS CHARACTER ) :
  DEFINE VARIABLE v_out-list AS CHARACTER NO-UNDO.

  RUN get-sets-union IN THIS-PROCEDURE ( INPUT i-lst1, INPUT i-lst2, INPUT i-dlmtr, OUTPUT v_out-list ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v_out-list ).
END FUNCTION. /* sets-union */
    &ENDIF

PROCEDURE get-sets-union :
  DEFINE  INPUT PARAMETER p-list-augend AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-list-addend AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-delimiter   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-result-list AS CHARACTER NO-UNDO.

  DEFINE VARIABLE jndex     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_entries AS INTEGER   NO-UNDO.
  DEFINE VARIABLE v_item    AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END.
    ASSIGN p-result-list = p-list-augend
           j_entries     = NUM-ENTRIES( p-list-addend, p-delimiter ).
    DO jndex = 1 TO j_entries :
      ASSIGN v_item = ENTRY( jndex, p-list-addend, p-delimiter ).
      IF LOOKUP( v_item, p-result-list, p-delimiter ) = 0 THEN DO:
    &IF "{2}" <> "procedure-only" &THEN
        ASSIGN p-result-list = addl-list( p-result-list, v_item, p-delimiter ).
    &ELSE
        RUN add-last-to-list IN THIS-PROCEDURE (  INPUT p-result-list,
                                                  INPUT v_item,
                                                  INPUT p-delimiter,
                                                 OUTPUT p-result-list ) NO-ERROR.
    &ENDIF
      END.
    END. /* DO jndex ... */
  END. /* ON ERROR */
END PROCEDURE. /* get-sets-union */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME sets-intersection
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

  &IF LOOKUP(  'addl-list',    {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '^addl-list',    {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 &THEN

    &IF DEFINED( Std_Func_addl-list_defined ) = 0 &THEN
&GLOB Std_Func_addl-list_defined yes
{&Std_Func_addl-list}
    &ENDIF

  &ENDIF

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION sets-intersection RETURNS CHARACTER ( INPUT i-lst1  AS CHARACTER,
                                               INPUT i-lst2  AS CHARACTER,
                                               INPUT i-dlmtr AS CHARACTER ) :
  DEFINE VARIABLE v_out-list AS CHARACTER NO-UNDO.

  RUN get-sets-intersection IN THIS-PROCEDURE ( INPUT i-lst1, INPUT i-lst2, INPUT i-dlmtr, OUTPUT v_out-list ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v_out-list ).
END FUNCTION. /* sets-intersection */
    &ENDIF

PROCEDURE get-sets-intersection :
  DEFINE  INPUT PARAMETER p-list-1st  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-list-2nd  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-delimiter AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-result    AS CHARACTER NO-UNDO.

  DEFINE VARIABLE jndex     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_entries AS INTEGER   NO-UNDO.
  DEFINE VARIABLE v_item    AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-result = "":U.
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END.

    ASSIGN j_entries = NUM-ENTRIES( p-list-1st, p-delimiter ).
    DO jndex = 1 TO j_entries :
      ASSIGN v_item = ENTRY( jndex, p-list-1st, p-delimiter ).
      IF LOOKUP( v_item, p-list-2nd, p-delimiter ) > 0 AND LOOKUP( v_item, p-result, p-delimiter ) = 0 THEN DO:
    &IF "{2}" <> "procedure-only" &THEN
        ASSIGN p-result = addl-list( p-result, v_item, p-delimiter ).
    &ELSE
        RUN add-last-to-list IN THIS-PROCEDURE (  INPUT p-result,
                                                  INPUT v_item,
                                                  INPUT p-delimiter,
                                                 OUTPUT p-result     ) NO-ERROR.
    &ENDIF
      END.
    END. /* DO jndex ... */

    ASSIGN j_entries = NUM-ENTRIES( p-list-2nd, p-delimiter ).
    DO jndex = 1 TO j_entries :
      ASSIGN v_item = ENTRY( jndex, p-list-2nd, p-delimiter ).
      IF LOOKUP( v_item, p-list-1st, p-delimiter ) > 0 AND LOOKUP( v_item, p-result, p-delimiter ) = 0 THEN DO:
    &IF "{2}" <> "procedure-only" &THEN
        ASSIGN p-result = addl-list( p-result, v_item, p-delimiter ).
    &ELSE
        RUN add-last-to-list IN THIS-PROCEDURE (  INPUT p-result,
                                                  INPUT v_item,
                                                  INPUT p-delimiter,
                                                 OUTPUT p-result     ) NO-ERROR.
    &ENDIF
      END.
    END. /* DO jndex ... */
  END. /* ON ERROR */
END PROCEDURE. /* get-sets-intersection */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME ChooseMark
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

  &IF LOOKUP(  'addl-list',    {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '^addl-list',    {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 &THEN

    &IF DEFINED( Std_Func_addl-list_defined ) = 0 &THEN
&GLOB Std_Func_addl-list_defined yes
{&Std_Func_addl-list}
    &ENDIF

  &ENDIF

  &IF LOOKUP(  'DelEntry',     {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '^DelEntry',     {&Std-Func_defined-list} ) = 0 AND
      LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 &THEN

{&Std_Func_DelEntry}

  &ENDIF

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION ChooseMark RETURNS CHARACTER ( INPUT i-list  AS CHARACTER,
                                        INPUT i-item  AS CHARACTER,
                                        INPUT i-dlmtr AS CHARACTER  ) :
  DEFINE VARIABLE v_list-out AS CHARACTER NO-UNDO.

  RUN get-choose-mark IN THIS-PROCEDURE ( INPUT i-list, INPUT i-item, INPUT i-dlmtr, OUTPUT v_list-out ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-list ELSE v_list-out ).
END FUNCTION. /* ChooseMark */
    &ENDIF

PROCEDURE get-choose-mark :
  DEFINE  INPUT PARAMETER p-list-in   AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-item      AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-delimiter AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-list-out  AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END.
    IF LOOKUP( p-item, p-list-in, p-delimiter ) > 0 THEN DO:
    &IF "{2}" <> "procedure-only" &THEN
      ASSIGN p-list-out = DelEntry(  p-list-in, p-item, p-delimiter ).
    &ELSE
      RUN delete-from-list IN THIS-PROCEDURE (  INPUT p-list-in,
                                                INPUT p-item,
                                                INPUT p-delimiter,
                                               OUTPUT p-list-out   ) NO-ERROR.
    &ENDIF
    END.                                            ELSE DO:
    &IF "{2}" <> "procedure-only" &THEN
      ASSIGN p-list-out = addl-list( p-list-in, p-item, p-delimiter ).
    &ELSE
      RUN add-last-to-list IN THIS-PROCEDURE (  INPUT p-list-in,
                                                INPUT p-item,
                                                INPUT p-delimiter,
                                               OUTPUT p-list-out   ) NO-ERROR.
    &ENDIF
    END.
  END. /* ON ERROR */
END PROCEDURE. /* get-choose-mark */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME is-marked
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION is-marked RETURNS LOGICAL (  INPUT i-list  AS CHARACTER,
                                      INPUT i-item  AS CHARACTER,
                                      INPUT i-dlmtr AS CHARACTER ) :
  DEFINE VARIABLE l_is-marked AS LOGICAL NO-UNDO.

  RUN get-marked IN THIS-PROCEDURE ( INPUT i-list, INPUT i-item, INPUT i-dlmtr, OUTPUT l_is-marked ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE l_is-marked ).
END FUNCTION. /* is-marked */
    &ENDIF

PROCEDURE get-marked :
  DEFINE  INPUT PARAMETER p-list      AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-item      AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-delimiter AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-is-marked AS LOGICAL   NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END.
    ASSIGN p-is-marked = ( IF LOOKUP( p-item, p-list, p-delimiter ) > 0 THEN YES ELSE NO ).
  END. /* ON ERROR */
END PROCEDURE. /* get-marked */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME MarkSign
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION MarkSign RETURNS CHARACTER (  INPUT i-list  AS CHARACTER,
                                       INPUT i-item  AS CHARACTER,
                                       INPUT i-dlmtr AS CHARACTER ) :
  DEFINE VARIABLE v_mark-sign AS CHARACTER NO-UNDO.

  RUN get-mark-sign IN THIS-PROCEDURE ( INPUT i-list, INPUT i-item, INPUT i-dlmtr, OUTPUT v_mark-sign ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "?" ELSE v_mark-sign ).
END FUNCTION. /* MarkSign */
    &ENDIF

PROCEDURE get-mark-sign :
  DEFINE  INPUT PARAMETER p-list      AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-item      AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-delimiter AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-mark-sign AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = {&comma-char}. END.
    ASSIGN p-mark-sign = ( IF LOOKUP( p-item, p-list, p-delimiter ) > 0 THEN CHR( 42 ) ELSE CHR( 32 ) ).
  END. /* ON ERROR */
END PROCEDURE. /* get-mark-sign */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Int2Hex
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Int2Hex RETURNS CHARACTER ( INPUT i-int AS INTEGER ) :
  DEFINE VARIABLE v_result AS CHARACTER NO-UNDO.

  RUN conv-int-to-hex IN THIS-PROCEDURE ( INPUT i-int, OUTPUT v_result ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v_result ).
END FUNCTION. /* Int2Hex */
    &ENDIF

PROCEDURE conv-int-to-hex :
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-hex AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v_list   AS CHARACTER NO-UNDO INITIAL '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F':U.
  DEFINE VARIABLE c_result AS CHARACTER NO-UNDO.
  DEFINE VARIABLE j_xx     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_digit  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_target AS INTEGER   NO-UNDO.
  DEFINE VARIABLE c_sign   AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN j_target = ABS( p-num )
           c_sign   = ( IF p-num < 0 THEN "-":U ELSE "":U ).
    DO WHILE j_target > 15 :
      ASSIGN j_xx     = INTEGER( TRUNCATE( j_target * 0.0625, 0 ) )
             j_digit  = j_target - j_xx * 16
             j_target = j_xx
             c_result = ENTRY( j_digit + 1, v_list ) + c_result.
    END.
    ASSIGN p-hex = c_sign + ENTRY( j_target + 1, v_list ) + c_result.
  END. /* ON ERROR */
END PROCEDURE. /* conv-int-to-hex */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Hex2Int
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Hex2Int RETURNS INTEGER ( INPUT i-hex AS CHARACTER ) :
  DEFINE VARIABLE j_num AS INTEGER NO-UNDO.

  RUN conv-hex-to-int IN THIS-PROCEDURE ( INPUT i-hex, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION. /* Hex2Int */
    &ENDIF

PROCEDURE conv-hex-to-int :
  DEFINE  INPUT PARAMETER p-hex AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int AS INTEGER   NO-UNDO.

  DEFINE VARIABLE jj     AS INTEGER NO-UNDO.
  DEFINE VARIABLE j_sign AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-hex = TRIM( p-hex ).
    IF SUBSTRING( p-hex, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-hex  = SUBSTRING( p-hex, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-hex ) :
      ASSIGN p-int = p-int * 16 + LOOKUP( SUBSTRING( p-hex, jj, 1 ), "0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F":U ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END. /* ON ERROR */
END PROCEDURE. /* conv-hex-to-int */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Int2Base
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Int2Base RETURNS CHARACTER ( INPUT i-int AS INTEGER, INPUT i-base AS INTEGER ) :
  DEFINE VARIABLE v_result AS CHARACTER NO-UNDO.

  RUN conv-int-to-base IN THIS-PROCEDURE ( INPUT i-int, INPUT i-base, OUTPUT v_result ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v_result ).
END FUNCTION. /* Int2Base */
    &ENDIF

PROCEDURE conv-int-to-base :
  DEFINE  INPUT PARAMETER p-num  AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-base AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res  AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v_list   AS CHARACTER NO-UNDO INITIAL '':U.
  DEFINE VARIABLE c_result AS CHARACTER NO-UNDO.
  DEFINE VARIABLE j_xx     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_digit  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_target AS INTEGER   NO-UNDO.
  DEFINE VARIABLE c_sign   AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-base > 60 THEN DO:
      ASSIGN p-res = ?.
      UNDO, RETURN ERROR.
    END.
    ASSIGN v_list   = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U +
                      'Б,Г,Д,Ё,Ж,З,И,Й,Л,П,У,Ф,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,@,$':U
           j_target = ABS( p-num )
           c_sign   = ( IF p-num < 0 THEN "-":U ELSE "":U ).
    DO WHILE j_target > ( p-base - 1 ) :
      ASSIGN j_xx     = INTEGER( TRUNCATE( j_target / p-base, 0 ) )
             j_digit  = j_target - j_xx * p-base
             j_target = j_xx
             c_result = ENTRY( j_digit + 1, v_list ) + c_result.
    END.
    ASSIGN p-res = c_sign + ENTRY( j_target + 1, v_list ) + c_result.
  END. /* ON ERROR */
END PROCEDURE. /* conv-int-to-base */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Base2Int
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Base2Int RETURNS INTEGER ( INPUT i-hex AS CHARACTER, INPUT i-base AS INTEGER ) :
  DEFINE VARIABLE j_num AS INTEGER NO-UNDO.

  RUN conv-base-to-int IN THIS-PROCEDURE ( INPUT i-hex, INPUT i-base, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION. /* Base2Int */
    &ENDIF

PROCEDURE conv-base-to-int :
  DEFINE  INPUT PARAMETER p-num  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-base AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int  AS INTEGER   NO-UNDO.

  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_sign AS INTEGER   NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-base > 60 THEN DO:
      ASSIGN p-int = ?.
      UNDO, RETURN ERROR.
    END.
    ASSIGN v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U +
                    'Б,Г,Д,Ё,Ж,З,И,Й,Л,П,У,Ф,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,@,$':U
           v_list = SUBSTRING( v_list, 1, p-base * 2 - 1 )
           p-num  = TRIM( p-num ).
    IF SUBSTRING( p-num, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-num  = SUBSTRING( p-num, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-num ) :
      ASSIGN p-int = p-int * p-base + LOOKUP( SUBSTRING( p-num, jj, 1 ), v_list ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END. /* ON ERROR */
END PROCEDURE. /* conv-base-to-int */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Base2Int64
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Base2Int64 RETURNS INT64 ( INPUT i-hex AS CHARACTER, INPUT i-base AS INTEGER ) :
  DEFINE VARIABLE j_num AS INT64 NO-UNDO.

  RUN conv-base-to-int64 IN THIS-PROCEDURE ( INPUT i-hex, INPUT i-base, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION. /* Base2Int64 */
    &ENDIF

PROCEDURE conv-base-to-int64 :
  DEFINE  INPUT PARAMETER p-num  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-base AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int  AS INT64     NO-UNDO.

  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_sign AS INT64   NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-base > 60 THEN DO:
      ASSIGN p-int = ?.
      UNDO, RETURN ERROR.
    END.
    ASSIGN v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U +
                    'Б,Г,Д,Ё,Ж,З,И,Й,Л,П,У,Ф,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,@,$':U
           v_list = SUBSTRING( v_list, 1, p-base * 2 - 1 )
           p-num  = TRIM( p-num ).
    IF SUBSTRING( p-num, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-num  = SUBSTRING( p-num, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-num ) :
      ASSIGN p-int = p-int * p-base + LOOKUP( SUBSTRING( p-num, jj, 1 ), v_list ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END. /* ON ERROR */
END PROCEDURE. /* conv-base-to-int64 */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Int2Bin
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Int2Bin RETURNS CHARACTER ( INPUT i-int AS INTEGER ) :
  DEFINE VARIABLE v_result AS CHARACTER NO-UNDO.

  RUN conv-int-to-bin IN THIS-PROCEDURE ( INPUT i-int, OUTPUT v_result ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v_result ).
END FUNCTION. /* Int2Bin */
    &ENDIF

PROCEDURE conv-int-to-bin :
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-bin AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v_list   AS CHARACTER NO-UNDO INITIAL '0,1':U.
  DEFINE VARIABLE c_result AS CHARACTER NO-UNDO.
  DEFINE VARIABLE j_xx     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_digit  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_target AS INTEGER   NO-UNDO.
  DEFINE VARIABLE c_sign   AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN j_target = ABS( p-num )
           c_sign   = ( IF p-num < 0 THEN "-":U ELSE "":U ).
    DO WHILE j_target > 1 :
      ASSIGN j_xx     = INTEGER( TRUNCATE( j_target * 0.5, 0 ) )
             j_digit  = j_target - j_xx * 2
             j_target = j_xx
             c_result = ENTRY( j_digit + 1, v_list ) + c_result.
    END.
    ASSIGN p-bin = c_sign + ENTRY( j_target + 1, v_list ) + c_result.
  END. /* ON ERROR */
END PROCEDURE. /* conv-int-to-bin */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Bin2Int
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Bin2Int RETURNS INTEGER ( INPUT i-bin AS CHARACTER ) :
  DEFINE VARIABLE j_num AS INTEGER NO-UNDO.

  RUN conv-bin-to-int IN THIS-PROCEDURE ( INPUT i-bin, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION. /* Bin2Int */
    &ENDIF

PROCEDURE conv-bin-to-int :
  DEFINE  INPUT PARAMETER p-bin AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int AS INTEGER   NO-UNDO.

  DEFINE VARIABLE jj     AS INTEGER NO-UNDO.
  DEFINE VARIABLE j_sign AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-bin = TRIM( p-bin ).
    IF SUBSTRING( p-bin, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-bin  = SUBSTRING( p-bin, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-bin ) :
      ASSIGN p-int = p-int * 2 + LOOKUP( SUBSTRING( p-bin, jj, 1 ), "0,1":U ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END. /* ON ERROR */
END PROCEDURE. /* conv-bin-to-int */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Int2Octal
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Int2Octal RETURNS CHARACTER ( INPUT i-int AS INTEGER ) :
  DEFINE VARIABLE v_result AS CHARACTER NO-UNDO.

  RUN conv-int-to-oct IN THIS-PROCEDURE ( INPUT i-int, OUTPUT v_result ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v_result ).
END FUNCTION. /* Int2Octal */
    &ENDIF

PROCEDURE conv-int-to-oct :
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-oct AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v_list   AS CHARACTER NO-UNDO INITIAL '0,1,2,3,4,5,6,7':U.
  DEFINE VARIABLE c_result AS CHARACTER NO-UNDO.
  DEFINE VARIABLE j_xx     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_digit  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_target AS INTEGER   NO-UNDO.
  DEFINE VARIABLE c_sign   AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN j_target = ABS( p-num )
           c_sign   = ( IF p-num < 0 THEN "-":U ELSE "":U ).
    DO WHILE j_target > 7 :
      ASSIGN j_xx     = INTEGER( TRUNCATE( j_target * 0.125, 0 ) )
             j_digit  = j_target - j_xx * 8
             j_target = j_xx
             c_result = ENTRY( j_digit + 1, v_list ) + c_result.
    END.
    ASSIGN p-oct = c_sign + ENTRY( j_target + 1, v_list ) + c_result.
  END. /* ON ERROR */
END PROCEDURE. /* conv-int-to-oct */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Oct2Int
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Oct2Int RETURNS INTEGER ( INPUT i-oct AS CHARACTER ) :
  DEFINE VARIABLE j_num AS INTEGER NO-UNDO.

  RUN conv-oct-to-int IN THIS-PROCEDURE ( INPUT i-oct, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION. /* Oct2Int */
    &ENDIF

PROCEDURE conv-oct-to-int :
  DEFINE  INPUT PARAMETER p-oct AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int AS INTEGER   NO-UNDO.

  DEFINE VARIABLE jj     AS INTEGER NO-UNDO.
  DEFINE VARIABLE j_sign AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-oct = TRIM( p-oct ).
    IF SUBSTRING( p-oct, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-oct  = SUBSTRING( p-oct, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-oct ) :
      ASSIGN p-int = p-int * 8 + LOOKUP( SUBSTRING( p-oct, jj, 1 ), "0,1,2,3,4,5,6,7":U ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END. /* ON ERROR */
END PROCEDURE. /* conv-oct-to-int */

  &ENDIF
&UNDEF SELF-NAME

&SCOP Std_Func_NumDays ~
    &IF "{2}" <> "procedure-only" &THEN ~
FUNCTION NumDays RETURNS INTEGER ( INPUT i-date AS DATE ) : ~
  DEFINE VARIABLE j_days AS INTEGER NO-UNDO. ~
~
  RUN get-day-number IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j_days ) NO-ERROR. ~
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_days ). ~
END FUNCTION. /* NumDays */ ~
    &ENDIF ~
~
PROCEDURE get-day-number : ~
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO. ~
  DEFINE OUTPUT PARAMETER p-days AS INTEGER NO-UNDO. ~
~
  DEFINE VARIABLE month-days AS INTEGER NO-UNDO EXTENT 11 INITIAL [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30 ]. ~
  DEFINE VARIABLE j_month    AS INTEGER NO-UNDO. ~
  DEFINE VARIABLE j_year     AS INTEGER NO-UNDO. ~
  DEFINE VARIABLE jj         AS INTEGER NO-UNDO. ~
~
  DO ON ERROR UNDO, RETURN ERROR : ~
    IF p-date = ? THEN DO: ASSIGN p-date = TODAY. END. ~
    ASSIGN j_year  = YEAR(  p-date ) ~
           j_month = MONTH( p-date ) - 1 ~
           p-days  = DAY(   p-date ). ~
    IF INTEGER( TRUNCATE( j_year * 0.25, 0 ) ) * 4 = j_year THEN DO: ASSIGN month-days[ 2 ] = month-days[ 2 ] + 1. END. ~
    DO jj = 1 TO j_month : ~
      ASSIGN p-days = p-days + month-days[ jj ]. ~
    END. ~
  END. /* ON ERROR */ ~
END PROCEDURE. /* get-day-number */

&SCOP  SELF-NAME NumDays
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

{&Std_Func_NumDays}

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME DateNum
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION DateNum RETURNS DATE ( INPUT i-days AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE t_date AS DATE NO-UNDO.

  RUN get-date-for-day-number IN THIS-PROCEDURE ( INPUT i-days, INPUT i-year, OUTPUT t_date ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE t_date ).
END FUNCTION. /* DateNum */
    &ENDIF

PROCEDURE get-date-for-day-number :
  DEFINE  INPUT PARAMETER p-days AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-date AS DATE    NO-UNDO.

  DEFINE VARIABLE month-days AS INTEGER NO-UNDO EXTENT 11 INITIAL [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30 ].
  DEFINE VARIABLE j-month    AS INTEGER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-year = ? THEN DO: ASSIGN p-year = YEAR( TODAY ). END.
    IF p-year < 100 THEN DO: ASSIGN p-year = p-year + ( IF p-year < 50 THEN 2000 ELSE 1900 ). END.
    IF INTEGER( TRUNCATE( p-year * 0.25, 0 ) ) * 4 = p-year THEN DO: ASSIGN month-days[ 2 ] = month-days[ 2 ] + 1. END.
    DO j-month = 1 TO 11 :
      IF p-days > month-days[ j-month ] THEN DO: ASSIGN p-days = p-days - month-days[ j-month ]. END.
                                        ELSE DO: LEAVE. END.
    END.
    ASSIGN p-date = ( IF p-days > 31 THEN ? ELSE DATE( j-month, p-days, p-year ) ).
  END. /* ON ERROR */
END PROCEDURE. /* get-date-for-day-number */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME KeyStamp
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION KeyStamp RETURNS CHARACTER :
  DEFINE VARIABLE c-stamp AS CHARACTER NO-UNDO.

  RUN get-key-stamp IN THIS-PROCEDURE ( OUTPUT c-stamp ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE c-stamp ).
END FUNCTION. /* KeyStamp */
    &ENDIF

PROCEDURE get-key-stamp :
  DEFINE OUTPUT PARAMETER p-key AS CHARACTER NO-UNDO.

  DEFINE VARIABLE t_date AS DATE      NO-UNDO.
  DEFINE VARIABLE c-date AS CHARACTER NO-UNDO.
  DEFINE VARIABLE j_time AS INTEGER   NO-UNDO.
  DEFINE VARIABLE c-time AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN t_date  = TODAY
           j_time  = TIME.
    IF t_date <> TODAY THEN DO:
      ASSIGN t_date  = TODAY
             j_time  = TIME.
    END.
    ASSIGN c-date = STRING( t_date, "99/99/99":U )
           c-time = STRING( j_time, "HH:MM:SS":U ).
    ASSIGN p-key  = SUBSTRING( c-date, 7, 2 ) + SUBSTRING( c-date, 4, 2 ) +
                    SUBSTRING( c-date, 1, 2 ) + REPLACE(   c-time, ":", "":U ).
  END. /* ON ERROR */
END PROCEDURE. /* get-key-stamp */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Week-Num
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

  &SCOP  SELF-NAME NumDays
    &IF LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 OR
        LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 &THEN

{&Std_Func_NumDays}

    &ENDIF
  &UNDEF SELF-NAME

  &SCOP  SELF-NAME WeekDay-Rus
    &IF LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 OR
        LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 &THEN

{&Std_Func_WeekDay-Rus}

    &ENDIF
  &UNDEF SELF-NAME

  &SCOP  SELF-NAME Week-Num

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Week-Num RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE j-week AS INTEGER NO-UNDO.

  RUN get-week-number IN THIS-PROCEDURE ( INPUT i-date, OUTPUT j-week ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j-week ).
END FUNCTION. /* Week-Num */
    &ENDIF

PROCEDURE get-week-number :
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-week AS INTEGER NO-UNDO.

  DEFINE VARIABLE j-days AS INTEGER NO-UNDO.
    &IF "{2}" <> "procedure-only" &THEN
  DEFINE VARIABLE j_days AS INTEGER NO-UNDO.
    &ENDIF

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO:
      ASSIGN p-date = TODAY.
      IF p-date <> TODAY THEN DO: ASSIGN p-date = TODAY. END.
    END.
      &IF "{2}" <> "procedure-only" &THEN
    ASSIGN j-days = NumDays( p-date ) + WeekDay-Rus( DATE( 1, 1, YEAR( p-date ) ) ) - 2.
      &ELSE
    ASSIGN j-days = 0.
    RUN get-day-number      IN THIS-PROCEDURE ( INPUT p-date, OUTPUT j_days ) NO-ERROR.
    ASSIGN j-days = j-days + j_days.
    RUN get-weekday-num-rus IN THIS-PROCEDURE ( INPUT p-date, OUTPUT j_days ) NO-ERROR.
    ASSIGN j-days = j-days + j_days - 2.
      &ENDIF
    ASSIGN p-week = INTEGER( TRUNCATE( j-days / 7, 0 ) ) + 1.
  END. /* ON ERROR */
END PROCEDURE. /* get-week-number */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Week-From
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

  &SCOP  SELF-NAME WeekDay-Rus
    &IF LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 AND
        LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 AND
        LOOKUP( '^Week-Num',     {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  'Week-Num',     {&Std-Func_defined-list} ) = 0 &THEN

{&Std_Func_WeekDay-Rus}

    &ENDIF
  &UNDEF SELF-NAME

  &SCOP  SELF-NAME Week-From

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Week-From RETURNS DATE ( INPUT i-num AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE t-date AS DATE NO-UNDO.

  RUN get-week-start IN THIS-PROCEDURE ( INPUT i-num, INPUT i-year, OUTPUT t-date ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE t-date ).
END FUNCTION. /* Week-From */
    &ENDIF

PROCEDURE get-week-start :
  DEFINE  INPUT PARAMETER p-num  AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-date AS DATE    NO-UNDO.

  DEFINE VARIABLE month-days AS INTEGER NO-UNDO EXTENT 11 INITIAL [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30 ].
  DEFINE VARIABLE j-month    AS INTEGER NO-UNDO.
  DEFINE VARIABLE j-day      AS INTEGER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-num < 1 OR p-num > 53 THEN DO: UNDO, RETURN ERROR. END.
    IF p-year = ? THEN DO: ASSIGN p-year = YEAR( TODAY ). END.
    IF p-year < 100 THEN DO: ASSIGN p-year = p-year + ( IF p-year < 50 THEN 2000 ELSE 1900 ). END.
    IF INTEGER( TRUNCATE( p-year * 0.25, 0 ) ) * 4 = p-year THEN DO: ASSIGN month-days[ 2 ] = month-days[ 2 ] + 1. END.
      &IF "{2}" <> "procedure-only" &THEN
    IF WeekDay-Rus( DATE( 1, 1, p-year ) ) <> 1 THEN DO:
      &ELSE
    RUN get-weekday-num-rus IN THIS-PROCEDURE ( INPUT DATE( 1, 1, p-year ), OUTPUT j-day ) NO-ERROR.
    IF j-day <> 1 THEN DO:
      &ENDIF
      IF p-num = 1 THEN DO:
        ASSIGN p-date = DATE( 1, 1, p-year )
    &IF "{2}" <> "procedure-only" &THEN
               p-date = p-date - WeekDay-Rus( p-date ) + 1
    &ELSE
        .
        RUN get-weekday-num-rus IN THIS-PROCEDURE ( INPUT p-date, OUTPUT j-day ) NO-ERROR.
        ASSIGN p-date = p-date - j-day + 1
    &ENDIF
        .
        RETURN.
      END.         ELSE DO: ASSIGN p-num = p-num - 1. END.
    END.
      &IF "{2}" <> "procedure-only" &THEN
    ASSIGN j-day = p-num * 7 - WeekDay-Rus( DATE( 1, 1, p-year ) ) + 2.
      &ELSE
    RUN get-weekday-num-rus IN THIS-PROCEDURE ( INPUT DATE( 1, 1, p-year ), OUTPUT j-day ) NO-ERROR.
    ASSIGN j-day = p-num * 7 - j-day + 2.
      &ENDIF
    DO j-month = 1 TO 11 :
      IF j-day > month-days[ j-month ] THEN DO: ASSIGN j-day = j-day - month-days[ j-month ]. END.
                                       ELSE DO: LEAVE. END.
    END.
    ASSIGN p-date = ( IF j-day > 31 THEN ? ELSE DATE( j-month, j-day, p-year ) ).
  END. /* ON ERROR */
END PROCEDURE. /* get-week-start */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Week-Till
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

  &SCOP  SELF-NAME WeekDay-Rus
    &IF LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 AND
        LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 AND
        LOOKUP( '^Week-Num',     {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  'Week-Num',     {&Std-Func_defined-list} ) = 0 AND
        LOOKUP( '^Week-From',    {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  'Week-From',    {&Std-Func_defined-list} ) = 0 &THEN

{&Std_Func_WeekDay-Rus}

    &ENDIF
  &UNDEF SELF-NAME

  &SCOP  SELF-NAME Week-Till

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Week-Till RETURNS DATE ( INPUT i-num AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE t-date AS DATE NO-UNDO.

  RUN get-week-stop IN THIS-PROCEDURE ( INPUT i-num, INPUT i-year, OUTPUT t-date ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE t-date ).
END FUNCTION. /* Week-Till */
    &ENDIF

PROCEDURE get-week-stop :
  DEFINE  INPUT PARAMETER p-num  AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-date AS DATE    NO-UNDO.

  DEFINE VARIABLE month-days AS INTEGER NO-UNDO EXTENT 11 INITIAL [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30 ].
  DEFINE VARIABLE j-month    AS INTEGER NO-UNDO.
  DEFINE VARIABLE j-day      AS INTEGER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-num < 1 OR p-num > 53 THEN DO: UNDO, RETURN ERROR. END.
    IF p-year = ? THEN DO: ASSIGN p-year = YEAR( TODAY ). END.
    IF p-year < 100 THEN DO: ASSIGN p-year = p-year + ( IF p-year < 50 THEN 2000 ELSE 1900 ). END.
    IF INTEGER( TRUNCATE( p-year * 0.25, 0 ) ) * 4 = p-year THEN DO: ASSIGN month-days[ 2 ] = month-days[ 2 ] + 1. END.
      &IF "{2}" <> "procedure-only" &THEN
    ASSIGN j-day = p-num * 7 - WeekDay-Rus( DATE( 1, 1, p-year ) ) + 1.
      &ELSE
    RUN get-weekday-num-rus IN THIS-PROCEDURE ( INPUT DATE( 1, 1, p-year ), OUTPUT j-day ) NO-ERROR.
    ASSIGN j-day = p-num * 7 - j-day + 1.
      &ENDIF
    IF j-day > 337 + month-days[ 2 ] THEN DO:
      ASSIGN j-day  = j-day  - ( 337 + month-days[ 2 ] )
             p-year = p-year + 1.
      ASSIGN p-date = ( IF j-day > 31 THEN ? ELSE DATE( 1, j-day, p-year ) ).
      RETURN.
    END.
    DO j-month = 1 TO 11 :
      IF j-day > month-days[ j-month ] THEN DO: ASSIGN j-day = j-day - month-days[ j-month ]. END.
                                       ELSE DO: LEAVE. END.
    END.
    ASSIGN p-date = ( IF j-day > 31 THEN ? ELSE DATE( j-month, j-day, p-year ) ).
  END. /* ON ERROR */
END PROCEDURE. /* get-week-stop */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Week-Date
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

  &SCOP  SELF-NAME WeekDay-Rus
    &IF LOOKUP( '*',             {&Std-Func_defined-list} ) = 0 AND
        LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 AND
        LOOKUP( '^Week-Num',     {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  'Week-Num',     {&Std-Func_defined-list} ) = 0 AND
        LOOKUP( '^Week-From',    {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  'Week-From',    {&Std-Func_defined-list} ) = 0 AND
        LOOKUP( '^Week-Till',    {&Std-Func_defined-list} ) > 0 AND
        LOOKUP(  'Week-Till',    {&Std-Func_defined-list} ) = 0 &THEN

{&Std_Func_WeekDay-Rus}

    &ENDIF
  &UNDEF SELF-NAME

  &SCOP  SELF-NAME Week-Date

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Week-Date RETURNS DATE ( INPUT i-week AS INTEGER, INPUT i-day AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE t-date AS DATE NO-UNDO.

  RUN get-weekday-date IN THIS-PROCEDURE ( INPUT i-week, INPUT i-day, INPUT i-year, OUTPUT t-date ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE t-date ).
END FUNCTION. /* Week-Date */
    &ENDIF

PROCEDURE get-weekday-date :
  DEFINE  INPUT PARAMETER p-week AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-day  AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-date AS DATE    NO-UNDO.

  DEFINE VARIABLE month-days AS INTEGER NO-UNDO EXTENT 11 INITIAL [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30 ].
  DEFINE VARIABLE j-month    AS INTEGER NO-UNDO.
  DEFINE VARIABLE j-day      AS INTEGER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-week < 1 OR p-week > 53 THEN DO: UNDO, RETURN ERROR. END.
    IF p-year = ? THEN DO: ASSIGN p-year = YEAR( TODAY ). END.
    IF p-year < 100 THEN DO: ASSIGN p-year = p-year + ( IF p-year < 50 THEN 2000 ELSE 1900 ). END.
    IF INTEGER( TRUNCATE( p-year * 0.25, 0 ) ) * 4 = p-year THEN DO: ASSIGN month-days[ 2 ] = month-days[ 2 ] + 1. END.
      &IF "{2}" <> "procedure-only" &THEN
    IF WeekDay-Rus( DATE( 1, 1, p-year ) ) <> 1 THEN DO:
      &ELSE
    RUN get-weekday-num-rus IN THIS-PROCEDURE ( INPUT DATE( 1, 1, p-year ), OUTPUT j-day ) NO-ERROR.
    IF j-day <> 1 THEN DO:
      &ENDIF
      IF p-week = 1 THEN DO:
        ASSIGN p-date = DATE( 1, 1, p-year )
    &IF "{2}" <> "procedure-only" &THEN
               p-date = p-date - WeekDay-Rus( p-date ) + 1
    &ELSE
        .
        RUN get-weekday-num-rus IN THIS-PROCEDURE ( INPUT p-date, OUTPUT j-day ) NO-ERROR.
        ASSIGN p-date = p-date - j-day + 1
    &ENDIF
        .
        RETURN.
      END.          ELSE DO: ASSIGN p-week = p-week - 1. END.
    END.
    ASSIGN j-day = p-week * 7 - WeekDay-Rus( DATE( 1, 1, p-year ) ) + p-day + 1.
      &IF "{2}" <> "procedure-only" &THEN
    ASSIGN j-day = p-week * 7 - WeekDay-Rus( DATE( 1, 1, p-year ) ) + p-day + 1.
      &ELSE
    RUN get-weekday-num-rus IN THIS-PROCEDURE ( INPUT DATE( 1, 1, p-year ), OUTPUT j-day ) NO-ERROR.
    ASSIGN j-day = p-week * 7 - j-day + p-day + 1.
      &ENDIF
    DO j-month = 1 TO 11 :
      IF j-day > month-days[ j-month ] THEN DO: ASSIGN j-day = j-day - month-days[ j-month ]. END.
                                       ELSE DO: LEAVE. END.
    END.
    ASSIGN p-date = ( IF j-day > 31 THEN ? ELSE DATE( j-month, j-day, p-year ) ).
  END. /* ON ERROR */
END PROCEDURE. /* get-weekday-date */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Week-Date-Eng
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Week-Date-Eng RETURNS DATE ( INPUT i-week AS INTEGER, INPUT i-day AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE t-date AS DATE NO-UNDO.

  RUN get-weekday-date-eng IN THIS-PROCEDURE ( INPUT i-week, INPUT i-day, INPUT i-year, OUTPUT t-date ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE t-date ).
END FUNCTION. /* Week-Date */
    &ENDIF

PROCEDURE get-weekday-date-eng :
  DEFINE  INPUT PARAMETER p-week AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-day  AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-date AS DATE    NO-UNDO.

  DEFINE VARIABLE month-days AS INTEGER NO-UNDO EXTENT 11 INITIAL [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30 ].
  DEFINE VARIABLE j-month    AS INTEGER NO-UNDO.
  DEFINE VARIABLE j-day      AS INTEGER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-week < 1 OR p-week > 53 THEN DO: UNDO, RETURN ERROR. END.
    IF p-year = ? THEN DO: ASSIGN p-year = YEAR( TODAY ). END.
    IF p-year < 100 THEN DO: ASSIGN p-year = p-year + ( IF p-year < 50 THEN 2000 ELSE 1900 ). END.
    IF INTEGER( TRUNCATE( p-year * 0.25, 0 ) ) * 4 = p-year THEN DO: ASSIGN month-days[ 2 ] = month-days[ 2 ] + 1. END.
    IF WEEKDAY( DATE( 1, 1, p-year ) ) <> 1 THEN DO:
      IF p-week = 1 THEN DO:
        ASSIGN p-date = DATE( 1, 1, p-year )
               p-date = p-date - WEEKDAY( p-date ) + 1.
        RETURN.
      END.          ELSE DO: ASSIGN p-week = p-week - 1. END.
    END.
    ASSIGN j-day = p-week * 7 - WEEKDAY( DATE( 1, 1, p-year ) ) + p-day + 1.
    DO j-month = 1 TO 11 :
      IF j-day > month-days[ j-month ] THEN DO: ASSIGN j-day = j-day - month-days[ j-month ]. END.
                                       ELSE DO: LEAVE. END.
    END.
    ASSIGN p-date = ( IF j-day > 31 THEN ? ELSE DATE( j-month, j-day, p-year ) ).
  END. /* ON ERROR */
END PROCEDURE. /* get-weekday-date-eng */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Leap-Year
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Leap-Year RETURNS LOGICAL ( INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE bissextile AS LOGICAL NO-UNDO.

  RUN get-leap-year-sign IN THIS-PROCEDURE ( INPUT i-year, OUTPUT bissextile ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE bissextile ).
END FUNCTION. /* Leap-Year */
    &ENDIF

PROCEDURE get-leap-year-sign :
  DEFINE  INPUT PARAMETER p-year AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-sign AS LOGICAL NO-UNDO.

  DEFINE VARIABLE t_date AS DATE NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-year = ? OR p-year = 0 THEN DO:
      ASSIGN t_date = TODAY.
      IF t_date <> TODAY THEN DO: ASSIGN t_date = TODAY. END.
      ASSIGN p-year = YEAR( t_date ).
    END.
    ASSIGN p-sign = ( INTEGER( TRUNCATE( p-year * 0.25, 0 ) ) * 4 = p-year ).
  END. /* ON ERROR */
END PROCEDURE. /* get-leap-year-sign */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Leap-Year-d
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Leap-Year-d RETURNS LOGICAL ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE bissextile AS LOGICAL NO-UNDO.

  RUN get-leap-year-sign-d IN THIS-PROCEDURE ( INPUT i-date, OUTPUT bissextile ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE bissextile ).
END FUNCTION. /* Leap-Year */
    &ENDIF

PROCEDURE get-leap-year-sign-d :
  DEFINE  INPUT PARAMETER p-date AS DATE    NO-UNDO.
  DEFINE OUTPUT PARAMETER p-sign AS LOGICAL NO-UNDO.

  DEFINE VARIABLE j-year AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF p-date = ? THEN DO:
      ASSIGN p-date = TODAY.
      IF p-date <> TODAY THEN DO: ASSIGN p-date = TODAY. END.
    END.
    ASSIGN j-year = YEAR( p-date ).
    ASSIGN p-sign = ( INTEGER( TRUNCATE( j-year * 0.25, 0 ) ) * 4 = j-year ).
  END. /* ON ERROR */
END PROCEDURE. /* get-leap-year-sign-d */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Sparse
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Sparse RETURNS CHARACTER ( INPUT p-instring AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-sparsed-string IN THIS-PROCEDURE ( INPUT p-instring, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION. /* Sparse */
    &ENDIF

PROCEDURE get-sparsed-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE jj AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN p-outstring = p-outstring + ( IF p-outstring = "":U THEN "":U ELSE " ":U ) + SUBSTRING( p-instring, jj, 1 ).
    END.
    ASSIGN p-outstring = CAPS( TRIM( p-outstring ) ).
  END.
END PROCEDURE. /* get-sparsed-string */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME SparseSymbol
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION SparseSymbol RETURNS CHARACTER ( INPUT p-instring AS CHARACTER, INPUT p-symbol AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-sparsed-symbol IN THIS-PROCEDURE ( INPUT p-instring, INPUT p-symbol, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION. /* SparseSymbol */
    &ENDIF

PROCEDURE get-sparsed-symbol :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-symbol    AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE jj AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF LENGTH( p-symbol ) > 1 THEN DO: ASSIGN p-symbol = SUBSTRING( p-symbol, 1, 1 ). END.
    IF p-symbol <> "":U THEN DO: ASSIGN p-instring = REPLACE( p-instring, " ":U, p-symbol ). END.
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN p-outstring = p-outstring + ( IF p-outstring = "":U THEN "":U ELSE p-symbol ) +
                           SUBSTRING( p-instring, jj, 1 ).
    END.
    ASSIGN p-outstring = CAPS( TRIM( p-outstring ) ).
  END.
END PROCEDURE. /* get-sparsed-symbol */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Compress
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Compress RETURNS CHARACTER ( INPUT p-instring AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-compressed-string IN THIS-PROCEDURE ( INPUT p-instring, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION. /* Compress */
    &ENDIF

PROCEDURE get-compressed-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE jj       AS INTEGER   NO-UNDO.
  DEFINE VARIABLE c-symbol AS CHARACTER NO-UNDO.
  DEFINE VARIABLE j-blanks AS INTEGER   NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM( p-instring ).
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN c-symbol = SUBSTRING( p-instring, jj, 1 ).
      IF c-symbol = " ":U THEN DO:
        ASSIGN j-blanks = j-blanks + 1.
      END.                ELSE DO:
        ASSIGN p-outstring = p-outstring + ( IF j-blanks > 1 THEN " ":U ELSE "":U ) + c-symbol
               j-blanks    = 0.
      END.
    END.
    ASSIGN p-outstring = TRIM( p-outstring ).
  END.
END PROCEDURE. /* get-compressed-string */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME CompressSymbol
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION CompressSymbol RETURNS CHARACTER ( INPUT p-instring AS CHARACTER, INPUT p-symbol AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-compressed-symbol IN THIS-PROCEDURE ( INPUT p-instring, INPUT p-symbol, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION. /* CompressSymbol */
    &ENDIF

PROCEDURE get-compressed-symbol :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-symbol    AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE jj       AS INTEGER   NO-UNDO.
  DEFINE VARIABLE c-symbol AS CHARACTER NO-UNDO.
  DEFINE VARIABLE j-blanks AS INTEGER   NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM( p-instring ).
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN c-symbol = SUBSTRING( p-instring, jj, 1 ).
      IF c-symbol = p-symbol THEN DO:
        ASSIGN j-blanks = j-blanks + 1.
      END.                ELSE DO:
        ASSIGN p-outstring = p-outstring + ( IF j-blanks > 1 THEN p-symbol ELSE "":U ) + c-symbol
               j-blanks    = 0.
      END.
    END.
    ASSIGN p-outstring = TRIM( p-outstring ).
  END.
END PROCEDURE. /* get-compressed-symbol */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Centering
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Centering RETURNS CHARACTER ( INPUT i-string AS CHARACTER, INPUT i-length AS INTEGER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-centre-string IN THIS-PROCEDURE ( INPUT i-string, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION. /* Centering */
    &ENDIF

PROCEDURE get-centre-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.
  DEFINE VARIABLE j-left   AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN j-left      = INTEGER( ( p-length - ( j-format + 1 ) ) * 0.5 )
             p-outstring = FILL( " ":U, j-left ) + p-instring + FILL( " ":U, p-length - ( j-left + j-format ) ).
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE. /* get-centre-string */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME CenteringSymbol
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION CenteringSymbol RETURNS CHARACTER ( INPUT i-string AS CHARACTER,
                                             INPUT i-symbol AS CHARACTER,
                                             INPUT i-length AS INTEGER    ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-centre-symbol IN THIS-PROCEDURE ( INPUT i-string, INPUT i-symbol, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION. /* CenteringSymbol */
    &ENDIF

PROCEDURE get-centre-symbol :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-symbol    AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.
  DEFINE VARIABLE j-left   AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF LENGTH( p-symbol ) > 1 THEN DO: ASSIGN p-symbol = SUBSTRING( p-symbol, 1, 1 ). END.
    ASSIGN j-format = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN j-left      = INTEGER( ( p-length - ( j-format + 1 ) ) * 0.5 )
             p-outstring = FILL( p-symbol, j-left ) + p-instring + FILL( p-symbol, p-length - ( j-left + j-format ) ).
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE. /* get-centre-symbol */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME ShiftRight
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION ShiftRight RETURNS CHARACTER ( INPUT i-string AS CHARACTER, INPUT i-length AS INTEGER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-right-string IN THIS-PROCEDURE ( INPUT i-string, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION. /* ShiftRight */
    &ENDIF

PROCEDURE get-right-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN p-outstring = FILL( " ":U, p-length - j-format ) + p-instring.
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE. /* get-right-string */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME ShiftRightSymbol
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION ShiftRightSymbol RETURNS CHARACTER ( INPUT i-string AS CHARACTER,
                                              INPUT i-symbol AS CHARACTER,
                                              INPUT i-length AS INTEGER    ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-right-symbol IN THIS-PROCEDURE ( INPUT i-string, INPUT i-symbol, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION. /* ShiftRightSymbol */
    &ENDIF

PROCEDURE get-right-symbol :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-symbol    AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN p-outstring = FILL( p-symbol, p-length - j-format ) + p-instring.
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE. /* get-right-symbol */

  &ENDIF
&UNDEF SELF-NAME

&SCOP  SELF-NAME Digital
  &IF LOOKUP( '*',             {&Std-Func_defined-list} ) > 0 AND
      LOOKUP( '^{&SELF-NAME}', {&Std-Func_defined-list} ) = 0 OR
      LOOKUP(  '{&SELF-NAME}', {&Std-Func_defined-list} ) > 0 &THEN

    &IF "{2}" <> "procedure-only" &THEN
FUNCTION Digital RETURNS LOGICAL ( INPUT i-string AS CHARACTER ) :
  DEFINE VARIABLE l_is-digital AS LOGICAL NO-UNDO.

  RUN get-digital IN THIS-PROCEDURE ( INPUT i-string, OUTPUT l_is-digital ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN NO ELSE l_is-digital ).
END FUNCTION. /* Digital */
    &ENDIF

PROCEDURE get-digital :
  DEFINE  INPUT PARAMETER p-string  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-digital AS LOGICAL   NO-UNDO INITIAL NO.

  DO ON ERROR UNDO, RETURN ERROR :
    IF SUBSTRING( p-string, 1, 1 ) = "-" OR
       SUBSTRING( p-string, 1, 1 ) = "+" THEN DO:
      ASSIGN p-string = SUBSTRING( p-string, 2 ).
    END.
    ASSIGN p-string  = REPLACE( p-string, "0", "":U )
           p-string  = REPLACE( p-string, "1", "":U )
           p-string  = REPLACE( p-string, "2", "":U )
           p-string  = REPLACE( p-string, "3", "":U )
           p-string  = REPLACE( p-string, "4", "":U )
           p-string  = REPLACE( p-string, "5", "":U )
           p-string  = REPLACE( p-string, "6", "":U )
           p-string  = REPLACE( p-string, "7", "":U )
           p-string  = REPLACE( p-string, "8", "":U )
           p-string  = REPLACE( p-string, "9", "":U )
           p-string  = REPLACE( p-string, ".", "":U ).
    ASSIGN p-digital = ( p-string = "":U ).
  END.
END PROCEDURE. /* get-digital */

  &ENDIF
&UNDEF SELF-NAME

&IF "{1}" = "def" OR "{1}" = "help" &THEN
  &UNDEF Std-Func_i
  &UNDEF Std-Func_vss-revision
  &UNDEF Std-Func_vss-author
  &UNDEF Std-Func_vss-date
  &UNDEF Std-Func_vss-workfile
  &UNDEF Std-Func_vss-archive
  &UNDEF Std-Func_vss-description
  /* &UNDEF Std-Func_function-number */
  /* &UNDEF Std-Func_function-list */
  &UNDEF Std-Func_function-used
  &UNDEF Std-Func_func_not_used
  &UNDEF Std-Func_defined-list
&ENDIF


/* $Workfile$   E n d */