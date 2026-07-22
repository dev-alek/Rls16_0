block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cnf-cnf.p $
$Archive: adm/cnf-cnf.p $

Процедуры работы с таблицей конфигурации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U.
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo init "$Workfile: cnf-cnf.p $":U.
define variable vss-archive     as character no-undo init "$Archive: adm/cnf-cnf.p $":U.
define variable vss-description as character no-undo init "Процедуры работы с таблицей конфигурации".



{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ adm/cnf-inc.i  }
{ gbl/conf-enc.i }
{ adm/cfg-pr.i   }
{ gbl/waitfram.i }

define variable str-hdl      as handle  no-undo .        /* указатель на процедурц работы с настройкой */
define variable db-hdl       as handle  no-undo .        /* указатель на процедуры работы с базой */
define variable stand-alone  as logical no-undo .        /* признак работы без коннекта с базой */

define stream txt-file.                          /* для импорта и экспорта конфигураций   */
define stream temp-stream.                       /* для временного файла конфигураций     */
define temp-table t-cnf no-undo like cnf. /* первоначально считываем в запись рабочей таблицы */




/* ----------------------------------------------------------------------------------------------------------------------------
    Инициализация процедур
--------------------------------------------------------------------------------------------------------------------------------- */
procedure init.

define input parameter  par-str-hdl as handle.
define input parameter  par-db-hdl  as handle.

if valid-handle (par-str-hdl) then
   assign str-hdl = par-str-hdl.
else
   return "2".    /* невозможно запротоколировать ошибку, так как не ясно - куда */
if valid-handle (par-db-hdl) then     /* отсутствие означает работу в автономе */
   assign db-hdl      = par-db-hdl
          stand-alone = false.
   else
          stand-alone = true.
this-procedure:private-data = "Work-with-config".
return.
end procedure.


/* ----------------------------------------------------------------------------------------------------------------------------
    Завершение работы с текущей конфигурации
--------------------------------------------------------------------------------------------------------------------------------- */
Procedure Kill.
    Delete Procedure This-procedure.
    Return.
End Procedure.

/* ----------------------------------------------------------------------------------------------------------------------------
    Импорт конфигурации из текстового файла
--------------------------------------------------------------------------------------------------------------------------------- */

function valid-length returns logical (par-str as character, par-len as integer, par-label as character).

if length(par-str) > par-len then do:
   run log-error in str-hdl ("Превышена максимальная длина "  + string(par-len) + " для " + par-label, 2).
   return false.
end.
   return true.
end.

PROCEDURE Import.

define input parameter par-FName   as character no-undo.  /* имя файла для импорта */
define input parameter par-Clear   as logical   no-undo.  /* выполнять очистку перед чтением */
define input parameter par-UseLast as logical   no-undo.  /* при догрузке части параметров выполнять
                                                             замену значений параметров, а не сохранять
                                                             существующие значения. Побочный эффект -
                                                             при дублировании параметров внутри одного файла
                                                             будет использоваться соответственно последнее
                                                             или первое значение  */
define input parameter p-stand-alone as logical    no-undo.  /* игнорировать проверку кодирования*/
define input parameter p-db-load     as character  no-undo.  /* "" - для всех БД или номер базы для которой закачать */

define variable Fname              as character           no-undo.  /* полное имя файла для импорта */
define variable Count              as integer   initial 0 no-undo.  /* счетчик считанных записей    */
define variable v-ok               as logical             no-undo .
define variable v-last-key         as integer             no-undo .
define variable v-new-line         as integer             no-undo .
define variable v-read-chksum      as logical             no-undo .
define variable v-md5-signature-av as character           no-undo .
define variable v-md5-signature    as character           no-undo .
define variable v-db-list          as character           no-undo .

define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_db for ub.db .

/* проверяем наличие заказанного файла  */
assign
  err-level  = 0
.
if par-fname = "" then par-fname = {&cnf-file}.
  assign
    par-fname = SEARCH( par-fname )
  .
IF par-fname = ? then do:
   run log-error in str-hdl ("Не найден файл конфигурации " + par-fname, 2).
   return string (err-level).
end.
else do:
  run log-error in str-hdl("Чтение конфигурационных параметров " + par-fname, 0).
end.

