block-level on error undo, throw.
/*

$Revision: 1351a33238ea, 1271, rls $
$Author: ASMorozov $
$Date: Wed Mar 21 09:55:56 2018 +0300 $
$Workfile: restext.p $
$Archive: adm/restext.p $

Выгрузка внешних подсистем для rest-rdb.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-log-handle as handle           no-undo.
define input parameter p-db-num     as integer          no-undo.
define input parameter p-unload-history as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: 1351a33238ea, 1271, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Mar 21 09:55:56 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: restext.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/restext.p $":U .
define variable vss-description as character no-undo init "Выгрузка внешних подсистем для rest-rdb.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/esallatr.i work }

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
       or buf_ext-system.esys-type > integer({&openxml-type-ordinal})
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
      end.        /* for each buf_с-ext-system */
    end. /*if p-unload-history then do:*/
  end.        /* for each buf_ext-system */
end.


/*==========================================================================*/
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
    end.        /* for each buf_esys-datatype-exp */
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
      end.        /* for each buf_c-esys-datatype-exp */
    end.
end.
end procedure. /* restext-esys-datatype-exp */


/*==========================================================================*/
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
    end.        /* for each buf_esys-datatype-imp */
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
      end.        /* for each buf_c-esys-datatype-imp */
   end.
end.
end procedure. /* restext-esys-datatype-imp */


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
              buf_esys-all-attr.attr-code = {&attr-custom-pack-name}
          and buf_esys-all-attr.table-name = {&table_esys-pck-sent}
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
  end.        /* for each buf_esys-pck-sent */
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
  end.        /* for each buf_esys-pck-rcvd */
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
              buf_esys-all-attr.attr-code = {&attr-route-custom-pack-name}
          and buf_esys-all-attr.table-name = {&table_esys-route}
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
  end.        /* for each buf_esys-route */
end.

end procedure. /* rest-sys-pck */