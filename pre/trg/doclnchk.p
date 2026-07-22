block-level on error undo, throw.
define input parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
define input parameter p-artic     like ub.doc-line.artic     no-undo .
define input parameter p-prod-type like ub.doc-line.prod-type no-undo .
define input parameter p-prod-code like ub.doc-line.prod-code no-undo .
define input parameter l-check-cli-qnty as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка целостности строки документа".
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
procedure partrqst :
  define input  parameter p-doc-code                   like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type                   like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code                   like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                      like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type                  like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code                  like ub.doc-line.prod-code no-undo .
  define output parameter p-total-parts-qnty           like ub.parts.qnty         no-undo .
  define output parameter p-total-parts-fact-qnty      like ub.parts.fact-qnty    no-undo .
  define output parameter p-total-parts-cli-qnty       like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-fact-cli-qnty  like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-price-cli      as decimal                 no-undo .
  define output parameter p-total-parts-price-base     as decimal                 no-undo .
  define output parameter p-total-parts-price-rubl     as decimal                 no-undo .
  define output parameter p-total-parts-transport-base as decimal                 no-undo .
  define output parameter p-total-parts-transport-rubl as decimal                 no-undo .
  define output parameter p-total-parts-other-base     as decimal                 no-undo .
  define output parameter p-total-parts-other-rubl     as decimal                 no-undo .
  define variable vss-description as character no-undo init "partrqst: Суммарная информация по всем зарезервированным партиям строки документа".
  do
  on error undo, return error return-value
  :
    assign
      p-total-parts-qnty           = 0
      p-total-parts-fact-qnty      = 0
      p-total-parts-cli-qnty       = 0
      p-total-parts-fact-cli-qnty  = 0
      p-total-parts-price-cli      = 0
      p-total-parts-price-base     = 0
      p-total-parts-price-rubl     = 0
      p-total-parts-transport-base = 0
      p-total-parts-transport-rubl = 0
      p-total-parts-other-base     = 0
      p-total-parts-other-rubl     = 0
    .
    define buffer buf_parts for ub.parts .
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      define variable v-parts-fact-multiplier as decimal   no-undo .
      assign
        v-parts-fact-multiplier = 1
      .
      if buf_parts.qnty <> 0 then do:
        assign
          v-parts-fact-multiplier = buf_parts.fact-qnty / buf_parts.qnty
        .
      end.
      assign
        p-total-parts-qnty            = p-total-parts-qnty       + buf_parts.qnty
        p-total-parts-fact-qnty       = p-total-parts-fact-qnty  + buf_parts.fact-qnty
        p-total-parts-cli-qnty        = p-total-parts-cli-qnty   + buf_parts.cli-qnty
        p-total-parts-fact-cli-qnty   = p-total-parts-fact-cli-qnty
                                      + buf_parts.cli-qnty * v-parts-fact-multiplier
        p-total-parts-price-cli       = p-total-parts-price-cli  + buf_parts.cli-qnty  * buf_parts.price-cli
        p-total-parts-price-base      = p-total-parts-price-base + buf_parts.fact-qnty * buf_parts.price-base
        p-total-parts-price-rubl      = p-total-parts-price-rubl + buf_parts.fact-qnty * buf_parts.price-rubl
        p-total-parts-transport-base  = p-total-parts-transport-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-base <> ?
                                          then buf_parts.transport-base
                                          else 0
                                          )
        p-total-parts-transport-rubl  = p-total-parts-transport-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-rubl <> ?
                                          then buf_parts.transport-rubl
                                          else 0
                                          )
        p-total-parts-other-base      = p-total-parts-other-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-base <> ?
                                          then buf_parts.other-base
                                          else 0
                                          )
        p-total-parts-other-rubl      = p-total-parts-other-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-rubl <> ?
                                          then buf_parts.other-rubl
                                          else 0
                                          )
      .
    end.
  end.
end procedure.
define variable v-total-gds-dtl-doc-qnty  like ub.gds-dtl.doc-qnty  no-undo .
define variable v-total-gds-dtl-fact-qnty like ub.gds-dtl.fact-qnty no-undo .
do
on error undo, return error
:
  find first ub.doc-line no-lock
    where ub.doc-line.doc-code  = p-doc-code
      and ub.doc-line.artic     = p-artic
      and ub.doc-line.prod-type = p-prod-type
      and ub.doc-line.prod-code = p-prod-code
    no-error .
  if not available ub.doc-line then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена строка документа" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error .
  end.
  find first ub.trn-doc no-lock
    where ub.trn-doc.doc-code = ub.doc-line.doc-code
    no-error .
  if not available ub.trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-obj-type like ub.doc-line.obj-type no-undo .
  define variable v-obj-code like ub.doc-line.obj-code no-undo .
  assign
    v-obj-type = ub.doc-line.obj-type
    v-obj-code = ub.doc-line.obj-code
  .
  assign
    v-total-gds-dtl-doc-qnty  = 0
    v-total-gds-dtl-fact-qnty = 0
  .
  for each gds-dtl no-lock
    where gds-dtl.doc-code  = p-doc-code
      and gds-dtl.artic     = p-artic
      and gds-dtl.prod-type = p-prod-type
      and gds-dtl.prod-code = p-prod-code
  :
    assign
      v-total-gds-dtl-doc-qnty  = v-total-gds-dtl-doc-qnty  + ub.gds-dtl.doc-qnty
      v-total-gds-dtl-fact-qnty = v-total-gds-dtl-fact-qnty + ub.gds-dtl.fact-qnty
    .
  end.
    define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
  run partrqst in this-procedure
    (input  p-doc-code
    ,input  v-obj-type
    ,input  v-obj-code
    ,input  p-artic
    ,input  p-prod-type
    ,input  p-prod-code
        ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
    ).
  if ub.trn-doc.doc-type <> 'инв':U then do:
    if v-total-parts-qnty <> v-total-gds-dtl-doc-qnty
    then do:
      message
        "Количество по всем партиям не сооветствует количеству по всем признакам" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Количество по всем партиям:" v-total-parts-qnty skip
        "Количества по всем признакам:" v-total-gds-dtl-doc-qnty skip
        view-as alert-box .
      undo, return error .
    end.
  end.
  if ub.trn-doc.doc-type <> 'инв':U then do:
    if ub.trn-doc.status_ <> 'касс':U then do:
      if v-total-parts-fact-qnty <> v-total-gds-dtl-fact-qnty
      then do:
        message
          "Фактическое количество по всем партиям не сооветствует" skip
          "фактическому количеству по всем признакам" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Фактическое количество по всем партиям:" v-total-parts-fact-qnty skip
          "Фактическое количества по всем признакам:" v-total-gds-dtl-fact-qnty skip
          view-as alert-box .
        undo, return error .
      end.
    end.
  end.
  if l-check-cli-qnty then do:
    if v-total-parts-qnty = doc-line.doc-qnty then do:
      if v-total-parts-cli-qnty <> ub.doc-line.cli-qnty then do:
        message
          "Количество по ТТН по всем партиям не сооветствует" skip
          "количеству по ТТН накладной" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Количество по ТТН по всем партиям:" v-total-parts-cli-qnty skip
          "Количество по ТТН накладной:" ub.doc-line.cli-qnty skip
          view-as alert-box .
        undo, return error .
      end.
    end.
  end.
end.
