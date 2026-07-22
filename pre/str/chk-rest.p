block-level on error undo, throw.
define input parameter p-doc-code like ub.c-chk-doc.doc-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Восстановление удаленного чека".
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
define variable v-obj-db-num as integer no-undo .
define variable v-discnt as character no-undo .
define buffer buf_c-chk-doc for ub.c-chk-doc.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf2_c-chk-doc for ub.c-chk-doc.
define buffer buf2_c-chk-gds for ub.c-chk-gds.
define buffer buf2_c-chk-pay for ub.c-chk-pay.
define buffer buf2_c-chk-discnt for ub.c-chk-discnt.
define buffer buf2_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_marking-chk for ub.marking-chk.
define buffer buf_c-marking-chk for ub.c-marking-chk.
define buffer buf2_c-marking-chk for ub.c-marking-chk.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-doc-attr for ub.chk-doc-attr.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_chk-pay-attr for ub.chk-pay-attr.
define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find last buf_c-chk-doc exclusive-lock where
          buf_c-chk-doc.doc-code = p-doc-code use-index pi.
  if buf_c-chk-doc.is-del = no then do:
    undo main-block, return error substitute("Нельзя восстановить чек &1 по истории - чек не был удален", p-doc-code).
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_c-chk-doc.obj-type
  ,input  buf_c-chk-doc.obj-code
  ,output v-obj-db-num
  )  .
  if v-obj-db-num <> g#db-num then do:
    undo main-block, return error substitute("Нельзя восстановить чек &1 по истории&2" +
                                              "чек объекта &3&4, принадлежащего БД &5" +
                                              "текущая БД - &6"
                                              , p-doc-code
                                              , chr(10)
                                              , buf_c-chk-doc.obj-type
                                              , buf_c-chk-doc.obj-code
                                              , v-obj-db-num
                                              , g#db-num
                                              ).
  end.
  if buf_c-chk-doc.out-code <> '':U
  and buf_c-chk-doc.out-code <> ? then do:
     undo main-block, return error substitute("Нельзя восстановить чек &1 по истории&2" +
                                               "в выбранном срезе истории &3 чек привязан к документу продажи"
                                               , buf_c-chk-doc.doc-code
                                               , chr(10)
                                               , buf_c-chk-doc.chip-num).
  end.
  FIND  buf_chk-doc where
        buf_chk-doc.obj-type = buf_c-chk-doc.obj-type
    and buf_chk-doc.obj-code = buf_c-chk-doc.obj-code
    and buf_chk-doc.chk-date = buf_c-chk-doc.chk-date
    and buf_chk-doc.pay-desk = buf_c-chk-doc.pay-desk
    and buf_chk-doc.chk-time = buf_c-chk-doc.chk-time
    and buf_chk-doc.chk-num = buf_c-chk-doc.chk-num
    and buf_chk-doc.sales-man = buf_c-chk-doc.sales-man NO-ERROR NO-WAIT.
   IF NOT AVAIL buf_chk-doc
   AND NOT LOCKED buf_chk-doc  AND NOT AMBIGUOUS buf_chk-doc then do:
     create buf_chk-doc.
     buffer-copy buf_c-chk-doc to buf_chk-doc.
     create buf2_c-chk-doc.
     buffer-copy buf_c-chk-doc
     except is-del chip-num
     to buf2_c-chk-doc
     assign
     buf2_c-chk-doc.is-del = ?
     buf2_c-chk-doc.chip-num = buf_c-chk-doc.chip-num + 1
     .
     for each buf_c-chk-gds no-lock where
            buf_c-chk-gds.doc-code = buf_c-chk-doc.doc-code
        and buf_c-chk-gds.chip-num = buf_c-chk-doc.chip-num
     on error undo main-block, return error:
       create buf_chk-gds.
       buffer-copy buf_c-chk-gds to buf_chk-gds.
       create buf2_c-chk-gds.
       buffer-copy buf_c-chk-gds
       except chip-num to buf2_c-chk-gds
       assign
       buf2_c-chk-gds.chip-num = buf2_c-chk-doc.chip-num
       .
     end.
     for each buf_c-chk-discnt no-lock where
            buf_c-chk-discnt.doc-code = buf_c-chk-doc.doc-code
        and buf_c-chk-discnt.chip-num = buf_c-chk-doc.chip-num
     on error undo main-block, return error:
       create buf_chk-discnt.
       buffer-copy buf_c-chk-discnt to buf_chk-discnt.
       create buf2_c-chk-discnt.
       buffer-copy buf_c-chk-discnt
       except chip-num to buf2_c-chk-discnt
       assign
       buf2_c-chk-discnt.chip-num = buf2_c-chk-doc.chip-num
       .
     end.
     for each buf_c-chk-pay no-lock where
            buf_c-chk-pay.doc-code = buf_c-chk-doc.doc-code
        and buf_c-chk-pay.chip-num = buf_c-chk-doc.chip-num
     on error undo main-block, return error:
       create buf_chk-pay.
       buffer-copy buf_c-chk-pay to buf_chk-pay.
       create buf2_c-chk-pay.
       buffer-copy buf_c-chk-pay
       except chip-num to buf2_c-chk-pay
       assign
       buf2_c-chk-pay.chip-num = buf2_c-chk-doc.chip-num
       .
     end.
     for each buf_c-marking-chk no-lock where
             buf_c-marking-chk.doc-code = buf_c-chk-doc.doc-code
         and buf_c-marking-chk.chip-num = buf_c-chk-doc.chip-num
     on error undo main-block, return error:
       create buf_marking-chk.
       buffer-copy buf_c-marking-chk to buf_marking-chk.
       create buf2_c-marking-chk.
       buffer-copy buf_c-marking-chk
       except chip-num to buf2_c-marking-chk
       assign
       buf2_c-marking-chk.chip-num = buf2_c-chk-doc.chip-num
       .
     end.
     chk-doc-attr_ :
     for each buf_c-chk-doc-attr no-lock where
            buf_c-chk-doc-attr.doc-code = buf_c-chk-doc.doc-code
        and buf_c-chk-doc-attr.chip-num = buf_c-chk-doc.chip-num
     on error undo main-block, return error:
       if num-entries(buf_c-chk-doc-attr.attr-code, chr(4)) > 1
       then do :
         if entry(1, buf_c-chk-doc-attr.attr-code, chr(4)) begins "gds="
         then do :
           find first buf_chk-gds-attr exclusive-lock where buf_chk-gds-attr.attr-code = entry(2, buf_c-chk-doc-attr.attr-code, chr(4)) and
           buf_chk-gds-attr.doc-code = buf_c-chk-doc-attr.doc-code and
           buf_chk-gds-attr.line-num = integer(entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=")) no-error .
           if not available (buf_chk-gds-attr) then do:
           create buf_chk-gds-attr.
           assign
           buf_chk-gds-attr.attr-code = entry(2, buf_c-chk-doc-attr.attr-code, chr(4))
           buf_chk-gds-attr.line-num = integer(entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "="))
           buf_chk-gds-attr.attr-value = buf_c-chk-doc-attr.attr-value
           buf_chk-gds-attr.doc-code = buf_c-chk-doc-attr.doc-code
           .
           end.
           else do:
             buf_chk-gds-attr.attr-value = buf_c-chk-doc-attr.attr-value .
           end.
           create buf2_c-chk-doc-attr.
           buffer-copy buf_c-chk-doc-attr
           except chip-num to buf2_c-chk-doc-attr
           assign
           buf2_c-chk-doc-attr.chip-num = buf2_c-chk-doc.chip-num
           .
           next chk-doc-attr_ .
         end .
         if entry(1, buf_c-chk-doc-attr.attr-code, chr(4)) begins "pay="
         then do :
           find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = entry(2, buf_c-chk-doc-attr.attr-code, chr(4)) and
           buf_chk-pay-attr.doc-code = buf_c-chk-doc-attr.doc-code and
           buf_chk-pay-attr.line-num = integer(entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=")) no-error .
           if not available (buf_chk-pay-attr) then do:
           create buf_chk-pay-attr.
           buffer-copy buf_c-chk-doc-attr to buf_chk-pay-attr
           assign
           buf_chk-pay-attr.attr-code = entry(2, buf_c-chk-doc-attr.attr-code, chr(4))
           buf_chk-pay-attr.line-num = integer(entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "="))
           buf_chk-pay-attr.doc-code = buf_c-chk-doc-attr.doc-code
           buf_chk-pay-attr.attr-value = buf_c-chk-doc-attr.attr-value
           .
           end.
           create buf2_c-chk-doc-attr.
           buffer-copy buf_c-chk-doc-attr
           except chip-num to buf2_c-chk-doc-attr
           assign
           buf2_c-chk-doc-attr.chip-num = buf2_c-chk-doc.chip-num
           .
           next chk-doc-attr_ .
         end .
         if entry(1, buf_c-chk-doc-attr.attr-code, chr(4)) begins "discnt="
         then do :
           v-discnt = entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=") .
           create buf_chk-discnt-attr.
           buffer-copy buf_c-chk-doc-attr to buf_chk-discnt-attr
           assign
           buf_chk-discnt-attr.attr-code = entry(2, buf_c-chk-doc-attr.attr-code, chr(4))
           buf_chk-discnt-attr.line-num = integer(entry(1, v-discnt, chr(3)))
           buf_chk-discnt-attr.record-type = integer(entry(2, v-discnt, chr(3)))
           buf_chk-discnt-attr.discnt-id = integer(entry(3, v-discnt, chr(3)))
           buf_chk-discnt-attr.object-line-num = integer(entry(4, v-discnt, chr(3)))
           .
           create buf2_c-chk-doc-attr.
           buffer-copy buf_c-chk-doc-attr
           except chip-num to buf2_c-chk-doc-attr
           assign
           buf2_c-chk-doc-attr.chip-num = buf2_c-chk-doc.chip-num
           .
           next chk-doc-attr_ .
         end .
       find first buf_chk-gds-attr exclusive-lock where buf_chk-gds-attr.attr-code = buf_c-chk-doc-attr.attr-code and
         buf_chk-gds-attr.doc-code = buf_c-chk-doc-attr.doc-code and
         buf_chk-pay-attr.line-num = integer(entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=")) no-error .
       if not available (buf_chk-gds-attr) then
       do:
         create buf_chk-gds-attr.
           assign
           buf_chk-gds-attr.attr-code = entry(2, buf_c-chk-doc-attr.attr-code, chr(4))
           buf_chk-pay-attr.line-num = integer(entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "="))
           buf_chk-gds-attr.attr-value = buf_c-chk-doc-attr.attr-value
           buf_chk-gds-attr.doc-code = buf_c-chk-doc-attr.doc-code
           .
       end.
       else
       do:
         buf_chk-gds-attr.attr-value = buf_c-chk-doc-attr.attr-value .
       end.
       end .
       find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.attr-code = buf_c-chk-doc-attr.attr-code and
       buf_chk-doc-attr.doc-code = buf_c-chk-doc-attr.doc-code no-error .
       if not available (buf_chk-doc-attr) then do:
       create buf_chk-doc-attr.
       buffer-copy buf_c-chk-doc-attr to buf_chk-doc-attr.
       end.
       else do:
         buf_chk-doc-attr.attr-value = buf_c-chk-doc-attr.attr-value .
       end.
       create buf2_c-chk-doc-attr.
       buffer-copy buf_c-chk-doc-attr
       except chip-num to buf2_c-chk-doc-attr
       assign
       buf2_c-chk-doc-attr.chip-num = buf2_c-chk-doc.chip-num
       .
     end.
   end.
   else do:
     undo main-block, return error substitute("Нельзя восстановить чек &1 по истории&2" +
                             "такой чек уже существует либо проверка его отсутствия не удалась"
                             , p-doc-code
                             , chr(10)).
   end.
end.
