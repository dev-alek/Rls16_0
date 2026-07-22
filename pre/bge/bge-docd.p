block-level on error undo, throw.
define input parameter parparentproc    as handle               no-undo.
define input parameter p-date-from      as date       no-undo.
define input parameter p-date-to        as date       no-undo.
define input parameter p-range          as integer    no-undo.
define input parameter p-obj-list       as character  no-undo.
define input parameter p-doc-type-list  as character  no-undo.
define input parameter p-pay-code       as logical    no-undo.
define input parameter p-cst            as logical    no-undo.
define input parameter p-parts          as logical    no-undo.
define input parameter p-chk-pay-code   as logical    no-undo.
define input parameter p-pay-desk       as logical    no-undo.
define input parameter p-pay-desk-cards as logical    no-undo.
define input parameter p-deleted        as logical    no-undo.
define input parameter p-chk            as logical    no-undo.
define input parameter p-doc-rvs        as logical    no-undo.
define input parameter p-opened-docs    as logical    no-undo.
define input parameter hedt             as handle     no-undo.
define input parameter hcnt             as handle     no-undo.
define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-docd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-docd.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию документов с выводом в dbf".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-filelist-total-file-num           as integer      no-undo .
define variable v-filelist-total-dir-num            as integer      no-undo .
define variable v-filelist-main-procedure-handle    as handle       no-undo .
define variable v-filelist-main-procedure-name      as character    no-undo .
define temp-table temp-dirlist no-undo
    field dir-full-name     as character
    field dir-short-name    as character
    field need-process      as logical
    index xpk is primary unique dir-full-name
.
define temp-table temp-filelist no-undo
  field file-name        as character
  field file-name-no-ext as character
  field file-extension   as character
  field directory-name   as character
  field full-name        as character
  field dir-short-name   as character
  field need-process     as logical
  index xpk is unique primary full-name
  index xie1 directory-name file-name
  index xie2 directory-name file-name-no-ext
  index xie3 file-name
  index xie4 file-name-no-ext
  index xie5 need-process file-name
  .
define stream dir-list .
procedure filelist-get-file-num :
  define output parameter p-file-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-file-num = v-filelist-total-file-num
    .
  end.
end procedure.
procedure filelist-clear :
  do
  on error undo, return error return-value
  :
    define buffer buf_filelist for temp-filelist .
    assign
      v-filelist-total-file-num = 0
    .
    for each buf_filelist
    on error undo, return error
    :
      delete buf_filelist .
    end.
  end.
