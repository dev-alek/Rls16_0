/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подключение фильтрации / сортировки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/13/08
Author: Bakhtadze Natalya
Creation date: 03/13/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop seq {&sequence}

&if "{1}" = "defproc" &then
&if defined(fltopend_i_defproc) = 0 &then

&glob fltopend_i_defproc

define variable v-fltopend-rowid as rowid extent 18 no-undo .

procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .


  do
  on error undo, return error
  :

&if "{&flt-open-debug-file}" <> "" &then
output to {&flt-open-debug-file}.
export p-flt-open-open-query skip.
export p-where-cond skip.
export p-use-indFIRST-query-tail skip.
export p-use-ind-sort-clmn-by skip.
export p-indexed-reposition skip.
output close.

&endif


define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .

assign
v-prepare-string = p-flt-open-open-query + " where " + {&space-char} +
                   p-where-cond + {&space-char}  +
                   p-use-indFIRST-query-tail + {&space-char} +
                   p-use-ind-sort-clmn-by + {&space-char} +
                   p-indexed-reposition
.

&if "{&flt-open-debug-file}" <> "" &then
output to {&flt-open-debug-file} append.
export v-prepare-string skip.
output close.
&endif

assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.


  end.

end procedure. /* fltopend_fltopend */

procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .

define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .

do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).

  &if "{&flt-open-find-debug-file}" <> "" &then
    output to {&flt-open-find-debug-file} .
    export v-prepare-string.
    output close .
  &endif

  glog = v-qh:query-prepare(v-prepare-string) no-error.

  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end. /*doe*/
end procedure. /* fltopend_fltfindd */

procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .


define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .


do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + {&space-char} +
                    p-where-cond + {&space-char}  +
                    p-use-indFIRST-query-tail + {&space-char} +
                    p-use-ind-sort-clmn-by + {&space-char} +
                    p-indexed-reposition
  .
    &if "{&flt-open-find-debug-file}" <> "" &then
      output to {&flt-open-find-debug-file} .
      export v-prepare-string.
      output close .
    &endif

  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    /*первый next нужен для reposition*/
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end. /*doe*/
end procedure. /* fltopend_fltfindq */


&Endif
&else

&scop l-disable-where  l-disable-where-{&seq}
&scop l-filter-open    l-filter-open-{&seq}
&scop filter-rec       flt-rec-{&seq}
&scop filter-name      filter-name-{&seq}
&scop where-phrase     where-phrase-{&seq}
&scop sort-phrase      sort-phrase-{&seq}
&scop where-phrase-rus where-phrase-rus-{&seq}
&scop sort-phrase-rus  sort-phrase-rus-{&seq}

define variable  {&l-disable-where}  as logical   no-undo .
define variable  {&l-filter-open}    as logical  /* no-undo - специально сделана как undo переменная */ .
define variable  {&filter-rec}       as recid     no-undo .
define variable  {&filter-name}      as character no-undo .
define variable  {&where-phrase}     as character no-undo .
define variable  {&sort-phrase}      as character no-undo .
define variable  {&where-phrase-rus} as character no-undo .
define variable  {&sort-phrase-rus}  as character no-undo .


&if "{&flt-open-waitfram}" <> "" &then
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
&endif

run gbl/flt-get.p
  (input {&flt-open-call-point}
  ,output {&filter-rec}
  ,output {&filter-name}
  ,output {&where-phrase}
  ,output {&sort-phrase}
  ,output {&where-phrase-rus}
  ,output {&sort-phrase-rus}
  ).


&if "{&flt-open-query}" <> "" &then
if {&flt-open-query} then do:
&endif
  /* открытие query */
  &if "{&flt-open-set-filter-name}" <> "" &then
    /* устанавливаем название фильтра в окне */
    run {&flt-open-set-filter-name} in this-procedure
      (INPUT {&filter-name}
      ) no-error .
  &endif

  assign
    {&l-filter-open} = false
  .
  if {&filter-rec} <> ?
  &if "{&flt-open-sort-column-phrase}" <> "" &then
    or {&flt-open-sort-column-phrase} > ""
  &endif
  then do:
    define variable  parameter-2-{&seq} as character no-undo .
    define variable  parameter-3-{&seq} as character no-undo .
    define variable  parameter-4-{&seq} as character no-undo .
    define variable  parameter-5-{&seq} as character no-undo .
    define variable  parameter-6-{&seq} as character no-undo .
    define variable  parameter-7-{&seq} as character no-undo .
      assign
      parameter-3-{&seq} =
&if defined(flt-open-dyn_open-query-str) &then
                            {&flt-open-dyn_open-query-string}
&else
                              "{&flt-open-dyn_open-query}"
