block-level on error undo, throw.
/*

$Revision: a26797a5baf0, 2307, rls $
$Author: EShklyar $
$Date: Fri Feb 14 16:31:04 2020 +0300 $
$Workfile: usr-prnt.p $
$Archive: adm/usr-prnt.p $

Печать прав пользовател

Автор: Белоусов Илья Александрович
Дата создания: 08/01/08
Author: Ilia Belousov
Creation date: 08/01/08

Input:

Output:

*/
define input parameter parParentProc   AS WIDGET-HANDLE    NO-UNDO .
define input parameter p-user-id       as character        no-undo .
define input parameter p-db-num        as integer          no-undo .


define variable vss-revision    as character no-undo init "$Revision: a26797a5baf0, 2307, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Feb 14 16:31:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usr-prnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/usr-prnt.p $":U .
define variable vss-description as character no-undo init "Печать прав пользователя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

/*
{ cmp/r-page0.i  def }
*/

{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ gbl/getcntxt.i  def }

define buffer buf_user-login        for ub.user-login .
define buffer buf_user-account      for ub.user-account .
define buffer buf_global-state      for ub.global-state .
define buffer buf_global-state-attr for ub.global-state-attr .
define variable v-action-gbl as logical no-undo .

define variable g#report-num              as integer              no-undo .

define stream out-stream.

do
on error undo, return error
:
   { gbl/getcntxt.i  get }

   run get-report-num in parparentproc (output g#report-num).
   { adm/usr-prnt.i }
  FIND FIRST buf_global-state
    NO-LOCK
    .
  FIND FIRST buf_global-state-attr
    WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
    AND buf_global-state-attr.attr-code = "action-gbl"
    EXCLUSIVE-LOCK
    NO-error
    .
  IF AVAILABLE buf_global-state-attr 
    THEN 
  DO:
    if buf_global-state-attr.attr-value = "yes" then v-action-gbl = yes .
  END.
   FIND FIRST buf_user-account
      WHERE buf_user-account.user-id = p-user-id
      NO-LOCK
      NO-ERROR
      .
   IF NOT AVAILABLE buf_user-account
   THEN DO:
      message
         "Пользователь" p-user-id "не найден"
         skip
      view-as alert-box information.
      return.
   END.

   FIND FIRST buf_user-login
      WHERE buf_user-login.user-id = buf_user-account.user-id
         AND buf_user-login.db-num = p-db-num
      NO-LOCK
      NO-ERROR
      .
   IF NOT AVAILABLE buf_user-login
   THEN DO:
      message
         "У пользователя" buf_user-account.nik "отсутствует логин"
         skip "для БД" p-db-num
      view-as alert-box information.
      return.
   END.
    
   run open-stream     IN THIS-PROCEDURE .

   run print-header    in this-procedure .

   run print-body      in this-procedure .

   run close-stream    IN THIS-PROCEDURE .

end.




procedure open-stream :
do
on error undo, return error
:

    { gbl/working.i }

    { cmp/open-out.i stream out-stream " " }

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .
    output stream out-stream close.

    run usr-prnt-init in this-procedure.


end. /* do on error */
end procedure. /* open-stream */




PROCEDURE print-header :
do
on error undo, return error
:

    /* первый лист */
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet1-user}
        , input buf_user-account.user-id
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet1-user-name}
        , input buf_user-account.last-name
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet1-user-nik}
        , input buf_user-account.nik
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet1-user-login}
        , input buf_user-login.user-login
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet1-db}
        , input buf_user-login.db-num
    ).

    /* второй лист */
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet2-user}
        , input buf_user-account.user-id
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet2-user-name}
        , input buf_user-account.last-name
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet2-user-nik}
        , input buf_user-account.nik
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet2-user-login}
        , input buf_user-login.user-login
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet2-db}
        , input buf_user-login.db-num
    ).

    /* третий лист */
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet3-user}
        , input buf_user-account.user-id
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet3-user-name}
        , input buf_user-account.last-name
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet3-user-nik}
        , input buf_user-account.nik
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet3-user-login}
        , input buf_user-login.user-login
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet3-db}
        , input buf_user-login.db-num
    ).

    /* четвертый лист */
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet4-user}
        , input buf_user-account.user-id
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet4-user-name}
        , input buf_user-account.last-name
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet4-user-nik}
        , input buf_user-account.nik
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet4-user-login}
        , input buf_user-login.user-login
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet4-db}
        , input buf_user-login.db-num
    ).

