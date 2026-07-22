block-level on error undo, throw.
DEFINE INPUT PARAMETER  v-doc-code  like ub.trn-doc.doc-code no-undo.
DEFINE OUTPUT PARAMETER i-err-count as   integer             no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trnfix.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trnfix.p $":U .
define variable vss-description as character no-undo init "Утилита проверки и коррекции документа".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-doc-pl no-undo
  field pl-code          like ub.doc-pl.pl-code
  field cli-qnty         like ub.doc-pl.cli-qnty
  field cli-doc-qnty     like ub.doc-pl.cli-doc-qnty
  field cli-fact-qnty    like ub.doc-pl.cli-fact-qnty
  field doc-qnty         like ub.doc-pl.doc-qnty
  field fact-qnty        like ub.doc-pl.fact-qnty
  field db-cli-qnty      like ub.doc-pl.cli-qnty
  field db-cli-doc-qnty  like ub.doc-pl.cli-doc-qnty
  field db-cli-fact-qnty like ub.doc-pl.cli-fact-qnty
  field db-doc-qnty      like ub.doc-pl.doc-qnty
  field db-fact-qnty     like ub.doc-pl.fact-qnty
  index xpk is primary pl-code
.
procedure temp-doc-pl-clear :
  define buffer buf_temp-doc-pl for temp-doc-pl .
  do
  on error undo, return error return-value
  :
    for each buf_temp-doc-pl
    on error undo, return error return-value
    :
      delete buf_temp-doc-pl .
    end.
  end.
end procedure.
procedure temp-doc-pl-init :
  define input parameter p-out-code like ub.doc-pl.out-code no-undo .
  define input parameter p-gds-code like ub.doc-pl.gds-code no-undo .
  define buffer buf_doc-pl for ub.doc-pl .
  define buffer buf_temp-doc-pl for temp-doc-pl .
  do
  on error undo, return error return-value
  :
    for each buf_doc-pl share-lock
      where buf_doc-pl.out-code = p-out-code
        and buf_doc-pl.gds-code = p-gds-code
    on error undo, return error return-value
    :
      create buf_temp-doc-pl .
      assign
        buf_temp-doc-pl.pl-code          = buf_doc-pl.pl-code
        buf_temp-doc-pl.db-cli-qnty      = buf_doc-pl.cli-qnty
        buf_temp-doc-pl.db-cli-doc-qnty  = buf_doc-pl.cli-doc-qnty
        buf_temp-doc-pl.db-cli-fact-qnty = buf_doc-pl.cli-fact-qnty
        buf_temp-doc-pl.db-doc-qnty      = buf_doc-pl.doc-qnty
        buf_temp-doc-pl.db-fact-qnty     = buf_doc-pl.fact-qnty
      .
    end.
  end.
end procedure.
procedure temp-doc-pl-accum :
  define input parameter p-pl-code       like ub.doc-pl.pl-code      no-undo .
  define input parameter p-cli-qnty      like ub.doc-pl.cli-qnty     no-undo .
  define input parameter p-doc-qnty      like ub.doc-pl.doc-qnty     no-undo .
  define input parameter p-fact-qnty     like ub.doc-pl.fact-qnty    no-undo .
  define input parameter p-cli-base-rate like ub.parts.cli-base-rate no-undo .
  define buffer buf_temp-doc-pl for temp-doc-pl .
  do
  on error undo, return error return-value
  :
    find first buf_temp-doc-pl
      where buf_temp-doc-pl.pl-code = p-pl-code
      no-error .
    if not available buf_temp-doc-pl then do:
      create buf_temp-doc-pl .
      assign
        buf_temp-doc-pl.pl-code = p-pl-code
      .
    end.
    assign
      buf_temp-doc-pl.cli-qnty      = buf_temp-doc-pl.cli-qnty      + p-cli-qnty
      buf_temp-doc-pl.cli-doc-qnty  = buf_temp-doc-pl.cli-doc-qnty  + p-doc-qnty  / p-cli-base-rate
      buf_temp-doc-pl.cli-fact-qnty = buf_temp-doc-pl.cli-fact-qnty + p-fact-qnty / p-cli-base-rate
      buf_temp-doc-pl.doc-qnty      = buf_temp-doc-pl.doc-qnty      + p-doc-qnty
      buf_temp-doc-pl.fact-qnty     = buf_temp-doc-pl.fact-qnty     + p-fact-qnty
    .
  end.
