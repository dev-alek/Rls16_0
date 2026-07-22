DEFINE TEMP-TABLE tt_schedule NO-UNDO LIKE ub.schedule.
define input        parameter parparentproc as widget-handle no-undo .
define input        parameter p-action     as   character              no-undo .
define input        parameter p-cre-db-num like ub.schedule.cre-db-num no-undo .
define input        parameter p-task-type  like ub.schedule.task-type  no-undo .
define input-output parameter p-recid      as   recid                  no-undo .
define output       parameter p-modify     as   logical                no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование строки рассписания".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE LastDate:
    def input parameter in-date as date no-undo.
    def output parameter LastDate as date no-undo.
    LastDate = ((DATE(MONTH(in-date),28,YEAR(in-date)) + 4) - DAY(DATE(MONTH(in-date),28,YEAR(in-date)) + 4)).
END PROCEDURE.
define temp-table curr-task no-undo
  field db-num      as character column-label "БД" format "X(5)"
  field db-num-char as character column-label "БД" format "X(5)"
  field task-num    as integer   column-label "N задачи" format ">>>>>>>9"
  field task-type   as character
  field cre-db-num    as integer
  field task-date   as date      column-label "Дата"  format "99.99.9999"
  field task-time   as integer   column-label "Время"
  field task-free-id  as character column-label "ID произвольного задания"
  index pi is unique primary
    task-type
    db-num
    task-num
  index pii
    task-type
    db-num
    task-date
    task-time
.
define temp-table tt-weekday no-undo
  field weekday as integer
  index pi is unique primary
    weekday ascending
.
define temp-table tt-hour no-undo
  field hour as integer
  index pi is unique primary
    hour ascending
.
define temp-table tt-minute no-undo
  field minute as integer
  index pi is unique primary
    minute ascending
.
define temp-table tt-db no-undo
  field db-num as integer
  index pi is unique primary
    db-num ascending
