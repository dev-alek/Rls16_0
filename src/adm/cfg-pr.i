/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с конфигурационными параметрами

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i }

/* имена файлов по умолчанию   */
&glob cnf-struct-file "cmp/mold_db.sch"
&glob cnf-file        "config.cfg"

&glob delim-cfg '`':U

&glob field-list ~
~{&pref-tbl~}param-code ~
~{&pref-tbl~}param-type ~
~{&pref-tbl~}data-type ~
~{&pref-tbl~}param-name ~
~{&pref-tbl~}attach-type ~
~{&pref-tbl~}list-value ~
~{&pref-tbl~}default-value ~
~{&pref-tbl~}PS ~
~{&pref-tbl~}param-group ~
~{&pref-tbl~}user-resp

define {&new} shared temp-table cnf-struct no-undo
  field param-code    as character
  field param-type    as character
  field data-type     as character
  field param-name    as character
  field attach-type   as character
  field list-value    as character
  field default-value as character
  field PS            as character
  field param-group   as character
  field user-resp     as character
  index by-code is unique param-code
.

define temp-table t_cnf-struct no-undo like cnf-struct .

define stream TxtStream.
define stream temp-stream .

function coding-user-resp returns character
  ( input p-param-code as character
   ,input p-user-resp  as character
  )
:
  return encode( p-param-code + p-user-resp ) .
end function.

function decoding-user-resp returns character
  ( input p-param-code as character
   ,input p-code-usr   as character
  )
:
  define variable v-ind         as integer   no-undo .
  define variable v-user-list   as character no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-user-resp   as character no-undo .
  assign
    v-user-list   = "Бахтадзе,Булгаков,Белоусов,Гюнтнер,Исаков,Перваков,Суслов,Уханов,Чернова,Кочетков,Степанов,Хныкин,Гридчина,Шальнев,Сливенко,Харитонов,Кирюхин,Морозов"
    v-num-entries = num-entries( v-user-list )
    v-user-resp   = "":U
  .
  block_do:
  do v-ind = 1 to v-num-entries :
    if encode( p-param-code + entry( v-ind, v-user-list ) ) = p-code-usr then do:
      assign
        v-user-resp = entry( v-ind, v-user-list )
      .
      leave block_do.
    end.
  end.
  if v-user-resp = "":U then do:
    message
      vss-include-info{&vssseq} skip
      substitute( "Невозможно распознать ответственного за параметр <&1>!",  p-param-code) skip
      substitute( "Возможно его нет в списке." ) skip
      view-as alert-box error
    .
    return "unknown":U.
  end.
  else do:
    return v-user-resp .
  end.

end function.

function sum-enc returns character (str as character, num-rev as integer).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .

   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      if rev_incl_i <= num-rev
        or rev_incl_l - rev_incl_i < num-rev
      then do:
        assign
          rev_incl_s = rev_incl_s + substr(str, rev_incl_l - rev_incl_i + 1, 1)
        .
      end.
      else do:
        assign
          rev_incl_s = rev_incl_s + substr(str, rev_incl_i, 1)
        .
      end.
   end.
   return rev_incl_s.
end.

&glob param-type-list "logical,integer,decimal,date,character":U
&glob type-list-char  "character":U

