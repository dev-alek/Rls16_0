block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-auto as integer no-undo .
define input parameter p-inkas-code as character no-undo .
define output parameter p-continue as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salechpe.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salechpe.p $":U .
define variable vss-description as character no-undo init "Проверки при закрытии продажи если установлена опция close-day-period,".
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
define  new shared  temp-table doc-list no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.
define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   new shared   temp-table doc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable v-host-code as integer no-undo .
define variable glog as logical no-undo .
define variable log-file-name as character no-undo .
define variable v-view-log  as logical no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable p-parent-handle as handle no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_inkas for ub.inkas.
define buffer buf_fbr-doc for ub.fbr-doc.
find first buf_inkas no-lock where
        buf_inkas.inkas-code = p-inkas-code no-error.
if not available buf_inkas then do:
  undo, return error substitute("Не найдена продажа &1", p-inkas-code).
end.
if p-auto = 0 then do:
  log-file-name = 'saleclos.log' .
end.
else do:
  log-file-name = 'ext-sale.log'.
end.
run get-doc-list in this-procedure no-error.
if can-find(first doc-list)  then do:
  case p-auto:
    when 0
    or
    when 1
    then do:
      message
      substitute("Согласно настройкам закрытие продажи ведет к закрытию периода до даты &1,&2" +
                 "Однако на Вашем объекте имеются еще незакрытые документы&2" +
                 "После закрытия продажи эти документы могут быть закрыты только следующим периодом&2&2" +
                 "Ознакомтесь со списком незакрытых документов"
                , (buf_inkas.doc-date +  1)
                , chr(10)
                )
      view-as alert-box warning.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output v-host-code
  )  .
      run str/doc-list.w (
                    input parparentproc
                    ,input v-host-code
                    ,input buf_inkas.obj-type
                    ,input buf_inkas.obj-code
                    ) no-error.
      if error-status:error then do:
                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Ошибка при проверке наличия незакрытых документов")                                       ).
        return error.
      end.
      else do:
        message
        substitute("Продолжить закрытие продажи невзирая на открытые документы?")
        view-as alert-box question buttons yes-no update glog.
        if glog then do:
          run get-doc-list in this-procedure no-error.
          if can-find(first doc-list) then do:
                        run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("При закрытии продажи на объекте имелись незакрытые документы!")                                       ).
            p-continue = yes.
            return.
          end.
        end.
      end.
    end.
    when 2 then do:
            run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Согласно настройкам закрытие продажи ведет к закрытию периода до даты &1,&2" +                  "Однако на объекте имеются еще незакрытые документы&2" +                  "Закрытие продажи НЕВОЗМОЖНО!"                 , (buf_inkas.doc-date +  1)                 , chr(10)                 )                                       ).
    end.
  end case.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе закрытия продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action4   as character no-undo .
  define variable v-printed4       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе закрытия продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'saleclos.log')
    ,input  7
    ,output v-user-action4
    ,output v-printed4
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'saleclos.log').
end.
  return "error":U.
end.
else do:
  p-continue = yes.
end.
procedure get-doc-list :
for each doc-list :
  delete doc-list.
end.
for each buf_trn-doc no-lock where
        buf_trn-doc.obj-type = buf_inkas.obj-type
    and buf_trn-doc.obj-code = buf_inkas.obj-code
    and (buf_trn-doc.status_ = 'накл':U
    or
       buf_trn-doc.status_ = 'разрешен':U
    or buf_trn-doc.status_ = 'прво':U
       )
    and buf_trn-doc.doc-date <= buf_inkas.doc-date
    :
  if buf_trn-doc.doc-code = p-inkas-code then next.
  if buf_trn-doc.out-code = p-inkas-code then next.
  if buf_trn-doc.doc-type = 'инв':U then do:
    next.
  end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = buf_trn-doc.doc-code
    and doc-list.doc-type = buf_trn-doc.doc-type
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  create doc-list .
  assign
  doc-list.doc-code   = buf_trn-doc.doc-code
  doc-list.obj-type   = buf_trn-doc.obj-type
  doc-list.obj-code   = buf_trn-doc.obj-code
  doc-list.fact-num   = buf_trn-doc.fact-num
  doc-list.doc-date   = buf_trn-doc.doc-date
  doc-list.fact-date  = buf_trn-doc.fact-date
  doc-list.shift-date = buf_trn-doc.shift-date
  doc-list.shift-num  = buf_trn-doc.shift-num
  doc-list.fact-order = buf_trn-doc.fact-order
  doc-list.is-trn-doc = yes
  doc-list.is-del     = no
  doc-list.doc-type   = buf_trn-doc.doc-type
  doc-list.ext-doc-type   = buf_trn-doc.ext-doc-type
  doc-list.znak       = if can-do ('рас,спи':U, doc-list.doc-type) then -1 else 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
end.
for each buf_trn-doc no-lock where
        buf_trn-doc.obj-type = buf_inkas.obj-type
    and buf_trn-doc.obj-code = buf_inkas.obj-code
    and buf_trn-doc.doc-type = 'инв':U
    and buf_inkas.fact-date <= buf_Inkas.doc-date
    and (buf_trn-doc.status_ = 'накл':U
        or  buf_trn-doc.status_ = 'разрешен':U ):
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = buf_trn-doc.doc-code
    and doc-list.doc-type = buf_trn-doc.doc-type
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  create doc-list .
  assign
  doc-list.doc-code   = buf_trn-doc.doc-code
  doc-list.obj-type   = buf_trn-doc.obj-type
  doc-list.obj-code   = buf_trn-doc.obj-code
  doc-list.fact-num   = buf_trn-doc.fact-num
  doc-list.doc-date   = buf_trn-doc.doc-date
  doc-list.fact-date  = buf_trn-doc.fact-date
  doc-list.shift-date = buf_trn-doc.shift-date
  doc-list.shift-num  = buf_trn-doc.shift-num
  doc-list.fact-order = buf_trn-doc.fact-order
  doc-list.is-trn-doc = yes
  doc-list.is-del     = no
  doc-list.doc-type   = buf_trn-doc.doc-type
  doc-list.ext-doc-type   = buf_trn-doc.ext-doc-type
  doc-list.znak       = if can-do ('рас,спи':U, doc-list.doc-type) then -1 else 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
end.
for each buf_fbr-doc no-lock where
        buf_fbr-doc.obj-type = buf_inkas.obj-type
    and buf_fbr-doc.obj-code = buf_inkas.obj-code
    and (buf_fbr-doc.status_ = 'разрешен':U
    or buf_fbr-doc.status_ = 'новый':U)
    and buf_fbr-doc.doc-date <= buf_inkas.doc-date:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = buf_fbr-doc.doc-code
    and doc-list.doc-type = 'производство':U
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  create doc-list .
  assign
  doc-list.doc-code   = buf_fbr-doc.doc-code
  doc-list.obj-type   = buf_fbr-doc.obj-type
  doc-list.obj-code   = buf_fbr-doc.obj-code
  doc-list.fact-num   = 0
  doc-list.fact-date  = buf_fbr-doc.fact-date
  doc-list.shift-date = buf_fbr-doc.shift-date
  doc-list.shift-num  = buf_fbr-doc.shift-num
  doc-list.fact-order = 0
  doc-list.is-trn-doc = no
  doc-list.doc-type   = 'производство':U
  doc-list.ext-doc-type   = 'производство':U
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
end.
end procedure.