end procedure.
procedure filelist-init :
  do
  on error undo, return error
  :
    define input parameter p-dir-name       as character no-undo .
    define input parameter p-filter-ext     as logical   no-undo .
    define input parameter p-ext-list       as character no-undo .
    define input parameter p-dir-short-name as character no-undo .
    define buffer buf_temp-filelist for temp-filelist .
    if p-filter-ext = true
       and p-ext-list = ?
    or (p-filter-ext = false
       and p-ext-list <> ?
       and p-ext-list <> "":U
       )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "p-filter-ext" p-filter-ext skip
        "p-ext-list"   p-ext-list   skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_temp-filelist
      where buf_temp-filelist.directory-name = p-dir-name
    on error undo, return error return-value
    :
      delete buf_temp-filelist .
    end.
    input stream dir-list from os-dir( p-dir-name ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    define variable v-extension             as character no-undo .
    define variable v-file-name-without-ext as character no-undo .
    repeat
    on error undo, return error
    :
      import stream dir-list v-file v-path v-mask .
      if  v-mask <> ?
      and v-mask begins 'F':u
      then do:
      end.
      else do:
        next .
      end.
      if num-entries(v-file, '.':u) > 1
      then do:
        assign
          v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
          v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
        .
      end.
      else do:
        assign
          v-extension = ''
          v-file-name-without-ext = v-file
        .
      end.
      if p-filter-ext = true
      then do:
        if lookup(v-extension, p-ext-list) = 0
        then do:
          next .
        end.
      end.
      create buf_temp-filelist .
      assign
        buf_temp-filelist.file-name        = v-file
        buf_temp-filelist.directory-name   = p-dir-name
        buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
        buf_temp-filelist.file-extension   = v-extension
        buf_temp-filelist.full-name        = p-dir-name + '/':u + v-file
        buf_temp-filelist.dir-short-name   = p-dir-short-name
      .
      assign
        v-filelist-total-file-num = v-filelist-total-file-num + 1
      .
      if v-filelist-main-procedure-handle <> ?
      then do:
        run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle
          (input "file":U
          , input v-filelist-total-file-num
          , input buf_temp-filelist.full-name
          , input buf_temp-filelist.file-name
          ) no-error.
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-subdir-init" skip(1)
            skip "Ошибка при вызове процедуры вывода"
            skip "результатов сканирования каталогов."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
          undo, return error .
        end.
      end.
    end.
    input stream dir-list close .
    return.
  end.
end procedure.
procedure filelist-dirlist-init-by-list :
  do
  on error undo, return error
  :
    define input parameter p-root-dir   as character no-undo .
    define input parameter p-dir-list   as character no-undo .
    define input parameter p-filter-ext as logical   no-undo .
    define input parameter p-ext-list   as character no-undo .
    define variable v-num-appdir as integer   no-undo .
    do v-num-appdir = 1 to num-entries(p-dir-list)
    :
      define variable v-curr-dir  as character no-undo .
      assign
        v-curr-dir = entry(v-num-appdir, p-dir-list)
      .
      run filelist-init in this-procedure
        (input p-root-dir + '/':u + v-curr-dir
        ,input p-filter-ext
        ,input p-ext-list
        ,input v-curr-dir
        ) .
    end.
  end.
end procedure.
procedure filelist-dirlist-clear :
  do
  on error undo, return error
  :
    define buffer buf_temp-dirlist for temp-dirlist .
    assign
        v-filelist-total-dir-num = 0
    .
    for each buf_temp-dirlist
    on error undo, return error
    :
      delete buf_temp-dirlist .
    end.
  end.
end procedure.
procedure filelist-dirlist-subdir-init :
define input parameter p-dir-name   as character no-undo .
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    input stream dir-list from os-dir( p-dir-name ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    file-in-directory:
    repeat
    on error undo, return error
    :
        import stream dir-list
            v-file
            v-path
            v-mask
        .
        if  v-mask = ?
        or index( v-mask, 'D':u ) = 0
        or v-file = ".":U
        or v-file = "..":U
        then do:
            next file-in-directory.
        end.
        else do:
            find first buf_temp-dirlist
                 where buf_temp-dirlist.dir-full-name    = v-path
            no-error.
            if not available buf_temp-dirlist
            then do:
                create buf_temp-dirlist .
                assign
                    buf_temp-dirlist.dir-full-name    = v-path
                    buf_temp-dirlist.dir-short-name   = v-file
                    buf_temp-dirlist.need-process     = yes
                .
            end.
            assign
                v-filelist-total-dir-num = v-filelist-total-dir-num + 1
            .
            if v-filelist-main-procedure-handle <> ?
            then do:
                run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle (
                      input "dir":U
                    , input v-filelist-total-dir-num
                    , input buf_temp-dirlist.dir-full-name
                    , input buf_temp-dirlist.dir-short-name
                ) no-error.
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "filelist-dirlist-subdir-init"
                        skip(1)
                        skip "Ошибка при вызове процедуры вывода"
                        skip "результатов сканирования каталогов."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.
    end.
    input stream dir-list close .
end.
end procedure.
procedure filelist-dirlist-init :
define input parameter p-dir-name   as character no-undo .
    define variable v-file  as character no-undo.
    define variable v-path  as character no-undo.
    define variable v-mask  as character no-undo.
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    for each buf_temp-dirlist
       where buf_temp-dirlist.dir-full-name begins file-info :full-pathname
    on error undo, return error return-value
    :
        delete buf_temp-dirlist .
    end.
    create buf_temp-dirlist .
    assign
        buf_temp-dirlist.dir-full-name    = file-info :full-pathname
        buf_temp-dirlist.dir-short-name   = file-info :file-name
        buf_temp-dirlist.need-process     = yes
    .
    do
    while available buf_temp-dirlist
    on error undo, return error
    :
        run filelist-dirlist-subdir-init in this-procedure (
            input buf_temp-dirlist.dir-full-name
        ).
        assign
            buf_temp-dirlist.need-process = no
        .
        find first buf_temp-dirlist
             where buf_temp-dirlist.need-process = yes
        no-error.
    end.
end.
end procedure.
procedure filelist-set-procedure-handle :
define input parameter p-proc-handle    as handle           no-undo.
define input parameter p-proc-name      as character        no-undo.
    define variable v-signature    as character    no-undo.
do
on error undo, return error
:
    if p-proc-handle = ?
    or not valid-handle( p-proc-handle )
    or p-proc-handle :get-signature( p-proc-name ) = ""
    then do:
        assign
            v-filelist-main-procedure-handle = ?
            v-filelist-main-procedure-name   = ""
        .
        undo, return error "filelist-set-procedure-handle: Ошибка передачи handle основной процедуры или имени процедуры обработки результатов сканирования каталогов.".
    end.
    else do:
        assign
            v-signature = p-proc-handle :get-signature( p-proc-name )
        .
        if entry(   1, v-signature )    = "PROCEDURE":U
        and entry( 1, entry(  3, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  3, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  4, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  4, v-signature ), " ":U ) = "INTEGER":U
        and entry( 1, entry(  5, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  5, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  6, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  6, v-signature ), " ":U ) = "CHARACTER":U
        then do:
            assign
                v-filelist-main-procedure-handle = p-proc-handle
                v-filelist-main-procedure-name   = p-proc-name
            .
        end.
        else do:
            assign
                v-filelist-main-procedure-handle = ?
                v-filelist-main-procedure-name   = ""
            .
            undo, return error "filelist-set-procedure-handle: Ошибка задания параметров процедуры обработки результатов сканирования каталогов.".
        end.
    end.
end.
end procedure.
procedure filelist-clear-procedure-handle :
do
on error undo, return error
:
    assign
        v-filelist-main-procedure-handle = ?
        v-filelist-main-procedure-name   = ?
    .
end.
end procedure.
procedure filelist-build-by-dirlist :
    define buffer buf_temp-dirlist      for temp-dirlist.
do
for buf_temp-dirlist
on error undo, return error
:
    for each buf_temp-dirlist
    on error undo, return error
    :
        run filelist-init in this-procedure (
              input buf_temp-dirlist.dir-full-name
            , input no
            , input "":U
            , input buf_temp-dirlist.dir-short-name
        ).
    end.
end.
end procedure.
procedure filelist-check-dir-exists :
define input parameter p-dir-name   as character        no-undo.
define output parameter p-exists    as logical          no-undo.
do
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :file-type <> ?
    and substring( file-info :file-type, 1, 1 ) = "D":U
    then do:
        assign
            p-exists = yes
        .
    end.
    else do:
        assign
            p-exists = no
        .
    end.
end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-host no-undo
  field host-code like ub.store.host-code
  index xpk host-code
.
define  temp-table temp-obj no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field host-code like ub.store.host-code
  field db-num    like ub.clients.db-num
  index xpk  obj-type obj-code
  index xie1 host-code
  index xie2 db-num host-code
.
procedure init-temphost:
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .
  define buffer buf_temp-host for temp-host .
  define buffer buf_temp-obj for temp-obj .
  do
  on error undo, return error return-value
  :
    for each buf_store
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_store.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_store.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'скл':U
          and buf_clients.obj-code = buf_store.obj-code
        no-error .
      if not available buf_clients
      then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'скл':U buf_store.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'скл':U
        buf_temp-obj.obj-code  = buf_store.obj-code
        buf_temp-obj.host-code = buf_store.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
    for each buf_shop
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_shop.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_shop.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'маг':U
          and buf_clients.obj-code = buf_shop.obj-code
        no-error .
      if not available buf_clients then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'маг':U buf_shop.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'маг':U
        buf_temp-obj.obj-code  = buf_shop.obj-code
        buf_temp-obj.host-code = buf_shop.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
  end.
end.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DEF STREAM stmXMLOut.
DEF STREAM stmXMLLog.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure strtdate :
  define input  parameter p-str         as character no-undo .
  define output parameter p-value       as date      no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
do
on error undo, return error return-value
:
  define variable v-value       as date      no-undo .
  define variable v-i           as integer   no-undo .
  define variable v-num         as integer   no-undo .
  define variable v-delim       as character no-undo .
  define variable v-delim-list  as character no-undo .
  define variable v-day         as integer   no-undo .
  define variable v-month       as integer   no-undo .
  define variable v-year        as integer   no-undo .
  define variable v-day-str     as character no-undo .
  define variable v-month-str   as character no-undo .
  define variable v-year-str    as character no-undo .
  assign
    p-value       = ?
    p-data-valid  = false
  .
  if p-str = ?
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Не задана строка для преобразования. " )
    .
    return .
  end.
  if p-str = ""
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Задана пустая строка для преобразования. " )
    .
    return .
  end.
  if length(p-str)  > 10
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверная длина строки. " )
    .
    return .
  end.
  assign
    v-delim-list = '/,-,.':U
  .
  _delim:
  do v-i = 1 to num-entries( v-delim-list )
  :
    assign
      v-delim = entry( v-i , v-delim-list )
      v-num   = num-entries( p-str , v-delim )
    .
    if v-num <> 3
    then do:
      assign
        v-delim = ''
      .
    end.
    else do:
      leave _delim.
    end.
  end.
  if v-delim = ''
  then do:
    assign
      p-message = substitute( "Ошибка при преобразовании к дате. Неправильный разделитель, либо ошибочное количество разделителей. " )
    .
    return .
  end.
  assign
    v-day-str   = entry( 1, p-str , v-delim)
    v-month-str = entry( 2, p-str , v-delim)
    v-year-str  = entry( 3, p-str , v-delim)
  .
  if  length(v-day-str) > 2   or
      length(v-day-str) < 1   or
      length(v-month-str) > 2 or
      length(v-month-str) < 1 or
      (
        length(v-year-str) <> 2 and
        length(v-year-str) <> 4
      )
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неправильное количество символов числа, месяца, либо года. " )
    .
    return .
  end.
  if length( v-year-str ) = 2
  then do:
    assign
      v-year-str = substring( string( year(today) ), 1 , 2 ) + v-year-str
    .
  end.
  assign
    v-day   = integer( v-day-str )
    v-month = integer( v-month-str)
    v-year  = integer( v-year-str)
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный формат символов числа, месяца, либо года. " )
    .
    return .
  end.
  if v-day < 1  or
     v-day > 31 or
     v-month < 1 or
     v-month > 12 or
     v-year < 0   or
     v-year > 5000
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный диапозон числа, месяца, года. " )
    .
    return .
  end.
  assign
    v-value = date( v-month, v-day, v-year )
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. &1. " , error-status :get-message(1))
    .
    return .
  end.
  assign
    p-value       = v-value
    p-data-valid  = true
  .
end.
end procedure.
define variable v-bge-xml-bgecliiv      as logical  init no  no-undo.
define variable v-bge-xml-bgeclall      as logical  init no  no-undo.
define variable v-bge-xml-bgedict       as logical  init no  no-undo.
define variable v-bge-xml-bgeflold      as character         no-undo.
define variable v-bge-xml-bgefmt        as character         no-undo.
define variable v-bge-xml-shift-mode    as logical           no-undo.
define variable v-bge-xml-bgeflnm-doc   as character         no-undo.
define variable v-bge-xml-bgeflnm-day   as character         no-undo.
define variable v-bge-xml-log-file-name as character    no-undo.
define variable v-bge-xml-dbf-file-name as character    no-undo.
define variable v-bge-xml-db-num-str    as character    no-undo .
define variable v-bge-xml-static-log-file-name as character    no-undo.
define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character
    index pi is primary unique
        edt-key
.
define temp-table temp_bge-xml_goods no-undo
    field gds-code as integer
    index pi is primary unique gds-code
.
define temp-table temp_bge-xml_clients no-undo
    field obj-type as character
    field obj-code as integer
    field shift-date    as date
    field shift-num     as integer
    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bge-xml_dis-card no-undo
    field d-card as character
    index pi is primary unique
        d-card
.
define temp-table temp_doc-code no-undo
    field doc-code as character
    index pi is primary unique
        doc-code
.
define temp-table temp_del-doc-code no-undo
    field doc-code as character
    index pi is primary unique
        doc-code
.
define temp-table temp_pr-doc-num no-undo
    field doc-num as character
    index pi is primary unique
        doc-num
.
define temp-table temp_fin-doc-code no-undo
    field host-code as integer
    field fin-doc-code as integer
    index pi is primary unique
        host-code
        fin-doc-code
.
define temp-table temp_del-fin-doc-code no-undo
    field host-code as integer
    field fin-doc-code as integer
    field corr-user-db-num as integer
    field chip-num as integer
    index pi is primary unique
        host-code
        fin-doc-code
        corr-user-db-num
        chip-num
.
define temp-table temp_fin-ob no-undo
    field host-code as integer
    field fin-doc-code as character
    index pi is primary unique
        host-code
        fin-doc-code
.
define temp-table temp_del-fin-ob no-undo
    field host-code as integer
    field fin-doc-code as character
    field corr-user-db-num as integer
    field chip-num as integer
    index pi is primary unique
        host-code
        fin-doc-code
        corr-user-db-num
        chip-num
.
define temp-table temp_ord-doc-code no-undo
  field doc-code as character
index pi is primary unique
  doc-code
.
define temp-table tt-bge-xml-bgecliiv no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
index pi is primary unique
  obj-type
  obj-code
.
FUNCTION w-XMLPutParamInTag RETURNS CHAR (INPUT sParName AS CHAR, INPUT sToPlace AS CHAR,
                                          INPUT iFlagEmpty AS INTEGER).
    DEF VAR sOut AS CHAR FORMAT "X(255)" NO-UNDO.
    IF sToPlace = "" OR sToPlace = ? OR sToPlace = "0" THEN
        DO:
            IF iFlagEmpty = 0                           THEN RETURN "".
            ELSE IF iFlagEmpty = 1                      THEN RETURN sParName + "=&#034;&#034;".
            ELSE IF iFlagEmpty = 2 AND sToPlace = "0"   THEN RETURN sParName + "=&#034;0&#034;".
            ELSE IF iFlagEmpty = 3 AND sToPlace = ""    THEN RETURN sParName + "=&#034;&#034;".
            ELSE RETURN "".
        END.
    ELSE DO:
        run xmlchar-encode in this-procedure (
              input sToPlace
            , output sToPlace
        ).
        ASSIGN
            sToPlace = sParName + '="' + sToPlace + '"'
        .
        RETURN sToPlace.
    END.
END FUNCTION.
function bge-xml-date returns character
( input p-date as date )
:
  define variable v-date-str as character no-undo .
  run bge-xml-date-to-str in this-procedure ( input   p-date
                                            , output  v-date-str
                                            ) .
  return v-date-str.
end function.
function bge-xml-str-date returns character
( input p-date-str as character )
:
  define variable v-date-str as character no-undo .
  run bge-xml-date-str-to-str in this-procedure ( input   p-date-str
                                                , output  v-date-str
                                                ) .
  return v-date-str.
end function.
function bge-xml-normalize-dec returns decimal
( input p-val as decimal )
:
  return (if p-val = ? then 0 else p-val) .
end function.
PROCEDURE wp-XMLTagOpen:
DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:
    end.
    else do:
        assign
            v-out-string = substitute( "&1&2<&3&4>"
                                    , chr(10)
                                    , fill( " ":U, 4 * iTagLevel)
                                    , sTagName
                                    , ( if sParValue = "":U or sParValue = ? then "":U else " " + sParValue )
                            )
        .
        put stream stmXMLOut unformatted
            v-out-string
        .
    end.
end.
END PROCEDURE.
PROCEDURE wp-XMLTagPut:
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
  DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
  DEF INPUT PARAM iFlagEmpty AS INTEGER NO-UNDO.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        if v-bge-xml-dbf-file-name <> "":U
        then do:
            output stream stmXMLOut to value( v-bge-xml-dbf-file-name ) append.
            export stream stmXMLOut
                sTagName
                sParValue
            .
            output stream stmXMLOut close.
        end.
    end.
    else do:
        IF  iFlagEmpty = 1
        OR (iFlagEmpty = 0 AND (sParValue <> "" AND sParValue <> ?) )
        OR (iFlagEmpty = 2 AND (sParValue <> "" AND sParValue <> ? AND sParValue <> "0"))
        OR (iFlagEmpty = 3 AND (sParValue <> "" AND sParValue <> ? AND CAPS(sParValue) <> "NO"))
        THEN DO:
            run xmlchar-encode in this-procedure (
                input sParValue
                , output sParValue
            ).
            assign
                v-out-string = substitute( "&1&2<&3>&4</&3>"
                                            , chr(10)
                                            , FILL(" ", 4 * iTagLevel)
                                            , sTagName
                                            , sParValue
                            )
            .
            PUT STREAM stmXMLOut UNFORMATTED
                v-out-string
            .
        END.
    end.
end.
END PROCEDURE.
PROCEDURE wp-XMLTagClose:
DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:
    end.
    else do:
        assign
            v-out-string = substitute( "&1&2</&3>"
                                , ( if iTagLevel=0 then "":U else chr(10) )
                                , fill( " ", 4 * iTagLevel )
                                , sTagName
                        )
        .
        PUT STREAM stmXMLOut UNFORMATTED
            v-out-string
        .
    end.
end.
END PROCEDURE.
PROCEDURE wp-XMLWriteLog:
  DEF INPUT PARAMETER sFileName AS CHAR     NO-UNDO.
  DEF INPUT PARAMETER iLogLevel AS INTEGER  NO-UNDO.
  DEF INPUT PARAMETER sToWrite  AS CHAR     NO-UNDO.
define variable v-str              as character no-undo .
define variable v-error-append     as logical   no-undo .
define variable v-error-append-msg as character no-undo .
assign
  v-str = chr(10)
          + (if (iLogLevel = 0 or sToWrite = "&DLine" or sToWrite = "&Line") then "" else cur-time-string-sec() + " ")
          + (if sToWrite = "&Line" then fill("-", 80) else if sToWrite = "&DLine" then fill("=", 80) else sToWrite)
  v-str = replace(v-str, (chr(10) + chr(13)), chr(10) )
  v-str = replace(v-str, (chr(13) + chr(10)), chr(10) )
  v-str = replace(v-str, chr(10), (chr(13) + chr(10)) )
.
run bge/bge-log.p (input v-str) no-error .
if error-status:error then do:
  assign
    v-error-append     = yes
    v-error-append-msg = return-value
  .
end.
run gbl/fileapnd.p
  ( input sFileName
  , input v-str
  , input 10
  ) no-error .
if error-status:error then do:
  assign
    v-error-append     = yes
    v-error-append-msg = substitute( "&1&2&3"
                                    , v-error-append-msg
                                    , chr(10)
                                    , return-value
                                    )
  .
end.
if v-error-append
then do:
  return error substitute( "&1" , v-error-append-msg ) .
end.
END PROCEDURE.
PROCEDURE wp-XMLWriteEDT:
  DEF INPUT PARAMETER hEDT AS HANDLE NO-UNDO.
  DEF INPUT PARAMETER iLogLevel AS INTEGER  NO-UNDO.
  DEF INPUT PARAMETER sToWrite  AS CHAR     NO-UNDO.
    if valid-handle ( hEDT )
    then do:
        hEDT :move-to-eof().
        hEDT :insert-string(IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                        OR sToWrite = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        hEDT :insert-string(IF sToWrite = "&Line" THEN FILL("-", 80)
                ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
                ELSE FILL(" ", iLogLevel) + sToWrite).
        hEDT :insert-string(chr(10)).
    end.
    process events.
    output to 'bgescn.txt' append.
        put unformatted
            chr(10) string( (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                        OR sToWrite = "&Line") THEN "" ELSE
                                        STRING(TODAY) + " " + STRING(TIME, "hh:mm:ss") + " ") )
            string( (IF sToWrite = "&Line" THEN FILL("-", 80)
                ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
                ELSE FILL(" ", iLogLevel) + sToWrite) )
        .
    output close.
END PROCEDURE.
PROCEDURE wp-XMLShowCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE   NO-UNDO.
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :VISIBLE = TRUE.
    end.
END PROCEDURE.
PROCEDURE wp-XMLHideCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE   NO-UNDO.
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :VISIBLE = FALSE.
    end.
END PROCEDURE.
PROCEDURE wp-XMLWriteCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE  NO-UNDO.
  DEF INPUT PARAMETER sCounter AS CHAR    NO-UNDO.
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :SCREEN-VALUE = sCounter.
    end.
END PROCEDURE.
procedure bge-xml-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name  as character        no-undo.
define input parameter p-doc-name       as character        no-undo.
define input parameter p-version        as character        no-undo.
define input parameter p-db-num         as integer          no-undo.
define input parameter p-date-from      as date             no-undo.
define input parameter p-shift-num-from as integer          no-undo.
define input parameter p-date-to        as date             no-undo.
define input parameter p-shift-num-to   as integer          no-undo.
define input parameter p-obj-list       as character        no-undo.
define input parameter p-doc-type-list  as character        no-undo.
define input parameter p-pay-code       as logical          no-undo.
define input parameter p-cst            as logical          no-undo.
define input parameter p-parts          as logical          no-undo.
define input parameter p-chk-pay-code   as logical          no-undo.
define input parameter p-pay-desk       as logical          no-undo.
define input parameter p-pay-desk-cards as logical          no-undo.
define input parameter p-deleted        as logical          no-undo.
define input parameter p-opened-docs    as logical          no-undo.
define variable v-out-string    as character    no-undo.
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251".
assign
    v-out-string = substitute( "&1&2&3"
                        , "<?xml version='1.0' encoding='windows-1251'?>":U
                        , chr(10)
                        , "<IBS_Trade_House>":U )
.
put stream stmXMLOut unformatted
    v-out-string
.
run wp-XMLTagOpen(1, "header","").
if v-bge-xml-bgeflold = "oracle":u
then do:
  run wp-XMLTagOpen in this-procedure  ( 2, "delivery", "").
  run wp-XMLTagput in this-procedure ( 3, "message","", 1).
  run wp-XMLTagput in this-procedure ( 3, "from","IBS Trade House", 1).
  run wp-XMLTagput in this-procedure ( 3, "to","Oracle Retail", 1).
  run wp-XMLTagClose in this-procedure ( 2, "delivery"    ).
end.
run wp-XMLTagOpen( 2, "manifest", "").
run wp-XMLTagOpen( 3, "document", "").
run wp-XMLTagput( 4, "name", p-doc-name, 0).
run wp-XMLTagput( 4, "description", "", 0).
run wp-XMLTagput( 4, "version", p-version, 0).
run wp-XMLTagclose( 3, "document" ).
run wp-XMLTagclose( 2, "manifest" ).
run wp-XMLTagclose( 1, "header" ).
run wp-XMLTagOpen(1, "options","").
run wp-XMLTagput( 2, "exportDate",      string( today,              "99/99/9999" ), 0).
run wp-XMLTagput( 2, "exportDateXml",   bge-xml-date( today )                     , 0).
run wp-XMLTagput( 2, "exportTime",      string( time,               "HH:MM:SS"   ), 0).
run wp-XMLTagput( 2, "baseNum",         string( p-db-num                         ), 0).
run wp-XMLTagput( 2, "dateFrom",        string( p-date-from,        "99/99/9999" ), 0).
run wp-XMLTagput( 2, "dateFromXml",     bge-xml-date( p-date-from )               , 0).
run wp-XMLTagput( 2, "shiftNumFrom",    string( p-shift-num-from                 ), 2).
run wp-XMLTagput( 2, "dateTo",          string( p-date-to,          "99/99/9999" ), 0).
run wp-XMLTagput( 2, "dateToXml",       bge-xml-date( p-date-to )                 , 0).
run wp-XMLTagput( 2, "shiftNumTo",      string( p-shift-num-to                   ), 2).
run wp-XMLTagput( 2, "objList",                 p-obj-list                        , 0).
run wp-XMLTagput( 2, "docTypeList",             p-doc-type-list                   , 0).
run wp-XMLTagput( 2, "payCode",         string( p-pay-code                       ), 0).
run wp-XMLTagput( 2, "cst",             string( p-cst                            ), 0).
run wp-XMLTagput( 2, "parts",           string( p-parts                          ), 0).
run wp-XMLTagput( 2, "chkPayCode",      string( p-chk-pay-code                   ), 0).
run wp-XMLTagput( 2, "chkPayDesk",      string( p-pay-desk                       ), 0).
run wp-XMLTagput( 2, "chkPayDeskCards", string( p-pay-desk-cards                 ), 0).
run wp-XMLTagput( 2, "deletedDocs",     string( p-deleted                        ), 0).
run wp-XMLTagput( 2, "openedDocs",      string( p-opened-docs                    ), 0).
run wp-XMLTagClose(1, "options").
run wp-XMLTagOpen( 1, "body", "" ).
output stream stmXMLOut close.
end.
end procedure.
procedure xml-bge-write-footer:
do
on error undo, return error return-value
:
define input parameter p-xml-file-name as character    no-undo.
define variable v-error-num     as integer           no-undo.
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run wp-XMLTagClose( 1, "body" ).
run wp-XMLTagClose( 0, "IBS_Trade_House" ).
output stream stmXMLOut close.
if v-bge-xml-bgeflold = "oracle":u
then do:
  define variable v-tmp-file-name         as character no-undo .
  define variable v-zip-file-name         as character no-undo .
  define variable v-exch-file-name        as character no-undo .
  define variable v-heap-file-name        as character no-undo .
  define variable v-i                     as integer   no-undo .
  define variable v-file-name             as character no-undo .
  define variable v-arc                   as character no-undo .
  define variable v-str                   as character no-undo .
  define variable v-exch-tmp-file-name    as character no-undo .
  define variable v-bge-xml-tmp-exch-dir  as character no-undo .
  define variable v-bge-xml-exch-dir      as character no-undo .
  define variable v-bge-xml-heap-dir      as character no-undo .
  define variable v-bge-xml-compress-heap as logical   no-undo .
  define variable v-home-dir              as character no-undo .
  define variable v-os-command            as character no-undo .
  get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
  if v-home-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта.":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  assign
    v-home-dir = v-home-dir
  .
  run gbl/dir-cre.p ( input v-home-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта.":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  get-key-value section "BGE" key "dir-exch" value v-bge-xml-exch-dir .
  if v-bge-xml-exch-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта (exch).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  run gbl/dir-cre.p ( input v-bge-xml-exch-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта (exch).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  get-key-value section "BGE" key "dir-heap" value v-bge-xml-heap-dir.
  if v-bge-xml-heap-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта (heap).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  run gbl/dir-cre.p ( input v-bge-xml-heap-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта (heap).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  get-key-value section "BGE" key "heap-compress" value v-str.
  assign
    v-i = int(v-str)
  no-error .
  if v-i = ? or v-i = 0
  then do:
    assign
      v-bge-xml-compress-heap = no
    .
  end.
  else do:
    assign
      v-bge-xml-compress-heap = yes
    .
  end.
  assign
    v-arc = search( "exe/7za.exe":u )
  .
  if v-arc = ? or v-arc = ""
  then do:
    undo, return error("Не найдена программа 7za.exe, невозможно упаковать файлы в архив.":u).
  end.
  assign
    v-file-name            = entry(num-entries( p-xml-file-name , chr(47) ) , p-xml-file-name , chr(47) )
    v-tmp-file-name        = session :temp-directory + v-file-name + "DAT":u
    v-zip-file-name        = session :temp-directory + v-file-name + "DAT.zip":u
    v-bge-xml-tmp-exch-dir = v-bge-xml-exch-dir + ".000"
    v-exch-tmp-file-name   = v-bge-xml-tmp-exch-dir + chr(47) + v-file-name + "tmp":u
    v-exch-file-name       = v-bge-xml-exch-dir + chr(47) + v-file-name + "DAT.zip":u
    v-heap-file-name       = v-bge-xml-heap-dir + chr(47) + v-file-name + "DAT":u
  .
  run gbl/del-file.p (input v-tmp-file-name) .
  run gbl/del-file.p (input v-zip-file-name) .
  run bge/os_copy.p ("M", p-xml-file-name + "xm1":u, v-tmp-file-name, output v-error-num ).
  if v-error-num > 0
  then do:
      undo, return error substitute( "Ошибка переноса из &1 в &2. Код ошибки: &3"
                                   , p-xml-file-name + "xm1":u
                                   , v-tmp-file-name
                                   , v-error-num
                                   ).
  end.
  assign
    v-os-command     = substitute( "&1 a -tzip &2 &3"
                                 , v-arc
                                 , v-zip-file-name
                                 , v-tmp-file-name
                                 )
  .
  os-command silent value ( v-os-command ) .
  run gbl/del-file.p (input v-heap-file-name) .
  if v-bge-xml-compress-heap = no
  then do:
    run bge/os_copy.p ("C", v-tmp-file-name, v-heap-file-name, output v-error-num ).
    if v-error-num > 0
    then do:
        undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                     , v-tmp-file-name
                                     , v-heap-file-name
                                     , v-error-num
                                     ) .
    end.
  end.
  else do:
    run bge/os_copy.p ("C", v-zip-file-name, v-heap-file-name + ".zip", output v-error-num ).
    if v-error-num > 0
    then do:
        undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                     , v-zip-file-name
                                     , v-heap-file-name
                                     , v-error-num
                                     ) .
    end.
  end.
  run gbl/del-file.p (input v-tmp-file-name) .
  run gbl/dir-cre.p ( input v-bge-xml-tmp-exch-dir ) no-error.
  if error-status :error then do:
    undo, return error substitute( "&1&2&3"
                                  , substitute( "Не удалось создать каталог &1.", v-bge-xml-tmp-exch-dir )
                                  , chr(10)
                                  , "Обратитесь к администратору."
                                  ).
  end.
  run gbl/del-file.p (input v-exch-file-name) .
  run gbl/del-file.p (input v-exch-tmp-file-name ) .
  run bge/os_copy.p ("M", v-zip-file-name, v-exch-tmp-file-name, output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , v-zip-file-name
                                  , v-exch-tmp-file-name
                                  , v-error-num
                                  ) .
  end.
  run bge/os_copy.p ("M", v-exch-tmp-file-name, v-exch-file-name , output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , v-exch-tmp-file-name
                                  , v-exch-file-name
                                  , v-error-num
                                  ) .
  end.
  run gbl/del-file.p (input v-bge-xml-tmp-exch-dir ) .
end.
else do:
  run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , p-xml-file-name + "xm1"
                                  , p-xml-file-name + "xml"
                                  , v-error-num
                                  ) .
  end.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-bge-filename0:
define input parameter p-prefix   as character no-undo .
define input parameter p-name     as character no-undo .
define input parameter p-shared-process as logical no-undo .
define input parameter p-home-dir as character no-undo . // из ini-параметра [BGE] Dirfrg-acc
define output parameter p-xml-file-name  as character no-undo .
// define output parameter p-fullfnamenoext as character no-undo .
define output parameter p-locked         as logical      no-undo.
define variable v-fullfnamenoext as character no-undo .
define variable v-fileext        as character no-undo .
define variable v-fullfname      as character no-undo .
define variable v-error-num      as integer   no-undo .
do
on error undo, return error
:
  case v-bge-xml-bgeflold :
    when "old" then do:
      v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, chr(47), p-name, v-bge-xml-db-num-str) .
      v-fileext       = ".xml":U .
      v-fullfname     = v-fullfnamenoext + v-fileext .
      p-xml-file-name = v-fullfname .
      run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
      if v-error-num > 0 then do:
        return error.
      end.
    end.
    when "var" then do:
      case p-prefix :
        when "doc" then do:
          v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, chr(47), p-name, v-bge-xml-bgeflnm-doc) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
        when "day" then do:
          v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, chr(47), p-name, v-bge-xml-bgeflnm-day) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
        otherwise do:
          v-fullfnamenoext = substitute ("&1&2&3", p-home-dir, chr(47), p-name) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
      end case.
      run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
      if v-error-num > 0 then do:
        return error.
      end.
    end.
    when "new" then do:
                run bge/genfname.p (
                    input p-home-dir
                    , input p-prefix
                    , input ""
                    , input "xml"
                    , input ""
                    , output p-xml-file-name
                ).
    end.
    when "no-parameter" then do:
      if p-shared-process then do:
                    run bge/genfname.p (
                        input p-home-dir
                        , input "d"
                        , input ""
                        , input "xml"
                        , input ""
                        , output p-xml-file-name
                    ).
      end.
      else do:
        v-fullfnamenoext = substitute ("&1&2&3", p-home-dir, chr(47), p-name) .
        v-fileext       = ".xml":U .
        v-fullfname     = v-fullfnamenoext + v-fileext .
        p-xml-file-name = v-fullfname .
        run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
        if v-error-num > 0 then do:
          return error.
        end.
      end.
    end.
  end case.
  assign
    p-xml-file-name = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
    p-locked = ( search ( p-xml-file-name + "lk" ) <> ? )
  .
