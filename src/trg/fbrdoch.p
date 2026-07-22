block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись истории документа производства

Автор: Белоусов Илья Александрович
Дата создания: 03/04/08
Author: Ilia Belousov
Creation date: 03/04/08

Input:

Output:

*/
define parameter buffer oldb for ub.fbr-doc.
define parameter buffer newb for ub.fbr-doc.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись истории документа производства".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


    define variable v-chip-num    as integer      no-undo.
    define variable v-today       as date         no-undo.
    define variable v-time        as integer      no-undo.
    define variable v-is-equal    as logical      no-undo.

    define buffer buf_c-fbr-doc     for ub.c-fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
    define buffer buf_c-fbr-line        for c-fbr-line.
do
for buf_c-fbr-doc
  , buf_fbr-line
  , buf_c-fbr-line
on error undo, return error
:
    if new( newb )
    then do:
        /* Первое изменение документа производства создаёт пустой документ, не прописан даже тип. */
        run cur-time in this-procedure (
            output v-today
            , output v-time
        ).
        assign
            v-chip-num = next-value( s-fbr-chip )
        .
        create buf_c-fbr-doc .
        buffer-copy
            newb except doc-code
        to buf_c-fbr-doc
        assign
            buf_c-fbr-doc.doc-code         = newb.doc-code
            buf_c-fbr-doc.corr-date        = v-today
            buf_c-fbr-doc.corr-time        = v-time
            buf_c-fbr-doc.corr-user-db-num = g#db-num
            buf_c-fbr-doc.corr-user-name   = g#userid
            buf_c-fbr-doc.chip-num         = v-chip-num
        .
/*        for each buf_fbr-line no-lock                                             */
/*           where buf_fbr-line.doc-code = newb.doc-code                            */
/*        on error undo, return error                                               */
/*        :                                                                         */
/*                                                                                  */
/*                create buf_c-fbr-line.                                            */
/*                assign                                                            */
/*                    buf_c-fbr-line.doc-code             = buf_fbr-line.doc-code   */
/*                    buf_c-fbr-line.trn-type             = buf_fbr-line.trn-type   */
/*                    buf_c-fbr-line.recipe-code          = buf_fbr-line.recipe-code*/
/*                    buf_c-fbr-line.artic                = buf_fbr-line.artic      */
/*                    buf_c-fbr-line.prod-type            = buf_fbr-line.prod-type  */
/*                    buf_c-fbr-line.prod-code            = buf_fbr-line.prod-code  */
/*                    buf_c-fbr-line.corr-date            = v-today                 */
/*                    buf_c-fbr-line.corr-time            = v-time                  */
/*                    buf_c-fbr-line.corr-user-db-num     = g#db-num                */
/*                    buf_c-fbr-line.corr-user-name       = g#userid                */
/*                    buf_c-fbr-line.chip-num             = v-chip-num              */
/*                .                                                                 */
                if g#news <> yes
                then do:
                    run trg/userlog.p (
                          input {&nwsdochs_action_create}
                        , input {&table_c-fbr-doc}
                        , input ( buffer buf_c-fbr-doc :handle )
                        , input ?
                        , input ""
                    ) no-error.
                    if error-status :error
                    then do:
                        undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                                            , {&new-line}
                                            , vss-workfile
                                            , return-value
                                            , error-status :get-message ( 1 ) ).
                    end.
/*                end.*/

    end.
    end.
    else do:
        run cur-time in this-procedure (
            output v-today
            , output v-time
        ).
        assign
            v-chip-num = next-value( s-fbr-chip )
        .
        create buf_c-fbr-doc .
        buffer-copy
            newb except doc-code
        to buf_c-fbr-doc
        assign
            buf_c-fbr-doc.doc-code         = newb.doc-code
            buf_c-fbr-doc.corr-date        = v-today
            buf_c-fbr-doc.corr-time        = v-time
            buf_c-fbr-doc.corr-user-db-num = g#db-num
            buf_c-fbr-doc.corr-user-name   = g#userid
            buf_c-fbr-doc.chip-num         = v-chip-num
        .
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code = newb.doc-code
        on error undo, return error
        :