end.  /* do on error */
END PROCEDURE. /* print-header */




PROCEDURE print-body :

  define buffer buf_user-login-action-role for ub.user-login-action-role .
  define buffer buf_action-role-item       for ub.action-role-item .
  define buffer buf_action-item            for ub.action-item .
  define buffer buf_action-role            for ub.action-role .
  define buffer buf_user-host              for ub.user-host .
  define buffer buf_user-obj               for ub.user-obj .
  define buffer buf_user-menu-group        for ub.user-menu-group .
  define buffer buf_clients                for ub.clients .
  define buffer buf_menu-group             for ub.menu-group .
  define variable v-host-code like ub.user-host.host-code no-undo .
  define variable v-obj-code  like ub.user-obj.obj-code no-undo .
  define variable v-obj-type  like ub.user-obj.obj-type no-undo .
  
  do
    on error undo, return error
    :
    /* 1 Фирмы */
    FOR EACH  buf_user-host WHERE 
      buf_user-host.user-id = p-user-id
      NO-LOCK:
      if not v-action-gbl and buf_user-host.db-num  <> p-db-num then next .  
      
      for FIRST buf_clients
        WHERE buf_clients.obj-type = {&cmp}
        AND buf_clients.obj-code = buf_user-host.host-code
        NO-LOCK
        :
        
        RUN usr-prnt-sheet1-write-line-data IN THIS-PROCEDURE
          ( INPUT buf_user-host.host-code
          , INPUT buf_clients.obj-name
          ) .
          v-host-code = buf_user-host.host-code .
      end.   
    END.


    /* 2 Объекты */
    FOR EACH  buf_user-obj where
      buf_user-obj.user-id = p-user-id
      NO-LOCK:
      if not v-action-gbl and buf_user-obj.db-num  <> p-db-num then next .
      for FIRST buf_clients
        WHERE buf_clients.obj-type = buf_user-obj.obj-type
        AND buf_clients.obj-code = buf_user-obj.obj-code
        NO-LOCK
        :
        RUN usr-prnt-sheet2-write-line-data IN THIS-PROCEDURE
          ( INPUT buf_user-obj.obj-type
          , INPUT buf_user-obj.obj-code
          , INPUT buf_clients.obj-name
          ) .
          assign
            v-obj-code = buf_user-obj.obj-code
            v-obj-type = buf_user-obj.obj-type
          .   
      END.
    end.

    
    /* 3 Меню */
    FOR EACH  buf_user-menu-group
      WHERE buf_user-menu-group.user-id = p-user-id
      NO-LOCK
      ,
      each buf_menu-group
      WHERE buf_menu-group.menu-code        = buf_user-menu-group.menu-code
      AND buf_menu-group.menu-group-code  = buf_user-menu-group.menu-group-code
      :
      if not v-action-gbl and buf_user-menu-group.db-num  <> p-db-num then next .
      CASE buf_user-menu-group.menu-group-context:
        WHEN {&cntxt-global}
        THEN 
          DO:
            RUN usr-prnt-sheet3-write-line-data IN THIS-PROCEDURE
              ( INPUT "Глобально"
              , INPUT buf_menu-group.menu-group-name
              ) .
          END.
        WHEN {&cntxt-firm}
        THEN 
          DO:
            FIND  FIRST buf_clients
              WHERE buf_clients.obj-type = {&cmp}
              AND buf_clients.obj-code = buf_user-menu-group.host-code
              NO-LOCK
              NO-ERROR
              .
            IF AVAILABLE buf_clients
              THEN 
            DO:
              RUN usr-prnt-sheet3-write-line-data IN THIS-PROCEDURE
                ( INPUT SUBSTITUTE( "Фирма &1 &2", buf_clients.obj-code, buf_clients.obj-name)
                , INPUT buf_menu-group.menu-group-name
                ) .
            END.
          END.
        WHEN {&cntxt-object}
        THEN 
          DO:
            FIND  FIRST buf_clients
              WHERE buf_clients.obj-type = buf_user-menu-group.obj-type
              AND buf_clients.obj-code = buf_user-menu-group.obj-code
              NO-LOCK
              NO-ERROR
              .
            IF AVAILABLE buf_clients
              THEN 
            DO:
              RUN usr-prnt-sheet3-write-line-data IN THIS-PROCEDURE
                ( INPUT SUBSTITUTE( "&1 &2 &3", buf_clients.obj-type, buf_clients.obj-code, buf_clients.obj-name)
                , INPUT buf_menu-group.menu-group-name
                ) .
            END.
          END.
        OTHERWISE 
        DO:
        END.
      END CASE.
    END.

    /* 4 Права */
    if v-action-gbl then 
    do:
      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = {&action-head-code-main}
        AND buf_user-login-action-role.action-role-context = {&cntxt-global}
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = {&action-head-code-main}
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        NO-LOCK
        :
        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = {&action-head-code-main}
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = {&action-head-code-main}
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT "Без привязки"
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.
      END.

      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = {&action-head-code-main}
        AND buf_user-login-action-role.action-role-context = {&cntxt-firm}
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = {&action-head-code-main}
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        NO-LOCK
        :
        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = {&action-head-code-main}
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = {&action-head-code-main}
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT SUBSTITUTE("Фирма &1", buf_user-login-action-role.host-code)
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.
      END.

      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = {&action-head-code-main}
        AND buf_user-login-action-role.action-role-context = {&cntxt-object}
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = {&action-head-code-main}
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        NO-LOCK
        :
        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = {&action-head-code-main}
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = {&action-head-code-main}
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT SUBSTITUTE("&1 &2", buf_user-login-action-role.obj-type, buf_user-login-action-role.obj-code)
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.
      END.
    end.
    else 
    do:
      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = {&action-head-code-main}
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.action-role-context = {&cntxt-global}
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = {&action-head-code-main}
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        AND buf_action-role.db-num              = p-db-num
        NO-LOCK
        :


        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = {&action-head-code-main}
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          AND buf_action-role-item.db-num              = p-db-num
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = {&action-head-code-main}
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT "Без привязки"
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.

      END.


      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = {&action-head-code-main}
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.action-role-context = {&cntxt-firm}
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = {&action-head-code-main}
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        AND buf_action-role.db-num              = p-db-num
        NO-LOCK
        :

        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = {&action-head-code-main}
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          AND buf_action-role-item.db-num              = p-db-num
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = {&action-head-code-main}
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :

          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT SUBSTITUTE("Фирма &1", buf_user-login-action-role.host-code)
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .

        END.

      END.

      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = {&action-head-code-main}
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.action-role-context = {&cntxt-object}
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = {&action-head-code-main}
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        AND buf_action-role.db-num              = p-db-num
        NO-LOCK
        :


        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = {&action-head-code-main}
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          AND buf_action-role-item.db-num              = p-db-num
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = {&action-head-code-main}
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT SUBSTITUTE("&1 &2", buf_user-login-action-role.obj-type, buf_user-login-action-role.obj-code)
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .

        END.

      END.
    end.  
  end.  /* do on error */
END PROCEDURE. /* print-body */




procedure close-stream :
do
on error undo, return error
:

    run usr-prnt-close in this-procedure .
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
    os-rename
        value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
        value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
    .
    { gbl/stopwork.i }

    /* печатаем */
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable DisabledOptions as integer   no-undo .
    define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w (
          input "":U
        , input 20
        , input string(session :temp-directory) + {&DF_Name} + string( g#report-num )
        , input 7
        , output v-user-action
        , output v-printed
    ).
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

end. /* do on error */
end procedure. /* close-stream */