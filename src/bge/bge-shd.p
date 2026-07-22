block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: bge-shd.p $
$Archive: bge/bge-shd.p $

Экспорт по расписанию.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-cre-db-num as integer   no-undo .
define input parameter p-task-type  as character no-undo .
define input parameter p-task-num   as integer   no-undo .
define input parameter p-db-num     as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-shd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-shd.p $":U .
define variable vss-description as character no-undo init "Экспорт по расписанию.".
{ cmp/vssrevis.i    }
{ cmp/trg-def.i     }
{ adm/auto-def.i    }
{ ref/shd-attr.i    }
{ gbl/temphost.i    }
{ cmp/t-tnved.i new }
{ cmp/operlist.i    }
    
    define buffer lck_schedule-attr for ub.schedule-attr.
    define buffer buf_shift-obj for ub.shift-obj.

    define variable v-ind                       as integer      no-undo.
    define variable v-param-list                as character    no-undo.
    define variable v-temp-obj-list             as character    no-undo.
    define variable v-obj-counter               as integer      no-undo.
    define variable v-obj-list                  as character    no-undo.
    define variable v-obj-list-shift            as character    no-undo.
    define variable v-obj-list-noshift          as character    no-undo.
    define variable v-obj-list-type             as character    no-undo.
    define variable v-obj-list-code             as integer      no-undo.
    define variable v-doc-type-list             as character    no-undo.
    define variable v-spec-doc-type-list        as character    no-undo.
    define variable v-date-range                as character    no-undo.
    define variable v-param-type                as character    no-undo.
    define variable v-date-from                 as date         no-undo.
    define variable v-date-to                   as date         no-undo.
    define variable v-pay-code                  as logical      no-undo.
    define variable v-cst                       as logical      no-undo.
    define variable v-parts                     as logical      no-undo.
    define variable v-chk-pay-code              as logical      no-undo.
    define variable v-pay-desk                  as logical      no-undo.
    define variable v-opened-docs               as logical      no-undo.
    define variable v-exp-doc                   as logical      no-undo.
    define variable v-exp-ref                   as logical      no-undo.
    define variable v-exp-day                   as logical      no-undo.
    define variable v-exp-way                   as logical      no-undo.
    define variable v-exp-ref-ext               as logical      no-undo.
    define variable v-exp-stk                   as logical      no-undo.
    define variable v-exp-stk-supp              as logical      no-undo.
    define variable v-incr                      as logical      no-undo.
    define variable v-exp-checks                as logical      no-undo.
    define variable v-exp-doc-rvs               as logical      no-undo.
    define variable v-exp-fo                    as logical      no-undo.
    define variable v-exp-fp                    as logical      no-undo.
    define variable v-exp-s-f                   as logical      no-undo.
    /*define variable v-gds-grp-list              as character    no-undo.*/

    define variable v-range                     as integer      no-undo.
    define variable v-initial-range             as integer      no-undo.
    define variable v-host-code                 as integer      no-undo.

    define variable v-par-value         as character    no-undo.
    define variable v-par-type          as character    no-undo.
    define variable v-shift-mode-on     as logical      no-undo.
    define variable v-bgeflold          as character    no-undo.

    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle     no-undo .

