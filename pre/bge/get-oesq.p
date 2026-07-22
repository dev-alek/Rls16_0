block-level on error undo, throw.
define input  parameter p-table-name as character no-undo.
define input  parameter p-doc-code   as character no-undo.
define output parameter p-seq-num    as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-oesq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/get-oesq.p $":U .
define variable vss-description as character no-undo init "Получение номера sequence выгрузки в Oracle Retail для документа".
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
procedure orddocattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input  parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-value    like ub.ord-doc-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if avail buf_ord-doc-attr then do:
      assign
        p-value =  buf_ord-doc-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure orddocattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define input parameter p-value    like ub.ord-doc-attr.attr-value no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr exclusive-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if not available buf_ord-doc-attr then do:
      create buf_ord-doc-attr .
      assign
        buf_ord-doc-attr.doc-code  = p-doc-code
        buf_ord-doc-attr.attr-code = p-code
      .
    end.
    assign
      buf_ord-doc-attr.attr-value = p-value
    .
end.
end procedure.
procedure orddocattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if  available buf_ord-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure orddocattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    define variable v-other          as character no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr exclusive-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ord-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ord-doc-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure orddocattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-proc           as character no-undo .
    define output parameter p-func           as character no-undo .
    define output parameter p-sort           as integer   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'cycle-doc-code':U then do:     assign     p-label          = "Номер заказа цикличного"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Номер заказа цикличного"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-day':U then do:     assign     p-label          = "период цикличности"     p-type           = 'I':U      p-format         = ">>>>>>9"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "период цикличности"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-done':U then do:     assign     p-label          = "Заказ рассчитан"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Заказ рассчитан"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'exch-code':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'exch-rate':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'exch-scale':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'base-rate':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'base-scale':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-contract-code':U then do:     assign     p-label          = "договор"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "договор"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-ship-date':U then do:     assign     p-label          = "дата доставки"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "дата доставки"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-ship-time':U then do:     assign     p-label          = "время доставки"     p-type           = 'I':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "время доставки"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-date1':U then do:     assign     p-label          = "период продаж"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "период продаж"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-date2':U then do:     assign     p-label          = "период продаж"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "период продаж"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-doc-date':U then do:     assign     p-label          = "дата заказа"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "дата заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'ora-exp-seq-num':U then do:     assign     p-label          = "Номер выгрузки в Oracle Retail"     p-type           = 'I':U      p-format         = "999999999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Номер выгрузки в Oracle Retail"     p-user-can-edit  = false     p-output-display = false     p-sort           = 100     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки заказа" + " " + p-code .
      end.
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_c-trn-doc     for ub.c-trn-doc.
  define buffer buf_price-doc     for ub.price-doc.
  define buffer buf_ord-doc       for ub.ord-doc.
  define variable v-seq-num as integer   no-undo .
  define variable v-exist   as logical   no-undo .
  define variable v-value   as character no-undo.
  define variable v-type    as character no-undo.
do
for buf_trn-doc
  , buf_c-trn-doc
  , buf_price-doc
  , buf_ord-doc
on error undo, return error return-value
:
  assign
    p-seq-num = ?
  .
  case p-table-name
  :
    when 'trn-doc':U
    or when 'c-trn-doc':U
    or when 'price-doc':U
    then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-xst in g#trdcalib (  input p-doc-code ,
                        input 'ora-exp-seq-num':U ,
                       output v-exist ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1 &2 &3 &4&5&4&6&4&7"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , chr(10)
                                      , error-status :get-message(1)
                                      , return-value
                                      , "Ошибка из tdat-xst.i"
                                      ).
      end.
      if v-exist = no
      then do:
        return .
      end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'ora-exp-seq-num':U ,
                       output v-value ,
                       output v-type ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1 &2 &3 &4&5&4&6&4&7"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , chr(10)
                                      , error-status :get-message(1)
                                      , return-value
                                      , "Ошибка из tdat-val.i"
                                      ).
      end.
    end.
    when 'ord-doc':U
    then do:
      run orddocattr-exist in this-procedure ( input p-doc-code
                                              , input 'ora-exp-seq-num':U
                                              , output v-exist
                                              ) no-error .
      if error-status :error = yes
      then do:
        undo, return error substitute( "&1 &2 &3 &4&5&4&6&4&7"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , chr(10)
                                      , error-status :get-message(1)
                                      , return-value
                                      , "Ошибка из orddocattr-exist"
                                      ).
      end.
      if v-exist = no
      then do:
        return .
      end.
      run orddocattr-value in this-procedure ( input p-doc-code
                                              , input 'ora-exp-seq-num':U
                                              , output v-value
                                              , output v-type
                                              ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1 &2 &3 &4&5&4&6&4&7"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , chr(10)
                                      , error-status :get-message(1)
                                      , return-value
                                      , "Ошибка из orddocattr-value"
                                      ).
      end.
    end.
    otherwise do:
      undo, return error substitute( "&1 &2 &3 &4&5: &6"
                                    , vss-workfile
                                    , vss-revision
                                    , vss-description
                                    , chr(10)
                                    , "Недопустимый тип документа":U
                                    , p-table-name
                                    ).
    end.
  end case.
  assign
    v-seq-num = integer(v-value)
  no-error .
  if error-status :error = yes
  then do:
    undo, return error substitute( "&1 &2 &3 &4&5: &6"
                                  , vss-workfile
                                  , vss-revision
                                  , vss-description
                                  , chr(10)
                                  , "Ошибка преобразования номера пакета":U
                                  , v-value
                                  ).
  end.
  assign
    p-seq-num = v-seq-num
  .
end.
