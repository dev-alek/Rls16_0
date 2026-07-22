block-level on error undo, throw.
/*

$Revision: 236d5a2aedd7, 1258, rls $
$Author: EShklyar $
$Date: Mon Mar 19 12:53:37 2018 +0300 $
$Workfile: cactnrolev.p $
$Archive: ref/cactnrolev.p $

Заполнение временной таблицы для показа изменений по таблицам истории групп прав

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/04/04
Author: Bakhtadze Natalya
Creation date: 06/04/04

*/


define input parameter  p-db-num                    like  ub.c-action-role.db-num               no-undo .
define input parameter  p-head-code                 like  ub.c-action-role.action-head-code     no-undo .
define input parameter  p-role-code                 like  ub.c-action-role.action-role-code     no-undo .
define input parameter  p-corr-user-db-num          like  ub.c-action-role.corr-user-db-num     no-undo .
define input parameter  p-chip-num                  like  ub.c-action-role.chip-num             no-undo .
define input parameter  p-subject                   like  ub.c-action-role.subject              no-undo .
define input parameter  p-action                    like ub.c-cli-hist.action                   no-undo .
define input parameter  p-silent                    as logical                                  no-undo .
define output parameter p-description               as character                                no-undo .



define variable vss-revision    as character no-undo init "$Revision: 236d5a2aedd7, 1258, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Mar 19 12:53:37 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cactnrolev.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cactnrolev.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории групп прав".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cd-attr.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii           as integer   no-undo.
define variable v-mess       as character no-undo .

define buffer buf_c-action-role      for ub.c-action-role.
define buffer buf_c-action-role-item for ub.c-action-role-item.

{ ref/tmpchgs.i "SHARED" " " "with-action" }

if p-action = integer({&hn-delete}) then return.
find first buf_c-action-role no-lock where
    buf_c-action-role.db-num   = p-db-num
    AND buf_c-action-role.action-head-code = p-head-code
    AND buf_c-action-role.action-role-code = p-role-code
    AND buf_c-action-role.chip-num = p-chip-num
    AND buf_c-action-role.corr-user-db-num = p-corr-user-db-num
    no-error .
if not available buf_c-action-role then 
do:
    return error .
end.

CASE p-subject:
    when {&table_action-role} or 
    when "":U then 
        do:
            run action-role-proc in this-procedure(output p-description) no-error .
        end.
    when {&table_action-role-item} then 
        do:
            run action-role-item-proc in this-procedure(output p-description) no-error .
        end.
END CASE.
if error-status:error then 
do:
    return error .
end.


procedure action-role-proc :
    define output parameter p-description as character no-undo .

    define buffer current_c-action-role for ub.c-action-role  .


    do
        on error undo, return error
        :
        find first current_c-action-role no-lock where
            current_c-action-role.db-num   = p-db-num
            AND current_c-action-role.action-head-code = p-head-code
            AND current_c-action-role.action-role-code = p-role-code
            AND current_c-action-role.corr-user-db-num = p-corr-user-db-num
            AND current_c-action-role.chip-num = p-chip-num
            no-error .
        if not avail current_c-action-role then 
        do:
            v-mess = "Неверная ссылка на c-action-role в таблице c-action-role".
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent then v-mess else '':U).
        end.
        define variable v-label-param as character no-undo .

    &scop fields-name-list  "action-head-code,action-role-code,action-role-context,action-role-name,action-role-description,db-num,is-del"

        v-label-param =
            "action-head-code" + {&delim-par} + "Код заголовка права" + {&delim-par} + "" + {&delim-flf}
            + "action-role-code" + {&delim-par} + "Код роли" + {&delim-par} + "" + {&delim-flf}
            + "action-role-context" + {&delim-par} + "Контекст роли" + {&delim-par} + "" + {&delim-flf}
            + "action-role-name" + {&delim-par} + "Имя роли" + {&delim-par} + "" + {&delim-flf}
            + "action-role-description" + {&delim-par} + "Описание роли" + {&delim-par} + "" + {&delim-flf}
            + "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
            + "is-del" + {&delim-par} + "Группа прав удалена" + {&delim-par} + "" .
        run proc-full-temp-changes in this-procedure (
            input  (buf_c-action-role.action = integer({&hn-create}))
            ,input  (buf_c-action-role.action = integer({&hn-delete}))
            ,input  buffer current_c-action-role:handle
            ,input  {&table_action-role}
            ,input  {&fields-name-list}
            ,input  v-label-param).
    end.
end procedure. /* action-role-proc */



procedure action-role-item-proc :
    define output parameter p-description as character no-undo .
    define variable v-tooltip as character no-undo .
    define variable v-label   as character no-undo .
    define buffer current_c-action-role-item for ub.c-action-role-item  .


    do
        on error undo, return error
        :
        find first current_c-action-role-item no-lock where
            current_c-action-role-item.db-num   = p-db-num
            AND current_c-action-role-item.action-head-code = p-head-code
            AND current_c-action-role-item.action-role-code = p-role-code
            AND current_c-action-role-item.corr-user-db-num = p-corr-user-db-num
            AND current_c-action-role-item.chip-num = p-chip-num
            no-error .
        if not avail current_c-action-role-item then
        do:
            v-mess = "Неверная ссылка на c-action-role-item в таблице c-action-role".
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent then v-mess else '':U).
        end.


    &scop fields-name-list  "action-head-code,action-role-code,action-role-item-code,action-item-code,action-item-id,db-num,is-del"

        v-label =
            "action-head-code" + {&delim-par} + "Код заголовка права" + {&delim-par} + "" + {&delim-flf}
            + "action-role-code" + {&delim-par} + "Код роли" + {&delim-par} + "" + {&delim-flf}
            + "action-role-item-code" + {&delim-par} + "Код действия" + {&delim-par} + "" + {&delim-flf}
            + "action-item-code" + {&delim-par} + "Код права" + {&delim-par} + "" + {&delim-flf}
            + "action-item-id" + {&delim-par} + "Идентификатор права" + {&delim-par} + "" + {&delim-flf}
            + "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
            + "is-del" + {&delim-par} + "Группа прав удалена" + {&delim-par} + "" .
        run proc-full-temp-changes in this-procedure (
            input  (buf_c-action-role.action = integer({&hn-create}))
            ,input  (buf_c-action-role.action = integer({&hn-delete}))
            ,input  buffer current_c-action-role-item:handle
            ,input  {&table_action-role-item}
            ,input  {&fields-name-list}
            ,input  v-label).

    end.

end procedure. /* cash-desk-attr-proc */

PROCEDURE err-mess:
    DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
    CASE p-silent:
        when yes then 
            do:
                p-mess =  substitute("История групп прав  БД&1: щепка &2 Предмет изменений &3&4&5"
                    , p-db-num
                    , p-chip-num
                    , p-subject
                    , {&new-line}
                    , p-mess).

            end.
        otherwise 
        do:
            message
                p-mess
                view-as alert-box error .
        end.
    end.
END PROCEDURE.