do
on error undo, return error
:
    run adm/lockshda.p ( input p-cre-db-num
                       , input p-task-type
                       , input p-task-num
                       , input {&attr-schedule-param-list-h}
                       , buffer lck_schedule-attr
                       ) no-error .
    if error-status :error = yes
    then do:
      run write-to-log( vss-workfile + {&space-char}
                      + "Другая сессия уже работает с этим расписанием..." + {&new-line}
                      + error-status:get-message(error-status:num-messages)
                      + return-value
                      ) .
      return . /* --->>>--- */
    end.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgeshift}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
          v-shift-mode-on = no
      .
    end.
    else do:
      assign
          v-shift-mode-on = ( v-value-character = "distinct":U )
      .
    end.
    delete object v-tth.

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgeflold}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgeflold  = "old":U
      .
    end.
    else do:
      assign
        v-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.

    run gbl/set-gbl.p (
          input true
        , input g#auto-user-id
        , input g#auto-user-password
    ) no-error .
    if error-status :error
    then do:
        run write-to-log( vss-workfile + {&space-char}
                        + "Ошибка при инициализации переменных g#..." + {&new-line}
                        + error-status:get-message(error-status:num-messages)
                        + return-value
                        ) .
        return error.
    end.

    do : /* Список параметров должен быть для всех типов выгрузки. */
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , output v-param-list
        , output v-param-type
    ).
    assign
        v-range = integer( entry( 1,  v-param-list ) )
    .
    if v-range = 2
    then do:
        if num-entries( v-param-list ) > 14
        then do:
            assign
                v-host-code = integer( entry( 15,  v-param-list ) )
            .
        end.
        else do:
            assign
                v-host-code = -1
            .
            run write-to-log in this-procedure (
                input vss-workfile + {&space-char} + " Не удалось определить код фирмы для выгрузки по объектам."
            ).
        end.
    end.
    run schedule-attr-extract-logical in this-procedure (
          input 2
        , input v-param-list
        , output v-pay-code
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 3
        , input v-param-list
        , output v-cst
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 4
        , input v-param-list
        , output v-opened-docs
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 6
        , input v-param-list
        , output v-parts
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 7
        , input v-param-list
        , output v-chk-pay-code
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 8
        , input v-param-list
        , output v-exp-doc
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 9
        , input v-param-list
        , output v-exp-ref
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 10
        , input v-param-list
        , output v-exp-day
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 11
        , input v-param-list
        , output v-exp-way
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 12
        , input v-param-list
        , output v-exp-ref-ext
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 13
        , input v-param-list
        , output v-exp-stk
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 14
        , input v-param-list
        , output v-exp-stk-supp
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 16
        , input v-param-list
        , output v-pay-desk
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 17
        , input v-param-list
        , output v-incr
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 18
        , input v-param-list
        , output v-exp-checks
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 19
        , input v-param-list
        , output v-exp-fo
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 20
        , input v-param-list
        , output v-exp-fp
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 22
        , input v-param-list
        , output v-exp-s-f
    ).
        
    run schedule-attr-extract-logical in this-procedure (
          input 23
        , input v-param-list
        , output v-exp-doc-rvs
    ).
    
    end .

    if v-incr = no
    then do:
        if v-exp-doc = yes
        or v-exp-fp = yes
        then do:        /* Список документов формируется только для выгрузки по документам и платежам */
            run schedule-attr-value in this-procedure (
                input p-cre-db-num
                , input p-task-type
                , input p-task-num
                , input {&attr-schedule-doc-type-list-h}
                , output v-doc-type-list
                , output v-param-type
            ).
        end.
        if v-exp-doc = yes
        or v-exp-stk = yes
        or v-exp-day = yes
        or v-exp-fo  = yes
        or v-exp-fp  = yes
        or v-exp-s-f = yes
        then do:        /* Интервал дат должен быть задан только для выгрузки документов, товарных остатков и товаров по дням ФО и ФП */
            run schedule-attr-value in  this-procedure (
                input p-cre-db-num
                , input p-task-type
                , input p-task-num
                , input {&attr-schedule-date-list-h}
                , output v-date-range
                , output v-param-type
            ).
            run analyze-date-range in this-procedure (
                  input v-date-range
                , output v-date-from
                , output v-date-to
            ) no-error.
            if error-status :error
            or v-date-from  = ?
            or v-date-to    = ?
            then do:
                run write-to-log( vss-workfile + {&space-char}
                                + substitute( " Ошибка выгрузки по расписанию. Не удалось определить интервал дат для выгрузки." + {&new-line} + "&1" + {&new-line} + "&2" + {&new-line} + "&3"
                                                , return-value
                                                , error-status :get-message( 0 )
                                                , error-status :get-message( 1 )
                                            )
                                ) .
                undo, return error .
            end.
        end.        /* if v-exp-doc = yes or ... */
    end.        /* if v-incr = no */
    if v-exp-doc = yes
    or v-exp-day = yes
    or v-exp-way = yes
    or v-exp-stk = yes
    or v-exp-fo  = yes
    or v-exp-fp  = yes
    or v-exp-s-f = yes
    then do:        /* Для выгрузки документов и товаров по дням - сформировать список объектов */
        assign
            v-initial-range = v-range
        .
        run fill-obj-list in this-procedure (
              input v-initial-range
            , input v-host-code
            , output v-range
            , output v-obj-list
        ).
        if v-obj-list = ""
        or v-range <> 3
        then do:
            run write-to-log( vss-workfile + {&space-char}
                            + substitute( " Нет объектов для выгрузки или неверно задан тип выгрузки."
                                            + {&new-line} + "    Номер базы данных:                   &1"
                                            + {&new-line} + "    Задан список объектов:               &2"
                                            + {&new-line} + "    Тип выгрузки (допускается только 3): &3"
                                            , p-db-num
                                            , v-obj-list
                                            , v-range
                                        )
                            ) .
            undo, return error .
        end.
    end.        /* if v-exp-doc = yes or ... */
    if v-incr = no
    then do:
        run write-to-log ( vss-workfile + {&space-char} + " Выгрузка по расписанию. Флаг инкрементальной выгрузки выключен." ) .
        if v-exp-doc = yes
        then do:
            if v-shift-mode-on = yes
            then do:
                run bge/shd-doch.p (
                      input p-db-num
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input cross-list(v-doc-type-list, {&TDEDT_List}, {&comma-char})    /*  p-doc-type-list */
                    , input v-pay-code        /*  p-pay-code      */
                    , input v-cst             /*  p-cst           */
                    , input v-parts           /*  p-parts         */
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input no                /* pay-desk-cards   */
                    , input v-opened-docs     /*  p-opened-docs   */
                    , input v-exp-doc-rvs
                    , input ?
                    , input ?
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + {&space-char}
                                    + substitute( " Ошибка выгрузки документов по расписанию. &1 "
                                                    , return-value
                                                )
                                    ) .
                end.
            end.        /* if v-shift-mode-on = yes */
            else do:
                if v-bgeflold = "firm":U
                then do:
                    run bge/shd-docf.p (
                          input p-db-num
                        , input v-date-from
                        , input v-date-to
                        , input v-range
                        , input v-obj-list
                        , input cross-list(v-doc-type-list, {&TDEDT_List}, {&comma-char})    /*  p-doc-type-list */
                        , input v-pay-code        /*  p-pay-code      */
                        , input v-cst             /*  p-cst           */
                        , input v-parts           /*  p-parts         */
                        , input v-chk-pay-code
                        , input v-pay-desk
                        , input no                /* pay-desk-cards   */
                        , input v-opened-docs     /*  p-opened-docs   */
                        , input v-exp-doc-rvs
                        , input ?
                        , input ?
                    ) no-error.
                    if error-status :error
                    then do:
                        run write-to-log( vss-workfile + {&space-char}
                                        + substitute( " Ошибка выгрузки документов фирм по расписанию. &1 "
                                                        , return-value
                                                    )
                                        ) .
                    end.
                end.        /* if v-bgelib-bgeflold = "firm":U */
                else do:
                    run bge/shd-docs.p (
                          input p-db-num
                        , input v-date-from
                        , input v-date-to
                        , input v-range
                        , input v-obj-list
                        , input cross-list(v-doc-type-list, {&TDEDT_List}, {&comma-char})    /*  p-doc-type-list */
                        , input v-pay-code        /*  p-pay-code      */
                        , input v-cst             /*  p-cst           */
                        , input v-parts           /*  p-parts         */
                        , input v-chk-pay-code
                        , input v-pay-desk
                        , input no                /* pay-desk-cards   */
                        , input v-opened-docs     /*  p-opened-docs   */
                        , input v-exp-doc-rvs
                        , input ?
                        , input ?
                    ) no-error.
                    if error-status :error
                    then do:
                        run write-to-log( vss-workfile + {&space-char}
                                        + substitute( " Ошибка выгрузки документов по расписанию. &1 "
                                                        , return-value
                                                    )
                                        ) .
                    end.
                end.        /* NOT ( if v-bgelib-bgeflold = "firm":U ) */
            end.        /* NOT ( if v-shift-mode-on = yes ) */
        end.
        if v-exp-ref = yes
        then do:
            if v-exp-ref-ext = yes
            then do:
                run bge/bge-ref.p (
                      input ?
                    , input "good-ext"
                    , input yes
                    , input v-host-code
                    , input ?
                    , input ?
                ) no-error.
            end.
            else do:
                run bge/bge-ref.p (
                      input ?
                    , input ""
                    , input yes
                    , input v-host-code
                    , input ?
                    , input ?
                ) no-error.
            end.
            if error-status :error
            then do:
                run write-to-log( vss-workfile + {&space-char}
                                + substitute( " Ошибка выгрузки справочников по расписанию. &1 "
                                                , return-value
                                            )
                                ) .
            end.
        end.        /* if v-exp-ref = yes  */
        if v-exp-day = yes
        then do:
            run bge/bge-day.p (
                  input ?
                , input v-date-from
                , input v-date-to
                , input v-range
                , input v-obj-list
                , input 0
                , input yes
                , input ?
                , input ?
            ) no-error.
            if error-status :error
            then do:
                run write-to-log( vss-workfile + {&space-char}
                                + substitute( " Ошибка выгрузки товаров по дням по расписанию. &1 "
                                                , return-value
                                            )
                                ) .
            end.
        end.        /* if v-exp-day = yes  */
        if v-exp-way = yes
        then do:
            run bge/bge-way.p (
                input -1
                , input yes
                , input p-db-num
                , input v-obj-list
                , input ?
                , input ?
            ) no-error.
            if error-status :error
            then do:
                run write-to-log( vss-workfile + {&space-char}
                                + substitute( " Ошибка выгрузки товаров в пути по расписанию. &1 "
                                                , return-value
                                            )
                                ) .
            end.
        end.        /* if v-exp-way = yes  */      
        if v-exp-stk = yes and entry(1,v-date-range) = '1' then do:         
                    run bge/bgestd.p (
                          input ?
                        , input -1
                        , input 3
                        , input v-obj-list
                        , input v-date-to
                        , input v-cst
                        , input yes
                        , input yes
                        , input 0
                        /*, input v-gds-grp-list*/
                        , input ?
                        , input ?
                    ).
        end.
        else if v-exp-stk = yes  then  do: 
           if v-exp-stk-supp = yes
            then do:
                run bge/bge-stk.p (
                      input ?
                    , input -1
                    , input v-date-from
                    , input v-date-to
                    , input yes
                    , input yes
                    , input p-db-num
                    , input v-obj-list
                    /*, input v-gds-grp-list*/
                    , input ?
                    , input ?
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + {&space-char}
                                    + substitute( " Ошибка выгрузки остатков товаров по поставщикам по расписанию. &1 "
                                                    , return-value
                                                )
                                    ) .
                end.
            end.        /* if v-exp-stk-supp = yes */
            else do:
                run bge/bge-stk.p (
                      input ?
                    , input -1
                    , input v-date-from
                    , input v-date-to
                    , input no
                    , input yes
                    , input p-db-num
                    , input v-obj-list
                    /*, input v-gds-grp-list*/
                    , input ?
                    , input ?
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + {&space-char}
                                    + substitute( " Ошибка выгрузки остатков товаров по расписанию. &1 "
                                                    , return-value
                                                )
                                    ) .
                end.
            end.        /* NOT ( if v-exp-stk-supp = yes ) */
        end.        /* if v-exp-stk = yes  */
        if v-exp-fo = yes then do:  /* sv */
            run bge/bgefo.p (
                  input v-date-from
                , input v-date-to
                , input v-range
                , input v-obj-list
                , input ?
                , input ?
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + {&space-char}
                                    + substitute( " Ошибка выгрузки ФО по расписанию. &1 &2 "
                                                    , return-value, error-status :get-message(1)
                                                )
                                    ) .
                end.

        end.
        if v-exp-fp = yes then do:
           /* nvb */
            run bge/bgefdoc.p (
                  input v-date-from
                , input v-date-to
                , input v-initial-range
                , input "shd":U
                , input (if v-initial-range = 2 then v-host-code else 0)
                , input v-obj-list
                , input p-db-num
                , input cross-list(v-doc-type-list, {&fin-ext-doc-types}, {&comma-char})
                , input ?
                , input ?
            ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + {&space-char}
                                    + substitute( " Ошибка выгрузки платежных документов по расписанию. &1 &2 "
                                                    , return-value, error-status :get-message(1)
                                                )
                                    ) .
                end.
        end.
        if v-exp-s-f = yes then do:  /* mk */
