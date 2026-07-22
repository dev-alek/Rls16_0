block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p0-action     as character no-undo .
define input parameter p0-arch       as logical   no-undo .
define input parameter p0-file-name  as character no-undo .
define input parameter p0-source-dir as character no-undo .
define input parameter p0-target-dir as character no-undo .
define input parameter p0-temp-dir   as character no-undo .
define input parameter p-pck-num     as integer no-undo .
define input parameter p-esys-id     as integer no-undo .
define input parameter p-db-num      as integer no-undo .
define input parameter p-cr-db-num   as integer no-undo .
define input parameter p-delivery-method as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: 7aa39a4c7e01, 2814, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Чт сен 02 12:05:36 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sxg-pack.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/sxg-pack.p $":U .
define variable vss-description as character no-undo init "отправка и прием пакета новостей (файла)".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure esallatr-name :
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
    case p-code :
            when 'custom-pack-name':U then do:     assign     p-label = "Имя файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Имя файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'route-custom-pack-name':U then do:     assign     p-label = "Иям файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Иям файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure esallatr-value :
do
  on error undo, return error
  :
  define input  parameter p-table-name as character no-undo .
  define input  parameter p-key1     as int64 no-undo .
  define input  parameter p-key2     as int64 no-undo .
  define input  parameter p-key3     as character no-undo .
  define input  parameter p-key4     as character no-undo .
  define input  parameter p-key5     as int64 no-undo .
  define input  parameter p-key6     as int64 no-undo .
  define input  parameter p-key7     as character no-undo .
  define input  parameter p-key8     as character no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
    run esallatr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf_esys-all-attr no-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
   if avail buf_esys-all-attr then do:
    assign
    p-value = buf_esys-all-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = 'L':U then "no":U else "".
   end.
