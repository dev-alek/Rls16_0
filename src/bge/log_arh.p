block-level on error undo, throw.
/*

$Revision: b147bda3dbf4, 1291, rls $
$Author: SSlivenko $
$Date: Tue Apr 10 12:03:17 2018 +0300 $
$Workfile: log_arh.p $
$Archive: bge/log_arh.p $

Архивация логов

Автор: Сливенко Сергей Андреевич
Дата создания: 15/01/18
Author: Slivenko Sergey
Creation date: 15/01/18

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cre-db-num     as integer      no-undo .
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define input parameter p-db-num         as integer      no-undo .

define variable vss-revision    as character no-undo init "$Revision: b147bda3dbf4, 1291, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:03:17 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: log_arh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/log_arh.p $":U .
define variable vss-description as character no-undo init "Импорт данных по ДК из текстового файла - исполняемый модуль - вызов по расписанию".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ adm/auto-def.i    }
{ ref/shd-attr.i    }
{ gbl/cur-time.i }

define variable v-dir-name  as character no-undo .
define variable v-dir-type  as character no-undo .
define variable v-can-read  as logical   no-undo .
define variable v-param-list    as character     no-undo.
define variable v-param-type    as character     no-undo.
define variable v-computer-tcp-name    as character no-undo .
define variable v-computer-ip-addr     as character no-undo .
define variable v-target    as character no-undo .

define stream temp-list .
define stream work-list .
define stream news-list .
define stream oxml-list .
define stream log-list .

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

do
on error undo, return error return-value
:
  


&scop display-message    run write-log-and-file in p-log-handle (  ~
        input 1                                                      ~
      , input log-file-name                                          ~
      , input 1                                                      ~
      , input ~{&my-message~})


    assign
    log-file-name = "shd-free.log".

    run gbl/set-gbl.p
      (input  true
      ,input  g#auto-user-id
      ,input  g#auto-user-password
      ) no-error.
    if error-status :error
    then do:
      def var v-err-str as character no-undo.
      v-err-str = error-status:get-message(error-status:num-messages) + {&new-line} + return-value.
       
&scop my-message   substitute("!!!Ошибка при инициализации переменных g#... &1&2" ~
                                     , v-err-str ~
                                     , ~{&new-line~})

       {&display-message}.
                        
        return.
    end.
    
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , output v-param-list
        , output v-param-type
    ).
    if v-param-list = "":U then do:

&scop my-message   substitute("!!!Не заданы параметры импорта данных из ААЗС &1&2" ~
                                     , p-task-num        ~
                                     , ~{&new-line~})

       {&display-message}.
       return.
    end.
    
    v-dir-name = v-param-list no-error.
    

    assign
    file-info:file-name = v-dir-name
    v-dir-type = file-info:file-type
    .
    if index( v-dir-type, "D" ) = 0 then do:
&scop my-message   substitute("!!!Выбранный для импорта каталог &1 - недоступен&2" ~
                                     , v-dir-name ~
                                     , ~{&new-line~})

      {&display-message}.
      return .
    end.
    
    run gbl/tcp-info.p
      (output v-computer-tcp-name
      ,output v-computer-ip-addr
      ) .
    
    run main-proc no-error .
    if error-status:error then do:
&scop my-message   substitute("!!!Ошибка при архивации логов&3&1&3&2&3" ~
                                     , return-value ~
                                     , error-status:get-message(1) ~
                                     , ~{&new-line~})

      {&display-message}.
    end.
    else do:
&scop my-message   substitute("!!!Архивация логов завершена.&1" ~
                                     , ~{&new-line~})

      {&display-message}.
    end.
                        
end. /*doe*/

procedure main-proc :
  
  define variable v-temp-dir as character no-undo .
  define variable v-work-dir as character no-undo .
  
  define variable v-section   as character no-undo .
  define variable v-key       as character no-undo .
  define variable v-news-dir  as character no-undo .
  define variable v-oxml-dir  as character no-undo .
  define variable v-log-dir   as character no-undo .
  
  define variable v-arh-name         as character no-undo .
  
  define variable v-file                  as character no-undo .
  define variable v-path                  as character no-undo .
  define variable v-mask                  as character no-undo .
  define variable v-extension             as character no-undo .
  define variable v-file-name-without-ext as character no-undo .
  define variable v-filelist-total-file-num           as integer      no-undo .
  
  define buffer buf_temp-filelist for temp-filelist .
  
  v-temp-dir = session:temp-directory .
  
  file-info:file-name = "." .
  v-work-dir = file-info:full-pathname .
  
  assign
    v-section = 'news':u
    v-key     = 'nws-heap-dir':u
  .
  get-key-value section v-section key v-key value v-news-dir .
  
  assign
    v-section = 'OXML':u
    v-key     = 'oxml-dir':u
  .
  get-key-value section v-section key v-key value v-oxml-dir .
  
  assign
    v-section = 'REP-SETS':u
    v-key     = 'logDir':u
  .
  get-key-value section v-section key v-key value v-log-dir .
  
  
  assign
    v-arh-name = search( "exe/7z.exe":U )
  .
  if v-arh-name = ? then do:
    assign
      v-arh-name = search( "exe/7za.exe":U )
    .
  end. 
  
  v-target = v-dir-name + {&back-slash-char} + 
             v-computer-tcp-name + "_" + 
             string(year(today), "9999") + string(month(today), "99") + string(day(today), "99") +
             "-" + replace(string(time, "hh:mm"), ":", "") + ".zip".
  
  empty temp-table temp-filelist.
  
  
