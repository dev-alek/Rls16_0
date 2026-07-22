/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение констант для AT форм.

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Принятые в этом файле буквы в названиях:

1. <o><n>:  L - Landscape, P - Portrait; n - номер блока.
2. Cn - COLUMN n    для колонки n (только в таблицах)
3. LS - LabelStart  позиция первого символа названия поля.
   LX - LabelFormat длина названия поля.
   S  - Start       позиция первого символа рамки
   E  - END         позиция последнего символа рамки
   W  - WIDTH       ширина рамки
   FS - FIELD       позиция первого символа поля.
   FX - FORMAT      длина строки для соответствующего поля.
   EXTn - EXTENDED   дополнительные позиции в указанном блоке (обязательно комментировать!)

                  ---------------------------
                  Имя поля  | значение поля |
                  --------------------------
                             FS
                 ---LX---    ------FX------
                 LS        S               E
                           -------X--------

Input:

Output:

*/

/*&GLOB L1-S 180    */
/*&GLOB L1-E 198   */

/* 0 - блок с адресом организации и т.п. */
&GLOB P0-FS 5
&GLOB P0-X 100        /*160*/
&GLOB P0-X1 80        /*вариант ширины первого блока*/

/* 1 - маленький блок вверху справа */
&GLOB P1-S 118
&GLOB P1-E 136
&GLOB P1-X 19

/* 3 - заголовок с названием */
&GLOB P3-LS 20
&GLOB P3-S 39
&GLOB P3-X 34
&GLOB P3-C2-S 58
&GLOB P3-E 72
&GLOB P3-EXT1 98    /*Конец надписи статуса документа*/

/* 4 - таблица с датой, временем для заполнения вручную */
&GLOB P4-S 5
&GLOB P4-X 135        /*длина линии*/
&GLOB P4-X0 133       /*длина внутренней линии = длина линии - 2*/
&GLOB P4-X1 99        /*длина линии от второй колонки до конца*/
&GLOB P4-E {&P4-S} + 134
&GLOB P4-C2-S {&P4-S} + 34
&GLOB P4-C2-S1 {&P4-S} + 35     /*начало линии от второй колонки до конца*/
&GLOB P4-C3-S {&P4-S} + 59
&GLOB P4-C4-S {&P4-S} + 84
&GLOB P4-C5-S {&P4-S} + 109

/* 5 - таблица на 2-й странице */
&GLOB P5-S 5
&GLOB P5-X 135        /*длина линии*/
&GLOB P5-X0 133       /*длина внутренней линии = длина линии - 2*/
&GLOB P5-X1 65        /*длина внутренней линии до начала 3-й колонки*/
&GLOB P5-X2 9         /*длина внутренней линии от начала 4-й до начала 6-й колонки*/
&GLOB P5-X3 19        /*длина внутренней линии от начала 7-й до начала 11-й колонки*/
&GLOB P5-X4 34        /*длина внутренней линии от начала 7-й до конца*/
&GLOB P5-E     {&P5-S} + 134
&GLOB P5-C2-S  {&P5-S} + 47
&GLOB P5-C3-S  {&P5-S} + 66
&GLOB P5-C4-S  {&P5-S} + 75
&GLOB P5-C5-S  {&P5-S} + 80
&GLOB P5-C6-S  {&P5-S} + 85
&GLOB P5-C7-S  {&P5-S} + 98
&GLOB P5-C8-S  {&P5-S} + 103
&GLOB P5-C9-S  {&P5-S} + 108
&GLOB P5-C10-S {&P5-S} + 113
&GLOB P5-C11-S {&P5-S} + 118

/*&GLOB P5-C1-FW 17*/
/*&GLOB P5-C2-FW  7*/
/*&GLOB P5-C3-FW  7*/
/*&GLOB P5-C4-FW  7*/
/*&GLOB P5-C5-FW  7*/
/*&GLOB P5-C6-FW  7*/
/*&GLOB P5-C7-FW  7*/
/*&GLOB P5-C8-FW  7*/
/*&GLOB P5-C9-FW  7*/
/*&GLOB P5-C10-FW 7*/
/*&GLOB P5-C11-FW 7*/