.
procedure trans-task :
  define input parameter p-task-type as character no-undo .
  do
  on error undo, return error
  :
    define variable v-curr-weekday  as integer   no-undo .
    define variable v-today         as date      no-undo .
    define variable v-curr-time     as integer   no-undo .
    define variable v-curr-time-str as character no-undo .
    define variable v-curr-hour     as integer   no-undo .
    define variable v-curr-minute   as integer   no-undo .
    define variable v-curr-sec      as integer   no-undo .
    define variable v-task-date     as date      no-undo .
    define variable v-task-time     as integer   no-undo .
    define variable v-last-date     as date      no-undo .
    define variable v-num-entries   as integer   no-undo .
    define variable v-ind           as integer   no-undo .
    define variable v-set-task      as logical   no-undo .
    define variable v-task-time-h   as integer   no-undo .
    define variable v-first-hour    as integer   no-undo .
    define variable v-task-time-m   as integer   no-undo .
    define variable v-first-minute  as integer   no-undo .
    define variable v-create-task   as logical   no-undo .
    define buffer buf_schedule for ub.schedule .
    define buffer buf_db       for ub.db .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    block_sch:
    for each buf_schedule no-lock
      where buf_schedule.cre-db-num = buf_sys-ctrl.db-num
        and buf_schedule.task-type  = p-task-type
        and buf_schedule.active     = TRUE
    on error undo, return error
    :
      assign
        v-today         = today
        v-curr-time     = time
        v-curr-time-str = string( time, "HH:MM:SS":U )
        v-curr-hour     = integer( entry( 1, v-curr-time-str, ":":U ) )
        v-curr-minute   = integer( entry( 2, v-curr-time-str, ":":U ) )
        v-curr-sec      = integer( entry( 3, v-curr-time-str, ":":U ) )
        v-task-date     = v-today
        v-task-time     = v-curr-time
      .
      if trim( buf_schedule.task-weekday ) <> "*":U then do:
        for each tt-weekday
        on error undo, return error return-value
        :
          delete tt-weekday.
        end.
        run gbl/prcs-lst.p
          ( input  buf_schedule.task-weekday
           ,input  1
           ,input  7
           ,input  false
           ,input (buffer tt-weekday:handle)
           ,input "weekday":U
          ) no-error .
        find first tt-weekday no-lock
          where tt-weekday.weekday >= weekday( v-task-date ) - 1
          no-error .
        if available tt-weekday then do:
          assign
            v-task-date = v-task-date + tt-weekday.weekday - weekday( v-task-date ) + 1
          .
        end.
        else do:
          for first tt-weekday no-lock
            by tt-weekday.weekday
          on error undo, return error return-value
          :
            assign
              v-task-date = v-task-date + 7 + tt-weekday.weekday - weekday( v-task-date + 7 ) + 1
            .
          end.
        end.
        if v-task-date < v-today then do:
          next block_sch.
        end.
      end.
      else do:
        if trim( buf_schedule.task-year ) <> "*":U then do:
          assign
            v-task-date = date( month( v-task-date )
                                ,day( v-task-date )
                                ,integer( buf_schedule.task-year )
                              )
          .
          if v-task-date < v-today then do:
            next block_sch.
          end.
        end.
        if trim( buf_schedule.task-month ) <> "*":U then do:
          assign
            v-task-date = date( integer( buf_schedule.task-month )
                                ,day( v-task-date )
                                ,year( v-task-date )
                              )
          .
          if v-task-date < v-today then do:
            run next-task-year ( input recid( buf_schedule )
                                ,input-output v-task-date
                              ) no-error.
            if error-status :error then do:
              next block_sch.
            end.
          end.
        end.
        if trim( buf_schedule.task-day ) <> "*":U then do:
          run lastdate in this-procedure
            (input  v-task-date
            ,output v-last-date
            ) no-error .
          if error-status :error then do:
            next block_sch.
          end.
          if integer( buf_schedule.task-day ) > day( v-last-date ) then do:
            next block_sch.
          end.
          assign
            v-task-date = date( month( v-task-date )
                               ,integer( buf_schedule.task-day )
                               ,year( v-task-date )
                              )
          .
          if v-task-date < v-today then do:
            run next-task-month in this-procedure
              ( input recid( buf_schedule )
               ,input-output v-task-date
              ) no-error.
            if error-status :error then do:
              next block_sch.
            end.
          end.
        end.
      end.
      if trim( buf_schedule.task-hour ) <> "*":U then do:
        for each tt-hour
        on error undo, return error return-value
        :
          delete tt-hour.
        end.
        run gbl/prcs-lst.p
          ( input  buf_schedule.task-hour
           ,input  0
           ,input  24
           ,input  false
           ,input (buffer tt-hour:handle)
           ,input "hour":U
          ) no-error .
        for first tt-hour no-lock
          by tt-hour.hour
        on error undo, return error return-value
        :
          assign
            v-first-hour = tt-hour.hour
          .
        end.
        if v-task-date > v-today then do:
          assign
            v-task-time = v-task-time + ( v-first-hour - v-curr-hour ) * 3600
          .
        end.
        else do:
          if v-task-date = v-today then do:
            assign
              v-task-time-h = v-task-time
              v-set-task    = false
            .
            block_hour:
            for each tt-hour no-lock
              by tt-hour.hour
            on error undo, return error return-value
            :
              assign
                v-task-time-h = v-task-time + ( tt-hour.hour - v-curr-hour ) * 3600
              .
              if v-task-time-h >= v-curr-time then do:
                assign
                  v-task-time = v-task-time-h
                  v-set-task  = true
                .
                leave block_hour.
              end.
            end.
            if v-task-time < v-curr-time
              or v-set-task = false
            then do:
              assign
                v-task-time = v-task-time + ( v-first-hour - v-curr-hour ) * 3600
              .
              run next-task-day ( input recid( buf_schedule )
                                 ,input-output v-task-date
                                ) no-error.
              if error-status :error then do:
                next block_sch.
              end.
            end.
          end.
        end.
      end.
      else do:
        if v-task-date > v-today then do:
          assign
            v-task-time = v-task-time + ( 0 - v-curr-hour ) * 3600
          .
        end.
      end.
      if trim( buf_schedule.task-minute ) <> "*":U then do:
        for each tt-minute
        on error undo, return error return-value
        :
          delete tt-minute.
        end.
        run gbl/prcs-lst.p
          ( input buf_schedule.task-minute
           ,input 0
           ,input 60
           ,input false
           ,input (buffer tt-minute:handle)
           ,input "minute":U
          ) no-error .
        for first tt-minute no-lock
          by tt-minute.minute
        on error undo, return error return-value
        :
          assign
            v-first-minute = tt-minute.minute
          .
        end.
        if v-task-date > v-today then do:
          assign
            v-task-time = v-task-time + ( v-first-minute - v-curr-minute ) * 60
          .
        end.
        else do:
          if v-task-date = v-today then do:
            assign
              v-task-time-m = v-task-time
              v-set-task    = false
            .
            block_minute:
            for each tt-minute no-lock
              by tt-minute.minute
            on error undo, return error return-value
            :
              assign
                v-task-time-m = v-task-time + ( tt-minute.minute - v-curr-minute ) * 60
              .
              if v-task-time-m >= v-curr-time then do:
                assign
                  v-task-time = v-task-time-m
                  v-set-task  = true
                .
                leave block_minute.
              end.
            end.
            if v-task-time < v-curr-time
              or v-set-task = false
            then do:
              assign
                v-task-time = v-task-time + ( v-first-minute - v-curr-minute ) * 60
              .
              run next-task-hour ( input recid( buf_schedule )
                                  ,input-output v-task-date
                                  ,input-output v-task-time
                                ) no-error.
              if error-status :error then do:
                next block_sch.
              end.
            end.
          end.
        end.
      end.
      else do:
        assign
          v-task-time-h = integer( entry( 1, string( v-task-time, "HH:MM:SS":U ), ":":U ) )
        .
        if v-task-date > v-today
          or ( v-task-date = v-today
               and v-task-time-h > v-curr-hour
             )
        then do:
          assign
            v-task-time = v-task-time + ( 0 - v-curr-minute ) * 60
          .
        end.
      end.
      if trim( buf_schedule.task-second ) <> "*":U then do:
        assign
          v-task-time = v-task-time - v-curr-sec + integer( buf_schedule.task-second )
        .
        if v-task-date = v-today
          and v-task-time + 10 <= v-curr-time
        then do:
          run next-task-minute ( input recid( buf_schedule )
                                ,input-output v-task-date
                                ,input-output v-task-time
                               ) no-error.
          if error-status :error then do:
            next block_sch.
          end.
        end.
      end.
      if v-task-date = v-today
        and v-task-time <= v-curr-time
      then do:
        run next-task-minute ( input recid( buf_schedule )
                              ,input-output v-task-date
                              ,input-output v-task-time
                              ) no-error.
        if error-status :error then do:
          next block_sch.
        end.
      end.
      if buf_schedule.db-num-char <> "*":U then do:
        for each tt-db
        on error undo, return error return-value
        :
          delete tt-db.
        end.
        run gbl/prcs-lst.p
          ( input buf_schedule.db-num-char
          ,input 0
          ,input 99999
          ,input false
          ,input (buffer tt-db:handle)
          ,input "db-num":U
          ) no-error .
      end.
      for each buf_db no-lock
      on error undo, return error return-value
      :
        assign
          v-create-task = true
        .
        if buf_schedule.db-num-char <> "*":U then do:
          find first tt-db no-lock
            where tt-db.db-num = buf_db.db-num
            no-error .
          if not available tt-db then do:
            assign
              v-create-task = false
            .
          end.
        end.
        if v-create-task = true then do:
          create curr-task .
          assign
            curr-task.db-num      = string( buf_db.db-num )
            curr-task.db-num-char = buf_schedule.db-num-char
            curr-task.task-num    = buf_schedule.task-num
            curr-task.task-type   = buf_schedule.task-type
            curr-task.cre-db-num    = buf_schedule.cre-db-num
            curr-task.task-date   = v-task-date
            curr-task.task-time   = v-task-time
          .
        end.
      end.
    end.
    for each tt-weekday
    on error undo, return error return-value
    :
      delete tt-weekday.
    end.
    for each tt-hour
    on error undo, return error return-value
    :
      delete tt-hour.
    end.
    for each tt-minute
    on error undo, return error return-value
    :
      delete tt-minute.
    end.
    for each tt-db
    on error undo, return error return-value
    :
      delete tt-db.
    end.
  end.
end procedure.
procedure next-task-year :
  define input        parameter p-recid-sch as recid no-undo .
  define input-output parameter p-task-date as date no-undo.
  do
  on error undo, return error
  :
    define buffer buf_schedule for ub.schedule .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-year ) <> "*":U then do:
      assign
        p-task-date = ?
      .
      return error.
    end.
    else do:
      if month( p-task-date ) = 2
        and day( p-task-date ) = 29
      then do:
        if trim( buf_schedule.task-day ) <> "*":U then do:
          assign
            p-task-date = date( month( p-task-date )
                                ,day( p-task-date )
                                ,year( p-task-date ) + 4
                              )
          .
        end.
        else do:
          assign
            p-task-date = date( month( p-task-date )
                                ,28
                                ,year( p-task-date ) + 1
                              )
          .
        end.
      end.
      else do:
        assign
          p-task-date = date( month( p-task-date )
                              ,day( p-task-date )
                              ,year( p-task-date ) + 1
                            )
        .
      end.
    end.
  end.
