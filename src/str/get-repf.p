/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа приема отчета с касс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/28/05
Author: Bakhtadze Natalya
Creation date: 09/28/05

На объекте:
p-remote = 0
1 посылает запросы на все включенные не remote кассы объекта
2 читает поочередно полученные спул-файлы
3 все чеки, которых нет в БД, переписывает в БД
4 проверяет правильность каждого чека и отмечает ошибки


p-remote = 1
1 посылает запросы на все включенные remote кассы объекта

p-auto = -1 подбор неразобранных ранее файлов с касс IBM-XML не посылаем запрос

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

define input parameter p-remote as integer no-undo .
которые далее определены как переменные с префиксом p-

*/
/*0 работа с*/

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Программа приема чеков с касс" .
{ cmp/vssrevis.i }

{ str/get-chk.i  NEW }
{ str/get-chkf.i }
{ bge/bgelib.i }
{ str/cd-xml.i  }
{ str/tekkatsk.i  " " Dirstream }
{ gbl/thbj-def.i }
{ gbl/key-rec.i }
{ bge/socet.i}
{ gbl/objsrv.i}
/*образыв бывших input parameter*/
define variable p-obj-type        like ub.clients.obj-type no-undo .
define variable p-obj-code        like ub.clients.obj-code no-undo .

define variable p-remote          as integer   no-undo .
define variable p-auto            as integer   no-undo .
define variable p-shft-close      as integer   no-undo .
define variable p-other           as character no-undo .
define variable v-input-error     as logical   no-undo .
define variable v-view-log        as logical   no-undo .
define variable v-date            as date      no-undo.
define variable v-time            as integer   no-undo.
define variable v-today-date      as date      no-undo.
define variable v-today-time      as integer   no-undo.
define variable v-shift-num       as integer   no-undo .
define variable v-shift-name      as character no-undo.
define variable v-z-count         as integer   no-undo .
define variable v-chk-num         as integer   no-undo .
define variable v-mes             as character no-undo .
define variable v-param-prfx      as character no-undo .
define variable v-shift-date      as date      no-undo .
define variable l-shift-on        as logical   no-undo .
define variable v-esm             as character no-undo .
define variable v-shift-date-chr  as character no-undo .
define variable v-versiond        as decimal   no-undo .
define variable v-podbor          as logical   no-undo .
define variable log-file-name     as character no-undo .
define variable ii                as integer   no-undo .
define variable v-spec-command    as character no-undo .
define variable v-entry           as character no-undo .
define variable v-attr-value      as character no-undo .
define variable v-attr-type       as character no-undo .
define variable v-is-script       as logical   no-undo .
define variable imaria            as integer   no-undo .
define variable shift-maria       as integer   no-undo .
define variable v-p-spl           as character no-undo .
define variable v-spl-doc         as character no-undo .
define variable v-spl             as character no-undo .
define variable v-no-get-chk      as logical   no-undo .
define variable dflt-cd           as character no-undo .
define variable v-param-type      as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as INTEGER   no-undo .
define variable v-value-logical   AS LOGICAL   no-undo .
define variable v-tth             as handle    no-undo .
define variable vi                as integer   no-undo.
assign
    v-tth = buffer thbjattr_thbj-attr:table-handle .


&scop view-log   if p-auto = 0 then do: ~
                   ~{ str/cdviewlg.i   ~
                    "substitute('!!!При приеме информации с касс &1&2 произошли ошибки!!!'  ~
                                 ,p-obj-type                                                ~
                                 ,p-obj-code)"                                               ~
                    "'get-chkf.log'" ~}   ~
                    return "error":U. ~
                 end

if num-entries(p-parameter, {&delim-par}) < 3
    then 
do:
    assign
        v-input-error = yes
        v-esm         = "Неверное количество ENTRY в составном параметре"
        .