assign
  v-last-key         = 0
  v-read-chksum      = false
  v-md5-signature-av = "":U
  file-info:file-name = ".":U
  FName = substitute( "&1\&2-&3-&4.tmp", file-info:full-pathname, time, etime, random( 1111111 , 9999999 ) )
.

input stream txt-file from value( par-fname ).
output stream temp-stream to value(FName) .
block_read:
repeat while v-last-key <> -2
on error undo, return error return-value
:
  readkey stream txt-file pause 0.
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
input stream txt-file close.

run gbl/md5.p
  ( input  search( FName )
  ,output v-md5-signature
  ) no-error.

if error-status :error then do:
  run log-error in str-hdl
    ( input substitute( "Ошибка при подсчете контрольной суммы файла конфигурации &1", par-fname )
     ,input 2
    ).
  return "2":U.
end.

os-delete value( FName ).
assign
  v-md5-signature = sum-enc( v-md5-signature, 10 )
.

if v-md5-signature-av <> v-md5-signature then do:
  run log-error in str-hdl
    ( input substitute( "Некорректная контрольная сумма файла конфигурации &1", par-fname )
     ,input 2
    ).
  if not p-stand-alone then do:
    return "2":U.
  end.
  else do:
    message
      substitute( "Некорректная контрольная сумма файла конфигурации &1!", par-fname ) skip
      substitute( "Вы действительно хотите загрузить этот файл?" )
      view-as alert-box question BUTTONS yes-no update v-ok.
    if v-ok <> true then do:
      return "2":U.
    end.
  end.
end.

main-block:
do on error undo main-block, leave main-block:

  if not p-stand-alone then do:
    find first buf_sys-ctrl no-lock .
  end.

  /*  очищаем либо все - в случае полной загрузки, либо только неиспользуемые - при добавлении параметров */
  For each cnf
    where par-clear
       or cnf.NotUsed = true
  :
    delete cnf .
  end.

  for each t-cnf
  :
    delete t-cnf .
  end.

  create t-cnf . /* читать будем в одну и ту же запись */

  input stream txt-file from value( par-fname ).

/* собственно чтение */
read-cycle:
  Repeat transaction
  on error undo read-cycle, leave main-block
  :
        count = count + 1 .
        import stream Txt-File delimiter {&delimiter} t-cnf except {&except-list} no-error.
        if error-status:error then do:
           message
             t-cnf.param-name skip
             error-status :get-message(1) skip
             return-value skip
             view-as alert-box error .
           run log-error in str-hdl ("ошибка при чтении файла конфигурации, строка " + string(count), 2).
           input stream txt-file close.
           undo, return "2":U.
        end.
        if t-cnf.param-code begins {&delim-nws} then do:
          if not p-stand-alone then do:
            if t-cnf.param-code = {&delim-nws} + v-md5-signature then do:
              leave read-cycle.
            end.
            else do:
              run log-error in str-hdl
                ( input substitute( "Некорректная контрольная сумма файла конфигурации &1", par-fname )
                 ,input 2
                ).
              input stream txt-file close.
              undo, return "2":U.
            end.
          end.
          else do:
            leave read-cycle.
          end.
        end.
        /* первым делом проверяем длину полей в индексе - иначе ошибка не отлавливается */
        if not valid-length (t-cnf.param-code, 8 , "Метка параметра")     then next read-cycle.
        if not valid-length (t-cnf.obj-type,   8 , "Тип объекта")         then next read-cycle.
        /* сразу проверяем кодированность */
        if p-db-load <> "":U
          and lookup( string( t-cnf.db-num ), p-db-load ) = 0
        then do:
          next read-cycle.
        end.
        if lookup( t-cnf.conf-type, {&cnf-type-list-protect} ) > 0
          and not p-stand-alone
        then do:
           find first buf_db no-lock
             where buf_db.db-num = t-cnf.db-num
             .
           run check-enc in this-procedure
             ( input t-cnf.db-num
              ,input buf_db.db-key
              ,input t-cnf.param-code
              ,input t-cnf.param-value
              ,input t-cnf.beg-date
              ,input t-cnf.end-date
              ,input t-cnf.param-encoded
              ,output v-ok
             ) no-error.
           if error-status :error
             or v-ok <> true
           then do:
              if t-cnf.db-num = buf_sys-ctrl.db-num
              then do:
                run log-error in str-hdl
                  ( input substitute("Параметр &1 для БД &2 (строка &3) - ошибка кодирования (&4)", t-cnf.param-code, t-cnf.db-num, Count, t-cnf.param-encoded )
                   ,input 2
                  ).
                input stream txt-file close.
                undo, return "2".
              end.
              else do:
                run log-error in str-hdl
                  ( input substitute("Параметр &1 для БД &2 (строка &3) - ошибка кодирования (&4). Параметр игнорируется", t-cnf.param-code, t-cnf.db-num, Count, t-cnf.param-encoded )
                   ,input 1
                  ).
                next read-cycle.
              end.
           end.
        end.
        if t-cnf.beg-date = ? then do:
          assign
            t-cnf.beg-date = {&beg-unlim-lcns}
          .
        end.
        if t-cnf.end-date = ? then do:
          assign
            t-cnf.end-date = {&end-unlim-lcns}
          .
        end.
        /* если дубль, то новых строк не порождаем */
