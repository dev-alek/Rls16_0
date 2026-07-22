block-level on error undo, throw.
define input parameter p-log-handle as handle           no-undo.
define input parameter p-db-num     as integer          no-undo.
define input parameter p-unload-history as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: 1351a33238ea, 1271, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Mar 21 09:55:56 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: restext.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/restext.p $":U .
define variable vss-description as character no-undo init "Выгрузка внешних подсистем для rest-rdb.".
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
procedure esallatr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'custom-pack-name':U then do:     assign     p-label = "Имя файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Имя файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'route-custom-pack-name':U then do:     assign     p-label = "Иям файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Иям файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure esallatr-value :
do
  on error undo, return error
  :
  define input  parameter p-table-name as character no-undo .
  define input  parameter p-key1     as int64 no-undo .
  define input  parameter p-key2     as int64 no-undo .
  define input  parameter p-key3     as character no-undo .
  define input  parameter p-key4     as character no-undo .
  define input  parameter p-key5     as int64 no-undo .
  define input  parameter p-key6     as int64 no-undo .
  define input  parameter p-key7     as character no-undo .
  define input  parameter p-key8     as character no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
    run esallatr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf_esys-all-attr no-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
   if avail buf_esys-all-attr then do:
    assign
    p-value = buf_esys-all-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = 'L':U then "no":U else "".
   end.
end.
end procedure.
define variable v-restext-count-str     as character    no-undo.
define variable v-counter       as integer      no-undo.
define variable v-table-name    as character    no-undo.
define buffer buf_ext-system                for ub.ext-system.
define buffer buf_c-ext-system              for ub.c-ext-system.
define buffer buf_ext-system-attr           for ub.ext-system-attr.
disable triggers for load of dst.ext-system.
disable triggers for load of dst.c-ext-system.
disable triggers for load of dst.ext-system-attr.
disable triggers for load of dst.esys-datatype-exp.
disable triggers for load of dst.c-esys-datatype-exp.
disable triggers for load of dst.esys-datatype-imp.
disable triggers for load of dst.c-esys-datatype-imp.
disable triggers for load of dst.esys-pck-sent.
disable triggers for load of dst.esys-pck-rcvd.
disable triggers for load of dst.esys-pck-keys.
disable triggers for load of dst.esys-route.
disable triggers for load of dst.esys-route-dump.
disable triggers for load of dst.esys-all-attr.
do
for buf_ext-system
  , buf_c-ext-system
  , buf_ext-system-attr
on error undo, return error
:
    assign
        v-counter       = 0
        v-table-name    = "ext-system":U
    .
    for each buf_ext-system no-lock
       where buf_ext-system.esys-db-num-imp = p-db-num
       or buf_ext-system.esys-db-num-exp = p-db-num
       or buf_ext-system.esys-type > integer('0':U)
    on error undo, return error
    :
        assign
            v-counter = v-counter + 1
            v-restext-count-str = substitute( "Обработано внешних систем: &1", v-counter )
        .
        run display-with-frame in p-log-handle (
              input v-restext-count-str
            , input v-table-name
            , input v-counter
        ).
        create dst.ext-system.
        buffer-copy buf_ext-system to dst.ext-system.
      for each buf_ext-system-attr no-lock where
              buf_ext-system-attr.esys-id = buf_ext-system.esys-id
          and buf_ext-system-attr.db-num = buf_ext-system.db-num
      on error undo, return error
      :
        create dst.ext-system-attr.
        buffer-copy buf_ext-system-attr to dst.ext-system-attr.
      end.
      if buf_ext-system.esys-db-num-exp = p-db-num then do:
        run restext-esys-datatype-exp in this-procedure (
              input buf_ext-system.esys-id
            , input buf_ext-system.db-num
        ).
      end.
      if buf_ext-system.esys-db-num-imp = p-db-num then do:
        run restext-esys-datatype-imp in this-procedure (
              input buf_ext-system.esys-id
            , input buf_ext-system.db-num
        ).
      end.
      if (buf_ext-system.esys-db-num-exp = p-db-num
      or buf_ext-system.esys-db-num-imp = p-db-num)
      and not buf_ext-system.delivery-method = 11 then do:
        run restext-esys-pck in this-procedure (
              input buf_ext-system.esys-id
            , input buf_ext-system.db-num
        ).
      end.
    if p-unload-history then do:
      assign
          v-counter       = 0
          v-table-name    = "c-ext-system":U
      .
      for each buf_c-ext-system no-lock
          where buf_c-ext-system.esys-id = buf_ext-system.esys-id
          and buf_c-ext-system.db-num = buf_ext-system.db-num
      on error undo, return error
      :
          assign
              v-counter = v-counter + 1
          .
          run display-with-frame in p-log-handle (
                input substitute( "Обработано удалённых внешних систем: &1", v-counter )
              , input v-table-name
              , input v-counter
          ).
          create dst.c-ext-system.
          buffer-copy buf_c-ext-system to dst.c-ext-system.
            if buf_ext-system.esys-db-num-exp = p-db-num then do:
          run restext-esys-datatype-exp in this-procedure (
                input buf_c-ext-system.esys-id
              , input buf_c-ext-system.db-num
          ).
            end.
            if buf_ext-system.esys-db-num-imp = p-db-num then do:
          run restext-esys-datatype-imp in this-procedure (
                input buf_c-ext-system.esys-id
              , input buf_c-ext-system.db-num
          ).
            end.
      end.
    end.
  end.
