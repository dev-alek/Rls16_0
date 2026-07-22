define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расписание автоматических заданий".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_schedule for ub.schedule .
define buffer buf_sys-ctrl for ub.sys-ctrl .
define variable v-btpr-type   as character no-undo .
define variable v-par-val     as character no-undo .
define variable v-par-type    as character no-undo .
define variable v-log         as logical   no-undo .
define variable v-modify-task as character no-undo .
define variable v-modify-btpr as character no-undo .
define variable v-PS          as character no-undo .
define variable v-curr-db     as integer   no-undo .
FUNCTION get-free-task-name RETURNS CHARACTER
  ( input p-cre-db-num as integer, INPUT p-task-type AS character, INPUT p-task-num AS integer )  FORWARD.
DEFINE BUTTON b-add DEFAULT
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-chg DEFAULT
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-copy DEFAULT
     LABEL "Копи&я"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-del DEFAULT
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-param
     LABEL "&Параметры"
     SIZE 10 BY 1.
DEFINE VARIABLE v-cre-db-num AS INTEGER FORMAT "->>>>9":U INITIAL 0
     LABEL "Расписание для БД"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "0"
     DROP-DOWN-LIST
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-task-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 12
     DROP-DOWN-LIST
     SIZE 40.3 BY 1 NO-UNDO.
DEFINE QUERY br-schedule FOR
      buf_schedule SCROLLING.
DEFINE BROWSE br-schedule
  QUERY br-schedule DISPLAY
      buf_schedule.active format "+/-"
