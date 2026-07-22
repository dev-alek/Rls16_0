block-level on error undo, throw.
define input-output parameter p-rec                 as recid     no-undo.
define input parameter        p-mode                as character no-undo .
define input parameter        p-silent              as logical   no-undo .
define input parameter        p-curr-code           like ub.currency.curr-code            no-undo .
define input parameter        p-curr-abbr           like ub.currency.curr-abbr            no-undo .
define input parameter        p-part-abbr           like ub.currency.part-abbr            no-undo .
define input parameter        p-curr-name           like ub.currency.curr-name            no-undo .
define input parameter        p-curr-name-one       like ub.currency.curr-name-one        no-undo .
define input parameter        p-curr-name-three     like ub.currency.curr-name-three      no-undo .
define input parameter        p-curr-name-five      like ub.currency.curr-name-five       no-undo .
define input parameter        p-curr-eng-name       like ub.currency.curr-eng-name        no-undo .
define input parameter        p-curr-eng-name-one   like ub.currency.curr-eng-name-one    no-undo .
define input parameter        p-curr-eng-name-three like ub.currency.curr-eng-name-three  no-undo .
define input parameter        p-curr-eng-name-five  like ub.currency.curr-eng-name-five   no-undo .
define input parameter        p-part-name           like ub.currency.part-name            no-undo .
define input parameter        p-part-name-one       like ub.currency.part-name-one        no-undo .
define input parameter        p-part-name-three     like ub.currency.part-name-three      no-undo .
define input parameter        p-part-name-five      like ub.currency.part-name-five       no-undo .
define input parameter        p-okv-code            like ub.currency.okv-code             no-undo .
define input parameter        p-okv-code-chr        as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 7872d7f298c6, 1094, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: currenc1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/currenc1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке валюты".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable dopi              as integer   no-undo.
define variable v-param-type      as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-tth             as handle    no-undo .
define variable v-mess            as character no-undo .
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.
define buffer buf_currency for ub.currency.
define buffer buf_shop for ub.shop.
define temp-table ibmrubc no-undo
  field code as integer
  index pi is unique primary code
  .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode <> 'ДОБАВЛЕНИЕ':U
  and p-mode <> 'ИЗМЕНЕНИЕ':U
  then do:
    assign
      v-mess = substitute( "&1 (&2). Ошибка задания входных параметров. Неверный параметр p-mode (&3).", vss-workfile, vss-revision, p-mode )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
   run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
  if v-value = "no"  then do:
  if v-db-num <> 0
  then do:
    assign
      v-mess = substitute( "Нельзя изменять запись ВАЛЮТЫ в УБД: Номер текущей БД &1.", v-db-num )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
  end.
  for each ibmrubc :
    delete ibmrubc.
  end.
  for each buf_shop no-lock
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  buf_shop.obj-code
        ,input  'cd-type-ibm':U
        ,input  'ibmrubc':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      delete object v-tth.
      assign
        v-mess = substitute("&1 (&2). Ошибка при получении настроек кассы &6 по умолчанию НА ОБЪЕКТЕ &3&4:&5&6 &7"
                            , vss-workfile
                            , vss-revision
                            , 'маг':U
                            , buf_shop.obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
                            , 'IBM':U
                            )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
    delete object v-tth.
    FIND FIRST ibmrubc where
                ibmrubc.code = v-value-integer NO-ERROR.
    IF not avail ibmrubc then do:
      create ibmrubc.
      assign
      ibmrubc.code = v-value-integer.
    end.
    run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  buf_shop.obj-code
        ,input  'cd-type-IBM-XML':U
        ,input  'ibmrubc':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      delete object v-tth.
      assign
        v-mess = substitute("&1 (&2).Ошибка при получении настроек кассы &8 по умолчанию НА ОБЪЕКТЕ &3&4:&5&6 &7"
                            , vss-workfile
                            , vss-revision
                            , 'маг':U
                            , buf_shop.obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
                            , 'IBM-XML':U
                            )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
    delete object v-tth.
    FIND FIRST ibmrubc where
                ibmrubc.code = v-value-integer NO-ERROR.
    IF not avail ibmrubc then do:
      create ibmrubc.
      assign
      ibmrubc.code = v-value-integer.
    end.
  end.
  if p-mode =  'ДОБАВЛЕНИЕ':U then do:
    if can-find(first ibmrubc where p-curr-code = ibmrubc.code) then do:
      assign
        v-mess = substitute("Код валюты не может быть равен &1", p-curr-code )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "curr-code":U ).
    end.
    if can-find( first buf_currency where buf_currency.curr-code = p-curr-code ) then do:
      assign
        v-mess = substitute("Уже есть валюта с кодом &1", p-curr-code )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "curr-code":U ).
    end.
    if can-find( first buf_currency where buf_currency.curr-abbr = p-curr-abbr ) then do:
      assign
        v-mess = substitute("Уже есть валюта с аббревиатурой &1", p-curr-abbr )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "curr-abbr":U ).
    end.
  end.
  if p-curr-abbr = "":U then do:
    assign
      v-mess = substitute("Не задана аббревиатура валюты (код &1)", p-curr-code )
      .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else "curr-abbr":U ).
  end.
  if p-curr-name = "":U then do:
    assign
      v-mess = substitute("Не задано название валюты (код &1)", p-curr-code )
      .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else "curr-name":U ).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create buf_currency.
    assign
    buf_currency.curr-code = p-curr-code
    buf_currency.curr-abbr = p-curr-abbr
    p-rec = recid(buf_currency)
    .
  end.
  else do:
    FIND FIRST buf_currency where
              recid(buf_currency) = p-rec No-ERROR.
    if not available buf_currency then do:
      assign
        v-mess = substitute("&1 (&2). Не найдена запись валюты p-rec = &3", vss-workfile, vss-revision, p-rec )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "":U ).
    end.
    if buf_currency.curr-abbr <> p-curr-abbr
    or buf_currency.curr-code <> p-curr-code
    then do:
      assign
        v-mess = substitute("Для уже имеющейся записи ВАЛЮТЫ нельзя изменить аббревиатуру и/или код валюты" )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "":U ).
    end.
  end.
  assign
  buf_currency.curr-name           = p-curr-name
  buf_currency.curr-abbr           = p-curr-abbr
  buf_currency.part-abbr           = p-part-abbr
  buf_currency.curr-name           = p-curr-name
  buf_currency.curr-name-one       = p-curr-name-one
  buf_currency.curr-name-three     = p-curr-name-three
  buf_currency.curr-name-five      = p-curr-name-five
  buf_currency.curr-eng-name       = p-curr-eng-name + chr(4) + p-okv-code-chr
  buf_currency.curr-eng-name-one   = p-curr-eng-name-one
  buf_currency.curr-eng-name-three = p-curr-eng-name-three
  buf_currency.curr-eng-name-five  = p-curr-eng-name-five
  buf_currency.part-name           = p-part-name
  buf_currency.part-name-one       = p-part-name-one
  buf_currency.part-name-three     = p-part-name-three
  buf_currency.part-name-five      = p-part-name-five
  buf_currency.okv-code            = p-okv-code
  .
  release buf_currency no-error.
  if error-status:error then do:
    assign
      v-mess = substitute("&1 (&2). Ошибка при сохранении записи ВАЛЮТЫ &3: &4: &5", vss-workfile, vss-revision, p-curr-code, error-status:get-message(1), return-value )
      .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else "":U ).
 end.
end.
return '':U .
procedure err-mess:
  define input-output parameter p-mess as character no-undo.
    case p-silent:
    when yes then do:
      assign
      p-mess = substitute("Сохранение изменений в карточке ВАЛЮТЫ&1"
                          + "Код валюты &2&1"
                          + "Аббревиатура валюты &3&1"
                          + "Название валюты &4&1"
                          + "&5"
                         , chr(10)
                         , p-curr-code
                         , p-curr-abbr
                         , p-curr-name
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
end procedure.
