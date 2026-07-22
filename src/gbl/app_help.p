block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: app_help.p $
$Archive: gbl/app_help.p $

Интерактивная помощь

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

Программа ищет файл в PROPATH с таким же именем, что и программа,
но с расширением .html, .htm

*/

define input parameter p-procedure as character no-undo .
define input parameter p-detail    as character no-undo .
define input parameter l-help-edit as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: app_help.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/app_help.p $":U .
define variable vss-description as character no-undo init "Интерактивная помощь".
{ cmp/vssrevis.i }

do
on error undo, return error return-value
:
  define variable s-file-name as character no-undo .
  define variable o-file-name as character no-undo .
  p-procedure = REPLACE ( p-procedure , "\" , "/" ) .
  assign

    s-file-name = entry ( num-entries( p-procedure,"/" ) , p-procedure,"/" )

  .

  /* выделяем имя файла без расширения */
  /* внимание - данный код не работает - если передается полные путь к */
  /* файлу, с директориями в имени которых присутствуют точки */
  if num-entries(  s-file-name, '.') > 0
  then do:
    assign
      s-file-name = entry(1, s-file-name, '.')
    .
  end.
  o-file-name  = s-file-name.
  s-file-name = "c:\help_15ver\" + s-file-name .

  if search(s-file-name + '.htm':u) > ''
  then do:
    run gbl/open_url.p
      (input search(s-file-name + '.htm':u)
      ).
  end.
  else do:
    if search(s-file-name + '.html':u) > ''
    then do:
      run gbl/open_url.p
        (input search(s-file-name + '.html':u)
        ).
    end.
    else do:
      if search('exe/help.chm':u) > '':u
      then do:

        define variable v-full-pathname as character no-undo .
        assign
          file-info :file-name = search('exe/help.chm':u)
        .
        assign
          v-full-pathname = file-info :full-pathname
        .

        run gbl/open_url.p
          (input substitute('mk:@MSITStore:&1::/&2.htm':u
                           ,v-full-pathname
                           ,o-file-name
                           )
          ).
      end.
      else do:
        message
          "В данный момент документация в формате *.htm отсутствует." skip
          "Обратитесь к документации, поставляемой вместе с системой." skip
          "" skip
          "" o-file-name + '.htm':u skip
             p-procedure skip
          view-as alert-box information.
      end.
    end.
  end.
end.