block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gendcpmp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gendcpmp.p $":U .
define variable vss-description as character no-undo init "Автоматичекая генерация пропроцессингов dis-card-property".
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
define variable gen-dir         as character no-undo .
define variable v-work-dir      as character no-undo .
define stream OutStream.
define stream errstream .
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
    v-work-dir = file-info :full-pathname + chr(92)
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
      gen-dir = file-info :full-pathname + chr(92)
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
  OUTPUT STREAM OutStream TO value( gen-dir + "ref/dc-prop.i" ) .
  put stream Outstream unformatted
  chr(47) + chr(42) + chr(10) + chr(10) + chr(36) + 'Revision: ':U + chr(36) + chr(10) + chr(36) + 'Author: ':U + chr(36) + chr(10) + chr(36) + 'Date: ':U + chr(36) + chr(10) + chr(36) + 'Workfile: ':U + chr(36) + chr(10) + chr(36) + 'Archive: ':U + chr(36) + chr(10) + chr(10) + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) + chr(10) + chr(10) + "Автор: Бахтадзе Наталья Викторовна":U + chr(10) + "Дата создания: 07/31/07":U + chr(10) + "Author: Bakhtadze Natalya":U + chr(10) + "Creation date: 07/31/07":U + chr(10) + chr(10) + chr(42) + chr(47) + chr(10)
  .
  put stream Outstream unformatted
  chr(10)
  "&scoped-define vssseq ~{&sequence}" +  chr(10) + 'define variable vss-include-info~{&vssseq} as character format "x(65)" no-undo initial ' + chr(34) + '@(#)' + chr(36) + 'Workfile:  ' + chr(36) + chr(32) + chr(36) + 'Revision:  ' + chr(36) + chr(34) + '.':U
  skip(1).
  for each buf_prop-head no-lock
  by buf_prop-head.dtm-code:
    if buf_prop-head.storage-place = 'dis-card-property':U
    or buf_prop-head.storage-place-host = 'dis-card-property':U
    or buf_prop-head.storage-place-obj = 'dis-card-property':U then do:
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
  chr(47) + chr(42) + chr(32) + chr(36) + 'Workfile: dc-prop.i' + chr(32) + chr(36) +  chr(32) + 'e n d ':U + chr(42) + chr(47)
  skip.
  output stream Outstream close.
end.
end procedure.
