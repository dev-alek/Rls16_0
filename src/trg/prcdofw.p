block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на корректировку шапки документа ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 02/06/06
Author: Svetlana Chernova
Creation date: 02/06/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.price-doc-forming OLD old_price-doc-forming.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на корректировку шапки документа ДНЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-today      as date      no-undo.
define variable start-time   as integer   no-undo .
define variable v-chg-fields as character no-undo .



main-block :
do transaction
    on error undo main-block, return error
    :

    buffer-compare ub.price-doc-forming except sys-date sys-time sys-time-chr to old_price-doc-forming
        save result in v-chg-fields.

    if ub.price-doc-forming.main-pdf-id = 0 or ub.price-doc-forming.main-pdf-id = ? then 
    do:
        assign
            ub.price-doc-forming.main-pdf-id = ub.price-doc-forming.pdf-id
            ub.price-doc-forming.main-pdf-db = ub.price-doc-forming.pdf-db
            .
    end.

    run cur-time in this-procedure(output v-today, output start-time).
    /* Запись в историю только корректировки ФАКТ */
    if ub.price-doc-forming.stts = integer({&pdf-fact}) then
    do:  /*{&fact}*/
        if new (ub.price-doc-forming) then
        do:
            create ub.c-price-doc-forming.
            assign
                ub.c-price-doc-forming.plt-id           = ub.price-doc-forming.plt-id
                ub.c-price-doc-forming.plt-db-num       = ub.price-doc-forming.plt-db-num
                ub.c-price-doc-forming.pdf-id           = ub.price-doc-forming.pdf-id
                ub.c-price-doc-forming.pdf-db           = ub.price-doc-forming.pdf-db
                ub.c-price-doc-forming.chip-num         = next-value ( s-corr-chip, {&db-name_schema})
                ub.c-price-doc-forming.corr-time        = start-time
                ub.c-price-doc-forming.corr-user-db-num = g#db-num
                ub.c-price-doc-forming.corr-user-name   = g#userid
                ub.c-price-doc-forming.corr-date        = v-today
                .
        end.
        else
        do:
            create ub.c-price-doc-forming.
            BUFFER-COPY ub.price-doc-forming TO ub.c-price-doc-forming
                assign
                ub.c-price-doc-forming.chip-num           = next-value (s-corr-chip, {&db-name_schema})
                ub.c-price-doc-forming.corr-user-db-num   = g#db-num
                ub.c-price-doc-forming.corr-user-name     = g#userid
                ub.c-price-doc-forming.corr-date          = v-today
                ub.c-price-doc-forming.corr-time          = start-time
                .
        end.
    end.

    define variable v-new-price-doc-forming as logical no-undo .

    assign
        v-new-price-doc-forming = new(ub.price-doc-forming)
        .
    if v-new-price-doc-forming = true then 
    do:
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_price-doc-forming}
            , input ( buffer ub.price-doc-forming :handle )
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
            , input {&table_price-doc-forming}
            , input ( buffer ub.price-doc-forming :handle )
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
  
    /* При удалении зачистка цен */
    if ub.price-doc-forming.stts = integer({&pdf-delete}) then 
    do:  /*{&deleted-status}*/
        for each ub.price-all exclusive-lock where
            ub.price-all.pdf-db        = ub.price-doc-forming.pdf-db      and
            ub.price-all.pdf-id        = ub.price-doc-forming.pdf-id      and
            ub.price-all.plt-db-num    = ub.price-doc-forming.plt-db-num  and
            ub.price-all.plt-id        = ub.price-doc-forming.plt-id
            :
            delete ub.price-all.
        end.
    end.

    /* факт */
    if g#news = false and  (
        ub.price-doc-forming.stts = integer({&pdf-ready})  or
        ub.price-doc-forming.stts = integer({&pdf-fact})   or
        ub.price-doc-forming.stts = integer({&pdf-delete}) )   then 
    do:  /*{&fact}*/

        run str/callnews.p
            (input "price-doc-forming"
            ,input (buffer ub.price-doc-forming:handle)
            ) no-error .
        if error-status:error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при передаче в новости price-doc-forming" skip
                return-value skip
                view-as alert-box error .
            return error.
        end.
    end.

    /* удален */
    if ( g#news = false or (g#news = true  and g#db-num = 0 )) and
        ( ub.price-doc-forming.stts = integer({&pdf-delete}) and
        old_price-doc-forming.stts <> integer({&pdf-delete})
        ) then 
    do:  /*{&deleted-status}*/
        run pdf-cmd-chance-h .
    end.

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_price-doc-forming}
            , input ( buffer ub.price-doc-forming:handle )
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
end.


procedure pdf-cmd-chance-h :
    do
        on error undo, return error return-value
        :
        define variable db-list as character no-undo .

        if g#db-num > 0 then 
        do:
            db-list = "0" .
        end.
        else 
        do:
            for each ub.db no-lock where
                ub.db.db-num <> 0
                :
                db-list = db-list + string(ub.db.db-num)  +  {&delim-nws}.
            end.

            db-list = trim(db-list , {&delim-nws}) .
        end.
        run trg/cmd-pdf.p (
            ub.price-doc-forming.pdf-id  ,
            ub.price-doc-forming.pdf-db  ,
            ub.price-doc-forming.plt-id  ,
            ub.price-doc-forming.plt-db-num ,
            "status" ,
            db-list
            ) no-error .
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "cmd-pdf.p"
                view-as alert-box error
                .
            return error return-value .
        end.
    end.

end procedure. /* pdf-cmd-chance-h */