/* Заголовок для таблицы - зависит от начала следующего блока (P5) */
&GLOB P4-C1-FX 33
&GLOB P4-C2-FS {&P5-S} + 34
&GLOB P4-C2-FX 50
&GLOB P4-C3-FS {&P5-S} + 87
&GLOB P4-C3-FX 30
&GLOB P4-C4-FS {&P5-S} + 119
&GLOB P4-C4-FX 13

/* 6 - таблица на 3-й странице */
&GLOB P6-S 5
&GLOB P6-X 135         /*длина линии*/
&GLOB P6-X0 133        /*длина внутренней линии = длина линии - 2*/
&GLOB P6-X1 45         /*длина внутренней линии до начала 5-й колонки*/
&GLOB P6-X2 25         /*длина внутренней линии до начала 4-й колонки*/
&GLOB P6-X3 60         /*длина внутренней линии от начала 7-й до конца*/
&GLOB P6-X4 40         /*длина внутренней линии от начала 9-й до начала 13-й колонки*/
&GLOB P6-E     {&P6-S} + 134
&GLOB P6-C2-S  {&P6-S} + 6
&GLOB P6-C3-S  {&P6-S} + 6
&GLOB P6-C4-S  {&P6-S} + 6
&GLOB P6-C5-S  {&P6-S} + 6
&GLOB P6-C6-S  {&P6-S} + 16
&GLOB P6-C7-S  {&P6-S} + 20
&GLOB P6-C8-S  {&P6-S} + 11
&GLOB P6-C9-S  {&P6-S} + 20
&GLOB P6-C10-S {&P6-S} + 6
&GLOB P6-C11-S {&P6-S} + 6
&GLOB P6-C12-S {&P6-S} + 6
&GLOB P6-C13-S {&P6-S} + 6

/*&GLOB P6-C1-FW 17*/
/*&GLOB P6-C2-FW  7*/
/*&GLOB P6-C3-FW  7*/
/*&GLOB P6-C4-FW  7*/
/*&GLOB P6-C5-FW  7*/
/*&GLOB P6-C6-FW  7*/
/*&GLOB P6-C7-FW  7*/
/*&GLOB P6-C8-FW  7*/
/*&GLOB P6-C9-FW  7*/
/*&GLOB P6-C10-FW 7*/
/*&GLOB P6-C11-FW 7*/

/* Общие параметры */
&GLOB P-FOOTER-LINE 130 /* линия внизу для продолжения на след. странице */
&GLOB DATA-LINE "   "________________       г.
&GLOB DATA-LINE-SIZE 30

&GLOB PAGE-WIDTH 136
&GLOB PAGE-LENGTH 60

/*========================================================================*/
FUNCTION center-field RETURNS INTEGER (INPUT iStartPix AS INTEGER, iEndPix AS INTEGER,
                                  iInput AS INTEGER).
/* Функция возвращает начальную позицию для печати строки длиной iInput
   по центру в поле, заданном начальной и конечной позицией.

 Если строка не поместится в поле - возвращается (первая позиция + 1)
 Если iStartPix < 0 или iEndPix < iStartPix, возвращается 0
*/
  def var v-start-print as integer no-undo .

  if (iStartPix < 0) or (iEndPix < iStartPix) then return 0.

  assign
    v-start-print = INTEGER(iStartPix + ((iEndPix - iStartPix) / 2) - (iInput / 2))
  .

/*  if v-start-print - iStartPix < 1 then v-start-print = iStartPix + 1.*/

  RETURN v-start-print .

END FUNCTION.

/*========================================================================*/
FUNCTION right-field RETURNS INTEGER ( iEndPix AS INTEGER,
                                  iInput AS INTEGER).
/* Функция возвращает начальную позицию для печати строки длиной iInput
   по правому краю в поле, заданном конечной позицией.

    Если полученная позиция <0, возвращается 0
*/
  def var v-start-print as integer no-undo .

  assign
    v-start-print = INTEGER(iEndPix - 1 - iInput)
  .

  if v-start-print < 0 then return 0.

  RETURN v-start-print .

END FUNCTION.