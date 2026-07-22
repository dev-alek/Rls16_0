block-level on error undo, throw.
define variable v-parameters         as character no-undo .
define variable v-compile-File       as character no-undo .
define variable v-log-file           as character no-undo .
define variable v-compile-parameters as character no-undo .
define variable ch           as character no-undo .
define variable v-ind        as integer   no-undo .
define variable alist        as character no-undo .
define stream sinp .
do
on error undo, return error return-value
:
  assign
    v-parameters = session :parameter
  .
  if num-entries(v-parameters) < 2
  then do:
    message  "error: not all parameters specified" skip
            '-param parameter must be like "<program.p>,<log.log>"'
      view-as alert-box.
    return.
  end.
  assign
    v-compile-file   = entry(1, v-parameters)
    v-log-file       = entry(2, v-parameters)
  .
  assign
    v-compile-file = replace(v-compile-file, '\':u, '/':u)
  .
  define variable v-dir-list             as character no-undo .
  define variable v-num-entries-dir-list as integer   no-undo .
  define variable v-dir-index            as integer   no-undo .
  define variable v-search-index         as integer   no-undo .
  assign
    v-dir-list             = 'adm,arc,bge,cmp,cus,exe,ibs/th/rul,ibs/th/gbl,gbl,nws,rcs,ref,rep,rul,str,trg,utl':u
    v-num-entries-dir-list = num-entries(v-dir-list)
  .
  do v-dir-index = 1 to v-num-entries-dir-list
  :
    assign
      v-search-index = r-index(v-compile-file, entry(v-dir-index, v-dir-list) + '/':u)
    .
    if v-search-index > 0
    then do:
      assign
        v-compile-file = substring(v-compile-file, v-search-index)
      .
      if entry(v-dir-index, v-dir-list) begins "ibs" then leave.
    end.
  end.
  if num-entries(v-parameters) > 2
  then do:
    assign
      v-compile-parameters = entry(3, v-parameters)
    .
  end.
  if connected("ub")
  then do:
    assign
      alist = ''
    .
    do v-ind = 1 to num-aliases
    :
      assign
        alist = alist + (if alist > "" then "," else "") + alias(v-ind)
      .
    end.
    do v-ind = 1 to num-entries('src,dst,dictdb,db-orig,db-copy,restseq,ubflt,ubfltdst,restseqflt':u)
    on error undo, leave
    :
      assign
        ch = entry(v-ind, 'src,dst,dictdb,db-orig,db-copy,restseq,ubflt,ubfltdst,restseqflt':u)
      .
      if lookup(ch, alist) = 0
      then do:
        create alias value(ch) for database ub.
        assign
          alist = alist + (if alist > "" then "," else "") + ch
        .
      end.
    end.
  end.
  define variable lsalbox as logical no-undo.
  assign
    lsalbox = session :system-alert-boxes
  .
  assign
    session :system-alert-boxes = false
  .
  define variable v-list-file-name as character no-undo .
  define variable v-xref-file-name as character no-undo .
  define variable v-prep-file-name as character no-undo .
  if lookup("list", v-compile-parameters, "_") > 0
  then do:
    assign
      v-list-file-name = "list.txt"
    .
  end.
  if lookup("xref", v-compile-parameters, "_") > 0
  then do:
    assign
      v-xref-file-name = "xref.txt"
    .
  end.
  if lookup("prep", v-compile-parameters, "_") > 0
  then do:
    assign
      v-prep-file-name = "prep_txt.p"
    .
  end.
  define variable v-output-pos as integer   no-undo .
  if search(v-compile-file) <> ""
  and search(v-compile-file) <> ?
  then do:
    define variable v-line          as character no-undo case-sensitive .
    define variable v-compare-start as character no-undo case-sensitive .
    define variable v-num-line      as integer   no-undo .
    define variable v-revision-ok as logical   no-undo .
    define variable v-reason      as character no-undo .
    assign
      v-revision-ok = false
    .
    input stream sinp from value(search(v-compile-file)) .
    repeat
    :
      import stream sinp unformatted v-line .
      assign
        v-num-line = v-num-line + 1
      .
      if v-num-line > 70
      then do:
        leave .
      end.
      assign
        v-compare-start = '$':u + "Revision:"
      .
      if  v-line begins v-compare-start
      and substring(v-line, length(v-line), 1) = '$'
      then do:
        import stream sinp unformatted v-line .
        assign
          v-num-line = v-num-line + 1
        .
        assign
          v-compare-start = '$':u + "Author:"
        .
        if  v-line begins v-compare-start
        and substring(v-line, length(v-line), 1) = '$':u
        then do:
        end.
        else do:
          leave .
        end.
        import stream sinp unformatted v-line .
        assign
          v-num-line = v-num-line + 1
        .
        assign
          v-compare-start = '$':u + "Date:"
        .
        if  v-line begins v-compare-start
        and substring(v-line, length(v-line), 1) = '$':u
        then do:
        end.
        else do:
          leave .
        end.
        import stream sinp unformatted v-line .
        assign
          v-num-line = v-num-line + 1
        .
        assign
          v-compare-start = '$':u + "Workfile:"
        .
        if  v-line begins v-compare-start
        and substring(v-line, length(v-line), 1) = '$':u
        then do:
        end.
        else do:
          leave .
        end.
        import stream sinp unformatted v-line .
        assign
          v-num-line = v-num-line + 1
        .
        assign
          v-compare-start = '$':u + "Archive:"
        .
        if  v-line begins v-compare-start
        and substring(v-line, length(v-line), 1) = '$':u
        then do:
        end.
        else do:
          leave .
        end.
        assign
          v-revision-ok = true
        .
        leave .
      end.
    end.
    input stream sinp close .
  end.
  output to value(v-log-file).
  compile value(v-compile-file)
    listing    value(v-list-file-name)
    xref       value(v-xref-file-name)
    preprocess value(v-prep-file-name)
    .
  if v-revision-ok <> true
  then do:
    put unformatted "** Стандартный заголовок. Не найден тэг " + v-compare-start + " (1)"  skip .
    put unformatted "** " + v-compile-file + " Не могу понять строку " + string(v-num-line) + ". (1)" skip .
  end.
  assign
    v-output-pos = seek(output)
  .
  if error-status :error
  or compiler :error
  or compiler :warning
  or v-output-pos <> 0
  then do:
    put unformatted "** Ошибка компиляции. (1)" skip .
    put unformatted "** " + v-compile-file + " Не могу понять строку 1. (1)" skip .
  end.
  output close.
  assign
    session :system-alert-boxes = lsalbox
  .
  quit.
end.
