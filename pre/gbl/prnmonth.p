block-level on error undo, throw.
define input  parameter p-month as integer   no-undo .
define input  parameter p-year  as integer   no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: prnmonth.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/prnmonth.p $":U .
def var vss-description as character no-undo init "Печать календаря на один месяц".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable v-month-name   as character no-undo .
define variable v-month-offset as integer   no-undo .
define variable v-ind       as integer   no-undo .
define variable v-row       as integer   no-undo .
define variable v-last-day  as integer   no-undo .
define variable v-day-label as integer   no-undo extent 42 .
define variable v-day-row   as integer   no-undo .
define variable v-day-col   as integer   no-undo .
define stream PrnLibStream .
do
on error undo, return error return-value
:
  run gbl/monthnam.p
    (input  p-month
    ,output v-month-name
    ).
  run gbl/lastday.p
    (input  date(p-month, 1, p-year)
    ,output v-last-day
    ).
  assign
    v-month-offset = (weekday(date(p-month, 1, p-year)) + 5) mod 7
  .
  do v-ind = 1 to v-last-day
  :
    assign
      v-day-label[v-ind + v-month-offset] = v-ind
    .
  end.
  output stream PrnLibStream to value('prnmonth.txt':u) .
  put stream PrnLibStream unformatted
    substitute("Календарь на &1 &2 года", v-month-name, p-year)
    chr(10) .
  put stream PrnLibStream unformatted
    ":-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:"
    chr(10) .
  put stream PrnLibStream unformatted
    ": Понедельник             : Вторник                 : Среда                   : Четверг                 : Пятница                 : Суббота                 : Воскресенье             :"
    chr(10) .
  put stream PrnLibStream unformatted
    ":-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:"
    chr(10) .
  do v-day-row = 0 to 5
  :
    do v-row = 1 to 7
    :
      do v-day-col = 1 to 7
      :
        assign
          v-ind = v-day-row * 7 + v-day-col
        .
        if v-day-label[v-ind] <> 0
        then do:
          case v-row
          :
            when 1
            then do:
              put stream PrnLibStream unformatted
                ": " + substring(string(v-day-label[v-ind], ">9") + fill(" ", 24), 1, 24)
                .
            end.
            when 7
            then do:
              put stream PrnLibStream unformatted
                ":" + fill("-", 25)
                .
            end.
            otherwise do:
              put stream PrnLibStream unformatted
                ":" + fill(" ", 25)
                .
            end.
          end.
        end.
        else do:
          if  v-row = 7
          and v-ind + 7 <= 42
          and v-day-label[v-ind + 7] <> 0
          then do:
            put stream PrnLibStream unformatted
              ":" + fill("-", 25)
              .
          end.
          else do:
            put stream PrnLibStream unformatted
              fill(" ", 26)
              .
          end.
        end.
        if (v-ind modulo 7 = 0
        and v-day-label[v-ind] <> 0
          )
        or (v-ind modulo 7 <> 0
        and v-day-label[v-ind] <> 0
        and v-ind + 1 <= 42
        and v-day-label[v-ind + 1] = 0
          )
        then do:
          put stream PrnLibStream unformatted
            ":"
            .
        end.
        if v-ind modulo 7 = 0
        then do:
          if  v-ind = 42
          and v-row = 7
          then do:
          end.
          else do:
            put stream PrnLibStream unformatted
              chr(10) .
          end.
        end.
      end.
    end.
  end.
  output stream PrnLibStream close .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  run gbl/prnfilen.w
    (input  substitute("Календарь на &1 &2 года"
                      ,v-month-name
                      ,p-year
                      )
    ,input  8
    ,input  'prnmonth.txt':u
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .
end.
