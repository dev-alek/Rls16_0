block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись смены

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.shift-obj old buffer oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись смены".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,ub.shift-obj.obj-type,ub.shift-obj.obj-code,ub.shift-obj.shift-date,ub.shift-obj.shift-num,ub.shift-obj.status_)" }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ ref/gds-attr.i }

define variable v-today          as date      no-undo.
define variable v-time           as integer   no-undo.
define variable v-obj-date       as date      no-undo.
define variable v-sys-time       as integer   no-undo.
define variable v-sys-date       as date      no-undo.
define variable v-max-shift-days as integer   no-undo.
define variable v-par-type       as character no-undo.
define variable v-host-code      like ub.shop.host-code no-undo.

define buffer prev-shift      for ub.shift-obj. /* для поиска предыдущей смены */
define buffer buf_shift-obj   for ub.shift-obj.
define buffer buf_c-shift-obj for ub.c-shift-obj.
define buffer buf_c-sht-hist  for ub.c-sht-hist.

define variable l-shift-on         as logical   no-undo .
define variable lok                as logical   no-undo .
define variable v-avail-petrol     as logical   no-undo .
define variable v-is-petrol        as logical   no-undo .
define variable v-is-pieces        as logical   no-undo .
define variable v-ptrl-without-rvs as character no-undo .
define variable v-attr-type        as character no-undo .
define variable v-edit-time        as logical   no-undo .

define variable v-vid-action       as integer   no-undo .
define variable v-vid-ok           as logical   no-undo .
define variable v-vid-mes          as character no-undo .
define variable v-vid-param        as longchar  no-undo .

define variable v-shift-staff-list as character no-undo .
define variable v-shift-manager    as character no-undo .

define buffer buf_inkas    for ub.inkas .
define buffer buf_pl-gds   for ub.pl-gds .
define buffer buf_goods    for ub.goods .
define buffer buf_rvs-doc  for ub.rvs-doc .
define buffer buf_rvs-line for ub.rvs-line .

define variable v-fact-status-list as character no-undo .
define variable ii                 as integer   no-undo .

main-block:
do
    on error undo, return error return-value
    :

    v-fact-status-list = (if {&fact} < {&inquiry}
        then ({&fact} + {&comma-char} + {&inquiry})
        else ({&inquiry} + {&comma-char} + {&fact})).

  /* проверяем, что на объекте включены смены */
    { gbl/objat.i
    ub.shift-obj.obj-type
    ub.shift-obj.obj-code
    "'shift-on=request'"
    l-shift-on
    no-error
  }
    if error-status :error then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запуске процедуры objat" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if l-shift-on <> yes then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "На объекте выключены смены" skip
            "Работа со сменами невозможна" skip
            "Объект" ub.shift-obj.obj-type ub.shift-obj.obj-code skip
            view-as alert-box error .
        undo main-block, return error .
    end.

    /* нужно проверять возможные переходы графа статусов */
    if lookup (ub.shift-obj.status_, {&sht-stts}) = 0
        then 
    do:
        /* недопустимый статус смены */
        message
            "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
            "Недопустимый статус смены" ub.shift-obj.status_ skip
            "Невозможно выполнить операцию со сменой" skip
            view-as alert-box error .
        undo main-block, return error .
    end.

    if not new( ub.shift-obj )
        and ( ub.shift-obj.obj-type     <> oldb.obj-type
        or ub.shift-obj.obj-code   <> oldb.obj-code
        or ub.shift-obj.shift-date <> oldb.shift-date
        or ub.shift-obj.shift-num  <> oldb.shift-num
        )
        then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя менять уникальные параметры смены" skip
            "Объект:" ub.shift-obj.obj-type ub.shift-obj.obj-code skip
            "Смена:" ub.shift-obj.shift-date skip
            "Порядок:" ub.shift-obj.shift-num skip
            view-as alert-box error .
        undo main-block, return error .
    end.

    if not new( ub.shift-obj )
        and ub.shift-obj.shift-name <> oldb.shift-name
        then 
    do:
        find first buf_shift-obj no-lock
            where buf_shift-obj.obj-type   = ub.shift-obj.obj-type
            and buf_shift-obj.obj-code   = ub.shift-obj.obj-code
            and buf_shift-obj.shift-date = ub.shift-obj.shift-date
            and buf_shift-obj.shift-name = ub.shift-obj.shift-name
            and rowid( buf_shift-obj )   <> rowid( ub.shift-obj )
            no-error .
        if available buf_shift-obj then 
        do:
            message
                vss-workfile vss-revision vss-description skip(1)
                "Уже существует смена с номером:" ub.shift-obj.shift-name
                "Дата:" string( ub.shift-obj.shift-date, "99/99/9999" ) skip
                "Объект:" ub.shift-obj.obj-type ub.shift-obj.obj-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.

    if ub.shift-obj.shift-date = ?
        or ub.shift-obj.shift-num  = ?
        or ub.shift-obj.shift-name = ?
        then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Заданы не все основные параметры смены" skip
            "Объект:" ub.shift-obj.obj-type ub.shift-obj.obj-code skip
            "Смена:" ub.shift-obj.shift-date skip
            "Номер:" ub.shift-obj.shift-name skip
            "Порядок:" ub.shift-obj.shift-num skip
            "Статус:" ub.shift-obj.status_ skip
            view-as alert-box error .
        undo main-block, return error .
    end.

    /* Если правим время для закрытой смены */
    /* -------------------------- */

    if not g#news and ub.shift-obj.status_ = {&sht-closed} and oldb.status_ = {&sht-closed} then 
    do:
        run gbl/sht-time-check.p(
            ub.shift-obj.shift-date,
            ub.shift-obj.shift-num,
            ub.shift-obj.obj-type,
            ub.shift-obj.obj-code,
            ub.shift-obj.open-time,
            ub.shift-obj.close-time,
            ub.shift-obj.open-date,
            ub.shift-obj.close-date
            ) no-error.
      
        if error-status:error then
            return error return-value.
      
        v-edit-time = true.
    end.

    /* -------------------------- */

    /*---START--------- Проверки для ожидаемой смены ---------------------*/
    if ub.shift-obj.status_ = {&sht-expected} then 
    do:
        /* ожидаемая смена должна быть позже любой закрытой, текущей */
        /* ищем открытую смену по объекту */
        find last prev-shift
            where prev-shift.obj-type = ub.shift-obj.obj-type
            and prev-shift.obj-code = ub.shift-obj.obj-code
            and prev-shift.status_ = {&sht-current}
            no-error .
        if  available prev-shift
            and ( prev-shift.shift-date > ub.shift-obj.shift-date
            or ( prev-shift.shift-date = ub.shift-obj.shift-date
            and prev-shift.shift-num  > ub.shift-obj.shift-num ) )
            then 
        do:
            message
                "Была найдена смена со статусом" prev-shift.status_ skip
                "Любая текущая или закрытая смена должна дату или номер больший чем у ожидаемой смены" skip
                "Ожидаемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                "Найдена смена" prev-shift.shift-date "Номер" prev-shift.shift-num skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        /* ищем последнюю закрытую смену по объекту */
        find last prev-shift where
            prev-shift.obj-type = ub.shift-obj.obj-type and
            prev-shift.obj-code = ub.shift-obj.obj-code and
            prev-shift.status_ = {&sht-closed}
            use-index pi no-error.
        if available prev-shift
            and ( prev-shift.shift-date > ub.shift-obj.shift-date
            or ( prev-shift.shift-date = ub.shift-obj.shift-date
            and prev-shift.shift-num  > ub.shift-obj.shift-num ) )
            then 
        do:
            message
                "Найдена смена со статусом" prev-shift.status_ skip
                "Любая текущая или закрытая смена должна иметь дату или номер больший чем у ожидаемой смены" skip
                "Одидаемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num  skip
                "Найдена смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
