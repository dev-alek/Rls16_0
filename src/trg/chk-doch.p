block-level on error undo, throw.
/*

$Revision: d765e193a656, 1242, rls $
$Author: EShklyar $
$Date: 2018/02/26 16:31:29 $
$Workfile: chk-doch.p $
$Archive: trg/chk-doch.p $

Запись истории для таблицы chk-doc

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/05
Author: Bakhtadze Natalya
Creation date: 10/20/05

*/

define parameter buffer buf_chk-doc for ub.chk-doc.

define input parameter p-validate    as logical no-undo .
define input parameter p-add         as logical no-undo .
define input parameter p-del         as logical no-undo .
define input-output parameter p-chip-num like ub.c-chk-doc.chip-num no-undo .
define output parameter p-is-update as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: d765e193a656, 1242, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2018/02/26 16:31:29 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-doch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: trg/chk-doch.p $":U .
define variable vss-description as character no-undo init "Запись истории для таблицы chk-doc".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-create   as logical no-undo .
define variable v-is-equal as logical no-undo .
define variable v-date     as date    no-undo.
define variable v-time     as integer no-undo.


define buffer buf_c-chk-doc      for ub.c-chk-doc.
define buffer buf_c-chk-gds      for ub.c-chk-gds.
define buffer buf_c-chk-pay      for ub.c-chk-pay.
define buffer buf_c-chk-discnt   for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_c-marking-chk  for ub.c-marking-chk.

define buffer last_c-chk-doc     for ub.c-chk-doc.
define buffer buf_chk-gds        for ub.chk-gds.
define buffer buf_chk-pay        for ub.chk-pay.
define buffer buf_chk-discnt     for ub.chk-discnt.
define buffer buf_chk-doc-attr   for ub.chk-doc-attr.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_chk-pay-attr for ub.chk-pay-attr.
define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
define buffer buf_marking-chk for marking-chk.