procedure check-cfg :
  define input-output parameter p-param-code    as character no-undo .
  define input-output parameter p-param-type    as character no-undo .
  define input-output parameter p-data-type     as character no-undo .
  define input-output parameter p-param-name    as character no-undo .
  define input-output parameter p-attach-type   as character no-undo .
  define input-output parameter p-list-value    as character no-undo .
  define input-output parameter p-default-value as character no-undo .
  define input-output parameter p-param-PS      as character no-undo .
  define input-output parameter p-param-group   as character no-undo .
  define input-output parameter p-user-resp     as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
  :
    define variable v-ind as character no-undo .
    assign
      p-param-code    = trim( p-param-code )
      p-param-type    = trim( p-param-type )
      p-data-type     = trim( p-data-type )
      p-param-name    = trim( p-param-name )
      p-attach-type   = trim( p-attach-type )
      p-list-value    = trim( p-list-value )
      p-default-value = trim( p-default-value )
      p-param-PS      = trim( p-param-PS )
      p-param-group   = trim( p-param-group )
      p-user-resp     = trim( p-user-resp )
    .

    if p-param-code = "":U then do:
      undo, return error substitute( "&1. Не задана метка параметра", vss-include-info{&vssseq} ).
    end.
    if length( p-param-code ) > 8 then do:
      undo, return error substitute( "&1. Длина метки параметра не может превышать 8 символов (&2)", vss-include-info{&vssseq}, p-param-code ).
    end.

    if lookup( p-param-type, {&cnf-type-list} ) = 0 then do:
      undo, return error substitute( '&1. Значение типа настройки "&2" не допустимо (&3)', vss-include-info{&vssseq}, p-param-type, p-param-code ).
    end.

    if lookup( p-param-type, {&cnf-type-list-protect} ) <> 0
      and lookup( p-attach-type, {&cnf-type-restr-protect} ) = 0
    then do:
      undo, return error substitute( '&1. Для параметров с типом "&2" допустимы только привязки "&3" (&4)', vss-include-info{&vssseq}, {&cnf-type-list-protect}, {&cnf-type-restr-protect}, p-param-code ).
    end.

    if p-param-name = "":U then do:
      undo, return error substitute( "&1. Не задано название параметра &2", vss-include-info{&vssseq}, p-param-code  ).
    end.

    if lookup( entry( 1, p-data-type ), {&param-type-list} ) = 0
      or num-entries( p-data-type ) > 2
      or ( num-entries( p-data-type ) = 2
           and entry( 2, p-data-type ) <> "list":U
         )
    then do:
      undo, return error substitute( "&1. Значение типа параметра &2 не допустимо (&3)", vss-include-info{&vssseq}, p-data-type, p-param-code ).
    end.

    if lookup( p-attach-type, {&cnf-type-restr} ) = 0
    then do:
      undo, return error substitute( '&1. Значение привязки "&2" не допустимо (&3)', vss-include-info{&vssseq}, p-attach-type, p-param-code ).
    end.

  end.
  return.
end procedure. /* check-cfg */

