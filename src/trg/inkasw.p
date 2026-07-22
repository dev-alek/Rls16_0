block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись inkas

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/29/05
Author: Bakhtadze Natalya
Creation date: 11/29/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.inkas OLD old-inkas .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись inkas".
{ cmp/vssrevis.i "substitute('&1|&2', ub.inkas.inkas-code, ub.inkas.status_)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/inkash.i }
{ str/trdcalib.i }

/*define variable cre-pay like ub.sysconf.credit-pay no-undo .*/
define variable conf-par        as character no-undo .
define variable par-type        as character no-undo .
define variable v-creating-hist as logical   no-undo .
define variable v-cmp           as character no-undo .
define variable varshift-name   as character no-undo .
define variable v-attr-value    as character no-undo .
define variable v-attr-type     as character no-undo .
define variable v-send          as logical   no-undo .


define buffer buf_sysconf  for ub.sysconf .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_trn-doc  for ub.trn-doc.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :


    /*  if  ub.inkas.status_ <> {&g___new}*/
    /*  and ub.inkas.status_ <> {&fact}*/
    /*  then do:*/
    /*    message*/
    /*      vss-workfile vss-revision vss-description skip*/
    /*      "Изменение статуса продажи невозможно" skip*/
    /*      "Продажа" ub.inkas.inkas-code skip*/
    /*      "Недопустимый статус продажи" ub.inkas.status_ skip*/
    /*      view-as alert-box error .*/
    /*    undo main-block, return error.*/
    /*  end.*/

    /* обновляем пользователя, дату и время последнего обновления */
    if not g#news
        then 
    do:
        { gbl/curdburt.i
      ub.inkas.user-db-num
      ub.inkas.user-name
      ub.inkas.sys-date
      ub.inkas.sys-time
      ub.inkas.sys-time-int
    }
    end.

    /* запрещаем открывать продажу, закрытую до статуса факт */
    if  not new ub.inkas
        and (old-inkas.status_ = {&fact} or old-inkas.status_ = {&inquiry})
        and ub.inkas.status_  <> old-inkas.status_ then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Изменение статуса продажи невозможно" skip
            "Продажа" ub.inkas.inkas-code skip
            "Продажа закрыта до статуса" {&fact} skip
            "Нельзя изменить статус продажи на" ub.inkas.status_ skip
            view-as alert-box error .
        undo main-block, return error.
    end.
    /* запись истории изменений */
    if not g#news then 
    do:
        buffer-compare old-INKAS
            to ub.inkas
            case-sensitive
            save result in v-cmp
            .
        if v-cmp <> "":U
            and (lookup('status_':U, v-cmp) > 0
            or
            lookup('sale-filter':U, v-cmp) > 0
            or
            lookup('is-auto-born':U, v-cmp) > 0
            or
            lookup('is-auto-close':U, v-cmp) > 0
            or
            lookup('is-auto-get':U, v-cmp) > 0
            or
            lookup('is-auto-rsrv':U, v-cmp) > 0
            or
            lookup('doc-date':U, v-cmp) > 0
            or
            lookup('fact-date':U, v-cmp) > 0
            or
            lookup('flag_':U, v-cmp) > 0
            or
            lookup('shift-date':U, v-cmp) > 0
            or
            lookup('shift-num':U, v-cmp) > 0
            or
            lookup('shift-name':U, v-cmp) > 0
            or
            lookup('acc-date':U, v-cmp) > 0
            or
            lookup('user-name':U, v-cmp) > 0
            )
            then 
        do:
            assign
                v-creating-hist = yes
                .
            run write-inkas-history in this-procedure (buffer old-INKAS
                ,ub.inkas.inkas-code
                ,ub.inkas.host-code
                ,ub.inkas.obj-type
                ,ub.inkas.obj-code).
        end.
    end.

    if old-inkas.status_ = ub.inkas.status_ then 
    do:
        return . /* --->>>--- */
    end.

    /* отправка продажи по новостям */
    if  not g#news
        and ub.inkas.status_ = {&inquiry}
        then 
    do:
        /*должны отправить по новостям все запросы*/
        assign
            v-send = no
            .
        define buffer buf_Sale-doc for ub.sale-doc.
        _trn-doc:
        for each buf_sale-doc no-lock where
            buf_sale-doc.inkas-code = ub.inkas.inkas-code,
            first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_Sale-doc.doc-code
            or buf_trn-doc.out-code = ub.inkas.inkas-code
            on error
            undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ):
            if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
                or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
                or buf_sale-doc.order > 0
                then 
            do:
                v-send = yes.
            end.
            if v-send then 
            do:
                run str/callnews.p (
                    input {&table_trn-doc}
                    ,input (buffer buf_trn-doc:handle)
                    ) no-error .
                if error-status :error then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Невозможно маршрутизировать запрос для продажи для отправки в новости" skip
                        "Документ" buf_trn-doc.doc-code skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo, return error .
                end.
            end.
        end.
    end.
    if  not g#news
        and (ub.inkas.status_ = {&fact}
        or
        ub.inkas.status_ = {&inquiry})
        then 
    do:
        run str/callnews.p
            (input {&table_inkas}
            ,input (buffer ub.inkas:handle)
            ) no-error .
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Невозможно маршрутизировать inkas для отправки в новости" skip
                "Документ" ub.inkas.inkas-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return error .
        end.
    end.
    run trg/userlog.p (
        input {&nwsdochs_action_create}
        , input {&table_inkas}
        , input ( buffer ub.inkas :handle )
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
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_inkas}
            , input ( buffer ub.inkas:handle )
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
      {&edoc-proc_event_inkas}
      " buffer old-inkas:handle "
      " buffer ub.inkas:handle "
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