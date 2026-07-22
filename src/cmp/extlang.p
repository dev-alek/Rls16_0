block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: extlang.p $
$Archive: cmp/extlang.p $

Возвращает дополнительные языки языковой базы данных

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/

do
on error undo, return error return-value
:
  define output parameter parlang as character no-undo .

  for each xl_language no-lock
  on error undo, return error
  :
    assign
      parlang = parlang
              + min(parlang, ",")
              + xl_language.lang_name
    .
  end.

end.