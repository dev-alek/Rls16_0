block-level on error undo, throw.
define stream mProt.
output stream mProt to "upd-rc.txt" convert target "ibm866".


/*

$Revision: 2d3eafa142ca, 3655, rls $
$Author: EShklyar $
$Date: 2024/01/31 10:15:43 $
$Workfile: upd-rc.p $
$Archive: adm/upd-rc.p $

Обновление r-кодов, обновления должны лежать передаваемом в каталоге

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/22/08
Author: Dmitry Ukhanov
Creation date: 01/22/08


Автор1: Румянцев Юрий Александрович
Дата создания1: 02/16/06

*/

define input parameter p0-source-dir as character no-undo .

define variable vss-revision    as character no-undo init "$revision: 9 $":u .
define variable vss-author      as character no-undo init "$author: rumyantsev $":u .
define variable vss-date        as character no-undo init "$date: 23.03.07 13:37 $":u .
define variable vss-workfile    as character no-undo init "$workfile: upd-rc.p $":u .
define variable vss-archive     as character no-undo init "$archive: /ver14_0/adm/upd-rc.p $":u .
define variable vss-description as character no-undo init "Обновление r-кодов, обновления должны лежать передаваемом в каталоге".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ utl/search.i }
{ cmp/str-glbl.i }
{ adm/auto-def.i }
define variable CheckUpd      as class ibs.th.adm.upd.CheckUpd no-undo.

procedure write-log:
   define input  parameter iTabPosition as integer   no-undo.
   define input parameter i-message    as character no-undo.
    
   run write-to-log in this-procedure( i-message).
end.

procedure write-log-and-file:
   define input parameter iTabPosition  as integer   no-undo.
   define input parameter iFile         as character no-undo.
   define input parameter ilog-level    as integer   no-undo.
   define input parameter i-message     as character no-undo.
    
   run write-to-log in this-procedure( i-message).
end.

procedure writelog :
   define input parameter p-file-name AS CHAR     NO-UNDO.
   define input parameter p-log-level AS INTEGER  NO-UNDO.
   define input parameter p-log-string  AS CHAR     NO-UNDO.
   
   run write-to-log in this-procedure( p-log-string).
end procedure. /* writelog */

define variable p0-pathrc as character no-undo .
define variable v-pathrc         as character no-undo .
define variable v-filename         as character no-undo .
define variable v-fullfilename     as character no-undo .
define variable v-rc-filename     as character no-undo .
define variable v-filetype         as character no-undo .
define variable v-copy-err         as logical no-undo .

define variable v-delfile as char no-undo.
define variable v-date   as date no-undo .
define variable v-type   as character no-undo .
define variable v-txt   as char no-undo .
define variable v-arc   as char no-undo .
define variable oldg#news as logical no-undo .
define variable oldg#esys as logical no-undo .

define stream flstream.

define temp-table upgfile-tbl no-undo
  field nameupgfile  as char
  field fullnameupgfile  as char
  field dateupg as date
  field type as character
  index dupg is unique primary dateupg
.

define variable v-version           as character no-undo .
define variable v-locale            as character no-undo .
define variable v-SVNRev            as integer   no-undo .
define variable v-compilerVersion   as character no-undo .
define variable v-compile-date      as date      no-undo .
define variable v-time              as integer   no-undo .
define variable v-comment           as character no-undo .
define variable v-file-date         as date      no-undo .
define variable v-file-time         as integer   no-undo .
define variable v-releace           as integer   no-undo.
define variable v-patch             as integer   no-undo.
define variable v-branch            as integer   no-undo.
define variable mFileLog            as character no-undo.
define variable mDirLog             as character no-undo.
define variable mIsError            as logical   no-undo.

define variable v-program-tag     as character no-undo .