/*            run bge/bge-sf.p (*/
/*                  input parparentproc*/
/*                , input v-date-from*/
/*                , input v-date-to*/
/*                , input v-range*/
/*                , input v-obj-list*/
/*                , input ?*/
/*                , input ?*/
/*                ) no-error.*/
/*                if error-status :error*/
/*                then do:*/
/*                    run write-to-log( vss-workfile + {&space-char}*/
/*                                    + substitute( " Ошибка выгрузки счетов-фактур по расписанию. &1 &2 "*/
/*                                                    , return-value, error-status :get-message(1)*/
/*                                                )*/
/*                                    ) .*/
/*                end.*/
        end.

    end.        /* if v-incr = no  */
    else do:
        run write-to-log ( vss-workfile + {&space-char} + " Выгрузка по расписанию. Флаг инкрементальной выгрузки включен. " ) .
        if v-exp-doc = yes
        then do:
            if v-shift-mode-on = yes
            then do:
                /* В списке могут быть как сменные так и не сменные объекты,
                разделим их на два списка и запустим обе выгрузки */
                
                v-obj-list-shift = "".
                v-obj-list-noshift = "".
                
                do v-obj-counter = 1 to num-entries (v-obj-list) / 2:
                    
                    assign
                    v-obj-list-type = entry(v-obj-counter * 2 - 1, v-obj-list)
                    v-obj-list-code = integer(entry(v-obj-counter * 2, v-obj-list)) no-error.
                    
                    
                    if not can-find(first buf_shift-obj
                        where buf_shift-obj.obj-type = v-obj-list-type
                          and buf_shift-obj.obj-code = v-obj-list-code)
                        then do:
                            assign
                            v-obj-list-noshift = v-obj-list-noshift + v-obj-list-type + ',' + string(v-obj-list-code) + ','.
                    end. /* if not can-find */
                    else do:
                        assign
                        v-obj-list-shift = v-obj-list-shift + v-obj-list-type + ',' + string(v-obj-list-code) + ','.
                    end.
                end.
                                
                /* Запустим по сменным */
                if v-obj-list-shift <> "" then do:
                run bge/shd-inch.p (
                      input p-db-num
                    , input v-range
                        , input v-obj-list-shift
                        , input v-exp-checks
                        , input v-exp-doc-rvs
                    ) no-error.
                    if error-status :error
                    then do:
                        run write-to-log ( vss-workfile + {&space-char}
                                        + substitute( " Ошибка выгрузки по расписанию. &1 "
                                                        , return-value
                                                    )
                                        ) .
                        undo, return error .
                    end.
                end. /* if v-obj-list-shift <> "" */
                
                /* Запустим по несменным */
                if v-obj-list-noshift <> "" then do:
                    run bge/shd-incr.p (
                          input p-db-num
                        , input v-range
                        , input v-obj-list-noshift
                        , input v-exp-checks
                        , input v-exp-doc-rvs
                    ) no-error.
                    if error-status :error
                    then do:
                        run write-to-log ( vss-workfile + {&space-char}
                                        + substitute( " Ошибка выгрузки по расписанию. &1 "
                                                        , return-value
                                                    )
                                        ) .
                        undo, return error .
                    end.
                end. /* if v-obj-list-noshift <> "" */
            end.        /* if v-shift-mode-on = yes */
            else do:
                run bge/shd-incr.p (
                      input p-db-num
                    , input v-range
                    , input v-obj-list
                    , input v-exp-checks
                    , input v-exp-doc-rvs
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log ( vss-workfile + {&space-char}
                                    + substitute( " Ошибка выгрузки по расписанию. &1 "
                                                    , return-value
                                                )
                                    ) .
                    undo, return error .
                end.
            end.        /* NOT ( if v-shift-mode-on = yes ) */
        end.        /* if v-exp-doc = yes  */
        if v-exp-ref = yes
        then do:
            run bge/bge-ref.p (
                  input ?
                , input "good-ext"
                , input yes
                , input v-host-code
                , input ?
                , input ?
            ) no-error.
        end.        /* if v-exp-ref = yes */
        if v-exp-fp = yes
        then do:
            run bge/shfdincr.p (
                  input p-db-num
                , input v-initial-range
                , input (if v-initial-range = 2 then v-host-code else 0)
                , input v-obj-list
            ) no-error.
            if error-status :error
            then do:
                run write-to-log ( vss-workfile + {&space-char}
                                + substitute( " Ошибка выгрузки по расписанию. &1 "
                                                , return-value
                                            )
                                ) .
                undo, return error .
            end.
        end.        /* if v-exp-fd = yes  */
        if v-exp-fo = yes
        then do:
            run bge/shfoincr.p (
                  input p-db-num
                , input v-range
                , input v-obj-list
            ) no-error.
            if error-status :error
            then do:
                run write-to-log ( vss-workfile + {&space-char}
                                + substitute( " Ошибка выгрузки по расписанию ФО. &1 "
                                                , return-value
                                            )
                                ) .
                undo, return error .
            end.
        end.        /* if v-exp-fo = yes  */
    end.        /* NOT ( if v-incr = no  ) */
end.

/*==========================================================================*/
procedure analyze-date-range :
do
on error undo, return error
:
define input parameter p-date-range         as character    no-undo.
define output parameter p-date-from         as date         no-undo.
define output parameter p-date-to           as date         no-undo.

    define variable v-today         as date      no-undo.
    define variable v-time          as integer   no-undo.
    define variable v-days-ago      as integer       no-undo.
    define variable v-days-amount   as integer       no-undo.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).

    case entry( 1, p-date-range )
    :
        when "0":U
        then do:
            assign
                v-days-ago    = integer( entry( 3, p-date-range ) )
                v-days-amount = integer( entry( 2, p-date-range ) )
            .
            assign
                p-date-from = v-today - v-days-ago
                p-date-to   = v-today - v-days-ago + v-days-amount
            .
            if p-date-to > v-today
            then do:
                assign
                  p-date-to = v-today
                .
            end.
        end.
        when "1":U
        then do:
            assign
                p-date-from = date( entry( 4, p-date-range ) )
                p-date-to   = v-today
            .
        end.
        when "2":U
        then do:
            assign
                p-date-from = date( entry( 4, p-date-range ) )
                p-date-to   = date( entry( 5, p-date-range ) )
            .
        end.
        otherwise do:
            assign
                p-date-from = ?
                p-date-to   = ?
            .
        end.
    end case.