/*            if new( newb )                                                                                 */
/*            then do:                                                                                       */
/*                create buf_c-fbr-line.                                                                     */
/*                assign                                                                                     */
/*                    buf_c-fbr-line.doc-code             = buf_fbr-line.doc-code                            */
/*                    buf_c-fbr-line.trn-type             = buf_fbr-line.trn-type                            */
/*                    buf_c-fbr-line.recipe-code          = buf_fbr-line.recipe-code                         */
/*                    buf_c-fbr-line.artic                = buf_fbr-line.artic                               */
/*                    buf_c-fbr-line.prod-type            = buf_fbr-line.prod-type                           */
/*                    buf_c-fbr-line.prod-code            = buf_fbr-line.prod-code                           */
/*                    buf_c-fbr-line.corr-date            = v-today                                          */
/*                    buf_c-fbr-line.corr-time            = v-time                                           */
/*                    buf_c-fbr-line.corr-user-db-num     = g#db-num                                         */
/*                    buf_c-fbr-line.corr-user-name       = g#userid                                         */
/*                    buf_c-fbr-line.chip-num             = v-chip-num                                       */
/*                .                                                                                          */
/*                if g#news <> yes                                                                           */
/*                then do:                                                                                   */
/*                    run trg/userlog.p (                                                                    */
/*                          input {&nwsdochs_action_update}                                                  */
/*                        , input {&table_c-fbr-line}                                                        */
/*                        , input ( buffer buf_c-fbr-line :handle )                                          */
/*                        , input ?                                                                          */
/*                        , input ""                                                                         */
/*                    ) no-error.                                                                            */
/*                    if error-status :error                                                                 */
/*                    then do:                                                                               */
/*                        undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"*/
/*                                            , {&new-line}                                                  */
/*                                            , vss-workfile                                                 */
/*                                            , return-value                                                 */
/*                                            , error-status :get-message ( 1 ) ).                           */
/*                    end.                                                                                   */
/*                end.                                                                                       */
/*            end.                                                                                           */
/*            else do:                                                                                       */
                assign
                    v-is-equal = no
                .
                find last buf_c-fbr-line no-lock
                    where buf_c-fbr-line.doc-code           =  buf_fbr-line.doc-code
                      and buf_c-fbr-line.trn-type           =  buf_fbr-line.trn-type
                      and buf_c-fbr-line.recipe-code        =  buf_fbr-line.recipe-code
                      and buf_c-fbr-line.artic              =  buf_fbr-line.artic
                      and buf_c-fbr-line.prod-type          =  buf_fbr-line.prod-type
                      and buf_c-fbr-line.prod-code          =  buf_fbr-line.prod-code
                use-index pi
                no-error.
                if available buf_c-fbr-line
                then do:
                    buffer-compare buf_c-fbr-line
                        except
                            corr-date
                            corr-time
                            corr-user-db-num
                            corr-user-name
                            chip-num
                    to buf_fbr-line
                    save result in v-is-equal.
                end.
                if v-is-equal = no
                then do:
                    create buf_c-fbr-line.
                    buffer-copy buf_fbr-line
                        except
                            doc-code
                            trn-type
                            recipe-code
                            artic
                            prod-type
                            prod-code
                    to buf_c-fbr-line
                    assign
                        buf_c-fbr-line.doc-code             = buf_fbr-line.doc-code
                        buf_c-fbr-line.trn-type             = buf_fbr-line.trn-type
                        buf_c-fbr-line.recipe-code          = buf_fbr-line.recipe-code
                        buf_c-fbr-line.artic                = buf_fbr-line.artic
                        buf_c-fbr-line.prod-type            = buf_fbr-line.prod-type
                        buf_c-fbr-line.prod-code            = buf_fbr-line.prod-code
                        buf_c-fbr-line.corr-date            = v-today
                        buf_c-fbr-line.corr-time            = v-time
                        buf_c-fbr-line.corr-user-db-num     = g#db-num
                        buf_c-fbr-line.corr-user-name       = g#userid
                        buf_c-fbr-line.chip-num             = v-chip-num
                    .
                    if g#news <> yes
                    then do:
                        run trg/userlog.p (
                              input {&nwsdochs_action_update}
                            , input {&table_c-fbr-line}
                            , input ( buffer buf_c-fbr-line :handle )
                            , input ?
                            , input ""
                        ) no-error.
                        if error-status :error
                        then do:
                            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                                                , {&new-line}
                                                , vss-workfile
                                                , return-value
                                                , error-status :get-message ( 1 ) ).
/*                        end.*/
                    end.
                end.
            end.
        end.        /* for each buf_fbr-line */
    end.
end.