/*  ТЕМПОВАЯ ПАПКА  */
  input stream temp-list from os-dir( v-temp-dir ).
  
  repeat
  on error undo, return error
  :
    import stream temp-list v-file v-path v-mask .

    /* проверяем, что найден файл */
    if  v-mask <> ?
    and v-mask begins 'F':u
    then do:
      /* это обычный файл */
    end.
    else do:
      next . /* --->>>--- */
    end.
    
    if v-file begins "auto-st"
    or v-file begins "calc-rep"
    or v-file begins "extgetcd"
    or v-file begins "ext-sale"
    or v-file begins "Objahsp"
    or v-file begins "Objarh"
    or v-file begins "Saleclos"
    or v-file begins "shd-free"
    or v-file begins "pomi"
    or v-file begins "calc-arc"
    or v-file begins "calc-ord"
    or v-file begins "ext-exp"
    or v-file begins "alc-rsrv"
    or v-file begins "exp-ATD"
    or v-file begins "rvs-err"
    or v-file begins "pmp-err"
    or v-file begins "pump.err"
    or v-file begins "revis.err"
    or v-file begins "delfsale"
    or v-file begins "process-fdoc"
    or v-file begins "sktsrv"
    or v-file begins "svn-err"
    or v-file begins "get-cd"
    or v-file begins "send-cd"
    or v-file begins "log-algo-pomi"
    then do :
      
    end.
    else do :
      next.
    end.

    if num-entries(v-file, '.':u) > 1
    then do:
      /* файл имеет расширение */
      assign
        v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
        v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
      .
    end.
    else do:
      /* файл имеет пустое расширение */
      assign
        v-extension = ''
        v-file-name-without-ext = v-file
      .
    end.

    create buf_temp-filelist .
    assign
      buf_temp-filelist.file-name        = v-file
      buf_temp-filelist.directory-name   = v-temp-dir
      buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
      buf_temp-filelist.file-extension   = v-extension
      buf_temp-filelist.full-name        = v-temp-dir + '/':u + v-file
    .
    
  end .  
  input stream temp-list close .
 
 
/*  РАБОЧАЯ ПАПКА  */  
  input stream work-list from os-dir( v-work-dir ).
  
  repeat
  on error undo, return error
  :
    import stream work-list v-file v-path v-mask .

    /* проверяем, что найден файл */
    if  v-mask <> ?
    and v-mask begins 'F':u
    then do:
      /* это обычный файл */
    end.
    else do:
      next . /* --->>>--- */
    end.
    
    if v-file begins "auto-st"
    or v-file begins "calc-rep"
    or v-file begins "extgetcd"
    or v-file begins "ext-sale"
    or v-file begins "Objahsp"
    or v-file begins "Objarh"
    or v-file begins "Saleclos"
    or v-file begins "shd-free"
    or v-file begins "pomi"
    or v-file begins "calc-arc"
    or v-file begins "calc-ord"
    or v-file begins "ext-exp"
    or v-file begins "alc-rsrv"
    or v-file begins "exp-ATD"
    or v-file begins "rvs-err"
    or v-file begins "pmp-err"
    or v-file begins "pump.err"
    or v-file begins "revis.err"
    or v-file begins "delfsale"
    or v-file begins "process-fdoc"
    or v-file begins "sktsrv"
    or v-file begins "svn-err"
    or v-file begins "get-cd"
    or v-file begins "send-cd"
    or v-file begins "log-algo-pomi"
    then do :
      
    end.
    else do :
      next.
    end.

    if num-entries(v-file, '.':u) > 1
    then do:
      /* файл имеет расширение */
      assign
        v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
        v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
      .
    end.
    else do:
      /* файл имеет пустое расширение */
      assign
        v-extension = ''
        v-file-name-without-ext = v-file
      .
    end.

    create buf_temp-filelist .
    assign
      buf_temp-filelist.file-name        = v-file
      buf_temp-filelist.directory-name   = v-work-dir
      buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
      buf_temp-filelist.file-extension   = v-extension
      buf_temp-filelist.full-name        = v-work-dir + '/':u + v-file
    .
    
  end .  
  input stream work-list close .


