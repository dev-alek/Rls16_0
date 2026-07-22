block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на запись Заказа

Автор: Чернова Светлана Александровна
Дата создания: 04/10/02
Author: Svetlana Chernova
Creation date: 04/10/02

*/

TRIGGER PROCEDURE FOR WRITE OF ub.ORD-doc OLD BUFFER old_ord-doc.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись заказа".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ cus/ord-savl.i }

define variable num_rec                as integer   no-undo .
define variable num_gds                as integer   no-undo .
define variable start-time             as integer   no-undo .
define variable current-time           as character no-undo .
define variable current-action         as character no-undo .
define variable v-description-ord-type as character no-undo .
define variable v-today                as date      no-undo.
define variable v-time                 as integer   no-undo.

define buffer bf_contract-specif for ub.contract-specif  .
define buffer buf_goods          for ub.goods  .
define variable v-curr-abbr as character no-undo .
&glob order-type-gbd 2
&glob order-type-ubd 3

FUNCTION is-edi-send-nws RETURN logical (  input p-cli-type as character
    , input p-cli-code as integer
    , input p-obj-type     as character
    , input p-obj-code     as integer
    ) .

    define variable v-obj-db-num       as integer   no-undo .
    define variable v-uniq-key-rec     as character no-undo .
    define variable v-obj-uniq-key-rec as character no-undo .
    define variable v-is-edi           as logical   no-undo .
    define variable par-is-edi         as character no-undo .
    define variable par-type           as character no-undo .

    define buffer buf_clients      for ub.clients .
    define buffer obj_clients      for ub.clients .
    define buffer buf_ext-classif  for ub.ext-classif .
    define buffer buf2_ext-classif for ub.ext-classif .
    define buffer buf_ext-system   for ub.ext-system  .

    { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
    if v-obj-db-num = 0 then 
    do:
        return no.
    end.

    { gbl/conf-rd.i "'is-edi'"   "''" "''" 0 "''" "''" "''"  no par-is-edi     par-type      no-error}

    v-is-edi = lookup(par-is-edi, "true,yes":U) > 0.

    if not v-is-edi then 
    do:
        return no.
    end.

    find first buf_clients no-lock
        where buf_clients.obj-type = p-cli-type
        and buf_clients.obj-code = p-cli-code
        no-error .
    if not available buf_clients then 
    do:
        return no .
    end.
    find first obj_clients no-lock where
        obj_clients.obj-type = p-obj-type
        and obj_clients.obj-code = p-obj-code no-error.
    if not available buf_clients then 
    do:
        return no .
    end.
    run gen-key-rec IN THIS-PROCEDURE ( input {&table_clients}
        , input (buffer buf_clients:handle)
        , output v-uniq-key-rec).
    run gen-key-rec IN THIS-PROCEDURE ( input {&table_clients}
        , input (buffer obj_clients:handle)
        , output v-obj-uniq-key-rec).

    for each buf_ext-classif no-lock
        where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name    = {&extclass_clients_exite-edi},
        first buf_ext-system no-lock
        where buf_ext-system.esys-id = buf_ext-classif.key#_one
        and buf_ext-system.db-num  = 0
        and buf_ext-system.esys-have-export = yes
        and buf_ext-system.esys-db-num-exp = 0
        ,
        first buf2_ext-classif no-lock
        where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
        and buf2_ext-classif.classif-subject = {&table_clients}
        and buf2_ext-classif.classif-name    = {&extclass_clients_exite-edi}
        and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
        leave.
    end. /*if available buf_ext-classif then do :*/
    if available buf_ext-classif then 
    do :
        return yes .
    end. /*if available buf_ext-classif then do :*/
    return no .
END FUNCTION.

assign
    v-description-ord-type = ub.ord-doc.doc-type
    .

/* для показа процесса закрытия документа */

define frame a
    ub.ord-doc.doc-code                        label "Заказ" skip
    v-description-ord-type                     label "Тип документа" skip
    current-action         format "x(40)"      no-label skip
    num_rec                format ">>>>>>>9"   label "Обработано артикулов" skip
    ub.ord-line.artic                          label "Текущий артикул" skip
    num_gds                format ">>>>>>>9"   label "Обработано признаков" skip
    current-time           format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Обработка заказа"
    .


main-block :
do transaction
    on error undo main-block, return error
    :
    define variable kol-str as integer no-undo .
    kol-str = 0.

    /* обновляем пользователя, дату и время последнего обновления */
    if not g#news
        then 
    do:


        /* Проверка по договору */
        if ub.ord-doc.contract-code > 0  and
            not ( ub.ord-doc.status_ = {&fact} or
            ub.ord-doc.status_ = {&ord-rejection})

            then 
        do:
            find first bf_contract-specif where bf_contract-specif.host-code    = ub.ord-doc.host-code     and
                bf_contract-specif.contract-num = ub.ord-doc.contract-code no-lock no-error.
            if available bf_contract-specif then 
            do: /* спецификация есть */
                for each ub.ord-line no-lock where
                    ub.ord-line.doc-code = ub.ord-doc.doc-code :
                    if not can-find (first bf_contract-specif no-lock where
                        bf_contract-specif.host-code    = ub.ord-doc.host-code and
                        bf_contract-specif.contract-num = ub.ord-doc.contract-code and
                        bf_contract-specif.gds-code     = ub.ord-line.gds-code   ) then 
                    do:
                        message
                            "Выбран Договор со спецификацией !!!" skip
                            "Несоответствие списка товаров заказа и спецификации " skip
                            "Заказ      :" ub.ord-doc.doc-code        skip
                            "код товара :" ub.ord-line.gds-code skip
                            "артикл     :" ub.ord-line.artic skip
                            view-as alert-box error .
                    end.
                end.
            end.
        end.
        { gbl/curdburt.i
      ub.ord-doc.user-db-num
      ub.ord-doc.user-name
      ub.ord-doc.sys-date
      ub.ord-doc.sys-time
      ub.ord-doc.sys-time-int
    }

        if ub.ord-doc.status_ = {&g___new} then 
        do:
            if ub.ord-doc.exch-rate = 0 or ub.ord-doc.exch-scale = 0  then 
            do:
                if ub.ord-doc.exch-code = ? then  ub.ord-doc.exch-code = 0 .
                { gbl/exchrate.i
       ub.ord-doc.exch-code
       ub.ord-doc.doc-date
       ub.ord-doc.exch-rate
       ub.ord-doc.exch-scale
       v-curr-abbr }

            end.
            if ub.ord-doc.base-rate = 0 or ub.ord-doc.base-scale = 0  then 
            do:
                { gbl/baserate.i
          ub.ord-doc.host-code
          ub.ord-doc.doc-date
          ub.ord-doc.base-rate
          ub.ord-doc.base-scale
          no-error }
            end.

            for each ub.ord-line exclusive-lock
                where ub.ord-line.doc-code = ub.ord-doc.doc-code :
                find first buf_goods no-lock where
                    buf_goods.artic = ub.ord-line.artic and
                    buf_goods.prod-type = ub.ord-line.prod-type  and
                    buf_goods.prod-code = ub.ord-line.prod-code no-error .
                if available buf_goods then
                    assign
                        ub.ord-line.gds-code = buf_goods.gds-code
                        .

                kol-str = kol-str + 1.
            end.
            ub.ord-doc.tot-lines = kol-str .
            run sum-head .
        end.

        if new(ub.ord-doc)  then
            assign
                ub.ord-doc.real-date-create = today
                ub.ord-doc.real-time-create = time
                ub.ord-doc.creid            = g#userid
                ub.ord-doc.fact-num         = next-value (s-ORD-fact, {&db-name_schema})
                .
    end.

    /* определяем пользователя */
    if ub.ord-doc.status_ = {&ord-accept} then 
    do:
        assign
            ub.ord-doc.creid = g#userid
            .
    end.
    /* раньше хдесь при переходе на статус ПОСТАВКА вызывался EDI */

    /* Прием новостей */
    if ub.ord-doc.doc-type = {&o-r}
        and ub.ord-doc.status_ <> {&g___new}
        and g#db-num = 0
        and g#news
        then 
    do:
        /* message "Прием новостей заказа g#news=" g#news
                 "old" old_ord-doc.status_  skip
                 "new" ub.ord-doc.status_  skip
                  ub.ord-doc.cli-code ub.ord-doc.obj-code skip
                 'g#db-num ' g#db-num.*/

        run str/callnews.p
            (input {&table_ord-doc}
            ,input (buffer ub.ord-doc:handle)
            ) no-error .
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Невозможно маршрутизировать ord-doc для отправки в новости" skip
                "Заказ О-РЦ " ub.ord-doc.doc-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return error .
        end.
    end.

    define variable l-date as date      no-undo .
    define variable l-time as integer   no-undo .
    define variable s-date as date      no-undo . /* дата начала смены для документа */
    define variable s-num  as integer   no-undo . /* порядок смены для документа */
    define variable s-name as character no-undo . /* номер смены для документа */


    if ub.ord-doc.status_ = {&fact} then 
    do:
        /* определяем фактический номер документа */
        if not g#news then 
        do:
            /* фактическое время закрытия */
            run cur-time in this-procedure (output l-date , output l-time) no-error .

            ub.ord-doc.fact-time  = l-time .
            run gbl/factdate.p ( input        ub.ord-doc.obj-type  ,
                input        ub.ord-doc.obj-code   ,
                input-output ub.ord-doc.fact-date ,
                input-output ub.ord-doc.fact-time ,
                input-output s-date  ,
                input-output s-num ,
                input-output s-name,
                input        yes     ).
            assign
                ub.ord-doc.shift-date = s-date
                ub.ord-doc.shift-num  = s-num
                ub.ord-doc.shift-name = s-name.
            if ub.ord-doc.fact-num =  0 or ub.ord-doc.fact-num = ?  then 
            do:
                /* определяем порядковый номер */
                assign
                    ub.ord-doc.fact-num = next-value (s-ORD-fact, {&db-name_schema})
                    .
            end.

            /* определяем fact-order */
            if ub.ord-doc.fact-order =  0 or ub.ord-doc.fact-order = ?  then 
            do:
                define variable v-fact-order           as decimal no-undo .
                define variable v-shift-end-fact-order as decimal no-undo .
                define variable v-day-end-fact-order   as decimal no-undo .
                define variable l-shift-on             as logical no-undo .
                { gbl/objat.i
        ub.ord-doc.obj-type
        ub.ord-doc.obj-code
        "'shift-on=request'"
        l-shift-on
        no-error
      }
                if error-status :error then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при определении атрибута объекта" skip
                        "Заказ" ub.ord-doc.doc-code skip
                        "Объект" ub.ord-doc.obj-type ub.ord-doc.obj-code skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.

                run factord in this-procedure
                    (input  ub.ord-doc.fact-date   /* p-fact-date            */
                    ,input  ub.ord-doc.fact-time   /* p-fact-time            */
                    ,input  ub.ord-doc.fact-num    /* p-fact-num             */
                    ,input  ub.ord-doc.shift-date  /* p-shift-date           */
                    ,input  ub.ord-doc.shift-num   /* p-shift-num            */
                    ,input  l-shift-on             /* p-shift-on             */
                    ,output v-fact-order           /* p-fact-order           */
                    ,output v-shift-end-fact-order /* p-shift-end-fact-order */
                    ,output v-day-end-fact-order   /* p-day-end-fact-order   */
                    ) no-error .
                if error-status :error
                    or v-fact-order = ?
                    or v-fact-order = 0 then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при определении фактического номера складского документа" skip
                        "Заказ" ub.ord-doc.doc-code skip
                        "fact-date"               ub.ord-doc.fact-date   skip
                        "fact-time"               ub.ord-doc.fact-time   skip
                        "fact-num"                ub.ord-doc.fact-num    skip
                        "shift-date"              ub.ord-doc.shift-date  skip
                        "shift-num"               ub.ord-doc.shift-num   skip
                        "v-fact-order"            v-fact-order           skip
                        "v-shift-end-fact-order"  v-shift-end-fact-order skip
                        "v-day-end-fact-order"    v-day-end-fact-order   skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo, return error .
                end.

                assign
                    ub.ord-doc.fact-order = v-fact-order
                    .
            end.
        end.
    end.



    run cur-time in this-procedure ( output v-today
        , output start-time
        ).
    assign
        current-action = "Проверка статуса."
        .

    view frame a.
    display
        ub.ord-doc.doc-code
        v-description-ord-type
        with frame a.

    /* история */
    if g#news  = false then 
    do:
        if  not (ub.ord-doc.status_ = {&g___new} and ub.ord-doc.flag_ = false and old_ord-doc.obj-code <> 0 ) or
            ( old_ord-doc.user-name <> g#userid )
            then 
        do:
            create ub.c-ord-doc.
            BUFFER-COPY old_ord-doc  TO ub.c-ord-doc
                assign
                ub.c-ord-doc.chip-num           = next-value (s-corr-chip, {&db-name_schema})
                ub.c-ord-doc.corr-time          = start-time
                ub.c-ord-doc.corr-user-db-num   = g#db-num
                ub.c-ord-doc.corr-user-name     = g#userid
                ub.c-ord-doc.corr-date          = v-today
                .
        end.
    end.

    /* Статус  */
    if  (( ub.ord-doc.status_    = {&ord-rejection}
        or
        ( ub.ord-doc.status_    = {&ord-req}  and ub.ord-doc.flag_ = true and ub.ord-doc.doc-type   = {&o-o} )
        or
        ( ub.ord-doc.status_    = {&ord-req}  and ub.ord-doc.doc-type   = {&o-r} )
        or
        ( ub.ord-doc.status_    = {&ord-per}  and ub.ord-doc.doc-type   = {&o-r} )
        or
        ( ub.ord-doc.status_    = {&ord-ship} and ub.ord-doc.doc-type   = {&o-r} )
        or
        ub.ord-doc.status_    = {&fact}
        or
        ( ub.ord-doc.status_    = {&ord-rcv} and
        old_ord-doc.out-code  <> ub.ord-doc.out-code )
        or
        ( ub.ord-doc.order-type = {&order-type-gbd} and
        g#db-num <> 0 and
        ub.ord-doc.status_    = {&g___new} and
        ub.ord-doc.flag_      = true  and
        ub.ord-doc.doc-type   = {&o-o} )
        or
        ( ub.ord-doc.order-type = {&order-type-ubd} and
        g#db-num = 0 and
        ub.ord-doc.status_    = {&g___new} and
        ub.ord-doc.flag_      = true  and
        ub.ord-doc.doc-type   = {&o-o} )
        ) and
        g#news  = false)
        or is-edi-send-nws(ub.ord-doc.cli-type, ub.ord-doc.cli-code, ub.ord-doc.obj-type, ub.ord-doc.obj-code)
        then 
    do:
        run str/callnews.p
            (input {&table_ord-doc}
            ,input (buffer ub.ord-doc:handle)
            ) no-error .
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Невозможно маршрутизировать ord-doc для отправки в новости" skip
                "Заказ" ub.ord-doc.doc-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return error .
        end.
    end.

    define variable v-message as character no-undo .
    { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    " (if ub.ord-doc.doc-type = {&o-r} then {&edoc-proc_event_intorder} else {&edoc-proc_event_order}) "
    " buffer old_ord-doc:handle "
    " buffer ub.ord-doc:handle "
    ''
    ''
    no-error
    }
    if error-status:error
        then 
    do:
        v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,{&new-line}
            , error-status:get-message(1)
            , return-value ).
        if not g#news then 
        do:
            message
                v-message
                view-as alert-box error .
        end.
        undo main-block,  return error v-message.
    end.


    assign
        current-action = "Проверка строк."
        .

    for each ub.ord-line exclusive-lock
        where ub.ord-line.doc-code = ub.ord-doc.doc-code
        on error undo main-block, return error
        on end-key undo main-block, return error
        :
        run ord-savl_process-line in this-procedure ( buffer ub.ord-doc, buffer ub.ord-line) no-error .
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при обработке товара" skip
                "Заказ" ub.ord-doc.doc-code skip
                "Артикул" ub.ord-line.artic ub.ord-line.prod-type ub.ord-line.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
        /*  undo main-block, return error . */
        end.
    end.  /* for each ub.ord-line */
    if new ub.ord-doc then 
    do:
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_ord-doc}
            , input ( buffer ub.ord-doc :handle )
            , input ?
            , input ""
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
    end. 
    else 
    do:
        run trg/userlog.p (
            input {&nwsdochs_action_update}
            , input {&table_ord-doc}
            , input ( buffer ub.ord-doc :handle )
            , input ?
            , input ""
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
    end.



    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_ORD-doc}
            , input ( buffer ub.ORD-doc:handle )
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
end. /*do*/



procedure show-action :
    do
        on error undo, return error
        :
        define input parameter p-action as character no-undo .

        define variable v-today as date    no-undo.
        define variable v-time  as integer no-undo.

        run cur-time in this-procedure ( output v-today
            , output v-time
            ).
        assign
            current-time   = string(v-time - start-time, "HH:MM:SS")
            current-action = p-action
            .
        display
            current-time current-action
            with frame a.
    end.
end procedure. /* show-action */

procedure sum-head :

    do
        on error undo, return error return-value
        :
        assign
            ub.ord-doc.qnty     = 0
            ub.ord-doc.cli-qnty = 0
            ub.ord-doc.sum-cli  = 0
            ub.ord-doc.sum-rubl = 0
            ub.ord-doc.sum-base = 0
            .

        for each ub.ord-line no-lock where
            ub.ord-line.doc-code = ub.ord-doc.doc-code :
            assign
                ub.ord-doc.qnty     = ub.ord-doc.qnty + ub.ord-line.qnty
                ub.ord-doc.cli-qnty = ub.ord-doc.cli-qnty + ub.ord-line.cli-qnty
                ub.ord-doc.sum-cli  = ub.ord-doc.sum-cli  + ( ub.ord-line.cli-qnty * ub.ord-line.price-cli)
                ub.ord-doc.sum-rubl = ub.ord-doc.sum-rubl + ( ub.ord-line.qnty * ub.ord-line.price-rubl )
                ub.ord-doc.sum-base = ub.ord-doc.sum-base + ( ub.ord-line.qnty * ub.ord-line.price-base )
                .
        end.
    end.

end procedure. /* sum-head */

procedure display-line-process :
    define input parameter p-num-rec as integer no-undo .
    define parameter buffer buf_ord-line for ub.ord-line.
    DEFINE VARIABLE v-today as date    no-undo .
    DEFINE VARIABLE v-time  as integer no-undo .

    do
        on error undo, return error
        :
        run cur-time in this-procedure ( output v-today
            ,output v-time
            ).
        assign
            current-time = string(v-time - start-time, "HH:MM:SS")
            .
        display
            p-num-rec  @ num_rec
            buf_ord-line.artic
            num_gds
            current-time
            current-action
            with frame a.
    end.

end procedure. /* display-line-process */

/* $Workfile$ e n d */