procedure fill-cnf-struct :

  define input parameter p-file-name as character no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-file-name as character no-undo .
    define variable v-counter as integer   no-undo .

    define variable v-temp-fname       as character           no-undo.  /* полное имя файла для импорта */
    define variable v-last-key         as integer             no-undo .
    define variable v-new-line         as integer             no-undo .
    define variable v-read-chksum      as logical             no-undo .
    define variable v-md5-signature-av as character           no-undo .
    define variable v-md5-signature    as character           no-undo .

    define frame inf-cfg
      v-counter label "Просмотрено"
      with view-as dialog-box side-labels 1 columns three-d title ""
    .

    assign
      v-file-name = search( p-file-name )
    .
    if v-file-name = ""
      or v-file-name = ?
    then do:
      return error substitute( "&1. Не задан файл схемы конфигурации!", vss-include-info{&vssseq} ).
    end.

    assign
      v-last-key         = 0
      v-read-chksum      = false
      v-md5-signature-av = "":U
      file-info:file-name = ".":U
      v-temp-fname = substitute( "&1\&2-&3-&4.tmp", file-info:full-pathname, time, etime, random( 1111111 , 9999999 ) )
    .

    input stream TxtStream from value( v-file-name ).
    output stream temp-stream to value(v-temp-fname) .
    block_read:
    repeat while v-last-key <> -2
    on error undo, return error
    :
      readkey stream TxtStream pause 0.
      assign
        v-last-key = lastkey
      .
      if chr( v-last-key ) = {&delim-nws} then do:
        assign
          v-read-chksum = true
        .
      end.
      else do:
        if v-read-chksum = true then do:
          if v-last-key = 13 then do:
            leave block_read.
          end.
          else do:
            assign
              v-md5-signature-av = v-md5-signature-av + chr( v-last-key )
            .
          end.
        end.
        else do:
          if v-last-key = 13 then do:
            put stream temp-stream skip(v-new-line).
            assign
              v-new-line = 1
            .
          end.
          else do:
            put stream temp-stream unformatted chr( v-last-key ).
            assign
              v-new-line = 0
            .
          end.
        end.
      end.
    end.
    output stream temp-stream close.
    input stream TxtStream close.

    run gbl/md5.p
      ( input  search( v-temp-fname )
       ,output v-md5-signature
      ) no-error.

    if error-status :error then do:
      return error substitute("Ошибка при подсчете контрольной суммы текстового файла схемы &1", v-file-name ) .
    end.

    os-delete value( v-temp-fname ).
    assign
      v-md5-signature = sum-enc( v-md5-signature, 8 )
    .

    if v-md5-signature-av <> v-md5-signature then do:
      return error substitute( "Некорректная контрольная сумма текстового файла схемы &1", v-file-name ) .
    end.

    input stream TxtStream from value( v-file-name ).

    assign
      v-counter = 0
    .
    assign
      frame inf-cfg:title = "Чтение параметров конфигурации"
    .
    view frame inf-cfg.

    /* очищаем временную таблицу настроек */
    for each t_cnf-struct:
      delete t_cnf-struct.
    end.

    create t_cnf-struct no-error. /* читаем всегда в одну запись */

    read-cycle:
    repeat transaction
    on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-counter = v-counter + 1
      .
      if ( v-counter modulo 10 ) = 0 then do:
        display
          v-counter
          with frame inf-cfg.
      end.

      &scop pref-tbl t_cnf-struct.

      import stream TxtStream delimiter {&delim-cfg} {&field-list} no-error.
      if error-status:error then do:
        return error substitute( "&1. Ошибка при чтении текстового файла схемы! Cтрока &1. (&2)", vss-include-info{&vssseq}, v-counter, error-status :get-message ( error-status :num-messages ) ).
      end.
      else do:
        if not ( {&pref-tbl}param-code begins {&delim-nws} ) then do:
          assign
            t_cnf-struct.user-resp = decoding-user-resp( t_cnf-struct.param-code, t_cnf-struct.user-resp )
          .
          if t_cnf-struct.user-resp = "unknown":U then do:
            return error substitute( "&1. Ошибка параметра! Cтрока &2.", vss-include-info{&vssseq}, v-counter ).
          end.

          /* Проверка параметров схемы */
          run check-cfg in this-procedure
            ( input-output {&pref-tbl}param-code
            ,input-output {&pref-tbl}param-type
            ,input-output {&pref-tbl}data-type
            ,input-output {&pref-tbl}param-name
            ,input-output {&pref-tbl}attach-type
            ,input-output {&pref-tbl}list-value
            ,input-output {&pref-tbl}default-value
            ,input-output {&pref-tbl}PS
            ,input-output {&pref-tbl}param-group
            ,input-output {&pref-tbl}user-resp
            ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка параметра! Cтрока &2. &3 (&4)", vss-include-info{&vssseq}, v-counter, return-value, error-status :get-message ( error-status :num-messages ) ).
          end.
          else do:
            find first cnf-struct
              where cnf-struct.param-code = t_cnf-struct.param-code
              no-error
            .
            if not available cnf-struct then do:
              create cnf-struct .
            end.
            buffer-copy t_cnf-struct to cnf-struct .
          end.
        end.
      end.
    end.
    delete t_cnf-struct no-error.
    hide frame inf-cfg.
    input stream TxtStream close.
  end.
  return.
end procedure. /* fill-cnf-struct */

/* $Workfile$ e n d */