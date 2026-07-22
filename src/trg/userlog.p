block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура заполнения таблицы истории пользователя.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 03/27/08
Author: Victor Guntner
Creation date: 03/27/08

Input:

Output:

*/
define input parameter p-action         as character        no-undo.
define input parameter p-tbl-name       as character        no-undo.
define input parameter p-table-handle  as handle           no-undo.
define input parameter p-video-action  as integer           no-undo.
define input parameter p-video-param   as longchar          no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура заполнения таблицы истории пользователя.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ trg/userlog.i  }
{ gbl/schemlib.i }
{ gbl/key-rec.i  }
{ gbl/cur-time.i }
{ gbl/usrnickf.i }
{ gbl/db-attr.i  }
 
    define variable v-field-handle          as handle       no-undo.
    define variable v-corr-user-db-num      as integer      no-undo.
    define variable v-parent-name           as character    no-undo.
    define variable v-field-list            as character    no-undo.
    define variable v-value-list            as character    no-undo.
    define variable v-field-counter         as integer      no-undo.
    define variable v-counter               as integer      no-undo.
    define variable v-parent-buffer-handle  as handle       no-undo.
    define variable v-parent-unique-key-rec as character    no-undo.
    define variable v-unique-key-rec        as character    no-undo.
    define variable v-corr-date             as date         no-undo.
    define variable v-corr-time             as integer      no-undo.
    define variable v-corr-user-name        as character    no-undo.
    define variable v-db-attr-value         as character    no-undo .
    define variable v-db-attr-type          as character    no-undo .
    define variable v-mess-id               as integer      no-undo .

    define buffer buf_user-login            for ub.user-login .
    define buffer buf_c-user-log            for c-user-log.
    define buffer buf_temp_userlog-bush     for temp_userlog-bush.
    
    define variable par-type as character no-undo .
    define variable par-is-cctv as character no-undo .
    define variable is-cctv as logical no-undo .

    define variable v-action-type   as character no-undo .
     
do
for buf_c-user-log
  , buf_temp_userlog-bush