end.
procedure restext-esys-datatype-exp :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define variable v-counter    as integer      no-undo.
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_c-esys-datatype-exp   for ub.c-esys-datatype-exp.
do
for buf_esys-datatype-exp
  , buf_c-esys-datatype-exp
on error undo, return error
:
    assign
        v-counter = 0
    .
    for each buf_esys-datatype-exp no-lock
       where buf_esys-datatype-exp.esys-id  = p-esys-id
         and buf_esys-datatype-exp.db-num   = p-db-num
    on error undo, return error
    :
        assign
            v-counter = v-counter + 1
        .
        run display-with-frame in p-log-handle (
              input v-restext-count-str
            , input "esys-datatype-exp":U
            , input v-counter
        ).
        create dst.esys-datatype-exp.
        buffer-copy buf_esys-datatype-exp to dst.esys-datatype-exp.
    end.
    if p-unload-history then do:
      for each buf_c-esys-datatype-exp no-lock
        where buf_c-esys-datatype-exp.esys-id  = p-esys-id
          and buf_c-esys-datatype-exp.db-num   = p-db-num
      on error undo, return error
      :
          assign
              v-counter = v-counter + 1
          .
          run display-with-frame in p-log-handle (
                input v-restext-count-str
              , input "c-esys-datatype-exp":U
              , input v-counter
          ).
          create dst.c-esys-datatype-exp.
          buffer-copy buf_c-esys-datatype-exp to dst.c-esys-datatype-exp.
      end.
    end.
end.
end procedure.
procedure restext-esys-datatype-imp :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define variable v-counter    as integer      no-undo.
    define buffer buf_esys-datatype-imp     for ub.esys-datatype-imp.
    define buffer buf_c-esys-datatype-imp   for ub.c-esys-datatype-imp.
do
for buf_esys-datatype-imp
  , buf_c-esys-datatype-imp
on error undo, return error
:
    assign
        v-counter       = 0
    .
    for each buf_esys-datatype-imp no-lock
       where buf_esys-datatype-imp.esys-id  = p-esys-id
         and buf_esys-datatype-imp.db-num   = p-db-num
    on error undo, return error
    :
        assign
            v-counter = v-counter + 1
        .
        run display-with-frame in p-log-handle (
              input v-restext-count-str
            , input "esys-datatype-imp":U
            , input v-counter
        ).
        create dst.esys-datatype-imp.
        buffer-copy buf_esys-datatype-imp to dst.esys-datatype-imp.
    end.
    if p-unload-history then do:
      for each buf_c-esys-datatype-imp no-lock
        where buf_c-esys-datatype-imp.esys-id  = p-esys-id
          and buf_c-esys-datatype-imp.db-num   = p-db-num
      on error undo, return error
      :
          assign
              v-counter = v-counter + 1
          .
          run display-with-frame in p-log-handle (
                input v-restext-count-str
              , input "c-esys-datatype-imp":U
              , input v-counter
          ).
          create dst.c-esys-datatype-imp.
          buffer-copy buf_c-esys-datatype-imp to dst.c-esys-datatype-imp.
      end.
   end.