end procedure.
procedure next-task-month :
  define input        parameter p-recid-sch as recid no-undo .
  define input-output parameter p-task-date as date no-undo.
  do
  on error undo, return error
  :
    define variable v-date      as date no-undo .
    define variable v-last-date as date no-undo .
    define buffer buf_schedule for ub.schedule .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-month ) <> "*":U then do:
      run next-task-year ( input p-recid-sch
                          ,input-output p-task-date
                         ) no-error.
      if error-status :error then do:
        assign
          p-task-date = ?
        .
        return error.
      end.
    end.
    else do:
      if month( p-task-date ) = 12 then do:
        assign
          p-task-date = date( 1
                             ,day( p-task-date )
                             ,year( p-task-date )
                             )
        .
        run next-task-year ( input p-recid-sch
                            ,input-output p-task-date
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
          .
          return error.
        end.
      end.
      else do:
        assign
          v-date = date( month( p-task-date ) + 1
                        ,1
                        ,year( p-task-date )
                       )
        .
        run lastdate in this-procedure
          ( input  v-date
           ,output v-last-date
          ) no-error .
        if error-status :error then do:
          assign
            p-task-date = ?
          .
          return error.
        end.
        if day( p-task-date ) > day( v-last-date ) then do:
          if trim( buf_schedule.task-day ) <> "*":U then do:
            do while true :
              assign
                v-date = date( month( v-date ) + 1
                              ,1
                              ,year( v-date )
                            )
              .
              run lastdate in this-procedure
                ( input  v-date
                 ,output v-date
                ) no-error .
              if error-status :error then do:
                assign
                  p-task-date = ?
                .
                return error.
              end.
              if day( p-task-date ) = day( v-date ) then do:
                assign
                  p-task-date = v-date
                .
                leave.
              end.
            end.
          end.
          else do:
            assign
              p-task-date = v-last-date
            .
          end.
        end.
        else do:
          assign
            p-task-date = date( month( p-task-date ) + 1
                               ,day( p-task-date )
                               ,year( p-task-date )
                              )
          .
        end.
      end.
    end.
  end.
end procedure.
procedure next-task-day :
  define input        parameter p-recid-sch as recid no-undo .
  define input-output parameter p-task-date as date no-undo.
  do
  on error undo, return error
  :
    define buffer buf_schedule for ub.schedule .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-weekday ) <> "*":U then do:
      find first tt-weekday no-lock
        where tt-weekday.weekday > weekday( p-task-date ) - 1
        no-error .
      if available tt-weekday then do:
        assign
          p-task-date = p-task-date + tt-weekday.weekday - weekday( p-task-date ) + 1
        .
      end.
      else do:
        for first tt-weekday no-lock
          by tt-weekday.weekday
        on error undo, return error return-value
        :
          assign
            p-task-date = p-task-date + 7 + tt-weekday.weekday - weekday( p-task-date + 7 ) + 1
          .
        end.
      end.
    end.
    else do:
      if trim( buf_schedule.task-day ) <> "*":U then do:
        run next-task-month ( input p-recid-sch
                            ,input-output p-task-date
                            ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
          .
          return error.
        end.
      end.
      else do:
        if month( p-task-date ) <> month( p-task-date + 1 ) then do:
          assign
            p-task-date = date( month( p-task-date )
                                ,1
                                ,year( p-task-date )
                              )
          .
          run next-task-month ( input p-recid-sch
                              ,input-output p-task-date
                              ) no-error.
          if error-status :error then do:
            assign
              p-task-date = ?
            .
            return error.
          end.
        end.
        else do:
          assign
            p-task-date = p-task-date + 1
          .
        end.
      end.
    end.
  end.
end procedure.
procedure next-task-hour :
  define input        parameter p-recid-sch as recid   no-undo .
  define input-output parameter p-task-date as date    no-undo.
  define input-output parameter p-task-time as integer no-undo.
  do
  on error undo, return error
  :
    define buffer buf_schedule for ub.schedule .
    define variable v-task-hour as integer   no-undo .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-hour ) <> "*":U then do:
      assign
        v-task-hour = integer( entry( 1, string( p-task-time, "HH:MM:SS":U ), ":":U ) )
      .
      find first tt-hour no-lock
        where tt-hour.hour > v-task-hour
        no-error .
      if available tt-hour then do:
        assign
          p-task-time = p-task-time + ( tt-hour.hour - v-task-hour ) * 3600
        .
      end.
      else do:
        for first tt-hour no-lock
          by tt-hour.hour
        on error undo, return error return-value
        :
          assign
            p-task-time = p-task-time + ( tt-hour.hour - v-task-hour ) * 3600
          .
        end.
        run next-task-day ( input p-recid-sch
                          ,input-output p-task-date
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
            p-task-time = ?
          .
          return error.
        end.
      end.
    end.
    else do:
      if p-task-time + 3600 >= 86400 then do:
        run next-task-day ( input p-recid-sch
                           ,input-output p-task-date
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
            p-task-time = ?
          .
          return error.
        end.
        assign
          p-task-time = p-task-time + 3600 - 86400
        .
      end.
      else do:
        assign
          p-task-time = p-task-time + 3600
        .
      end.
    end.
  end.
end procedure.
procedure next-task-minute :
  define input        parameter p-recid-sch as recid   no-undo .
  define input-output parameter p-task-date as date    no-undo.
  define input-output parameter p-task-time as integer no-undo.
  do
  on error undo, return error
  :
    define buffer buf_schedule for ub.schedule .
    define variable v-task-minute as integer   no-undo .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-minute ) <> "*":U then do:
      assign
        v-task-minute = integer( entry( 2, string( p-task-time, "HH:MM:SS":U ), ":":U ) )
      .
      find first tt-minute no-lock
        where tt-minute.minute > v-task-minute
        no-error .
      if available tt-minute then do:
        assign
          p-task-time = p-task-time + ( tt-minute.minute - v-task-minute ) * 60
        .
      end.
      else do:
        for first tt-minute no-lock
          by tt-minute.minute
        on error undo, return error return-value
        :
          assign
            p-task-time = p-task-time + ( tt-minute.minute - v-task-minute ) * 60
          .
        end.
        run next-task-hour ( input p-recid-sch
                            ,input-output p-task-date
                            ,input-output p-task-time
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
            p-task-time = ?
          .
          return error.
        end.
      end.
    end.
    else do:
      if truncate( p-task-time / 3600, 0 ) <> truncate( ( p-task-time + 60 ) / 3600, 0 ) then do:
        run next-task-hour ( input p-recid-sch
                            ,input-output p-task-date
                            ,input-output p-task-time
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
            p-task-time = ?
          .
          return error.
        end.
        assign
          p-task-time = p-task-time + 60 - 3600
        .
      end.
      else do:
        assign
          p-task-time = p-task-time + 60
        .
      end.
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-schedule-free no-undo
field free-id as character
field free-task-name as character
field proc-run-name as character
field proc-param-edit-name as character
field conf-param as character
field is-gbd as logical
field is-ubd as logical
field enable-concurrent-0 as logical
field enable-concurrent-db as logical
field other-info as character
field enc-key as character
field is-rum as logical
index pi is unique primary
free-id.
procedure schedule-attr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-obj-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-oss-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-gds-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-doc-type-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-date-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-filter':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-filter-2':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schd-free-id':U then do:     assign     p-label = "Идентификатор произвольной задачи"     p-type = 'C':U      p-format = "X(30)"     p-label = "Идентификатор произвольной задачи"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure schedule-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-obj-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-oss-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-gds-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-doc-type-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-date-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-filter':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-filter-2':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schd-free-id':U then do:     assign     p-tooltip = "Идентификатор произвольной задачи"     p-label = "Идентификатор произвольной задачи" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure schedule-attr-value :
do
on error undo, return error return-value
:
define input parameter  p-cre-db-num as integer    no-undo.
define input parameter  p-task-type  as character  no-undo.
define input parameter  p-task-num   as integer    no-undo.
define input parameter  p-code       as character  no-undo.
define output parameter p-value      as character  no-undo.
define output parameter p-type       as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_schedule-attr for ub.schedule-attr.
    run schedule-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    if p-code begins ('schd-free-id':U + chr(4))
    and entry(2, p-code, chr(4)) = '':U then do:
      find first buf_schedule-attr no-lock
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  begins p-code
      no-error .
    end.
    else do:
      find first buf_schedule-attr no-lock
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  = p-code
      no-error .
    end.
    if available buf_schedule-attr
    then do:
        assign
            p-value = buf_schedule-attr.attr-value
        .
    end.
    else do:
      if p-code begins ('schd-free-id':U + chr(4) ) then do:
         run schedule-attr-get-free-props in this-procedure (input entry(2, p-code, chr(4)), output p-value).
      end.
      else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
    end.
end.
end procedure.
procedure schedule-attr-write :
do
on error undo, return error
:
define input parameter p-cre-db-num  as integer   no-undo.
define input parameter p-task-type   as character no-undo.
define input parameter p-task-num    as integer   no-undo.
define input parameter p-code        as character no-undo.
define input parameter p-value       as character no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_schedule-attr for ub.schedule-attr .
    run schedule-attr-name in this-procedure (
          input  p-code
        , output v-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        create buf_schedule-attr.
        assign
          buf_schedule-attr.cre-db-num = p-cre-db-num
          buf_schedule-attr.task-type  = p-task-type
          buf_schedule-attr.task-num   = p-task-num
          buf_schedule-attr.attr-code  = p-code
          buf_schedule-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_schedule-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure schedule-attr-delete :
do
on error undo, return error
:
define input  parameter p-cre-db-num  as integer   no-undo.
define input  parameter p-task-type   as character no-undo.
define input  parameter p-task-num    as integer   no-undo.
define input  parameter p-code        as character no-undo.
define output parameter p-deleted     as logical   no-undo.
    define buffer buf_schedule-attr for ub.schedule-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run schedule-attr-name in this-procedure (
          input p-code
        , output v-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
        delete buf_schedule-attr.
        assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure schedule-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-news = false.   end.
            when 'schedule-obj-list':U then do:     assign     p-news = false.   end.
            when 'schedule-oss-list':U then do:     assign     p-news = false.   end.
            when 'schedule-gds-list':U then do:     assign     p-news = false.   end.
            when 'schedule-doc-type-list':U then do:     assign     p-news = false.   end.
            when 'schedule-date-list':U then do:     assign     p-news = false.   end.
            when 'schedule-filter':U then do:     assign     p-news = false.   end.
            when 'schedule-filter-2':U then do:     assign     p-news = false.   end.
            when 'schd-free-id':U then do:     assign     p-news = false.   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure schedule-attr-extract-logical :
do
on error undo, return error
:
define input  parameter p-parameter-number   as integer      no-undo.
define input  parameter p-parameter-list     as character    no-undo.
define output parameter p-parameter-value   as logical      no-undo.
    if num-entries( p-parameter-list ) > p-parameter-number - 1
    then do:
        assign
            p-parameter-value   = ( entry( p-parameter-number, p-parameter-list ) = "yes" )
        .
    end.
    else do:
        assign
            p-parameter-value   = no
        .
    end.
end.
end procedure.
procedure schedule-attr-get-free-id :
do
on error undo, return error return-value
:
  define input  parameter p-cre-db-num  as integer   no-undo.
  define input  parameter p-task-type   as character no-undo.
  define input  parameter p-task-num    as integer   no-undo.
  define output parameter p-free-id     as character no-undo.
  define buffer buf_schedule-attr for ub.schedule-attr.
  find first buf_schedule-attr no-lock
      where buf_schedule-attr.cre-db-num = p-cre-db-num
        and buf_schedule-attr.task-type  = p-task-type
        and buf_schedule-attr.task-num   = p-task-num
        and buf_schedule-attr.attr-code  begins  ('schd-free-id':U + chr(4))
  no-error .
  if available buf_schedule-attr then
  assign
  p-free-id = entry(2, buf_schedule-attr.attr-code, chr(4))
  no-error
  .
end.
end procedure.
procedure schedule-attr-get-free-props :
  define input parameter p-free-id as character no-undo .
  define output parameter p-value as character no-undo .
  define buffer buf_temp-schedule-free for temp-schedule-free.
  do
  on error undo, return error return-value
  :
    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free then do:
      assign
      p-value = buf_temp-schedule-free.free-task-name       + chr(4) +
                buf_temp-schedule-free.proc-run-name        + chr(4) +
                buf_temp-schedule-free.proc-param-edit-name + chr(4) +
                buf_temp-schedule-free.conf-param           + chr(4) +
                string(buf_temp-schedule-free.is-gbd)       + chr(4) +
                string(buf_temp-schedule-free.is-ubd)       + chr(4) +
                string(buf_temp-schedule-free.enable-concurrent-0) + chr(4) +
                string(buf_temp-schedule-free.enable-concurrent-db) + chr(4) +
                buf_temp-schedule-free.other-info
      .
    end.
    else do:
     if p-free-id <> '':U then return error substitute("&1 &2 &3&4Неопределены процедуры для работы с произвольной задачей по расписанию&4" +
                           "id произвольной задачи - &5"
                           ,vss-workfile
                           ,vss-revision
                           ,vss-description
                           ,chr(10)
                           ,p-free-id).
    end.
  end.
end procedure.
procedure schedule-attr-is-rum-free-id :
define input parameter p-free-id as character no-undo .
define output parameter p-is-rum as logical no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
do
on error undo, return error
:
    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free
    and buf_temp-schedule-free.is-rum
    then do:
      p-is-rum = yes.
    end.
end.
end procedure.
procedure schedule-attr-fill-free-props :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
define variable v-answer as logical no-undo .
  do
  on error undo, return error substitute("&1 &2 &3&4&5&4"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        ,error-status:get-message(1) )
  :
    run gbl/filename.p (
                    input 'cmp/shd-free.d'
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) .
    input from value(v-full-path).
    repeat :
      create buf_temp-schedule-free.
      import buf_temp-schedule-free.
    END.
    input close.
    _ff:
    for each buf_temp-schedule-free :
      if buf_temp-schedule-free.free-id = '':U then do:
         delete buf_temp-schedule-free.
         next _ff.
       end.
       run schedule-attr-check-enc in this-procedure (
                                                    input  buf_temp-schedule-free.free-id
                                                   ,input  (buf_temp-schedule-free.proc-run-name +
                                                            buf_temp-schedule-free.proc-param-edit-name +
                                                            buf_temp-schedule-free.conf-param +
                                                            string(buf_temp-schedule-free.is-gbd) +
                                                            string(buf_temp-schedule-free.is-ubd) +
                                                            string(buf_temp-schedule-free.enable-concurrent-0) +
                                                            string(buf_temp-schedule-free.enable-concurrent-db) +
                                                            string(buf_temp-schedule-free.other-info)
                                                            )
                                                    ,input  buf_temp-schedule-free.enc-key
                                                    ,output v-answer    ) no-error .
       if error-status:error
       or not v-answer then delete buf_temp-schedule-free.
     end.
  end.
end procedure.
Function schedule-attr-reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.
procedure schedule-attr-check-enc.
  define input  parameter p-free-id   as character no-undo .
  define input  parameter p-value     as character no-undo .
  define input  parameter p-enc-value as character no-undo .
  define output parameter p-answer    as logical   no-undo .
  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .
  assign
  tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value)) .
  .
  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.
end.
procedure schedule-attr-conf-enc.
  define input  parameter p-free-id   as character no-undo .
  define input  parameter p-value     as character no-undo .
  define output parameter p-enc-value as character no-undo .
  define variable tmp         as character no-undo .
  assign
    tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value))
  .
  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output p-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure schedule-attr-pswd-enc :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer buf_schedule     for ub.schedule .
define buffer buf-src_schedule for ub.schedule .
define buffer buf_sys-ctrl     for ub.sys-ctrl.
define variable v-free-id         as character no-undo .
define variable v-cancel          as logical   no-undo .
define variable v-params          as character no-undo .
DEFINE VARIABLE v-enable-db-num   as logical   no-undo.
define variable v-free-task-name  as character no-undo .
define variable is-ubd            as logical   no-undo init yes.
define variable is-gbd            as logical   no-undo init yes.
define variable v-free-attr-value as character no-undo .
define temp-table tt-val no-undo
  field t-val as integer
  index pi as unique primary t-val
  .
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE QUERY sch-frame FOR
      tt_schedule SCROLLING.
DEFINE FRAME sch-frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 24
     tt_schedule.active AT ROW 2.25 COL 15.5
          VIEW-AS TOGGLE-BOX
          SIZE 8.75 BY 1
     tt_schedule.db-num-char AT ROW 3.5 COL 13 COLON-ALIGNED FORMAT "X(256)"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
     tt_schedule.task-year AT ROW 5.25 COL 13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     tt_schedule.task-month AT ROW 5.25 COL 27 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt_schedule.task-day AT ROW 5.25 COL 38.5 COLON-ALIGNED
          LABEL "Число"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt_schedule.task-weekday AT ROW 6.5 COL 13 COLON-ALIGNED HELP
          ""
          LABEL "Дни недели" FORMAT "X(13)"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tt_schedule.task-hour AT ROW 8 COL 13 COLON-ALIGNED
          LABEL "Часы" FORMAT "X(75)"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
     tt_schedule.task-minute AT ROW 9.25 COL 13 COLON-ALIGNED
          LABEL "Минуты" FORMAT "X(183)"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
     SPACE(0.87) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка расписания"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME sch-frame:SCROLLABLE       = FALSE
       FRAME sch-frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME sch-frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON RETURN OF tt_schedule.active IN FRAME sch-frame
DO:
  apply "entry" to tt_schedule.task-year in frame sch-frame.
  return no-apply.
END.
ON CHOOSE OF b-exit IN FRAME sch-frame
DO:
  assign
    tt_schedule.db-num-char
    tt_schedule.active
    tt_schedule.task-year
    tt_schedule.task-month
    tt_schedule.task-day
    tt_schedule.task-weekday
    tt_schedule.task-hour
    tt_schedule.task-minute
  .
  run proc-save in this-procedure
    no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON LEAVE OF tt_schedule.db-num-char IN FRAME sch-frame
DO:
  if tt_schedule.db-num-char:screen-value = "?":U then assign tt_schedule.db-num-char:screen-value = "*":U .
END.
ON RETURN OF tt_schedule.db-num-char IN FRAME sch-frame
DO:
  apply "entry" to tt_schedule.active in frame sch-frame.
  return no-apply.
END.
ON LEAVE OF tt_schedule.task-day IN FRAME sch-frame
DO:
  if tt_schedule.task-day:screen-value = "?":U then assign tt_schedule.task-day:screen-value = "*":U .
END.
ON RETURN OF tt_schedule.task-day IN FRAME sch-frame
DO:
  apply "entry" to tt_schedule.task-weekday in frame sch-frame.
  return no-apply.
END.
ON LEAVE OF tt_schedule.task-hour IN FRAME sch-frame
DO:
  if tt_schedule.task-hour:screen-value = "?":U then assign tt_schedule.task-hour:screen-value = "*":U .
END.
ON RETURN OF tt_schedule.task-hour IN FRAME sch-frame
DO:
  apply "entry" to tt_schedule.task-minute in frame sch-frame.
  return no-apply.
END.
ON LEAVE OF tt_schedule.task-minute IN FRAME sch-frame
DO:
  if tt_schedule.task-minute:screen-value = "?":U then assign tt_schedule.task-minute:screen-value = "*":U .
END.
ON RETURN OF tt_schedule.task-minute IN FRAME sch-frame
DO:
  apply "choose" to b-exit in frame sch-frame.
  return no-apply.
END.
ON LEAVE OF tt_schedule.task-month IN FRAME sch-frame
DO:
  if tt_schedule.task-month:screen-value = "?":U then assign tt_schedule.task-month:screen-value = "*":U .
END.
ON RETURN OF tt_schedule.task-month IN FRAME sch-frame
DO:
  apply "entry" to tt_schedule.task-day in frame sch-frame.
  return no-apply.
END.
ON LEAVE OF tt_schedule.task-weekday IN FRAME sch-frame
DO:
  if tt_schedule.task-weekday:screen-value = "?":U then assign tt_schedule.task-weekday:screen-value = "*":U .
END.
ON RETURN OF tt_schedule.task-weekday IN FRAME sch-frame
DO:
  apply "entry" to tt_schedule.task-hour in frame sch-frame.
  return no-apply.
END.
ON LEAVE OF tt_schedule.task-year IN FRAME sch-frame
DO:
  if tt_schedule.task-year:screen-value = "?":U then assign tt_schedule.task-year:screen-value = "*":U .
END.
ON RETURN OF tt_schedule.task-year IN FRAME sch-frame
DO:
  apply "entry" to tt_schedule.task-month in frame sch-frame.
  return no-apply.
END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame sch-frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame sch-frame
do:
  apply "help":u to frame sch-frame .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame sch-frame:width - 0.3
                fh            = frame sch-frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME sch-frame:PARENT eq ?
THEN FRAME sch-frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable v-task-num like ub.schedule.task-num no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  assign
    v-task-num = 0
    v-free-id  = "":U
  .
  case p-action :
    when 'ИЗМЕНЕНИЕ':U then do:
      find first buf_schedule exclusive-lock
        where recid( buf_schedule ) = p-recid
        no-error
      .
      if not available buf_schedule then do:
        message vss-workfile vss-revision vss-description skip
          "Не найдена строка расписания для редактирования!"
          view-as alert-box error.
        return error .
      end.
      else do:
        assign
          v-task-num = buf_schedule.task-num
        .
      end.
    end.
    when 'КОПИРОВАНИЕ':U then do:
      find first buf-src_schedule exclusive-lock
        where recid( buf-src_schedule ) = p-recid
        no-error
      .
      if not available buf-src_schedule then do:
        message vss-workfile vss-revision vss-description skip
          "Не найдена строка расписания для копирования!"
          view-as alert-box error.
        return error .
      end.
      else do:
        assign
          v-task-num = buf-src_schedule.task-num
        .
      end.
    end.
  end case.
  if ( not available buf_schedule
       and p-action = 'ИЗМЕНЕНИЕ':U
     )
     or ( not available buf-src_schedule
          and p-action = 'КОПИРОВАНИЕ':U
        )
  then do:
  end.
  if p-task-type = 'autofree':U then do:
    if p-action = 'КОПИРОВАНИЕ':U then do:
      run schedule-attr-get-free-id  in this-procedure
        ( input p-cre-db-num
         ,input p-task-type
         ,input v-task-num
         ,output v-free-id
        ) no-error .
      if error-status:error then do:
        undo, return error substitute( "&1. Невозможно получить название  произвольного задания по строке расписания &3&2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ) .
      end.
    end.
    if v-free-id = "":U then do:
      run adm/freeshdp.w
        ( input parparentproc
        ,input 0
        ,input '':U
        ,input 0
        ,input p-action
        ,input p-cre-db-num
        ,input p-task-type
        ,input v-task-num
        ,input '':U
        ,input-output v-free-id
        ,output v-cancel
        ,output v-params
      ) no-error.
      if error-status :error then do:
        undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ) .
      end.
      if v-free-id = '':U
        or ( v-cancel
            and p-action <> 'ИЗМЕНЕНИЕ':U
          )
      then do:
        undo, return error return-value .
      end.
    end.
  end.
  run fill-temp-table in this-procedure no-error.
  if error-status:error then do:
    message
    substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    view-as alert-box .
    undo, return error.
  end.
  assign
    p-modify = false
  .
  frame sch-frame:title = substitute( "Строка расписания для БД &1", p-cre-db-num ).
  RUN Myenable.
  WAIT-FOR GO OF FRAME sch-frame.
END.
RUN disable_UI.
delete tt_schedule .
PROCEDURE disable_UI :
  HIDE FRAME sch-frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY sch-frame FOR EACH tt_schedule SHARE-LOCK.
  GET FIRST sch-frame.
  IF AVAILABLE tt_schedule THEN
    DISPLAY tt_schedule.active tt_schedule.db-num-char tt_schedule.task-year
          tt_schedule.task-month tt_schedule.task-day tt_schedule.task-weekday
          tt_schedule.task-hour tt_schedule.task-minute
      WITH FRAME sch-frame.
  ENABLE b-exit b-quit b-help tt_schedule.active tt_schedule.db-num-char
         tt_schedule.task-year tt_schedule.task-month tt_schedule.task-day
         tt_schedule.task-weekday tt_schedule.task-hour tt_schedule.task-minute
      WITH FRAME sch-frame.
  VIEW FRAME sch-frame.
END PROCEDURE.
PROCEDURE fill-temp-table :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-db-num-char like ub.schedule.db-num-char no-undo.
    define variable v-value       as   character               no-undo .
    define buffer buf_temp-schedule-free for temp-schedule-free.
    find first buf_sys-ctrl no-lock.
    create tt_schedule .
    if available buf_schedule then do:
      buffer-copy buf_schedule to tt_schedule .
    end.
    else do:
      if available buf-src_schedule then do:
        buffer-copy buf-src_schedule to tt_schedule .
      end.
      else do:
        assign
          tt_schedule.task-type   = p-task-type
          tt_schedule.db-num-char = "*":U
          tt_schedule.activ       = false
        .
      end.
    end.
    assign
      tt_schedule.task-second = "00"
    .
    case p-task-type:
      when  'autosale':U
      or when 'autogcd':U
      or when 'autooxml':U
      or when 'autosuz':U
      or when 'is_PM':U
      then do:
        assign
          v-db-num-char = string (p-cre-db-num)
          is-gbd = no
          v-enable-db-num = no
        .
      end.
      when 'autofree':U then do:
        run schedule-attr-get-free-props in this-procedure (input v-free-id, output v-free-attr-value).
        if v-free-attr-value <> '':u then do:
          assign
          is-gbd = (entry(buffer buf_temp-schedule-free:buffer-field("is-gbd"):position - 2, v-free-attr-value, chr(4) ) = "yes")
          is-ubd = (entry(buffer buf_temp-schedule-free:buffer-field("is-ubd"):position - 2, v-free-attr-value, chr(4) ) = "yes")
          v-free-task-name = entry(buffer buf_temp-schedule-free:buffer-field("free-task-name"):position - 2, v-free-attr-value, chr(4) )
          v-enable-db-num = no
          .
          if (is-ubd = yes
          and p-cre-db-num > 0)
          or (is-gbd = yes
          and p-cre-db-num = 0)
          then do:
            assign
            v-db-num-char = string (p-cre-db-num)
            .
          end.
          else do:
            undo, return error substitute("Задание &1 невыполнимо в БД &2", v-free-task-name, p-cre-db-num).
          end.
        end.
        else do:
          undo, return error return-value .
        end.
        if p-action = 'ИЗМЕНЕНИЕ':U then do:
          assign
            v-enable-db-num = no
          .
        end.
      end.
      otherwise do:
        assign
          v-db-num-char = "*":u
          v-enable-db-num = yes
        .
        case p-task-type:
          when 'autonws':U
          then do:
          end.
          when 'mercury':U
          then do:
          end.
          when 'hddtest':U
          then do:
          end.
          when 'is_motp':U
          then do:
          end.
          when 'is_diadoc':U
          then do:
          end.
          otherwise do:
            if p-action = 'ИЗМЕНЕНИЕ':U
              or p-action = 'КОПИРОВАНИЕ':U
            then do:
              assign
                v-enable-db-num = yes
              .
            end.
          end.
        end case.
      end.
    end case.
    if p-action = 'ДОБАВЛЕНИЕ':U then do:
      assign
        tt_schedule.db-num-char = v-db-num-char.
      .
    end.
  end.
END PROCEDURE.
PROCEDURE MyENable :
IF AVAILABLE tt_schedule THEN
DISPLAY
tt_schedule.db-num-char
tt_schedule.active
tt_schedule.task-year
tt_schedule.task-hour
tt_schedule.task-month
tt_schedule.task-minute
tt_schedule.task-day
tt_schedule.task-weekday
WITH FRAME sch-frame.
ENABLE
b-exit
b-quit
b-help
tt_schedule.db-num-char WHEN v-enable-db-num
tt_schedule.active
tt_schedule.task-year
tt_schedule.task-hour
tt_schedule.task-month
tt_schedule.task-minute
tt_schedule.task-day
tt_schedule.task-weekday
WITH FRAME sch-frame.
if p-task-type = 'autofree':U then do:
  assign
  frame sch-frame:title = v-free-task-name.
end.
VIEW FRAME sch-frame.
END PROCEDURE.
PROCEDURE proc-save :
do
on error undo, return error return-value
:
  define buffer buf-chk_db            for ub.db .
  define buffer buf-src_schedule-attr for ub.schedule-attr .
  define buffer buf_schedule-attr     for ub.schedule-attr .
  define variable v-tmp-int as integer   no-undo .
  define variable v-today   as date      no-undo .
  define variable v-time    as integer   no-undo .
  define variable v-equal   as logical   no-undo .
  define variable v-hour-str    as character no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-ind         as integer   no-undo .
  define variable v-hour-int    as integer   no-undo .
  define variable v-hour-beg    as integer   no-undo .
  define variable v-hour-end    as integer   no-undo .
  define variable v-shift-num as integer no-undo .
  define variable v-shift-date as date no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  run cur-time ( output v-today
              ,output v-time
            ).
  assign
    tt_schedule.db-num-char  = trim( tt_schedule.db-num-char )
    tt_schedule.task-year    = trim( tt_schedule.task-year )
    tt_schedule.task-month   = trim( tt_schedule.task-month )
    tt_schedule.task-day     = trim( tt_schedule.task-day )
    tt_schedule.task-weekday = trim( tt_schedule.task-weekday )
    tt_schedule.task-hour    = trim( tt_schedule.task-hour )
    tt_schedule.task-minute  = trim( tt_schedule.task-minute )
  .
  if tt_schedule.db-num-char <> "*":U then do:
    for each tt-val
    on error undo, return error return-value
    :
      delete tt-val.
    end.
    run gbl/prcs-lst.p
      ( input tt_schedule.db-num-char
       ,input 0
       ,input 99999
       ,input true
       ,input (buffer tt-val:handle)
       ,input "t-val":U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        'Номер БД может быть только числовым или "*"!'
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      apply "entry" to tt_schedule.db-num-char in frame sch-frame.
      undo, return error .
    end.
    for each tt-val no-lock
    on error undo, return error return-value
    :
      find first buf-chk_db no-lock
        where buf-chk_db.db-num = tt-val.t-val
        no-error
      .
      if not available buf-chk_db then do:
        message vss-workfile vss-revision vss-description skip
          "Нет БД с номером" tt-val.t-val
          view-as alert-box error.
        apply "entry" to tt_schedule.db-num-char in frame sch-frame.
        undo, return error .
      end.
      if p-task-type = 'autofree':U
      and buf-chk_db.db-num <> 0
      and is-ubd = no
      then do:
        message
        substitute("Для произвольного задания &1 можно задать расписание ТОЛЬКО для ГБД", v-free-task-name)
        view-as alert-box error .
        undo, return error.
      end.
      if p-task-type = 'autogcd':U then do:
        if buf-chk_db.db-num <> buf_sys-ctrl.db-num then do:
          message
          "Для автоматического приема информации с касс можно задать расписание ТОЛЬКО для текущей БД"
          view-as alert-box error .
          undo, return error.
        end.
      end.
      if p-task-type = 'autosale':U then do:
      find first buf_sys-ctrl no-lock.
      if buf-chk_db.db-num <> buf_sys-ctrl.db-num then do:
          message
          "Для автоматической обработки документов продаж можно задать расписание ТОЛЬКО для текущей БД"
          view-as alert-box error .
          undo, return error.
        end.
      end.
      if p-task-type = 'autocbnk':U then do:
      find first buf_sys-ctrl no-lock.
      if buf-chk_db.db-num <> 0 then do:
          message
          "Для автоматической обработки документов продаж можно задать расписание ТОЛЬКО для ГБД"
          view-as alert-box error .
          undo, return error.
        end.
      end.
    end.
    if p-task-type = 'autooxml':U then do:
      if buf-chk_db.db-num <> buf_sys-ctrl.db-num then do:
        message
        "Для работы системы OpenXML можно задать расписание ТОЛЬКО для текущей БД"
        view-as alert-box error .
        undo, return error.
      end.
    end.
  end.
  else do:
    if p-task-type = 'autogcd':U
    or p-task-type = 'autosale':U
    or p-task-type = 'autooxml':U
    then do:
      message
      "Для данного типа задач можно задать расписание только по текущей БД!"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  if tt_schedule.task-weekday <> "*":U then do:
    for each tt-val
    on error undo, return error return-value
    :
      delete tt-val.
    end.
    run gbl/prcs-lst.p
      ( input tt_schedule.task-weekday
       ,input 1
       ,input 7
       ,input true
       ,input (buffer tt-val:handle)
       ,input "t-val":U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        'Дни недели могут иметь только числовое значение в интервале от 1 до 7 или "*"!' skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      apply "entry" to tt_schedule.task-weekday in frame sch-frame.
      undo, return error .
    end.
  end.
  if tt_schedule.task-weekday <> "*":U
    and ( tt_schedule.task-year <> "*":U
         or tt_schedule.task-month <> "*":U
         or tt_schedule.task-day <> "*":U
        )
  then do:
    message vss-workfile vss-revision vss-description skip
      'Заданы дни недели, поэтому поля "год", "месяц" и "число" должны иметь значение "*"'
      view-as alert-box error.
    apply "entry" to tt_schedule.task-year in frame sch-frame.
    undo, return error .
  end.
  if tt_schedule.task-year <> "*":U then do:
    assign
      v-tmp-int = integer( tt_schedule.task-year )
      no-error
    .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        'Год может быть только числовым или "*"!'
        view-as alert-box error.
      apply "entry" to tt_schedule.task-year in frame sch-frame.
      undo, return error .
    end.
    if year( v-today ) > integer( tt_schedule.task-year ) then do:
      message vss-workfile vss-revision vss-description skip
        "Год не может быть меньше текущего!"
        view-as alert-box error.
      apply "entry" to tt_schedule.task-year in frame sch-frame.
      undo, return error .
    end.
  end.
  if tt_schedule.task-month <> "*":U then do:
    assign
      v-tmp-int = integer( tt_schedule.task-month )
      no-error
    .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        'Месяц может быть только числовым или "*"!'
        view-as alert-box error.
      apply "entry" to tt_schedule.task-month in frame sch-frame.
      undo, return error .
    end.
    if integer( tt_schedule.task-month ) > 12
      or integer( tt_schedule.task-month ) < 1
    then do:
      message vss-workfile vss-revision vss-description skip
        "Месяц может быть только в интервале от 1 до 12 !"
        view-as alert-box error.
      apply "entry" to tt_schedule.task-month in frame sch-frame.
      undo, return error .
    end.
  end.
  if tt_schedule.task-day <> "*":U then do:
    assign
      v-tmp-int = integer( tt_schedule.task-day )
      no-error
    .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        'День месяца может быть только числовым или "*"!'
        view-as alert-box error.
      apply "entry" to tt_schedule.task-day in frame sch-frame.
      undo, return error .
    end.
    if integer( tt_schedule.task-day ) > 31
      or integer( tt_schedule.task-day ) < 1
    then do:
      message vss-workfile vss-revision vss-description skip
        "День месяца может быть только в интервале от 1 до 31 !"
        view-as alert-box error.
      apply "entry" to tt_schedule.task-day in frame sch-frame.
      undo, return error .
    end.
  end.
  if tt_schedule.task-hour <> "*":U then do:
    for each tt-val
    on error undo, return error return-value
    :
      delete tt-val.
    end.
    run gbl/prcs-lst.p
      ( input tt_schedule.task-hour
       ,input 0
       ,input 24
       ,input true
       ,input (buffer tt-val:handle)
       ,input "t-val":U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        'Часы могут иметь только числовое значение в интервале от 0 до 24 или "*"!' skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      apply "entry" to tt_schedule.task-hour in frame sch-frame.
      undo, return error .
    end.
  end.
  if tt_schedule.task-minute <> "*":U then do:
    for each tt-val
    on error undo, return error return-value
    :
      delete tt-val.
    end.
    run gbl/prcs-lst.p
      ( input tt_schedule.task-minute
       ,input 0
       ,input 60
       ,input true
       ,input (buffer tt-val:handle)
       ,input "t-val":U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        'Минуты могут иметь только числовое значение в интервале от 0 до 60 или "*"!' skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      apply "entry" to tt_schedule.task-minute in frame sch-frame.
      undo, return error .
    end.
  end.
  if not available buf_schedule then do:
    create buf_schedule.
    assign
      buf_schedule.cre-db-num = p-cre-db-num
      buf_schedule.task-type  = p-task-type
      buf_schedule.task-num   = next-value( s-task-num, ub )
    .
  end.
  buffer-compare tt_schedule TO buf_schedule save result in v-equal no-error.
  if not v-equal then do:
    buffer-copy tt_schedule except cre-db-num task-type task-num TO buf_schedule.
    assign
      p-modify = true
    .
  end.
  if p-action = 'КОПИРОВАНИЕ':U then do:
    for each buf-src_schedule-attr no-lock
      where buf-src_schedule-attr.cre-db-num  = buf-src_schedule.cre-db-num
        and buf-src_schedule-attr.task-type   = buf-src_schedule.task-type
        and buf-src_schedule-attr.task-num    = buf-src_schedule.task-num
    on error undo, return error
    :
      find first buf_schedule-attr exclusive-lock
        where buf_schedule-attr.cre-db-num = buf_schedule.cre-db-num
          and buf_schedule-attr.task-type  = buf_schedule.task-type
          and buf_schedule-attr.task-num   = buf_schedule.task-num
          and buf_schedule-attr.attr-code  = buf-src_schedule-attr.attr-code
        no-error .
      if not available buf_schedule-attr then do:
        create buf_schedule-attr .
      end.
      buffer-copy buf-src_schedule-attr to buf_schedule-attr
        assign
          buf_schedule-attr.cre-db-num = buf_schedule.cre-db-num
          buf_schedule-attr.task-type  = buf_schedule.task-type
          buf_schedule-attr.task-num   = buf_schedule.task-num
        .
    end.
  end.
  if p-task-type = 'autofree':U then do:
    run schedule-attr-write in this-procedure
      ( input buf_schedule.cre-db-num
       ,input p-task-type
       ,input buf_schedule.task-num
       ,input ('schd-free-id':U + chr(4) + v-free-id)
       ,input v-free-attr-value
      ).
  end.
  assign
    p-recid = recid( buf_schedule )
  .
  for each tt-val
  on error undo, return error return-value
  :
    delete tt-val.
  end.
  v-shift-num = 0 .
  v-shift-date = ? .
  for first buf_shift-obj
      where buf_shift-obj.obj-type = v-cntxt-obj-type
        and buf_shift-obj.obj-code = v-cntxt-obj-code
        and buf_shift-obj.status_ = 'тек':U
      use-index stts :
    assign
      v-shift-date = buf_shift-obj.shift-date
      v-shift-num  = buf_shift-obj.shift-num
    .
  end.
  if v-shift-date = ? then v-shift-date = today .
  run trg/userlog.p (
          input 'schedule'
        , input ("Изменение расписания автозаданий на объекте " +
                v-cntxt-obj-type + string(v-cntxt-obj-code) + ";" +
                buf_schedule.task-type + ";" +
                (if buf_schedule.task-type = 'autofree':U then v-free-id else "0") + ";" +
                  string(buf_schedule.task-num) + "|" +
                  (if buf_schedule.active then "1" else "0") + "|" +
                  buf_schedule.task-year + "|" +
                  buf_schedule.task-month + "|" +
                  buf_schedule.task-day + "|" +
                  buf_schedule.task-weekday + "|" +
                  buf_schedule.task-hour + "|" +
                  buf_schedule.task-minute +
                chr(3) +
                v-cntxt-obj-type + chr(6) +
                string(v-cntxt-obj-code) + chr(6) +
                string(v-shift-date) + chr(6) +
                string(v-shift-num) + chr(6) +
                buf_schedule.task-type + chr(6) +
                (if buf_schedule.task-type = 'autofree':U then v-free-id else "0") + chr(6) +
                string(buf_schedule.task-num) + chr(6) +
                (if buf_schedule.active then "1" else "0") + chr(6) +
                buf_schedule.task-year + chr(6) +
                buf_schedule.task-month + chr(6) +
                buf_schedule.task-day + chr(6) +
                buf_schedule.task-weekday + chr(6) +
                buf_schedule.task-hour + chr(6) +
                buf_schedule.task-minute + chr(6) +
                "chg" + chr(6) +
                buf_schedule.db-num-char )
        , input ?
        , input ?
        , input ""
        ) no-error.
  if error-status :error
  then do:
      message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
  end.
end.
END PROCEDURE.
