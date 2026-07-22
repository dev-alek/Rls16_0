block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h_list.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/h_list.p $":U .
define variable vss-description as character no-undo init "формирование списка файлов-исходников    ".
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
define variable  v-fill-name   as character no-undo .
define variable  v-workfile_   as character no-undo .
define variable  v-author      as character no-undo .
define variable  v-description as character no-undo .
define variable  v-hlp as logical no-undo .
define variable g#log as logical no-undo .
define variable my-dir as character no-undo init "c:\work15_0\".
define variable v-exist as logical no-undo init false .
g#log =  session:SET-WAIT-STATE("GENERAL") .
define stream out-stream .
define stream htm-stream .
output stream out-stream to value (my-dir + "tt-help.txt") .
put stream out-stream unformatted
"Имя файла"                             at 1
"Workfile"                              at 12
"Author"                                at 25
"app"                                   at 40
"Написан"                               at 42
"Описание , то что после Archive"       at 50
skip
.
run filelist-dirlist-subdir-init (input  "y:\ver14_0\") no-error .
if error-status :error then
        message vss-workfile vss-revision vss-description skip
       "Ошибка  1" skip
        skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error
.
for each temp-dirlist
    on error undo, return error :
    run filelist-clear .
    run filelist-init
        ( temp-dirlist.dir-full-name  ,
          true                        ,
          "w"                         ,
          temp-dirlist.dir-short-name
          )  no-error .
        if error-status :error then
                message vss-workfile vss-revision vss-description skip
              "Ошибка 2 " skip
                skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error
        .
      for each temp-filelist
          on error undo, return error :
          run utl/h_ttable.p (
              input temp-filelist.full-name ,
              output   v-fill-name   ,
              output   v-workfile_   ,
              output   v-author      ,
              output   v-description ,
              output   v-hlp
                )
              no-error .
              if error-status :error then message vss-workfile vss-revision vss-description skip
                     "Ошибка 3 " skip
                      skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error
              .
            if not ( caps(trim(v-workfile_)) begins "E-" ) or true = true  then do:
                put stream out-stream unformatted
                temp-filelist.file-name                 at 1
                trim(v-workfile_)                       at 12
                trim(v-author)                          at 25
                .
                run make-htm.
                put stream out-stream unformatted
                string(v-hlp,"+/-")                                      at 40
                temp-dirlist.dir-short-name + string(v-exist,"+/-")      at 42
                substring(trim(v-description), 1, 200 )                  at 50
                skip
                .
            end.
      end.
end.
output stream out-stream close.
g#log =  session:SET-WAIT-STATE("") .
message "ВСЕ готово в " my-dir "tt-help.txt " .
procedure make-htm :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable v-header-page as character no-undo .
define variable v-descr        as character no-undo .
assign
v-header-page = v-description
v-descr =  temp-filelist.dir-short-name + " " + temp-filelist.file-name  + " " + v-author  + " " +  string(v-hlp,"+/-")
v-exist = false
.
if search(my-dir + temp-filelist.file-name-no-ext + ".htm") > '' then  do:
   v-exist = true .
   return .
end.
output stream htm-stream to value ( my-dir + temp-filelist.file-name-no-ext + ".htm") .
put stream htm-stream unformatted
'<html>                                                                                                          ' skip
'<head>                                                                                                          ' skip
'<title>' + v-header-page + '</title>                                                                            ' skip
'<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">                                      ' skip
'</head>                                                                                                         ' skip
'                                                                                                                ' skip
'<table border=0 cellspacing=0 cellpadding=0 width="100%" bgcolor="#649ccc"                                      ' skip
'style="width:100.0%;mso-cellspacing:0cm;background:#649CCC;mso-padding-alt:1.5pt 1.5pt 1.5pt 1.5pt">            ' skip
'  <tr>                                                                                                          ' skip
'    <td align="left">                                                                                           ' skip
'                                                                                                                ' skip
'      <span style="font-family:Helvetica,Arial; font-size:12pt; color:#FFFFFF"><b>' + v-header-page + '</b><b>  ' skip
'<br>                                                                                                            ' skip
'</b></span>                                                                                                     ' skip
'    </td>                                                                                                       ' skip
'    <td align="right">                                                                                          ' skip
'     <font face="Arial" size="2">                                                                               ' skip
'     <a href="th.htm">                                                                                          ' skip
'        <img name=main src="button_main.gif" border=0 alt="На главную страницу"></a>&nbsp;                      ' skip
'     <a href="th.htm">                                                                                          ' skip
'        <img name=prev src="button_prev.gif" border=0 alt="Предыдущая страница"></a>&nbsp;                      ' skip
'     <a href="th.htm">                                                                                          ' skip
'        <img name=next src="button_next.gif" border=0 alt="Следующая страница"></a>                             ' skip
'     </font>                                                                                                    ' skip
'    </td>                                                                                                       ' skip
'  </tr>                                                                                                         ' skip
'</table>                                                                                                        ' skip
'<br>                                                                                                            ' skip
'<body bgcolor="#FFFFFF" text="#000000" link=blue alink=purpul>                                                  ' skip
'                                                                                                                ' skip
'<p>' + v-descr + '</p>                                                                                            ' skip
'                                                                                                                ' skip
'<p><i><b><font size="+2">Управляющие кнопки:</font></b></i></p>                                                 ' skip
'<table width="100%" border="0" height="91">                                                                     '  skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Выход</b></td>                                                                           ' skip
'    <td width="84%">Выход из режима</td>                                                                        ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Печать</b></td>                                                                          ' skip
'    <td width="84%">Печать текущего списка </td>                                                                ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>История</b></td>                                                                         ' skip
'    <td width="84%">Просмотр истории изменений текущей строки </td>                                             ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Ввод</b></td>                                                                            ' skip
'    <td width="84%">Запомнить изменения и выйти из режима ввода и корректировки записи</td>                     ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Отказ</b></td>                                                                           ' skip
'    <td width="84%">Выход без запоминания изменений или без создания новой записи</td>                          ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Фильтр</b></td>                                                                          ' skip
'    <td width="84%">Вызов режима задания параметров для фильтрации записей</td>                                 '  skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%">&nbsp;</td>                                                                                 ' skip
'    <td width="84%">&nbsp;</td>                                                                                 ' skip
'  </tr>                                                                                                         ' skip
'</table>                                                                                                        ' skip
'</body>                                                                                                         ' skip
'</html>                                                                                                         ' skip
.
output stream htm-stream close.
return .
 end.
end procedure.
