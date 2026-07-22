/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Производство - процедуры работы со складом

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

Required:
    { cmp/str-glbl.i }
    { cmp/library.i  }
    { trg/partslib.i }
*/

/*==========================================================================*/
/*
    Input:
        p-autofbr - при автоматической раскрутке производства в остатках должны
                    учитываться все партии, а не только положительные. Иначе не удастс
                    зарезервировать товар в документе внутреннего перемещения (там
                    нельзя резервировать с образованием отрицательных партий).
*/
procedure fbrrest-get-free-qnty :
do
on error undo, return error
:
define input parameter p-obj-type       as character            no-undo.
define input parameter p-obj-code       as integer              no-undo.
define input parameter p-gds-code       as integer              no-undo.
define input parameter p-autofbr        as logical              no-undo.
define output parameter p-avail-qnty    as decimal              no-undo.

    define variable v-req-qnty  like ub.fbr-line.fact-qnty no-undo.  /* вспомогательная переменная */
    define variable v-free-qnty as decimal       no-undo.

    define buffer buf_goods         for ub.goods.
    define buffer buf_gds-obj       for ub.gds-obj.
    define buffer buf_temp-parts    for temp-parts.

    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    assign
        p-avail-qnty = 0
    .
    run partslib-init-temp-parts in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_goods.artic
        , input buf_goods.prod-type
        , input buf_goods.prod-code
    ).
    assign
        v-free-qnty = 0
    .
    for each buf_temp-parts
    on error undo, return error
    :
        if buf_temp-parts.qnty > 0
        then do:        /* Собрать свободное количество, которое может быть зарезервировано */
            assign
                v-free-qnty = v-free-qnty + buf_temp-parts.free-qnty
            .
        end.
    end.        /* for each buf_temp-parts */
    assign
        p-avail-qnty = ( if v-free-qnty > 0 then v-free-qnty else 0 )
    .
end.
end procedure. /* fbrrest-get-free-qnty */


/*==========================================================================*/
/*
    Определить объект - склад для кухни ресторана
    input:
        p-obj-code - код объекта кухни (тип объекта обязательно маг)
    output:
        p-catering-obj-type
        p-catering-obj-code -  объект склад для кухни, указанный в настройках объекта кухни.
*/
procedure fbrrest-get-catering-object :
do
on error undo, return error
:
define input parameter p-obj-code            as integer      no-undo.
define output parameter p-catering-obj-type  as character    no-undo.
define output parameter p-catering-obj-code  as integer      no-undo.

    define buffer buf_shop              for ub.shop.

    find first buf_shop no-lock
         where buf_shop.obj-code = p-obj-code
    .
    assign
        p-catering-obj-type = buf_shop.kitchen-store-type
        p-catering-obj-code = buf_shop.kitchen-store-code
    .
end.
end procedure. /* fbrrest-get-catering-object */