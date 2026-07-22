/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд для определения наличия права

Автор: Гридчина Полина Дмитриевна
Дата создания: 03/05/2011
Author: Gridchina Polina
Creation date: 03/05/2011


*/


            if can-find( first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = (if v-on-gbl then 0 else v-check-db-num)
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_user-login-action-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code)
            then do:
              v-gds-grp-code = p-gds-grp-code.
              if v-on-grp and buf_user-login-action-role.gds-grp-code = ? then next.
              if v-on-grp  then do while v-gds-grp-code <> 0 :
                if buf_user-login-action-role.gds-grp-code = v-gds-grp-code then do:
                    assign
                          p-ok            = true
                          v-error-message = '':U
                    .
                    leave check_block . /* --->>>--- */
                end.
                FIND FIRST buf_gds-grp
                      WHERE buf_gds-grp.node-code = v-gds-grp-code
                      no-lock
                      no-error
                      .
                IF NOT AVAILABLE buf_gds-grp
                THEN DO:
                  assign
                      p-ok            = FALSE
                      v-error-message = substitute  ( 'Для пользователя &1 (&2)~n недоступно право &3 ~n&4 ~nпривязка &5~nгруппа товара &6'
                                                    , p-user-id
                                                    , v-full-user-name
                                                    , v-action-item-id
                                                    , v-action-item-description
                                                    , v-context
                                                    , p-gds-grp-code
                                                    )
                  .
                  leave check_block . /* --->>>--- */
                END.
                assign
                  v-gds-grp-code = buf_gds-grp.upper-code
                .
              END. /* DO WHILE */
              else do:

                assign
                  p-ok            = true
                  v-error-message = '':U
                .
                leave check_block . /* --->>>--- */
              end.
            end.

/* $Workfile$ e n d */