&scop buf1 cnf.
&scop buf2 = t-cnf.
&scop link-word and

        find first cnf
          where {&Fields}
          no-error.
        if available cnf then do:
           if cnf.param-value   <> t-cnf.param-value or
              cnf.param-encoded <> t-cnf.param-encoded or
              cnf.param-type    <> t-cnf.param-type  or
              cnf.conf-type     <> t-cnf.conf-type   or
              cnf.NotUsed       =  true
           then do:
              if par-UseLast then do:
                  if cnf.param-value <> t-cnf.param-value
                  then do:
                    run log-error in str-hdl
                      ( input substitute( "Параметр &1 для БД &2. Значение &3 заменено на &4", cnf.param-code, cnf.db-num, cnf.param-value, t-cnf.param-value )
                      ,input 0
                      ).
                  end.
                  else do:
                    if cnf.param-encoded <> t-cnf.param-encoded
                    then do:
                      run log-error in str-hdl
                        ( input substitute( "Параметр &1 для БД &2 перекодирован", cnf.param-code, cnf.db-num )
                        ,input 0
                        ).
                    end.
                    else do:
                      run log-error in str-hdl
                        ( input substitute( "Изменены атрибуты параметра &1 для БД &2 ", cnf.param-code, cnf.db-num )
                        ,input 0
                        ).
                    end.
                  end.
                  if lookup( cnf.conf-type, {&cnf-type-list-protect} ) > 0
                    and lookup( t-cnf.conf-type, {&cnf-type-list-protect} ) = 0
                    and not p-stand-alone
                  then do:
                    assign
                      cnf.ErrorExist = 2
                    .
                  end.
                  else do:
                    assign
                      cnf.ErrorExist = 0
                    .
                  end.

                  buffer-copy t-cnf to cnf no-error.
                  if error-status:error then do:
                    run log-sys-error in str-hdl ("Системная ошибка").
                    input stream txt-file close.
                    undo, return "2" .
                  end.

                  assign
                    cnf.is-changed    = true
                    cnf.NotUsed       = false
                  .
              end.
              else
                 run log-error in str-hdl
                   ( input substitute( "Параметр &1 для БД &2. Новое значение игнорируется", cnf.param-code, cnf.db-num )
                    ,input 0
                   ).
           end.
        end.
        else do:
          create cnf no-error.
          if error-status:error then do:
            run log-sys-error in str-hdl ("Системная ошибка").
            input stream txt-file close.
            undo, return "2" .
          end.
          buffer-copy t-cnf to cnf no-error.
          if error-status:error then do:
            run log-sys-error in str-hdl ("Системная ошибка").
            input stream txt-file close.
            undo, return "2" .
          end.
          assign
            cnf.is-changed  = true
          .
        end.
     release cnf no-error.
      if error-status:error then do:
        run log-sys-error in str-hdl ("Системная ошибка").
        input stream txt-file close.
        undo, return "2" .
      end.
  end. /* цикл импорта */

  input stream txt-file close.

  /*  проверка не может быть совмещена с чтением, так как необходимо гарантировать
      наличие в считанных параметрах корневых значений иерархических параметров */

  for each cnf
  on error undo, return error return-value
  :
    run chk-param (buffer cnf) no-error.
    {&log-err}
  end.

  /* добавляем отсутствующее */
  run chk-unref in this-procedure
    ( input ?
    , input ?
    , input ?
    , input p-stand-alone
    ) no-error.
  {&log-err}

  /* удаляемся с миром */
  return if err-level > 0 then string (err-level) else "".