/*  НОВОСТНАЯ ПАПКА  */  
  input stream news-list from os-dir( v-news-dir ).
  
  repeat
  on error undo, return error
  :
    import stream news-list v-file v-path v-mask .

    /* проверяем, что найден файл */
    if  v-mask <> ?
    and v-mask begins 'F':u
    then do:
      /* это обычный файл */
    end.
    else do:
      next . /* --->>>--- */
    end.
    
    if v-file begins "news"
    then do :
      
    end.
    else do :
      next.
    end.

    if num-entries(v-file, '.':u) > 1
    then do:
      /* файл имеет расширение */
      assign
        v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
        v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
      .
    end.
    else do:
      /* файл имеет пустое расширение */
      assign
        v-extension = ''
        v-file-name-without-ext = v-file
      .
    end.

    create buf_temp-filelist .
    assign
      buf_temp-filelist.file-name        = v-file
      buf_temp-filelist.directory-name   = v-news-dir
      buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
      buf_temp-filelist.file-extension   = v-extension
      buf_temp-filelist.full-name        = v-news-dir + '/':u + v-file
    .
    
  end .  
  input stream news-list close .
  
  
/*  OXML ПАПКА  */  
  input stream oxml-list from os-dir( v-oxml-dir ).
  
  repeat
  on error undo, return error
  :
    import stream oxml-list v-file v-path v-mask .

    /* проверяем, что найден файл */
    if  v-mask <> ?
    and v-mask begins 'F':u
    then do:
      /* это обычный файл */
    end.
    else do:
      next . /* --->>>--- */
    end.
    
    if v-file begins "openxml"
    then do :
      
    end.
    else do :
      next.
    end.

    if num-entries(v-file, '.':u) > 1
    then do:
      /* файл имеет расширение */
      assign
        v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
        v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
      .
    end.
    else do:
      /* файл имеет пустое расширение */
      assign
        v-extension = ''
        v-file-name-without-ext = v-file
      .
    end.

    create buf_temp-filelist .
    assign
      buf_temp-filelist.file-name        = v-file
      buf_temp-filelist.directory-name   = v-oxml-dir
      buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
      buf_temp-filelist.file-extension   = v-extension
      buf_temp-filelist.full-name        = v-oxml-dir + '/':u + v-file
    .
    
  end .  
  input stream news-list close .  


/*  LOG ПАПКА  */   
  input stream log-list from os-dir( v-log-dir ).
  
  repeat
  on error undo, return error
  :
    import stream log-list v-file v-path v-mask .

    /* проверяем, что найден файл */
    if  v-mask <> ?
    and v-mask begins 'F':u
    then do:
      /* это обычный файл */
    end.
    else do:
      next . /* --->>>--- */
    end.
    
    if v-file begins "auto-st"
    or v-file begins "calc-rep"
    or v-file begins "extgetcd"
    or v-file begins "ext-sale"
    or v-file begins "Objahsp"
    or v-file begins "Objarh"
    or v-file begins "Saleclos"
    or v-file begins "shd-free"
    or v-file begins "pomi"
    or v-file begins "calc-arc"
    or v-file begins "calc-ord"
    or v-file begins "ext-exp"
    or v-file begins "alc-rsrv"
    or v-file begins "exp-ATD"
    or v-file begins "rvs-err"
    or v-file begins "pmp-err"
    or v-file begins "pump.err"
    or v-file begins "revis.err"
    or v-file begins "delfsale"
    or v-file begins "process-fdoc"
    or v-file begins "sktsrv"
    or v-file begins "svn-err"
    or v-file begins "get-cd"
    or v-file begins "send-cd"
    or v-file begins "log-algo-pomi"
    then do :
      
    end.
    else do :
      next.
    end.

    if num-entries(v-file, '.':u) > 1
    then do:
      /* файл имеет расширение */
      assign
        v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
        v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
      .
    end.
    else do:
      /* файл имеет пустое расширение */
      assign
        v-extension = ''
        v-file-name-without-ext = v-file
      .
    end.

    create buf_temp-filelist .
    assign
      buf_temp-filelist.file-name        = v-file
      buf_temp-filelist.directory-name   = v-log-dir
      buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
      buf_temp-filelist.file-extension   = v-extension
      buf_temp-filelist.full-name        = v-log-dir + '/':u + v-file
    .
    
  end .  
  input stream log-list close .
  
  
  
  os-delete value ("arhlog") recursive .

  os-create-dir value ("arhlog") .
  
  for each buf_temp-filelist no-lock :
    os-copy value (buf_temp-filelist.full-name) value ("arhlog\" + buf_temp-filelist.file-name).
    os-command silent
              value( substitute( "&1 a -tzip -y -ssw &2 &3":U, v-arh-name, v-target, (v-work-dir + "\arhlog\" + buf_temp-filelist.file-name) ) )
            .
    os-delete value (buf_temp-filelist.full-name) .        
  end.
  
  os-delete value ("arhlog") recursive .
  
end procedure .

procedure wri-log-and-file:
    define input parameter p-log-string     as char       no-undo.
/* процедура продублирована здесь, т.к. из более глубокого уровня не видна
   расшаренная переменная log-file-name, использующаяся только в автопроцессах */
&scop my-message   substitute("&1" ~
                              , p-log-string ~
                              , ~{&new-line~})

      {&display-message}.
end procedure .
