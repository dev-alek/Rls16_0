block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrout.p $
$Archive: utl/fbrout.p $

Выгрузка данных по документу производства

Автор: Белоусов Илья Александрович
Дата создания: 07/09/08
Author: Ilia Belousov
Creation date: 07/09/08

Input:

Output:

*/

define temp-table temp_fbr-recipe no-undo
    field recipe-code   as character
    field recipe-type   as character
    field recipe-name   as character

    index pi is primary unique
        recipe-code
.
define variable v-fbrtest-frc-key    as integer      no-undo.

define input parameter p-fbr-doc-code   as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrout.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fbrout.p $":U .
define variable vss-description as character no-undo init "Выгрузка данных по документу производства".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

&scoped-define outfile "fbrout.txt"

define stream out-stream.

    define buffer buf_fbr-doc           for fbr-doc.
    define buffer buf_fbr-line          for fbr-line.
    define buffer buf_recipe            for recipe.
    define buffer buf_recipe-gds        for recipe-gds.
    define buffer buf_fbr-recipe        for fbr-recipe.
    define buffer buf_fbr-recipe-gds    for fbr-recipe-gds.
    define buffer buf_temp_fbr-recipe   for temp_fbr-recipe.
do
for buf_fbr-doc
  , buf_fbr-line
  , buf_recipe
  , buf_recipe-gds
  , buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_temp_fbr-recipe