&endif
      &if defined(dyn_where-cond) = 0 &then
      &scop dyn_where-cond "~{&where-cond~}"
      &scop dyn_where-cond-flag 1
      &endif
      parameter-4-{&seq} =
        (
          if ("{&where-cond}" + " " + {&where-phrase}) <> ""
          then {&dyn_where-cond} + " " + {&where-phrase}
          else "true"
        )
      &if defined(dyn_use-indFIRST) = 0 &then
      &scop dyn_use-indFIRST "~{&use-indFIRST~}"
      &scop dyn_use-indFIRST-flag 1
      &endif
      &if defined(flt-open-dyn_open-query-tail) = 0 &then
      &scop flt-open-dyn_open-query-tail-flag 1
      &scop flt-open-dyn_open-query-tail "~{&flt-open-open-query-tail~}"
      &endif
      parameter-5-{&seq} = (" " + {&dyn_use-indFIRST} + " " + {&flt-open-dyn_open-query-tail})
      &if defined(dyn_use-ind) = 0 &then
      &scop dyn_use-ind "~{&use-ind~}"
      &scop dyn_use-ind-flag 1
      &endif
      &if defined(dyn_by) = 0 &then
      &scop dyn_by "~{&by~}"
      &scop dyn_by-flag 1
      &endif
      parameter-6-{&seq} = if {&sort-phrase} = ''
                           then
        (
        " " + {&dyn_use-ind} +
        &if "{&flt-open-sort-column-phrase}" <> "" &then
          " " + {&flt-open-sort-column-phrase} +
        &endif
        " " + {&dyn_by}
        )
                           else
        (
        " " + {&dyn_use-ind} +
        &if "{&flt-open-sort-column-phrase}" <> "" &then
          " " + {&flt-open-sort-column-phrase} +
        &endif
        " " + {&sort-phrase}
        )

      parameter-7-{&seq} =
        " {&flt-open-indexed-reposition}  "
    .
    /* обработаем ошибки компиляции */
    do
    on stop undo, leave
    on error undo, leave
    :

      assign
        {&l-disable-where} =
          ("{&where-cond}" + " " + {&where-phrase} = "")
      .

      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input {&flt-open-query-handle}
                          ,input parameter-3-{&seq}
                          ,input parameter-4-{&seq}
                          ,input parameter-5-{&seq}
                          ,input parameter-6-{&seq}
                          ,input parameter-7-{&seq}
                          )
      .

      assign
        {&l-filter-open} = true
      .
    end.

  &if "{&flt-open-debug-file}" <> "" &then
    output to {&flt-open-debug-file} .

    put unformatted
      "glog = {&flt-open-query-handle}:query-prepare (" skip
      parameter-3-{&seq}
      "where"            skip
      parameter-4-{&seq} skip
      parameter-5-{&seq} skip
      parameter-6-{&seq} skip
      parameter-7-{&seq} skip
      ")"                skip
      .
    output close .
  &endif

    if {&l-filter-open} = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
      &if "{&flt-open-query-was-opened}" <> "" &then
        /* устанавливаем признак того, что query была переоткрыта */
        assign
          {&flt-open-query-was-opened} = true
        .
      &endif
    end.
  end.

  if {&l-filter-open} = false then do:
    /* Фильтры / дополнительная сортировка не заданы
      или была ошибка при отборе записей по фильтру
    */
    {&flt-open-open-query}
    &IF "{&where-cond}" <> "" &THEN
      where {&where-cond}
    &ENDIF
    {&use-indFIRST}
    {&flt-open-open-query-tail}
      {&use-ind}
      {&by}
      {&flt-open-indexed-reposition}
  .

    &if "{&flt-open-query-was-opened}" <> "" &then
      /* устанавливаем признак того, что query была переоткрыта */
      assign
        {&flt-open-query-was-opened} = true
      .
    &endif
  end.
