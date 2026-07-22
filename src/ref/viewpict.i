/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр, заведение картинки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/10/05
Author: Bakhtadze Natalya
Creation date: 06/10/05

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable stat                 as character no-undo .
define variable Path-To-Dir-Pictures as character no-undo .
define variable Path-To-Pictures     as character no-undo .

define variable v-ii                 as integer no-undo .
define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

/*строка форматов image файлов в каком порядке искать файлы*/
{ gbl/img-frm.i }



do:
  RUN verify-ini-entry("pict_path":U,
                        "REP-SETS":U,
                        "не определен путь к подкаталогу для хранения фото товара" + {&new-line} +
                        "отсутствует параметр pict_path, секция [REP-SETS] ini-файла",
                        no,
                        output Path-To-Dir-Pictures) no-error.
  if error-status:error or Path-To-Dir-Pictures = ? then return error.

  RUN verify-file(Path-To-Dir-Pictures,
                  "Не найден каталог " + Path-To-Dir-Pictures + {&new-line} +
                  "параметр pict_path, секция [REP-SETS] ini-файла",
                  no,
                  output loc#log) no-error.
  if error-status:error or not loc#log then return error.

  RUN verify-file((Path-To-Dir-Pictures + "{1}"),
                  "Не найден подкаталог " + Path-To-Dir-Pictures + "{1}",
                  no,
                  output loc#log) no-error.
  if error-status:error or not loc#log then return error.

  run adm/shattri.p (
      input "get":U
      ,input  ''
      ,input  0
      ,input  {&attr-images}
      ,input  {&attr-images_imgorder} /*p-param-code*/
      ,output v-image-order
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .

  delete object v-tth.
  if error-status:error
  or v-image-order = '':U then
  v-image-order = "jpg,bmp".

   assign
   Path-To-Pictures = Path-To-Dir-Pictures + "{1}" + string( {2} )
   .

  if length( Path-To-Pictures ) > 56 then do:
    message
      "Слишком длинное имя файла ( с учетом полного пути )."
      view-as alert-box error .
  end.

  do v-ii = 1 to num-entries(v-image-order):
    assign
      stat = search( Path-To-Pictures  + "." + entry(v-ii, v-image-order) )
    .
    if stat <> ? then leave.
  end.
  /*path-to-pictures - это без расширения и точки!!!*/
  if stat <> ? then do:
    run ref/view-pic.w ( Path-To-Pictures, entry(v-ii, v-image-order), if {3} then "b-update" else "":U ) .
  end.
  else do:
    if not {3} then do:
      message
      "Изображение отсутствует"
      view-as alert-box .
      RETURN.
    end.
    run ref/photo-n.w ( Path-To-Pictures, {&add-def}  ) .
  end.

end.