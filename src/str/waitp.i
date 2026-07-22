/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры ожидания удаления файла для ручного и автоматичесского (по расписанию) чтения и записи информации на кассы
для ручного режима это просто перевызов процедуры waitp.w

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/24/05
Author: Bakhtadze Natalya
Creation date: 01/24/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(dirstream_s) = 0 &then
&glob dirstream_s
define stream dirstream .
&endif

procedure waitp :
define input parameter p-auto as logical no-undo .
define input parameter fname           as character no-undo .
/*составной параметр - может содержать три entry of {&delim-par}*/
/*одновеременно могут быть заданы - либо первый entry - имя файла  ожидающего удаления*/
/*либо 2 и 3 entry - директория и маска файла ожидающие появления*/

define input parameter mess            as character no-undo .
define input parameter btn-mess-start  as character no-undo .
define input parameter mess-auto-end   as character no-undo .
define input parameter btn-mess-end    as character no-undo .
define input parameter p-waiting       as integer   no-undo .

define variable v-start-time as int64   no-undo .
define variable v-exec-time as integer no-undo .
define variable v-exec-time0 as integer no-undo .

define variable v-file-name-del as character no-undo .
define variable v-dir-name as character no-undo .
define variable v-fn-add-mask as character no-undo .
define variable v-elapsed-time as integer no-undo .
define variable v-start-dir-watch-time as int64   no-undo .
define variable v-appear as logical no-undo .



  do
  on error undo, return error
  :
    if p-auto then do:

      assign
      v-file-name-del = entry(1, fname, {&delim-par})
      v-dir-name      = (if num-entries(fname, {&delim-par}) = 3
                        and v-file-name-del = "":U
                        then entry(2, fname, {&delim-par})
                        else "":U)
      v-fn-add-mask = (if num-entries(fname, {&delim-par}) = 3
                      and v-file-name-del = "":U
                      then entry(3, fname, {&delim-par})
                      else "":U)
      v-fn-add-mask = (if v-dir-name <> "":U and v-fn-add-mask = "":U
                      then "*.*"
                      else v-fn-add-mask)
      .

      assign
        v-start-time = etime
      .

      run show-counter in p-log-handle.
      run write-counter in p-log-handle ( input btn-mess-start ).
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input mess).

      do while true
      :
        /* делаем более точные оценки прошедшего времени на основании etime */
        assign
          v-exec-time = (etime - v-start-time) / 1000
        .
        /*покажем counter*/
        run show-counter in p-log-handle .
        /*запишем counter*/
        if v-exec-time0 <> v-exec-time then
        run write-counter in p-log-handle (substitute("Время ожидания &1", string(v-exec-time, "HH:MM:SS"))).
        assign
        v-exec-time0 =  v-exec-time.
        if v-exec-time >= p-waiting then do:
          if v-file-name-del  <> ""
          or v-dir-name <> "":u
          then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("&1"
                                  , mess-auto-end
                                  )).
            /*больше не ждем*/
            run hide-counter in p-log-handle .
            return . /* --->>>--- */
          end.
          if v-dir-name = "":U then do:
            /* файл удален */
            run hide-counter in p-log-handle .
            return . /* --->>>--- */
          end.
        end.
        if v-file-name-del <> "" then do:
          if search(v-file-name-del) = ?
          then do:
            /* файл удален */
            run hide-counter in p-log-handle .
            return . /* --->>>--- */
          end.
        end.
        if v-dir-name <> "":U
        and v-exec-time > minimum(p-waiting / 4, 15)
        and (v-start-dir-watch-time = 0
            or
            (etime  - v-start-dir-watch-time) > v-elapsed-time * 10
            )
        then do:
          assign
          v-start-dir-watch-time = etime.
          run proc-read-dir in this-procedure (
                                              input v-dir-name
                                              ,input v-fn-add-mask
                                              ,output v-elapsed-time
                                              ,output v-appear
                                              ) no-error .
          if error-status:error then do:
            return.
          end.
          if v-appear then return.
        end.
      end. /*dow*/
    end. /*if p-autor*/
    else do:
      run str/waitp.w (
                   input fname
                 , input mess
                 , input btn-mess-start
                 , input btn-mess-end
                 , input p-waiting
                  ) no-error .
      if error-status:error then return error .
    end.

  end.

end procedure. /* waitp */


procedure waitpxml :
define input parameter p-auto as logical no-undo .
define input parameter fname-out       as character no-undo .
define input parameter fname-in        as character no-undo .
define input parameter mess            as character no-undo .
define input parameter btn-mess-start  as character no-undo .
define input parameter btn-mess-end    as character no-undo .
define input parameter mess-continue-waiting as character no-undo .
define input parameter p-waiting       as integer   no-undo .

  define variable v-start-time as int64     no-undo .
  define variable v-exec-time as integer no-undo .
  define variable v-exec-time0 as integer no-undo .
  define variable v-continue-waiting as logical no-undo .


  do
  on error undo, return error
  :
    if p-auto then do:

      assign
        v-start-time = etime
      .

      run show-counter in p-log-handle.
      run write-counter in p-log-handle ( input btn-mess-start ).
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input mess).

      do while true
      :
        /* делаем более точные оценки прошедшего времени на основании etime */
        assign
          v-exec-time = (etime - v-start-time) / 1000
        .
        /*покажем counter*/
        run show-counter in p-log-handle .
        /*запишем counter*/
        if v-exec-time0 <> v-exec-time then
        run write-counter in p-log-handle (substitute("Время ожидания &1", string(v-exec-time, "HH:MM:SS"))).
        assign
        v-exec-time0 =  v-exec-time.
        if v-exec-time >= p-waiting
        and not v-continue-waiting
        then do:
          if fname-out <> "" then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("------------------------- &1&1------------------------- &2"
                                  , {&new-line}
                                  , (if p-auto then 'Касса не ответила.' else btn-mess-end)
                                  )).
            return . /* --->>>--- */
          end.
          else do:
            /* файл удален */
            run hide-counter in p-log-handle .
            return . /* --->>>--- */
          end.
        end.
        if fname-out <> "" then do:
          if search(fname-out) = ?
          then do:
            /* файл удален */
            run hide-counter in p-log-handle .
            return . /* --->>>--- */
          end.
          else do:
            /*проверим а новый появился?*/
            if search(fname-in) <> ? then do:
                assign
                v-continue-waiting = yes
                .
            end. /*if search(fname-in) <> ? then do:*/
          end. /*if search(fname-out) <> ?*/
        end. /*if fname-out <> "" then do:*/
      end. /*dow*/
    end. /*if p-autor*/
    else do:
      run str/waitpxml.w (
                   input fname-out
                 , input fname-in
                 , input mess
                 , input btn-mess-start
                 , input btn-mess-end
                 , input mess-continue-waiting
                 , input p-waiting
                  ) no-error .
      if error-status:error then return error .
    end.

  end.

end procedure. /* waitpxml */

{ str/waitrddr.i }


/* $Workfile$ e n d */