end.

/* обработка ранее не обработанных ошибок */
run log-sys-error in str-hdl ("При загрузке параметров возникла непредвиденная ошибка").
input stream txt-file close.
return if err-level > 0 then string (err-level) else "".

END PROCEDURE.


procedure get-db-list-for-cnf :

  define input  parameter p-stand-alone as logical          no-undo .
  define output parameter p-db-list     as character        no-undo .

  do
  on error  undo, return error substitute( "&1 (get-db-list-for-cnf). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-db-list-for-cnf). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-db-list-for-cnf). endkey", vss-workfile )
  :
    define variable v-num-entries as integer   no-undo .
    define variable v-ind         as integer   no-undo .

    define buffer buf_cnf      for cnf .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define buffer buf_db       for ub.db .

    assign
      p-db-list = "":U
    .

    if p-stand-alone = true then do:
      assign
        p-db-list = "?":U
      .
      for each buf_cnf
        where buf_cnf.db-num <> ?
        break by buf_cnf.db-num
      :
        if first-of( buf_cnf.db-num ) then do:
          assign
            p-db-list = substitute( "&1&2&3", p-db-list, {&comma-char}, buf_cnf.db-num )
          .
        end.
      end.
    end.
    else do:
      find first buf_sys-ctrl no-lock .
      if buf_sys-ctrl.db-num <> 0 then do:
        assign
          p-db-list = string( buf_sys-ctrl.db-num )
        .
      end.
      else do:
        for each buf_db no-lock
        on error undo, return error return-value
        :
          if buf_db.db-key <> "":U
            and buf_db.db-key <> ?
          then do:
            assign
              p-db-list = substitute( "&1&2&3", p-db-list, {&comma-char}, buf_db.db-num )
            .
          end.
        end.
        assign
          p-db-list = left-trim( p-db-list, {&comma-char} )
        .
      end.
    end.
  end.
  return .

end procedure. /* get-db-list-for-cnf */

/* ----------------------------------------------------------------------------------------------------------------------------
      Проверить обязательное наличие непривязанного параметра и добавить оный
--------------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE chk-unref .

  define input parameter p-param-code   like cnf.param-code no-undo .
  define input parameter p-db-list      as character        no-undo .
  define input parameter p-ingnore-type as character        no-undo .
  define input parameter p-stand-alone  as logical          no-undo .

  do
  on error  undo, return error substitute( "&1 (chk-unref). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (chk-unref). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (chk-unref). endkey", vss-workfile )
  :
    define variable v-db-num      as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-ind         as integer   no-undo .

    define buffer buf_cnf        for cnf .
    define buffer buf_cnf-struct for cnf-struct .


    if p-db-list = ? then do:
      run get-db-list-for-cnf in this-procedure
        ( input p-stand-alone
        , output p-db-list
        ) .
    end.

    for each buf_cnf-struct
      where p-param-code = ?
        or ( p-param-code <> ?
              and buf_cnf-struct.param-code = p-param-code
            )
    :
      if p-ingnore-type <> ?
        and lookup( buf_cnf-struct.param-type, p-ingnore-type ) > 0
      then do:
        next.
      end.

      assign
        v-num-entries = num-entries( p-db-list, {&comma-char} )
      .
      do v-ind = 1 to v-num-entries
      on error undo, return error return-value
      :
        assign
          v-db-num = integer( entry( v-ind, p-db-list, {&comma-char} ) )
        .
        find first buf_cnf no-lock
          where buf_cnf.param-code = buf_cnf-struct.param-code
            and buf_cnf.host-code  = 0
            and buf_cnf.obj-type   = ""
            and buf_cnf.obj-code   = 0
            and buf_cnf.beg-date   = {&beg-unlim-lcns}
            and buf_cnf.end-date   = {&end-unlim-lcns}
            and buf_cnf.db-num     = v-db-num
          no-error .
        if not available buf_cnf then do:
          create cnf.
          assign
            cnf.param-code = buf_cnf-struct.param-code
            cnf.host-code  = 0
            cnf.obj-type   = ""
            cnf.obj-code   = 0
            cnf.beg-date   = {&beg-unlim-lcns}
            cnf.end-date   = {&end-unlim-lcns}
            cnf.db-num     = v-db-num
            cnf.NotUsed    = True
          .
          run fill-default (buffer cnf).
        end.
      end.
    end.
  end.

END PROCEDURE.

/* ----------------------------------------------------------------------------------------------------------------------------
      Заполнить параметр значениями из настройки
--------------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE fill-default.

  define parameter buffer b-cnf for cnf.
  define buffer b2-cnf for cnf.               /* для обнаружения и удаления дублей */

  find first cnf-struct
    where cnf-struct.param-code = b-cnf.param-code
    no-error.
  if not available cnf-struct then do:
    return .
  end.
  /* присваиваем общие данные */
  assign
    b-cnf.param-value = if b-cnf.param-value = "" then cnf-struct.default-value else b-cnf.param-value
    b-cnf.param-ps    = cnf-struct.PS
    b-cnf.param-name  = cnf-struct.param-name
    b-cnf.conf-type   = cnf-struct.param-type
  .
  run cnv-param-type in str-hdl
    ( input cnf-struct.data-type
    ) no-error.  /* типы параметров не точно совпадают */
  {&log-err}
  assign
    b-cnf.param-type = return-value
  .

  /* зачищаем непредусмотренные привязки, при этом может возникнуть дублирование
    от которого избавляемся путем хирургического удаления*/

  if cnf-struct.attach-type <> {&cnf-company}
    and cnf-struct.attach-type <> {&cnf-object}
  then do:
    assign
      b-cnf.host-code  = 0
    .
  end.
  if cnf-struct.attach-type <> {&cnf-object}  then do:
    assign
      b-cnf.obj-code   = 0
      b-cnf.obj-type   = "":U
    .
  end.

  &scop buf1 b2-cnf.
  &scop buf2 = b-cnf.
  &scop link-word and

  find first b2-cnf
    where {&fields}
      and recid(b2-cnf) <> recid(b-cnf)
    no-error.

  if available b2-cnf then do:
    if b2-cnf.NotUsed = true then do:
        delete b2-cnf .
    end.
    else do:
        delete b-cnf .
    end.
  end.