end .
end procedure .
procedure xml-bge-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-shared-process     as logical      no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-home-dir          as character no-undo .
define variable v-error-num         as integer   no-undo .
define variable v-bge-xml-heap-dir  as character no-undo .
    get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle"
    then do:
      assign
          v-home-dir = v-home-dir + chr(47) + "exp-acc"
      .
    end.
    run gbl/dir-cre.p ( input v-home-dir ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        assign
            p-xml-file-name = v-home-dir
            p-locked        = no
        .
    end.
    else do:
        run xml-bge-filename0 in this-procedure (p-prefix, p-name, p-shared-process, v-home-dir,
          output p-xml-file-name, output p-locked) .
    end.
    if v-bge-xml-bgeflold = "oracle"
    then do:
      get-key-value section "BGE" key "dir-heap" value v-bge-xml-heap-dir.
      if v-bge-xml-heap-dir = ?
      then do:
        undo, return error substitute( "&1&2&3"
                                      , "Не найден параметр ini-файла, определяющий каталог экспорта (heap).":u
                                      , chr(10)
                                      , "Обратитесь к администратору.":u
                                      ).
      end.
      run gbl/dir-cre.p ( input v-bge-xml-heap-dir ) no-error.
      if error-status :error
      then do:
        undo, return error substitute( "&1&2&3"
                                      , "Неверно задан каталог экспорта (heap).":u
                                      , chr(10)
                                      , "Обратитесь к администратору.":u
                                      ).
      end.
      if r-index( v-bge-xml-heap-dir, chr(47) ) > r-index( v-bge-xml-heap-dir, chr(92) ) then do:
        assign
          p-log-file-name = substring( v-bge-xml-heap-dir, 1, r-index( v-bge-xml-heap-dir, chr(47) ) ) + chr(47) + "actions.log"
        .
      end.
      else do:
        assign
          p-log-file-name = substring( v-bge-xml-heap-dir, 1, r-index( v-bge-xml-heap-dir, chr(92) ) ) + chr(47) + "actions.log"
        .
      end.
    end.
    else do:
      assign
          p-log-file-name = v-home-dir + chr(47) + "actions.log"
      .
    end.
    assign
       v-bge-xml-static-log-file-name = p-log-file-name
    .
end.
end procedure.
procedure bge-xml-read-config :
do
on error undo, return error return-value
:
define input  parameter p-last-date as date      no-undo .
define input  parameter p-db-num    as integer   no-undo .
    define variable v-bgeclall      as character     no-undo.
    define variable v-bgedict       as character     no-undo.
    define variable v-bgeshift      as character     no-undo.
    define variable v-par-type      as character     no-undo.
    define variable v-bgeflnm       as character     no-undo.
    define variable v-bgecliiv      as character     no-undo .
    define variable v-date-chars    as character case-sensitive  init "DD"      no-undo.
    define variable v-month-chars   as character case-sensitive  init "MM"      no-undo.
    define variable v-year-chars    as character case-sensitive  init "YY"      no-undo.
    define variable v-db-num-chars  as character case-sensitive  init "BBBBB"   no-undo.
    define variable v-db-num-str    as character     no-undo .
    define variable v-param-type      as character  no-undo .
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle      no-undo .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-bgecliiv
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgecliiv = no
      .
    end.
    else do:
      run bge-xml-fill-tt-bgecliiv in this-procedure ( input v-bgecliiv ).
    end.
    delete object v-tth.
    assign
        v-bge-xml-bgeclall = no
        v-bge-xml-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgeclall = no
      .
    end.
    else do:
      assign
        v-bge-xml-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgedict':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgedict = no
      .
    end.
    else do:
      assign
        v-bge-xml-bgedict = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgefmt':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bge-xml-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeshift':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
          v-bge-xml-shift-mode = no
      .
    end.
    else do:
      assign
          v-bge-xml-shift-mode = ( v-value-character = "distinct":U )
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeflold':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgeflold = "no-parameter":U
      .
    end.
    else do:
      assign
        v-bge-xml-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
    assign
      v-db-num-str          = ( if p-db-num <> ? then string(p-db-num ,"99999") else "":u )
      v-bge-xml-db-num-str  = v-db-num-str
    .
    if p-last-date <> ?
    then do:
        run adm/shattri.p ( input "get":U
                          , input  '':u
                          , input  0
                          , input  'bge-export':U
                          , input  'bgeflnm':U
                          , output v-value-character
                          , output v-value-date
                          , output v-value-decimal
                          , output v-value-integer
                          , output v-value-logical
                          , output v-param-type
                          , input-output table-handle v-tth
                          ) no-error .
        if error-status :error
        then do:
          assign
            v-bgeflnm = '':U
          .
        end.
        else do:
          assign
            v-bgeflnm = v-value-character
          .
        end.
        delete object v-tth.
        if v-bge-xml-bgeflold = "var"
        then do:
            if v-bgeflnm = ?
            or num-entries( v-bgeflnm ) < 2
            then do:
                assign
                    v-bge-xml-bgeflold = "new"
                .
            end.
            else do:
                assign
                    v-bge-xml-bgeflnm-doc = entry( 1, v-bgeflnm )
                    v-bge-xml-bgeflnm-day = entry( 2, v-bgeflnm )
                .
                assign
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-date-chars , string( day( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-month-chars, string( month( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-year-chars , substring( string( year( p-last-date ), "9999" ), 3, 2 ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-db-num-chars, v-db-num-str )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-date-chars , string( day( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-month-chars, string( month( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-year-chars , substring( string( year( p-last-date ), "9999" ), 3, 2 ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-db-num-chars, v-db-num-str )
                .
            end.
        end.
    end.
end.
end procedure.
procedure bge-xml-get-ref-filename :
define input parameter p-in-file-name       as character        no-undo.
define output parameter p-home-dir          as character        no-undo.
define output parameter p-out-file-name     as character        no-undo.
define output parameter p-locked            as logical          no-undo.
    define variable v-counter       as integer      no-undo.
    define variable v-error-level   as integer      no-undo.
do
on error undo, return error
:
    run bge/bge-ini.p (
          input "bge"
        , output p-home-dir
    ).
    if return-value <> "OK"
    then do:
        undo, return error.
    end.
    assign
        p-home-dir = p-home-dir + "\dict":U
    .
    run bge/dir_cd.p (
        input p-home-dir
        , input "CA"
    ).
    if return-value = "ERROR"
    then do:
        undo, return error.
    end.
    assign
        p-out-file-name = substitute( "&1\&2.", p-home-dir, p-in-file-name )
    .
    assign
        p-locked = ( search( p-out-file-name + "xml" ) <> ? ).
    .
    wait-lock:
    do v-counter = 1 TO 3
    :
        p-locked = ( search( p-out-file-name + "lk" ) <> ? ).
        if p-locked = no
        then do:
            leave wait-lock.
        end.
        else do:
            readkey pause 1.
        end.
    END.
    if p-locked = yes
    then do:
        undo, return error.
    end.
    run bge/os_copy.p (
          input "D":U
        , input p-out-file-name + "xml":U
        , input "":U
        , output v-error-level
    ).
    if v-error-level > 0
    then do:
        undo, return error.
    end.
end.
end procedure.
procedure bge-xml-write-ref-header :
define input parameter p-bge-name as character        no-undo.
define input parameter p-file-name as character        no-undo.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-file-name + "xm1") convert target "1251".
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>":U
    .
    assign
        v-out-string = substitute( "&1&2"
                            , chr(10)
                            , "<IBS_Trade_House>":U )
    .
    put stream stmXMLOut unformatted
        v-out-string
    .
    run wp-XMLTagOpen( 1, "header", "" ).
    if v-bge-xml-bgeflold = "oracle":u
    then do:
      run wp-XMLTagOpen in this-procedure  ( 2, "delivery", "").
      run wp-XMLTagput in this-procedure ( 3, "message","", 1).
      run wp-XMLTagput in this-procedure ( 3, "from","IBS Trade House", 1).
      run wp-XMLTagput in this-procedure ( 3, "to","Oracle Retail", 1).
      run wp-XMLTagClose in this-procedure ( 2, "delivery"    ).
    end.
    else do:
      run wp-XMLTagOpen( 2, "delivery", "" ).
      run wp-XMLTagOpen( 3, "to", "" ).
      run wp-XMLTagClose( 3, "to" ).
      run wp-XMLTagOpen( 3, "from", "" ).
      run wp-XMLTagClose( 3, "from" ).
      run wp-XMLTagClose( 2, "delivery" ).
    end.
    run wp-XMLTagOpen( 2, "manifest", "" ).
    run wp-XMLTagOpen( 3, "document", "" ).
    run wp-XMLTagPut( 4, "name", p-bge-name, 0 ).
    run wp-XMLTagPut( 4, "description", "", 0 ).
    run wp-XMLTagClose( 3, "document" ).
    run wp-XMLTagClose( 2, "manifest" ).
    run wp-XMLTagClose( 1, "header" ).
    run wp-XMLTagOpen( 1, "body", "" ).
end.
end procedure.
procedure bge-xml-write-ref-footer :
define input parameter p-file-name as character        no-undo.
    define variable v-error-level   as integer      no-undo.
do
on error undo, return error
:
    run wp-XMLTagClose in this-procedure ( input 1, input "body":U ).
    run wp-XMLTagClose in this-procedure ( input 0, input "IBS_Trade_House":U ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M":U
        , input p-file-name + "xm1":U
        , input p-file-name + "xml":U
        , output v-error-level
    ).
    if v-error-level > 0
    then do:
        undo, return error.
    end.
end.
end procedure.
procedure bge-xml-out-dir :
define output parameter p-out-dir       as character    no-undo.
define output parameter p-log-file-name as character    no-undo.
do
on error undo, return error
:
    p-out-dir = ibs.th.gbl.gbl-inipar:dirfrgAcc .
    if p-out-dir = ?
    then do:
        message
          skip substitute("Не найден параметр ini-файла, определяющий каталог экспорта (&1)."
                        , ibs.th.gbl.gbl-inipar:dirfrgAccKeyName)
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle" then assign
      p-out-dir = substitute( "&1&2exp-acc":U, p-out-dir, chr(47) )
    .
    run gbl/dir-cre.p ( input p-out-dir ) no-error.
    if error-status :error  then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dir
                                , return-value
                                , trim( error-status :get-message( 1 ) )
                                )
        ).
        undo, return error.
    end.
    assign
        v-bge-xml-static-log-file-name = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
        p-log-file-name                = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
    .
end.
end procedure.
procedure bge-xml-out-dir2 :
define output parameter p-out-dir       as character    no-undo.
define output parameter p-out-dirR      as character    no-undo.
define output parameter p-log-file-name as character    no-undo.
do
on error undo, return error
:
    p-out-dir = ibs.th.gbl.gbl-inipar:dirfrgAcc .
    if p-out-dir = ?
    then do:
        message
          skip substitute("Не найден параметр ini-файла, определяющий каталог экспорта (&1)."
                        , ibs.th.gbl.gbl-inipar:dirfrgAccKeyName)
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle" then assign
          p-out-dirR = substitute( "&1&2exp-reestr":U, p-out-dir, chr(47) )
          p-out-dir  = substitute( "&1&2exp-acc":U,    p-out-dir, chr(47) )
      .
    else p-out-dirR = p-out-dir .
    run gbl/dir-cre.p ( input p-out-dir ) no-error.
    if error-status :error  then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dir
                                , return-value
                                , error-status :get-message( 1 )
                                )
        ).
        undo, return error.
    end.
    if p-out-dirR <> p-out-dir then do:
      run gbl/dir-cre.p ( input p-out-dirR ) no-error.
      if error-status :error then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dirR
                                , return-value
                                , error-status :get-message( 1 )
                                )
        ).
        p-out-dirR = p-out-dir .
      end.
    end .
    assign
      v-bge-xml-static-log-file-name = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
      p-log-file-name                = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
    .
end.
end procedure.
procedure bge-xml-out-file :
do
on error undo, return error
:
define input parameter p-out-dir            as character        no-undo.
define input parameter p-prefix             as character        no-undo.
define input parameter p-sheduled           as logical          no-undo.
define output parameter p-xml-file-name     as character        no-undo.
define output parameter p-locked            as logical          no-undo.
define variable v-home-dir      as character     no-undo.
define variable v-error-num     as integer       no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        assign
            p-xml-file-name = p-out-dir
            p-locked        = no
        .
    end.
    else do:
        if v-bge-xml-bgeflold = "firm":U
        then do:
            run bge/genfname.p (
                  input p-out-dir
                , input p-prefix
                , input "":U
                , input "arj":U
                , input "":U
                , output p-xml-file-name
            ).
        end.
        else do:
            run bge/genfname.p (
                  input p-out-dir
                , input p-prefix
                , input "":U
                , input "xml":U
                , input "":U
                , output p-xml-file-name
            ).
        end.
        assign
            p-xml-file-name = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
            p-locked = ( search ( p-xml-file-name + "lk":U ) <> ? )
        .
    end.
end.
end procedure.
procedure bge-xml-init-ext-doc-type :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
        .
    end.
end.
end procedure.
procedure bge-xml-get-decimal-shift-num :
define input parameter p-shift-date     as date             no-undo.
define input parameter p-shift-num      as integer          no-undo.
define output parameter p-shift-decimal as decimal          no-undo.
do
on error undo, return error
:
    assign
        p-shift-decimal = ( p-shift-date - 01/01/1990 ) + truncate( p-shift-num / 1000, 3 )
    .
end.
end procedure.
procedure bge-xml-ora-exp-filename :
  define input  parameter p-table-name  as character no-undo .
  define input  parameter p-doc-code    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-filename    as character no-undo .
  define output parameter p-seq-num     as integer   no-undo .
  define variable v-ora-exp-seq     as integer   no-undo .
  define variable v-ora-exp-seq-str as character no-undo .
  define variable v-home-dir        as character no-undo.
do
on error undo, return error return-value
:
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
    if v-home-dir = ?
    then do:
      undo, return error substitute( "&1&2&3":U
                                    , "Не найден параметр ini-файла, определяющий каталог экспорта.":U
                                    , chr(10)
                                    , "Обратитесь к администратору.":U
                                    ).
    end.
    assign
        v-home-dir = v-home-dir
    .
    run gbl/dir-cre.p ( input v-home-dir ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&1&2&3":U
                                    , "Неверно задан каталог экспорта.":U
                                    , chr(10)
                                    , "Обратитесь к администратору.":U
                                    ).
    end.
    assign
      v-ora-exp-seq = ?
    .
    if  p-table-name <> ? and
        p-doc-code <> ?
    then do:
      run bge/get-oesq.p ( input p-table-name
                         , input p-doc-code
                         , output v-ora-exp-seq
                         ) no-error .
      if error-status :error = yes
      then do:
        undo, return error return-value .
      end.
    end.
    if v-ora-exp-seq = ?
    then do:
      run bge/oesq-get.p ( output v-ora-exp-seq ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
    end.
    if p-table-name <> ? and
       p-doc-code   <> ?
    then do:
      run bge/oesqdoc.p ( input p-table-name
                        , input p-doc-code
                        , input v-ora-exp-seq
                        ) no-error .
      if error-status :error = yes
      then do:
        undo, return error return-value .
      end.
    end.
    assign
      p-seq-num  = v-ora-exp-seq
      p-filename = substitute("&1/&2-000_&3."
                             , v-home-dir
                             , ( if p-obj-code < 1000 then string( p-obj-code, "999") else string(p-obj-code))
                             , string(v-ora-exp-seq , "999999999")
                             )
    .
  end.
end.
end procedure.
procedure bge-xml-date-to-str :
  define input  parameter p-date  as date      no-undo .
  define output parameter p-str   as character no-undo .
do
on error undo, return error return-value
:
  if p-date <> ?
  then do:
    assign
      p-str = substitute( "&1-&2-&3"
                        , string( year(p-date)  , "9999")
                        , string( month(p-date) , "99"  )
                        , string( day(p-date)   , "99"  )
                        )
    .
  end.
  else do:
    assign
      p-str = ?
    .
  end.
end.
end procedure.
procedure bge-xml-date-str-to-str :
  define input  parameter p-date-str  as character no-undo .
  define output parameter p-str       as character no-undo .
  define variable v-date          as date      no-undo .
  define variable v-date-valid    as logical   no-undo .
  define variable v-error-message as character no-undo .
do
on error undo, return error return-value
:
  assign
    p-str = ?
  .
  if p-date-str = ? or p-date-str = ""
  then do:
    return .
  end.
  run strtdate in this-procedure ( input  p-date-str
                                 , output v-date
                                 , output v-date-valid
                                 , output v-error-message
                                 ).
  if v-date-valid <> true
  then do:
    return .
  end.
  assign
    p-str = substitute( "&1-&2-&3"
                      , string( year(v-date)  , "9999")
                      , string( month(v-date) , "99"  )
                      , string( day(v-date)   , "99"  )
                      )
  .
end.
end procedure.
procedure bge-xml-fill-tt-bgecliiv :
  define input  parameter p-str as character no-undo .
  define buffer buf_tt-bge-xml-bgecliiv for tt-bge-xml-bgecliiv.
  define buffer buf_clients             for ub.clients.
  define variable v-i         as integer   no-undo .
  define variable v-count     as integer   no-undo .
  define variable v-cli-count as integer   no-undo .
  define variable v-client    as character no-undo .
  define variable v-obj-type  as character no-undo .
  define variable v-obj-code  as integer   no-undo .
do
on error undo, return error return-value
:
  empty temp-table buf_tt-bge-xml-bgecliiv.
  assign
    v-bge-xml-bgecliiv = no
    v-cli-count        = num-entries(p-str,';')
  .
  if v-cli-count > 0
  then do:
    _cli-cycle:
    do v-i = 1 to v-cli-count
    :
      assign
        v-client = entry(v-i , p-str, ';')
      .
      if num-entries(v-client) <> 2
      then do:
        undo, return error substitute("Неправильный формат записи контрагента в параметре 'bgecliiv'. Позиция записи &1." , v-i).
      end.
      assign
        v-obj-type = entry(1, v-client)
      .
      assign
        v-obj-code = integer(entry(2, v-client))
      no-error .
      if error-status :error
      then do:
        undo, return error substitute("Неправильный формат записи кода контрагента в параметре 'bgecliiv'. Позиция записи &1." , v-i).
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = v-obj-type
          and buf_clients.obj-code = v-obj-code
      no-error.
      if not available buf_clients
      then do:
        next _cli-cycle.
      end.
      find first buf_tt-bge-xml-bgecliiv no-lock
        where buf_tt-bge-xml-bgecliiv.obj-type = buf_clients.obj-type
          and buf_tt-bge-xml-bgecliiv.obj-code = buf_clients.obj-code
      no-error .
      if available buf_tt-bge-xml-bgecliiv
      then do:
        next _cli-cycle.
      end.
      create buf_tt-bge-xml-bgecliiv.
      assign
        buf_tt-bge-xml-bgecliiv.obj-type = buf_clients.obj-type
        buf_tt-bge-xml-bgecliiv.obj-code = buf_clients.obj-code
      .
    end.
  end.
  else do:
    assign
      v-bge-xml-bgecliiv = no
    .
    return .
  end.
  find first buf_tt-bge-xml-bgecliiv no-lock no-error .
  if available buf_tt-bge-xml-bgecliiv
  then do:
    assign
      v-bge-xml-bgecliiv = yes
    .
  end.
end.
end procedure.
procedure bge-xml-resolve-ext-doc-type :
  define input  parameter p-ext-doc-type      as character no-undo .
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define output parameter p-out-ext-doc-type  as character no-undo .
  define buffer buf_tt-bge-xml-bgecliiv for tt-bge-xml-bgecliiv.
do
on error undo, return error return-value
:
  assign
    p-out-ext-doc-type = p-ext-doc-type
  .
  if p-ext-doc-type <> 'ie':U
  then do:
    return .
  end.
  if v-bge-xml-bgecliiv = yes
  then do:
    find first buf_tt-bge-xml-bgecliiv no-lock
      where buf_tt-bge-xml-bgecliiv.obj-type = p-obj-type
        and buf_tt-bge-xml-bgecliiv.obj-code = p-obj-code
    no-error .
    if available buf_tt-bge-xml-bgecliiv
    then do:
      assign
        p-out-ext-doc-type = 'iv':U
      .
    end.
  end.
end.
end procedure.
procedure safe-wp-xmltagput :
  define input  parameter pTagLevel   as integer   no-undo .
  define input  parameter pTagName    as character no-undo .
  define input  parameter pParValue   as character no-undo .
  define input  parameter pFlagEmpty  as integer   no-undo .
do
on error undo, return error return-value
:
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    return .
  end.
  run wp-xmltagput in this-procedure ( input pTagLevel
                                     , input pTagName
                                     , input pParValue
                                     , input pFlagEmpty
                                     ).
end.
end procedure.
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_dbflib_field no-undo
    field field-name        as character    format "x(32)"
    field data-type         as character
    field field-decimals    as integer
    field dbfield-name      as character    format "x(11)"
    field field-handle      as handle
    field field-length      as integer      format ">>>9"
    index field-name        is primary unique
        field-name
.
define temp-table temp_dbflib_data no-undo
    field record-number as integer
    field field-name    as character
    field data-value    as character
    index pi is primary unique
        record-number
        field-name
.
define variable v-dbflib-reclength      as integer      no-undo.
define variable v-field-amount          as integer      no-undo.
define stream dbf-stream.
procedure dbflib-write-dbf :
define input parameter p-filename       as character        no-undo.
define input parameter p-record-amount  as integer          no-undo.
    define variable v-date          as date         no-undo.
    define variable v-string-value  as character    no-undo.
    define variable raw-value       as raw          no-undo.
    define variable v-record-count  as integer      no-undo.
    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
    define buffer buf_temp_dbflib_data     for temp_dbflib_data.
do
for buf_temp_dbflib_field
  , buf_temp_dbflib_data
on error undo, return error
:
    output stream dbf-stream to value( p-filename ) binary no-convert.
    put stream dbf-stream
        control "~003":U
    .
    run dbflib-makebinary (
          input year( today ) - 2000
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
        month( today )
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
          input day( today )
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
          input p-record-amount
        , input 4
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
          input ( 32 + 32 * v-field-amount + 1 )
        , input 2
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
          input v-dbflib-reclength + 1
        , input 2
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    put stream dbf-stream control null( 20 ).
    for each buf_temp_dbflib_field
    :
        put stream dbf-stream control
            buf_temp_dbflib_field.dbfield-name
            null( 11 - length( buf_temp_dbflib_field.dbfield-name ) )
        .
        case buf_temp_dbflib_field.data-type:
            when "character":U
            then do:
                put stream dbf-stream "C".
            end.
            when "integer":U
            or when "decimal"
            then do:
                put stream dbf-stream "N".
            end.
            when "logical":U
            then do:
                put stream dbf-stream "L".
            end.
            when "date":U
            then do:
                put stream dbf-stream "D".
            end.
            otherwise do:
                undo, return error substitute("Unknown field type for &1: &2",
                                                buf_temp_dbflib_field.field-handle:name,
                                                buf_temp_dbflib_field.data-type).
            end.
        end case.
        put stream dbf-stream control
            null( 4 )
            chr( buf_temp_dbflib_field.field-length )
        .
        if buf_temp_dbflib_field.field-decimals = 0
        then do:
            put stream dbf-stream control null.
        end.
        else do:
            put stream dbf-stream control
                chr( buf_temp_dbflib_field.field-decimals )
            .
        end.
        put stream dbf-stream control
            null(2)
            chr(1)
            null(11)
       .
    end.
    put stream dbf-stream control
        chr(13)
    .
    do v-record-count = 1 to p-record-amount
    on error undo, return error
    :
        for each buf_temp_dbflib_data
           where buf_temp_dbflib_data.record-number = v-record-count
        :
            put stream dbf-stream
                " "
            .
            find first buf_temp_dbflib_field
            where buf_temp_dbflib_field.field-name = buf_temp_dbflib_data.field-name
            no-error.
            if available buf_temp_dbflib_field
            then do:
                case buf_temp_dbflib_field.data-type
                :
                    when "logical":U
                    then do:
                        put stream dbf-stream unformatted
                            ( if buf_temp_dbflib_data.data-value = "yes":U
                            then "T":U
                            else "F":U )
                        .
                    end.
                    when "date":U
                    then do:
                        assign
                            v-date = date( buf_temp_dbflib_data.data-value )
                        .
                        put stream dbf-stream unformatted
                            year( v-date )
                            month( v-date ) format "99"
                            day( v-date ) format "99"
                        .
                    end.
                    when "decimal":U
                    or when "integer":U
                    then do:
                        if session:numeric-format = "EUROPEAN":U
                        then do:
                            assign
                                v-string-value = replace( string( buf_temp_dbflib_data.data-value ), ".":U, "":U )
                                v-string-value = replace( v-string-value, ",":U, ".":U )
                            .
                        end.
                        else do:
                            assign
                                v-string-value = replace( string( buf_temp_dbflib_data.data-value ),",","")
                            .
                        end.
                        put stream dbf-stream unformatted
                            v-string-value
                            fill( " ":U, buf_temp_dbflib_field.field-length - length( v-string-value ) )
                        .
                    end.
                    otherwise do:
                        put stream dbf-stream unformatted
                            string( buf_temp_dbflib_data.data-value )
                            fill( " ", buf_temp_dbflib_field.field-length - length( string( buf_temp_dbflib_data.data-value ) ) )
                        .
                    end.
                end case.
            end.
        end.
    end.
    output stream dbf-stream close.
end.
end procedure.
PROCEDURE dbflib-makebinary:
define input parameter anumm#     as integer      no-undo.
define input parameter abyte#     as integer      no-undo.
define output parameter raw-value as raw          no-undo.
    define variable acoun#    as integer      no-undo.
do
on error undo, return error
:
    assign
        length( raw-value ) = abyte#
    .
    if anumm# <0
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip ": This routine works for positive integers only."
            skip "Received value of" anumm# "is invalid."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error
        title "Conversion to binary".
        undo, return error .
    end.
    if anumm# > 0
    and anumm# modulo anumm# / EXP( anumm#, abyte#) > 256
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip ": received number" anumm#
            skip "does not fit in" abyte# "bytes."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error
        title "Conversion to binary".
        undo, return error .
    end.
    do acoun# = abyte# to 1 by -1
    on error undo, return error
    :
        put-byte( raw-value, acoun# ) = int( truncate( anumm# / EXP( 256, acoun# - 1 ), 0 ) ).
        if anumm# ne 0
        then do:
            assign
                anumm# = anumm# modulo EXP( 256, acoun# - 1 )
            .
        end.
    end.
end.
END PROCEDURE.
procedure dbflib-init :
    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
    define buffer buf_temp_dbflib_data     for temp_dbflib_data.
do
for buf_temp_dbflib_field
  , buf_temp_dbflib_data
:
    empty temp-table buf_temp_dbflib_field.
    empty temp-table buf_temp_dbflib_data.
    assign
        v-dbflib-reclength = 0
        v-field-amount     = 0
    .
end.
end procedure.
procedure dbflib-add-field :
define input parameter p-field-name     as character        no-undo.
define input parameter p-field-length   as integer          no-undo.
define input parameter p-data-type      as character        no-undo.
define input parameter p-field-decimals as integer          no-undo.
    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
do
for buf_temp_dbflib_field
on error undo, return error
:
    find first buf_temp_dbflib_field
         where buf_temp_dbflib_field.field-name       = p-field-name
    no-error.
    if not available buf_temp_dbflib_field
    then do:
        create buf_temp_dbflib_field.
        assign
            buf_temp_dbflib_field.field-name       = p-field-name
            buf_temp_dbflib_field.field-length     = p-field-length
            buf_temp_dbflib_field.data-type        = p-data-type
            buf_temp_dbflib_field.field-decimals   = p-field-decimals
            buf_temp_dbflib_field.dbfield-name     = caps( replace( substring( p-field-name, 1, 11 ), "-":U, "_":U ) )
            v-dbflib-reclength                     = v-dbflib-reclength + buf_temp_dbflib_field.field-length
            v-field-amount                         = v-field-amount + 1
        .
    end.
end.
end procedure.
procedure dbflib-add-data :
define input parameter p-record-number  as integer          no-undo.
define input parameter p-field-name     as character        no-undo.
define input parameter p-data-value     as character        no-undo.
    define buffer buf_temp_dbflib_data      for temp_dbflib_data.
do
for buf_temp_dbflib_data
on error undo, return error
:
    find first buf_temp_dbflib_data
         where buf_temp_dbflib_data.record-number  = p-record-number
           and buf_temp_dbflib_data.field-name     = p-field-name
    no-error.
    if not available buf_temp_dbflib_data
    then do:
        create buf_temp_dbflib_data.
        assign
            buf_temp_dbflib_data.record-number  = p-record-number
            buf_temp_dbflib_data.field-name     = p-field-name
            buf_temp_dbflib_data.data-value     = p-data-value
        .
    end.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define stream in-stream.
    define variable v-xml-file-name     as character            no-undo.
    define variable v-log-file-name     as character            no-undo.
    define variable v-locked            as logical              no-undo.
    define variable v-log-string        as character            no-undo.
    define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.
    define variable v-db-num            as integer              no-undo.
    define variable v-yesno             as logical              no-undo.
do
on error undo, return error return-value
:
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
    run bge-xml-init-ext-doc-type in this-procedure .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_export':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output v-yesno
    )  .
end.
    if v-yesno = no
    then do:
        return error.
    end.
    run init-temphost.
    assign
        v-log-string = ", по всем фирмам"
    .
    case p-range:
    when 2
    then do:
        for each temp-obj
        where temp-obj.host-code <> v-cntxt-host-code-obj
        :
            delete temp-obj.
        end.
        assign
            v-log-string = ", по фирме (код фирмы " + string( v-cntxt-host-code-obj ) + ")"
        .
    end.
    when 3
    then do:
        for each temp-obj
        :
            delete temp-obj.
        end.
        do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
        :
            create temp-obj.
            assign
                temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
                temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
            no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка чтения списка объектов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  temp-obj.obj-type
  ,input  temp-obj.obj-code
  ,output temp-obj.host-code
  ) no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Не найдена фирма для объекта" temp-obj.obj-type temp-obj.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        assign
            v-log-string = ", по объектам: " + p-obj-list
        .
    end.
    end case.
    run bge-xml-read-config in this-procedure ( input p-date-to
                                              , input ?
                                              ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка чтения параметров экспорта."
        skip "Для экспорта данных будут приняты параметры по умолчанию."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
    end.
    run xml-bge-filename in this-procedure (
          input "doc"
        , input "document"
        , input "no"
        , output v-xml-file-name
        , output v-log-file-name
        , output v-locked
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки в DBF" )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: Дата с: &1, дата по: &2"
                                , p-date-from
                                , p-date-to
                          )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", p-obj-list )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... типы документов: &1", p-doc-type-list )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... надо ли виды платежей: &1, ГТД: &2, партии: &3, типы кассовых платежей: &4, кассы: &5, преф.карт: &6, удал.документы: &7, незакр.документы: &8"
                                                      , p-pay-code
                                                      , p-cst
                                                      , p-parts
                                                      , p-chk-pay-code
                                                      , p-pay-desk
                                                      , p-pay-desk-cards
                                                      , p-deleted
                                                      , p-opened-docs )
    ).
    object-of-list:
    for each temp-obj
    :
        run export-docs-by-object (
              input temp-obj.host-code
            , input temp-obj.obj-type
            , input temp-obj.obj-code
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка экспорта документов по объекту"
            skip "Тип объекта:" temp-obj.obj-type
            skip "Код объекта:" temp-obj.obj-code
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            next object-of-list.
        end.
    end.
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в .D - файлы. Идёт преобразование в DBF..." )
    ).
    run convert-to-dbf in this-procedure (
          input v-xml-file-name
        , input v-log-file-name
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные преобразованы в DBF" )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
end.
procedure export-docs-by-object :
define input parameter p-host-code  as integer      no-undo.
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.
    define variable v-err-message       as character    no-undo.
do
on error undo, return error return-value
:
    run wp-XMLWriteEDT( hEDT, 1, string( p-obj-type ) + " " + string( p-obj-code ) ).
    run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов").
    run bge/bge-ahz.p (
          input parparentproc
        , input p-obj-type
        , input p-obj-code
        , input yes
        , input yes
        , input no
        , input p-date-from
        , input p-date-to
        , output v-archive-ok
        , output v-comment
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка проверки архивов на объекте."
        skip "Тип объекта:" p-obj-type
        skip "Код объекта:" p-obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-archive-ok = no
    then do:
        assign
            v-err-message = substitute( "*** Документы по объекту &1 &2 в интервале дат &3 - &4 не будут выгружены. Архивы по объекту в заданном интервале дат не целостные. &5."
                                    , p-obj-type
                                    , p-obj-code
                                    , p-date-from
                                    , p-date-to
                                    , v-comment       )
        .
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input v-err-message
        ).
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip v-err-message
        view-as alert-box error.
        undo, return error.
    end.
    process events.
    run rep/get-fo.p (
          input  p-obj-type
        , input  p-obj-code
        , input  p-date-from
        , input  p-date-to
        , output v-fact-order-from
        , output v-fact-order-to
        , output v-docs-exists
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка определения границ fact-order для поиска по архивам"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    if v-docs-exists = no
    then do:
        run wp-XMLWriteEDT( hEDT, 4, "В заданном диапазоне дат нет закрытых документов").
    end.
    else do:
        run wp-XMLShowCNT(hCNT).
        for each temp_ext-doc-type
        :
            if lookup( temp_ext-doc-type.ext-doc-type, p-doc-type-list ) <> 0
            or p-doc-type-list = "":U
            then do:
                run bge/doc-oper.p (
                      input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input temp_ext-doc-type.ext-doc-type
                    , input temp_ext-doc-type.ext-doc-type-label
                    , input v-fact-order-from
                    , input v-fact-order-to
                    , input p-date-from
                    , input p-date-to
                    , input p-pay-code
                    , input p-cst
                    , input p-parts
                    , input p-chk-pay-code
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input p-chk
                    , input p-doc-rvs
                    , input v-xml-file-name
                    , input v-log-file-name
                    , input this-procedure
                    , input hEDT
                    , input hCNT
                ) no-error.
                if error-status :error
                then do:
                    run wp-XMLWriteEDT(
                          input hEDT
                        , input 1
                        , input substitute( "Ошибка экспорта документов. &1. &2. &3."
                                            , return-value
                                            , trim(error-status :get-message( 1 ) )
                                            , trim(error-status :get-message( 2 ) ) )
                    ).
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка экспорта документов."
                        skip return-value
                        skip trim( error-status :get-message( 1 ) )
                             trim( error-status :get-message( 2 ) )
                             trim( error-status :get-message( 3 ) )
                    view-as alert-box error.
                    undo, return error.
                end.
            end.
        end.
        run wp-XMLHideCNT(hCNT).
    end.
    process events.
end.
end procedure.
procedure cb-fill_bge-xml_goods :
define input parameter p-gds-code   as integer          no-undo.
do
on error undo, return error
:
    find first temp_bge-xml_goods
         where temp_bge-xml_goods.gds-code = p-gds-code
    no-error.
    if not available temp_bge-xml_goods
    then do:
        create temp_bge-xml_goods.
        assign
            temp_bge-xml_goods.gds-code = p-gds-code
        .
    end.
end.
end procedure.
procedure cb-fill_bge-xml_clients :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
    define buffer buf_temp_bge-xml_clients      for temp_bge-xml_clients.
do
for buf_temp_bge-xml_clients
on error undo, return error
:
    find first buf_temp_bge-xml_clients
         where buf_temp_bge-xml_clients.obj-type = p-obj-type
           and buf_temp_bge-xml_clients.obj-code = p-obj-code
    no-error.
    if not available buf_temp_bge-xml_clients
    then do:
        create buf_temp_bge-xml_clients.
        assign
            buf_temp_bge-xml_clients.obj-type = p-obj-type
            buf_temp_bge-xml_clients.obj-code = p-obj-code
        .
    end.
end.
end procedure.
procedure convert-to-dbf :
define input parameter p-dir-name       as character        no-undo.
define input parameter p-log-filename   as character        no-undo.
    define variable v-field-name     as character    no-undo.
    define variable v-field-length   as integer      no-undo.
    define variable v-field-value    as character    no-undo.
    define buffer buf_temp-filelist     for temp-filelist.
do
for buf_temp-filelist
on error undo, return error return-value
:
    run filelist-clear in this-procedure .
    run filelist-init in this-procedure (
          input p-dir-name
        , input yes
        , input "d":U
        , input ?
    ).
    for each buf_temp-filelist
    :
        input stream in-stream from value( buf_temp-filelist.full-name ).
        case substring( buf_temp-filelist.file-name, 1, 4 )
        :
            when "head":U
            or when "hpss":U
            or when "hcss":U
            or when "hdsm":U
            or when "hcsm":U
            or when "hssm":U
            or when "hbiv":U
            or when "haiv":U
            or when "hspc":U
            or when "hsps":U
            or when "lhdr":U
            or when "ldtl":U
            or when "lprt":U
            or when "ldsm":U
            or when "lcsm":U
            or when "lssm":U
            or when "lbiv":U
            or when "laiv":U
            or when "lspc":U
            or when "lsps":U
            then do:
                run dbflib-init in this-procedure.
                repeat:
                    import stream in-stream
                        v-field-name
                        v-field-value
                    .
                    if v-field-value = ?
                    then do:
                        assign
                            v-field-value = "":U
                            v-field-length = 0
                        .
                    end.
                    else do:
                        assign
                            v-field-length = length( v-field-value )
                        .
                    end.
                    run dbflib-add-field in this-procedure (
                          input v-field-name
                        , input 255
                        , input "character":U
                        , input 0
                    ).
                    run dbflib-add-data in this-procedure (
                          input 1
                        , input v-field-name
                        , input v-field-value
                    ).
                end.
                run dbflib-write-dbf in this-procedure (
                    input substitute( "&1/&2.dbf":U, p-dir-name, buf_temp-filelist.file-name-no-ext )
                  , input 1
                ) no-error.
                if error-status :error
                then do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка записи файла формата dbf."
                        skip return-value
                        skip trim( error-status :get-message( 1 ) )
                             trim( error-status :get-message( 2 ) )
                             trim( error-status :get-message( 3 ) )
                    view-as alert-box error.
                    undo, return error.
                end.
            end.
        end case.
        input stream in-stream close.
        os-delete value( buf_temp-filelist.full-name ).
    end.
end.
end procedure.