end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ext-system-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-write :
  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (input p-esys-id
      ,input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-exist in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-delete :
  define input  parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-delete in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "X(65)" no-undo
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ftp-fl_CreateFileList :
define input parameter lpFindData   as  memptr no-undo.
define input parameter pcSearchDir  as  char   no-undo.
define variable iFileSize           as  integer no-undo.
define variable lResult             as  logical no-undo.
define variable v-file-name as character no-undo .
define buffer buf_temp-dirlist for temp-dirlist.
define buffer buf_temp-filelist for temp-filelist.
do
on error undo, return error
:
    if get-long(lpFindData, 1) = 16 then do:
    v-file-name = get-string(lpFindData,45).
    find first buf_temp-dirlist where
              buf_temp-dirlist.dir-full-name = pcSearchDir + chr(47) + v-file-name no-error.
    if not available buf_temp-dirlist then do:
      create buf_temp-dirlist.
      assign
      buf_temp-dirlist.dir-full-name = pcSearchDir + chr(47) + v-file-name
      buf_temp-dirlist.dir-short-name = v-file-name
      .
    end.
  end.
  else do:
    assign
    iFileSize = get-long(lpFindData,33)
    .
    v-file-name = get-string(lpFindData,45).
    if v-file-name <> '' then do:
      find first buf_temp-filelist where
                buf_temp-filelist.full-name = pcSearchDir + chr(47) + v-file-name no-error.
      if not available buf_temp-filelist then do:
        create buf_temp-filelist.
        assign
        buf_temp-filelist.full-name = pcSearchDir + chr(47) + v-file-name
        buf_temp-filelist.directory-name = pcSearchDir
        buf_temp-filelist.file-name = v-file-name
        .
      end.
    end.
  end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE InternetConnectA EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  hInternetSession  as  long.
  define input parameter  lpszServerName    as  char.
  define input parameter  nServerPort       as  long.
  define input parameter  lpszUserName      as  char.
  define input parameter  lpszPassword      as  char.
  define input parameter  dwService         as  long.
  define input parameter  dwFlags           as  long.
  define input parameter  dwContext         as  long.
  define return parameter hInternetConnect  as  long.
END.
PROCEDURE InternetGetLastResponseInfoA EXTERNAL "wininet.dll" PERSISTENT:
  define output parameter lpdwError          as  long.
  define output parameter lpszBuffer         as  char.
  define input-output  parameter lpdwBufferLength   as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE InternetOpenUrlA EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  hInternetSession  as  long.
  define input parameter  lpszUrl           as  char.
  define input parameter  lpszHeaders       as  char.
  define input parameter  dwHeadersLength   as  long.
  define input parameter  dwFlags           as  long.
  define input parameter  dwContext         as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE InternetOpenA EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  sAgent            as  char.
  define input parameter  lAccessType       as  long.
  define input parameter  sProxyName        as  char.
  define input parameter  sProxyBypass      as  char.
  define input parameter  lFlags            as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE InternetReadFile EXTERNAL "wininet.dll" PERSISTENT:
  define input  parameter  hFile            as  long.
  define output parameter  sBuffer          as  char.
  define input  parameter  lNumBytesToRead  as  long.
  define output parameter  lNumOfBytesRead  as  long.
  define return parameter  iResultCode      as  long.
END.
PROCEDURE InternetCloseHandle EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  hInet             as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE FtpFindFirstFileA EXTERNAL "wininet.dll" PERSISTENT :
    define input parameter  hFtpSession as  long.
    define input parameter  lpFileName as char.
    define input parameter  lpFindFileData as memptr.
    define input parameter  dwFlags        as long.
    define input parameter  dwContext      as long.
    define return parameter hSearch as long.
END PROCEDURE.
PROCEDURE InternetFindNextFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hSearch as long.
    define input parameter  lpFindFileData as memptr.
    define return parameter found as long.
END PROCEDURE.
PROCEDURE FtpGetCurrentDirectoryA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession as long.
    define input parameter  lpszCurrentDirectory as long.
    define input-output parameter lpdwCurrentDirectory as long.
    define return parameter iRetCode as long.
END PROCEDURE.
PROCEDURE FtpSetCurrentDirectoryA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession as long.
    define input parameter  lpszDirectory as long.
    define return parameter iRetCode as long.
END PROCEDURE.
PROCEDURE FtpOpenFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession  as long.
    define input parameter  lpszFileName as long.
    define input parameter  dwAccess     as long.
    define input parameter  dwFlags      as long.
    define input parameter  dwContext    as long.
    define return parameter iRetCode as long.
END PROCEDURE.
PROCEDURE FtpPutFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession       as long.
    define input parameter  lpszLocalFile     as long.
    define input parameter  lpszNewRemoteFile as long.
    define input parameter  dwFlags           as long.
    define input parameter  dwContext         as long.
    define return parameter iRetCode          as long.
END PROCEDURE.
PROCEDURE FtpGetFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession          as long.
    define input parameter  lpszRemoteFile       as long.
    define input parameter  lpszNewFile          as long.
    define input parameter  fFailIfExists        as long.
    define input parameter  dwFlagsAndAttributes as long.
    define input parameter  dwFlags              as long.
    define input parameter  dwContext            as long.
    define return parameter iRetCode             as long.
END PROCEDURE.
PROCEDURE FtpDeleteFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession          as long.
    define input parameter  lpszRemoteFile       as long.
    define return parameter iRetCode             as long.
END PROCEDURE.
PROCEDURE GetLastError external "kernel32.dll" :
  define return parameter dwMessageID as long.
END PROCEDURE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION ora-rcpt_get-rcpt-name returns character ( input p-file-name as character):
define variable v-file-name as character no-undo .
assign
v-file-name = substitute("&1-&2_&3"
                          ,entry(2, entry(1, p-file-name, "_"), "-")
                          ,entry(1, entry(1, p-file-name, "_"), "-")
                          ,entry(2, p-file-name, "_")) no-error.
if error-status:error then v-file-name = p-file-name.
return v-file-name.
END FUNCTION.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  // ext-system-attr-value для проверки сертификатов
function objExists return character
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
FUNCTION availFile RETURNS logical
  ( INPUT ifile AS character ) :
    def var vii as int no-undo.
    do vii = 1 to 5:
       assign
          file-info:file-name = ifile
       .
       if    file-info:file-type = ?
          or not ( file-info:file-type begins "F":U )
          or file-info:file-size = 0
       then do:
          if vii = 5
          then do:
             return false.
          end.
          else do:
             pause 1 no-message.
          end.
       end.
       else do:
          return true.
       end.
    end.
end.
  define stream FLStream.
  define variable v-filename         as character no-undo .
  define variable v-fullfilename     as character no-undo .
  define variable v-filetype         as character no-undo .
//  define variable v-num-name-parts   as integer no-undo . 23/VII-2019
  define variable v-r-index          as integer no-undo .
  define variable v-fileext          as character no-undo .
  define variable v-filenamenoext    as character no-undo .
  define variable v-current-pack-num as integer no-undo .
  define variable v-ftp-ip as character no-undo .
  define variable v-ftp-login as character no-undo .
  define variable v-ftp-password as character no-undo .
  define variable v-ftp-path as character no-undo .
  define variable v-ftp-path-in as character no-undo .
  define variable v-ftp-path-out as character no-undo .
  define variable v-flags as character no-undo .
  define variable v-cmd-line as character no-undo .
  define variable l-res as integer no-undo .
  define variable v-type as character no-undo .
  define variable v-parameter as character no-undo .
  define variable log-file-name as character no-undo .
    define variable v-cert-enstr       as character no-undo . // чтение v-cert-enabled строкой
    define variable v-cert-enabled     as logical no-undo . // true - добавить цифровую подпись
    define variable v-attr-type        as character no-undo . // для чтения значений из ext-system-attr
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define buffer buf_temp-filelist for temp-filelist.
  define buffer buf_esys-pck-sent for ub.esys-pck-sent.
do
on error undo, return error
:
  assign
    file-info:file-name = p0-temp-dir
  .
  if file-info:file-type = ?
    or not ( file-info:file-type begins "D":U )
  then do:
    os-create-dir value( p0-temp-dir ).
    if os-error <> 0 then do:
      return error substitute( "&1. Каталог &2 отсутствует, а создать его не удалось.", vss-workfile, p0-temp-dir ).
    end.
  end.
  if p0-file-name <> ? then do:
    v-fullfilename = p0-source-dir + chr(92) + p0-file-name .
    assign
      file-info:file-name = v-fullfilename
    .
    if file-info:file-type = ?
      or not ( file-info:file-type begins "F":U )
    then do:
      return error substitute( "&1. Исходный файл &2 не найден.", vss-workfile, v-fullfilename ).
    end.
    v-r-index = r-index(p0-file-name, '.':u) .
    if v-r-index > 0 then assign
      v-filenamenoext = substring( p0-file-name, 1, v-r-index - 1 )
      v-fileext       = substring( p0-file-name, v-r-index + 1 )
    .
    else assign
      v-filenamenoext = p0-file-name
      v-fileext       = "":U
    .
    run ext-system-attr-value in this-procedure (
                                      input  p-esys-id
                                     ,input  p-db-num
                                     ,input  'cert-sign':U
                                     ,output v-cert-enstr
                                     ,output v-attr-type) .
    v-cert-enabled = logical (v-cert-enstr) .
    run file-s-g ( input p0-action
                  ,input p0-arch
                  ,input p0-file-name
                  ,input v-fullfilename
                  ,input v-filenamenoext
                  ,input v-fileext
                  ,input p0-source-dir
                  ,input p0-target-dir
                  ,input p0-temp-dir
                  ,input p-pck-num
                  ,input v-cert-enabled
                 ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  else do:
    if p-delivery-method = integer('2':U)
    or p-delivery-method = integer('1':U)
    or p-delivery-method = integer('5':U)
    or p-delivery-method = integer('9':U)
    then do:
      run ext-system-attr-value in this-procedure ( input p-esys-id
                                                    ,input p-db-num
                                                    ,input 'FTP':U
                                                    ,output v-ftp-ip
                                                    ,output v-type) no-error.
      run ext-system-attr-value in this-procedure ( input p-esys-id
                                                    ,input p-db-num
                                                    ,input 'Login':U
                                                    ,output v-ftp-login
                                                    ,output v-type) no-error.
      run ext-system-attr-value in this-procedure ( input p-esys-id
                                                    ,input p-db-num
                                                    ,input 'Password':U
                                                    ,output v-ftp-password
                                                    ,output v-type) no-error.
      run ext-system-attr-value in this-procedure ( input p-esys-id
                                                    ,input p-db-num
                                                    ,input 'Path':U
                                                    ,output v-ftp-path
                                                    ,output v-type) no-error.
      if p-delivery-method = integer('5':U) or p-delivery-method = integer('9':U) then do:
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                      ,input p-db-num
                                                      ,input 'IN-dir':U
                                                      ,output v-ftp-path-in
                                                      ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                      ,input p-db-num
                                                      ,input 'OUT-dir':U
                                                      ,output v-ftp-path-out
                                                      ,output v-type) no-error.
        v-flags = string(134217728).
      end.
      else do:
        v-ftp-path-in = "in".
        v-ftp-path-out = "out".
        v-flags = string(0).
      end.
      run get-log-file-name in p-parent-handle ( output log-file-name) no-error.
      assign
      v-parameter = v-ftp-ip + chr(4) +
                    v-ftp-login + chr(4) +
                    v-ftp-password + chr(4) +
                    v-flags + chr(4) +
                    (if v-ftp-path <> ''
                    then (trim (trim (trim(v-ftp-path
                                    , chr(92))
                                ,chr(47))
                          ,chr(92)) + chr(47))
                    else '') +
                    v-ftp-path-in + chr(4) +
                    "ftp-fl_CreateFileList" + chr(4) +
                    log-file-name.
      .
      for each buf_temp-filelist :
        delete buf_temp-filelist.
      end.
      run gbl/ftp-ls.p ( input parparentproc
                        ,input this-procedure:handle
                        ,input p-log-handle
                        ,input v-parameter ) no-error.
      if not can-find(first buf_temp-filelist) then do:
        if p-delivery-method = integer('5':U) or p-delivery-method = integer('9':U) then do:
          define variable v-to-return as logical no-undo .
          v-to-return = yes.
        end.
        else do:
        return.
      end.
      end.
      if not v-to-return then do:
        assign
        v-parameter = v-ftp-ip + chr(4) +
                      v-ftp-login + chr(4) +
                      v-ftp-password + chr(4) +
                    v-flags + chr(4) +
                    '' + chr(4) +
                    '' + chr(4) +
                      string(yes) + chr(4) +
                    "cb_getnextfilename" + chr(4) +
                      "process-edoc.txt"
        .
        run gbl/ftp-get.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input v-parameter ) no-error.
        if error-status:error then do:
          return error return-value.
        end.
      end.
    end.
    input stream FLStream from os-dir ( p0-source-dir ) .
    v-current-pack-num = p-pck-num - 1.
    repeat
    on error undo, return error
    :
      import stream FLStream v-filename v-fullfilename v-filetype.
      v-r-index = r-index(v-filename, '.':u) .
      if v-r-index > 0 then assign
        v-filenamenoext = substring( v-filename, 1, v-r-index - 1 )
        v-fileext       = substring( v-filename, v-r-index + 1 )
      .
      else assign
        v-filenamenoext = v-filename
        v-fileext       = "":U
      .
      if v-filetype begins "F"
        and v-r-index > 0
        and lookup(  v-fileext,  "$$$"  ) = 0
      then do:
        assign
          file-info:file-name = v-fullfilename
        .
      //  if lookup(entry( num-entries( v-filename, "." ), v-filename, "." ), "$$$") = 0 and
           if file-info:file-type MATCHES "*W*":U
          and file-info:file-type MATCHES "*R*":U
          and not ( file-info:file-type MATCHES "*H*":U )
        then do:
          v-current-pack-num = v-current-pack-num + 1.
          // переносит пакет из exch в heap и распаковывает его там, если он архив
          run file-s-g ( input p0-action
                        ,input p0-arch
                        ,input v-filename
                        ,input v-fullfilename
                        ,input v-filenamenoext
                        ,input v-fileext
                        ,input p0-source-dir
                        ,input p0-target-dir
                        ,input p0-temp-dir
                        ,input v-current-pack-num
                        ,input false
                      ) no-error.
          if error-status :error then do:
            return error return-value.
          end.
          if p-delivery-method = integer('5':U) or p-delivery-method = integer('9':U) then do:
            define variable v-caller-handle as handle no-undo .
            v-caller-handle = this-procedure:instantiating-procedure.
            if lookup("cb_fill-filelist", v-caller-handle:internal-entries) > 0 then do:
              run cb_fill-filelist in v-caller-handle ( input v-filename, input p-delivery-method) no-error.
            end.
          end.
        end.
      end.
    END.
    input stream FLStream close.
  end.
  return .