&if "{&flt-open-query}" <> "" &then
end.
else do:
  assign
    {&flt-open-find-recid} = recid( {&flt-open-table-name} )
  .

  /* поиск записи */
  do
  on stop undo, leave
  on error undo, leave
  :
    &if defined(flt-open-find-buffer-name) = 0 &then
      &scop flt-open-find-buffer-name ~{&flt-open-table-name~}
    &endif
    if {&flt-open-query-handle}:get-buffer-handle(1) = (buffer {&flt-open-find-buffer-name}:handle) then do:
      assign
      parameter-2-{&seq} = (if {&flt-open-find-next} then "true":u else "false":u )
      &if defined(dyn_where-cond) = 0 &then
      &scop dyn_where-cond "~{&where-cond~}"
      &scop dyn_where-cond-flag 1
      &endif
      &if defined(flt-open-dyn_find-condition) = 0 &then
      &scop flt-open-dyn_find-condition ~{&flt-open-find-condition~}
      &scop flt-open-dyn_find-condition-flag 1
      &endif
      &if defined(dyn_use-indFIRST) = 0 &then
      &scop dyn_use-indFIRST "~{&use-indFIRST~}"
      &scop dyn_use-indFIRST-flag 1
      &endif
      &if defined(dyn_use-ind) = 0 &then
      &scop dyn_use-ind "~{&use-ind~}"
      &scop dyn_use-ind-flag 1
      &endif
      parameter-4-{&seq} =
        "where ":u + {&dyn_where-cond} + " ":u + {&where-phrase} + " ":u + {&flt-open-dyn_find-condition} + " " + {&dyn_use-indFIRST}
      parameter-5-{&seq} = {&dyn_use-ind}
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input {&flt-open-query-handle}
                          ,input rowid({&flt-open-table-name})
                          ,input logical(parameter-2-{&seq})  /*(if {&flt-open-find-next} then "true":u else "false":u )*/
                          ,input {&flt-open-search-option} /*{&flt-open-search-option}*/
                          ,input (buffer {&flt-open-table-name}:handle)
                          ,input parameter-4-{&seq}  /*p-where-cond*/
                          ,input parameter-5-{&seq}  /*p-use-index-phrase*/
                          ) no-error.
      .

      assign
        {&flt-open-find-recid} = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-{&seq} = (if {&flt-open-find-next} then "true":u else "false":u )
      parameter-3-{&seq} =  "{&flt-open-dyn_open-query}"
      &if defined(dyn_where-cond) = 0 &then
      &scop dyn_where-cond "~{&where-cond~}"
      &scop dyn_where-cond-flag 1
      &endif
      parameter-4-{&seq} =
        (
          if ("{&where-cond}" + " " + {&where-phrase}) <> ""
          then {&dyn_where-cond} + " " + {&where-phrase}
          else "true"
        )
      &if defined(dyn_use-indFIRST) = 0 &then
      &scop dyn_use-indFIRST "~{&use-indFIRST~}"
      &scop dyn_use-indFIRST-flag 1
      &endif
      &if defined(flt-open-dyn_open-query-tail) = 0 &then
      &scop flt-open-dyn_open-query-tail "~{&flt-open-open-query-tail~}"
      &scop flt-open-dyn_open-query-tail-flag 1
      &endif
      parameter-5-{&seq} = (" " + {&dyn_use-indFIRST} + " " + {&flt-open-dyn_open-query-tail} + " " + {&flt-open-dyn_find-condition})
      &if defined(dyn_use-ind) = 0 &then
      &scop dyn_use-ind "~{&use-ind~}"
      &scop dyn_use-ind-flag 1
      &endif
      &if defined(dyn_by) = 0 &then
      &scop dyn_by "~{&by~}"
      &scop dyn_by-flag 1
      &endif
      parameter-6-{&seq} = if {&sort-phrase} = ''
                           then
        (
        " " + {&dyn_use-ind} +
        &if "{&flt-open-sort-column-phrase}" <> "" &then
          " " + {&flt-open-sort-column-phrase} +
        &endif
        " " + {&dyn_by}
        )
                           else
        (
        " " + {&dyn_use-ind} +
        &if "{&flt-open-sort-column-phrase}" <> "" &then
          " " + {&flt-open-sort-column-phrase} +
        &endif
        " " + {&sort-phrase}
        )

      parameter-7-{&seq} =
        " {&flt-open-indexed-reposition}  "

    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input {&flt-open-query-handle}
                          ,input logical(parameter-2-{&seq})  /*(if {&flt-open-find-next} then "true":u else "false":u )*/
                          ,input {&flt-open-search-option}
                          ,input parameter-3-{&seq}
                          ,input parameter-4-{&seq}
                          ,input parameter-5-{&seq}
                          ,input parameter-6-{&seq}
                          ,input parameter-7-{&seq}
                          ,output v-fltopend-rowid
                          ) no-error.
      .

      {&flt-open-find-recid} = ?.
    end.
    assign
      {&flt-open-query-was-opened} = true
    .
  end.
end.
&endif

&if "{&flt-open-waitfram}" <> "" &then
  run waitfram-hide in this-procedure .
&endif
&if defined(dyn_where-cond-flag) > 0 &then
&undefine dyn_where-cond
&undefine dyn_where-cond-flag
&endif
&if defined(dyn_use-indFIRST-flag) > 0 &then
&undefine dyn_use-indFIRST
&undefine dyn_use-indFIRST-flag
&endif
&if defined(dyn_use-ind-flag) > 0 &then
&undefine dyn_use-ind
&undefine dyn_use-ind-flag
&endif
&if defined(dyn_by-flag) > 0 &then
&undefine dyn_by
&undefine dyn_by-flag
&endif
&if defined(flt-open-dyn_find-condition-flag) > 0 &then
&undefine flt-open-dyn_find-condition
&undefine flt-open-dyn_find-condition-flag
&endif
&if defined(flt-open-dyn_open-query-tail-flag) > 0 &then
&undefine flt-open-dyn_open-query-tail
&undefine flt-open-dyn_open-query-tail-flag
&endif
&if defined(flt-open-dyn_open-query-string) > 0 &then
&undefine flt-open-dyn_open-query-string
&endif

&endif

/* $Workfile$ */