END PROCEDURE.

/* ----------------------------------------------------------------------------------------------------------------------------
      Вывести в текстовый файл текущие значения параметров
--------------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE export-cnf.
  define input  parameter p-conf-handle   as handle    no-undo .
  define input  parameter p-stand-alone   as logical   no-undo .
  define input  parameter p-cur-recid-cnf as recid     no-undo .
  define input  parameter p-mark-cnf      as character no-undo .
  define output parameter p-qnty-cnf      as integer   no-undo .

  do
  on error  undo, return error substitute( "&1 (export-cnf). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (export-cnf). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (export-cnf). endkey", vss-workfile )
  :

    define variable v-md5-signature as character no-undo .
    define variable v-file-name     as character no-undo .
    define variable v-exp-type      as character no-undo .
    define variable v-db-list       as character no-undo .
    define variable v-sel-dbs       as character no-undo .
    define variable v-new-db-num    as integer   no-undo .
    define variable v-new-db-key    as character no-undo .
    define variable v-selected      as logical   no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-with-err      as logical   no-undo .
    define variable v-err-msg       as character no-undo .

    define buffer buf_cnf        for cnf .
    define buffer buf1_cnf       for cnf .
    define buffer buf_cnf-struct for cnf-struct .


    for each buf_cnf
      where buf_cnf.db-num  <> ?
        and buf_cnf.notused = false
      break by buf_cnf.db-num
    :
      if first-of( buf_cnf.db-num )
      then do:
        assign
          v-db-list = substitute( "&1&2&3", v-db-list, {&comma-char}, buf_cnf.db-num )
        .
      end.
    end.
    assign
      v-db-list  = left-trim( v-db-list, {&comma-char} )
      p-qnty-cnf = ?
    .

    if trim( v-db-list ) = "":U then do:
      message
        substitute("Нет включенных параметров ни для одной БД") skip
        view-as alert-box information .
      return .
    end.

    assign
      v-selected = false
    .
    if p-cur-recid-cnf <> ? then do:
      find first buf_cnf
        where recid( buf_cnf ) = p-cur-recid-cnf
        no-error .
      if available buf_cnf
        and buf_cnf.db-num <> ?      /* привязанный к БД              */
        and buf_cnf.NotUsed = false  /* включенный !!!                */
        and buf_cnf.ErrorExist = 0   /* без ошибок                    */
      then do:
        assign
          v-selected = true
        .
      end.
    end.