on error undo, return error
:
    output stream out-stream to {&outfile}.
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-code
    no-error.
    if not available buf_fbr-doc
    then do:
        run write-log in this-procedure ( "Неверно задан номер документа производства", p-fbr-doc-code ).
        message
            substitute( "Неверно задан номер документа производства: &1", p-fbr-doc-code )
            skip
        view-as alert-box error.
        undo, return error .
    end.
    run write-log in this-procedure ( "Документ производства", buf_fbr-doc.doc-code ).
    run write-log in this-procedure ( "Тип объекта          ", buf_fbr-doc.obj-type ).
    run write-log in this-procedure ( "Код объекта          ", buf_fbr-doc.obj-code ).
    run write-log in this-procedure ( "Свободный            ", buf_fbr-doc.is-free ).
    run write-log in this-procedure ( "Удалён               ", buf_fbr-doc.is-del ).
    run write-log in this-procedure ( "Статус               ", buf_fbr-doc.status_ ).
    run write-log in this-procedure ( "Дата                 ", buf_fbr-doc.doc-date ).
    run write-log in this-procedure ( "Факт-дата            ", buf_fbr-doc.fact-date ).
    run write-log in this-procedure ( "Тип                  ", buf_fbr-doc.doc-type ).
    run write-log in this-procedure ( "Пользователь         ", buf_fbr-doc.user-name ).
    run write-log in this-procedure ( "Дата смены           ", buf_fbr-doc.shift-date ).
    run write-log in this-procedure ( "Номер смены          ", buf_fbr-doc.shift-num ).
    run write-log in this-procedure ( "Приход количество    ", buf_fbr-doc.in-qnty ).
    run write-log in this-procedure ( "Приход Уч.цены б.в.  ", buf_fbr-doc.in-base ).
    run write-log in this-procedure ( "Приход Уч.цены {&abbr_rub}.  ", buf_fbr-doc.in-rubl ).
    run write-log in this-procedure ( "Приход Пр.цены       ", buf_fbr-doc.in-sale ).
    run write-log in this-procedure ( "Приход Пр.ц.НДС б.в. ", buf_fbr-doc.in-vat-base ).
    run write-log in this-procedure ( "Приход Пр.ц.НДС {&abbr_rub}. ", buf_fbr-doc.in-vat-rubl ).
    run write-log in this-procedure ( "Расход количество    ", buf_fbr-doc.out-qnty ).
    run write-log in this-procedure ( "Расход Уч.цены б.в.  ", buf_fbr-doc.out-base ).
    run write-log in this-procedure ( "Расход Уч.цены {&abbr_rub}.  ", buf_fbr-doc.out-rubl ).
    run write-log in this-procedure ( "Расход Пр.цены       ", buf_fbr-doc.out-sale ).
    run write-log in this-procedure ( "Расход Пр.ц.НДС б.в. ", buf_fbr-doc.out-vat-base ).
    run write-log in this-procedure ( "Расход Пр.ц.НДС {&abbr_rub}. ", buf_fbr-doc.out-vat-rubl ).
    run write-log in this-procedure ( "Примечание           ", buf_fbr-doc.PS ).
    run write-log in this-procedure ( "CR"                   , "":U ).
    run write-log in this-procedure ( "line"                 , "":U ).
    for each buf_fbr-recipe no-lock
       where buf_fbr-recipe.doc-code    = buf_fbr-doc.doc-code
    on error undo, return error
    :
        find first buf_temp_fbr-recipe
             where buf_temp_fbr-recipe.recipe-code = buf_fbr-recipe.recipe-code
        no-error.
        if not available buf_temp_fbr-recipe
        then do:
            create buf_temp_fbr-recipe.
            assign
                buf_temp_fbr-recipe.recipe-code = buf_fbr-recipe.recipe-code
                buf_temp_fbr-recipe.recipe-type = buf_fbr-recipe.recipe-type
                buf_temp_fbr-recipe.recipe-name = buf_fbr-recipe.recipe-name
            .
        end.
    end.        /* for each buf_fbr-recipe */
    for each buf_temp_fbr-recipe no-lock
    on error undo, return error
    :
        run write-log in this-procedure ( "line"                 , "":U ).
        run write-log in this-procedure ( "line"                 , "":U ).
        run write-log in this-procedure ( "Рецепт документа производства", buf_temp_fbr-recipe.recipe-code ).
        run write-log in this-procedure ( "Тип рецепта                  ", buf_temp_fbr-recipe.recipe-type ).
        run write-log in this-procedure ( "Имя рецепта                  ", buf_temp_fbr-recipe.recipe-name ).
        for each buf_fbr-recipe no-lock
           where buf_fbr-recipe.doc-code    = buf_fbr-doc.doc-code
             and buf_fbr-recipe.recipe-code = buf_temp_fbr-recipe.recipe-code
        :
            run write-log in this-procedure ( "line", "":U ).
            run write-log in this-procedure ( "Код товара        ", buf_fbr-recipe.gds-code ).
            run write-log in this-procedure ( "Артикул           ", buf_fbr-recipe.artic ).
            run write-log in this-procedure ( "Производитель тип ", buf_fbr-recipe.prod-type ).
            run write-log in this-procedure ( "Производитель код ", buf_fbr-recipe.prod-code ).
            run write-log in this-procedure ( "Порция количество ", buf_fbr-recipe.portion-qnty ).
            run write-log in this-procedure ( "Порция вес        ", buf_fbr-recipe.portion-weight ).
            run write-log in this-procedure ( "Количество нетто  ", buf_fbr-recipe.qnty ).
            run write-log in this-procedure ( "Количество брутто ", buf_fbr-recipe.brutto-qnty ).
            run write-log in this-procedure ( "Цена продажи      ", buf_fbr-recipe.price-sale ).
            run write-log in this-procedure ( "Цена продажи НДС  ", buf_fbr-recipe.price-vat-sale ).
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = buf_fbr-recipe.recipe-code
            no-error.
            if available buf_recipe
            then do:
                run write-log in this-procedure ( "line", "":U ).
                run write-log in this-procedure ( "Рецепт системы, номер", buf_recipe.recipe-code ).
                run write-log in this-procedure ( "Рецепт системы, тип  ", buf_recipe.recipe-type ).
                run write-log in this-procedure ( "Рецепт системы, имя  ", buf_recipe.recipe-name ).
                run write-log in this-procedure ( "Код товара           ", buf_recipe.gds-code ).
                run write-log in this-procedure ( "Артикул              ", buf_recipe.artic ).
                run write-log in this-procedure ( "Производитель тип    ", buf_recipe.prod-type ).
                run write-log in this-procedure ( "Производитель код    ", buf_recipe.prod-code ).
                run write-log in this-procedure ( "Порция количество    ", buf_recipe.portion-qnty ).
                run write-log in this-procedure ( "Порция вес           ", buf_recipe.portion-weight ).
                run write-log in this-procedure ( "Количество нетто     ", buf_recipe.qnty ).
                run write-log in this-procedure ( "Количество брутто    ", buf_recipe.brutto-qnty ).
            end.
            run write-log in this-procedure ( "line", "":U ).
            run write-log in this-procedure ( "Строка документа     ", buf_recipe.recipe-code ).
            find first buf_fbr-line no-lock
                 where buf_fbr-line.prod-type   = buf_fbr-recipe.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe.prod-code
                   and buf_fbr-line.artic       = buf_fbr-recipe.artic
                   and buf_fbr-line.doc-code    = buf_fbr-doc.doc-code
            no-error.
            if available buf_fbr-line
            then do:
                run write-log in this-procedure ( "Тип (приход/списание)", buf_fbr-line.trn-type ).
                run write-log in this-procedure ( "Артикул              ", buf_fbr-line.artic ).
                run write-log in this-procedure ( "Производитель тип    ", buf_fbr-line.prod-type ).
                run write-log in this-procedure ( "Производитель код    ", buf_fbr-line.prod-code ).
                run write-log in this-procedure ( "Составной            ", buf_fbr-line.is-comp ).
                run write-log in this-procedure ( "Рассчитаны уч.цены   ", buf_fbr-line.is-calc ).
                run write-log in this-procedure ( "Метод расчёта        ", buf_fbr-line.calc-method ).
                run write-log in this-procedure ( "Сезонный коэффициент ", buf_fbr-line.coeff-value ).
                run write-log in this-procedure ( "Коэффициент отходов  ", buf_fbr-line.coeff-waste ).
                run write-log in this-procedure ( "Количество факт      ", buf_fbr-line.fact-qnty ).
                run write-log in this-procedure ( "Количество зарезерв. ", buf_fbr-line.rsrv-qnty ).
                run write-log in this-procedure ( "Уч.цена фиксирована  ", buf_fbr-line.fix-cost ).
                run write-log in this-procedure ( "Уч.цена б.в.         ", buf_fbr-line.price-base ).
                run write-log in this-procedure ( "Уч.цена {&abbr_rub}.         ", buf_fbr-line.price-rubl ).
                run write-log in this-procedure ( "Пр.цена              ", buf_fbr-line.price-sale ).
                run write-log in this-procedure ( "Сумма уч.ц. б.в.     ", buf_fbr-line.price-sum-base ).
                run write-log in this-procedure ( "Сумма уч.ц. {&abbr_rub}.     ", buf_fbr-line.price-sum-rubl ).
                run write-log in this-procedure ( "Сумма НДС уч.ц. б.в. ", buf_fbr-line.price-sum-vat-base ).
                run write-log in this-procedure ( "Сумма НДС уч.ц. {&abbr_rub}. ", buf_fbr-line.price-sum-vat-rubl ).
            end.
            else do:
                run write-log in this-procedure ( "*** Ошибка: нет строки документа производства.", buf_recipe.recipe-code ).
            end.
            for each buf_fbr-recipe-gds no-lock
               where buf_fbr-recipe-gds.doc-code    = buf_fbr-doc.doc-code
                 and buf_fbr-recipe-gds.recipe-code = buf_fbr-recipe.recipe-code
            on error undo, return error
            :
                run write-log in this-procedure ( "line", "":U ).
                run write-log in this-procedure ( "Ингредиент рецепта документа, артикул", buf_fbr-recipe-gds.artic ).
                run write-log in this-procedure ( "Производитель тип    ", buf_fbr-recipe-gds.prod-type ).
                run write-log in this-procedure ( "Производитель код    ", buf_fbr-recipe-gds.prod-code ).
                run write-log in this-procedure ( "Код товара           ", buf_fbr-recipe-gds.gds-code ).
                run write-log in this-procedure ( "Отходы               ", buf_fbr-recipe-gds.is-waste ).
                run write-log in this-procedure ( "Количество нетто     ", buf_fbr-recipe-gds.qnty ).
                run write-log in this-procedure ( "Количество брутто    ", buf_fbr-recipe-gds.brutto-qnty ).
                run write-log in this-procedure ( "Метод расчёта        ", buf_fbr-recipe-gds.calc-method ).
                run write-log in this-procedure ( "Сезонный коэффициент ", buf_fbr-recipe-gds.coeff-value ).
                run write-log in this-procedure ( "Коэффициент отходов  ", buf_fbr-recipe-gds.coeff-waste ).
                run write-log in this-procedure ( "Порядковый номер     ", buf_fbr-recipe-gds.proc-number ).
                find first buf_recipe-gds no-lock
                     where buf_recipe-gds.recipe-code = buf_fbr-recipe.recipe-code
                       and buf_recipe-gds.prod-type   = buf_fbr-recipe-gds.prod-type
                       and buf_recipe-gds.prod-code   = buf_fbr-recipe-gds.prod-code
                       and buf_recipe-gds.artic       = buf_fbr-recipe-gds.artic
                no-error.
                if available buf_recipe-gds
                then do:
                    run write-log in this-procedure ( "line", "":U ).
                    run write-log in this-procedure ( "Ингредиент рецепта системы, артикул", buf_recipe-gds.artic ).
                    run write-log in this-procedure ( "Производитель тип    ", buf_recipe-gds.prod-type ).
                    run write-log in this-procedure ( "Производитель код    ", buf_recipe-gds.prod-code ).
                    run write-log in this-procedure ( "Код товара           ", buf_recipe-gds.gds-code ).
                    run write-log in this-procedure ( "Количество нетто     ", buf_recipe-gds.qnty ).
                    run write-log in this-procedure ( "Количество брутто    ", buf_recipe-gds.brutto-qnty ).
                    run write-log in this-procedure ( "Метод расчёта        ", buf_recipe-gds.calc-method ).
                    run write-log in this-procedure ( "Коэффициент отходов  ", buf_recipe-gds.coeff-waste ).
                    run write-log in this-procedure ( "Порядковый номер     ", buf_recipe-gds.proc-number ).
                end.
                run write-log in this-procedure ( "line", "":U ).
                run write-log in this-procedure ( "Строка документа для ингредиента", buf_fbr-recipe-gds.artic ).
                find first buf_fbr-line no-lock
                     where buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                       and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                       and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                       and buf_fbr-line.doc-code    = buf_fbr-doc.doc-code
                no-error.
                if available buf_fbr-line
                then do:
                    run write-log in this-procedure ( "Тип (приход/списание)", buf_fbr-line.trn-type ).
                    run write-log in this-procedure ( "Артикул              ", buf_fbr-line.artic ).
                    run write-log in this-procedure ( "Производитель тип    ", buf_fbr-line.prod-type ).
                    run write-log in this-procedure ( "Производитель код    ", buf_fbr-line.prod-code ).
                    run write-log in this-procedure ( "Составной            ", buf_fbr-line.is-comp ).
                    run write-log in this-procedure ( "Рассчитаны уч.цены   ", buf_fbr-line.is-calc ).
                    run write-log in this-procedure ( "Метод расчёта        ", buf_fbr-line.calc-method ).
                    run write-log in this-procedure ( "Сезонный коэффициент ", buf_fbr-line.coeff-value ).
                    run write-log in this-procedure ( "Коэффициент отходов  ", buf_fbr-line.coeff-waste ).
                    run write-log in this-procedure ( "Количество факт      ", buf_fbr-line.fact-qnty ).
                    run write-log in this-procedure ( "Количество зарезерв. ", buf_fbr-line.rsrv-qnty ).
                    run write-log in this-procedure ( "Уч.цена фиксирована  ", buf_fbr-line.fix-cost ).
                    run write-log in this-procedure ( "Уч.цена б.в.         ", buf_fbr-line.price-base ).
                    run write-log in this-procedure ( "Уч.цена {&abbr_rub}.         ", buf_fbr-line.price-rubl ).
                    run write-log in this-procedure ( "Пр.цена              ", buf_fbr-line.price-sale ).
                    run write-log in this-procedure ( "Сумма уч.ц. б.в.     ", buf_fbr-line.price-sum-base ).
                    run write-log in this-procedure ( "Сумма уч.ц. {&abbr_rub}.     ", buf_fbr-line.price-sum-rubl ).
                    run write-log in this-procedure ( "Сумма НДС уч.ц. б.в. ", buf_fbr-line.price-sum-vat-base ).
                    run write-log in this-procedure ( "Сумма НДС уч.ц. {&abbr_rub}. ", buf_fbr-line.price-sum-vat-rubl ).
                end.
                else do:
                    run write-log in this-procedure ( "*** Ошибка: нет строки документа производства.", buf_recipe.recipe-code ).
                end.
            end.        /* for each buf_fbr-recipe-gds */
        end.
    end.        /* for each buf_temp_fbr-recipe */
    output stream out-stream close.
end.

/*==========================================================================*/
procedure write-log :
define input parameter p-name-string    as character        no-undo.
define input parameter p-value-string   as character        no-undo.

do
on error undo, return error
:
    case p-name-string
    :
        when "line":U
        then do:
            put stream out-stream unformatted
                fill( "=", 80 ) + {&new-line}
            .
        end.        /* when "line":U */
        when "CR":U
        then do:
            put stream out-stream unformatted
                {&new-line}
            .
        end.        /* when "line":U */
        otherwise do:
            put stream out-stream unformatted
                substitute( "&2: &3&1", {&new-line}, p-name-string, p-value-string )
            .
        end.        /* otherwise */
    end case.       /* case p-name-string */
end.
end procedure. /* write-log */