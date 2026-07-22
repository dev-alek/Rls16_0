/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение процедур логирования авто процеса 

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/

/* В ЭТОМ ФАЙЛЕ НЕДОПУСТИМО ИСПОЛЬЗОВАТЬ ССЫЛКИ НА КАКУЮ-ЛИБО БАЗУ ДАННЫХ!!! */

&scoped-define vssseq {&sequence}
&if defined(auto-def-log_i) = 0 &then
&glob auto-def-log_i yes
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define {1} shared variable auto-window-h     as handle    no-undo . /*это handle automain.w!!!*/
define {1} shared variable auto-log-msg-h    as handle    no-undo .
define {1} shared variable hand-log-msg-h    as handle    no-undo .
define {1} shared variable log-file-name     as character no-undo initial ? .
define {1} shared variable add-log-file-name as character no-undo initial ? .
define {1} shared variable writelogvalue     as character no-undo initial ? .

&if defined (defonly) eq 0 &then
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

define stream LogStream .
define variable mNoTime as logical no-undo.
procedure write-to-log-notime :
  define input param i-str as character no-undo .
  mNoTime = yes.
  run write-to-log (i-str).
  mNoTime = no.
end.

procedure write-to-log :

  define input param p-str as character no-undo .

  do
  on error  undo, return error substitute( "&1 (write-to-log). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-log). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-log). endkey", vss-workfile )
  :
    define variable log-res        as logical   no-undo .
    define variable v-jj           as integer   no-undo .
    /* здесь именно ТЕКУЩЕЕ ВРЕМЯ */
    &if defined(auto-def_i) ne 0 &then
    if    mNoTime
       or writelogvalue eq "AsyncProc"
    then
       p-str = substitute( "&1 (pid: &2) &3&4"   , g#auto-user-id, g#auto-pid,                        p-str, {&new-line} ).
    else
       p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, {&new-line} ).
    &endif
    /* На экран */
    if auto-log-msg-h <> ? then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ? then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.

/*    output stream LogStream to value( log-file-name ) append .*/
/*    put stream LogStream unformatted p-str .*/
/*    output stream LogStream close.*/

    assign
      p-str = replace(p-str, ({&new-line} + {&carriage-return}), {&new-line} )
      p-str = replace(p-str, ({&carriage-return} + {&new-line}), {&new-line} )
      p-str = replace(p-str, {&new-line}, ({&carriage-return} + {&new-line}) )
    .

    if add-log-file-name <> ? then do:
      do v-jj = 1 to num-entries(add-log-file-name, {&delim-nws}):
        run gbl/fileapnd.p
          ( input entry(v-jj, add-log-file-name, {&delim-nws} )
          ,input p-str
          ,input 20 /* время ожинания освобождения файла */
          ) no-error .
        if error-status:error then do:
          return error return-value .
        end.
      end.
    end.
    if writelogvalue eq "AsyncProc" 
    then do:
       p-str = trim(p-str, ({&carriage-return} + {&new-line}) )
    .
       Publish "WriteLogAsunc" (p-str,yes).
    end.
    else if writelogvalue <> "yes" then do:
      run gbl/fileapnd.p
        ( input log-file-name
        ,input p-str
        ,input 20 /* время ожинания освобождения файла */
        ) no-error .
      if error-status:error then do:
        return error return-value .
      end.
    end.

  end.

end procedure.  /* write-to-log */


procedure write-to-screen :

  define input param p-str as character no-undo .

  do
  on error  undo, return error substitute( "&1 (write-to-screen). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-screen). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-screen). endkey", vss-workfile )
  :
    define variable log-res as logical no-undo.

    /* здесь именно ТЕКУЩЕЕ ВРЕМЯ */
    &if defined(auto-def_i) ne 0 &then
    assign
      p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, {&new-line} )
    .
    &endif
    /* На экран */
    if auto-log-msg-h <> ?
    then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ?
    then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
  end.

end procedure.  /* write-to-log */

procedure send-msg-to-email :

  define input  parameter p-subject      as character no-undo .
  define input  parameter p-text-err     as character no-undo .
  define input  parameter p-attach-files as character no-undo .

  do
  on error  undo, return error substitute( "&1 (send-msg-to-email). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-msg-to-email). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-msg-to-email). endkey", vss-workfile )
  :

    define variable v-tth             as handle    no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-param-type      as character no-undo .

    define variable v-email       as character no-undo .
    define variable v-tmp-str     as character no-undo .
    define variable v-tmp1-str    as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .

    delete object v-tth no-error.

    run adm/shattri.p
      ( input "get":U
       ,input  "":U
       ,input  0
       ,input  {&attr-auto-task}
       ,input  {&attr-auto-task_send-msg-to-email}
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,input-output table-handle v-tth
      ) no-error .
    if not error-status :error  then do:
      assign
        v-tmp-str = v-value-character
      .
    end.
    delete object v-tth no-error.

    assign
      v-tmp-str     = replace(v-tmp-str, ({&new-line} + {&carriage-return}), {&comma-char} )
      v-tmp-str     = replace(v-tmp-str, ({&carriage-return} + {&new-line}), {&comma-char} )
      v-tmp-str     = replace(v-tmp-str, {&new-line}, {&comma-char} )
      v-num-entries = num-entries( v-tmp-str, {&comma-char} )
      v-email       = "":U
    .

    do v-ind = 1 to v-num-entries
    :
      assign
        v-tmp1-str = entry( v-ind, v-tmp-str, {&comma-char} )
      .
      if trim( v-tmp1-str ) <> "":U then do:
        if v-email = "":U then do:
          assign
            v-email = v-tmp1-str
          .
        end.
        else do:
          assign
            v-email = v-email + {&comma-char} + v-tmp1-str
          .
        end.
      end.
    end.

    if v-email <> "":U then do:
      run gbl/sendmail.p
        ( input v-email
        , input p-subject
        , input p-text-err
        , input p-attach-files
        ) no-error .
      if error-status :error
        or return-value <> "":U
      then do:
        return error substitute( "&1 (send-msg-to-email). &2", vss-workfile, return-value ) .
      end.
    end.

  end.

end procedure. /* send-msg-to-email */
&endif
&endif

/* $Workfile$ e n d */