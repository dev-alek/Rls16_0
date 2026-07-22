/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с интерфейсом групп товаров

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define closed-noterminal-grp-mark "»"
&global-define opened-noterminal-grp-mark "«"
&global-define terminal-with-goods-grp-mark "•"
&global-define terminal-no-goods-grp-mark " "
&global-define selection-char "*"
&global-define choose-for-move "choose-for-move"

&global-define button-sel-only "b-sel"
&global-define buttons-sel-mark "b-sel,b-mark"
&global-define buttons-actn-sel-mark "b-sel,b-mark,b-actn-mark"
&global-define buttons-sel-term {&g#term} + ",b-sel"
&global-define buttons-sel-scales {&g#term} + ",b-scales"
&global-define buttons-for-move "buttons-for-move"
&global-define buttons-for-admin "buttons-for-admin"
&global-define grplib-grp-amount-for-warning 1000

&global-define tab-size 4
&global-define grplib-max-chars-in-full-grp-name 350
&global-define grplib-ascii-exclude-list-for-grp-name 47,92,58,63,34,60,62,171,187,183
&global-define grplib-literal-exclude-list-for-grp-name /\:*?"<>|«»·

&global-define grplib-separator chr(2)

define temp-table temp_grplib_grp no-undo
    field sel           as character     /* Метка выбора; обычно '*' */
    field nabor         as character     /* '+/-' */
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character     /* Метка перед именем группы; разные значения для терминальной группы,
                                            группы с раскрытыми подгруппами и группы с не наскрытыми подгруппами */
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical

    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.

define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character

    index pi is primary unique node-code
    index ps processed
.

define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.


/*==========================================================================*/
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
/* Настроечные параметры на будущее */
do
on error undo, return error
:

    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure. /* grplib-get-parameters */

/*==========================================================================*/
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.

    define variable v-upper-code    as integer           no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.

    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then {&grplib-separator} else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure. /* grplib-get-sort-name */

/*Процедура нахождения полного имени группы*/

{ ref/grplibfn.i }

/*==========================================================================*/
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.

    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure. /* grplib-get-root-code */

/*==========================================================================
Процедура заполняет temp-table temp_grplib_found-grp по заданному
полному имени (последняя группа имени может быть указана по первым буквам).
В случае, если группа не найдена - возвращается Error. Причина передается в
return-value.
fill-path указывает программе, как заполнять temp-table: yes - заполняютс
все найденные группы с соответствующими уровнями level, для последнего уровн
создается несколько записей temp-table для групп, найденных по шаблону.
no - заполняется только последний уровень.
*/
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.

    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.

    assign
        p-search-name = replace( p-search-name, {&slash-char}, {&grplib-separator} )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, {&grplib-separator} )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:        /* Для всех групп кроме последней ищем точное совпадение */
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, {&grplib-separator} )
            no-error .
            if not available buf_gds-grp
            then do: /* Не обнаружена группа с таким названием */
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, {&grplib-separator} ).
            end.
            else do:        /*  Есть такая группа. Идем дальше. */
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else {&delim-grp} )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else {&grplib-separator} ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + {&delim-grp}
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.        /* if v-counter < v-level */
        else do:        /* Для последней группы ищем совпадение по начальным символам и составляем список таких групп */
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, {&grplib-separator} )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else {&delim-grp} )
                                                        + buf_gds-grp.node-name + {&delim-grp}
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else {&grplib-separator} )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do: /* Нет ни одной группы с таким названием */
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
/*                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, {&grplib-separator} ).*/
            end.
        end.        /* if v-counter >= v-level */
    end.        /* do v-counter = 1 to v-level */
end.
end procedure. /* grplib-find-grp-by-full-name */

/*==========================================================================*/
/*  Процедура заполняет temp-table temp_grplib_found-grp
    списком подгрупп заданной группы, включая саму эту группу.
*/
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.

    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.

    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, {&delim-grp}) +
                                                        {&delim-grp} + buf_gds-grp.node-name + {&delim-grp}
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, {&grplib-separator}) +
                                                        {&grplib-separator} + buf_gds-grp.node-name + {&grplib-separator}
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, {&delim-grp}) +
                                                           {&delim-grp} + buf_gds-grp.node-name + {&delim-grp}
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, {&grplib-separator}) +
                                                           {&grplib-separator} + buf_gds-grp.node-name + {&grplib-separator}
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, {&delim-grp}) +
                                                            {&delim-grp} + buf_gds-grp.node-name + {&delim-grp}
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, {&grplib-separator}) +
                                                            {&grplib-separator} + buf_gds-grp.node-name + {&grplib-separator}
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure. /* grplib-find-all-subgroup */

/*==========================================================================*/
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.

    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.

    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        /*
            Если максимальная подстрока совпадает с именем группы и нет другой группы, начинающейся так же,
            то в конце строки ставим {&delim-grp}, если группа не терминальна
        */
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
                /*
                if v-is-terminal = no
                then do:
                    assign
                        p-end-name = p-end-name + {&delim-grp}
                    .
                end.
                */
            end.
        end.
    end.
end.
end procedure. /* grplib-expand-name */

/*==========================================================================*/
/* Вычисляет в списке строк temp_grplib_found-grp максимальную одинаковую начальную
    подстроку длиной не менее p-min-substring-length
    input:
        p-min-substring-length  as integer  - минимальная длина
    output:
        p-substring                         - максимальная одинаковая начальная подстрока
*/
/*==========================================================================*/
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.

        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp      /* Не была найдена подстрока */
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure. /* grplib-get-max-substring */

/*==========================================================================*/
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.

    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:                    /* Терминальная группа */
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure. /* grplib-is-terminal */

/*==========================================================================*/
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.

    define buffer buf_goods         for ub.goods.

    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure. /* grplib-have-goods */

/*==========================================================================*/
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.

    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.

    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + {&new-line} + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
        /* Нашли группу */
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure. /* grplib-find-by-substring */

/*==========================================================================
    Можно задать p-upper-code < 0 - тогда будет только проверка
    на недопустимые символы в имени группы.
*/
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.

    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.

    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "{&grplib-ascii-exclude-list-for-grp-name}"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы {&grplib-literal-exclude-list-for-grp-name}'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + {&new-line} + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > {&grplib-max-chars-in-full-grp-name}
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более {&grplib-max-chars-in-full-grp-name} символов.'
                .
            end.
        end.        /* if p-upper-code > 0 */
    end.
end.
end procedure. /* grplib-analyze-grp-name */

/*==========================================================================*/
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.

    define variable v-full-name    as character    no-undo.

do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, {&delim-grp} ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure. /* grplib-get-lvl-num */

/* $Workfile$ e n d */