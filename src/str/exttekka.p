block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exttekka.p $
$Archive: str/exttekka.p $

Вывод на кассу МАРИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/25/06
Author: Bakhtadze Natalya
Creation date: 01/25/06

*/

/*

на входе есть несколько файлов
по одному текстовому файлу для каждого выгружаемого объекта    fffffff.[n] - fffffff берется из sequens n - номер объекта в
формате 999
и один файл задания  с расширением .tsk
в нем лежит dump временной таблицы управления выводом

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exttekka.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/exttekka.p $":U .
define variable vss-description as character no-undo init "Вывод на кассу МАРИЯ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ str/tekkatsk.i }
{ gbl/cur-time.i }

define temp-table tt-shift-info no-undo
field is-current as logical
field is-petrol as logical
field num-recs-petrol as decimal
field num-recs-petrol-prev as decimal
field num-recs as decimal
field num-recs-prev as decimal
field jour-no as decimal
field rec-no as decimal
field z-count as integer
field chk-date as date
field info-from as character
field order as integer
field was-open as logical
field is-close as logical
field is-last-closed as logical
field tekka-date-chr as character
field tekka-time-chr as character
field shift-open-date-chr as character
field shift-open-time-chr as character
field shift-close-date-chr as character
field shift-close-time-chr as character
index pi is primary
info-from
is-petrol
z-count
chk-date
index pi2
info-from
is-petrol
z-count
is-current
index iorder
order
.

define variable ii               as integer   no-undo .
define variable jj               as integer   no-undo .
define variable tempfile-tsk     as character no-undo .
define variable loc#log          as logical   no-undo .
define variable res              as character no-undo .
define variable p-param          as character no-undo .
define variable v-dir-path       as character no-undo .
/*директория Add-in*/
define variable v-temp-dir       as character no-undo .
/*директория обмена - там лежат файлы послыаемые и принимаемые*/
define variable err-file         as character no-undo .
define variable ss               as character no-undo .
define variable v-field-value    as character no-undo .
define variable v-field-value-ibm866  as character no-undo .
define variable v-obj-list       as character no-undo .
define variable ch#TekkaApplication as com-handle no-undo .
define variable v-dopi as integer no-undo .
define variable v-error          as character no-undo .
define variable v-next-obj-num as integer no-undo .
define variable v-if-next-obj-num as integer no-undo .
define variable rv as integer no-undo .
define variable v-return-value as character no-undo .
define variable v-is-spool-request as logical no-undo .
define variable v-closed-shift-num as integer no-undo .
define variable v-closed-shift-info as character no-undo .
define variable v-date-time-info as character no-undo .
define variable v-num-recs-info as character no-undo .
define variable v-petrol-exist as logical no-undo .
define variable v-record-shift as integer no-undo .
define variable v-string as character no-undo .


define stream for-task .
define stream TekkaStream .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer sec_temp-tekka-tsk for temp-tekka-tsk.

