/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа со строками расписани

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/03
Author: Dmitry Ukhanov
Creation date: 03/22/03

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/lastdate.i }


define temp-table curr-task no-undo
  field db-num      as character column-label "БД" format "X(5)"
  field db-num-char as character column-label "БД" format "X(5)"
  field task-num    as integer   column-label "N задачи" format ">>>>>>>9"
  field task-type   as character
  field cre-db-num    as integer
  field task-date   as date      column-label "Дата"  format "99.99.9999"
  field task-time   as integer   column-label "Время"  /* format "HH:MM:SS" */
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

procedure trans-task : /* преобразование строк расписания к виду дата, время */

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
          /* для создания запаса по времени в 10 сек */
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
          ,input 99999  /* (максимальное значение db.db-num) */
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
end procedure. /* trans-task */

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
end procedure. /* next-task-year */

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
end procedure. /* next-task-month */

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
end procedure. /* next-task-day */

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
        /* Это на случай, если перескочим через границу суток */
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
end procedure. /* next-task-hour */

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
      /* Это на случай, если перескочим через границу часа */
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
end procedure. /* next-task-minute */

/* $Workfile$ end */