end.
procedure file-s-g private :
  define input parameter p-action     as character no-undo .
  define input parameter p-arch       as logical   no-undo .
  define input parameter p-file-name  as character no-undo .
  define input parameter p-fullfile-name    as character no-undo .
  define input parameter p-file-name-no-ext as character no-undo .
  define input parameter p-file-ext   as character no-undo .
  define input parameter p-source-dir as character no-undo .
  define input parameter p-target-dir as character no-undo .
  define input parameter p-temp-dir   as character no-undo .
  define input parameter p-current-pack-num as integer no-undo .
  define input parameter p-cert-enabled as logical no-undo .
    define variable v-arch             as logical   no-undo .
    define variable v-arh-name         as character no-undo .
    define variable v-arh-type         as character no-undo .
    define variable v-file-hash        as character no-undo .
    define variable v-file-source-arj  as character no-undo .
    define variable v-file-temp        as character no-undo .
    define variable v-file-target      as character no-undo .
    define variable v-file-source-all  as character no-undo .
    define variable v-log-file-source      as character no-undo .
    define variable v-log-file-source-arj  as character no-undo .
    define variable v-log-file-temp        as character no-undo .
    define variable v-log-file-target      as character no-undo .
    define variable v-zip-command      as character no-undo .
    define variable v-unzip-command    as character no-undo .
    define variable v-err-mess         as character no-undo .
    define variable v-send-log         as logical   no-undo .
    define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
  do
  on error undo, return error
  :
    assign
      v-file-temp       = p-temp-dir   + chr(92) + p-file-name
      v-file-target     = p-target-dir + chr(92) + p-file-name
    .
  case p-delivery-method:
    when integer('2':U) or
    when integer('1':U) then do:
      v-arh-name = ''.
      p-arch = no.
    end.
    when integer('4':U) then do:
      v-arh-name = "".
      v-arh-type = "".
      p-arch = no.
    end.
    when integer('5':U) then do:
      v-arh-name = ''.
      p-arch = no.
    end.
    when integer('9':U) then do:
      v-arh-name = ''.
      p-arch = no.
    end.
    when integer('3':U) then do:
      v-arh-name = search('exe/pkzipc.exe':U).
      v-arh-type = "zip".
      if p-action = "put" then do :
            if search(p-source-dir + chr(92) + p-file-name-no-ext + ".LOG") <> ? then do:
              v-send-log = yes.
              assign
              v-log-file-source     = p-source-dir + chr(92) + p-file-name-no-ext + ".LOG"
              v-log-file-temp       = p-temp-dir   + chr(92) + p-file-name-no-ext + ".LOG"
              v-log-file-target     = p-target-dir + chr(92) + p-file-name-no-ext + ".LOG"
              .
            end.
      end .
    end.
    when integer('11':U) then do:
      p-arch = yes.
      v-arh-type = "zip".
      if p-action = "put":U
      or p-action = "fput" then do :
                               v-arh-name = search( "exe/7z.exe":U ) .
        if v-arh-name = ? then v-arh-name = search( "exe/7za.exe":U ) .
      end .
      else do :
                               v-arh-name = search('exe/pkzipc.exe':U).
      end .
      if p-file-ext = "zip" then do :
        if p-action = "get" then do :
          if v-arh-name = ? then
            return error substitute( "&1. Программа архиватор не найдена", vss-workfile ).
          v-arch = true .
        end .
      end .
      else do :
        if p-action = "get" then do :
          if not can-do ("xml,p7s,p7c", p-file-ext) then return .
          v-arch = false .
        end .
      end .
    end.
    otherwise do :
        v-arh-name = search( "exe/arj32.exe":U ) .
      if v-arh-name = ? then
        v-arh-name = search( "exe/arj.exe":U ) .
      v-arh-type = "arj".
    end .
  end case .
  if p-action = "get" or p-action = "fget" then do:
    if lookup( p-file-ext, "arj") <> 0
    or lookup( p-file-ext, "zip") <> 0 then do:
      run write-to-log in p-parent-handle ( substitute( "Прием файла &1 (&2)", p-fullfile-name, v-arh-name ) ) .
      if v-arh-name = ? then
         return error substitute( "&1. Программа архиватор не найдена!", vss-workfile ).
      v-arch = true .
    end.
    else do:
      run write-to-log in p-parent-handle ( substitute( "Прием файла &1 (copy)", p-fullfile-name ) ) .
      v-arch = false .
    end.
  end .
    run gbl/md5.p(p-fullfile-name, output v-file-hash).
    run write-to-log in p-parent-handle ( substitute("Файл: &1; Контрольная сумма: &2.", p-fullfile-name,  v-file-hash) ) .
    case p-action :
      when "fput" or
      when "fget" then .
      when "put" then do :
      end .
      otherwise do :
      if p-delivery-method = integer('1':U)
      or p-delivery-method = integer('3':U)
      or p-delivery-method = integer('5':U)
      or p-delivery-method = integer('9':U)
      then do:
        find first buf_esys-all-attr share-lock where
                  buf_esys-all-attr.attr-code = 'custom-pack-name':U
              and buf_esys-all-attr.table-name = 'esys-pck-rcvd':U
              and buf_esys-all-attr.key1 = p-current-pack-num
              and buf_esys-all-attr.key2 = p-esys-id
              and buf_esys-all-attr.key5 = p-db-num
              and buf_esys-all-attr.key6 = g#db-num
              no-error .
        if not available buf_esys-all-attr then do:
          create buf_esys-all-attr.
          assign
          buf_esys-all-attr.attr-code = 'custom-pack-name':U
          buf_esys-all-attr.table-name = 'esys-pck-rcvd':U
          buf_esys-all-attr.key1 = p-current-pack-num
          buf_esys-all-attr.key2 = p-esys-id
          buf_esys-all-attr.key5 = p-db-num
          buf_esys-all-attr.key6 = g#db-num
          .
        end.
        if p-delivery-method = integer('3':U) then do:
          buf_esys-all-attr.attr-value = p-file-name-no-ext + ".DAT".
        end.
        else do:
          buf_esys-all-attr.attr-value = p-file-name.
        end.
      end.
      end .
    end case .
    if p-action = "put":U
    or p-action = "fput"
    then do:
      if p-arch = true then do:
        if v-arh-name = ? then do:
          return error substitute( "&1. Программа архиватор не найдена!", vss-workfile ).
        end.
        run write-to-log in p-parent-handle ( substitute( "Отправка файла &1 (&2)", p-fullfile-name, v-arh-name ) ).
        if v-arh-type = "arj" then do:
        assign
          v-file-source-arj = p-source-dir + chr(92) + p-file-name-no-ext + ".arj":U
          v-file-temp       = p-temp-dir   + chr(92) + p-file-name-no-ext + ".arj":U
          v-file-target     = p-target-dir + chr(92) + p-file-name-no-ext + ".arj":U
        .
        // @FUTU в зависимости от параметра запаковать или только файл, или файл вместе с цифровой подписью
        os-command silent
          value( v-arh-name )
          value( "a -e -y":U )
          value( v-file-source-arj )
          value( p-fullfile-name )
        .
        end.
        if v-arh-type = "zip" then do:
          case p-delivery-method:
            when integer('3':U) then do:
              assign
                v-file-source-arj = p-source-dir + chr(92) + p-file-name + ".zip":U
                v-file-temp       = p-temp-dir   + chr(92) + p-file-name + ".zip":U
                v-file-target     = p-target-dir + chr(92) + p-file-name + ".zip":U
              .
              if v-send-log then do:
                assign
                  v-log-file-source-arj = p-source-dir + chr(92) + p-file-name-no-ext + ".LOG" + ".zip":U
                  v-log-file-temp       = p-temp-dir   + chr(92) + p-file-name-no-ext + ".LOG" + ".zip":U
                  v-log-file-target     = p-target-dir + chr(92) + p-file-name-no-ext + ".LOG" + ".zip":U
                .
              end.
              os-command silent
                value( v-arh-name )
                value( "-add -path=none -span=700 ":U )
                value( v-file-source-arj )
                value( p-fullfile-name )
              .
              if v-send-log then do:
                os-command silent
                  value( v-arh-name )
                  value( "-add -path=none -span=700 ":U )
                  value( v-log-file-source-arj )
                  value( v-log-file-source )
                .
              end.
            end.
            when integer('11':U) then do:
              assign
                v-file-source-arj = p-source-dir + chr(92) + p-file-name-no-ext + ".zip":U
                v-file-temp       = p-temp-dir   + chr(92) + p-file-name-no-ext + ".zip":U
                v-file-target     = p-target-dir + chr(92) + p-file-name-no-ext + ".zip":U
              .
              v-zip-command =
              if p-cert-enabled then
                 substitute( "&1 a -tzip -y &2 &3 &4&5&6.p7s":U
                   , v-arh-name
                   , v-file-source-arj
                   , p-fullfile-name
                   , p-source-dir, chr(92) , p-file-name-no-ext
                 )
              else
                 substitute( "&1 a -tzip -y &2 &3":U, v-arh-name, v-file-source-arj, p-fullfile-name )
              .
              os-command silent value( v-zip-command ) .
              if not availfile(v-file-source-arj)
              then do:
                return error substitute( "&1. Заархивированный файл &2 не найден или имеет нулевой размер.", vss-workfile, v-file-source-arj ).
              end.
              run write-to-log in p-parent-handle ( substitute( "Файл &1 заархивирован в &2)", p-fullfile-name, v-file-source-arj ) ).
            end.
            otherwise do:
              assign
                v-file-source-arj = p-source-dir + chr(92) + p-file-name-no-ext + ".zip":U
                v-file-temp       = p-temp-dir   + chr(92) + p-file-name-no-ext + ".zip":U
                v-file-target     = p-target-dir + chr(92) + p-file-name-no-ext + ".zip":U
                v-file-source-all = p-source-dir + chr(92) + p-file-name-no-ext + ".*":U
              .
              os-command silent
                value( v-arh-name )
                value( "-add -path=none ":U )
                value( v-file-source-arj )
                value( v-file-source-all )
                value( ">> pkzipc-log.txt" )
              .
              assign
                file-info:file-name = v-file-source-arj
              .
              if file-info:file-type = ?
                or not ( file-info:file-type begins "F":U )
              then do:
                return error substitute( "&1. Заархивированный файл &2 не найден.", vss-workfile, v-file-source-arj ).
              end.
              run write-to-log in p-parent-handle ( substitute( "Файл &1 заархивирован в &2)", p-fullfile-name, v-file-source-arj ) ).
            end.
          end.
        end.
      end.
      else do:
        assign
        v-file-source-arj = p-source-dir + chr(92) + p-file-name
        v-file-temp       = p-temp-dir   + chr(92) + p-file-name
        v-file-target     = p-target-dir + chr(92) + p-file-name
        .
        run write-to-log in p-parent-handle ( substitute( "Отправка файла &1 (copy)", p-fullfile-name ) ).
        assign
          v-file-source-arj = p-fullfile-name
        .
      end.
      run del-file ( input v-file-temp ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
      if v-send-log then do:
        run del-file ( input v-log-file-temp ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
      end.
      run write-to-log in p-parent-handle ( substitute( "Копирование файла &1 во временную папку &2)", v-file-source-arj, v-file-temp ) ).
      os-copy value( v-file-source-arj ) value( v-file-temp ).
      if os-error <> 0 then do:
        run adm/os-err.p ( output v-err-mess ).
        return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-file-temp, p-target-dir, chr(10), v-err-mess ) .
      end.
      if v-send-log then do:
        os-copy value( v-log-file-source-arj ) value( v-log-file-temp ).
        if os-error <> 0 then do:
          run adm/os-err.p ( output v-err-mess ).
          return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-log-file-temp, p-target-dir, chr(10), v-err-mess ) .
        end.
      end.
      if p-arch = true then do:
        run write-to-log in p-parent-handle ( substitute( "Удаление файла &1)", v-file-source-arj ) ).
        run del-file ( input v-file-source-arj ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        if v-send-log then do:
          run del-file ( input v-log-file-source-arj ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
        end.
        if p-delivery-method = integer('11':U)
        then do :
          v-unzip-command = substitute("&1 -extract -silent -nofix -over=all &2 &3":U
                                      , search('exe/pkzipc.exe':U)
                                      , v-file-temp
                                      , p-temp-dir
                                      ) .
          os-command silent value( v-unzip-command ) .
          if searchfile(p-temp-dir + chr(92) + p-file-name-no-ext + ".xml":U) = ?
          then do :
            find first buf_esys-pck-sent exclusive-lock where
                      buf_esys-pck-sent.esys-id = p-esys-id
                  and buf_esys-pck-sent.db-num = p-db-num
                  and buf_esys-pck-sent.esps-cr-db-num = p-cr-db-num
                  and buf_esys-pck-sent.esps-pack-num = p-pck-num.
            assign
              buf_esys-pck-sent.esps-SendTxtDate = ?
              buf_esys-pck-sent.esps-sendtxttime = ""
              buf_esys-pck-sent.esps-sendtxttimeint = 0
              buf_esys-pck-sent.esps-crenum = buf_esys-pck-sent.esps-crenum - 1
              buf_esys-pck-sent.esps-total-recs = 0
            .
            run del-file ( input v-file-temp ) no-error .
            if error-status :error then do:
              return error return-value .
            end.
            run write-to-log in p-parent-handle (  substitute( "&1. Невозможно разархивировать созданный файл &2 . Ошибка архивации", vss-workfile, v-file-temp ) ).
            return .
          end .
          else do :
            run del-file ( input searchfile(p-temp-dir + chr(92) + p-file-name-no-ext + ".xml":U) ) no-error .
            if error-status :error then do:
              return error return-value .
            end.
            if p-cert-enabled
            then do :
              run del-file ( input searchfile(p-temp-dir + chr(92) + p-file-name-no-ext + ".p7s":U) ) no-error .
            end .
          end .
        end .
      end.
      run write-to-log in p-parent-handle ( substitute( "Перенос файла из временной папки &1 в &2)", v-file-temp, v-file-target ) ).
      run ren-file ( input v-file-temp
                    ,input v-file-target
                   ) no-error .
      if error-status :error then do:
        assign
          v-err-mess = return-value
        .
        run del-file ( input v-file-temp ) no-error .
        if error-status :error then do:
          assign
            v-err-mess = v-err-mess + chr(10) + return-value
          .
        end.
        return error v-err-mess .
      end.
      if v-send-log then do:
        run ren-file ( input v-log-file-temp
                      ,input v-log-file-target
                    ) no-error .
        if error-status :error then do:
          assign
            v-err-mess = return-value
          .
          run del-file ( input v-log-file-temp ) no-error .
          if error-status :error then do:
            assign
              v-err-mess = v-err-mess + chr(10) + return-value
            .
          end.
          return error v-err-mess .
        end.
      end.
      if p-action = "put"
      and (  p-delivery-method = integer('2':U)
          OR p-delivery-method = integer('1':U)
          OR p-delivery-method = integer('5':U)
          OR p-delivery-method = integer('9':U)
          )
      then do:
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                     ,input p-db-num
                                                     ,input 'FTP':U
                                                     ,output v-ftp-ip
                                                     ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                     ,input p-db-num
                                                     ,input 'Login':U
                                                     ,output v-ftp-login
                                                     ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                     ,input p-db-num
                                                     ,input 'Password':U
                                                     ,output v-ftp-password
                                                     ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                     ,input p-db-num
                                                     ,input 'Path':U
                                                     ,output v-ftp-path
                                                     ,output v-type) no-error.
        if p-delivery-method = integer('5':U) or p-delivery-method = integer('9':U) then do:
          run ext-system-attr-value in this-procedure ( input p-esys-id
                                                        ,input p-db-num
                                                        ,input 'IN-dir':U
                                                        ,output v-ftp-path-in
                                                        ,output v-type) no-error.
          run ext-system-attr-value in this-procedure ( input p-esys-id
                                                        ,input p-db-num
                                                        ,input 'OUT-dir':U
                                                        ,output v-ftp-path-out
                                                        ,output v-type) no-error.
          v-flags = string(134217728).
        end.
        else do:
          v-ftp-path-in = "in".
          v-ftp-path-out = "out".
          v-flags = string(0).
        end.
       run get-log-file-name in p-parent-handle ( output log-file-name) no-error.
        assign
        v-parameter = v-ftp-ip + chr(4) +
                      v-ftp-login + chr(4) +
                      v-ftp-password + chr(4) +
                      v-flags + chr(4) +
                      (if v-ftp-path <> ''
                      then (trim (trim (trim(v-ftp-path
                                      , chr(92))
                                  ,chr(47))
                            ,chr(92)) + chr(47))
                      else '') +
                      v-ftp-path-out + chr(47) + p-file-name  + chr(4) +
                      p-target-dir + chr(47) + p-file-name + chr(4) +
                      string(no) + chr(4) +
                      log-file-name
        .
        run gbl/ftp-put.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input v-parameter ) no-error.
        if error-status:error then do:
           run write-to-log in p-parent-handle ( input  substitute("Ошибки при передаче файла &1 по FTP"
                                                                  , p-file-name
                                                                  )).
        end.
        else do:
          if p-delivery-method <> integer('5':U) and p-delivery-method <> integer('9':U) then do:
          run cur-time in this-procedure ( output v-today, output v-time).
          find first buf_esys-pck-sent exclusive-lock where
                    buf_esys-pck-sent.esys-id = p-esys-id
                and buf_esys-pck-sent.db-num = p-db-num
                and buf_esys-pck-sent.esps-cr-db-num = p-cr-db-num
                and buf_esys-pck-sent.esps-pack-num = p-pck-num.
          assign
          buf_esys-pck-sent.esps-rcvd = yes
          buf_esys-pck-sent.esps-RcvdTimeInt    = v-time
          buf_esys-pck-sent.esps-RcvdTime       = string( v-time, "HH:MM:SS" )
          buf_esys-pck-sent.esps-rcvddate       = v-today
          .
        end.
        end.
        run del-file ( input v-file-target ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
      end.
    end.
    if p-action = "get"
    or p-action = "fget"
    then do:
      if p-delivery-method = integer('11':U) then do:
        if v-arch then do:
          if not availfile(p-fullfile-name)
          then do:
            run write-to-log in p-parent-handle ( substitute("Файл &1 не найден или пустой! Пропускаем..."
                                                            , p-fullfile-name)  ) .
          end .
          else do :
            if lookup( p-file-ext, "zip") <> 0 then v-unzip-command =
              substitute("&1 -extract -silent -nofix -over=all &2 &3":U
                        , v-arh-name
                        , p-fullfile-name
                        , p-target-dir
                        ) .
            else
            if lookup( p-file-ext, "arj") <> 0 then v-unzip-command =
              substitute("&1 e -y &2 &3":U
                        , v-arh-name
                        , p-fullfile-name
                        , p-target-dir
                        ) .
            run write-to-log in p-parent-handle ( substitute("Команда на распаковку &1: &2"
                                                            , p-file-ext, v-unzip-command)  ) .
            os-command silent value( v-unzip-command ) .
            if os-error <> 0 and log-manager:logfile-name ne ?
            then do:
                log-manager:write-message("Ошибка при распаковке os-error: " + string(os-error) , "!sxg-pack!").
            end.
            if searchfile(p-target-dir + chr(92) + p-file-name-no-ext + ".xml":U) = ?
            then do :
              run write-to-log in p-parent-handle ( substitute("Ошибка при распаковке! Файл &1 не является архивом, либо архив битый. Пропускаем..."
                                                            , p-fullfile-name)  ) .
            end .
            else do :
              run del-file ( input p-fullfile-name ) no-error .
              if error-status :error then do:
                return error return-value .
              end.
            end .
          end.
        end.
        else do :
          run del-file ( input v-file-target ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
          run ren-file ( input p-fullfile-name, input v-file-target ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
        end .
      end .
      else do :
        run ren-file ( input p-fullfile-name, input v-file-temp ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        run del-file ( input v-file-target ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        os-copy value( v-file-temp ) value( v-file-target ).
        if os-error <> 0 then do:
          run adm/os-err.p ( output v-err-mess ).
          return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-file-temp, p-target-dir, chr(10), v-err-mess ).
        end.
        run del-file ( input v-file-temp ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        if v-arch then do:
        if lookup( p-file-ext, "zip") <> 0 then do:
          v-unzip-command = substitute("&1 -extract -silent -nofix -over=all &2 &3":U
                                      , v-arh-name
                                      , v-file-target
                                      , p-target-dir
                                      ) .
        end.
        else
        if lookup( p-file-ext, "arj") <> 0 then do:
          v-unzip-command = substitute("&1 e -y &2 &3":U
                                      , v-arh-name
                                      , v-file-target
                                      , p-target-dir
                                      ) .
        end.
          run write-to-log in p-parent-handle (  substitute("Команда на распаковку &1: &2", p-file-ext, v-unzip-command)  ) .
          os-command silent value( v-unzip-command ) .
          run del-file ( input v-file-target ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
      end.
      end .
    end.
  end.
end procedure.
procedure del-file :
  define input parameter p-del-file-name as character no-undo .
  do
  on error undo, return error
  :
    define variable v-ind      as integer   no-undo .
    define variable v-err-code as integer   no-undo .
    define variable v-err-mess as character no-undo .
    define variable v-str      as character no-undo .
    assign
      file-info:file-name = p-del-file-name
    .
    if file-info:file-type <> ? then do:
      if file-info:file-type begins "F":U then do:
        assign
          v-str = "файл"
        .
      end.
      else do:
        if file-info:file-type begins "D":U then do:
          assign
            v-str = "каталог"
          .
        end.
        else do:
          assign
            v-str = "не знаю что"
          .
        end.
      end.
      bl1:
      do v-ind = 1 to 60 :
        os-delete value( p-del-file-name ).
        assign
          v-err-code = os-error
          file-info:file-name = p-del-file-name
        .
        if v-err-code = 0
          or file-info:file-type = ?
        then do:
          leave bl1 .
        end.
        pause 1 no-message .
      end.
      if os-error <> 0 then do:
        run adm/os-err.p ( output v-err-mess ).
        return error substitute( "&1. Невозможно удалить &2 &3&4&5", vss-workfile, v-str, p-del-file-name, chr(10), v-err-mess ).
      end.
    end.
  end.
  return.
end procedure.
procedure ren-file :
  define input parameter p-file-source as character no-undo .
  define input parameter p-file-target as character no-undo .
  do
  on error undo, return error
  :
    define variable v-ind      as integer   no-undo .
    define variable v-err-code as integer   no-undo .
    define variable v-err-mess as character no-undo .
    run del-file ( input p-file-target ) no-error .
    if error-status :error then do:
      return error return-value .
    end.
    bl1:
    do v-ind = 1 to 60 :
      os-rename value( p-file-source ) value( p-file-target ).
      assign
        v-err-code = os-error
        file-info:file-name = p-file-source
      .
      if v-err-code = 0
        or file-info:file-type = ?
      then do:
        leave bl1 .
      end.
      pause 1 no-message .
    end.
    if v-err-code <> 0 then do:
      run adm/os-err.p ( output v-err-mess ).
      return error substitute( "&1. Невозможно переименовать файл &2 в &3&4&5", vss-workfile, p-file-source, p-file-target, chr(10), v-err-mess ).
    end.
  end.
end procedure.
procedure cb_getnextfilename :
define input-output parameter p-rfile-name as character no-undo .
define input-output parameter p-lfile-name as character no-undo .
define buffer buf_temp-filelist for temp-filelist.
do
on error undo, return error
:
  find first buf_temp-filelist where
            buf_temp-filelist.full-name > p-rfile-name no-error .
  if available buf_temp-filelist then do:
    assign
    p-rfile-name = buf_temp-filelist.full-name
    p-lfile-name =  p0-source-dir + chr(47) + buf_temp-filelist.file-name
    .
  end.
  else do:
    assign
    p-rfile-name = ''
    p-lfile-name = ''
    .
  end.
end.
end procedure.