end procedure.
define variable v-root-node   as integer   no-undo .
define variable l-empty-scale as logical   no-undo .
find first ub.trn-doc no-lock
  where ub.trn-doc.doc-code = v-doc-code
  no-error .
if not available ub.trn-doc then do:
  message
    "Документ не найден" v-doc-code skip
    view-as alert-box error .
  undo, return error .
end.
if (ub.trn-doc.status_ = 'накл':U and ub.trn-doc.flag_  = no)
or (ub.trn-doc.status_ = 'касс':U)
then do:
end.
else do:
  define variable lok as logical no-undo .
  message
    "Статус документа" ub.trn-doc.status_ ub.trn-doc.flag_ skip
    "Вы хотите ввести системный пароль и продолжить работу программы" skip
    "Коррекция признаков возможна только для товаров, имеющих пустую шкалу" skip
    view-as alert-box question buttons yes-no update lok.
  if lok <> true then do:
    undo, return error .
  end.
  else do:
    run gbl/authoriz.p
      (input  "checkdoc.p:fix"
      ,output lok
      ) .
    if lok <> true then do:
      message
        "Пароль введен неправильно." skip
        "Исправление документа невозможно" skip
        view-as alert-box information .
      undo, return error .
    end.
  end.
end.
for each doc-line
  where doc-line.doc-code = v-doc-code