buf_schedule.db-num-char format "x(255)"
buf_schedule.task-year
buf_schedule.task-month format "x(2)"
buf_schedule.task-day column-label "Число"
buf_schedule.task-weekday column-label "Дни недели" format "x(13)"
buf_schedule.task-hour column-label "Часы" format "x(72)"
buf_schedule.task-minute column-label "Минуты" format "x(183)"
buf_schedule.task-num column-label "N задачи" format ">>>>>>>>>9"
get-free-task-name(buf_schedule.cre-db-num, buf_schedule.task-type, buf_schedule.task-num) @ v-ps column-label "Примечание" format "x(40)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.43.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-add AT ROW 1 COL 11
     b-chg AT ROW 1 COL 21
     b-copy AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     bt-param AT ROW 1 COL 51
     b-help AT ROW 1 COL 71
     v-cre-db-num AT ROW 2.5 COL 2.5
     v-task-type AT ROW 2.5 COL 32.5 NO-LABEL
     br-schedule AT ROW 3.8 COL 1
     SPACE(0.00) SKIP(0.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Расписание"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  define variable v-recid as recid   no-undo.
  define variable v-mod   as logical no-undo .
  define buffer buf-check_db for ub.db .
  find first buf-check_db share-lock
    where buf-check_db.db-num = v-cre-db-num
    .
  if v-cre-db-num = v-curr-db
    or ( v-cre-db-num <> v-curr-db
         and v-curr-db = 0
         and ( buf-check_db.db-key = "":U
               or buf-check_db.db-key = ?
             )
       )
  then do:
    assign
      v-recid = ?
    .
    run adm/sch-edit.w
      ( input parparentproc
      ,input 'ДОБАВЛЕНИЕ':U
      ,input v-cre-db-num
      ,input v-btpr-type
      ,input-output v-recid
      ,output v-mod
      ) no-error.
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Не удалось создать строку расписания!"
        view-as alert-box error.
      return no-apply.
    end.
    if v-mod = true then do:
      if v-curr-db = v-cre-db-num then do:
        run add-modify-task in this-procedure.
      end.
      OPEN QUERY br-schedule FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type .
      reposition br-schedule to recid v-recid no-error.
    end.
    if v-btpr-type = 'is_PM':U
    then do :
      apply "choose" to bt-param IN FRAME Dialog-Frame .
    end .
  end.
  else do:
    message
      substitute( "Новую строку расписания можно создавать только для текущей БД" ) skip
      substitute( "или в ГБД для невыгруженной БД (т.е. БД у которой нет ключа)") skip
      view-as alert-box error .
  end.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  define variable v-recid as recid   no-undo.
  define variable v-mod   as logical no-undo .
  if not available buf_schedule then do:
    message vss-workfile vss-revision vss-description skip
      "Не выбрана строка расписания!"
      view-as alert-box error.
    return no-apply.
  end.
  assign
    v-recid = recid( buf_schedule )
  .
  run adm/sch-edit.w
    ( input parparentproc
     ,input 'ИЗМЕНЕНИЕ':U
     ,input v-cre-db-num
     ,input v-btpr-type
     ,input-output v-recid
     ,output v-mod
    ) no-error.
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
      "Не удалось изменить строку расписания!"
      view-as alert-box error.
    return no-apply.
  end.
  if v-mod = true then do:
    if v-curr-db = v-cre-db-num then do:
      run add-modify-task in this-procedure.
    end.
    OPEN QUERY br-schedule FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type .
    reposition br-schedule to recid v-recid no-error.
  end.
END.
ON CHOOSE OF b-copy IN FRAME Dialog-Frame
DO:
  define variable v-recid as recid   no-undo.
  define variable v-mod   as logical no-undo .
  if not available buf_schedule then do:
    message vss-workfile vss-revision vss-description skip
      "Не выбрана строка расписания!"
      view-as alert-box error.
    return no-apply.
  end.
  assign
    v-recid = recid( buf_schedule )
  .
  run adm/sch-edit.w
    ( input parparentproc
     ,input 'КОПИРОВАНИЕ':U
     ,input v-cre-db-num
     ,input v-btpr-type
     ,input-output v-recid
     ,output v-mod
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Не удалось скопировать строку расписания!") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply.
  end.
  if v-mod = true then do:
    if v-curr-db = v-cre-db-num then do:
      run add-modify-task in this-procedure.
    end.
    OPEN QUERY br-schedule FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type .
    reposition br-schedule to recid v-recid no-error.
  end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  define variable v-log as logical no-undo .
  if not available buf_schedule then do:
    message vss-workfile vss-revision vss-description skip
      "Не выбрана строка расписания!"
      view-as alert-box error.
    return no-apply.
  end.
  assign
    v-log = false
  .
  message "Вы действительно хотите удалить строку расписания?"
    view-as alert-box question buttons yes-no update v-log.
  if v-log = false
  then do:
    return no-apply.
  end.
  else do:
    run adm/schedul3.p (  input parparentproc
                         ,input recid( buf_schedule )
                         ,input no
                        ) no-error.
    if error-status:error then do:
      undo, return no-apply.
    end.
    if v-curr-db = v-cre-db-num then do:
      run add-modify-task in this-procedure.
    end.
    OPEN QUERY br-schedule FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type .
  end.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  define variable v-ind           as integer   no-undo .
  define variable v-num-entries   as integer   no-undo .
  define variable v-loc-btpr-type as character no-undo .
  define variable v-loc-btpr-task as character no-undo .
  define variable v-not-change    as character no-undo .
  if v-modify-btpr <> "":U then do:
    message
      "Были произведены изменения расписания для задач:" skip
      v-modify-task skip
      "Вы хотите переформировать время выполнения этих задач в соответствии с новым расписанием?"
      view-as alert-box question buttons yes-no update v-log.
    assign
      v-not-change = "":U
    .
    if v-log = true then do:
      assign
        v-num-entries = num-entries( v-modify-btpr )
      .
      do v-ind = 1 to v-num-entries:
        assign
          v-loc-btpr-type = entry( v-ind, v-modify-btpr )
          v-loc-btpr-task = entry( v-ind, v-modify-task )
        .
        run delete-btpr in this-procedure
          ( input        v-loc-btpr-type
           ,input        v-loc-btpr-task
           ,input-output v-not-change
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при удалении времени очередного сеанса." skip
            return-value skip
            error-status :get-message(1)
            view-as alert-box error .
          return no-apply.
        end.
      end.
      if v-not-change = "":U then do:
        message
          "Время очередного(ых) сеанса(ов) будет обновлено в течении минуты," skip
          "если соответствующие сеансы активны."
          view-as alert-box information.
      end.
      else do:
        message
          substitute( "Время сеансов &1 не изменено т.к. оно задано вручную", v-not-change ) skip
          "Время остальных очередных сеансов будет обновлено в течении минуты," skip
          "если соответствующие сеансы активны."
          view-as alert-box information.
      end.
    end.
  end.
END.
ON CHOOSE OF bt-param IN FRAME Dialog-Frame
DO:
  define variable v-cancel as logical no-undo.
  define variable v-free-id as character no-undo .
  if not available buf_schedule then return no-apply.
  define buffer buf_schedule-attr for ub.schedule-attr.
  case v-task-type:
    when 'autonws':U then do:
    end.
    when 'mercury':U then do:
    end.
    when 'hddtest':U then do:
    end.
    when 'is_motp':U then do:
    end.
    when 'is_diadoc':U then do:
    end.
    when 'is_PM':U then do:
      run adm/isPM-shdp.w
        (input  buf_schedule.cre-db-num
        ,input  buf_schedule.task-type
        ,input  buf_schedule.task-num
        ,output v-cancel
        ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when 'autoarh':U then do:
      run adm/arc-shdp.w
        (input  buf_schedule.cre-db-num
        ,input  buf_schedule.task-type
        ,input  buf_schedule.task-num
        ,output v-cancel
        ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when 'autoexp':U then do:
      run bge/bge-shdp.w (
            input parparentproc
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , output v-cancel
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when 'autogcd':U then do:
      run str/gcd-shdp.w (
            input parparentproc
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , output v-cancel
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when 'autosale':U then do:
      run str/sal-shdp.w (
            input parparentproc
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , output v-cancel
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when 'autosuz':U then do:
      if buf_schedule.cre-db-num <>  g#db-num
      and g#db-num <> 0 then do:
        message
        "Невозможно менять/просматривать параметры расписания в чужой УБД"
        view-as alert-box .
        undo, return no-apply.
      end.
      run str/suz-shdp.w (
            input parparentproc
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , output v-cancel
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when 'autocbnk':U then do:
      define variable v-params        as character    no-undo.
      define variable v-object-list        as character    no-undo.
      define variable v-doc-type-list      as character    no-undo.
      define variable v-hsch-list          as character    no-undo.
      define variable v-csch-list          as character    no-undo.
      define variable v-date-list          as character    no-undo.
      run bge/clb-shdp.w (
            input parparentproc
          , input 0
          , input 'shd':U
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , input ?
          , output v-cancel
          , output v-params
          , output v-object-list
          , output v-doc-type-list
          , output v-date-list
          , output v-hsch-list
          , output v-csch-list
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when 'autofree':U then do:
      run schedule-attr-get-free-id  in this-procedure (
                                                         input buf_schedule.cre-db-num
                                                        ,input buf_schedule.task-type
                                                        ,input buf_schedule.task-num
                                                        ,output v-free-id) no-error .
      if error-status:error then do:
        message
        "Невозможно получить название  произвольного задания по строке расписания"
        view-as alert-box error .
        undo, return no-apply.
      end.
      run adm/freeshdp.w (
            input parparentproc
          , input 0
          , input '':U
          , input 0
          , input 'shd':U
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , input ?
          , input-output v-free-id
          , output v-cancel
          , output v-params
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
        "НЕТ ОБРАБОТКИ АТРИБУТА" v-task-type
        view-as alert-box error.
      return no-apply.
    end.
  end case.
END.
ON VALUE-CHANGED OF v-cre-db-num IN FRAME Dialog-Frame
DO:
  assign
    v-cre-db-num
  .
  OPEN QUERY br-schedule FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type .
END.
ON VALUE-CHANGED OF v-task-type IN FRAME Dialog-Frame
DO:
  assign
    v-task-type
    v-btpr-type = v-task-type
  .
  case v-task-type:
       when 'autonws':U
    or when 'autooxml':U
    or when 'mercury':U
    or when 'hddtest':U
    or when 'is_motp':U
    or when 'is_diadoc':U
    then do:
      disable bt-param with frame Dialog-Frame .
    end.
       when 'autogcd':U
    or when 'autoarh':U
    or when 'autoexp':U
    or when 'autosale':U
    or when 'autosuz':U
    or when 'autocbnk':U
    or when 'autofree':U
    or when 'is_PM':U
    then do:
      enable bt-param with frame Dialog-Frame .
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
        "НЕТ ОБРАБОТКИ АТРИБУТА" v-task-type
        view-as alert-box error.
      return no-apply.
    end.
  end case.
  OPEN QUERY br-schedule FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type .
END.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-schedule :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define buffer buf_db for ub.db .
  for each buf_db no-lock
    where buf_db.db-num > 0
  on error undo, return error return-value
  :
    v-cre-db-num:add-last( string( buf_db.db-num ) ).
  end.
  find first buf_sys-ctrl no-lock .
  assign
    v-curr-db    = buf_sys-ctrl.db-num
    v-cre-db-num = v-curr-db
    v-task-type:list-item-pairs = 'Обмен новостями':U + chr(44) + 'autonws':U + chr(44) +
                                   'Расчет архивов':U + chr(44) + 'autoarh':U + chr(44) +
                                   'Прием информации с касс':U + chr(44) + 'autogcd':U + chr(44) +
                                   'Работа с документами продажи':U + chr(44) + 'autosale':U + chr(44) +
                                   'Запуск отчетов':U + chr(44)  + 'autosuz':U + chr(44) +
                                   'Эксп/имп в КЛИЕНТ-БАНК':U + chr(44)  + 'autocbnk':U + chr(44) +
                                   'Произвольные задания':U + chr(44)  + 'autofree':U + chr(44) +
                                   'Меркурий':U + chr(44)  + 'mercury':U + chr(44) +
                                   'Мониторинг HDD':U + chr(44)  + 'hddtest':U + chr(44) +
                                   'ИС МОТП':U + chr(44)  + 'is_motp':U + chr(44) +
                                   'ИС Диадок':U + chr(44)  + 'is_diadoc':U + chr(44) +
                                   'Президентский мониторинг':U + chr(44)  + 'is_PM':U
    v-task-type   = 'autonws':U
    v-btpr-type   = 'autonws':U
    v-modify-task = "":U
    v-modify-btpr = "":U
    buf_schedule.db-num-char:resizable in browse br-schedule = yes
    buf_schedule.db-num-char:width = 5
    buf_schedule.task-weekday:resizable in browse br-schedule = yes
    buf_schedule.task-weekday:width = 10
    buf_schedule.task-hour:resizable in browse br-schedule = yes
    buf_schedule.task-hour:width = 15
    buf_schedule.task-minute:resizable in browse br-schedule = yes
    buf_schedule.task-minute:width = 15
    v-PS:resizable in browse br-schedule = yes
    v-PS:width = 40
  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-bge'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-par-val
  ,output v-par-type
  ) no-error .
   if error-status:error
     or v-par-type <> "L":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка чтения конфигурационного параметра is-bge!"
      view-as alert-box error.
    return error .
  end.
  if v-par-val = "yes" then do:
    assign
      v-log = v-task-type:add-last( 'Экспорт':U , 'autoexp':U  ).
    .
  end.
  assign
    v-log = v-task-type:add-last( 'OpenXML':U , 'autooxml':U  ).
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE add-modify-task :
  if lookup( v-btpr-type, v-modify-btpr ) = 0 then do:
    if v-modify-btpr <> "":U then do:
      assign
        v-modify-btpr = v-modify-btpr + ",":U
        v-modify-task = v-modify-task + ",":U
      .
    end.
    assign
      v-modify-btpr = v-modify-btpr + v-btpr-type
      v-modify-task = v-modify-task + '"':U + v-task-type + '"':U
    .
  end.
END PROCEDURE.
PROCEDURE delete-btpr :
  define input        parameter p-btpr-type  as character no-undo .
  define input        parameter p-btpr-task  as character no-undo .
  define input-output parameter p-not-change as character no-undo .
  do
  on error undo, return error
  :
    define variable v-str    as character no-undo .
    define buffer buf_BatchProcess for ub.BatchProcess .
    assign
      v-str = "":U
    .
    for each buf_BatchProcess exclusive-lock
      where buf_BatchProcess.BP_Status = 'N':U
        and buf_BatchProcess.BP_Type   = p-btpr-type
    on error undo, return error
    :
      if buf_BatchProcess.Key#_One = 1 then do:
        if v-str = "":U then do:
          assign
            v-str = substitute( "&1 для БД: &2", p-btpr-task, buf_BatchProcess.CharKey_One )
          .
        end.
        else do:
          assign
            v-str = v-str + substitute( ",&1", buf_BatchProcess.CharKey_One )
          .
        end.
      end.
      else do:
        delete buf_BatchProcess.
      end.
      if v-str <> "":U then do:
        if p-not-change = "":U then do:
          assign
            p-not-change = v-str
          .
        end.
        else do:
          assign
            p-not-change = p-not-change + chr(44) + v-str
          .
        end.
      end.
    end.
  end.
  return.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-cre-db-num v-task-type
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-add b-chg b-copy b-del b-help v-cre-db-num v-task-type
         br-schedule
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-schedule FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type .
END PROCEDURE.
FUNCTION get-free-task-name RETURNS CHARACTER
  ( input p-cre-db-num as integer, INPUT p-task-type AS character, INPUT p-task-num AS integer ) :
define variable v-dop as character no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
IF p-task-type <> 'autofree':U THEN
  RETURN "".
run schedule-attr-value in this-procedure (
                                             input  p-cre-db-num
                                            ,input  p-task-type
                                            ,input  p-task-num
                                            ,input  ('schd-free-id':U + chr(4))
                                            ,output v-value
                                            ,output v-type ) no-error .
if error-status:error then return chr(63).
assign
v-dop = entry(1, v-value, chr(4) )
no-error .
if error-status:error then do:
  return chr(63).
end.
return v-dop.
END FUNCTION.