on error undo, return error
:
   find last  buf_c-user-log where buf_c-user-log.corr-user-db-num = g#db-num
                             /*   and buf_c-user-log.cusr-id          = next-value( s-user-history ) */
   no-lock no-error.
   if     avail buf_c-user-log
      and buf_c-user-log.cusr-id          > current-value( s-user-history )
   then
      current-value( s-user-history ) = buf_c-user-log.cusr-id.
   release buf_c-user-log. 
             
   if p-action = 'report':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = "Отчет " + entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = 'report:':U + {&delim-key} + entry(2,p-tbl-name,{&delim-key}) 
            buf_c-user-log.head-table       = 'report':U
            buf_c-user-log.uniq-key-rec     = 'report:':U + {&delim-key} + entry(2,p-tbl-name,{&delim-key}) 
         no-error.      
        return.
    end.   
    if p-action = 'utl':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = 'utl:':U + {&delim-key} + entry(2,p-tbl-name,{&delim-key}) 
            buf_c-user-log.head-table       = 'utl':U
            buf_c-user-log.uniq-key-rec     = 'utl:':U + {&delim-key} + entry(2,p-tbl-name,{&delim-key}) 
         no-error.      
        return.
    end. 
    if p-action = 'atd-alarm-sched':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,{&delim-key}) 
            buf_c-user-log.head-table       = 'atd-alarm-sched':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,{&delim-key}) 
         no-error.      
        return.
    end.
    if p-action = 'schedule':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,{&delim-key}) 
            buf_c-user-log.head-table       = 'schedule':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,{&delim-key}) 
         no-error.      
        return.
    end.
    if p-action = 'rvd-reasons':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,{&delim-key}) 
            buf_c-user-log.head-table       = 'rvd-reasons':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,{&delim-key}) 
         no-error.      
        return.
    end.
    if p-action = 'mi-change':U
    or p-action = 'mi-change-1C':U
    then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,{&delim-key}) 
            buf_c-user-log.head-table       = p-action
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,{&delim-key}) 
         no-error.      
        return.
    end.
    if p-action = 'printdoc':U then do:      
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = 'prtdoc:':U + {&delim-key} + substring(p-tbl-name,index(p-tbl-name,{&delim-key}) + 1)
            buf_c-user-log.head-table       = 'prtdoc':U
            buf_c-user-log.uniq-key-rec     = 'prtdoc:':U + {&delim-key} + substring(p-tbl-name,index(p-tbl-name,{&delim-key}) + 1)
         no-error.      
        return.
    end.
    if   p-action = 'tech-prol-pwd':U then do:      
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid 
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = 'tech-prol-pwd:':U + {&delim-key} + entry(2,p-tbl-name,{&delim-key})
            buf_c-user-log.head-table       = 'tech-prol-pwd':U
            buf_c-user-log.uniq-key-rec     = 'tech-prol-pwd:':U + {&delim-key} + entry(2,p-tbl-name,{&delim-key})
         no-error.      
        return.
    end.
    if   p-action = 'run-proc':U then do:
       define variable mproc as character no-undo.
       define variable mparam as character no-undo.
       mparam = ";" + entry(3,p-tbl-name,{&delim-key}) no-error.
        mproc = entry(2,p-tbl-name,{&delim-key}).
        if search (mproc)  ne ?
        then
           mproc = search (mproc).
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid 
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = mproc + mparam
            buf_c-user-log.head-table       = 'run-proc':U
            buf_c-user-log.uniq-key-rec     = mproc + mparam
         no-error.      
        return.
    end.
    if   p-action = 'sysadm-pwd':U then do:      
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid 
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,{&delim-key})
            buf_c-user-log.head-table       = 'sysadm-pwd':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,{&delim-key})
         no-error.      
        return.
    end.
    
    if   p-action = 'one-pwd':U then do:      
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid 
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,{&delim-key})
            buf_c-user-log.head-table       = 'one-pwd':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,{&delim-key})
         no-error.      
        return.
    end.
    if   p-action = 'MEASURER_PAR':U then do:      
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid 
            buf_c-user-log.des              = entry(1,p-tbl-name,{&delim-key})
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,{&delim-key})
            buf_c-user-log.head-table       = 'MEASURER_PAR':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,{&delim-key})
         no-error.      
        return.
    end.
    define variable m-two-key as character no-undo.
    if num-entries (p-tbl-name,{&delim-key}) > 1
    then assign
       m-two-key  = entry(2,p-tbl-name,{&delim-key})
       p-tbl-name = entry(1,p-tbl-name,{&delim-key})
    .
    case p-action :
        when {&nwsdochs_action_delete}      then v-action-type = "Удаление" .
        when {&nwsdochs_action_create}      then v-action-type = "Создание" .
        when {&nwsdochs_action_update}      then v-action-type = "Изменение" .
        when {&nwsdochs_action_update_err}  then v-action-type = "Изменение ОШ." .
        when {&nwsdochs_action_delete_err}  then v-action-type = "Удаление ОШ." .
    end case.

    if not p-table-handle :available
    then do:
        undo, return error substitute( "&1. Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-description, p-tbl-name ).
    end.
/*    if p-action <>  {&nwsdochs_action_create} then                                                                                                 */
/*    do:                                                                                                                                            */
/*        if not valid-handle( p-table-handle :buffer-field( "corr-user-db-num":U ) )                                                                */
/*            then                                                                                                                                   */
/*        do:                                                                                                                                        */
/*            undo, return error substitute( "&1. Ошибка структуры c-таблицы. В таблице &2 нет поля corr-user-db-num", vss-description, p-tbl-name ).*/
/*        end.                                                                                                                                       */
/*        if not valid-handle( p-table-handle :buffer-field( "corr-date":U ) )                                                                       */
/*            then                                                                                                                                   */
/*        do:                                                                                                                                        */
/*            undo, return error substitute( "&1. Ошибка структуры c-таблицы. В таблице &2 нет поля corr-date", vss-description, p-tbl-name ).       */
/*        end.                                                                                                                                       */
/*        if not valid-handle( p-table-handle :buffer-field( "corr-time":U ) )                                                                       */
/*            then                                                                                                                                   */
/*        do:                                                                                                                                        */
/*            undo, return error substitute( "&1. Ошибка структуры c-таблицы. В таблице &2 нет поля corr-time", vss-description, p-tbl-name ).       */
/*        end.                                                                                                                                       */
/*    end.                                                                                                                                           */
    run gen-key-rec in this-procedure (
          input p-tbl-name
        , input p-table-handle
        , output v-unique-key-rec
    ) no-error.
    if error-status :error
    then do:
        return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3.", vss-workfile, return-value, p-tbl-name ).
    end.
    if v-unique-key-rec = ?
    or v-unique-key-rec = ""
    then do:
        return error substitute( "&1. Уникальный ключ имеет неопределенное значение. Имя таблицы &2.", vss-workfile, p-tbl-name ).
    end.

    assign
        v-corr-user-db-num = p-table-handle :buffer-field( "corr-user-db-num":U ) :buffer-value            
        v-corr-date        = p-table-handle :buffer-field( "corr-date":U ) :buffer-value   
        v-corr-time        = p-table-handle :buffer-field( "corr-time":U ) :buffer-value 
        v-corr-user-name   = p-table-handle :buffer-field( "corr-user-name":U ) :buffer-value no-error
    .
    if error-status :error then 
    do: 
        if not p-tbl-name begins "c-"
        then 
        do: 
            run cur-time in this-procedure(output v-corr-date, output v-corr-time).
            assign
                v-corr-user-db-num = g#db-num
                v-corr-date        = v-corr-date
                v-corr-time        = v-corr-time
                v-corr-user-name   = g#userid .
        end.
        else 
        do: 
            undo, return error substitute( "Ошибка структуры c-таблицы  &2 ", vss-description, p-tbl-name ).
        end.
    end.
        
    if v-corr-user-db-num   = ?
    or v-corr-date          = ?
    or v-corr-time          = ?
    or v-corr-user-name     = ?
    then do:        /* Возможно, в c-таблицу пытаются сделать запись без corr-user-db-num и т.п. - такие записи не регистрируем...  */
/*        message*/
/*            "X2"*/
/*            skip*/
/*        view-as alert-box information.*/
        undo, return .
    end.
    run userlog-hist-table-init (
          input p-tbl-name
    ).
    /* Обработка несвязанных таблиц истории */
    block-userlog-type-simple:
    for each buf_temp_userlog-bush
       where buf_temp_userlog-bush.ulbType = {&userlog-type-simple}
         and buf_temp_userlog-bush.ulbTableName = p-tbl-name
    on error undo, return error
    :
       if m-two-key ne buf_temp_userlog-bush.ulbTwoKey
       then
          next block-userlog-type-simple.
        if buf_temp_userlog-bush.ulbParentKey = 0
        then do:        /* История головной таблицы. В историю пишется unique-key-rec самой таблицы как родительский */
            assign
                v-parent-unique-key-rec = v-unique-key-rec
                v-parent-name           = p-tbl-name
            .
        end.        /* if buf_temp_userlog-bush.ulbParentKey = 0 */
        else do:
            run userlog-get-table-name in this-procedure (
                  input buf_temp_userlog-bush.ulbParentKey
                , output v-parent-name
            ).
            if v-parent-name = p-tbl-name
            then do:
                assign
                    v-parent-unique-key-rec = v-unique-key-rec
                .
            end.        /* if v-parent-name = p-tbl-name  */
            else do:
               if p-tbl-name = "user-obj" or
                  p-tbl-name = "user-host" or
                  p-tbl-name = "user-login-action-role" or
                  p-tbl-name = "user-login-action-item" or
                  p-tbl-name = "user-menu-group"
                  then do:
                  v-field-list = "user-id" .
/*                run schemlib-get-index-fields in this-procedure (*/
/*                    input p-tbl-name                             */
/*                    , output v-field-list                        */
/*                ) no-error.                                      */
               end.
               else do:
                run schemlib-get-index-fields in this-procedure (
                    input v-parent-name
                    , output v-field-list
                ) no-error.
                end.
                if error-status :error
                or v-field-list = "":U
                then do:
                    undo, return error substitute( "&1. Ошибка вычисления первичного ключа родительской таблицы '&2' для таблицы '&3'", vss-description, v-parent-name, p-tbl-name ).
                end.
                assign
                    v-field-counter = num-entries( v-field-list )
                .
                do v-counter = 1 to v-field-counter
                on error undo, return error
                :
                    assign
                        v-field-handle = p-table-handle :buffer-field( entry( v-counter, v-field-list ) )
                    .
                    if not valid-handle( v-field-handle )
                    then do:
                        undo, return error substitute( "&1. В таблице '&2' нет поля, соответствующего полю '&3' в родительской таблице '&4'"
                            , vss-description
                            , v-parent-name
                            , entry( v-counter, v-field-list )
                            , v-parent-name
                        ).
                    end.
                    assign
                        v-value-list = substitute( "&1&2&3":U
                                        , v-value-list
                                        , ( if v-value-list = "":U then "":U else ",":U )
                                        , v-field-handle :buffer-value
                                        )
                    .
                end.        /* do */
                run schemlib-set-buffer in this-procedure (
                    input v-parent-name
                    , input v-field-list
                    , input v-value-list
                    , output v-parent-buffer-handle
                ) no-error.
                if error-status:error
                then
                   return error return-value.
                run gen-key-rec in this-procedure (
                    input v-parent-name
                    , input v-parent-buffer-handle
                    , output v-parent-unique-key-rec
                ) no-error.
                if error-status :error
                then do:
                    return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3.", vss-workfile, return-value, v-parent-name ).
                end.
                if v-parent-unique-key-rec = ?
                or v-parent-unique-key-rec = ""
                then do:
                    return error substitute( "&1. Уникальный ключ имеет неопределенное значение. Имя таблицы &2.", vss-workfile, v-parent-name ).
                end.
            end.        /* NOT ( if v-parent-name = p-tbl-name  ) */
        end.        /* NOT ( if buf_temp_userlog-bush.ulbParentKey = 0 ) */

        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = v-corr-user-db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
         
            buf_c-user-log.des              = substitute( "&1 &2 &3":U
                                                , v-action-type
                                                , buf_temp_userlog-bush.ulbDesc
                                                , buf_temp_userlog-bush.ulbParentDesc
                                            )
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = v-parent-unique-key-rec
            buf_c-user-log.head-table       = v-parent-name
            buf_c-user-log.uniq-key-rec     = v-unique-key-rec
        .
        assign
        buf_c-user-log.corr-date        = p-table-handle :buffer-field( "corr-date":U ) :buffer-value
        buf_c-user-log.corr-time        = p-table-handle :buffer-field( "corr-time":U ) :buffer-value
        buf_c-user-log.corr-user-name   = p-table-handle :buffer-field( "corr-user-name":U ) :buffer-value no-error.
        if error-status :error then 
        do: 
            assign
                buf_c-user-log.corr-date      = v-corr-date
                buf_c-user-log.corr-time      = v-corr-time
                buf_c-user-log.corr-user-name = g#userid.
                
        end.
 
        if buf_c-user-log.corr-user-name = "" then do:
          assign
            buf_c-user-log.corr-user-name = p-table-handle :buffer-field( "user-id":U ) :buffer-value no-error.
        end.
    
    end.
    /* Обработка таблиц истории, связанных в кусты */
    block-userlog-type-bush:
    for each buf_temp_userlog-bush
       where buf_temp_userlog-bush.ulbType      = {&userlog-type-bush}
         and buf_temp_userlog-bush.ulbTableName = p-tbl-name
         and buf_temp_userlog-bush.ulbParentKey <> 0
    on error undo, return error
    :
       if m-two-key ne buf_temp_userlog-bush.ulbTwoKey
       then
          next block-userlog-type-bush.
       
        run userlog-get-table-name in this-procedure (
              input buf_temp_userlog-bush.ulbParentKey
            , output v-parent-name
        ).
        if v-parent-name = p-tbl-name
        then do:        /* История самой головной таблицы не пишется. */

        end.        /* if v-parent-name = p-tbl-name  */
        else do:
            run schemlib-get-index-fields in this-procedure (
                  input v-parent-name
                , output v-field-list
            ) no-error.
            if error-status :error
            or v-field-list = "":U
            then do:
                undo, return error substitute( "&1. Ошибка вычисления первичного ключа родительской таблицы '&2' для таблицы '&3'", vss-description, v-parent-name, p-tbl-name ).
            end.
            
        if not valid-handle( p-table-handle :buffer-field( "subject":U ) )
            then
        do:
            assign
                v-value-list = string(p-tbl-name)
            .
            undo, return error substitute( "&1. Ошибка структуры c-таблицы. В таблице &2 нет поля subject", vss-description, p-tbl-name ).

        end.
        else do:  
            assign
                v-value-list = string( p-table-handle :buffer-field("subject":U ) :buffer-value )
            .            
        end.
          
            run schemlib-set-buffer in this-procedure (
                  input v-parent-name
                , input v-field-list
                , input v-value-list
                , output v-parent-buffer-handle
            ).
            run gen-key-rec in this-procedure (
                  input v-parent-name
                , input v-parent-buffer-handle
                , output v-parent-unique-key-rec
            ) no-error.
            if error-status :error
            then do:
                return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3.", vss-workfile, return-value, v-parent-name ).
            end.
            create buf_c-user-log.
            assign
                buf_c-user-log.corr-user-db-num = v-corr-user-db-num
                buf_c-user-log.cusr-id          = next-value( s-user-history )
                buf_c-user-log.chip-num         = 0
                buf_c-user-log.corr-date        = p-table-handle :buffer-field( "corr-date":U ) :buffer-value
                buf_c-user-log.corr-time        = p-table-handle :buffer-field( "corr-time":U ) :buffer-value
                buf_c-user-log.corr-user-name   = p-table-handle :buffer-field( "corr-user-name":U ) :buffer-value
                buf_c-user-log.des              = substitute( "&1 &2 &3":U
                                                    , v-action-type
                                                    , buf_temp_userlog-bush.ulbDesc
                                                    , buf_temp_userlog-bush.ulbParentDesc
                                                )
                buf_c-user-log.have-screen      = yes
                buf_c-user-log.head-table-key   = v-parent-unique-key-rec
                buf_c-user-log.head-table       = v-parent-name
                buf_c-user-log.uniq-key-rec     = v-unique-key-rec
            .

        end.
    end.
    if valid-handle( v-parent-buffer-handle )
    then do:
        delete object v-parent-buffer-handle.
    end.
end.

{ gbl/conf-rd.i "'is-cctv'"  "''" "''" 0 "''" "''" "''"  no par-is-cctv par-type      no-error}
is-cctv = lookup(par-is-cctv, "true,yes":U) > 0 .
return-value = "".

if p-video-action <> 0 and p-video-action <> ? and is-cctv
    then 
do :
    define variable v-vid-ok  as logical   no-undo .
    define variable v-vid-mes as character no-undo .
    if not p-video-param begins "Login=" then 
    do :
        find first buf_user-login no-lock
            where buf_user-login.db-num  = g#db-num
            and buf_user-login.user-id = g#userid
            no-error .
        if available buf_user-login
            then 
        do:
            assign
                p-video-param = p-video-param + {&delim-par} +
                            "Login=" + buf_user-login.user-login + {&delim-par} +
                            "THname=" + usrnickf(buf_user-login.user-id)
                .
        end.
    end.

    run db-attr-value in this-procedure ( input g#db-num
                                          , input {&attr-mess-id-video}
                                          , output v-db-attr-value
                                          , output v-db-attr-type
                                          ) no-error .
    assign
      v-mess-id = integer (v-db-attr-value) no-error.
    
    if v-mess-id = ?
      then v-mess-id = 0.

    p-video-param = p-video-param + {&delim-par} +
      "MESSAGE_ID=" + string (v-mess-id)
    .
    v-mess-id = v-mess-id + 1.
    run db-attr-write in this-procedure ( input g#db-num
                                        , input {&attr-mess-id-video}
                                        , input string (v-mess-id)
                                        ) no-error .

    run trg/video-action.p (input p-video-action,
        input p-video-param,
        output v-vid-ok,
        output v-vid-mes) .
end.