do
on error undo, return error return-value
:

  assign
    p-param = session :parameter
  .
  if num-entries(p-param) <> 4 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный вызов процедуры обмена информацией с ЭККА МАРИЯ в дополнительной сессии PROGRESS" skip
      "Неверное количество параметров" num-entries(p-param) skip
      "Параметры" p-param skip
      view-as alert-box error.
    run write-err in this-procedure ( input "Ошибка параметров") .
     quit .
  end.

  assign
  v-dir-path     = trim(entry(1, p-param), {&double-quote})
  err-file       = entry(2, p-param)
  tempfile-tsk   = entry(3, p-param)
  v-temp-dir     = trim(entry(4, p-param), {&double-quote})
  .
  /* проверка входных параметров */
  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .

  assign
    file-info:file-name = v-temp-dir
  .
  if not (file-info:file-type <> ?
    and index( file-info:file-type, "D":U ) <> 0)
  then do:
    run Write-err in this-procedure ( input "Неизвестное имя директории обмена") .
    quit.
  end.
  /* импорт параметров форматирования */
  run make-temp-tekka-tsk in this-procedure ( output v-obj-list) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при чтении параметров коммуникации из файла" skip
      "Файл параметров коммуникации" tempfile-tsk skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run Write-err in this-procedure ( input "Неверные данные в файле параметров коммуникации") .
    quit.
  end.
  /*
  run tekkatsk-verify-schema in this-procedure (
                                                input v-obj-list
                                               ,input v-dir-path) no-error .
  if error-status:error then do:
    run waitfram-hide in this-procedure .
    run Write-err in this-procedure (input "Ошибки при проверке схемы") .
    quit.
  end.
  */
  run waitfram-show in this-procedure ( input "Ждите! Идет обмен информацией...").
  { cmp/relescom.i ch#TekkaApplication }
  CREATE "AddIn.TAddIn" ch#TekkaApplication no-error.
  if error-status:error then DO:
    run  ClearTekka in this-procedure .
    run  write-err in this-procedure ( input "Ошибка при вызове OLE-сервера") .
    quit.
  End.
  res = ch#TekkaApplication:SetDataPath(v-dir-path).
  if res <> '0' then do:
    run  ClearTekka in this-procedure .
    run  write-err in this-procedure (input substitute("Неверная директория OLE-сервера &1 или другая ошибка(код ошибки &2)"
                                            , v-dir-path
                                            , res)) .
    quit.
  end.
      _tasks:
  for each temp-tekka-tsk
  break
  by temp-tekka-tsk.order-num
  by temp-tekka-tsk.range
  by temp-tekka-tsk.obj-num
  :
    if temp-tekka-tsk.filename = '':u
    and temp-tekka-tsk.send-get <> 'task':U then next.
    case temp-tekka-tsk.send-get:
      when 'send':U then do:
        if temp-tekka-tsk.by-record then do:
          v-record-shift = temp-tekka-tsk.min-plu - 1.
        end.
        else do:
          v-record-shift = 0.
        end.
        if not temp-tekka-tsk.filename begins '-' then do:
          if v-full-path <> '':U
          and last-of( temp-tekka-tsk.range)
          then do:
            OS-delete value(v-full-path).
          end.
          run gbl/filename.p (
             input  temp-tekka-tsk.filename
            ,output v-full-path
            ,output v-path
            ,output v-file-name
            ,output v-file-name-no-ext
            ,output v-file-name-ext
            ) .
          v-dopi = ch#TekkaApplication:hook().
          if not temp-tekka-tsk.by-record then do:
            res = ch#TekkaApplication:CreateObj(temp-tekka-tsk.obj-num, 0).
            if res <> '1' then do:
              run write-err in this-procedure ( input substitute("Ошибка при попытке создать объект &1 в памяти", temp-tekka-tsk.obj-num)) .
              quit.
            end.
            /*
            v-error = ch#TekkaApplication:GetError().
            if v-error <> {&tekka-no-error-char} then do:
              run write-err in this-procedure ( input v-error) .
              quit.
            end.
            */
          end. /*if not temp-tekka-tsk.by-record then do:*/
          input stream TekkaStream from value(temp-tekka-tsk.filename) .
          repeat :
            create temp-tekka-record.
            assign
            temp-tekka-record.obj-num = temp-tekka-tsk.obj-num
            temp-tekka-record.plu = ?
            .
            import stream TekkaStream unformatted ss .
            if temp-tekka-tsk.num-fields <> num-entries(ss, {&delim-par} ) then do:

            end.
            /*номер записи*/
            ii = integer(entry(1, ss, {&delim-key})).
            assign
            temp-tekka-record.plu = ii
            temp-tekka-record.body = (if num-entries(ss, {&delim-key}) > 1
                                      then entry(2, ss, {&delim-key}) else '':U)
            .
          end. /*repeat :*/
          input stream TekkaStream close.
          for each buf_temp-tekka-tsk where
                  buf_temp-tekka-tsk.obj-num = temp-tekka-tsk.obj-num:
            buf_temp-tekka-tsk.filename = '-' + buf_temp-tekka-tsk.filename.
          end.
        end. /*if <> '-'*/
        if temp-tekka-tsk.by-record then do:
          res = ch#TekkaApplication:CreateObjN(temp-tekka-tsk.obj-num
                                        ,(temp-tekka-tsk.max-plu - temp-tekka-tsk.min-plu + 1 )
                                        ,temp-tekka-tsk.min-plu - 1 ). /*и где offset?????????*/
          if res <> '1' then do:
            run write-err in this-procedure ( input substitute("Ошибка при попытке создать объект &1 в памяти", temp-tekka-tsk.obj-num)) .
            quit.
          end.
          /*v-error = ch#TekkaApplication:GetError().
          if v-error <> {&tekka-no-error-char} then do:
            run write-err in this-procedure ( input v-error) .
            quit.
          end.*/
        end.
        if temp-tekka-tsk.binary then do:
          if temp-tekka-tsk.shift-fields <> 0 then do:
            v-dopi = ch#TekkaApplication:StartGetObj(string(temp-tekka-tsk.obj-num)
                                            ,temp-tekka-tsk.cash-num-char /*"5712000000"*/
                                            ,temp-tekka-tsk.port-num /*"COM1"*/
                                            ,temp-tekka-tsk.way /* "local" или "ftp" или "номер телефона"*/
                                            ,temp-tekka-tsk.pswd /* "00000000"*/ ).
            run waiting in this-procedure ( input temp-tekka-tsk.obj-name, input temp-tekka-tsk.waiting-sek) no-error.
            if error-status:error then do:
              run write-err in this-procedure ( input error-status:get-message(1) ) .
              quit.
            end.
            if return-value <> '':u then do:
              run write-err in this-procedure ( input return-value  ) .
              quit.
            end.
              if temp-tekka-tsk.shift-fields < 0 then
              temp-tekka-tsk.shift-fields = 0.
            end. /*        if temp-tekka-tsk.shift-fields <> 0 then do:*/
          end. /*binary*/
        _record:
        for each temp-tekka-record where
                 temp-tekka-record.obj-num = temp-tekka-tsk.obj-num
             and temp-tekka-record.plu >= temp-tekka-tsk.min-plu
             and temp-tekka-record.plu <= temp-tekka-tsk.max-plu
        by
        temp-tekka-record.plu:
          if temp-tekka-record.plu = ? then do:
            delete temp-tekka-record.
            next _record.
          end.
          if temp-tekka-record.body = '':U then do:
            v-error = ch#TekkaApplication:SetFIeld(temp-tekka-record.plu , 1, '':U).
            if v-error <> '1' then do:
              run write-err in this-procedure ( input substitute("Устанавливаемое поле в объекте не существует: " +
                                                                  "очищаемое поле 1 запись &2 объект &3&4"
                                                                  , {&new-line}
                                                                  , temp-tekka-record.plu
                                                                  , temp-tekka-tsk.obj-num
                                                                  , ("|" + v-error + "|")
                                                                  )
                                            ) .
              quit.
            end.
          end.
          else do:
            _jj:
            do jj = 1 to temp-tekka-tsk.num-fields:
              /*
              find first buf_temp-tekka-schema
              where buf_temp-tekka-schema.host = 'ibs'
                and buf_temp-tekka-schema.obj-num = temp-tekka-tsk.obj-num
                and buf_temp-tekka-schema.field-num = jj.*/
                /*
                if buf_temp-tekka-schema:bin-group = '':U then
                v-field-value = dynamic-function ('set-' + buf_temp-tekka-schema.custom-type, entry(jj, ss, {&delim-par} )) .
                else
                v-field-value = dynamic-function ('set-nm' + buf_temp-tekka-schema.custom-type
                                                  , entry(jj, temp-tekka-record.body, {&delim-par} )
                                                  , buf_temp-tekka-schema.custom-type) .
                */.
              v-field-value = entry(jj, temp-tekka-record.body, {&delim-par}) .
              if v-field-value = {&question-mark} then do:
                next _jj.
              end.
              v-error = ch#TekkaApplication:SetFIeld(temp-tekka-record.plu, jj  +  temp-tekka-tsk.shift-fields, v-field-value).
              if v-error <> '1' then do:

                run write-err in this-procedure ( input substitute("Устанавливаемое поле в объекте не существует: " +
                                                                    "поле &2 запись &3 объект &4: &5"
                                                                    , {&new-line}
                                                                    , jj + temp-tekka-tsk.shift-fields
                                                                    , temp-tekka-record.plu
                                                                    , temp-tekka-tsk.obj-num
                                                                    , v-error
                                                                    )
                                              ) .
                quit.
              end.
            END. /*            do jj = 1 to temp-tekka-tsk.num-fields:*/
          end. /*body = '':U*/
          delete temp-tekka-record.
        end. /*        for each temp-tekka-record where*/
        if temp-tekka-tsk.by-record then do:
          res = ch#TekkaApplication:StartPutObj(temp-tekka-tsk.cash-num-char /*"5712000000"*/
                                          ,temp-tekka-tsk.port-num /*"COM1"*/
                                          ,temp-tekka-tsk.way /* "local" или "ftp" или "номер телефона"*/
                                          ,temp-tekka-tsk.pswd /* "00000000"*/ ).

        end.
        else do:
          res = ch#TekkaApplication:StartPutObj(temp-tekka-tsk.cash-num-char /*"5712000000"*/
                                          ,temp-tekka-tsk.port-num /*"COM1"*/
                                          ,temp-tekka-tsk.way /* "local" или "ftp" или "номер телефона"*/
                                          ,temp-tekka-tsk.pswd /* "00000000"*/ ).
        end.
        run waiting in this-procedure ( input temp-tekka-tsk.obj-name, input temp-tekka-tsk.waiting-sek) no-error.
        if error-status:error then do:
          run write-err in this-procedure ( input error-status:get-message(1) ) .
          quit.
        end.
        if return-value <> '':u then do:
          run write-err in this-procedure ( input return-value  ) .
          quit.
        end.
      end. /*send*/
      when 'get':U then do:
        for each temp-tekka-record:
          delete temp-tekka-record.
        end.
        v-dopi = ch#TekkaApplication:hook().
        if not temp-tekka-tsk.by-record then do:
          ch#TekkaApplication:CreateObj(temp-tekka-tsk.obj-num, 0).
          res = ch#TekkaApplication:CreateObj(temp-tekka-tsk.obj-num, 0).
          if res <> '1' then do:
            run write-err in this-procedure ( input substitute("Ошибка при попытке создать объект &1 в памяти", temp-tekka-tsk.obj-num)) .
            quit.
          end.
          /*
          v-error = ch#TekkaApplication:GetError().
          if v-error <> {&tekka-no-error-char} then do:
            run write-err in this-procedure ( input v-error).
            quit.
          end.
          */
        end.
        else do:
          if not v-is-spool-request
          and lookup(string(temp-tekka-tsk.obj-num), {&spool-objects}) > 0 then do:
            assign
            v-is-spool-request = yes
            .
            v-petrol-exist = tekka-is-petrol-journal (input temp-tekka-tsk.obj-num).
          end.
          if v-is-spool-request
          and v-next-obj-num = 0
          and tekka-is-first-journal(temp-tekka-tsk.obj-num)
          and tekka-is-closed-shift-journal(temp-tekka-tsk.obj-num) > 0 then do:
            v-next-obj-num = 0.
            v-if-next-obj-num = 0.
          end.
          if v-next-obj-num > 0
          and temp-tekka-tsk.obj-num <> v-next-obj-num then do:
            next _tasks.
          end.
          v-next-obj-num = 0.
          if v-is-spool-request = yes
          and temp-tekka-tsk.other-info <> '':U
          and tekka-is-first-journal(temp-tekka-tsk.obj-num) = yes
          then do:
            v-return-value = ''.
            run get-spool-optimize in this-procedure ( buffer temp-tekka-tsk, v-petrol-exist ) no-error .
            if not error-status:error then do:
              v-return-value = return-value.
              if v-date-time-info <> '':U then do:
                output stream TekkaStream to value(temp-tekka-tsk.filename).
                put stream TekkaStream unformatted
                temp-tekka-tsk.obj-num {&delim-key}
                -1 {&delim-key}
                "tekka-date-time=" v-date-time-info '=' temp-tekka-tsk.cash-num
                skip.
                output stream TekkaStream  close.
              end.
              do rv = 1 to num-entries(v-return-value):
                if entry(rv, v-return-value) begins 'next-object=' then do:
                  assign
                  v-next-obj-num = integer(entry(2, entry(rv, v-return-value), '=')).
                  next _tasks.
                end.
                if entry(rv, v-return-value) begins 'if-read-0-then-next-object=' then do:
                  assign
                  v-if-next-obj-num = integer(entry(2, entry(rv, v-return-value), '=')).
                end.
                if entry(rv, v-return-value) begins 'close-shift=' then do:
                  output stream TekkaStream to value(temp-tekka-tsk.filename) append.
                  put stream TekkaStream unformatted
                  temp-tekka-tsk.obj-num {&delim-key}
                  0 {&delim-key}
                  entry(rv, v-return-value)
                  (if integer(left-trim(entry(rv, v-return-value), 'close-shift=')) = v-closed-shift-num
                   then ({&delim-par} + v-closed-shift-info)
                   else '':U)
                  skip.
                  output stream TekkaStream  close.
                end.
                if entry(rv, v-return-value) = 'next' then do:
                  next _tasks.
                end.
                if entry(rv, v-return-value) begins "min-plu=" then do:
                  temp-tekka-tsk.min-plu = integer(entry(2, entry(rv, v-return-value), '=':U)).
                  if temp-tekka-tsk.secondary > 0 then do:
                    find first sec_temp-tekka-tsk where
                              sec_temp-tekka-tsk.obj-num = temp-tekka-tsk.secondary no-error .
                    if available sec_temp-tekka-tsk then do:
                      assign
                      sec_temp-tekka-tsk.min-plu =  10000 * (decimal(entry(2, entry(rv, v-return-value), '=':U)) -
                                                    temp-tekka-tsk.min-plu)
                      .
                    end.
                  end.
                end.
              end.
            end. /*not error-status-error*/
          end.
        end.
        v-dopi = ch#TekkaApplication:StartGetObj(string(temp-tekka-tsk.obj-num)
                                        ,temp-tekka-tsk.cash-num-char /*"5712000000"*/
                                        ,temp-tekka-tsk.port-num /*"COM1"*/
                                        ,temp-tekka-tsk.way /* "local" или "ftp" или "номер телефона"*/
                                        ,temp-tekka-tsk.pswd /* "00000000"*/ ).
        run waiting in this-procedure ( input temp-tekka-tsk.obj-name, input temp-tekka-tsk.waiting-sek) no-error.
        if error-status:error then do:
          run write-err in this-procedure ( input error-status:get-message(1) ) .
          quit.
        end.
        if return-value <> '':u then do:
          run write-err in this-procedure ( input return-value  ) .
          quit.
        end.
        if temp-tekka-tsk.by-record then do:
          if temp-tekka-tsk.num-records = 0
          or temp-tekka-tsk.num-records = ? then  do:
            temp-tekka-tsk.num-records = ch#TekkaApplication:GetRecordsCount().
          end.
          if temp-tekka-tsk.max-plu = ? then do:
            assign
            temp-tekka-tsk.max-plu = temp-tekka-tsk.num-records.
          end.
          if temp-tekka-tsk.min-plu = ? then do:
            assign
            temp-tekka-tsk.min-plu = 0.
          end.
          if temp-tekka-tsk.num-records = 0 then do:
            if v-if-next-obj-num > 0 then do:
              assign
              v-next-obj-num = v-if-next-obj-num
              v-if-next-obj-num  = 0
              .
            end.
            v-next-obj-num = tekka-get-next-obj-num ( input temp-tekka-tsk.obj-num, input v-petrol-exist).
            NEXT _tasks.
          end.
          if temp-tekka-tsk.min-plu > temp-tekka-tsk.num-records
          and v-is-spool-request = yes
          and temp-tekka-tsk.num-records < tekka-get-max-journal-record-num  ( input temp-tekka-tsk.obj-num)
          then do:
            v-next-obj-num = tekka-get-next-obj-num ( input temp-tekka-tsk.obj-num, input v-petrol-exist).
            NEXT _tasks.
          end.
          output stream TekkaStream to value(temp-tekka-tsk.filename) append.
          if temp-tekka-tsk.num-fields = 0
          or temp-tekka-tsk.num-fields = ? then do:
            temp-tekka-tsk.num-fields = ch#TekkaApplication:GetFieldsCount().
          end.
          do ii = max(1, temp-tekka-tsk.min-plu) to minimum(temp-tekka-tsk.num-records, temp-tekka-tsk.max-plu):
            do jj = 1 to temp-tekka-tsk.num-fields:
              v-field-value = ch#TekkaApplication:GetField(ii, jj).
              /*преобразуем в человеческий вид и пнем в файл*/
              /*
              find first buf_temp-tekka-schema
              where buf_temp-tekka-schema.host = 'ibs'
                and buf_temp-tekka-schema.obj-num = temp-tekka-tsk.obj-num
                and buf_temp-tekka-schema.field-num = jj.
             */
              /*
              put stream TekkaStream unformatted
              dynamic-function ('get-' + buf_temp-tekka-schema.custom-type, v-field-value) {&delim-par} .
              */
              if jj = 1 then
              put stream TekkaStream unformatted
              temp-tekka-tsk.obj-num {&delim-key}
              ii {&delim-key}.
              put stream TekkaStream unformatted
              v-field-value {&delim-par} .
            end. /*do jj*/
            put stream TekkaStream unformatted skip.
          END. /*do ii*/
          output stream TekkaStream  close.
          if temp-tekka-tsk.num-records < tekka-get-max-journal-record-num  ( input temp-tekka-tsk.obj-num)
          and temp-tekka-tsk.secondary = 0
          then do:
            assign
            v-next-obj-num = tekka-get-next-obj-num ( input temp-tekka-tsk.obj-num, input v-petrol-exist).
          end.
        end. /*if by-record*/
        else do:
          v-error = ch#TekkaApplication:SaveXml(temp-tekka-tsk.filename).
          if v-error <> '0' then do:
            run write-err in this-procedure ( input v-error ).
            quit.
          end.
          /*
          v-error = ch#TekkaApplication:GetError().
          if v-error <> {&tekka-no-error-char} then do:
            run write-err in this-procedure ( input v-error ).
            quit.
          end.
          */
        end.
      end. /*when 'get'*/
      when 'task':U then do:
        v-string = substitute("select &1 from &2 where &3"
                              ,temp-tekka-tsk.obj-name
                              ,temp-tekka-tsk.cash-num-char
                              ,temp-tekka-tsk.other-info).
        v-error = ch#TekkaApplication:AddTask( v-string).
        if v-error <> {&tekka-no-error-char} then do:
          run write-err in this-procedure ( input v-error ).
          quit.
        end.
      end. /*when 'task':U then do:*/
    END CASE.
  END.  /*конец цикла по temp-tekka-tsk*/
  if v-full-path <> '':U
  then do:
    OS-delete value(v-full-path).
  end.


  run ClearTekka in this-procedure .
  PROCESS EVENTS.
  run waitfram-hide in this-procedure .
  run write-err in this-procedure ( input {&new-line}) .
  quit.

  procedure ClearTekka :

    do
    on error undo, return error
    :
      run waitfram-hide in this-procedure .
      { cmp/relescom.i ch#TekkaApplication }
      PROCESS EVENTS.
    end.

  end procedure. /* ClearTekka */

  procedure write-err :
    do
    on error undo, return error
    :
      define input parameter p-is-err as character no-undo .
      run gbl/bat-err.p (
         input err-file
        ,input (if p-is-err <> "":U then p-is-err else "")
        ).
    end.
  end.
end.

procedure make-temp-tekka-tsk :
define output parameter p-obj-list as character no-undo .

  do
  on error undo, return error return-value
  :
    define buffer buf_temp-tekka-tsk for temp-tekka-tsk .

    for each buf_temp-tekka-tsk
    on error undo, return error
    :
      delete buf_temp-tekka-tsk .
    end.

    input stream for-task from value( tempfile-tsk ) .

    repeat
    :
      create buf_temp-tekka-tsk .
      import stream for-task buf_temp-tekka-tsk .
      assign
      p-obj-list = p-obj-list + {&comma-char} + string(buf_temp-tekka-tsk.obj-num).
    end.
    input stream for-task close.
    OS-delete value( tempfile-tsk ).
    p-obj-list = trim(p-obj-list, {&comma-char}).
  end.

end procedure. /* make-temp-tekka-tsk */

procedure waiting :
define input parameter p-mess as character no-undo .
define input parameter p-waiting as integer no-undo .
define variable v-exec-time as integer no-undo .
define variable v-answer as character no-undo .
define variable v-start-time as int64     no-undo .
assign
v-start-time = etime
.
_do:
do while true:
/*    assign*/
/*      v-exec-time = v-exec-time + 1*/
/*    .*/
    /* делаем более точные оценки прошедшего времени на основании etime */
  assign
  v-exec-time = (etime - v-start-time) / 1000
  .

  run waitfram-show in this-procedure ( input substitute("&1 Время ожидания &2"
                                      , p-mess
                                      , string(v-exec-time, "HH:MM:SS")))
  .
  v-answer = ch#TekkaApplication:GetStatus().
  if v-answer = 'work' then next _do.
  else leave _do.

  if v-exec-time >= p-waiting then do:
    return substitute("Превышено время ожидания: &1 ЭККА не ответила"). /* --->>>--- */
  end.
end.
if v-answer = 'done' then return '':U.
v-error = ch#TekkaApplication:GetError().
if v-error = {&tekka-no-error-char} then do:
  return {&tekka-no-error-char} .
end.
else do:
return v-error.
end.

end procedure. /* waiting */

procedure get-spool-optimize:
define parameter buffer buf_temp-tekka-tsk for temp-tekka-tsk.
define input parameter p-petrol-exist as logical no-undo .
define variable vvv as character no-undo .
define variable v-date as date no-undo .
define variable v-date-p as date no-undo .
define variable v-z-count as integer no-undo init 0.
define variable v-z-count-p as integer no-undo init 0.
define variable v-num-recs as decimal no-undo .
define variable v-num-recs-p as decimal no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-is-petrol-journal as logical no-undo .
define variable v-is-closed-journal as integer no-undo .
define variable ii as integer no-undo .
define variable kk as integer no-undo .
define variable v-page-len as integer no-undo .
define variable v-page-len-p as integer no-undo .
define variable v-jour-no as integer no-undo .
define variable v-jour-no-p as integer no-undo .
define variable v-line-num as decimal no-undo .
define variable v-line-num-p as decimal no-undo .
define variable v-field-z-count as integer no-undo .
define variable v-field-z-count-p as integer no-undo .
define variable v-field-date as integer no-undo .
define variable v-field-date-p as integer no-undo .
define variable v-cd-num-recs as integer no-undo .
define variable v-prev-cd-num-recs as integer no-undo .
define variable v-cd-date as date no-undo .
define variable v-cd-date-chr as character no-undo .
define variable v-dopi as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-year as integer no-undo .
define variable v-cd-z-count-orig as integer no-undo .
define variable v-cd-z-count as integer no-undo .
define variable v-cd-z-close as logical no-undo .
define variable v-prev-cd-z-count-orig as integer no-undo .
define variable v-prev-cd-z-count as integer no-undo .
define variable v-prev-cd-z-close as logical no-undo .
define variable v-obj-num as integer no-undo .
define variable v-to-read-obj-num as integer no-undo .
define variable v-to-read-num-recs as decimal no-undo .
define variable v-return-value as character no-undo .
define variable v-get-closed-shift-info as logical no-undo .

define buffer buf_tt-shift-info for tt-shift-info.
define buffer bufm_tt-shift-info for tt-shift-info.

  do
  on error undo, return error return-value
  :
    if p-petrol-exist then do:
      assign
      v-is-petrol-journal = tekka-is-petrol-journal(buf_temp-tekka-tsk.obj-num)
      .
      assign
      v-is-closed-journal = tekka-is-closed-shift-journal(buf_temp-tekka-tsk.obj-num)
      .
      assign
      v-date-p =  date( integer(entry(2, entry(4, buf_temp-tekka-tsk.other-info, {&space-char}), '-':U))
                    ,integer(entry(3, entry(4, buf_temp-tekka-tsk.other-info, {&space-char}), '-':U))
                    ,integer(entry(1, entry(4, buf_temp-tekka-tsk.other-info, {&space-char}), '-':U))
                    )
      v-z-count-p = integer(entry(5, buf_temp-tekka-tsk.other-info, {&space-char} ))
      v-z-count-p = (if v-z-count-p = ? then 0 else v-z-count-p)
      v-num-recs-p = integer(entry(6, buf_temp-tekka-tsk.other-info, {&space-char} ))
      v-num-recs-p = (if v-num-recs-p = ? then 0 else v-num-recs-p)
      .
    end.
    assign
    v-date =  date( integer(entry(2, entry(1, buf_temp-tekka-tsk.other-info, {&space-char}), '-':U))
                  ,integer(entry(3, entry(1, buf_temp-tekka-tsk.other-info, {&space-char}), '-':U))
                  ,integer(entry(1, entry(1, buf_temp-tekka-tsk.other-info, {&space-char}), '-':U))
                  )
    v-z-count = integer(entry(2, buf_temp-tekka-tsk.other-info, {&space-char} ))
    v-z-count = (if v-z-count = ? then 0 else v-z-count)
    v-num-recs = decimal(entry(3, buf_temp-tekka-tsk.other-info, {&space-char} ))
    v-num-recs = (if v-num-recs = ? then 0 else v-num-recs)
    no-error .
    if error-status:error then return .
    if p-petrol-exist then do:
      assign
      v-page-len-p = {&petrol-page-len}
      v-jour-no-p = truncate (v-num-recs-p / {&petrol-page-len}, 0)
      v-line-num-p = v-num-recs-p MODULO {&petrol-page-len}
      v-field-z-count-p = {&petrol-z-count-field}
      v-field-date-p  =  {&petrol-date-field}
      .
    end.
    assign
    v-page-len = {&goods-page-len}
    v-jour-no = truncate (v-num-recs / {&goods-doc-page-len}, 0)
    v-line-num = v-num-recs MODULO {&goods-doc-page-len}
    v-field-z-count = {&goods-doc-z-count-field}
    v-field-date  = {&goods-doc-date-field}
    .
    do ii = 1 to  (IF p-PETROL-exist THEN 2 ELSE 1):
      find first buf_tt-shift-info where
                buf_tt-shift-info.info-from = 'IBS'
            and buf_tt-shift-info.is-petrol = (if ii = 1 and p-petrol-exist then yes else no)
            and buf_tt-shift-info.chk-date = (if ii = 1 and p-petrol-exist then v-date-p else v-date)
            and buf_tt-shift-info.z-count = (if ii = 1 and p-petrol-exist then v-z-count-p else v-z-count)  no-error.
      if not available buf_tt-shift-info then do:
        create buf_tt-shift-info.
        assign
        buf_tt-shift-info.info-from = 'IBS'
        buf_tt-shift-info.is-petrol = (if ii = 1 and p-petrol-exist then yes else no)
        buf_tt-shift-info.chk-date = (if buf_tt-shift-info.is-petrol
                                      then v-date-p
                                      else v-date)
        buf_tt-shift-info.num-recs = (if buf_tt-shift-info.is-petrol
                                      then v-num-recs-p
                                      else v-num-recs)
        buf_tt-shift-info.z-count = (if buf_tt-shift-info.is-petrol
                                     then v-z-count-p
                                     else v-z-count)
        buf_tt-shift-info.jour-no = (if buf_tt-shift-info.is-petrol
                                     then v-jour-no-p
                                     else v-jour-no)
        buf_tt-shift-info.rec-no = (if buf_tt-shift-info.is-petrol
                                    then v-line-num-p
                                    else v-line-num)
        buf_tt-shift-info.order = ii
        buf_tt-shift-info.is-current = ?
        buf_tt-shift-info.is-close = ?
        .
      end.
    end.
    v-dopi = ch#TekkaApplication:StartGetObj(string(0)
                                    ,buf_temp-tekka-tsk.cash-num-char /*"5712000000"*/
                                    ,buf_temp-tekka-tsk.port-num /*"COM1"*/
                                    ,buf_temp-tekka-tsk.way /* "local" или "ftp" или "номер телефона"*/
                                    ,buf_temp-tekka-tsk.pswd /* "00000000"*/ ).
    run waiting in this-procedure ( input buf_temp-tekka-tsk.obj-name, input buf_temp-tekka-tsk.waiting-sek) no-error.
    if error-status:error then do:
      run write-err in this-procedure ( input error-status:get-message(1) ) .
      quit.
    end.
    if return-value <> '':u then do:
      run write-err in this-procedure ( input return-value  ) .
      quit.
    end.
    vvv = ch#TekkaApplication:GetInfo().

    v-error = ch#TekkaApplication:GetError().
    if v-error <> {&tekka-no-error-char} then do:
      run write-err in this-procedure ( input v-error).
      quit.
    end.

    assign
    v-prev-cd-z-count = integer(entry(1, vvv, {&space-char} ))
    v-prev-cd-z-close = (integer(entry(3, vvv, {&space-char} )) = 1)
    v-cd-z-count = integer(entry(2, vvv, {&space-char} ))
    v-cd-z-close = (integer(entry(4, vvv, {&space-char} )) = 1)
    no-error .
    if error-status:error then do:
      run write-err in this-procedure ( input substitute("Получены неверные данные о состоянии смен на кассе &1", buf_temp-tekka-tsk.cash-num)).
      quit.
    end.
    assign
    v-prev-cd-z-count-orig = v-prev-cd-z-count
    v-prev-cd-z-count = (if v-prev-cd-z-count = 0 then 100 else v-prev-cd-z-count)
    v-cd-z-count-orig = v-cd-z-count
    v-cd-z-count  = (if v-cd-z-count = 0 then 100 else v-cd-z-count)
    .
    assign
    v-closed-shift-num =  v-prev-cd-z-count
    .
    do ii = 1 to (if p-petrol-exist then 2 else 1):
      if v-prev-cd-z-count-orig > 0 then do:
        find first bufm_tt-shift-info where
                  bufm_tt-shift-info.info-from = 'maria'
              and bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
              and bufm_tt-shift-info.is-current = no no-error.
        if available bufm_tt-shift-info then do:
          if bufm_tt-shift-info.z-count = v-prev-cd-z-count then do:
          end.
          else do:
            assign
            bufm_tt-shift-info.is-close = yes.
            create bufm_tt-shift-info.
            assign
            bufm_tt-shift-info.info-from = 'MARIA'
            bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
            bufm_tt-shift-info.is-current = no
            bufm_tt-shift-info.z-count = v-prev-cd-z-count
            bufm_tt-shift-info.is-close = yes
            bufm_tt-shift-info.was-open = yes
            .
          end.
        end. /*if available bufm_tt-shift-info*/
        else do:
            create bufm_tt-shift-info.
            assign
            bufm_tt-shift-info.info-from = 'MARIA'
            bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
            bufm_tt-shift-info.is-current = no
            bufm_tt-shift-info.z-count = v-prev-cd-z-count
            bufm_tt-shift-info.is-close = yes
            bufm_tt-shift-info.was-open = yes
            .
        end.
      end. /*if v-prev-cd-z-count-orig > 0 then do:*/
      if v-cd-z-count-orig > 0 then do:
        find first bufm_tt-shift-info where
                  bufm_tt-shift-info.info-from = 'maria'
              and bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
              and bufm_tt-shift-info.is-current = yes no-error.
        if available bufm_tt-shift-info then  do:
          assign
          bufm_tt-shift-info.was-open = (not v-cd-z-close)
          .
          if bufm_tt-shift-info.z-count <> v-cd-z-count then do:
            assign
            bufm_tt-shift-info.is-close = yes
            bufm_tt-shift-info.was-open = yes
            .
            create bufm_tt-shift-info.
            assign
            bufm_tt-shift-info.info-from = 'MARIA'
            bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
            bufm_tt-shift-info.is-current = yes
            bufm_tt-shift-info.z-count = v-cd-z-count
            bufm_tt-shift-info.was-open = (not v-cd-z-close)
            .
          end.
        end.
        else do:
          create bufm_tt-shift-info.
          assign
          bufm_tt-shift-info.info-from = 'MARIA'
          bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
          bufm_tt-shift-info.is-current = yes
          bufm_tt-shift-info.z-count = v-cd-z-count
          bufm_tt-shift-info.was-open = (not v-cd-z-close)
          .
        end.
      end. /*if v-cd-z-count-orig > 0 then do:*/
    end.
    for each buf_tt-shift-info where
              buf_tt-shift-info.info-from = 'IBS'
          and buf_tt-shift-info.is-petrol = v-is-petrol-journal
    by buf_tt-shift-info.order:
      v-get-closed-shift-info = no.
      for each bufm_tt-shift-info where
            bufm_tt-shift-info.info-from = 'maria'
        and bufm_tt-shift-info.is-petrol = v-is-petrol-journal
        and bufm_tt-shift-info.z-count = buf_tt-shift-info.z-count
      by bufm_tt-shift-info.order:
        if bufm_tt-shift-info.is-close
        and bufm_tt-shift-info.z-count = v-closed-shift-num
        then do:
          if bufm_tt-shift-info.shift-open-date-chr = "" then do:
            v-get-closed-shift-info = yes.
            run get-closed-shift-info in this-procedure ( buffer buf_temp-tekka-tsk
                                                        , buffer bufm_tt-shift-info
                                                        , output v-closed-shift-info
                                                        , output v-date-time-info
                                                        , output v-num-recs-info
                                                        ) no-error .
          end.
          else do:
            v-get-closed-shift-info = yes.
            assign
            v-closed-shift-info = bufm_tt-shift-info.shift-open-date-chr + {&delim-par} +
                                  bufm_tt-shift-info.shift-open-time-chr + {&delim-par} +
                                  bufm_tt-shift-info.shift-close-date-chr + {&delim-par} +
                                  bufm_tt-shift-info.shift-close-time-chr
            v-date-time-info    =  bufm_tt-shift-info.tekka-date-chr + {&delim-par} +
                                   bufm_tt-shift-info.tekka-time-chr
            .
          end.
          assign
          v-return-value = v-return-value + {&comma-char} +
                          substitute("close-shift=&1", bufm_tt-shift-info.z-count).
          assign
          buf_tt-shift-info.is-current = no
          buf_tt-shift-info.is-close = yes
          .
        end. /*if bufm_tt-shift-info.is-close*/

        if bufm_tt-shift-info.is-current
        and bufm_tt-shift-info.z-count = v-cd-z-count then do:
          assign
          buf_tt-shift-info.is-current = yes
          buf_tt-shift-info.is-close = no
          .
          if v-is-closed-journal > 0
          then do:
            assign
            v-return-value = v-return-value + {&comma-char} + 'next-object=' +
                            string(tekka-get-next-obj-num ( input buf_temp-tekka-tsk.obj-num, input v-petrol-exist)).
            /*зачем нам старые чеки? мы уже в новой смене читали*/
            return v-return-value.
          end.
        end.
      end.
      if not v-get-closed-shift-info then do:
        run get-closed-shift-info in this-procedure ( buffer buf_temp-tekka-tsk
                                                    , buffer bufm_tt-shift-info
                                                    , output v-closed-shift-info
                                                    , output v-date-time-info
                                                    , output v-num-recs-info
                                                    ) no-error .
        assign
        v-return-value = v-return-value + {&comma-char} +
                        substitute("close-shift=&1", v-prev-cd-z-count).
      end.
      if buf_tt-shift-info.is-close = (v-is-closed-journal > 0) then do:
        /*если в атрибуте лежит та смена которая читается */
        assign
        v-num-recs = (if buf_tt-shift-info.num-recs = 0.0 then 0.0 else (buf_tt-shift-info.num-recs + 1.0001))
        v-obj-num = buf_temp-tekka-tsk.obj-num.
        assign
        v-to-read-obj-num =  tekka-get-obj-num ( input v-num-recs
                                                ,input v-is-petrol-journal
                                                ,input (v-is-closed-journal = 0)
                                                ,output v-to-read-num-recs).
        if buf_temp-tekka-tsk.obj-num <> v-to-read-obj-num then do:
          assign
          v-return-value = v-return-value + {&comma-char} + "next".
        end.
        assign
        v-return-value = v-return-value + {&comma-char} + substitute("min-plu=&1", v-to-read-num-recs).
        return v-return-value.
      end.
    end. /* for each buf_tt-shift-inof*/
    /*определяем страницу и запись для чтения дальше*/
    return v-return-value .
  end. /*doe*/
