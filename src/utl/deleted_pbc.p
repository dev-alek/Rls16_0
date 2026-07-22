block-level on error undo, throw.

 /*
$Revision: bf04b0e5cfa2, 2256, rls $
$Author: druban $
$Date: Wed Dec 25 15:24:01 2019 +0300 $
$Workfile: deleted_pbc.p $
$Archive: utl/deleted_pbc.p $

Удаление дополнительных Баркодов по списку соответствий.

Автор: Шутилов Арнольд Валерьевич
Дата создания: 17/09/14
Author: Shutilov Arnold
Creation date: 17/09/14
*/

/* ***************************  Definitions  ************************** */

define variable vss-revision    as character no-undo init "$Revision: bf04b0e5cfa2, 2256, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:01 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: deleted_pbc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/deleted_pbc.p $":U .
define variable vss-description as character no-undo init "Удаление незакрытых накладных с просроч. платежами и связаными с ними ФО".

{ cmp/vssrevis.i }

define variable v-file-name as character no-undo.
define variable v-file-line-str as character initial "" no-undo. /* Cтрока из открываемого файла. */
define variable v-lst-del-pbc   as character initial "" no-undo. /* Полный список доп. Баркодов, подлежащих удалению. */
define variable v-cnt-line as integer no-undo.
define variable v-num-entry as integer no-undo.
define variable v-i as integer initial 0 no-undo.
define variable v-i1 as integer initial 0 no-undo. /* Здесь считаем кол-во планируемых пользователем к удалению доп.Бар-кодов. */
define variable v-i2 as integer initial 0 no-undo. /* Здесь считаем кол-во фактически удаляемых из ТН доп.Бар-кодов. */
define variable v-i3 as integer initial 0 no-undo. /* Здесь считаем кол-во повторных (допущенных пользователем) доп.Бар-кодов. */

define temp-table tt-deleted-pbc no-undo
    field b-str like ub.prod-bc.b-str       /* Какие нужно удалить доп. Баркоды (здесь данные из пользовательского файла соответствий на удаление). */
    index pi as primary unique b-str
.

/* ***************************  Definitions  ************************** */

/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */



/* **********************  Internal Procedures  *********************** */

procedure proc-mes-err-file-empty:
/* **************************** */
    message "Внимание!" skip
    "Файл соответствий не содержит значимых данных!" skip(2)
    "Обязательно проверьте:" skip
    "- доп.Бар-коды отделены друг от друга запятыми" skip
    "(кроме запятых не используйте в качестве разделителей кавычки и др. символы!);" skip
    "- доп.Бар-коды не содержат пустых значений или не состоят из одних пробелов;"
    "- под списком доп.Баркодов должна стоять пустая строка!" skip
    "- список соответствий заполняется в файле: deleted_pbc.txt"
    view-as alert-box error.

end procedure.

do:

    /* Жёсткое определение имени файла соответствий */
    v-file-name = "deleted_pbc.txt". /* ТН-3305. 2014г. Арн. Наименование файла соответствий от сокращённого deleted prod-bc, т.е. удаляемые доп. Баркоды (список на удаление). */

    /* Проверка наличия/Создание файла соответствия. */
    if search(v-file-name) = ? then
        do:
            message "Внимание!" skip
            "Не найден файл соответствия - deleted_pbc.txt" skip(2)
            "Создайте файл deleted_pbc.txt в рабочей директории и заполните его доп.Баркодами, которые Вы хотите удалить." view-as alert-box error.
            return.
