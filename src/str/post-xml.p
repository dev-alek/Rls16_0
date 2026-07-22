block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

пересылка xml файла на кассу в режиме нахождения в diallog.w

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/02/05
Author: Bakhtadze Natalya
Creation date: 12/02/05

ожидание выполнени и появлния файла ответа

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-news     as logical no-undo . /*новости */
define input parameter p-auto     as logical no-undo . /*автомат */
define input parameter p-mode     as character no-undo . /*get send*/
define input parameter log-file-name as character no-undo .
define input parameter p-url as character no-undo .
define input parameter p-post-file-name as character no-undo .
define input parameter p-response-file-name as character no-undo .
define input parameter p-response-time   as integer no-undo . /*время ожидания прихода файла*/
/*сообщение которое пользователь будет видеть на экране во время выполнения команды*/
DEFINE INPUT PARAMETER p-mess AS CHAR NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск на выполнение командной строки без экрана".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/windows.i  }
{ gbl/runrepid.i }

/*командная строка*/
define variable Cmd                       AS CHARacter                No-UNDO.
define variable cmd-out                   as character                no-undo .
define variable v-result                  as character                no-undo .
define variable curl-path                 as character                no-undo .
define variable HiNSTANCE                 AS INTEGER                  NO-UNDO.
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-errrs                   as character                no-undo .
define variable v-std-err-file-name       as character                no-undo .
define variable bat-file                  as character                no-undo.
define variable v-size                    as integer                  no-undo .
define variable rv                        as integer                  no-undo .
define variable v-pid                     as integer                  no-undo .
define variable v-instant                 as logical                  no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  /*ищем curl.exe*/

  assign
    curl-path = search("exe/curl.exe")
  .
  if curl-path = ? then do:
    undo main-block, return error "Не найден путь к файлу exe/curl.exe" .
  end.
  if num-entries(p-mode) > 1 then do:
    if entry(2,p-mode) = "instant" then do:
      v-instant = yes.
    end.
    p-mode = entry(1, p-mode).
  end.

  OS-DELETE value(p-response-file-name).

  run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input p-mess      ).
  if (p-news or p-auto)
  and p-mode <>'get'
  then do:
    /* создается временный командный файл для получения err*/
    run gbl/_tmpfile.p (
                        input ""
                      , input "err"
                      , output v-std-err-file-name) .

    /* создается временный командный файл для выполнения команды*/
    run gbl/_tmpfile.p (
                        input ""
                      , input "bat"
                      , output bat-file) .


    assign
    cmd = substitute('"&1" -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 --stderr &4 '
                    , curl-path
                    , p-post-file-name
                    , p-url
                    , v-std-err-file-name
                    )
    .
    output to value(bat-file) convert target "ibm866".
    PUT  UNFORMATTED cmd SKIP.
    output close.
  end.
  else do:
    /* создается временный командный файл для выполнения команды*/
    run gbl/_tmpfile.p (
                        input ""
                      , input "bat"
                      , output bat-file) .

    assign
    cmd = substitute('"&1" -0 --trace-ascii test.txt -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                    , curl-path
                    , p-post-file-name
                    , p-url
                    , p-response-file-name)
    .
    output to value(bat-file) convert target "ibm866".
    PUT  UNFORMATTED cmd SKIP.
    output close.
  end.

  if (p-news = yes
  or p-auto = yes) then do:
    run gbl/run-gpid.p (
                      input bat-file
                     ,input '':U
                     ,output v-pid).
  end.
  else do:
    OS-COMMAND silent  value(bat-file).
  end.

  /* время ожидания в секундах */
  define variable v-time-count as integer no-undo .
  define variable v-err-file-found as logical no-undo .
  if v-instant then do:
    p-response-time = p-response-time * 2.
  end.


  if (not (p-news = yes or p-auto = yes) )
  or p-mode = 'get'
  then do:
    /* в цикле ждем появлЕния файла response */
    REPEAT:
      _repeat:
      REPEAT WHILE v-time-count < p-response-time :
        assign
          v-time-count = v-time-count + 1
        .
        
        run gbl/pause.p( 1000).

        assign
          FILE-INFO :FILE-NAME = p-response-file-name
        .
        if file-info = ? then do:
          v-time-count = v-time-count - 1.
          
          run gbl/pause.p( 1000).
          next _repeat.
        end.
        IF INDEX(FILE-INFO:FILE-TYPE, "F")  > 0 then  do:
          input from value(p-response-file-name).
          import unformatted v-result no-error .
          input close.
          if error-status:error
          or not (v-result begins "<?xml") then do:
            v-errrs = error-status:get-message(1) .
            OS-DELETE value(p-post-file-name).
            OS-DELETE value(p-response-file-name).
            OS-DELETE value(bat-file).
            return error.
          end.
          assign
            v-err-file-found = true
          .
          leave .
       end.
     END.
     if v-time-count > p-response-time
     or v-err-file-found = yes
     then leave.
     v-time-count = v-time-count + 1.
     if error-status:error then do:
        v-time-count = v-time-count + 1.
     end.
   end.
   if v-err-file-found <> true then do:
      run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Превышено время ожидания &1&2Не найден файл с результатом выполнения задания &3&2&4"
                          , p-response-time
                          , {&new-line}
                          , cmd
                          , v-errrs)
                           ).
      OS-DELETE value(bat-file).
      if not (p-news = ? and p-auto = ?) then
      OS-DELETE value(p-post-file-name).
