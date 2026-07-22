block-level on error undo, throw.
define input  parameter parparentproc   as   handle               no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trncstcp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trncstcp.p $":U .
define variable vss-description as character no-undo init "Выбор документов и простановка кода ГТД ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define buffer buf_trn-doc for ub.trn-doc .
define variable v-update-ind as integer no-undo .
define variable v-skip-ind   as integer no-undo .
define variable lok as logical no-undo .
define variable loc-ref-list as character no-undo .
define variable v-doc-rec    as integer   no-undo .
do
on error undo, return error
:
  assign
    lok = false
  .
  message
    "Программа обновления ГТД в приходном документе на основании расходного документа" skip
    "Сначала необходимо выбрать приходный документ." skip
    "Затем расходный." skip
    "ВНИМАНИЕ! Информация о ГТД в других базах данных не будет изменена." skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update lok .
  if lok <> true then do:
    return .
  end.
  run str/all-docs.w
    (input parparentproc
    ,input v-cntxt-host-code-obj
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input 'ТИП':U
    ,input 'факт':U
    ,input 'при':U
    ,input ?
    ,input false
    ,input "b-sel":U
    ,input 'ie':U
    ,input no
    ,input ?
    ,output loc-ref-list
    ).
  assign
    v-doc-rec = integer(entry(1, loc-ref-list))
  .
  find trn-doc no-lock
    where recid (trn-doc) = v-doc-rec
    no-error .
  if not available trn-doc then do:
    return .
  end.
  run str/all-docs.w
    (input parparentproc
    ,input ?
    ,input ?
    ,input ?
    ,input 'работа':U
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input "b-sel":U
    ,input ?
    ,input no
    ,input ?
    ,output loc-ref-list
    ).
  assign
    v-doc-rec = integer(entry(1, loc-ref-list))
  .
  find buf_trn-doc no-lock
    where recid (buf_trn-doc) = v-doc-rec
    no-error .
  if not available buf_trn-doc then do:
    return .
  end.
  assign
    lok = false
  .
  message
    "Вы выбрали следующие документы" skip
    "Приходный" ub.trn-doc.doc-code skip
    "Расходный" buf_trn-doc.doc-code skip
    "Будем скопирована информация о ГТД" skip
    ub.trn-doc.doc-code "<---" buf_trn-doc.doc-code skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update lok .
  if lok <> true then do:
    return .
  end.
  run copy-doc-cst in this-procedure
    (input ub.trn-doc.doc-code
    ,input buf_trn-doc.doc-code
    ).
  message
    "Информация о ГТД скопирована" skip
    "Приходный документ" ub.trn-doc.doc-code skip
    "Обновлено партий" v-update-ind skip
    "Не обновлено партий" v-skip-ind skip
    view-as alert-box information .
end.
procedure copy-doc-cst :
  do
  on error undo, return error
  :
    define input parameter p-input-doc-code   like ub.trn-doc.doc-code no-undo .
    define input parameter p-expense-doc-code like ub.trn-doc.doc-code no-undo .
    define buffer buf_trn-doc     for ub.trn-doc .
    define buffer expense_trn-doc for ub.trn-doc .
    define buffer buf_parts       for ub.parts .
    define buffer expense_parts   for ub.parts .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-input-doc-code
      .
    find first expense_trn-doc no-lock
      where expense_trn-doc.doc-code = p-expense-doc-code
      .
    for each buf_parts exclusive-lock
      where buf_parts.out-code = p-input-doc-code
    on error undo, return error
    :
      find first expense_parts no-lock
        where expense_parts.out-code  = p-expense-doc-code
          and expense_parts.obj-type  = expense_trn-doc.obj-type
          and expense_parts.obj-code  = expense_trn-doc.obj-code
          and expense_parts.artic     = buf_parts.artic
          and expense_parts.prod-type = buf_parts.prod-type
          and expense_parts.prod-code = buf_parts.prod-code
          and expense_parts.part-code = buf_parts.part-code
          and expense_parts.cst-code  <> ""
        no-error .
      if available expense_parts then do:
        assign
          v-update-ind = v-update-ind + 1
        .
        run trg/partcst.p
          (input expense_parts.cst-code
          ,input buf_parts.in-code
          ,input buf_parts.artic
          ,input buf_parts.prod-type
          ,input buf_parts.prod-code
          ,input buf_parts.part-code
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры partcst.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          v-skip-ind = v-skip-ind + 1
        .
      end.
    end.
  end.
end procedure.