end.
end procedure. /* analyze-date-range */


/*==========================================================================*/
procedure fill-obj-list :
define input parameter p-range-in   as integer          no-undo.
define input parameter p-host-code  as integer          no-undo.
define output parameter p-range-out as integer          no-undo.
define output parameter p-obj-list  as character        no-undo.

    define variable v-obj-counter               as integer      no-undo.

    define buffer buf_clients   for ub.clients.
do
for buf_clients
on error undo, return error
:
    if p-range-in = 2
    and v-host-code = -1
    then do:        /* Выбрана выгрузка по фирме, но код фирмы получить не удалось */
        assign
            p-range-in = 1
        .
    end.
    assign
        p-range-out = p-range-in
    .
    run init-temphost.
    case p-range-in
    :
        when 1
        then do:        /* Выгружаются все объекты списка БД */
            for each temp-obj
            :
                if temp-obj.db-num = p-db-num
                then do:
                    assign
                        p-obj-list = p-obj-list
                                        + ( if p-obj-list = "" then "" else "," )
                                        + temp-obj.obj-type
                                        + "," + string( temp-obj.obj-code )
                    .
                end.
            end.
            assign
                p-range-out  = 3
            .
        end.        /* when 1 */
        when 2
        then do:
            for each temp-obj
            :
                if temp-obj.db-num = p-db-num
                and temp-obj.host-code = v-host-code
                then do:
                    assign
                        p-obj-list = p-obj-list
                                        + ( if p-obj-list = "" then "" else "," )
                                        + temp-obj.obj-type
                                        + "," + string( temp-obj.obj-code )
                    .
                end.
            end.
            assign
                p-range-out  = 3
            .
        end.        /* when 2 */
        when 3      /* Выбрать только те объекты, которые принадлежат списку БД. */
        then do:
            run schedule-attr-value in this-procedure (
                  input p-cre-db-num
                , input p-task-type
                , input p-task-num
                , input {&attr-schedule-obj-list-h}
                , output v-temp-obj-list
                , output v-param-type
            ).
            do v-obj-counter = 1 to num-entries ( v-temp-obj-list ) / 2
            :
                find first buf_clients no-lock
                        where buf_clients.obj-type  = entry( v-obj-counter * 2 - 1, v-temp-obj-list )
                        and buf_clients.obj-code = integer( entry( v-obj-counter * 2, v-temp-obj-list ) )
                no-error.
                if not available buf_clients
                then do:
                    run write-to-log( vss-workfile + {&space-char}
                                    + substitute( " Ошибка выгрузки по расписанию: Не найден заданный объект &1 &2" + {&new-line}
                                                    , buf_clients.obj-type
                                                    , buf_clients.obj-code
                                                )
                                    ) .
                    undo, return error .
                end.
                else do:
                    if buf_clients.db-num = p-db-num
                    then do:
                        assign
                            p-obj-list = p-obj-list
                                            + ( if p-obj-list = "" then "" else "," )
                                            + buf_clients.obj-type
                                            + "," + string( buf_clients.obj-code )
                        .
                    end.
                end.
            end.
        end.        /* when 3 */
    end case.
end.
end procedure. /* fill-obj-list */
