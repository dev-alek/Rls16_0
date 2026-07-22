block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

проверка необходимости выполнения действия по расписанию

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/03
Author: Dmitry Ukhanov
Creation date: 03/22/03

*/
/*define temp-table tt-BatchProcess  like ub.BatchProcess .*/
{ adm/ttbatch.i }
 
define input  parameter p-task-type   as character no-undo .
define input  parameter p-for-db      as longchar no-undo .
define output parameter p-list-db     as character no-undo .
define output parameter p-list-db-All as character no-undo .
define output parameter p-list-key     as character no-undo .
define output parameter p-list-key-all  as character no-undo .

define input  parameter p-for-extsys  as character no-undo .
define input  parameter p-for-proc    as character no-undo .
define output parameter table for tt-BatchProcess .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "проверка необходимости выполнения действия по расписанию".
{ cmp/vssrevis.i }
{ adm/auto-def.i }
{ gbl/db-attr.i  }
{ cmp/ini-lib.i  }
{ adm/push-m.i "with-attr-code" }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define temp-table tt-db no-undo
    field db-num as integer
    index pi is unique primary
      db-num ascending
  .

  define buffer buf_sys-ctrl         for ub.sys-ctrl .
  define buffer buf_db               for ub.db .
  define buffer buf_schedule         for ub.schedule .
  define buffer buf_BatchProcess     for ub.BatchProcess .
  define buffer buf-all_BatchProcess for ub.BatchProcess .

  define variable v-str           as character no-undo .
  define variable v-db-attr-value as character no-undo .
  define variable v-db-attr-type  as character no-undo .
  define variable v-db-attr-code  as character no-undo .
  define variable v-db-attr-exist as logical   no-undo .
  define variable v-db-attr-del   as logical   no-undo .
  define variable v-time          as integer   no-undo .
  define variable v-today         as date      no-undo .

  define variable v-new-time      as character no-undo .
  define variable v-new-date      as date      no-undo .
  define variable v-user-id       as character no-undo .
  define variable v-process       as character no-undo .
  define variable v-chg-manual    as logical   no-undo .
  define variable v-out           as character no-undo.
  define variable vWaitNextRunTime as logical no-undo.

  run cur-time( output v-today
               ,output v-time
              ) no-error.
  if error-status :error then do:
    run write-to-log( vss-workfile + {&space-char}
                      + "Ошибка при определении текущего времени"
                    ) .
  end.
  run verify-ini-entry in this-procedure (
                                         input  'WaitNextRunTime'
                                        ,input    'schedule-free'
                                        ,input substitute("отсутствует параметр &1 секция &2 в ini-файле"
                                                          , 'WaitNextRunTime'
                                                          , 'schedule-free')
                                        ,input yes
                                        ,output v-out) no-error.
  if    not error-status:error 
     and v-out ne ?
     and v-out ne ""
  then
     vWaitNextRunTime =  logical( v-out) no-error.
  assign
    v-str          = get-str-type( p-task-type )
    v-db-attr-code = get-attr-code( p-task-type )
  .
  if v-str = ? then do:
    return error string( vss-workfile + {&space-char} + "НЕТ ОБРАБОТКИ АТРИБУТА" + {&space-char} + p-task-type ) .
  end.

  assign
    p-list-db = "":U
  .

  find first buf_sys-ctrl no-lock.
  if trim( buf_sys-ctrl.status_ ) <> "":U then do:
    return error substitute( "&1. При статусе БД равном &2 работа сеанса &3 не допускается!"
                             ,vss-workfile
                             ,buf_sys-ctrl.status_
                             ,v-str
                            ) .

  end.

  /* проверка соответствия атрибутов действительности */
  for each tt-db
  on error undo, return error return-value
  :
    delete tt-db.
  end.

  for each buf_schedule no-lock
    where buf_schedule.task-type = p-task-type
      and buf_schedule.db-num-char <> "*":U
  on error undo, return error return-value
  :
    if buf_schedule.active = true then do:
      run gbl/prcs-lst.p
        ( input buf_schedule.db-num-char
        , input 0
        , input 99999  /* (максимальное значение db.db-num) */
        , input false
        , input (buffer tt-db:handle)
        , input "db-num":U
        ) no-error .
    end.
  end.

  block1_db:
  for each buf_db no-lock
  on error undo, return error return-value
  :
    find first buf_schedule no-lock
      where buf_schedule.task-type   = p-task-type
        and buf_schedule.db-num-char = "*":U
        and buf_schedule.active      = true
      no-error
    .
    if not available buf_schedule then do:
      find first tt-db no-lock
        where tt-db.db-num = buf_db.db-num
        no-error
      .
      if not available tt-db then do:
        run db-attr-exist ( input buf_db.db-num
                           ,input v-db-attr-code
                           ,output v-db-attr-exist
                          ) no-error.
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка при определении наличия атрибута расписания для БД &2"
                                        ,vss-workfile
                                        ,buf_db.db-num
                                      )
                          ) .
        end.
        if v-db-attr-exist = true then do:
          run db-attr-value ( input buf_db.db-num
                             ,input v-db-attr-code
                             ,output v-db-attr-value
                             ,output v-db-attr-type
                            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка при чтении атрибута наличия расписания для БД &2"
                                          ,vss-workfile
                                          ,buf_db.db-num
                                        )
                            ) .
          end.
          if v-db-attr-value = "yes":U then do:
            run db-attr-delete ( input buf_db.db-num
                                ,input v-db-attr-code
                                ,output v-db-attr-del
                              ) no-error.
            if error-status :error
              or v-db-attr-del = false
            then do:
              run write-to-log( substitute( "&1. Ошибка при удалении атрибута отсутствия расписания для БД &2&3"
                                            ,vss-workfile
                                            ,buf_db.db-num
                                            ,{&new-line}
                                            ,return-value
                                          )
                              ) .
            end.
          end.
          next block1_db.
        end.
      end.
    end.

    find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = {&btpr-normal}
        and buf_BatchProcess.BP_Type     = p-task-type
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
        and (p-task-type <> {&btpr-type-autooxml} or 
              (p-task-type = {&btpr-type-autooxml} and 
                (  (num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-extsys = ""
                    ) 
                or (p-for-extsys <> "" 
                    and num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                    and entry (4, buf_BatchProcess.CharKey_Three, {&delim-key}) = p-for-extsys
                    )
                 )
               )
             )
          and (p-task-type <> {&btpr-type-autofree} or 
                (p-task-type = {&btpr-type-autofree} and 
                  (  (num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-proc = ""
                      ) 
                  or (p-for-proc <> "" 
                      and num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                      and entry (4, buf_BatchProcess.CharKey_Three, {&delim-key}) = p-for-proc
                      )
                   )
                 )
               )
      no-error
    .

    if not available buf_BatchProcess then do:
      run db-attr-exist ( input buf_db.db-num
                          ,input v-db-attr-code
                          ,output v-db-attr-exist
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка при определении наличия атрибута расписания для БД &2"
                                      ,vss-workfile
                                      ,buf_db.db-num
                                    )
                        ) .
      end.
      if v-db-attr-exist then do:
        run db-attr-write ( input buf_db.db-num
                            ,input v-db-attr-code
                            ,input "no":U
                          ) no-error.
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка при записи атрибута отсутствия расписания для БД &2"
                                        ,vss-workfile
                                        ,buf_db.db-num
                                      )
                          ) .
        end.
      end.
    end.
  end.
  for each tt-db
  on error undo, return error return-value
  :
    delete tt-db.
  end.

  for each buf_db no-lock
  on error undo, return error
  :
    if p-task-type = {&btpr-type-autonws}
       and ( ( buf_sys-ctrl.db-num = 0
               and buf_db.db-num = 0
             )
             or ( buf_sys-ctrl.db-num <> 0
                  and buf_db.db-num <> 0
                )
           )
    then do:
    /* для жесткости в новостях отсеиваем "лишние" БД */
      next.
    end.
    if p-task-type = {&btpr-type-autooxml}
       and ( ( buf_sys-ctrl.db-num = 0
               and buf_db.db-num <> 0
             )
             or ( buf_sys-ctrl.db-num <> 0
                  and buf_db.db-num <> buf_sys-ctrl.db-num
                )
           )
    then do:
    /* для жесткости в oxml отсеиваем "лишние" БД */
    /*гюнтнер согласен и извещен*/
      next.
    end.

    if p-for-db <> "":U
      and lookup( string( buf_db.db-num), p-for-db ) = 0
    then do:
      /* добавим фильтр на сессию, если такой имеется */
      next.
    end.

    find first buf_BatchProcess exclusive-lock
      where buf_BatchProcess.BP_Status   = {&btpr-normal}
        and buf_BatchProcess.BP_Type     = p-task-type
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
        and (p-task-type <> {&btpr-type-autooxml} or 
              (p-task-type = {&btpr-type-autooxml} and 
                (  (num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-extsys = ""
                    ) 
                or (p-for-extsys <> "" 
                    and num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                    and entry (4, buf_BatchProcess.CharKey_Three, {&delim-key}) = p-for-extsys
                    )
                 )
               )
             )
          and (p-task-type <> {&btpr-type-autofree} or 
                (p-task-type = {&btpr-type-autofree} and 
                  (  (num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-proc = ""
                      ) 
                  or (p-for-proc <> "" 
                      and num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                      and entry (4, buf_BatchProcess.CharKey_Three, {&delim-key}) = p-for-proc
                      )
                   )
                 )
               )
      no-error
    .
    if available buf_BatchProcess then do:
      for each buf-all_BatchProcess exclusive-lock
        where buf-all_BatchProcess.BP_Status   = {&btpr-normal}
          and buf-all_BatchProcess.BP_Type     = p-task-type
          and buf-all_BatchProcess.CharKey_One = string( buf_db.db-num )
          and buf-all_BatchProcess.CharKey_Two = "auto":U
          and (p-task-type <> {&btpr-type-autooxml} or 
                (p-task-type = {&btpr-type-autooxml} and 
                  (  (num-entries (buf-all_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-extsys = ""
                      ) 
                  or (p-for-extsys <> "" 
                      and num-entries (buf-all_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                      and entry (4, buf-all_BatchProcess.CharKey_Three, {&delim-key}) = p-for-extsys
                      )
                   )
                 )
               )
          and (p-task-type <> {&btpr-type-autofree} or 
                (p-task-type = {&btpr-type-autofree} and 
                  (  (num-entries (buf-all_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-proc = ""
                      ) 
                  or (p-for-proc <> "" 
                      and num-entries (buf-all_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                      and entry (4, buf-all_BatchProcess.CharKey_Three, {&delim-key}) = p-for-proc
                      )
                   )
                 )
               )
      on error undo, return error
      :
        if buf-all_BatchProcess.BatchProcess# <> buf_BatchProcess.BatchProcess# then do:
          delete buf-all_BatchProcess.
        end.
      end.
    end.
    assign
      v-process    = "":U
      v-chg-manual = false
    .

    for each buf-all_BatchProcess exclusive-lock
       where buf-all_BatchProcess.BP_Status   = {&btpr-normal}
         and buf-all_BatchProcess.BP_Type     = p-task-type
         and buf-all_BatchProcess.CharKey_One = string( buf_db.db-num )
    on error undo, return error
    :
      if buf-all_BatchProcess.CharKey_Two <> "auto":U then do:
        if v-chg-manual = false then do:
          if not available buf_BatchProcess then do:
            create buf_BatchProcess .
            buffer-copy buf-all_BatchProcess to buf_BatchProcess
              assign
                buf_BatchProcess.BatchProcess# = next-value (s-btpr, {&db-name_schema})
                buf_BatchProcess.CharKey_Two   = "auto":U
              .
          end.
          if buf-all_BatchProcess.CharKey_Two = "manual":U
            or
            ( buf-all_BatchProcess.BP_ExecSysDate < buf_BatchProcess.BP_ExecSysDate
              or ( buf-all_BatchProcess.BP_ExecSysDate = buf_BatchProcess.BP_ExecSysDate
                  and buf-all_BatchProcess.BP_ExecSysTimeInt < buf_BatchProcess.BP_ExecSysTimeInt
                )
            )
          then do:
            buffer-copy buf-all_BatchProcess except BatchProcess# CharKey_Two to buf_BatchProcess .
            assign
              v-process  = buf-all_BatchProcess.CharKey_Two
              v-new-date = buf-all_BatchProcess.BP_ExecSysDate
              v-new-time = buf-all_BatchProcess.BP_ExecSysTime
              v-user-id  = buf-all_BatchProcess.User_ID
            .
            if buf-all_BatchProcess.CharKey_Two = "manual":U then do:
              assign
                v-chg-manual = true
              .
            end.
          end.
        end.
        delete buf-all_BatchProcess.
      end.
    end.

    if v-process <> "":U then do:
      run write-to-log( substitute( "Следующий сеанс &1 &2 после &3 &4 (изменил &5) (&6)"
                                    ,v-str
                                    ,buf_db.db-num
                                    ,v-new-time
                                    ,string( v-new-date , "99.99.9999" )
                                    ,v-user-id
                                    ,v-process
                                  )
                      ) .
    end.

    find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status         = {&btpr-normal}
        and buf_BatchProcess.BP_Type           = p-task-type
        and buf_BatchProcess.CharKey_One       = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two       = "auto":U
        and ( buf_BatchProcess.BP_ExecSysDate < v-today
              or (buf_BatchProcess.BP_ExecSysDate = v-today
                  and buf_BatchProcess.BP_ExecSysTimeInt < v-time
                )
            )
        and (p-task-type <> {&btpr-type-autooxml} or 
              (p-task-type = {&btpr-type-autooxml} and 
                (  (num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-extsys = ""
                    ) 
                or (p-for-extsys <> "" 
                    and num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                    and entry (4, buf_BatchProcess.CharKey_Three, {&delim-key}) = p-for-extsys
                    )
                 )
               )
             )
        and (p-task-type <> {&btpr-type-autofree} or 
              (p-task-type = {&btpr-type-autofree} and 
                (  (num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-proc = ""
                    ) 
                or (p-for-proc <> "" 
                    and num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                    and entry (4, buf_BatchProcess.CharKey_Three, {&delim-key}) = p-for-proc
                    )
                 )
               )
             )
      no-error
    .
    if available buf_BatchProcess then do:
       if p-list-db = "":U then do:
        assign
          p-list-db  = string( buf_db.db-num )
          p-list-key = buf_BatchProcess.CharKey_Three
        .
      end.
      else do:
        assign
          p-list-db  = p-list-db + {&comma-char} + string( buf_db.db-num )
          p-list-key = p-list-key + {&delim-nws} + buf_BatchProcess.CharKey_Three
        .
      end.
       
    end.
     for each buf_BatchProcess no-lock
         where buf_BatchProcess.BP_Status         = {&btpr-normal}
           and buf_BatchProcess.BP_Type           = p-task-type
           and buf_BatchProcess.CharKey_One       = string( buf_db.db-num )
           and buf_BatchProcess.CharKey_Two       = "auto":U
           and ( buf_BatchProcess.BP_ExecSysDate > v-today
                 or (buf_BatchProcess.BP_ExecSysDate = v-today
                     and buf_BatchProcess.BP_ExecSysTimeInt > v-time
                   )
               )
           and (p-task-type <> {&btpr-type-autooxml} or 
                 (p-task-type = {&btpr-type-autooxml} and 
                   (  (num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-extsys = ""
                       ) 
                   or (p-for-extsys <> "" 
                       and num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                       and entry (4, buf_BatchProcess.CharKey_Three, {&delim-key}) = p-for-extsys
                       )
                    )
                  )
                )
           and (p-task-type <> {&btpr-type-autofree} or 
                 (p-task-type = {&btpr-type-autofree} and 
                   (  (num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) <= 3 and p-for-proc = ""
                       ) 
                   or (p-for-proc <> "" 
                       and num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) > 3 
                       and entry (4, buf_BatchProcess.CharKey_Three, {&delim-key}) = p-for-proc
                       )
                    )
                  )
                )
     :
        if vWaitNextRunTime
        then do:
           create tt-BatchProcess.
           buffer-copy buf_BatchProcess to tt-BatchProcess .
        end.
        if p-list-db = "":U then do:
        assign
          p-list-db-all  = string( buf_db.db-num )
          p-list-key-all = buf_BatchProcess.CharKey_Three
        .
      end.
      else do:
        assign
          p-list-db-all  = p-list-db-all  + {&comma-char} + string( buf_db.db-num )
          p-list-key-all = p-list-key-all + {&delim-nws} + buf_BatchProcess.CharKey_Three
        .
      end.
     end.
     
  end.
  run gbl/delatrlb.p .
end.

/* $Workfile$ end */