END PROCEDURE.

procedure get-closed-shift-info  :
define parameter buffer buf_temp-tekka-tsk for temp-tekka-tsk.
define parameter buffer bufm_tt-shift-info  for tt-shift-info.
define output parameter p-closed-shift-info as character no-undo .
define output parameter p-date-time-info as character no-undo .
define output parameter p-num-recs-info as character no-undo .

define variable v-dopi as character no-undo .
define variable jj as integer no-undo .
define variable kk as integer no-undo .
define variable v-field-value as character no-undo .

  do
  on error undo, return error return-value
  :
    v-dopi = ch#TekkaApplication:StartGetObj (
                                     string({&closed-shift-info})
                                    ,buf_temp-tekka-tsk.cash-num-char /*"5712000000"*/
                                    ,buf_temp-tekka-tsk.port-num /*"COM1"*/
                                    ,buf_temp-tekka-tsk.way /* "local" или "ftp" или "номер телефона"*/
                                    ,buf_temp-tekka-tsk.pswd /* "00000000"*/ ).
    run waiting in this-procedure ( input buf_temp-tekka-tsk.obj-name, input buf_temp-tekka-tsk.waiting-sek) no-error.
    if error-status:error then do:
      run write-err in this-procedure ( input error-status:get-message(1) ) .
      quit.
    end.
    if return-value <> '':u then do:
      run write-err in this-procedure ( input return-value  ) .
      quit.
    end.
    if not available bufm_tt-shift-info then do:
      do jj =  {&closed-shift-first-field}  to ({&closed-shift-first-field} + {&closed-shift-fields-num}  - 1):
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-closed-shift-info = p-closed-shift-info + (if jj = {&closed-shift-first-field}
                                                    then '':U
                                                    else {&delim-par} ) + v-field-value
        .
      end. /*do jj*/
      do jj =  {&tekka-date-field}  to {&tekka-time-field}:
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-date-time-info = p-date-time-info + (if jj = {&tekka-date-field}
                                                    then '':U
                                                    else {&delim-par} ) + v-field-value
        .
      end. /*do jj*/
      do jj =  {&tekka-num-recs-first-field}  to ({&tekka-num-recs-first-field} + {&tekka-num-recs-fields-num} - 1):
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-num-recs-info = p-num-recs-info + (if jj = {&tekka-num-recs-first-field}
                                                    then '':U
                                                    else {&delim-par} ) + v-field-value
        .
      end. /*do jj*/
    end.
    else do:
      kk = buffer bufm_tt-shift-info:buffer-field("shift-open-date-chr"):position.
      do jj =  {&closed-shift-first-field}  to  ({&closed-shift-first-field} +  {&closed-shift-fields-num} - 1):
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-closed-shift-info = p-closed-shift-info + (if jj = {&closed-shift-first-field}
                                                    then '':U
                                                    else {&delim-par} ) + v-field-value
        buffer bufm_tt-shift-info:buffer-field(kk + jj - {&closed-shift-first-field} - 1):buffer-value = v-field-value
        .
      end. /*do jj*/
      kk = buffer bufm_tt-shift-info:buffer-field("tekka-date-chr"):position.
      do jj =  {&tekka-date-field}  to {&tekka-time-field}:
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-date-time-info = p-date-time-info + (if jj = {&tekka-date-field}
                                                    then '':U
                                                    else {&delim-par} ) + v-field-value
        buffer bufm_tt-shift-info:buffer-field(kk + jj - {&tekka-date-field} - 1):buffer-value = v-field-value
        .
      end. /*do jj*/
      kk = buffer bufm_tt-shift-info:buffer-field("num-recs-petrol"):position.
      do jj =  {&tekka-num-recs-first-field}  to ({&tekka-num-recs-first-field} + {&tekka-num-recs-num-fields} - 1):
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-num-recs-info = p-num-recs-info + (if jj = {&tekka-num-recs-first-field}
                                                    then '':U
                                                    else {&delim-par} ) + v-field-value
        buffer bufm_tt-shift-info:buffer-field(kk + jj - {&tekka-num-recs-first-field} - 1):buffer-value = v-field-value
        .
      end. /*do jj*/
   end.
  end.

end procedure. /* get-closed-shift-info  */