end.
else 
do:
    assign
        p-obj-type   = entry(1, p-parameter, {&delim-par})
        p-obj-code   = integer(entry(2, p-parameter, {&delim-par}))
        p-remote     = integer(entry(3, p-parameter, {&delim-par}))
        p-auto       = if num-entries(p-parameter, {&delim-par}) >= 4
             then integer(entry(4, p-parameter, {&delim-par}))
             else 0
        p-shft-close = if num-entries(p-parameter, {&delim-par}) >= 5
             then integer(entry(5, p-parameter, {&delim-par}))
             else 0
  no-error .
    if error-status:error then 
    do:
        assign
            v-esm         = error-status:get-message(1)
            v-input-error = yes
            .
    end.
    if num-entries(p-parameter, {&delim-par}) > 7 then 
    do:
        p-other = p-parameter.
        entry(1, p-other, {&delim-par}) = ''.
        p-other = substring(p-other, 2).
        entry(1, p-other, {&delim-par}) = ''.
        p-other = substring(p-other, 2).
        entry(1, p-other, {&delim-par}) = ''.
        p-other = substring(p-other, 2).
        entry(1, p-other, {&delim-par}) = ''.
        p-other = substring(p-other, 2).
        entry(1, p-other, {&delim-par}) = ''.
        p-other = substring(p-other, 2).
        entry(1, p-other, {&delim-par}) = ''.
        p-other = substring(p-other, 2).
        entry(1, p-other, {&delim-par}) = ''.
        p-other = substring(p-other, 2).
    end.
    assign
        v-podbor = (if p-auto = -1 then yes else no)
        p-auto   = (if v-podbor then 0 else p-auto)
        p-auto   = (if g#auto then 1 else 0)
        .
end.


assign
    log-file-name = (if p-auto = 0 then 'get-repf.log' else 'extgetcd.log').


if v-input-error = yes then 
do:
    run write-log-and-file in p-log-handle (
        input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка входных параметров &1:&2&3&4"
        , p-parameter
        , {&new-line}
        , v-esm
        , return-value
        )).
    assign
        v-view-log = yes.
    {&view-log}.
end.

{ str/waitp.i }


DEFINE VARIABLE var-found-not-remote as logical   no-undo .
DEFINE VARIABLE var-spl-suffix       as character no-undo .
DEFINE VARIABLE var-spl-suffix-tmp   as character no-undo .
define variable v-host-code          like ub.sysconf.host-code no-undo .
define variable glog                 as logical   no-undo .

for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
end.
assign
    v-tth = buffer thbjattr_thbj-attr:table-handle .
define variable v-disp-msg as character no-undo.

define buffer get-chk-lock_batchprocess for ub.batchprocess .

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }

{ str/lockgchk.i }

run writelog in p-log-handle (
    input log-file-name
    , input 0
    , input  "&Dline"
    ).
define variable v-cd-prfx           as character no-undo .
define variable v-spl-obj-cash-name as character no-undo .

{ gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd no-error }

