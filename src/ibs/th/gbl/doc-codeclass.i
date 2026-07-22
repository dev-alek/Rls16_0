/*

$Revision: f7f4e950f623, 0, rls $
$Author: expertek $
$Date: 2012/10/22 17:03:47 $
$Workfile: doc-code.i $
$Archive: str/doc-code.i $

Генерация номера для любой накладной или переоценки

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

Номер документа создается как
  уникальный номер внутри базы данных
  знак минус
Для удаленных баз данных
  номер объекта
  вторая буква типа объекта

Раньше использовалась первая буква - но для английской версии
первые буквы слов Shop и Store совпадают.

режим генерации номера: main - для исходного документа
  chip - для документа - щепки
  pair - для парнОго документа
  trio  - для тройного документа но parroot-doc-code - номер с =
  flora  - для документа получающего из запроса в накладную для флористов
  trio-m  -  для тройного документа но parroot-doc-code обычный номер с -
  quadro    для четвертого документа
  stock-up для иного документа увеличивающего склад
  stock-down для иного документа уменьшающего склад
  stock-fix для иного документа корректирующего склад
  chip,pair - для щепки парнОго документа
  flora  - для щепки документа получающего из запроса в накладную для флористов
  trio-m  для щепки тройного документа но parroot-doc-code обычный номер с -
  quadro - для щепки четвертого документа
  stock-up    для щепки иного документа увеличивающего склад
  stock-down  для щепки иного документа уменьшающего склад
  stock-fix  для щепки иного документа корректирующего склад


2 - номер целевого документа
3 - номер исходного документа (для всех режимов, кроме main)
4 - вспомогательная переменная (для режима chip)

!!!!ПРОГРАММИСТ!
Прежде чем удалить или изменить моды parmode проверь, что для них нет вызовов, и они не упомянуты в str-glbl.i!!!!!

После того, как ДОБАВИЛИСЬ новые моды надо (возможно) скорректировать rest-seq - в месте ,
в котором из номера документа вырезается integer

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: doc-code.i $ $Revision: f7f4e950f623, 0, rls $".

&scop modes              "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," + ~
                         "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U

/*Господа $ использовать нельзя*/
&scop modes-delimiters   ("-,-,=,#,*,^,+,`,":U + chr(126) + ",{&bef-gds-office}-,{&bef-gds-office}-,{&bef-gds-office}=,{&bef-gds-office}*,{&bef-gds-office}^,{&bef-gds-office}+,{&bef-gds-office}`,{&bef-gds-office}" + chr(126))

method public character docCode (parmode as character, parobj-type as character, parobj-code as integer, parroot-doc-code as character):
define variable pardoc-code as character no-undo .
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
&scop first-part trim (string (next-value (s-trn-doc, {&db-name_schema}), ">>>>>>>>>9")) + "-"
&scop first-part-s trim (string (next-value (s-trn-doc, {&db-name_schema}), ">>>>>>>>>9")) + "s-"
&scop second-part + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, 1, 1)


find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .

  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = {&first-part} {&second-part}.
      end.
      else do:
        assign
          pardoc-code = {&first-part}.
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), {&modes}), {&modes-delimiters})
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,{&new-line}
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        /* для генерации номера используем доп. переменную, чтобы не пересчитывался индекс */
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            /* начало номера включая - */
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            /* только порядковый номер "щепки" + 1 */
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            /* конец номера включая . */
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end. /*otherwise*/
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,{&new-line}).
  end.
  else return pardoc-code .

end method.


/* $Workfile: doc-code.i $ e n d */