end.
end procedure.
procedure restext-esys-pck :
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_esys-all-attr for ub.esys-all-attr.
define buffer buf2_esys-route for ub.esys-route.
do
for buf_esys-pck-sent
  , buf_esys-pck-rcvd
  , buf_esys-pck-keys
on error undo, return error
:
  assign
      v-counter       = 0
  .
  for each buf_esys-pck-sent no-lock
      where buf_esys-pck-sent.esys-id  = p-esys-id
        and buf_esys-pck-sent.db-num   = p-db-num
  on error undo, return error
  :
      create dst.esys-pck-sent.
      buffer-copy buf_esys-pck-sent to
      dst.esys-pck-sent.
      assign
          v-counter = v-counter + 1
      .
     find first buf_esys-all-attr no-lock where
              buf_esys-all-attr.attr-code = 'custom-pack-name':U
          and buf_esys-all-attr.table-name = 'esys-pck-sent':U
          and  buf_esys-all-attr.key1 = buf_esys-pck-sent.esps-pack-num
          and  buf_esys-all-attr.key2 = buf_esys-pck-sent.esys-id
          and  buf_esys-all-attr.key5 = buf_esys-pck-sent.db-num no-error.
      if available buf_esys-all-attr then do:
        create dst.esys-all-attr.
        buffer-copy buf_esys-all-attr to
        dst.esys-all-attr.
      end.
      run display-with-frame in p-log-handle (
            input v-restext-count-str
          , input "esys-pck-sent":U
          , input v-counter
      ).
  end.
  for each buf_esys-pck-rcvd no-lock
      where buf_esys-pck-rcvd.esys-id  = p-esys-id
        and buf_esys-pck-rcvd.db-num   = p-db-num
  on error undo, return error
  :
      create dst.esys-pck-rcvd.
      buffer-copy buf_esys-pck-rcvd to
      dst.esys-pck-rcvd.
      assign
          v-counter = v-counter + 1
      .
      run display-with-frame in p-log-handle (
            input v-restext-count-str
          , input "esys-pck-rcvd":U
          , input v-counter
      ).
  end.
  for each buf_esys-route no-lock
      where buf_esys-route.esys-id  = p-esys-id
        and buf_esys-route.db-num   = p-db-num
  on error undo, return error
  :
      if buf_esys-route.esr-last-pack = -1 then do:
        find first buf2_esys-route no-lock where
                  buf2_esys-route.esys-id = buf_esys-route.esys-id
             and buf2_esys-route.db-num = buf_esys-route.db-num
             and buf2_esys-route.esr-tbl-ord = buf_esys-route.esr-tbl-ord
             and buf2_esys-route.esr-cr-db-num = buf_esys-route.esr-cr-db-num
             and buf2_esys-route.esr-last-pack > 0
             no-error.
        if available buf2_esys-route then next.
      end.
      for each buf_esys-route-dump no-lock
          where buf_esys-route-dump.esrd-dump-ord  = buf_esys-route.esr-dump-ord
            and buf_esys-route-dump.esrd-rec-ord > -29999999
            and buf_esys-route-dump.esrd-cr-db-num = buf_esys-route.esr-cr-db-num
      on error undo, return error
      :
        create dst.esys-route-dump.
        buffer-copy buf_esys-route-dump to
        dst.esys-route-dump.
        assign
            v-counter = v-counter + 1
        .
      end.
      find first buf_esys-all-attr no-lock where
              buf_esys-all-attr.attr-code = 'route-custom-pack-name':U
          and buf_esys-all-attr.table-name = 'esys-route':U
          and  buf_esys-all-attr.key1 = buf_esys-route.esr-dump-ord
          and  buf_esys-all-attr.key2 = buf_esys-route.esys-id
          and  buf_esys-all-attr.key5 = buf_esys-route.db-num no-error.
      if available buf_esys-all-attr then do:
        create dst.esys-all-attr.
        buffer-copy buf_esys-all-attr to
        dst.esys-all-attr.
      end.
      create dst.esys-route.
      buffer-copy buf_esys-route to
      dst.esys-route.
      assign
          v-counter = v-counter + 1
      .
      run display-with-frame in p-log-handle (
            input v-restext-count-str
          , input "esys-route":U
          , input v-counter
      ).
  end.
end.
end procedure.