/*    if p-query-handle <> ?*/
/*      and p-query-handle :is-open = true*/
/*      and p-query-handle :num-results > 0*/
/*      assign*/
/*        v-from-query = true*/
/*      .*/
/*    end.*/
/*    else do:*/
/*      assign*/
/*        v-from-query = false*/
/*      .*/
/*    end.*/

    assign
      v-file-name = {&cnf-file}
    .
    run adm/expi.w
      ( input p-stand-alone
      , input v-selected
      , input-output v-file-name
      , input  v-db-list
      , output v-sel-dbs
      , output v-exp-type
      , output v-new-db-num
      , output v-new-db-key
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1 (export-cnf). Ошибка при запуске процедуры выбора параметров экспорта. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ).
    end.
    if v-exp-type = ? then do:
      return .
    end.

    /* проверяем наличие обязательных параметров */
    for each buf_cnf
      where buf_cnf.NotUsed = true
      ,first buf_cnf-struct
      where buf_cnf-struct.param-code = buf_cnf.param-code
    on error undo, return error return-value
    :
      if lookup( buf_cnf-struct.param-type, {&cnf-type-list-mandatory}) > 0
        and lookup( string( buf_cnf.db-num ), v-sel-dbs ) > 0
      then do:
        message
          "Не все обязательные параметры включены для выбранных БД"
          "Продолжить вывод?"
          view-as alert-box buttons yes-no update v-ok.
        if v-ok = false then do:
          return .
        end.
        else do:
          leave .
        end.
      end.
    end.

    for first buf_cnf
      where buf_cnf.ErrorExist <> 0
    on error undo, return error return-value
    :
      message
        "В наборе есть параметры с ошибками!" skip
        "Вывести их в файл?" skip(1)
        view-as alert-box buttons yes-no-cancel update v-with-err .
      if v-with-err = ? then do:
        return .
      end.
    end.

    assign
      p-qnty-cnf = 0
    .
    run waitfram-show in this-procedure ("Экспорт конфигурации").

    for each t-cnf
    :
      delete t-cnf .
    end.

    create t-cnf .

    output stream txt-file to value(v-file-name).

    block_exp:
    for each buf_cnf                 /* цикл по всему списку параметров */
      where buf_cnf.db-num <> ?      /* привязанных к БД                */
        and buf_cnf.NotUsed = false  /* и включенных !!!                */
      ,first buf_cnf-struct
      where buf_cnf-struct.param-code = buf_cnf.param-code
    on error  undo, retry block_exp
    on stop   undo, retry block_exp
    on endkey undo, retry block_exp
    :
      if retry then do:
        assign
          v-err-msg = substitute( "&1 (export-cnf). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        .
        output stream txt-file close.
        return error v-err-msg .
      end.
      else do:
        if v-with-err = false
          and buf_cnf.ErrorExist <> 0
        then do:
          next block_exp .
        end.
        if ( lookup( string( buf_cnf.db-num ), v-sel-dbs ) > 0
            and ( v-exp-type = "all":U
                  or ( v-exp-type = "mark":U    and lookup(string( recid( buf_cnf ) ), p-mark-cnf) > 0 )
                  or ( v-exp-type = "all-protect":U and lookup( buf_cnf-struct.param-type, {&cnf-type-list-protect}) > 0 )
                  or ( v-exp-type = "all-mandatory":U and lookup( buf_cnf-struct.param-type, {&cnf-type-list-mandatory}) > 0 )
                )
          )
          or ( v-exp-type = "curr":U
                and recid( buf_cnf ) = p-cur-recid-cnf
              )
        then do:

          buffer-copy buf_cnf to t-cnf .

          if v-new-db-num <> ? then do:
            assign
              t-cnf.db-num = v-new-db-num
              t-cnf.db-key        = v-new-db-key
              t-cnf.param-encoded = "":U
            .
          end.

          if p-stand-alone = true    /* автономная работа */
            and lookup( t-cnf.conf-type, {&cnf-type-list-protect} ) > 0
          then do:
            run conf-enc in p-conf-handle
              ( input  t-cnf.db-num
              , input  t-cnf.db-key
              , input  t-cnf.param-code
              , input  t-cnf.param-value
              , input  t-cnf.beg-date
              , input  t-cnf.end-date
              , output t-cnf.param-encoded
              ) no-error.
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute("Ошибка кодировки параметра &1 для БД &2", t-cnf.param-code, t-cnf.db-num ) skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo block_exp, retry block_exp .
            end.
          end.

          export stream txt-file delimiter {&delimiter} t-cnf except {&except-list}.

          assign
            p-qnty-cnf = p-qnty-cnf + 1
          .
        end.
      end.
    end.

    output stream txt-file close.

    delete t-cnf .

    assign
      file-info:file-name = search( v-file-name )
      v-file-name         = file-info:full-pathname
    .

    run gbl/md5.p
      ( input  v-file-name
      , output v-md5-signature
      ) no-error.
    if error-status :error
      or trim( v-md5-signature ) = "":U
    then do:
      return error substitute( "&1 (export-cnf). Ошибка при подсчете контрольной суммы (&2) файла конфигурации!. &3&4&5"
                               , vss-workfile
                               , v-md5-signature
                               , return-value
                               , {&new-line}
                               , error-status :get-message ( 1 )
                             ).
    end.

    output stream txt-file to value(v-file-name) append.
    put stream txt-file unformatted substitute( "&1&2", {&delim-nws}, sum-enc( v-md5-signature, 10 ) ) skip.
    output stream txt-file close.

    run waitfram-hide in this-procedure .

  end.

end procedure.

/* ----------------------------------------------------------------------------------------------------------------------------
 Проверить строку конфигурации на соответствие файлу схемы конфигурации и дополнить параметр для вывода
 для параметров, являющихся корнем дерева, сразу размножаются все неиспользуемые параметры
--------------------------------------------------------------------------------------------------------------------------------- */

PROCEDURE chk-param.

  define parameter buffer par-cnf for cnf.

  assign
    err-level = par-cnf.ErrorExist
  .

  find first cnf-struct /*  Найти соответсвующую параметру настройку */
    where cnf-struct.param-code = par-cnf.param-code
    no-error.
  if not available cnf-struct then do:
    assign
      par-cnf.NotUsed    = true
      par-cnf.ErrorExist = 2
    .
    run log-error in str-hdl ("параметр " + par-cnf.param-code + " не допустим в текущей схеме", 1).
    return.
  end.

  /* Заполняем поля из структуры */
  assign
    par-cnf.param-name = cnf-struct.param-name
    par-cnf.param-PS   = cnf-struct.PS
  .

  /* при загрузке вне базы заменяем характеристики поля настроечными */
  if stand-alone = true then do:
    assign
      par-cnf.conf-type = cnf-struct.param-type
    .
  end.


  if cnf-struct.param-type <> par-cnf.conf-type then do:
    run log-error in str-hdl ("параметр " + par-cnf.param-code + " имеет тип настройки (" +
                              par-cnf.conf-type + "), несоответствующий схеме (" + cnf-struct.param-type + ")", 2).
  end.

  run cnv-param-type in str-hdl (cnf-struct.data-type).
  if par-cnf.param-type <> return-value then do:
    run log-error in str-hdl ("параметр " + par-cnf.param-code + " имеет тип параметра (" +
                                par-cnf.param-type + "), несоответствующий схеме (" + cnf-struct.data-type + ")", 2).
  end.

  /* проверка привязок по объектам-фирмам-пользователям ведется только при коннекте с базой */
  case cnf-struct.attach-type:
    when {&cnf-company} then do:
        if par-cnf.host-code <> 0 and not stand-alone then do:
          run chk-company in db-hdl (par-cnf.host-code) no-error.
          if return-value <> "" then do:
              run log-error in str-hdl ("параметр "  + par-cnf.param-code + " имеет неправильный код фирмы "
                                        + string(par-cnf.host-code), 1).
              if can-find (first cnf where cnf.param-code  = par-cnf.param-code and
                                            cnf.host-code   = 0                  and
                                            recid (cnf)    <> recid (par-cnf))  then do:
                run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                            + string(par-cnf.host-code) + " удален", 1).
                return.
              end.
              else do:
                par-cnf.host-code = 0 .
                run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                            + string(par-cnf.host-code) + " привязка отменена", 1).
              end.
          end.
        end.
        if (par-cnf.obj-code <> 0   or
            par-cnf.obj-type <> "" ) then do:
              run log-error in str-hdl ("параметр "  + par-cnf.param-code + " не может иметь привязки к объекту "
                                        + par-cnf.obj-type + " " + string (par-cnf.obj-code), 1).
              assign par-cnf.is-changed  = true
                      par-cnf.obj-code = 0
                      par-cnf.obj-type = "".
        end.
    end.
    when {&cnf-object} then do:
        define variable obj-host-code like par-cnf.host-code no-undo.
        if not stand-alone then do:
            if par-cnf.host-code <> 0 then do:
              run chk-company in db-hdl (par-cnf.host-code) no-error.
              if return-value <> "" then do:
                  run log-error in str-hdl ("параметр "  + par-cnf.param-code + " имеет неправильный код фирмы "
                                            + string(par-cnf.host-code), 1).
                  if can-find (first cnf where cnf.param-code  = par-cnf.param-code and
                                                cnf.host-code   = 0                  and
                                                cnf.obj-type    = ""                 and
                                                cnf.Obj-code    = 0                  and
                                                recid (cnf)    <> recid (par-cnf))  then do:
                    run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                                + string(par-cnf.host-code) + " удален", 1).
                    delete par-cnf.
                    return.
                  end.
                  else do:
                    assign
                      par-cnf.host-code = 0
                      par-cnf.obj-type  = ""
                      par-cnf.obj-code  = 0 .
                    run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                                + string(par-cnf.host-code) + " привязка отменена", 1).
                  end.
              end.
            end.
            if par-cnf.obj-code  <> 0 then do:
              run chk-host-code in db-hdl (par-cnf.obj-type, par-cnf.obj-code, output obj-host-code).
              if obj-host-code      = ?              or
                par-cnf.host-code <> obj-host-code   then do:
                run log-error in str-hdl ("параметр "  + string (par-cnf.param-code) + " код фирмы " + string(par-cnf.host-code)
                                            + " номер объекта " + string(par-cnf.obj-code)
                                            + " тип объекта " + string(par-cnf.obj-type)
                                            + " имеет несоответствие объекта и фирмы ", 1).
                if can-find (first cnf where cnf.param-code  = par-cnf.param-code and
                                            cnf.host-code   = par-cnf.host-code  and
                                            cnf.obj-type    = ""                 and
                                            cnf.Obj-code    = 0                  and
                                            recid (cnf)    <> recid (par-cnf))  then do:
                  run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы " + string(par-cnf.host-code)
                                              + " номер объекта " + string(par-cnf.obj-code)
                                              + " тип объекта " + string(par-cnf.obj-type)
                                              + " удален", 1).
                  delete par-cnf.
                  return.
                end.
                else do:
                  assign
                    par-cnf.obj-type  = ""
                    par-cnf.obj-code  = 0 .
                  run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                            + string(par-cnf.host-code) + " привязка к объекту отменена", 1).
                end.
              end.
            end.
        end.
    end.
    otherwise do:
        if par-cnf.host-code <> 0 then do:
              run log-error in str-hdl ("параметр "  + string(par-cnf.param-code) + " не может иметь привязки к фирме "
                                        + string(par-cnf.host-code), 1).
              assign par-cnf.is-changed    = true
                      par-cnf.host-code = 0 .
        end.
        if par-cnf.obj-code <> 0   or
          par-cnf.obj-type <> ""  then do:
              run log-error in str-hdl ("параметр "  + string(par-cnf.param-code) + " не может иметь привязки к объекту "
                                        + par-cnf.obj-type + " " + string (par-cnf.obj-code), 1).
              assign par-cnf.is-changed   = true
                      par-cnf.obj-code = 0
                      par-cnf.obj-type = "".
        end.
    end.
  end case.

  /* проверка вхождения значения параметра в список допустимых */
  if cnf-struct.list-value <> "" then do:
    if lookup(par-cnf.param-value, cnf-struct.list-value) = 0 then do:
        run log-error in str-hdl ("параметр "  + string(par-cnf.param-code) + " имеет недопустимое значение "
                                  + par-cnf.param-value + "(из " + cnf-struct.list-value + ")", 1).
    end.
  end.

  par-cnf.ErrorExist = maximum (err-level, par-cnf.ErrorExist) .

END PROCEDURE.