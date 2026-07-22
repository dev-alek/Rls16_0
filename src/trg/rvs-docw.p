block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись документа сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/17/07
Author: Dmitry Ukhanov
Creation date: 09/17/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.rvs-doc old buffer buf-old_rvs-doc.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись документа сверки ":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-rvs.i  }
{ trg/factord.i  }

define variable v-host-code     like ub.rvs-doc.host-code no-undo.
define variable varis-back-date as logical   no-undo initial "no".
/*для работы с видеонаблюдением*/
define variable v-vid-ok        as logical   no-undo .
define variable v-vid-mes       as character no-undo .
define variable v-vid-action    as integer   no-undo .
define variable v-vid-param     as longchar  no-undo .
define variable v-mess          as character no-undo.
define buffer buf_rvs-doc    for ub.rvs-doc .
define buffer before_rvs-doc for ub.rvs-doc .
define buffer after_rvs-doc  for ub.rvs-doc .
define variable varshift-date as date    no-undo.
define variable varshift-num  as integer no-undo.
define variable varshift-name as char    no-undo.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    
    { gbl/curshift.i
   ub.rvs-doc.obj-type
    ub.rvs-doc.obj-code
    varshift-date
    varshift-num
    varshift-name
    no-error
  }

    find first ub.clients no-lock
        where ub.clients.obj-type = ub.rvs-doc.obj-type
        and ub.clients.obj-code = ub.rvs-doc.obj-code
        no-error .
    if not available ub.clients then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неправильная ссылка на объект" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "Не найден объект" ub.rvs-doc.obj-type ub.rvs-doc.obj-code skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    /* проверяем уникальность кода документа */
    run trg/chkdocnm.p
        (input ub.rvs-doc.rvs-code /* p-doc-code   */
        ,input {&table_rvs-doc}    /* p-table-name */
        ,input recid(ub.rvs-doc)   /* p-recid      */
        ) no-error .
    if error-status :error then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке уникальности кода документа" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        undo main-block, return error .
    end.

    if  ub.rvs-doc.status_ <> {&g___new}
        and ub.rvs-doc.status_ <> {&permitted}
        and ub.rvs-doc.status_ <> {&rvs-froze}
        and ub.rvs-doc.status_ <> {&fact} then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неправильный статус документа сверки" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "Статус" ub.rvs-doc.status_ skip
            view-as alert-box error .
        undo main-block, return error .
    end.

    /* обновляем пользователя, дату и время последнего обновления */
    if g#news <> yes
        and buf-old_rvs-doc.status_ <> ub.rvs-doc.status_
        then 
    do:
        { gbl/curdburt.i
      ub.rvs-doc.user-db-num
      ub.rvs-doc.user-name
      ub.rvs-doc.sys-date
      ub.rvs-doc.sys-time
      ub.rvs-doc.sys-time-int
    }
    end.

    if g#news <> yes
        and ( buf-old_rvs-doc.status_ <> ub.rvs-doc.status_
        or ( new ub.rvs-doc )
        )
        then 
    do:

    { str/hstc-rvs.i
      "buffer ub.rvs-doc"
      "integer( (if new ub.rvs-doc then {&hn-create} else {&hn-update}) )"
      ub.rvs-doc.rvs-code
      "dynamic-next-value('s-corr-chip':U,'{&db-name_schema}':U)"
      no-error
    }
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                substitute("Ошибка записи истории создания/изменения документа сверки &1", ub.rvs-doc.rvs-code ) skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.

    if buf-old_rvs-doc.status_ = ub.rvs-doc.status_ then 
    do:
        return . /* --->>>--- */
    end.

    if not new ub.rvs-doc
        and buf-old_rvs-doc.status_ = {&fact}
        and ub.rvs-doc.status_     <> {&fact} then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "Документ закрыт до статуса" {&fact} skip
            "Нельзя изменить статус документа на " ub.rvs-doc.status_ skip
            "Изменение статуса документа невозможно" skip
            view-as alert-box error .
        undo main-block, return error .
    end.

  /* проверяем, что фирма правильно заполнена */
    { gbl/hostcode.i
    ub.rvs-doc.obj-type
    ub.rvs-doc.obj-code
    v-host-code
    no-error
  }
    if error-status :error then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошика при определении кода фирмы для объекта" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "obj-type" ub.rvs-doc.obj-type skip
            "obj-code" ub.rvs-doc.obj-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if ub.rvs-doc.host-code <> v-host-code then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неправильно заполнено поле фирма" skip
            "Документ сверки" ub.rvs-doc.rvs-code skip
            "Объект"  ub.rvs-doc.obj-type ub.rvs-doc.obj-code skip
            "Фирма"   ub.rvs-doc.host-code skip
            "Должна быть фирма" v-host-code skip
            view-as alert-box error .
        undo main-block, return error .
    end.

    /* проверяем, что все товары по сверке заблокированы */
    if g#news = false
    and ub.rvs-doc.rvs-type <> {&test-asi}
    then do:
        run str/chk-rvs.p (input recid(ub.rvs-doc)) no-error.
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при проверке сверки" skip
                "Документ сверки" ub.rvs-doc.rvs-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block, return error return-value + error-status :get-message(1) .
        end.
    end.

    if ub.rvs-doc.status_ = {&permitted}
        or ub.rvs-doc.status_ = {&rvs-froze}
        or ( ub.rvs-doc.status_ = {&fact}
        and g#news = false
        )
    and ub.rvs-doc.rvs-type <> {&test-asi}
        then 
    do:
        run trg/lock-rvs.p
            ( input ub.rvs-doc.rvs-code  /* p-rvs-code          */
            , input "check-rvs-on=true"  /* p-action            */
            , input ""                   /* p-no-check-rvs-code */
            , input yes                  /* is-berate           */
            ) no-error.
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не заблокированы товары документа сверки" skip
                "Документ сверки" ub.rvs-doc.rvs-code skip
                "Статус" ub.rvs-doc.status_ skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return error .
        end.
    end.

    /* закрытие до статуса факт */
    if ub.rvs-doc.status_ = {&fact} then 
    do:
        run change-status-fact in this-procedure
            no-error .
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при выполнении программы change-status-fact" skip
                "Документ сверки" ub.rvs-doc.rvs-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.

    if g#news = false
        and ub.rvs-doc.creid = ""
        then 
    do:
        assign
            ub.rvs-doc.creid = g#userid
            .
    end.

    /* передача документа сверки через СПН (Система Передачи Новостей) */
    if not g#news then 
    do:
        if ub.rvs-doc.status_ = {&g___new} then 
        do:
            if g#db-num <> 0
                and not (new ub.rvs-doc)
                then 
            do:
                run nws/cmd-del.p
                    ( input {&table_rvs-doc}
                    ,input (buffer ub.rvs-doc:handle)
                    ,input "":U
                    ) no-error .
                if error-status :error then 
                do:
                    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
                end.
            end.
        end.
        else 
        do:
            run str/callnews.p
                (input {&table_rvs-doc}
                ,input (buffer ub.rvs-doc:handle)
                ) no-error .
            if error-status :error then 
            do:
                undo, return error substitute( "&1. Невозможно маршрутизировать rvs-doc для отправки в новости. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
            end.
        end.
    end.
    if g#oxml = yes then 
    do:
        run str/calloxml.p
            ( input {&nwsdochs_action_update}
            ,input {&table_rvs-doc}
            ,input ( buffer ub.rvs-doc:handle )
            ) no-error.
        if error-status :error then 
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                ,{&new-line}
                ,vss-workfile
                ,return-value
                ,error-status :get-message ( 1 )
                ).
        end.
    end.

    if ub.rvs-doc.rvs-type <> {&rvs-before-doc}
        and ub.rvs-doc.rvs-type <> {&test-asi}
        and ( ub.rvs-doc.status_ = {&fact}
        or ( ub.rvs-doc.status_ = {&g___new}
        and not new( ub.rvs-doc )
        )
        )
        then 
    do:
        /* в сверках по документу ставим бликировку на сверке "перед", а снимаем блокировку на сверке "после" */
        run trg/lock-rvs.p
            ( input ub.rvs-doc.rvs-code
            ,input "assign-rvs-on=false"
            ,input ""
            ,input false
            ) no-error.
        if error-status :error then 
        do:
            undo, return error return-value .
        end.
    end.

    if  ub.rvs-doc.status_ = {&fact}
    and ub.rvs-doc.rvs-type <> {&test-asi}
    and not g#news
    then do: 
        v-mess = return-value.  
        define variable v-person as character no-undo.
        for last  c-rvs-doc no-lock where
            c-rvs-doc.rvs-code = rvs-doc.rvs-code and
            c-rvs-doc.corr-user-db-num = g#db-num:
          
       
            for first  ub.clients where ub.clients.obj-type = {&prs} and  ub.clients.obj-code = ub.rvs-doc.boss no-lock : 
                v-person = clients.obj-name.
            end.
            { str/initiator.i }
            v-vid-action = 58 .
            v-vid-param =
                "Initiator=" + v-initiator + {&delim-par} +
                "ResponsiblePerson=" + (if v-person <> ?  then v-person else "") + {&delim-par} + 
                "SHOP_NUM=" + string(ub.rvs-doc.obj-code) + {&delim-par} +
                "DocType=" + string(ub.rvs-doc.rvs-type) + {&delim-par} +
                    
                "DocNum=" + string(ub.rvs-doc.rvs-code) + {&delim-par} +
                "FactDate=" + (if ub.rvs-doc.status_ = {&fact} then string(rvs-doc.fact-date) else "") + {&delim-par} +
                /*                    "ShiftNum=" + string(ub.rvs-doc.shift-num) + {&delim-par} +  */
                /*                    "ShiftDate=" + string(ub.rvs-doc.shift-date) + {&delim-par} +*/
                /*              "ShiftNumCurr=" + string(ub.c-rvs-doc.shift-num) + {&delim-par} +  */
                /*              "ShiftDateCurr=" + string(ub.c-rvs-doc.shift-date) + {&delim-par} +*/
                "SHIFT_NUM_DOC=" + (if string( ub.rvs-doc.shift-num) = ? then '' else string( ub.rvs-doc.shift-num)) + (if string( ub.rvs-doc.shift-date) = ? then '' else string( ub.rvs-doc.shift-date , "99999999" )) + {&delim-par} +  
                "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + {&delim-par} +
                "StatusOld=" + string(buf-old_rvs-doc.status_) + {&delim-par} +
                "StatusNew=" + string(ub.rvs-doc.status_) + {&delim-par} +
                "RESULT=" + string( 0 ) + {&delim-par} + 
                "Description=" + v-mess no-error.

            run trg/userlog.p (
                input {&nwsdochs_action_update}
                , input {&table_c-rvs-doc}
                , input ( buffer ub.c-rvs-doc :handle )
                , input v-vid-action
                , input v-vid-param
                ) no-error.
            if error-status :error
                then 
            do:
                return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                    , {&new-line}
                    , vss-workfile
                    , return-value
                    , error-status :get-message ( 1 ) ).
            end.
        end.
          
        for each rvs-line no-lock
            where rvs-line.rvs-code = ub.rvs-doc.rvs-code
            on error undo, return error return-value
            :
            find first rvs-line-attr no-lock
                where rvs-line-attr.obj-code  = rvs-line.obj-code
                and rvs-line-attr.obj-type  = rvs-line.obj-type
                and rvs-line-attr.gds-code  = rvs-line.gds-code
                and rvs-line-attr.pl-code   = rvs-line.pl-code
                and rvs-line-attr.rvs-code  = rvs-line.rvs-code
                and rvs-line-attr.attr-code = "CriticalDif" no-error.
            if available rvs-line-attr then
            do:
                   

                v-vid-action = 56 .
                v-vid-param = 
                    "Initiator=" + v-initiator + {&delim-par} +
                    "SHOP_NUM=" + string(ub.rvs-doc.obj-code) + {&delim-par} +
                    "DocType=" + string(ub.rvs-doc.rvs-type) + {&delim-par} +
                    "DocNum=" + string(ub.rvs-doc.rvs-code) + {&delim-par} +
                    "SHIFT_NUM_DOC=" + (if string( ub.rvs-doc.shift-num) = ? then '' else string( ub.rvs-doc.shift-num)) + (if string( ub.rvs-doc.shift-date) = ? then '' else string( ub.rvs-doc.shift-date , "99999999" )) + {&delim-par} +  
                    "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + {&delim-par} +
 
                    "PlCode=" + string( rvs-line.pl-code) + {&delim-par} +
                    "RESULT=0" + {&delim-par} +
                    /*            "Density=" + string(  rvs-line.density ) + {&delim-par} +*/
                    "Temperature=" + string( rvs-line.state-temperature) + {&delim-par} +
                    "StateDensity=" + string(  rvs-line.state-density) + {&delim-par} +
                    "StateMeasureQnty=" + string(   rvs-line.state-measure-qnty  ) + {&delim-par} + 
                    "StateBruttoQnty=" +  string( rvs-line.state-brutto-qnty ) + {&delim-par} +
                    "StateMeasureCliQnty=" + string( rvs-line.state-measure-cli-qnty)  + {&delim-par} +
                    "StateBruttoCliQnty=" + string( rvs-line.state-brutto-cli-qnty ) +  {&delim-par} +
                    "StateLevelTotal=" + string(  rvs-line.state-level-total) +  {&delim-par} +
                    "StateLevelPetrol=" + string(   rvs-line.state-level-petrol  ) +  {&delim-par} + 
                    "StateLevelWater=" + string(  rvs-line.state-level-water    ) +  {&delim-par} +  
                    "StateMeasureTcQnty=" + string(   rvs-line.state-measure-tc-qnty  ) +   {&delim-par} +  
                    "StateBruttoTcQnty=" + string(    rvs-line.state-brutto-tc-qnty ) +   {&delim-par} +  
                    "CriticalDiff=" + string(rvs-line-attr.attr-value) + {&delim-par} +
                        
                    "Description=".
            

                run trg/userlog.p (
                    input {&nwsdochs_action_update}
                    , input {&table_rvs-doc}
                    , input ( buffer ub.rvs-doc :handle )
                    , input v-vid-action
                    , input v-vid-param
                    ) no-error.
                if error-status :error
                    then
                do:
                    return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                        , {&new-line}
                        , vss-workfile
                        , return-value
                        , error-status :get-message ( 1 ) ).
                end.
            end.
        end.
    end.
  
    /* проверка на воду и отправка емайлов */
    if ub.rvs-doc.status_ = {&fact}
    and ub.rvs-doc.rvs-type <> {&test-asi}
    and g#news
      then 
    do:
        run str/rvs-wt-email.p(ub.rvs-doc.rvs-code) no-error.
        if error-status:error then
            message return-value
                view-as alert-box error.
    end.
    define variable v-new-rvs-doc as logical no-undo .

    assign
        v-new-rvs-doc = new(ub.rvs-doc)
        .
    if v-new-rvs-doc = true
    and ub.rvs-doc.rvs-type <> {&test-asi}
    and not g#news
    then do:
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_rvs-doc}
            , input ( buffer ub.rvs-doc :handle )
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
end.