define new shared variable oxml-exch-dir as character no-undo .
define new shared variable oxml-heap-dir as character no-undo .
{ cmp/trg-def.i }
{ gbl/getcntxa.i }
define variable parparentproc as handle no-undo.
parparentproc = this-procedure.
/*&scoped-define PREFIX_LOG substitute("&1 &2 БД&3",string(today,"99.99.9999"), string(time,"HH:MM:SS"), g#db-num)*/
&scoped-define PREFIX_LOG substitute("БД&1 ", g#db-num) 

/* Дата компиляции */

run gbl/vertag.p (
      output v-version
    , output v-locale
    , output v-SVNRev
    , output v-compilerVersion
    , output v-compile-date
    , output v-time
    , output v-comment
    , output v-file-date
    , output v-file-time
    , output v-releace
    , output v-patch
    , output v-branch
) .
if v-compile-date = ? then v-compile-date = 01/01/1970.

define variable mRunFile as character no-undo.

CheckUpd = new ibs.th.adm.upd.CheckUpd ().
CheckUpd:workStop ().
run waitfram-show in this-procedure ( input "Идет обновление программ ТН. Ждите..." ).

put stream mProt unformatted "Каталог обновлений: " p0-source-dir skip.

/* Ищем где лежат r-коды   */
assign
  p0-pathrc = search( "adm/upd-rc.r":U )
.
if p0-pathrc = ? then do:
  assign
    p0-pathrc = search( "adm/upd-rc.p":U )
  .
  if p0-pathrc = ? then do:
    put stream mProt unformatted "Не найден путь на программы ТН" skip.
    return error "Не найден путь на программы ТН".
  end.
end.


put stream mProt unformatted "Путь к программам: " p0-pathrc skip.

/* Есть ли архиватор  */
assign
  v-arc = search( "exe/7za.exe":U )
.
if v-arc = ? then do:
assign
  v-arc = search( "exe/7z.exe":U )
.
end.
if v-arc = ? then do:
  put stream mProt unformatted "Не найдена программа 7z.exe" skip.
  return error "Не найдена программа 7z.exe, раскрыть обновления невозможно" .
end.


put stream mProt unformatted "Архиватор: " v-arc skip.

assign
  v-pathrc = substring(p0-pathrc, 1, r-index(p0-pathrc, "\") - 1 )
  v-pathrc = substring(v-pathrc, 1, r-index(v-pathrc, "\") - 1 )
  p0-pathrc = substring(v-pathrc, 1, r-index(v-pathrc, "\") - 1 )
  mFileLog  = substitute(
                "&1update&2&3&4_th.log", 
                ibs.th.gbl.gbl-inipar:logDir, 
                year(today), 
                string(month(today),"99"), 
                string(day(today),"99"))
  add-log-file-name = mFileLog
.

put stream mProt unformatted "путь к rc: " v-pathrc skip.
put stream mProt unformatted "v-pathrc: " v-pathrc skip.
put stream mProt unformatted "p0-pathrc: " p0-pathrc skip.
put stream mProt unformatted "mFileLog: " mFileLog skip.

/* Выбираем из каталога с новостями файлы апгрейда r-кодов  */
input stream flstream from os-dir ( p0-source-dir ) .

put stream mProt unformatted " " skip.
put stream mProt unformatted "обработка файлов из " p0-source-dir " " skip.

repeat
on error undo, return error
:
  import stream flstream v-filename v-fullfilename v-filetype.

  if v-filetype begins "f" and num-entries( v-filename, "." ) > 1
    and ( ( v-filename begins "rc_20")
          or ( v-filename begins "update_")
        )
  then do:
/*      Вызов этой программы происходит в  s-g-pack.p  ,причем там тоже стоит проверка на имя файла,*/
/*      если имена будем править здесь то надо поправить и там  */
    assign
      file-info:file-name = v-fullfilename
      v-txt = substring (v-filename,  index(v-filename, "_") + 1, 8)
      v-type = substring (v-filename,  index(v-filename, "_") + 10, 2)
      v-rc-filename       = p0-pathrc + "\" + v-filename
    .
    
    put stream mProt unformatted "найден файл: " v-filename skip.
    put stream mProt unformatted "копирование " v-fullfilename " " v-rc-filename skip.
    os-command silent
      value( "copy" )
      value( v-fullfilename )
      value( v-rc-filename )
    .
    if os-error <> 0 or search(v-rc-filename) = ? then do:
      put stream mProt unformatted "Невозможно скопировать файл: " v-fullfilename "в каталог" p0-pathrc skip.
      return error substitute("Невозможно скопировать файл &1 в каталог &2", v-fullfilename, p0-pathrc) .
    end.
    

    put stream mProt unformatted "Скопирован: " v-filename " в " v-rc-filename skip.
    v-date = date( integer(substring(v-txt,5,2)), integer(substring(v-txt,7,2)), integer(substring(v-filename, index(v-filename, "_") + 1, 4)) ) no-error.
    if error-status:error or v-date < 01/01/2000 then
    do:
       run write-to-log (substitute(
           "&1Имя файла &2 не соответствует шаблону update_20YYMMDD. Обновление не установлено.", 
           {&PREFIX_LOG}, 
           v-filename
       )).
       put stream mProt unformatted "Имя файла не соответствует шаблону update_20YYMMDD" v-filename skip.
    end.
    else
    do:
       find first upgfile-tbl no-lock
          where upgfile-tbl.dateupg = v-date
          no-error.
       if not available upgfile-tbl then do:
          /* Во временную таблицу запоминаем все файлы апгрейда  */
          create upgfile-tbl.
          assign
            upgfile-tbl.dateupg         = v-date
            upgfile-tbl.nameupgfile     = v-filename
            upgfile-tbl.fullnameupgfile = v-rc-filename
            upgfile-tbl.type            = v-type
          .
          put stream mProt unformatted "Добавлен в таблицу обновлений: " v-filename " дата: " v-date skip.
       end.
    end.
    
    /* Удаление апгрейдного файла из каталога новостей */
    os-delete value ( v-fullfilename ) recursive.
    /* Лог: удален исходный файл */
    put stream mProt unformatted "Удален  файл: " v-fullfilename skip.
  end.  /*   if v-filetype begins "f" and  */
  
  /* Для кассы */
  if v-filetype begins "f" and num-entries( v-filename, "." ) > 1
  and ( v-filename begins "UFO-")
  then do:

      put stream mProt unformatted "Найден UFO файл: " v-filename skip.
     
      os-command silent
        value( "copy" )
        value( v-fullfilename )
        value( p0-pathrc )
      .
      if os-error <> 0  or search(p0-pathrc + "/" + v-filename) = ? then do:
        put stream mProt unformatted "Невозможно скопировать: " v-fullfilename " в каталог" p0-pathrc  skip.
        return error substitute("Невозможно скопировать файл &1 в каталог &2", v-fullfilename, p0-pathrc) .
      end.
      
      put stream mProt unformatted "Скопирован UFO: " v-filename skip.
      
      if search (p0-pathrc + "/" + v-filename) = ?
      then
      v-copy-err = true .
      
      assign
        file-info:file-name = p0-pathrc + "\ufo_update"
      .
      if file-info:file-type = ? then do:
          os-create-dir value( p0-pathrc  + "\ufo_update" ). 
          if os-error <> 0 then do:
              put stream mProt unformatted "Невозможно создать папку: " p0-pathrc + "\ufo_update" skip.
              return error string ( "Невозможно создать папку " + p0-pathrc  + "\ufo_update" ).
          end.
          put stream mProt unformatted "Создана папка: " p0-pathrc + "\ufo_update" skip.
      end.
      else do :
          assign
            file-info:file-name = p0-pathrc + "\ufo_update-old"
          .
          if file-info:file-type <> ? then do:
              os-delete value ( p0-pathrc + "\ufo_update-old" ) recursive. 
              if os-error <> 0 then do:
                  os-rename  value ( p0-pathrc + "\ufo_update-old" ) value ( p0-pathrc + "\ufo_update-old1" ). 
                  if os-error <> 0 then do:
                      put stream mProt unformatted "Невозможно удалить папку " skip.
                      return error string ( "Невозможно удалить папку " + p0-pathrc + "\ufo_update-old, удалите ее сами" ).
                  end.
              end.
          end.
        
          os-rename  value ( p0-pathrc + "\ufo_update" ) value ( p0-pathrc + "\ufo_update-old" ). 
          if os-error <> 0 then do:
              put stream mProt unformatted "Невозможно переименовать папку "  p0-pathrc skip.
              return error string(( "Невозможно переименовать папку " + p0-pathrc + "\ufo_update для сохранности" )).
          end.

          put stream mProt unformatted "Папка переименована: " p0-pathrc + "\ufo_update -> " p0-pathrc + "\ufo_update-old" skip.

          put stream mProt unformatted "создаем rc папку " p0-pathrc  "\ufo_update" skip.          
          os-create-dir value( p0-pathrc  + "\ufo_update" ). /* создаем rc */
          if os-error <> 0 then do:
              os-rename  value ( p0-pathrc  + "\ufo_update-old") value ( p0-pathrc  + "\ufo_update" ). /* переименовываем rc-old в rc при ошибке создания  rc*/
              put stream mProt unformatted "Невозможно создать папку " p0-pathrc  "\ufo_update" skip.
              return error string ( "Невозможно создать папку " + p0-pathrc  + "\ufo_update" ).
          end.
          put stream mProt unformatted "Создана новая папка: " p0-pathrc + "\ufo_update" skip.
      end. 
      
      if not v-copy-err
      then do :
        v-txt = p0-pathrc + "\rc\exe\7z.exe" + " x -y -o" + p0-pathrc + "\ufo_update " +  p0-pathrc + "/" + v-filename.   
      end.
      else do :
        FILE-INFO:FILE-NAME = ".".
        v-txt = v-pathrc + "\exe\7z.exe" + " x -y -o" + p0-pathrc + "\ufo_update " +  FILE-INFO:FULL-PATHNAME + "/" + v-filename.  
      end.


      put stream mProt unformatted "разархивирование UFO: " v-txt skip.
      os-command silent value ( v-txt ) .
     
      v-pathrc = search( p0-source-dir + "/" + v-filename ).
      os-delete value ( v-pathrc ) recursive.
      put stream mProt unformatted "Удален UFO файл: " v-pathrc skip.
      
  end.
  
end.  /*  repeat  on error undo   */
input stream flstream close.

put stream mProt unformatted "обраб. файлы из " p0-source-dir skip.
put stream mProt unformatted " " skip.


UPDATE_CYCLE:
for each upgfile-tbl no-lock
on error undo, return error return-value
:

    put stream mProt unformatted "начало процесса обновления: " UpgFile-tbl.NameUpgFile " " skip.
    
    run write-to-log (substitute("&1начало процесса обновления &2", {&PREFIX_LOG}, UpgFile-tbl.NameUpgFile)).
    mIsError = upgfile-tbl.dateupg <= v-compile-date.
    run write-to-log (substitute(
                        "&1Сравнение даты обновления – &2", 
                        {&PREFIX_LOG}, 
                        if mIsError 
                          then "ошибка, дата обновления равна или меньше текущей версии r-кодов" 
                          else "успешно")
                      ).
    if mIsError then
    do: 
      put stream mProt unformatted "Пропуск дата <= текущей: " UpgFile-tbl.NameUpgFile skip.
      delete upgfile-tbl.
      next UPDATE_CYCLE.
    end.

    /* Удаление старых bat-файлов */
    mRunFile = SearchFile ("!beforeTH.bat").
    if SearchFile (mRunFile) <> ?
      then os-delete value ( mRunFile ).
    mRunFile = SearchFile ("!upd-rc-before.bat").
    if SearchFile (mRunFile) <> ?
      then os-delete value ( mRunFile ).
    mRunFile = SearchFile ("!upd-rc-after.bat").
    if SearchFile (mRunFile) <> ?
      then os-delete value ( mRunFile ).

    /* Распаковка bat файлов */
    v-txt = substitute('&1\exe\7z.exe x -y -o&1 &2 *.bat'
                      , v-PathRC
                      , UpgFile-tbl.FullNameUpgFile
                      ) .
    put stream mProt unformatted "распаковка BAT: " v-txt skip.
    os-command silent value ( v-txt ) .
    mIsError = os-error <> 0 
             or SearchFile ("!beforeTH.bat") = ? 
             or SearchFile ("!upd-rc-before.bat") = ? 
             or SearchFile ("!upd-rc-after.bat") = ?.
    run write-to-log (substitute(
                        "&1Копирование bat-файлов – &2", 
                        {&PREFIX_LOG}, 
                        if mIsError 
                          then "ошибка" 
                          else "успешно")
                      ).
    if mIsError then do:
      put stream mProt unformatted "ошибка распаковки BAT " skip.
      next UPDATE_CYCLE.
    end.
    

    put stream mProt unformatted "BAT файлы распакованы " skip.

    mRunFile = SearchFile ("!beforeTH.bat").
    if mRunFile ne ?
    then do:
       put stream mProt unformatted "Запуск !beforeTH.bat" skip.
       run waitfram-show in this-procedure ("Выполнение " + mRunFile ).
       os-command value (substitute ("&2 &1 exit" ,{&ampersand}, mRunFile)).
       mIsError = os-error <> 0 .
       os-delete value ( mRunFile ).
       run write-to-log (substitute(
                           "&1Запуск !beforeTH.bat – &2", 
                           {&PREFIX_LOG}, 
                           if mIsError 
                             then "ошибка" 
                             else "успешно")
                         ).
       put stream mProt unformatted "Результат !beforeTH.bat: " (if mIsError then "ошибка" else "успешно") skip.
       if mIsError then next UPDATE_CYCLE.
    end.
    
    run upload1C in this-procedure.
	run nws/nws-init.p no-error.
    
    mRunFile = SearchFile ("!upd-rc-before.bat").
    if mRunFile ne ?
    then do:
       put stream mProt unformatted "Выполнение !upd-rc-before.bat" skip.
       run waitfram-show in this-procedure ("Выполнение " + mRunFile ).
       os-command value (substitute ("&2 &1 exit" ,{&ampersand}, mRunFile)).
       mIsError = os-error <> 0.
       os-delete value ( mRunFile ).
       run write-to-log (substitute(
                           "&1Запуск !upd-rc-before.bat – &2", 
                           {&PREFIX_LOG}, 
                           if mIsError 
                             then "ошибка" 
                             else "успешно")
                         ).
       put stream mProt unformatted "Результат !upd-rc-before.bat: " (if mIsError then "ошибка" else "успешно") skip.
       if mIsError then next UPDATE_CYCLE.
    end.
                                      
    if v-filename begins "rc_20" then do:
      assign
        file-info:file-name = v-pathrc + "-old"
      .
      if file-info:file-type <> ? then do:
          os-delete value ( v-pathrc + "-old" ) recursive. /* удаляем rc-old */
          if os-error <> 0 then do:
              os-rename  value ( v-pathrc + "-old" ) value ( v-pathrc + "-old1" ). /* переименовываем rc в rc-old */
              if os-error <> 0 then do:
                  put stream mProt unformatted "ошибка удаления папки rc-old" skip.
                  return error string ( "Невозможно удалить папку " + v-pathrc + "-old, удалите ее сами" ).
              end.
          end.
      end.

      os-rename  value ( v-pathrc ) value ( v-pathrc + "-old" ). /* переименовываем rc в rc-old */
      if os-error <> 0 then do:
          put stream mProt unformatted "ошибка переименования rc" skip.
          return error string(( "Невозможно переименовать папку " + v-pathrc + " для сохранности" )).
      end.
      /* Лог: папка переименована */
      put stream mProt unformatted "Папка переименована: " v-pathrc " -> " v-pathrc + "-old" skip.
      
      os-create-dir value( v-pathrc ). /* создаем rc */
      if os-error <> 0 then do:
          os-rename  value ( v-pathrc  + "-old") value ( v-pathrc ). /* переименовываем rc-old в rc при ошибке создания  rc*/
          put stream mProt unformatted "ошибка создания папки rc" skip.
          return error string ( "Невозможно создать папку " + v-pathrc ).
      end.

      put stream mProt unformatted "Создана папка: " v-pathrc skip.

      v-txt = "".
      v-txt = /* v-arc */ v-PathRC + "-old\exe\7z.exe" + " x -y -o" + v-PathRC + " " +  UpgFile-tbl.FullNameUpgFile.
      /* Лог: команда распаковки */
      put stream mProt unformatted "Команда распаковки RC: " v-txt skip.
      os-command silent value ( v-txt ) .
      /* Лог: результат распаковки */
      put stream mProt unformatted "Распаковка RC выполнена, код ошибки: " STRING(os-error) skip.
    end.

    v-delfile = search( "!delfile.bat" ).
    if v-delfile <> ? then do:
        /* Лог: найден файл удаления */
        put stream mProt unformatted "Найден !delfile.bat, выполнение удаления" skip.
        input from value ( v-delfile ) .
        repeat :
           import unformatted v-txt.
           if trim (v-txt) = "" then next.
           v-txt = trim(substring ( v-txt, r-index(v-txt, " ") )).
           if trim (v-txt) = "" then next.
           v-txt = search( v-txt ).
           put stream mProt unformatted "Удаление файла: " v-txt skip.
           os-delete value ( v-txt ) recursive.
        end.
        input close.
    end.  /*  if v-delfile <> ? then do:  */

    os-delete value ( v-delfile ) recursive. /* удаляем файл !delfile.bat */
    put stream mProt unformatted "Удален !delfile.bat" skip.
 


end.  /*  for each upgfile-tbl where  */


/* запускаем обновления из /updck */
put stream mProt unformatted "запуск code-updck.p " skip.
run waitfram-show in this-procedure ("Выполнение xml-файлов обновления" ).
run gbl/code-updck.p(input  this-procedure)  no-error .
if error-status:error then
do:
   put stream mProt unformatted "ошибка запуска code-updck.p: " return-value skip.
   run write-to-log (substitute(
                       "&1&2", 
                       {&PREFIX_LOG}, 
                       return-value)
                     ).
end.
else do:
   put stream mProt unformatted "code-updck.p выполнен " skip.
end.

def var v-file-name as character no-undo.
def var v-msg       as character no-undo.
mRunFile = SearchFile ("!upd-rc-after.bat").

if mRunFile ne ?
then do:
   put stream mProt unformatted "Выполнение !upd-rc-after.bat" skip.
   run waitfram-show in this-procedure ("Выполнение " + mRunFile ).
   os-command value (substitute ("&2 &1 exit" ,{&ampersand}, mRunFile)).
   mIsError = os-error <> 0.
   os-delete value ( mRunFile ).
   run write-to-log (substitute(
                       "&1Запуск !upd-rc-after.bat – &2", 
                       {&PREFIX_LOG}, 
                       if mIsError 
                         then "ошибка" 
                         else "успешно")
                     ).
   put stream mProt unformatted "Результат !upd-rc-after.bat: " (if mIsError then "ошибка" else "успешно") skip.
end.

/* копирование лога в каталог новостей*/
assign
  mDirLog = substring(p0-source-dir, r-index(p0-source-dir, "\") + 1).
  mDirLog = substitute("&1-&2",entry(2,mDirLog,"-"),entry(1,mDirLog,"-")).
  mDirLog = substring(p0-source-dir, 1, r-index(p0-source-dir, "\")) + mDirLog
.
os-command silent
  value( "copy" )
  value( mFileLog )
  value( mDirLog + substring(mFileLog, r-index(mFileLog, "\")) )
.

add-log-file-name = ?.
CheckUpd:workStart ().

/* BTS-1070                                                                                                                           */
/*if can-find(first upgfile-tbl) then                                                                                         */
/*do:                                                                                                                         */
/*  v-msg = "Установлены обновления Тrade Нouse. Для их применения необходимо закрыть все программы TH и запустить их снова.".*/
/*  run utl\proc-msg.p (v-msg) no-error.                                                                                      */
/*end.                                                                                                                        */

/* Чистим временную таблицу */
for each upgfile-tbl :
    delete upgfile-tbl.
end.


put stream mProt unformatted (if can-find(first upgfile-tbl) then 
         "Установлены обновления Тrade Нouse. Для их применения необходимо закрыть все программы TH и запустить их снова." 
       else "Новых обновлений нет.") skip.

run waitfram-hide in this-procedure .
return if can-find(first upgfile-tbl) then 
         "Установлены обновления Тrade Нouse. Для их применения необходимо закрыть все программы TH и запустить их снова." 
       else "Новых обновлений нет.".

/*    выгрузка в 1С-Erp*/
procedure upload1C:
    oldg#news = g#news .
    oldg#esys = g#esys .

   g#news = false .
   g#esys = true .
   run bge/oxml-ini.p no-error.
   run write-to-log (substitute(
                        "&1инициализация переменных для системы OpenXML - &2",
                        {&PREFIX_LOG},
                        if error-status:error
                          then substitute("ошибка&1&2&3&4", 
                                          if return-value <> "" then {&new-line} else "", 
                                          return-value,
                                          if error-status :get-message( error-status :num-messages ) <> "" then {&new-line} else "", 
                                          error-status :get-message( error-status :num-messages ))
                          else "успешно")
                    ).

   define variable m-db-num as int no-undo.
   define variable m-extsys as character no-undo.
   find first sys-ctrl no-error.
   m-db-num = sys-ctrl.db-num.
   run bge/oxmlinx.p (
          input parparentproc
        , input this-procedure
        , input this-procedure
        , input substitute("&1,&2,&3,&4"
                          , "take+analys"
                          , m-db-num
                          , m-extsys
                          , 0)   /*Т.к. внешние системы заводятся сейчас только в ГБД, то номер БД у них всегде 0. Если ситуация изменится, то надо будет переделать насттройку сессий оxml тоже*/
    ) no-error.
    run write-to-log (substitute(
                        "&1загрузка OpenXML – &2", 
                        {&PREFIX_LOG}, 
                        if error-status :error 
                          then substitute("ошибка&1&2&3&4", 
                                          if return-value <> "" then {&new-line} else "", 
                                          return-value,
                                          if error-status :get-message( error-status :num-messages ) <> "" then {&new-line} else "", 
                                          error-status :get-message( error-status :num-messages ))
                          else "успешно")
                      ).

    define variable m-err-code as character no-undo.
    define variable m-message as character no-undo.
    run bge/cnewxpck.p (
                      input  m-extsys
                    , output m-err-code
    ) no-error .
    run write-to-log (substitute(
                        "&1подготовка новых пакетов – &2", 
                        {&PREFIX_LOG}, 
                        if error-status :error 
                          then substitute("ошибка&1&2&3&4", 
                                          if return-value <> "" then {&new-line} else "", 
                                          return-value,
                                          if error-status :get-message( error-status :num-messages ) <> "" then {&new-line} else "", 
                                          error-status :get-message( error-status :num-messages ))
                          else substitute("успешно&1&2",
                                          if return-value <> "" then {&new-line} else "",
                                          return-value))
                      ).

    run bge/oxmloutx.p (
            input parparentproc
          , input this-procedure
          , input this-procedure
          , input substitute("all,&1", m-db-num )
      ) no-error.
    run write-to-log (substitute(
                        "&1выгрузка OpenXML – &2", 
                        {&PREFIX_LOG}, 
                        if error-status :error 
                          then substitute("ошибка&1&2&3&4", 
                                          if return-value <> "" then {&new-line} else "", 
                                          return-value,
                                          if error-status :get-message( error-status :num-messages ) <> "" then {&new-line} else "", 
                                          error-status :get-message( error-status :num-messages ))
                          else "успешно")
                      ).
   g#news = oldg#news.
   g#esys = oldg#esys.



end procedure.

FINALLY:
        OUTPUT CLOSE.
    END.