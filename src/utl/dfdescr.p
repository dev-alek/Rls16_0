block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dfdescr.p $
$Archive: utl/dfdescr.p $

Создания файла для описания перевода полей БД

Автор: Перваков Михаил Сергеевич
Дата создания: 02/16/01
Author: Mikhail Pervakov
Creation date: 02/16/01

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dfdescr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/dfdescr.p $":U .
define variable vss-description as character no-undo init "Создания файла для описания перевода полей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define variable v-new-format as character no-undo .
define variable l-ok  as logical no-undo .

define variable v-total-field as integer no-undo .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

message
  "Вы хотите сгенерировать файл для перевода описаний полей БД" skip
  view-as alert-box question buttons yes-no update l-ok .
if l-ok <> true then do:
  return . /* --->>>--- */
end.

define variable v-file-name as character no-undo init "dfdescr.df" .

output to value(v-file-name) .
run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
put unformatted
  '# Файл для перевода описаний полей' + {&new-line}
  '# Данный файл сгенерирован автоматически при помощи программы ' + vss-workfile + {&new-line}
  '# Дата  ' + string(v-today, "99/99/9999") + {&new-line}
  '# Время ' + string(v-time, "hh:mm") + {&new-line}
  '# Необходимо в описании поля после русского описания' +
  '# привести английский и румынский переводы, отделенные символом ` ' + {&new-line}
  '# Причем надо менять тот DESCRIPTION у которого слева отсутствует знак комментария #           ' + {&new-line}
  '# Пример:' + {&new-line}
  '# DESCRIPTION "Главный бухгалтер`Cheif accountant`Contabil sef     " ' + {&new-line}
  + {&new-line}
.
output close .

run waitfram-show in this-procedure
  (input "Анализ структуры БД"
  ).

define variable v-total as integer no-undo .
define variable v-descrip as integer no-undo .

define variable v-first-descr  as character no-undo .
define variable v-second-descr as character no-undo .
define variable v-third-descr  as character no-undo .

for each _File no-lock
  where _File._Hidden = false
:

  run waitfram-show in this-procedure
    (input "Анализ таблицы " + string(_File._File-Name, "x(40)") + "."
    ).

  field-block:
  for each _Field of _File no-lock
  :
    assign
      v-first-descr  = ''
      v-second-descr = ''
      v-third-descr  = ''
    .

    /* определяем русское описание */
    /* это либо первый элемент поля Description, либо из поля Label */
    assign
      v-first-descr = entry(1, _Field._Desc, '`':u)
    .
    if v-first-descr = ""
    or v-first-descr = ? then do:
      assign
        v-first-descr = _Field._Label
      .
    end.
    if v-first-descr = ? then do:
      assign
        v-first-descr = ""
      .
    end.

    /* английское описание */
    /* это всегда второй элемент поля Description */
    if num-entries(_Field._Desc, '`':u) >= 2 then do:
      assign
        v-second-descr = entry(2, _Field._Desc, '`':u)
      .
    end.

    /* английское описание */
    /* это всегда третий элемент поля Description */
    if num-entries(_Field._Desc, '`':u) >= 3 then do:
      assign
        v-third-descr = entry(3, _Field._Desc, '`':u)
      .
    end.

    /* у поля есть русское описание */
    /* но отсутствуют описания на иностранном языке */
    if  v-first-descr <> ""
    and (v-second-descr = ""
        or v-third-descr = ""
        )
    then do:

      assign
        v-total-field = v-total-field + 1
      .

      define variable ind as integer no-undo .

      output to value(v-file-name) append .
      put unformatted
        'UPDATE FIELD "' + _Field._Field-Name + '" OF "' + _File._File-Name + '"' + {&new-line}
        + SUBSTITUTE('# FORMAT "&1"'      , _Field._Format    ) + {&new-line}
        + SUBSTITUTE('# LABEL "&1"'       , _Field._Label     ) + {&new-line}
        + SUBSTITUTE('# COLUMN-LABEL "&1"', _Field._Col-Label ) + {&new-line}
        + SUBSTITUTE('# DESCRIPTION "&1"' , substring(replace(_Field._Desc, {&new-line}, {&space-char}), 1, 100) ) + {&new-line}
        + '  DESCRIPTION '
        .
      export
         _Field._Desc
        .
      put unformatted
        {&new-line}
      .
      output close .
    end.
  end.
end.

run waitfram-hide in this-procedure .

output to value(v-file-name) append .
put unformatted
  '# Всего полей для перевода ' + string(v-total-field) + {&new-line}
  + {&new-line}
.
output close .

message
  "Проверка описания полей закончена" skip
  "Необходимо перевести" v-total-field "описаний" skip
  "Отправьте файл" v-file-name "на перевод" skip
  view-as alert-box information .