/*---END----------- Проверки для ожидаемой смены ---------------------*/

  /* 20/IV-2018 curobjdt.i (чтение даты с провеками по всем параметрам и с возможной установкой
                более правильной даты заменить на objdtget.i (только чтение даты объекта),
                если по текущим изменениям будет предполагаться обильное тестирование смен и их закрытия.
  { gbl/objdtget.i ub.shift-obj.obj-type ub.shift-obj.obj-code v-obj-date no-error }
  if error-status:error then undo, return error
    substitute( "Ошибка чтения текущей даты на объекте &1&2 смены N&3", obj-type, obj-code, shiftnum ).
  */
    { gbl/curobjdt.i ub.shift-obj.obj-type ub.shift-obj.obj-code v-obj-date }
    if not g#news and not v-edit-time then 
    do:
        run cur-time in this-procedure ( output v-sys-date
            , output v-sys-time
            ).
        /* проверки выполняются только там, где закрывается смена */
        /* при приеме */
        if oldb.status_ = ub.shift-obj.status_ then 
        do:
            /* изменилось что-то кроме статуса */

            if  oldb.shift-date = ub.shift-obj.shift-date
                and oldb.shift-num  = ub.shift-obj.shift-num
                and ( oldb.status_ <> {&sht-expected}
                or oldb.open-time <> ub.shift-obj.open-time )
                then 
            do:
                /* любое изменение без изменения статуса должно затрагивать дату, номер или время смены */
                undo main-block, return error "Любое изменение смены без изменения статуса должно затрагивать дату, номер или время смены." .
            end.
            else 
            do:
                if ub.shift-obj.status_ <> {&sht-expected} then 
                do:
                    /* дату и номер смены можно менять только для ожидаемой смены */
                    message
                        "Дату или номер смены можно менять только для ожидаемой смены" skip
                        "Дата смены" oldb.shift-date skip
                        "Номер" oldb.shift-name skip
                        "Порядок" oldb.shift-num
                        view-as alert-box error .
                    undo main-block, return error .
                end.
            end.
        end.        /* oldb.status_ = ub.shift-obj.status_ */
        else 
        do:
            /* изменился статус */
            define variable v-valid-status-change as character no-undo .

            assign
                v-valid-status-change = (''              + '-' + {&sht-expected})
          + "," + (''              + '-' + {&sht-current} )
          + "," + ({&sht-expected} + '-' + {&sht-current} )
          + "," + ({&sht-current}  + '-' + {&sht-closed}  )
          + "," + ({&sht-expected} + '-' + {&sht-canceled})
          + "," + ({&sht-current}  + '-' + {&sht-expected})
          + "," + ({&sht-closed}   + '-' + {&sht-current} )
                .

            /* проверяем допустимость замены на соответствие списку возможных замен */
            if lookup( (oldb.status_ + '-' + ub.shift-obj.status_), v-valid-status-change) > 0
                then 
            do:
            /* ничего не делаем - это правильная смена статуса */
            end.
            else 
            do:
                message
                    "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                    "Недопустимая замена статуса" oldb.status_ "->" ub.shift-obj.status_ skip
                    "Невозможно выполнить операцию со сменой" skip
                    view-as alert-box error .
                undo main-block, return error .
            end.

            /* проверяем открытие смены */
            if  ub.shift-obj.status_ = {&sht-current}
                and (oldb.status_        = {&sht-expected}
                or oldb.status_        = ""
                )
                then 
            do:
                /* проверяем номер и дату смены */
                if ub.shift-obj.shift-num < {&min-shift-num}
                    or ub.shift-obj.shift-num > {&max-shift-num}
                    then 
                do:
                    message
                        "Неправильный номер смены" skip
                        "Невозможно открыть новую смену" skip
                        "Текущая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                if ub.shift-obj.shift-date <> v-obj-date then 
                do:
                    message
                        "Неправильная дата начала смены" skip
                        "Смену можно открыть только сегодняшним днем" skip
                        "Невозможно открыть новую смену" skip
                        "Текущая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.

                /* проверяем, нет ли открытой смены по объекту */
                find first prev-shift
                    where prev-shift.obj-type = ub.shift-obj.obj-type
                    and prev-shift.obj-code = ub.shift-obj.obj-code
                    and prev-shift.status_ = {&sht-current}
                    and recid (prev-shift) <> recid (ub.shift-obj)
                    no-error .
                if available prev-shift then 
                do:
                    message
                        "Не закрыта текущая смена" skip
                        "Невозможно открыть новую смену" skip
                        "Текущая смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.

                /* проверяем, нет ли открытых сверок по объекту */
                find first buf_rvs-doc
                    where buf_rvs-doc.obj-type = ub.shift-obj.obj-type
                    and buf_rvs-doc.obj-code = ub.shift-obj.obj-code
                    and buf_rvs-doc.rvs-type <> {&test-asi}
                    and buf_rvs-doc.status_  <> {&fact}
                    no-error .
                if available buf_rvs-doc then 
                do:
                    message
                        "Найдена незакрытая сверка" skip
                        "Невозможно открыть новую смену" skip
                        "Сверка" buf_rvs-doc.rvs-code skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.

                /* проверяем, все ли продажи по объекту закрыты */
                /* чтоб легло на индекс, делаем несколько find */
                do ii = 0 to num-entries(v-fact-status-list):
                    CASE ii:
                        when 0 then 
                            do:
                                find first buf_inkas no-lock
                                    where buf_inkas.obj-type = ub.shift-obj.obj-type
                                    and buf_inkas.obj-code = ub.shift-obj.obj-code
                                    and buf_inkas.status_ < entry(1, v-fact-status-list) no-error .
                            end.
                        when num-entries(v-fact-status-list) then 
                            do:
                                find first buf_inkas no-lock
                                    where buf_inkas.obj-type = ub.shift-obj.obj-type
                                    and buf_inkas.obj-code = ub.shift-obj.obj-code
                                    and buf_inkas.status_ > entry(num-entries(v-fact-status-list), v-fact-status-list) no-error .
                            end.
                        otherwise 
                        do:
                            find first buf_inkas no-lock
                                where buf_inkas.obj-type = ub.shift-obj.obj-type
                                and buf_inkas.obj-code = ub.shift-obj.obj-code
                                and buf_inkas.status_ > entry(ii, v-fact-status-list)
                                and buf_inkas.status_ < entry(ii + 1, v-fact-status-list)
                                no-error .
                        end.
                    END CASE.
                    if available buf_inkas then 
                    do:
                        message
                            "Найдена незакрытая продажа" skip
                            "Невозможно открыть новую смену" skip
                            "Продажа" buf_inkas.inkas-code skip
                            view-as alert-box error .
                        undo main-block, return error.
                    end.
                end.
                /* находим последнюю закрытую смену */
                find last prev-shift
                    where prev-shift.obj-type = ub.shift-obj.obj-type
                    and prev-shift.obj-code = ub.shift-obj.obj-code
                    and prev-shift.status_ = {&sht-closed}
                    use-index pi
                    no-error .
                if available prev-shift then 
                do:
                    /* проверяются соотношения между предыдущей и текущей сменами */
                    if  ub.shift-obj.shift-date > prev-shift.shift-date
                        or  ( ub.shift-obj.shift-date = prev-shift.shift-date
                        and ub.shift-obj.shift-num  > prev-shift.shift-num
                        )
                        then 
                    do:
                        /* OK: дата или номер смены больше чем у предыдущей смены*/
                        .
                    end.
                    else 
                    do:
                        message
                            "Найдена смена со статусом" {&sht-closed} skip
                            "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                            "Новая смена должна по времени идти после закрытой" skip
                            "Невозможно открыть новую смену" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                    if prev-shift.close-date < v-obj-date
                        or ( prev-shift.close-date = v-obj-date
                        and prev-shift.close-time < shift-obj.open-time    ) then 
                    do:
                    /* Новая смена будет закрыта после предыдущей, все как надо */
                    end.
                    else 
                    do:
                        message
                            "Найдена смена со статусом" {&sht-closed} skip
                            "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                            "Закрыта" prev-shift.close-date string (prev-shift.close-time, "HH:MM") skip
                            "Сейчас" v-obj-date string (ub.shift-obj.open-time, "HH:MM") skip
                            "Новая смена должна быть открыта после закрытия предыдущей" skip
                            "Невозможно открыть новую смену" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                end.

                /* ищем первую запланированную смену */
                find first prev-shift where
                    prev-shift.obj-type = ub.shift-obj.obj-type and
                    prev-shift.obj-code = ub.shift-obj.obj-code and
                    prev-shift.status_ = {&sht-expected}
                    use-index pi no-error.
                if available prev-shift then 
                do:
                    if oldb.status_ = {&sht-expected} then 
                    do:
                        /* текущая смена сделана путем включения запланированной */
                        if (prev-shift.shift-date < ub.shift-obj.shift-date or
                            prev-shift.shift-date = ub.shift-obj.shift-date and
                            prev-shift.shift-num < ub.shift-obj.shift-num) then 
                        do:
                            message
                                "Найдена более ранняя смена со статусом" {&sht-expected} skip
                                "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                                "Новую смену можно открыть только из нее" skip
                                "Невозможно открыть новую смену" skip
                                view-as alert-box error .
                            undo main-block, return error .
                        end.
                    end.
                    else 
                    do:
                        /* текущая смена сделана сразу как текущая */
                        message
                            "Найдена смена со статусом" {&sht-expected} skip
                            "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                            "Новую смену можно открыть, только изменив статус на" {&sht-current} skip
                            "Невозможно открыть новую смену" skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                end.
                /* проверяем, что новая смена открывается текущим днем */
                if ub.shift-obj.shift-date <> v-obj-date then 
                do:
                    message
                        "Открываемая смена" ub.shift-obj.shift-date ub.shift-obj.shift-name ub.shift-obj.shift-num skip
                        "Новая смена должна открываться сегодняшним числом" skip
                        "Невозможно открыть новую смену"
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                /* заполняем информацию об открытии */
                assign
                    ub.shift-obj.open-id   = g#userid
                    ub.shift-obj.open-date = v-obj-date
                    .
        
                v-vid-action = 51 .
                v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + {&delim-par} +
                    "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + {&delim-par} +
                    "RESULT=0" + {&delim-par} + 
                    "Description=".
            /*        run trg/video-action.p (input 51,          */
            /*                                input v-vid-param, */
            /*                                output v-vid-ok,   */
            /*                                output v-vid-mes) .*/
            end.
            /*---START--------- Проверяем закрытие смены ---------------------*/
            if ub.shift-obj.status_ = {&sht-closed} then 
            do:
                /* проверяются соотношения между датами и временами закрытия */
                if ub.shift-obj.open-date < v-obj-date
                    or (ub.shift-obj.open-date = v-obj-date
                    and ub.shift-obj.open-time < ub.shift-obj.close-time /* время закрытия на объекте может задаваться вручную */
                    )                                                 /* поэтому здесь оно уже задано */
                    then 
                do:
                /* OK: Дата-время закрытия смены - после даты-времени ее открытия */
                end.
                else 
                do:
                    message
                        "Время и дата открытия должны быть раньше закрытия" skip
                        "Открыта" ub.shift-obj.open-date string (ub.shift-obj.open-time, "HH:MM") skip
                        "Сейчас" v-obj-date string (ub.shift-obj.close-time, "HH:MM") skip
                        "Невозможно закрыть смену N" ub.shift-obj.shift-name "порядок" ub.shift-obj.shift-num "от" ub.shift-obj.shift-date skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                /* проверяем, нет ли другой открытой смены по объекту */
                find first prev-shift
                    where prev-shift.obj-type = ub.shift-obj.obj-type
                    and prev-shift.obj-code = ub.shift-obj.obj-code
                    and prev-shift.status_ = {&sht-current}
                    and recid (prev-shift) <> recid (ub.shift-obj)
                    no-error .
                if available prev-shift then 
                do:
                    message
                        "Найдена другая открытая смена" skip
                        "Невозможно закрыть текущую смену" skip
                        "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                /* проверяем, нет ли открытых сверок по объекту */
                find first buf_rvs-doc
                    where buf_rvs-doc.obj-type = ub.shift-obj.obj-type
                    and buf_rvs-doc.obj-code = ub.shift-obj.obj-code
                    and buf_rvs-doc.rvs-type <> {&test-asi}
                    and buf_rvs-doc.status_  <> {&fact}
                    no-error .
                if available buf_rvs-doc then 
                do:
                    message
                        "Найдена незакрытая сверка" skip
                        "Невозможно закрыть текущую смену" skip
                        "Сверка" buf_rvs-doc.rvs-code
                        view-as alert-box error .
                    undo main-block, return error .
                end.

                /* Проверим, есть ли топливные товары привязанные к местам хранения */
                assign
                    v-avail-petrol = false
                    .
                _block_chk-ptrl:
                for each buf_pl-gds
                    where buf_pl-gds.obj-type = ub.shift-obj.obj-type
                    and buf_pl-gds.obj-code = ub.shift-obj.obj-code
                    on error undo main-block, return error
                    :
                    find first buf_goods no-lock
                        where buf_goods.gds-code = buf_pl-gds.gds-code
                        .
                        { str/is-petrl.i
            buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            v-is-petrol
            v-is-pieces
            no-error
          }
                    if v-is-petrol = true
                        and v-is-pieces = false
                        then 
                    do:
                        assign
                            v-avail-petrol = true
                            .
                        leave _block_chk-ptrl.
                    end.
                end.

                if v-avail-petrol = true then 
                do:

                    find /* без last */ buf_rvs-doc  /* т.к. должна быть именно одна */
                        where buf_rvs-doc.obj-type   = ub.shift-obj.obj-type
                        and buf_rvs-doc.obj-code   = ub.shift-obj.obj-code
                        and buf_rvs-doc.shift-date = ub.shift-obj.shift-date
                        and buf_rvs-doc.shift-num  = ub.shift-obj.shift-num
                        and buf_rvs-doc.status_    = {&fact}
                        and buf_rvs-doc.rvs-type   = {&rvs-shift}
                        no-error .

                    /* проверяем, что последний документ смены это сменная сверка */
                    if not available buf_rvs-doc then 
                    do:
                        message
                            "Нет закрытой сверки сменой сверки" skip
                            "Невозможно закрыть текущую смену" skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num
                            view-as alert-box error .
                        undo main-block, return error .
                    end.

                    if ub.shift-obj.shift-name <> buf_rvs-doc.shift-name then 
                    do:
                        /* сверка не из этой смены */
                        message
                            "Последняя закрытая сверка за смену не соответствует текущей смене." skip
                            "Невозможно закрыть текущую смену." skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            "Сверка" buf_rvs-doc.rvs-code skip
                            "Сверка принадлежит смене" buf_rvs-doc.shift-date "Номер" buf_rvs-doc.shift-name "Порядок" buf_rvs-doc.shift-num skip
                            "Дата фактического закрытия сверки" buf_rvs-doc.fact-date skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.

                    /* ищем накладную или переоценку более позднюю, чем сверка */
                    find last ub.trn-doc
                        where ub.trn-doc.obj-type = ub.shift-obj.obj-type
                        and ub.trn-doc.obj-code = ub.shift-obj.obj-code
                        and ub.trn-doc.status_  = {&fact}
                        use-index stat-fact
                        no-error .
                    if available ub.trn-doc
                        and ub.trn-doc.fact-order > buf_rvs-doc.fact-order
                        then 
                    do:
                        /* накладная после сверки */
                        message
                            "Найдена накладная, которая закрыта позже закрывающей сверки" skip
                            "Невозможно закрыть текущую смену" skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            "Сверка" buf_rvs-doc.rvs-code skip
                            "Накладная" ub.trn-doc.doc-code
                            view-as alert-box error .
                        undo main-block, return error .
                    end.

                    find last ub.price-doc
                        where ub.price-doc.obj-type = ub.shift-obj.obj-type
                        and ub.price-doc.obj-code = ub.shift-obj.obj-code
                        and ub.price-doc.status_ = {&act-overvalue}
                        use-index fact-close
                        no-error .
                    if available ub.price-doc
                        and ub.price-doc.fact-order > buf_rvs-doc.fact-order
                        then 
                    do:
                        message
                            "Найдена переоценка, которая закрыта позже закрывающей сверки" skip
                            "Невозможно закрыть текущую смену" skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            "Сверка" buf_rvs-doc.rvs-code skip
                            "Переоценка" ub.price-doc.doc-num
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                    /* проверяем, что в закрывающей сверке все топливные места хранения */
                    for each buf_pl-gds
                        where buf_pl-gds.obj-type = ub.shift-obj.obj-type
                        and buf_pl-gds.obj-code = ub.shift-obj.obj-code,
                        first ub.place no-lock where ub.place.obj-type = buf_pl-gds.obj-type  
                        and ub.place.obj-code = buf_pl-gds.obj-code 
                        and ub.place.pl-code = buf_pl-gds.pl-code
                        and ub.place.status_ = ''
                        on error undo main-block, return error
                        :
                        find first buf_goods no-lock
                            where buf_goods.gds-code = buf_pl-gds.gds-code
                            .
                            { str/is-petrl.i
              buf_goods.artic
              buf_goods.prod-type
              buf_goods.prod-code
              v-is-petrol
              v-is-pieces
              no-error
            }
                        if v-is-petrol = true
                            and v-is-pieces = false
                            then 
                        do:
                            run gds-attr-value in this-procedure
                                ( input  buf_goods.gds-code
                                , input  {&attr-ptrl-without-rvs}
                                , output v-ptrl-without-rvs
                                , output v-attr-type
                                ) .

                            if lookup(v-ptrl-without-rvs, 'true,yes':u) = 0 then 
                            do:
                                find first buf_rvs-line
                                    where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                    and buf_rvs-line.gds-code = buf_pl-gds.gds-code
                                    and buf_rvs-line.pl-code  = buf_pl-gds.pl-code
                                    and buf_rvs-line.obj-type = ub.shift-obj.obj-type
                                    and buf_rvs-line.obj-code = ub.shift-obj.obj-code
                                    no-error .
                                if not available buf_rvs-line then 
                                do:
                                    message
                                        "Закрывающая сверка по смене не содержит всех действующих мест хранения топлива" skip
                                        "Невозможно закрыть текущую смену" skip
                                        "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                                        "Сверка" buf_rvs-doc.rvs-code skip
                                        "Код места хранения" buf_pl-gds.pl-code skip
                                        "Локальный код товара" buf_pl-gds.gds-code skip
                                        view-as alert-box error .
                                    undo main-block, return error .
                                end.
                            end.
                        end.
                    end.
                end.

                /* проверяем, все ли продажи по объекту закрыты */
                /* чтоб легло на индекс, делаем несколько find */
                find first ub.inkas
                    where ub.inkas.obj-type = ub.shift-obj.obj-type
                    and ub.inkas.obj-code = ub.shift-obj.obj-code
                    and ub.inkas.status_  > {&fact}
                    no-error .
                if not available ub.inkas then 
                do:
                    find first ub.inkas
                        where ub.inkas.obj-type = ub.shift-obj.obj-type
                        and ub.inkas.obj-code = ub.shift-obj.obj-code
                        and ub.inkas.status_  < {&fact}
                        no-error .
                end.
                if available ub.inkas then 
                do:
                end.
                do ii = 0 to num-entries(v-fact-status-list):
                    CASE ii:
                        when 0 then 
                            do:
                                find first buf_inkas no-lock
                                    where buf_inkas.obj-type = ub.shift-obj.obj-type
                                    and buf_inkas.obj-code = ub.shift-obj.obj-code
                                    and buf_inkas.status_ < entry(1, v-fact-status-list) no-error .
                            end.
                        when num-entries(v-fact-status-list) then 
                            do:
                                find first buf_inkas no-lock
                                    where buf_inkas.obj-type = ub.shift-obj.obj-type
                                    and buf_inkas.obj-code = ub.shift-obj.obj-code
                                    and buf_inkas.status_ > entry(num-entries(v-fact-status-list), v-fact-status-list) no-error .
                            end.
                        otherwise 
                        do:
                            find first buf_inkas no-lock
                                where buf_inkas.obj-type = ub.shift-obj.obj-type
                                and buf_inkas.obj-code = ub.shift-obj.obj-code
                                and buf_inkas.status_ > entry(ii, v-fact-status-list)
                                and buf_inkas.status_ < entry(ii + 1, v-fact-status-list)
                                no-error .
                        end.
                    END CASE.
                    if available buf_inkas then 
                    do:
                        message
                            "Найдена незакрытая продажа" skip
                            "Невозможно закрыть текущую смену" skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            "Продажа" buf_inkas.inkas-code skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                end.
                /* заполняем информацию о закрытии смены */
                run gbl/chk-date.p (
                    input shift-obj.obj-type
                    ,input shift-obj.obj-code
                    ,input v-obj-date
                    ,input shift-obj.close-time
                    ,input shift-obj.shift-date
                    ,input shift-obj.shift-num
                    ,input yes) no-error.
                if error-status :error then 
                do:
                    message "Ошибка при определении даты смены."
                        view-as alert-box error.
                    undo main-block, return error .
                end.

                assign
                    ub.shift-obj.close-id       = g#userid
                    ub.shift-obj.close-sys-date = v-sys-date
                    ub.shift-obj.close-sys-time = v-sys-time
                    /*  ub.shift-obj.close-date     = v-obj-date */ /* перенесено в sht-clos.p */ 
                    .
                { gbl/hostcode.i ub.shift-obj.obj-type ub.shift-obj.obj-code v-host-code }
                define variable v-value-character as character no-undo .
                define variable v-value-date      as date      no-undo .
                define variable v-value-decimal   as decimal   no-undo .
                define variable v-value-logical   as logical   no-undo .
                define variable v-tth             as handle    no-undo .
                define variable v-param-type      as character no-undo .

                run adm/shattri.p ( input "get":U
                    , input  ub.shift-obj.obj-type
                    , input  ub.shift-obj.obj-code
                    , input  {&attr-obj-date}
                    , input  {&attr-obj-date_diffshft}
                    , output v-value-character
                    , output v-value-date
                    , output v-value-decimal
                    , output v-max-shift-days
                    , output v-value-logical
                    , output v-param-type
                    , input-output table-handle v-tth
                    ) no-error .
                if error-status :error then 
                do:
                    /* параметр может быть не задан */
                    assign 
                        v-max-shift-days = 3.
                end.
                if ub.shift-obj.close-date > ub.shift-obj.open-date + v-max-shift-days then 
                do:
                    message
                        "С момента открытия смены прошло более " v-max-shift-days " дней" skip
                        "Смена не может быть закрыта датой " ub.shift-obj.close-date skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.

                /* проверка МЦ */
                find first ub.wth-doc no-lock
                    where ub.wth-doc.obj-type    = ub.shift-obj.obj-type
                    and ub.wth-doc.obj-code    = ub.shift-obj.obj-code
                    and ub.wth-doc.shift-date  = ub.shift-obj.shift-date
                    and ub.wth-doc.shift-num   = ub.shift-obj.shift-num
                    and ub.wth-doc.status_    <> {&fact}
                    no-error .
                if available ub.wth-doc then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при закрытии смены" skip
                        "Есть отркытые документы перемещения материальных ценностей" skip
                        "Документ МЦ" ub.wth-doc.doc-code skip
                        "Тип документа" ub.wth-doc.doc-type skip
                        "Дата" ub.wth-doc.doc-date skip
                        "Статус" ub.wth-doc.status_ skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.

                /* определяем fact-order */
                define variable v-fact-order           as decimal no-undo .
                define variable v-shift-end-fact-order as decimal no-undo .
                define variable v-day-end-fact-order   as decimal no-undo .

                run factord in this-procedure
                    (input  ub.shift-obj.close-date   /* p-fact-date            */
                    ,input  ub.shift-obj.close-time   /* p-fact-time            */
                    ,input  1                         /* p-fact-num             */
                    ,input  ub.shift-obj.shift-date   /* p-shift-date           */
                    ,input  ub.shift-obj.shift-num    /* p-shift-num            */
                    ,input  l-shift-on                /* p-shift-on             */
                    ,output v-fact-order              /* p-fact-order           */
                    ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
                    ,output v-day-end-fact-order      /* p-day-end-fact-order   */
                    ) no-error .
                if error-status :error
                    or v-fact-order = ?
                    or v-fact-order = 0 then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при определении фактического номера смены" skip
                        "obj-type"                ub.shift-obj.obj-type   skip
                        "obj-code"                ub.shift-obj.obj-code   skip
                        "fact-date"               ub.shift-obj.close-date skip
                        "fact-time"               ub.shift-obj.close-time skip
                        "shift-date"              ub.shift-obj.shift-date skip
                        "shift-num"               ub.shift-obj.shift-num  skip
                        "v-fact-order"            v-fact-order            skip
                        "v-shift-end-fact-order"  v-shift-end-fact-order  skip
                        "v-day-end-fact-order"    v-day-end-fact-order    skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                assign
                    ub.shift-obj.fact-order = v-shift-end-fact-order
                    .
        
                for each ub.shift-staff no-lock where ub.shift-staff.obj-type = ub.shift-obj.obj-type
                    and ub.shift-staff.obj-code = ub.shift-obj.obj-code
                    and ub.shift-staff.shift-num = ub.shift-obj.shift-num
                    and ub.shift-staff.shift-date = ub.shift-obj.shift-date
                    and ub.shift-staff.next-shift = no :
                    if ub.shift-staff.staff-role
                        then
                        assign
                            v-shift-manager = ub.shift-staff.name
                            .
                    else
                        assign
                            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
                            .                                  
                end.
        
                v-vid-action = 62 .
                v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + {&delim-par} +
                    "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + {&delim-par} +
                    "ShiftManager=" + v-shift-manager + {&delim-par} +
                    "ShiftStaff=" + v-shift-staff-list + {&delim-par} +
                    "RESULT=0" + {&delim-par} + 
                    "Description=".
            /*        run trg/video-action.p (input 62,          */
            /*                                input v-vid-param, */
            /*                                output v-vid-ok,   */
            /*                                output v-vid-mes) .*/
            end.
            /*---END----------- Проверяем закрытие смены ---------------------*/
            /*---START--------- Проверяем отмену закрытой смены ---------------------*/
            if ub.shift-obj.status_ = {&sht-current} and
                oldb.status_         = {&sht-closed} then 
            do:
                /* проверяем, нет ли другой открытой смены по объекту */
                find first prev-shift where
                    prev-shift.obj-type = ub.shift-obj.obj-type and
                    prev-shift.obj-code = ub.shift-obj.obj-code and
                    prev-shift.status_ = {&sht-current} and
                    recid (prev-shift) <> recid (ub.shift-obj) no-error.
                if available prev-shift then 
                do:
                    message
                        "Найдена другая открытая смена" skip
                        "Невозможно отменить закрытую смену" skip
                        "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                /* проверяем, последняя ли это закрытая смена */
                find last prev-shift where
                    prev-shift.obj-type = ub.shift-obj.obj-type and
                    prev-shift.obj-code = ub.shift-obj.obj-code and
                    prev-shift.status_ = {&sht-closed}
                    use-index pi no-error .
                if not available prev-shift or
                    prev-shift.shift-date < ub.shift-obj.shift-date or
                    prev-shift.shift-date = ub.shift-obj.shift-date and
                    prev-shift.shift-num < ub.shift-obj.shift-num then
                    /* OK */
                    .
                else 
                do:
                    message
                        "Найдена смена со статусом" {&sht-closed} skip
                        "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                        "Отменяемая закрытая смена должна быть последней" skip
                        "Невозможно отменить смену" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                ub.shift-obj.fact-order = 0.
        
                for each ub.shift-staff no-lock where ub.shift-staff.obj-type = ub.shift-obj.obj-type
                    and ub.shift-staff.obj-code = ub.shift-obj.obj-code
                    and ub.shift-staff.shift-num = ub.shift-obj.shift-num
                    and ub.shift-staff.shift-date = ub.shift-obj.shift-date
                    and ub.shift-staff.next-shift = no :
                    if ub.shift-staff.staff-role
                        then
                        assign
                            v-shift-manager = ub.shift-staff.name
                            .
                    else
                        assign
                            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
                            .                                  
                end.
        
                v-vid-action = 53 .
                v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + {&delim-par} +
                    "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + {&delim-par} +
                    "ShiftManager=" + v-shift-manager + {&delim-par} +
                    "ShiftStaff=" + v-shift-staff-list + {&delim-par} +
                    "RESULT=0" + {&delim-par} + 
                    "Description=".
            end.
            /*---END----------- Проверяем отмену закрытой смены ---------------------*/

            /*---START--------- Проверяем отмену открытой смены ---------------------*/
            if ub.shift-obj.status_ = {&sht-expected} and
                oldb.status_         = {&sht-current} then 
            do:
                /* ищем накладную или переоценку, закрытую в эту смену */
                find first ub.trn-doc where
                    ub.trn-doc.obj-type   = ub.shift-obj.obj-type   and
                    ub.trn-doc.obj-code   = ub.shift-obj.obj-code   and
                    ub.trn-doc.shift-date = ub.shift-obj.shift-date and
                    ub.trn-doc.shift-num  = ub.shift-obj.shift-num  and
                    ub.trn-doc.status_ = {&fact}
                    use-index stat-fact no-error.
                if available ub.trn-doc then 
                do:
                    message
                        "Найдена накладная, которая закрыта в течение смены" skip
                        "Невозможно отменить текущую смену" skip
                        "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        "Накладная" ub.trn-doc.doc-code
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                find first ub.price-doc where
                    ub.price-doc.obj-type   = ub.shift-obj.obj-type and
                    ub.price-doc.obj-code   = ub.shift-obj.obj-code and
                    ub.price-doc.shift-date = ub.shift-obj.shift-date and
                    ub.price-doc.shift-num  = ub.shift-obj.shift-num  and
                    ub.price-doc.status_    = {&act-overvalue}
                    use-index fact-close no-error.
                if available ub.price-doc then 
                do:
                    message
                        "Найдена переоценка, которая закрыта в течение смены" skip
                        "Невозможно отменить текущую смену" skip
                        "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        "Переоценка" ub.price-doc.doc-num
                        view-as alert-box error .
                    undo main-block, return error .
                end.

                /* проверяем, нет ли открытых сверок по объекту (они могут быть только по текущей смене)
                  закрытые сверки оставляем */
                find first buf_rvs-doc
                    where buf_rvs-doc.obj-type = ub.shift-obj.obj-type
                    and buf_rvs-doc.obj-code = ub.shift-obj.obj-code
                    and buf_rvs-doc.rvs-type <> {&test-asi}
                    and buf_rvs-doc.status_  <> {&fact}
                    no-error .
                if available buf_rvs-doc then 
                do:
                    message
                        "Найдена незакрытая сверка" skip
                        "Невозможно отменить текущую смену" skip
                        "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        "Сверка" buf_rvs-doc.rvs-code skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
        
                for each ub.shift-staff no-lock where ub.shift-staff.obj-type = ub.shift-obj.obj-type
                    and ub.shift-staff.obj-code = ub.shift-obj.obj-code
                    and ub.shift-staff.shift-num = ub.shift-obj.shift-num
                    and ub.shift-staff.shift-date = ub.shift-obj.shift-date
                    and ub.shift-staff.next-shift = no :
                    if ub.shift-staff.staff-role
                        then
                        assign
                            v-shift-manager = ub.shift-staff.name
                            .
                    else
                        assign
                            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
                            .                                  
                end.
        
                v-vid-action = 53 .
                v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + {&delim-par} +
                    "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + {&delim-par} +
                    "ShiftManager=" + v-shift-manager + {&delim-par} +
                    "ShiftStaff=" + v-shift-staff-list + {&delim-par} +
                    "RESULT=0" + {&delim-par} + 
                    "Description=".
            end.
        /*---END----------- Проверяем отмену открытой смены ---------------------*/
        end.        /* oldb.status_ <> ub.shift-obj.status_ */
    end.      /* not g#news */

    if not g#news then 
    do:
        run cur-time in this-procedure
            ( output v-today
            ,output v-time
            ).
        create buf_c-shift-obj.
        buffer-copy oldb except
            obj-type
            obj-code
            shift-date
            shift-num
            /*    shift-name*/
            to buf_c-shift-obj
            .
        assign
            buf_c-shift-obj.obj-type         = ub.shift-obj.obj-type
            buf_c-shift-obj.obj-code         = ub.shift-obj.obj-code
            buf_c-shift-obj.shift-date       = ub.shift-obj.shift-date
            buf_c-shift-obj.shift-num        = ub.shift-obj.shift-num
            buf_c-shift-obj.chip-num         = next-value (s-shift-chip, {&db-name_schema})
            buf_c-shift-obj.corr-time        = v-time
            buf_c-shift-obj.corr-user-db-num = g#db-num
            buf_c-shift-obj.corr-user-name   = g#userid
            buf_c-shift-obj.corr-date        = v-today
            .
        if new( ub.shift-obj ) then 
        do:
            assign
                buf_c-shift-obj.shift-name = ub.shift-obj.shift-name
                .
        end.
        create buf_c-sht-hist.
        buffer-copy buf_c-shift-obj to buf_c-sht-hist
            assign
            buf_c-sht-hist.action             = integer( if new( ub.shift-obj )
                                              then {&hn-create}
                                              else {&hn-update})

            buf_c-sht-hist.subject = {&table_shift-obj}
            buf_c-sht-hist.is-news = g#news
            .

        if ub.shift-obj.status_ <> "" then 
        do:
            run str/callnews.p
                (input {&table_shift-obj}
                ,input (buffer ub.shift-obj:handle)
                ) no-error .
            if error-status :error then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Невозможно маршрутизировать shift-obj для отправки в новости" skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                undo main-block, return error .
            end.
        end.

        if ub.shift-obj.status_ = {&sht-closed} then 
        do:
            /* Чек-лист */
            define buffer buf_user-account for ub.user-account .
            define variable user-id as character no-undo .
            define variable fio     as character no-undo .

            find first buf_user-account no-lock where buf_user-account.user-id = g#userid no-error .
            if available (buf_user-account) then 
            do:
                assign
                    user-id = buf_user-account.user-id
                    fio     = buf_user-account.last-name + " " + buf_user-account.first-name + " " + buf_user-account.second-name .
            end.

            define buffer buf_reportShift for ub.reportShift .
            define buffer buf_shift-attr  for ub.shift-obj-attr .

            find first buf_reportShift exclusive-lock where buf_reportShift.shift-date = ub.shift-obj.shift-date and
                buf_reportShift.shift-num = ub.shift-obj.shift-num and buf_reportShift.obj-code = ub.shift-obj.obj-code and
                buf_reportShift.obj-type = ub.shift-obj.obj-type and buf_reportShift.report-type = 0 no-error .
            if not available (buf_reportShift) then 
            do:

                find first buf_shift-attr exclusive-lock where buf_shift-attr.attr-code = "reportShift" and
                    buf_shift-attr.obj-code = ub.shift-obj.obj-code and
                    buf_shift-attr.obj-type = ub.shift-obj.obj-type and
                    buf_shift-attr.shift-date = 01/01/1970 and
                    buf_shift-attr.shift-num = 1 no-error .
                if available (buf_shift-attr) then 
                do:
                    buf_shift-attr.attr-value = string(integer(buf_shift-attr.attr-value) + 1) .
                end.
                else 
                do:
                    create buf_shift-attr .
                    assign
                        buf_shift-attr.attr-code  = "reportShift"
                        buf_shift-attr.obj-code   = ub.shift-obj.obj-code
                        buf_shift-attr.obj-type   = ub.shift-obj.obj-type
                        buf_shift-attr.shift-date = 01/01/1970
                        buf_shift-attr.shift-num  = 1 
                        buf_shift-attr.attr-value = string(next-value(s-reportShift, {&db-name_schema})).

                end.
                create buf_reportShift.
                assign
                    buf_reportShift.id          = integer(buf_shift-attr.attr-value)  
                    buf_reportShift.obj-code    = ub.shift-obj.obj-code
                    buf_reportShift.obj-type    = ub.shift-obj.obj-type
                    buf_reportShift.report-type = 0
                    buf_reportShift.shift-date  = ub.shift-obj.shift-date
                    buf_reportShift.shift-num   = ub.shift-obj.shift-num
                    .
            end. 
            assign
                buf_reportShift.date       = today
                buf_reportShift.user-id    = user-id
                buf_reportShift.fio        = fio
                buf_reportShift.time_      = time
                buf_reportShift.shift-name = ub.shift-obj.shift-name
                .
    
            find first ub.susp-chk no-lock where ub.susp-chk.obj-code = ub.shift-obj.obj-code and
                ub.susp-chk.obj-type = ub.shift-obj.obj-type and
                ub.susp-chk.shift-date = ub.shift-obj.shift-date and
                ub.susp-chk.shift-name = ub.shift-obj.shift-name and
                ub.susp-chk.shift-num = ub.shift-obj.shift-num no-error .
            if available (ub.susp-chk) then buf_reportShift.flag = true .        
        end.
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_shift-obj}
            , input ( buffer ub.shift-obj:handle )
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&edoc-proc_event_shift}
      " buffer oldb:handle "
      " buffer ub.shift-obj:handle "
      ''
      ''
      no-error
    }
    if error-status :error
        then
    do:
        return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
    
end.

/*писать в журнал действий пользователя*/
if g#news <> yes
    then 
do:
    run trg/userlog.p (
        input {&nwsdochs_action_update}
        , input {&table_c-sht-hist}
        , input ( buffer buf_c-sht-hist :handle )
        , input v-vid-action
        , input v-vid-param
        ) no-error.
    if error-status :error
        then 
    do:
        undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
/*            end.*/
end.