on error undo, return error
:
  find first ub.goods no-lock
    where ub.goods.artic     = ub.doc-line.artic
      and ub.goods.prod-type = ub.doc-line.prod-type
      and ub.goods.prod-code = ub.doc-line.prod-code
    .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  doc-line.artic
  ,input  doc-line.prod-type
  ,input  doc-line.prod-code
  ,output v-root-node
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output l-empty-scale
  )  .
  if l-empty-scale = false then do:
    next .
  end.
  if ub.goods.gds-type = 'т':U then do:
    define variable l-reserv-pl-code         as logical no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,input  'place-rsrv=request'
  ,output l-reserv-pl-code
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "Ошибка при определении признака товара на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if l-reserv-pl-code then do:
      run temp-doc-pl-clear in this-procedure .
      run temp-doc-pl-init  in this-procedure
        (input ub.doc-line.doc-code
        ,input ub.goods.gds-code
        ).
    end.
    define variable v-qnty      as decimal no-undo .
    define variable v-fact-qnty as decimal no-undo .
    assign
      v-qnty      = 0
      v-fact-qnty = 0
    .
    for each parts no-lock
      where parts.out-code  = doc-line.doc-code
        and parts.obj-type  = trn-doc.obj-type
        and parts.obj-code  = trn-doc.obj-code
        and parts.artic     = doc-line.artic
        and parts.prod-type = doc-line.prod-type
        and parts.prod-code = doc-line.prod-code
    :
      assign
        v-qnty      = v-qnty      + parts.qnty
        v-fact-qnty = v-fact-qnty + parts.fact-qnty
      .
      run temp-doc-pl-accum in this-procedure
        (input ub.parts.pl-code
        ,input ub.parts.cli-qnty
        ,input ub.parts.qnty
        ,input ub.parts.fact-qnty
        ,input ub.parts.cli-base-rate
        ) .
    end.
    if l-reserv-pl-code then do:
      for each temp-doc-pl
        where temp-doc-pl.db-doc-qnty  <> temp-doc-pl.doc-qnty
           or temp-doc-pl.db-fact-qnty <> temp-doc-pl.fact-qnty
      on error undo, return error
      :
        find first ub.doc-pl exclusive-lock
          where ub.doc-pl.obj-type = ub.doc-line.obj-type
            and ub.doc-pl.obj-code = ub.doc-line.obj-code
            and ub.doc-pl.pl-code  = temp-doc-pl.pl-code
            and ub.doc-pl.out-code = ub.doc-line.doc-code
            and ub.doc-pl.gds-code = ub.goods.gds-code
          no-error .
        if  temp-doc-pl.doc-qnty  = 0
        and temp-doc-pl.fact-qnty = 0
        then do:
          if available ub.doc-pl then do:
            output to checkdoc.txt append .
            export "fix_doc-pl_delete" temp-doc-pl.doc-qnty temp-doc-pl.fact-qnty .
            export "doc-pl_old_qnty" ub.doc-pl.doc-qnty ub.doc-pl.fact-qnty .
            export ub.doc-pl .
            output close .
            assign
              i-err-count = i-err-count + 1
            .
            delete ub.doc-pl .
          end.
        end.
        else do:
          if not available ub.doc-pl then do:
            create ub.doc-pl .
            assign
              ub.doc-pl.obj-type = ub.doc-line.obj-type
              ub.doc-pl.obj-code = ub.doc-line.obj-code
              ub.doc-pl.pl-code  = temp-doc-pl.pl-code
              ub.doc-pl.out-code = ub.doc-line.doc-code
              ub.doc-pl.gds-code = ub.goods.gds-code
            .
          end.
          output to checkdoc.txt append .
          export "fix_doc-pl_new_qnty" temp-doc-pl.doc-qnty temp-doc-pl.fact-qnty .
          export "doc-pl_old_qnty" ub.doc-pl.doc-qnty ub.doc-pl.fact-qnty .
          export ub.doc-pl .
          output close .
          assign
            i-err-count = i-err-count + 1
          .
          assign
            ub.doc-pl.doc-qnty  = temp-doc-pl.doc-qnty
            ub.doc-pl.fact-qnty = temp-doc-pl.fact-qnty
          .
        end.
      end.
    end.
    if doc-line.doc-qnty  <> v-qnty
    or doc-line.fact-qnty <> v-fact-qnty
    then do:
      output to checkdoc.txt append .
      export "fix_doc-line_new_qnty " v-qnty v-fact-qnty .
      export "doc-line_old_qnty" doc-line.doc-qnty doc-line.fact-qnty .
      export doc-line .
      output close .
      output to badartic.txt append .
      export
        doc-line.obj-type doc-line.obj-code
        doc-line.artic doc-line.prod-type doc-line.prod-code
        .
      output close .
      assign
        i-err-count = i-err-count + 1
      .
      assign
        doc-line.doc-qnty  = v-qnty
        doc-line.fact-qnty = v-fact-qnty
      .
    end.
    find first gds-dtl
      where gds-dtl.doc-code  = doc-line.doc-code
        and gds-dtl.artic     = doc-line.artic
        and gds-dtl.prod-type = doc-line.prod-type
        and gds-dtl.prod-code = doc-line.prod-code
        and gds-dtl.prt-code  = v-root-node
      no-error .
    if available gds-dtl then do:
      if gds-dtl.doc-qnty  <> v-qnty
      or gds-dtl.fact-qnty <> v-fact-qnty
      then do:
        output to checkdoc.txt append .
        export "fix_gds-dtl_new_qnty " v-qnty v-fact-qnty .
        export "gds-dtl_old_qnty " gds-dtl.doc-qnty gds-dtl.fact-qnty .
        export gds-dtl .
        output close .
        output to badartic.txt append .
        export
          doc-line.obj-type doc-line.obj-code
          doc-line.artic doc-line.prod-type doc-line.prod-code
          .
        output close .
        assign
          i-err-count = i-err-count + 1
        .
        assign
          gds-dtl.doc-qnty  = v-qnty
          gds-dtl.fact-qnty = v-fact-qnty
        .
      end.
    end.
  end.
end.