_cash-desk:
FOR EACH ub.cash-desk NO-LOCK WHERE
    ub.cash-desk.db-num = g#db-num and
    ub.cash-desk.obj-code = p-obj-code AND
    ub.cash-desk.cash-on
    BREAK
    By ub.cash-desk.pos-type
    with frame a :
    IF FIRST-OF(ub.cash-desk.pos-type) then 
    do:
    
        v-index = index(p-other, ub.cash-desk.pos-type + '=').
        if v-index > 0 then 
        do:
            /*извлечем спец команду*/
            assign
                v-spec-command = substring(p-other, v-index)
                v-index        = index(v-spec-command , {&delim-par})
                v-spec-command = if v-index > 0
                        then substring(v-spec-command , 1, v-index - 1)
                        else v-spec-command
                v-spec-command = replace(v-spec-command, cash-desk.pos-type + '=', '':U)
                .
        end.
        else 
        do:
            v-spec-command = '':U.
        end.
        CASE cash-desk.pos-type:
            when {&cd-type-IBM-XML} then 
                do:
                    assign
                        v-cd-prfx    = 'IBM-XML':U
                        v-param-prfx = 'ibm':U
                        .
                end.
            when {&cd-type-autotank} then 
                do:
                    assign
                        v-cd-prfx    = 'autotank':U
                        v-param-prfx = 'autotank':U
                        .
                end.
        END CASE.

        CASE cash-desk.pos-type :
            when {&cd-type-IBM-XML}
            or
            when {&cd-type-autotank}
            then  
                do:
                    run str/get-inis.p (
                        input p-obj-type
                        , input p-obj-code
                        , input cash-desk.pos-type
                        , input cash-desk.remote
                        , input "get":U /*некий параметр который говорит для чего нам настройки*/
                        , output out
                        , output out2
                        , output in_
                        , output spl
                        , output sav
                        , output v-remote
                        )  no-error .
                    if error-status:error then 
                    do:
                        run write-log-and-file in p-log-handle (
                            input 1
                            , input log-file-name
                            , input 1
                            , input substitute(
                            "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                            , cash-desk.pos-type
                            , p-obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            )).
                        assign
                            v-view-log = yes.
                        {&view-log}.
          else undo,  return "error".
                    end.
                    if cash-desk.pos-type = {&cd-type-magia-XML} then 
                    do:
                        assign
                            kassa-rub-code = 0
                            ibmgroup       = no
                            ibmspool       = "3"
                            .
                    end.
                    else 
                    do:
                        /* выбор секции, из которой читать настройки для кассы */
                        define variable v-effective-pos-type as character no-undo .
                        v-effective-pos-type =  (if (cash-desk.pos-type = {&cd-type-ibm}
                                      or
                                      cash-desk.pos-type = {&cd-type-nkt-ibm})
                                  then {&attr-cd-type-ibm}
                                  else {&attr-cd-type-ibm-xml}
                                  ).

                        run adm/shattri.p (
                            input "get":U
                            ,input  p-obj-type
                            ,input  p-obj-code
                            ,input  v-effective-pos-type
                            ,input  '':U /*p-param-code*/
                            ,output v-value-character
                            ,output v-value-date
                            ,output v-value-decimal
                            ,output v-value-integer
                            ,output v-value-logical
                            ,output v-param-type
                            ,INPUT-OUTPUT table-handle v-tth
                            ) no-error .
                        IF error-status:error then 
                        do:
                            assign
                                v-mes = substitute(
                                  "Не удалось получить настройки для  POS типа &1 для маг&2"
                                  , cash-desk.pos-type
                                  , p-obj-code).
                            run write-log-and-file in p-log-handle (
                                input 1
                                , input log-file-name
                                , input 1
                                , input v-mes).
                            v-view-log = yes.
                            undo, return error v-mes.
                        end.
                        for each thbjattr_thbj-attr where
                            thbjattr_thbj-attr.obj-type = p-obj-type
                            and thbjattr_thbj-attr.obj-code = p-obj-code
                            and thbjattr_thbj-attr.upper-prop-code =  v-effective-pos-type
                            on error undo, return error :
                            case thbjattr_thbj-attr.prop-code :
                                when {&attr-cd-type-ibm-xml_ibmrubc} then 
                                    do:
                                        kassa-rub-code = thbjattr_thbj-attr.property-value-integer.
                                    end.
                                when {&attr-cd-type-IBM-XML_specgrp} then
                                    do:
                                        specgrp = thbjattr_thbj-attr.property-value-character.
                                    end.
                                when {&attr-cd-type-autotank_cash-pay-list} then 
                                    do:

                                    end.
                            end case.
                        end.
                        if cash-desk.pos-type = {&cd-type-ibm-xml}
                            and entry(1, v-spec-command) = "version" then 
                        do:
                            define variable v-field-list as character no-undo .
                            define variable v-value-list as character no-undo .
                            define variable v-pos-type   as character no-undo .
                            define variable v-cash-num   as integer   no-undo init ?.
                            run gen-key-fv in this-procedure ( input replace(v-spec-command, "version" + {&comma-char}, '')
                                ,output v-field-list
                                ,output v-value-list
                                ).
                            assign
                                v-pos-type = entry(lookup("pos-type"
                                      , v-field-list
                                      , {&delim-key})
                                , v-value-list, {&delim-key})
                                v-cash-num = integer(entry(lookup("cash-num"
                                              , v-field-list
                                              , {&delim-key})
                                        , v-value-list, {&delim-key})).
                        end.
                    end. /*ibm* или ibm-xml */
                    assign
                        var-found-not-remote = no
                        .
        
                    /* Получение данных по отчетам с кассы */
                    run str/get-chk-report.p(parparentproc,
                        p-parent-handle,
                        p-log-handle,
                        log-file-name,
                        p-obj-type,
                        p-obj-code,
                        output v-value-logical) no-error.
                    if error-status:error then 
                    do:
                        run write-log-and-file in p-log-handle (
                            input 1
                            , input log-file-name
                            , input 1
                            , input return-value).
        
                    end.
                end.
        end.
    end.

end.
define variable v-save-file-name as character no-undo .
  
v-save-file-name = substitute("&1get-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
  
if v-view-log and p-auto = 0 then 
do:
    message
        "!!!При получении данных с касс произвошли ошибки!!!" skip
        "По завершении сообщения об ошибках будут сохранены в файле" skip
        v-save-file-name  
        view-as alert-box error .
    define variable v-user-action as character no-undo .
    define variable v-printed     as logical   no-undo .
    run gbl/prnfilen.w
        (input  "Ошибки, возникшие при получении данных с касс"
        ,input  0
        ,input  "./get-repf.log":U
        ,input  7
        ,output v-user-action
        ,output v-printed
        ) .

end.
  
run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute("&1", {&new-line})
    ).
OS-APPEND value(log-file-name) value(v-save-file-name).
OS-DELETE value(log-file-name).
/* если log-file-name писал в extgetcd.log - то отдельно
   надо добавить get-chkf.log, в который писали вложенные процессы */
if index (log-file-name, "get-repf.log") > 0 then . 
else 
do:
    OS-APPEND value("get-repf.log") value(v-save-file-name).
    OS-DELETE value("get-repf.log").
end.