_main:
do
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):

    if p-validate = no
        or p-add
        or p-del
        then 
    do:
        run cur-time in this-procedure(output v-date, output v-time).
        if p-chip-num > 0 then 
        do:
            find first buf_c-chk-doc where
                buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-doc.chip-num = p-chip-num no-error .
        end.
        if not available buf_c-chk-doc then 
        do:
            find last last_c-chk-doc no-lock where
                last_c-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
            if available last_c-chk-doc then 
            do:
                assign
                    p-chip-num = last_c-chk-doc.chip-num + 1
                    .
            end.
            else 
            do:
                assign
                    p-chip-num = 1
                    .
            end.
            create buf_c-chk-doc.
            assign
                buf_c-chk-doc.doc-code         = buf_chk-doc.doc-code
                buf_c-chk-doc.chip-num         = p-chip-num
                buf_c-chk-doc.corr-user-db-num = g#db-num
                buf_c-chk-doc.corr-user-name   = g#userid
                buf_c-chk-doc.corr-time        = v-time
                buf_c-chk-doc.corr-date        = v-date
                buf_c-chk-doc.is-del           = p-del
                buf_c-chk-doc.is-add           = (if available last_c-chk-doc
                                      then last_c-chk-doc.is-add
                                      else p-add)
                v-create                       = yes
                .
            if p-add then 
            do:
                run trg/userlog.p (
                    input {&nwsdochs_action_create}
                    , input {&table_c-chk-doc}
                    , input ( buffer buf_c-chk-doc :handle )
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
            if p-del then 
            do:
                run trg/userlog.p (
                    input {&nwsdochs_action_delete}
                    , input {&table_c-chk-doc}
                    , input ( buffer buf_c-chk-doc :handle )
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
        else 
        do:
            assign
                buf_c-chk-doc.corr-user-db-num = g#db-num
                buf_c-chk-doc.corr-user-name   = g#userid
                buf_c-chk-doc.corr-time        = v-time
                buf_c-chk-doc.corr-date        = v-date
                buf_c-chk-doc.is-del           = p-del
                buf_c-chk-doc.is-add           = p-add
                .
        end.
        buffer-copy buf_chk-doc
            except doc-code PS
            to buf_c-chk-doc.
        if not v-create then 
        do:
            /*сначала сотрем*/
            for each buf_c-chk-gds where
                buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-gds.chip-num = p-chip-num:
                delete buf_c-chk-gds.
            END.
            for each buf_c-chk-pay where
                buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-pay.chip-num = p-chip-num:
                delete buf_c-chk-pay.
            END.
            for each buf_c-chk-discnt where
                buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-discnt.chip-num = p-chip-num
                :
                delete buf_c-chk-discnt.
            END.
            for each buf_c-chk-doc-attr where
                buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-doc-attr.chip-num = p-chip-num:
                delete buf_c-chk-doc-attr.
            END.
            for each buf_c-marking-chk where
                buf_c-marking-chk.doc-code = buf_chk-doc.doc-code
                AND buf_c-marking-chk.chip-num = p-chip-num:
                delete buf_c-marking-chk.
            END.
            
        end.
        for each buf_chk-gds no-lock where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
            on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
            create buf_c-chk-gds.
            buffer-copy buf_chk-gds
                to buf_c-chk-gds
                assign
                buf_c-chk-gds.chip-num = p-chip-num
                buf_c-chk-gds.corr-user-db-num = g#db-num
                .
        end.
        for each buf_chk-pay no-lock where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code
            on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
            create buf_c-chk-pay.
            buffer-copy buf_chk-pay
                to buf_c-chk-pay
                assign
                buf_c-chk-pay.chip-num = p-chip-num
                buf_c-chk-pay.corr-user-db-num = g#db-num
                .
        end.        
        for each buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
          /*  And buf_chk-discnt.record-type = 0*/ /* Сохраняем в историю все скидки, почему-то раньше только 0 и 4 сохраняли */
            on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
            create buf_c-chk-discnt.
            buffer-copy buf_chk-discnt
                to buf_c-chk-discnt
                assign
                buf_c-chk-discnt.chip-num = p-chip-num
                buf_c-chk-discnt.corr-user-db-num = g#db-num
                .
        end.
        /*for each buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            And buf_chk-discnt.record-type = 4
            on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
            create buf_c-chk-discnt.
            buffer-copy buf_chk-discnt
                to buf_c-chk-discnt
                assign
                buf_c-chk-discnt.chip-num = p-chip-num
                buf_c-chk-discnt.corr-user-db-num = g#db-num
                .
        end.*/
        for each buf_chk-doc-attr no-lock where
            buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
            on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
            create buf_c-chk-doc-attr.
            buffer-copy buf_chk-doc-attr
                to buf_c-chk-doc-attr
                assign
                buf_c-chk-doc-attr.chip-num = p-chip-num
                buf_c-chk-doc-attr.corr-user-db-num = g#db-num
                .
        end.
        for each buf_marking-chk no-lock where
                 buf_marking-chk.doc-code = buf_chk-doc.doc-code
                 on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
                 find first buf_c-marking-chk where  
                            buf_c-marking-chk.doc-code = buf_chk-doc.doc-code
                        AND buf_c-marking-chk.chip-num = p-chip-num no-error.
                 if not available buf_c-marking-chk then do:
                    create buf_c-marking-chk.
                    buffer-copy buf_marking-chk
                    to buf_c-marking-chk
                    assign
                    buf_c-marking-chk.chip-num = p-chip-num
                    buf_c-marking-chk.corr-user-db-num = g#db-num
                    .
                 end.
        end. 

    for each buf_chk-gds-attr no-lock where
            buf_chk-gds-attr.doc-code = buf_chk-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      create buf_c-chk-doc-attr.
      buffer-copy buf_chk-gds-attr
      to buf_c-chk-doc-attr
      assign
      buf_c-chk-doc-attr.attr-code = "gds=" + string(buf_chk-gds-attr.line-num) + {&delim-par} + buf_chk-gds-attr.attr-code
      buf_c-chk-doc-attr.chip-num = p-chip-num
      buf_c-chk-doc-attr.corr-user-db-num = g#db-num
      .
    end.
    for each buf_chk-pay-attr no-lock where
            buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      create buf_c-chk-doc-attr.
      buffer-copy buf_chk-pay-attr
      to buf_c-chk-doc-attr
      assign
      buf_c-chk-doc-attr.attr-code = "pay=" + string(buf_chk-pay-attr.line-num) + {&delim-par} + buf_chk-pay-attr.attr-code
      buf_c-chk-doc-attr.chip-num = p-chip-num
      buf_c-chk-doc-attr.corr-user-db-num = g#db-num
      .
    end.
    for each buf_chk-discnt-attr no-lock where
            buf_chk-discnt-attr.doc-code = buf_chk-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      create buf_c-chk-doc-attr.
      buffer-copy buf_chk-discnt-attr
      to buf_c-chk-doc-attr
      assign
      buf_c-chk-doc-attr.attr-code = "discnt=" + string(buf_chk-discnt-attr.line-num)
                                   + {&delim-key} + string(buf_chk-discnt-attr.record-type)
                                   + {&delim-key} + string(buf_chk-discnt-attr.discnt-id)
                                   + {&delim-key} + string(buf_chk-discnt-attr.object-line-num)
                                   + {&delim-par} + buf_chk-discnt-attr.attr-code
      buf_c-chk-doc-attr.chip-num = p-chip-num
      buf_c-chk-doc-attr.corr-user-db-num = g#db-num
      .
    end.

         if p-del
            and ( g#db-num > 0 )
            then 
        do:
            run str/callnews.p
                (input {&table_c-chk-doc}
                ,input (buffer buf_c-chk-doc:handle)
                ) no-error .
        end.
    end. /*not p-validate*/
    else 
    do: /*p-validate*/
        find first buf_c-chk-doc where
            buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-doc.chip-num = p-chip-num .
        buffer-compare
            buf_c-chk-doc
            EXCEPT PS
            to buf_chk-doc
            case-sensitive
            save result in v-is-equal
            .
        if not v-is-equal then 
        do:
            assign
                p-is-update = yes
                .
            return.
        end.
        for each buf_chk-gds no-lock where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code:
            find first buf_c-chk-gds no-lock where
                buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-gds.chip-num = p-chip-num
                AND buf_c-chk-gds.line-num = buf_chk-gds.line-num no-error .
            if not avail buf_c-chk-gds then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-gds to buf_chk-gds
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        for each buf_chk-pay no-lock where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code:
            find first buf_c-chk-pay no-lock where
                buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-pay.chip-num = p-chip-num
                AND buf_c-chk-pay.line-num = buf_chk-pay.line-num no-error .
            if not avail buf_c-chk-pay then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-pay to buf_chk-pay
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        for each buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            AND buf_chk-discnt.record-type < 2
            :
            find first buf_c-chk-discnt no-lock where
                buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-discnt.chip-num = p-chip-num
                AND buf_c-chk-discnt.line-num = buf_chk-discnt.line-num
                AND buf_c-chk-discnt.discnt-id = buf_chk-discnt.discnt-id
                AND buf_c-chk-discnt.object-line-num = buf_chk-discnt.object-line-num
                AND buf_c-chk-discnt.record-type     = buf_chk-discnt.record-type
                no-error .
            if not avail buf_c-chk-discnt then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-discnt to buf_chk-discnt
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        /*бонусы*/
        for each buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            AND buf_chk-discnt.record-type >= 4
            and buf_chk-discnt.record-type <= 5
            :
            find first buf_c-chk-discnt no-lock where
                buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-discnt.chip-num = p-chip-num
                AND buf_c-chk-discnt.line-num = buf_chk-discnt.line-num
                AND buf_c-chk-discnt.discnt-id = buf_chk-discnt.discnt-id
                AND buf_c-chk-discnt.object-line-num = buf_chk-discnt.object-line-num
                AND buf_c-chk-discnt.record-type     = buf_chk-discnt.record-type
                no-error .
            if not avail buf_c-chk-discnt then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-discnt to buf_chk-discnt
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        for each buf_chk-doc-attr no-lock where
            buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code:
            find first buf_c-chk-doc-attr no-lock where
                buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-doc-attr.chip-num = p-chip-num
                AND buf_c-chk-doc-attr.attr-code = buf_chk-doc-attr.attr-code no-error .
            if not avail buf_c-chk-doc-attr then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-doc-attr to buf_chk-doc-attr
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then 
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        /*у нас слава богу не разрешено менять количество строк при рекдатировани чека поэтому обработный поиск не нужен*/
        /*если мы здесь - то значит ничего не изменилось  в чеке - и не фиг засорять базу историей*/
        for each buf_c-chk-gds where
            buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-gds.chip-num = p-chip-num:
            delete buf_c-chk-gds.
        end.
        for each buf_c-chk-pay where
            buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-pay.chip-num = p-chip-num:
            delete buf_c-chk-pay.
        end.
        for each buf_c-chk-discnt where
            buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-discnt.chip-num = p-chip-num:
            delete buf_c-chk-discnt.
        end.
        for each buf_c-chk-doc-attr where
            buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-doc-attr.chip-num = p-chip-num:
            delete buf_c-chk-doc-attr.
        end.
        for each buf_c-marking-chk where
            buf_c-marking-chk.doc-code = buf_chk-doc.doc-code
            AND buf_c-marking-chk.chip-num = p-chip-num:
            delete buf_c-marking-chk.
        END.

        delete buf_c-chk-doc.

    end.
end.