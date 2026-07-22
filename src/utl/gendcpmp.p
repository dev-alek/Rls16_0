block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gendcpmp.p $
$Archive: utl/gendcpmp.p $

Автоматичекая генерация пропроцессингов dis-card-property

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/31/07
Author: Bakhtadze Natalya
Creation date: 07/31/07

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gendcpmp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gendcpmp.p $":U .
define variable vss-description as character no-undo init "Автоматичекая генерация пропроцессингов dis-card-property".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable gen-dir         as character no-undo .
define variable v-work-dir      as character no-undo .
define stream OutStream.
define stream errstream .

&glob std-vss-header-nvb {&start-comment} + {&new-line} + {&new-line} + {&dollar} + 'Revision: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Author: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Date: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Workfile: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Archive: ':U + {&dollar} ~
+ {&new-line} + {&new-line} + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) ~
+ {&new-line} ~
+ {&new-line} + "Автор: Бахтадзе Наталья Викторовна":U ~
+ {&new-line} + "Дата создания: 07/31/07":U ~
+ {&new-line} + "Author: Bakhtadze Natalya":U ~
+ {&new-line} + "Creation date: 07/31/07":U ~
+ {&new-line} + {&new-line} ~
+ {&end-comment} + {&new-line}

&glob std-vss-info ~
"~&scoped-define vssseq ~~~{&sequence~}" +  ~{&new-line} + ~
'define variable vss-include-info~~~{&vssseq~} as character format "x(65)" no-undo initial ' + ~
{&double-quote} + '@(#)' + {&dollar} + 'Workfile:  ' + {&dollar} + {&space-char} + {&dollar} + 'Revision:  ' + {&dollar} + {&double-quote} + '.':U

&glob std-vss-bottom  {&start-comment} + {&space-char} + {&dollar} + 'Workfile: dc-prop.i' + {&space-char} + {&dollar} +  {&space-char} + 'e n d ':U + {&end-comment}

&glob dc-prop "ref/dc-prop.i"

do
on error undo, return error
:
  assign
    file-info :file-name = ".":U
  .
  if file-info :full-pathname = ""
  or file-info :full-pathname = ?  then do:
    message
      "Рабочий каталог не найден"
      view-as alert-box error .
    undo, return error .
  end.
  assign
    v-work-dir = file-info :full-pathname + {&back-slash-char}
  .

  run gbl/d-prompt.w (
      'title=':u + "Введите имя директории" + '\':u
    + 'text1=':u + "Введите имя директории" + '\':u
    + 'text2=':u + "где будет создан файл с препроцессингами dis-card-property (dc-prop.i)" + '\':u
    + 'format=x(256)\':u
    + 'type=char\':u
    ,input-output gen-dir
    ).
  if return-value = 'false':u then do:
    return .
  end.

  if gen-dir = "" then do:
    assign
      gen-dir = v-work-dir
    .
  end.
  else do:
    assign
      file-info :file-name = gen-dir
    .
    if file-info :full-pathname = ""
    or file-info :full-pathname = ?  then do:
      message
        "Указаный каталог не найден" skip
        gen-dir
        view-as alert-box error .
      undo, return error .
    end.
    assign
      gen-dir = file-info :full-pathname + {&back-slash-char}
    .
  end.
  run gen-file in this-procedure ( input gen-dir).
end.


procedure gen-file :
define input parameter gen-dir as character no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-map for ub.prop-map.
do
on error undo, return error
:
  OUTPUT STREAM OutStream TO value( gen-dir + {&dc-prop} ) .
  put stream Outstream unformatted
  {&std-vss-header-nvb}
  .
  put stream Outstream unformatted
  {&new-line}
  {&std-vss-info}
  skip(1).
  for each buf_prop-head no-lock
  by buf_prop-head.dtm-code:
    if buf_prop-head.storage-place = {&table_dis-card-property}
    or buf_prop-head.storage-place-host = {&table_dis-card-property}
    or buf_prop-head.storage-place-obj = {&table_dis-card-property} then do:
      put stream Outstream unformatted
        substitute("/*&1*/", buf_prop-head.prop-label)
        skip
        substitute("~&&global-define dc-prop_&1 &2"
                   ,buf_prop-head.prop-name
                   ,buf_prop-head.dtm-code
                   )
      skip.
      for each buf_prop-map no-lock where
              buf_prop-map.dtm-code = buf_prop-head.dtm-code:
        put stream Outstream unformatted
          substitute("/*&1*/", buf_prop-map.node-label)
          skip
          substitute("~&&global-define dc_prop_&1_&2 &3"
                    ,buf_prop-head.prop-name
                    ,buf_prop-map.node-name
                    ,buf_prop-map.node-code
                    )
        skip.
      end.
      put stream Outstream unformatted skip(1).
    end.
  end.
  put stream Outstream unformatted
  skip(1)
  {&std-vss-bottom}
  skip.
  output stream Outstream close.
end.

end procedure. /* gen-file */