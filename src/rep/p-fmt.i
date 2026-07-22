/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры форматирования для печатных форм

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:
    { cmp/str-glbl.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define month-list-for-date 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U


&global-define p-fmt-split-max-blank 20

define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character

    index pi is primary unique
        str-key
.
define variable v-p-fmt-{&vssseq}-str-key    as integer      no-undo.

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

/*==========================================================================
Преобразовывает строку для выравнивания (добавляет пробелы до строки)
Input:
    p-in-string     - Исходная строка
    p-page-width    - Ширина страницы
    p-align-type    - Тип выравнивания: 'left':U, 'right':U, 'center':U
*/
function p-fmt-align-string returns character (
      p-in-string      as character
    , p-page-width     as integer
    , p-align-type     as character
).

    define variable v-string-length     as integer      no-undo.
    define variable v-out-string        as character    no-undo.

    assign
        v-string-length = length( trim( p-in-string ) )
    .
    if v-string-length >= p-page-width
    then do:
        assign
            v-out-string = trim( p-in-string )
        .
    end.        /* if v-string-length >= p-page-width */
    else do:
        case p-align-type
        :
            when 'left':U
            then do:
                assign
                    v-out-string = trim( p-in-string )
                .
            end.        /* when 'left':U */
            when 'right':U
            then do:
                assign
                    v-out-string = fill( " ":U, p-page-width - v-string-length ) + trim( p-in-string )
                .
            end.        /* when 'right':U */
            when 'center':U
            then do:
                assign
                    v-out-string = fill( " ":U, integer( ( p-page-width - v-string-length ) / 2 ) ) + trim( p-in-string )
                .
            end.        /* when 'center':U */
        end case.       /* case p-align-type */
    end.        /* if NOT( v-string-length >= p-page-width ) */

    return v-out-string .

end function.

/*==========================================================================
Разбивает строку на две строки.
Input:
    p-source-string     - Исходная строка
    p-split-length      - Длина строк после разбиения.

Output:
    p-string-1          - Первая часть строки
    p-string-2          - Вторая часть строки

*/
procedure p-fmt-split-string :
define input parameter p-source-string  as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define output parameter p-string-1      as character        no-undo.
define output parameter p-string-2      as character        no-undo.
do
on error undo, return error
:
    define variable v-space-pos    as integer      no-undo.

    if length( p-source-string ) <= p-split-length
    then do:
        assign
            p-string-1 = p-source-string
        .
    end.        /* if length( p-source-string ) <= p-split-length */
    else do:
        assign
            v-space-pos = r-index( p-source-string, " ":U, p-split-length )
        .
        if v-space-pos = 0
        then do:
            assign
                v-space-pos = index( p-source-string, " ":U )
            .
        end.
        if v-space-pos = 0
        then do:
            assign
                p-string-1 = substring( p-source-string, 1, p-split-length )
                p-string-2 = trim( substring( p-source-string, p-split-length, p-split-length ) )
            .
        end.
        else do:
            assign
                p-string-1 = substring( p-source-string, 1, v-space-pos )
                p-string-2 = trim( substring( p-source-string, v-space-pos ) )
            .
        end.
    end.        /* NOT ( if length( p-source-string ) <= p-split-length ) */
end.
end procedure. /* split-string */

/*==========================================================================
Процедура округления для печатных форм

Input:
    p-qnty          - количество
    p-price-no-VAT  - цена без НДС
    p-VAT           - НДС на единицу товара
    p-SLT           - НП на единицу товара
    p-road-tax      - дорожный налог на единицу товара

Output:
    p-new-price-no-VAT  - округленная цена без НДС
    p-new-VAT           - округленный НДС на единицу товара
    p-new-SLT           - округленный НП на единицу товара
    p-new-sum-VAT       - округленная сумма НДС
    p-new-sum-SLT       - округленная сумма НП
    p-new-sum-road-tax  - округленная сумма дорожного налога
    p-new-sum-no-VAT    - округленная сумма без НДС
    p-new-sum-full      - округленная сумма

*/
procedure p-fmt-round :
define input parameter p-qnty               as decimal          no-undo.
define input parameter p-price-no-VAT       as decimal          no-undo.
define input parameter p-VAT                as decimal          no-undo.
define input parameter p-SLT                as decimal          no-undo.
define input parameter p-road-tax           as decimal          no-undo.
define output parameter p-new-price-no-VAT  as decimal          no-undo.
define output parameter p-new-VAT           as decimal          no-undo.
define output parameter p-new-SLT           as decimal          no-undo.
define output parameter p-new-sum-VAT       as decimal          no-undo.
define output parameter p-new-sum-SLT       as decimal          no-undo.
define output parameter p-new-sum-road-tax  as decimal          no-undo.
define output parameter p-new-sum-no-VAT    as decimal          no-undo.
define output parameter p-new-sum-full      as decimal          no-undo.

    define variable v-vat-pc    as decimal      no-undo.
    define variable v-slt-pc    as decimal      no-undo.
do
on error undo, return error
:
    if p-price-no-VAT = 0
    then do:
        assign
            p-new-price-no-VAT = 0.0
            p-new-VAT          = ?
            p-new-SLT          = ?
            p-new-sum-VAT      = 0.0
            p-new-sum-SLT      = 0.0
            p-new-sum-no-VAT   = 0.0
            p-new-sum-road-tax = 0.0
            p-new-sum-full     = 0.0
        .
    end.
    else do:
        assign
            v-vat-pc            = p-VAT / p-price-no-VAT
            v-slt-pc            = p-SLT / ( p-price-no-VAT + p-VAT )
            p-new-price-no-VAT  = round( p-price-no-VAT, 2 )
            p-new-VAT           = round( p-new-price-no-VAT * v-vat-pc, 2 )
            p-new-SLT           = round( ( p-new-price-no-VAT + p-new-VAT ) * v-slt-pc, 2 )
            p-new-sum-VAT       = round( p-new-VAT          * p-qnty, 2 )
            p-new-sum-SLT       = round( ( p-new-price-no-VAT + p-new-VAT ) * p-qnty * v-slt-pc, 2 )
            p-new-sum-no-VAT    = round( p-new-price-no-VAT * p-qnty, 2 )
            p-new-sum-road-tax  = round( p-road-tax * p-qnty, 2 )
            p-new-sum-full      = round( ( p-new-price-no-VAT + p-new-VAT + p-new-SLT + p-road-tax ) * p-qnty, 2 )
        .
    end.
end.
end procedure. /* p-fmt-round */

/*==========================================================================
Разбивает строку p-in-string на подстроки длиной по p-split-length,
для каждой подстроки создаёт запись buf_temp_p-fmt_string-part
*/
procedure p-fmt-split :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.

    define variable v-start-pos     as integer      no-undo.
    define variable v-end-pos       as integer      no-undo.

    define buffer buf_temp_p-fmt_string-part        for temp_p-fmt_string-part.
do
for buf_temp_p-fmt_string-part
on error undo, return error
:
    empty temp-table buf_temp_p-fmt_string-part.
    if p-split-length < 1
    then do:
        undo, return error substitute( "p-fmt-split: Строка не может быть разбита на &1 частей", p-split-length ).
    end.
    assign
        p-in-string                 = trim( p-in-string )
        v-p-fmt-{&vssseq}-str-key   = 0
        v-start-pos                 = 1
        v-end-pos                   = length( p-in-string )
    .
    run p-fmt-get-string-range in this-procedure (
          input p-in-string
        , input p-split-length
        , input v-start-pos
        , output v-start-pos
        , output v-end-pos
    ).
    do while v-end-pos <> 0
    :
        create buf_temp_p-fmt_string-part.
        assign
            v-p-fmt-{&vssseq}-str-key = v-p-fmt-{&vssseq}-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-{&vssseq}-str-key
            buf_temp_p-fmt_string-part.string-part  = substring( p-in-string, v-start-pos, v-end-pos - v-start-pos )
        .
        assign
            v-start-pos = v-end-pos + 1
        .
        run p-fmt-get-string-range in this-procedure (
              input p-in-string
            , input p-split-length
            , input v-start-pos
            , output v-start-pos
            , output v-end-pos
        ).
    end.
end.
end procedure. /* p-fmt-split */


/*==========================================================================*/
procedure p-fmt-get-string-range :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define input parameter p-old-start-pos  as integer          no-undo.
define output parameter p-start-pos     as integer          no-undo.
define output parameter p-end-pos       as integer          no-undo.

    define variable v-init-string    as character    no-undo.
    define variable v-temp-char      as character    no-undo.
    define variable v-temp-pos       as integer      no-undo.
    define variable v-counter        as integer      no-undo.
do
on error undo, return error
:
    assign
        p-start-pos   = p-old-start-pos
        v-init-string = substring( p-in-string, p-start-pos )
    no-error.
    if error-status :error
    or trim( v-init-string ) = "":U
    then do:
        assign
            p-end-pos = 0
        .
        undo, return .
    end.
    assign
        v-temp-char   = substring( v-init-string, 1, 1 )
    .
    do
    while trim( v-temp-char ) = "":U
    :
        assign
            p-start-pos     = p-start-pos + 1
            v-init-string   = substring( p-in-string, p-start-pos )
            v-temp-char     = substring( v-init-string, 1, 1 )
        .
    end.        /* do */
    assign
        v-temp-pos  = p-split-length
        v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        v-counter   = 0
    .
    search-word-end:
    do
    while trim( v-temp-char ) <> "":U
    :
        assign
            v-counter   = v-counter + 1
        .
        if v-counter > {&p-fmt-split-max-blank}
        then do:
            assign
                v-temp-pos  = p-split-length
            .
            leave search-word-end.
        end.
        assign
            v-temp-pos  = v-temp-pos - 1
            v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        .
    end.
    assign
        p-end-pos = p-start-pos + v-temp-pos - 1
    .
end.
end procedure. /* p-fmt-get-string-range */