/*            output to value(v-file-name).*/
/*            output close.                */
        end.

    /* *********************************************************************************************************************** */
    /* Перед работой с файлом - временно добавляем перевод каретки в конец файла (новая пустая строка). Баг Progress. */
    /*    output to value(v-file-name) append no-convert.*/
    /*        put skip(1).                               */
    /*    output close.                                  */

        /* ************************************************************** */
        /* Импорт файла соответствий во временную таблицу. */
        input from value(v-file-name).
            repeat:
                import unformatted v-file-line-str.
                v-lst-del-pbc = v-lst-del-pbc + trim(v-file-line-str).
                v-file-line-str = "".
                v-cnt-line = v-cnt-line + 1.
            end. /* repeat: */
        input close.
        /* ************************************************************** */

    /* После работы с файлом - пока не можем убрать временно добавленный перевод каретки в конец файла (новая пустая строка). Баг Progress. Нужно доработать! */
    /* NNN */
    /* *********************************************************************************************************************** */

    /* Проверка пустой-ли файл соответствий. */
        /* На этапе считывания данных из файла в переменную (если увидим, что импортировалось 0 линий, то зачем обрабатывать дальше). */
        if v-cnt-line = 0 then
            do:
                run proc-mes-err-file-empty.
                return.
            end.

        /* На этапе работы с переменной (исключаем доп. Баркоды-пустышки или заполненные пробелами) */
        /* Если нет (не пустой файл и не пустой список по num-entries) - производим промежуточное действие - заполняем временную таблицу для планируемого удаление доп. Баркодов ниже. */
        v-num-entry = num-entries(v-lst-del-pbc).
        if v-num-entry > 0 then
            do:
                do v-i = 1 to v-num-entry:
                    if trim(entry(v-i, v-lst-del-pbc, ",")) <> "" then
                        do:
                            /* Перед созданием очередной записи проверяем на повторы! */
                            if not can-find(first tt-deleted-pbc where tt-deleted-pbc.b-str = trim(entry(v-i, v-lst-del-pbc, ","))) then
                                do: /* Повторов нет: */
                                    create tt-deleted-pbc.
                                    tt-deleted-pbc.b-str = trim(entry(v-i, v-lst-del-pbc, ",")).
                                    v-i1 = v-i1 + 1.
                                end.
                            else /* Есть повторы, считаем их кол-во для отчёта в конце работы процедуры. */
                                do:
                                    v-i3 = v-i3 + 1.
                                end.
                        end.
                end.
            end.
        else /* Если да (пустой список по num-entries) т.е. доп. Баркодов к удалению нет - вывод сообщения об ошибке на экран. Может быть ситуация, когда произойдёт импорт из файла пустых или "пробельных" доп. Баркодов, т.е. попадаем сюда. */
            do:
                run proc-mes-err-file-empty.
                return.
            end.

/*    define buffer buf_prod-bc for ub.prod-bc.*/
/*    for each buf_prod-bc:                    */
/*    display buf_prod-bc.b-str.               */
/*    end.                                     */

/*    for each tt-deleted-pbc:*/
/*    display tt-deleted-pbc. */
/*    end.                    */

    /* Если нет (не пустой файл и не пустой список по num-entries) - производим основное действие - удаление доп. Баркодов фактическое, т.е. тех, которые РЕАЛЬНО хранятся в БД. */
    for each tt-deleted-pbc no-lock:
        find first ub.prod-bc where
        ub.prod-bc.b-str = tt-deleted-pbc.b-str exclusive-lock no-error.
        if available ub.prod-bc then
            do:
                v-i2 = v-i2 + 1. /* Подсчитываем РЕАЛЬНОЕ кол-во удалённых доп. Баркодов для отчётного сообщения в конце работы процедуры. */
                /*message "хочу удалить = " ub.prod-bc.b-str view-as alert-box.*/ delete ub.prod-bc.
            end.
    end.

    /* После окончания основного действия (удаление доп. Баркодов) - выводим отчёт-сообщение на экран */
    /* Файл соответствий пустой, или содержит незначащие данные: одни пробелы и "пуствшки". */
    if v-i2 = 0 and v-i1 = 0 then
    do:
        run proc-mes-err-file-empty.
        return.
    end.
    
    /* Планировалось удалить некоторые кол-во ДопБарКодов (которые суть - возможные значащие данные), но в ТН записей не нашлось. Удалять нечего. Извещаем пользователя. */
    if v-i2 = 0 then
        do:
            message "Внмание!" skip
            "Процесс удаления доп.Бар-кодов завершён." skip
            "Из запланированных к удалению - " v-i1 + v-i3 " позиц., " skip
            "удалено - " v-i2 " позиций доп.Бар-кодов." skip(2)
            "Запланированные к удалению поз. доп.Бар-кодов отсутствуют в ТН, возможно они удалены ранее!" view-as alert-box error.
        end.

    /* Когда разница между кол-вом запланированных удалений и реальным кол-вом удалённого. Есть ДБК отсутствующие в ТН, которые невозможно удалить. Извещаем пользователя об этом. */
    if v-i2 <> 0 and v-i1 <> v-i2 then
        do:
            message "Удаление доп.Бар-кодов произведено успешно!" skip
            "Из запланированных к удалению - " v-i1 + v-i3 " позиц., " skip 
            if v-i3 = 0 then "" else "исключено повторов - " string(v-i3) "," skip
            "удалено - " v-i2 " позиц. доп. Бар-кодов." skip
            "Не удалось удалить - " (v-i1 - v-i2) " позиц.  доп.Бар-кода,  котор. отсутств. в ТН." skip
            view-as alert-box information.
        end.

    /* Идеальный случай: Удалены все запланированные пользователем значения 100% */
    if v-i1 <> 0 and v-i1 = v-i2 then
        do:
            message "Удаление дополнительных Бар-кодов произведено успешно!" skip
            "Из запланированных к удалению - " v-i1 + v-i3 " позиц.," (if v-i3 = 0 then "" else " исключено повторов - " + string(v-i3) + ",") " удалено - " v-i2 " позиц. доп.Бар-кодов." view-as alert-box information.
        end.

end.