procedure change-status-fact :

    do
        on error undo, return error
        :
        if g#news then 
        do:
            if ub.rvs-doc.fact-order = ?
                or ub.rvs-doc.fact-order = 0 then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Не задан фактический номер сверки" skip
                    "Документ сверки" ub.rvs-doc.rvs-code skip
                    "fact-order" ub.rvs-doc.fact-order skip
                    view-as alert-box error .
                undo, return error .
            end.
        end.


        if not g#news then 
        do:
            /* проверяем факт дату, время */
            run gbl/chk-date.p
                (input ub.rvs-doc.obj-type
                ,input ub.rvs-doc.obj-code
                ,input ub.rvs-doc.fact-date
                ,input ub.rvs-doc.fact-time
                ,input ub.rvs-doc.shift-date
                ,input ub.rvs-doc.shift-num
                ,input yes
                ) no-error.
            if error-status :error then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при установке дат, времен, смен в документе сверки." skip
                    "fact-num" ub.rvs-doc.rvs-code skip
                    "fact-date" ub.rvs-doc.fact-date skip
                    "fact-time" ub.rvs-doc.fact-time skip
                    "shift-date" ub.rvs-doc.shift-date skip
                    "shift-num" ub.rvs-doc.shift-num skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                undo, return error .
            end.

            /* проверяем целостность дат для документов сверки и складского документа */
            if ub.rvs-doc.rvs-type = {&rvs-before-doc}
                or ub.rvs-doc.rvs-type = {&rvs-after-doc} then 
            do:
                find first ub.trn-doc no-lock
                    where ub.trn-doc.doc-code = ub.rvs-doc.out-code
                    no-error .
                if not available ub.trn-doc then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при поиске складского документа для сверки" skip
                        "Документ сверки"    ub.rvs-doc.rvs-code skip
                        "Складской документ" ub.rvs-doc.out-code skip
                        view-as alert-box error .
                    undo, return error .
                end.

                find first buf_rvs-doc
                    where buf_rvs-doc.rvs-type = ub.rvs-doc.rvs-type
                    and buf_rvs-doc.out-code = ub.rvs-doc.rvs-code
                    and recid(buf_rvs-doc)   <> recid(ub.rvs-doc)
                    no-error .
                if available buf_rvs-doc then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Для складского документа указано более одной сверки одного и того же типа" skip
                        "Складской документ" ub.rvs-doc.out-code skip
                        "Документ сверки" ub.rvs-doc.rvs-code skip
                        "Тип документа сверки" ub.rvs-doc.rvs-type skip
                        "Документ сверки 2" buf_rvs-doc.rvs-code skip
                        "Тип документа сверки 2" buf_rvs-doc.rvs-type skip
                        view-as alert-box error .
                    undo, return error .
                end.

                if ub.rvs-doc.rvs-type = {&rvs-after-doc} then 
                do:
                    find first before_rvs-doc no-lock
                        where before_rvs-doc.out-code = ub.rvs-doc.out-code
                        and before_rvs-doc.rvs-type = {&rvs-before-doc}
                        no-error .
                    if not available before_rvs-doc then 
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Для склаского документа задана сверка после налива." skip
                            "Но отсутствует сверка до налива" skip
                            "Сверка после налива" ub.rvs-doc.rvs-code skip
                            "Складской документ"  ub.rvs-doc.out-code skip
                            "Тип сверки" ub.rvs-doc.rvs-type skip
                            view-as alert-box error .
                        undo, return error .
                    end.

                    if ub.rvs-doc.fact-date  <> ub.trn-doc.fact-date
                        or ub.rvs-doc.shift-date <> ub.trn-doc.shift-date
                        or ub.rvs-doc.shift-num  <> ub.trn-doc.shift-num
                        then 
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Несоответствие дат для документа сверки и складского документа" skip
                            "Документ сверки" skip
                            {&tabulation} "Документ сверки"    ub.rvs-doc.rvs-code skip
                            {&tabulation} "Дата фактического закрытия" ub.rvs-doc.fact-date skip
                            {&tabulation} "Дата начала смены"  ub.rvs-doc.shift-date skip
                            {&tabulation} "Номер смены"        ub.rvs-doc.shift-name skip
                            {&tabulation} "Порядок смены"        ub.rvs-doc.shift-num skip
                            {&tabulation} "Складской документ" ub.rvs-doc.out-code  skip
                            "Складской документ" skip
                            {&tabulation} "Складской документ" ub.trn-doc.doc-code skip
                            {&tabulation} "Дата фактического закрытия" ub.trn-doc.fact-date skip
                            {&tabulation} "Дата начала смены"  ub.trn-doc.shift-date skip
                            {&tabulation} "Номер смены"        ub.trn-doc.shift-name skip
                            {&tabulation} "Порядок смены"        ub.trn-doc.shift-num skip
                            view-as alert-box error .
                        undo, return error .
                    end.

                    if ub.rvs-doc.fact-date  <> before_rvs-doc.fact-date
                        or ub.rvs-doc.shift-date <> before_rvs-doc.shift-date
                        or ub.rvs-doc.shift-num  <> before_rvs-doc.shift-num
                        then 
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Несоответствие дат для документа сверки и складского документа" skip
                            "Документ сверки после налива" skip
                            {&tabulation} "Документ сверки"    ub.rvs-doc.rvs-code skip
                            {&tabulation} "Дата фактического закрытия" ub.rvs-doc.fact-date skip
                            {&tabulation} "Дата начала смены"  ub.rvs-doc.shift-date skip
                            {&tabulation} "Номер смены"        ub.rvs-doc.shift-name skip
                            {&tabulation} "Порядок смены"        ub.rvs-doc.shift-num skip
                            {&tabulation} "Складской документ" ub.rvs-doc.out-code  skip
                            "Документ сверки до налива" skip
                            {&tabulation} "Документ сверки"    before_rvs-doc.rvs-code skip
                            {&tabulation} "Дата фактического закрытия" before_rvs-doc.fact-date skip
                            {&tabulation} "Дата начала смены"  before_rvs-doc.shift-date skip
                            {&tabulation} "Номер смены"        before_rvs-doc.shift-name skip
                            {&tabulation} "Порядок смены"        before_rvs-doc.shift-num skip
                            {&tabulation} "Складской документ" before_rvs-doc.out-code  skip
                            view-as alert-box error .
                        undo, return error .
                    end.
                end.

                if ub.rvs-doc.rvs-type = {&rvs-before-doc} then 
                do:
                    find first after_rvs-doc no-lock
                        where after_rvs-doc.out-code = ub.rvs-doc.out-code
                        and after_rvs-doc.rvs-type = {&rvs-after-doc}
                        no-error .
                    if not available after_rvs-doc then 
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Для склаского документа задана сверка после налива." skip
                            "Но отсутствует сверка до налива" skip
                            "Сверка до налива"   ub.rvs-doc.rvs-code skip
                            "Складской документ" ub.rvs-doc.out-code skip
                            "Тип сверки" ub.rvs-doc.rvs-type skip
                            view-as alert-box error .
                        undo, return error .
                    end.
                end.
            end.

            if ub.rvs-doc.rvs-type = {&rvs-shift} then 
            do:
                /* проверяем целостность документа смены */
                if  ub.rvs-doc.out-code <> ""
                    and ub.rvs-doc.out-code <> ?  then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Для документа сверки по смене указан номер документа" skip
                        "Документ сверки" ub.rvs-doc.rvs-code skip
                        "Тип документа" ub.rvs-doc.rvs-type skip
                        "Складской документ" ub.rvs-doc.out-code skip
                        view-as alert-box error .
                    undo, return error .
                end.
            end.
            if ub.rvs-doc.fact-order > 0 then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибочно задан фактический номер документа сверки" skip
                    "Документ сверки" ub.rvs-doc.rvs-code skip
                    "fact-order" ub.rvs-doc.fact-order skip
                    view-as alert-box error .
                undo, return error .
            end.

            /* определяем порядковый номер */
            define variable v-fact-num as integer no-undo .
            assign
                v-fact-num = dynamic-next-value('s-trn-fact':U, '{&db-name_schema}':U)
                .

            /* определяем fact-order */
            define variable v-fact-order           as decimal no-undo .
            define variable v-shift-end-fact-order as decimal no-undo .
            define variable v-day-end-fact-order   as decimal no-undo .

            define variable l-shift-on             as logical no-undo .
            { gbl/objat.i
              ub.rvs-doc.obj-type
              ub.rvs-doc.obj-code
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
                undo, return error .
            end.
            run factord in this-procedure
                (input  ub.rvs-doc.fact-date   /* p-fact-date            */
                ,input  ub.rvs-doc.fact-time   /* p-fact-time            */
                ,input  v-fact-num             /* p-fact-num             */
                ,input  ub.rvs-doc.shift-date  /* p-shift-date           */
                ,input  ub.rvs-doc.shift-num   /* p-shift-num            */
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
                    "Ошибка при определении фактического номера сверки" skip
                    "doc-num"                 ub.rvs-doc.rvs-code    skip
                    "fact-date"               ub.rvs-doc.fact-date   skip
                    "fact-time"               ub.rvs-doc.fact-time   skip
                    "fact-num"                v-fact-num             skip
                    "shift-date"              ub.rvs-doc.shift-date  skip
                    "shift-num"               ub.rvs-doc.shift-num   skip
                    "v-fact-order"            v-fact-order           skip
                    "v-shift-end-fact-order"  v-shift-end-fact-order skip
                    "v-day-end-fact-order"    v-day-end-fact-order   skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                undo, return error .
            end.

            if ub.rvs-doc.rvs-type = {&rvs-shift} then 
            do:
                assign
                    ub.rvs-doc.fact-order = v-shift-end-fact-order - {&arh-delta}
                    .
            end.
            else 
            do:
                assign
                    ub.rvs-doc.fact-order = v-fact-order
                    .
            end.
            find first ub.trn-doc where ub.trn-doc.doc-code = ub.rvs-doc.out-code no-error.
            if available ub.trn-doc and
                ub.trn-doc.is-back-date then 
            do:
                assign
                    varis-back-date = yes.
            end.
            /* проверяем, что не нарушается порядок закрытия сверок
            Теперь не проверяем http://exp-jira.expertek.local:8080/browse/EXPSD-8081
            
            if varis-back-date <> yes
                and not ( ub.rvs-doc.status_ = {&fact}
                and ub.rvs-doc.is-corr
                )
                then 
            do:
                find first buf_rvs-doc no-lock
                    where buf_rvs-doc.obj-type   =  ub.rvs-doc.obj-type
                    and buf_rvs-doc.obj-code   =  ub.rvs-doc.obj-code
                    and buf_rvs-doc.status_    =  ub.rvs-doc.status_
                    and buf_rvs-doc.fact-order >= ub.rvs-doc.fact-order
                    and recid(buf_rvs-doc)     <> recid(ub.rvs-doc)
                    no-error .
                if available buf_rvs-doc then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Имеется документ сверки с более высоким порядковым номером, чем текущий." skip
                        "Закрываемая сверка" skip
                        {&tabulation} "Документ сверки"   ub.rvs-doc.rvs-code skip
                        {&tabulation} "Тип сверки"        ub.rvs-doc.rvs-type skip
                        {&tabulation} "Номер документа"   ub.rvs-doc.fact-order skip
                        {&tabulation} "Дата фактического закрытия" ub.rvs-doc.fact-date skip
                        {&tabulation} "Дата начала смены" ub.rvs-doc.shift-date skip
                        {&tabulation} "Номер смены"       ub.rvs-doc.shift-name skip
                        {&tabulation} "Порядок смены"       ub.rvs-doc.shift-num skip
                        {&tabulation} "Документ"          ub.rvs-doc.out-code  skip
                        "Существует сверка" skip
                        {&tabulation} "Документ сверки"   buf_rvs-doc.rvs-code skip
                        {&tabulation} "Тип сверки"        buf_rvs-doc.rvs-type skip
                        {&tabulation} "Номер документа"   buf_rvs-doc.fact-order skip
                        {&tabulation} "Дата фактического закрытия" buf_rvs-doc.fact-date skip
                        {&tabulation} "Дата начала смены" buf_rvs-doc.shift-date skip
                        {&tabulation} "Номер смены"       buf_rvs-doc.shift-name skip
                        {&tabulation} "Порядок смены"       buf_rvs-doc.shift-num skip
                        {&tabulation} "Документ"          buf_rvs-doc.out-code  skip
                        view-as alert-box error .
                    undo , return error .
                end.
            end.
            
            */
            if ub.rvs-doc.rvs-type <> {&test-asi}
            then do :
              run clcavrgd in this-procedure (input rvs-doc.rvs-code)  no-error.
              if error-status:error then 
              do:
                  message
                      vss-workfile vss-revision vss-description skip
                      "Ошибка при расчете веса по средней плотности" skip
                      "Закрываемая сверка" skip
                      {&tabulation} "Документ сверки"   ub.rvs-doc.rvs-code skip
                      {&tabulation} "Тип сверки"        ub.rvs-doc.rvs-type skip
                      return-value                 skip
                      error-status:get-message(1)  skip
                      error-status:get-message(2)  skip
                      error-status:get-message(3)
                      view-as alert-box error .
                  undo , return error .
              end.
            end .
        end.
        
        { gbl/rum-runa.i
        ?
        this-procedure:handle
        ?
          {&edoc-proc_event_rvs-doc}
        " buffer buf-old_rvs-doc:handle "
        " buffer ub.rvs-doc:handle "
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
        
    
    end. /*do*/
end procedure. /* change-status-act */

{ trg/clcavrgs.i }