/*      return "error".*/
    end.
    else do:
      run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Время ожидания выполнения задания на кассе - &1 c"
                          , v-time-count
                           )).

    end.
  end.
  else do: /*g#news or g#auto*/
    _nrepeat:
    REPEAT WHILE v-time-count < 14 :
      assign
        v-time-count = v-time-count + 1
      .
      pause 1 no-message .
      rv = IsProcessRunning(v-pid).
      if rv >= 0 then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Время ожидания выполнения задания на кассе - &1 с"
                            , v-time-count
                            )).
        assign
        FILE-INFO :FILE-NAME = v-std-err-file-name
        .
        if file-info:full-pathname = v-std-err-file-name  then do:
           run gbl/filesize.p ( input v-std-err-file-name
                           ,output v-size ) no-error .
           if v-size <> 0 then do:
             run gbl/filename.p (
                input p-post-file-name
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
            run copyto-log-and-file in p-log-handle ( input v-std-err-file-name
                                                    ,input 1
                                                    ,input log-file-name
                                                    ,input 1
                                                    ).
            os-delete value (v-std-err-file-name).

            if not v-instant then do:
            /*вместо удаления перенесем в директорию UNDELIVERED*/
            run gbl/dir-cre.p ( input v-path + '\undelivered\') no-error .
            if error-status:error then do:
              /*директории нет и не удалось создать*/
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute(
                                    "!!!Каталог &1 для хранения НЕДОСТАВЛЕННЫХ файлов не найден&2" +
                                    "и/или попытка его создания не удалась:&2&3 &4"
                                    , v-path + '\undelivered\'
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    )).
              return "error".
            end. /*if error-status:error при dire-cre then do:*/
            else do:
              os-rename value( p-post-file-name  )  value( v-path + '\undelivered\' + v-file-name ) .
            end.
            end.
          end. /*if v-size <> 0 then do:*/
          else do:
            os-delete value (v-std-err-file-name).
          end.
        end. /*if file-info:full-pathname = v-str-err-file-name  then do:*/
        leave _nrepeat.
      end. /*if rv >= 0 then do:*/
    end. /*    REPEAT WHILE v-time-count < 7 :*/
    if v-time-count >= 14 then do:
      run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Время ожидания выполнения задания на кассе - &1 с"
                          , v-time-count
                          )).
    end.

  end. /*else do:g#news or g#auto*/
  OS-DELETE value(bat-file).

  OS-DELETE value(p-post-file-name).
end.