block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getexini.p $
$Archive: gbl/getexini.p $

ќпределение имени выполн€емого файла и имени *.ini файла сессии

јвтор: ѕерваков ћихаил —ергеевич
ƒата создани€: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

define output parameter p-exefile as character no-undo .
define output parameter p-inifile as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getexini.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getexini.p $":U .
define variable vss-description as character no-undo init "ќпределение имени выполн€емого файла и имени *.ini файла сессии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-cmdln as character no-undo .

do
on error undo, return error return-value
:
  run gbl/getcmdln.p
    (output v-cmdln
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ќе удалось определить командную строку запуска  сессии"     /*пробелы не стирать!*/
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* делаем разбор командной строки */
  assign
    v-cmdln = left-trim(v-cmdln, {&space-char})
  .

  /* удаление повторных пробелов пробелов */
  /* дл€ того, чтобы можно было потом разобрать строку */
  /* использу€ оператор entry */
  do while index(v-cmdln, fill({&space-char}, 2)) > 0
  :
    assign
      v-cmdln = replace(v-cmdln, fill({&space-char}, 2), {&space-char})
    .
  end.

  /* определ€ем им€ выполн€емого файла */
  assign
    p-exefile = trim(entry(1, v-cmdln, {&space-char}), {&double-quote})
  .

  /* определ€ем им€ *.ini файла                                        */
  /* просматриваем командную строку от начала к концу                  */
  /* просматриваем всю командную строку целиком                        */
  /* с тем чтобы определить правильный *.ini файл,                     */
  /* если пользователь несколько раз указал ininame в командной строке */
  define variable v-ind as integer   no-undo .
  do v-ind = 2 to num-entries(v-cmdln, {&space-char})
  :
    if entry(v-ind, v-cmdln, {&space-char}) = '-ininame':U
    then do:
      if v-ind + 1 <= num-entries(v-cmdln, {&space-char}) then do:
        assign
          p-inifile = entry(v-ind + 1, v-cmdln, {&space-char})
        .
      end.
    end.
  end.

  if p-inifile = ""
  or p-inifile = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "ќшибка при разборе командной строки запуска системы" skip
      "¬ командной строке не задан параметр" '-ininame':u skip
      "ќбратитесь к администратору" skip
      " омандна€ строка" skip
      v-cmdln skip
      view-as alert-box error .
    undo, return error .
  end.
end.