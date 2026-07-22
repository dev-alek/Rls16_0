block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: usersel.p $
$Archive: str/usersel.p $

Диалог выбора пользовател

Автор: Белоусов Илья Александрович
Дата создания: 03/13/08
Author: Ilia Belousov
Creation date: 03/13/08

Input:
    parparentproc   - handle главного окна
    p-old-user-id   - id пользователя для позиционировани

Output:
     p-new-user-id          - id выбранного пользовател
     p-new-parent-user-id   - старый идентификатор пользователя (в 14.x - login)

Пример использования:

    { gbl/getcntxt.i def}

    { gbl/getcntxt.i get}

    define variable v-selected-userid    as character    no-undo.

    run str/usersel.p (
          input parparentproc
        , input v-cntxt-userid
        , output v-selected-userid
        , output v-old-userid
    ).

*/
define input parameter parparentproc            as handle           no-undo.
define input parameter p-old-user-id            as character        no-undo.
define output parameter p-new-user-id           as character        no-undo.
define output parameter p-new-parent-user-id    as character        no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usersel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/usersel.p $":U .
define variable vss-description as character no-undo init "Диалог выбора пользователя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/onewin.i   }

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    define variable v-login-string  as character    no-undo.
    define variable v-cntxt-userid as character no-undo .
    define variable v-cntxt-db-num as integer no-undo .

    define buffer buf_user-account      for user-account.
    define buffer buf_user-login        for user-login.
do
for buf_user-account
  , buf_user-login
on error undo, return error
:
    run get-userid in parparentproc ( output v-cntxt-userid).
    run get-db-num in parparentproc ( output v-cntxt-db-num).
    assign
        p-new-user-id = p-old-user-id
    .
    run onewin_clear in this-procedure.
    for each buf_user-account no-lock
    on error undo, return error
    :
        assign
            v-login-string = "":U
        .
        for each buf_user-login no-lock
           where buf_user-login.user-id = buf_user-account.user-id
        by buf_user-login.db-num
        :
            assign
                v-login-string = substitute( "&1&2БД &3: &4"
                                            , v-login-string
                                            , ( if v-login-string = "":U then "":U else ", ":U )
                                            , buf_user-login.db-num
                                            , buf_user-login.user-login
                                            )
            .
        end.
        run onewin_add-item in this-procedure (
              input buf_user-account.user-id
            , input buf_user-account.nik
            , input substitute( "Фамилия, Имя, Отчество:   &2&1Уникальный идентификатор: &4&1Логины:             &5"
                                , {&new-line}
                                , trim( substitute( "&1 &2 &3", buf_user-account.last-name, buf_user-account.first-name, buf_user-account.second-name ) )
                                , v-cntxt-db-num
                                , buf_user-account.user-id
                                , v-login-string
                                )
            , input ( buf_user-account.user-id = v-cntxt-userid )
        ).
    end.        /* for each buf_user-account */
    run gbl/onewin.w (
          input parparentproc
        , input 2
        , input "Список псевдонимов пользователей"
        , input "":U
        , input "":U
        , input table temp_onewin_items
        , output table temp_onewin_itemsSelected
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted = yes
    then do:
        assign
            p-new-user-id = v-cur-ext-key
        .
        find first buf_user-account no-lock
             where buf_user-account.user-id = p-new-user-id
        no-error.
        if available buf_user-account
        then do:
            assign
                p-new-parent-user-id = buf_user-account.parent-user-id
            .
        end.
    end.
    else do:
        assign
            p-new-user-id           = "":U
            p-new-parent-user-id    = "":U
        .
    end.
end.