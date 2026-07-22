block-level on error undo, throw.
/*

$Revision: b2fe6a1e76c0, 2098, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:23:51 2019 +0300 $
$Workfile: help-road.p $
$Archive: bge/help-road.p $

Выгрузка реализации банковских продуктов

Автор: Белоусов Илья Александрович
Дата создания: 03/25/09
Author: Ilia Belousov
Creation date: 03/25/09

*/
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-db-num-char    as character    no-undo.
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define input parameter p-db-num         as integer      no-undo .


define variable vss-revision    as character no-undo init "$Revision: b2fe6a1e76c0, 2098, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:51 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: help-road.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/help-road.p $":U .
define variable vss-description as character no-undo init "Выгрузка реализации банковских продуктов".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ rep/exp-help-road.i}
{ ref/shd-attr.i }
{ trg/factord.i  }
{ ref/extclass.i }

   &scop display-message    run write-log-and-file in p-log-handle (  ~
         input 1                                                      ~
         , input "shd-free.log"                                          ~
         , input 1                                                      ~
         , input ~{&my-message~})

define variable v-task-num   as integer   no-undo.
define variable v-param-list as character no-undo.
define variable v-param-type as character no-undo.
define variable v-obj-list   as character no-undo.
define variable v-oss-list   as character no-undo.
define variable v-gds-list   as character no-undo.
define variable v-ii1        as integer   no-undo.
define variable v-ii2        as integer   no-undo.
define variable vRadio-set-1 as integer   no-undo.
define variable vRadio-set-2 as integer   no-undo.
define variable vRadio-set-3 as integer   no-undo.
define variable num-days     as integer   no-undo.

define buffer buf_tt-obj        for tt-obj.
define buffer buf_tt-oss-ref    for tt-oss-ref.
define buffer buf_tt-gds-list   for tt-gds-list.

define buffer buf_schedule      for ub.schedule.
define buffer buf_schedule-attr for ub.schedule-attr.

define variable v-folder   as character no-undo .
define variable v-file     as character no-undo .
define variable v-par-val  as character no-undo .
define variable v-par-type as character no-undo .

do
  on error undo, return error
  :
  if p-task-num > 0
    then 
  do:
    v-task-num = p-task-num.
  end.
  else 
  do:
    for each buf_schedule
      where buf_schedule.task-type     = p-task-type
      AND buf_schedule.cre-db-num    = INTEGER(p-db-num-char)
      no-lock
      ,
      first buf_schedule-attr
      where buf_schedule-attr.task-type   = p-task-type
      AND buf_schedule-attr.cre-db-num  = INTEGER(p-db-num-char)
      AND buf_schedule-attr.task-num    = buf_schedule.task-num
      AND buf_schedule-attr.attr-code   = ({&attr-schd-free-id} + {&delim-par} + 'help-road')
      no-lock
      :
      ASSIGN
        v-task-num = buf_schedule.task-num
        .
      leave .
    end.
  end.
  if v-task-num > 0
    then 
  do:
    run schedule-attr-value in this-procedure  ( input p-db-num-char
      , input p-task-type
      , input v-task-num
      , input {&attr-schedule-param-list-h}
      , output v-param-list
      , output v-param-type
      ) NO-ERROR .
  end.
  v-ii2 = num-entries( v-param-list, {&delim-par} ).
  if v-ii2 < 7 THEN 
  do:
    do v-ii1 = v-ii2 to 7:
      v-param-list = v-param-list
        + '':U
        + {&delim-par}.
    end.
  end.
  ASSIGN
    v-folder     = ENTRY(1, v-param-list, {&delim-par})
    v-file       = ENTRY(2, v-param-list, {&delim-par})
    vRadio-set-1 = INTEGER( ENTRY(3, v-param-list, {&delim-par}) )
    vRadio-set-2 = INTEGER( ENTRY(4, v-param-list, {&delim-par}) )
    vRadio-set-3 = INTEGER( ENTRY(5, v-param-list, {&delim-par}) )
    num-days     = INTEGER( ENTRY(6, v-param-list, {&delim-par}) )
    .
              
  EMPTY TEMP-TABLE buf_tt-obj.
  if v-task-num > 0 then
    run schedule-attr-value in this-procedure  ( input p-db-num-char
      , input p-task-type
      , input v-task-num
      , input {&attr-schedule-obj-list-h}
      , output v-obj-list
      , output v-param-type
      ) NO-ERROR .
  define variable ii      as integer   no-undo.
  define variable v-entry as character no-undo .

  do ii = 1 to num-entries(v-obj-list, {&delim-par})
    on error undo, next
    :
    assign
      v-entry = entry(ii, v-obj-list, {&delim-par})
      .
    FIND FIRST ub.clients
      WHERE ub.clients.obj-type = ENTRY(1, v-entry, {&comma-char})
      AND ub.clients.obj-code = INTEGER(ENTRY(2, v-entry, {&comma-char}))
      NO-LOCK
      NO-ERROR
      .
    IF AVAILABLE ub.clients
      THEN
    DO:
      create tt-obj.
      ASSIGN
        tt-obj.obj-code  = ub.clients.obj-code
        tt-obj.obj-type  = ub.clients.obj-type
        tt-obj.obj-name  = ub.clients.obj-name
        tt-obj.host-code = ub.clients.host-code
        .
    END.
  end.
 
  EMPTY TEMP-TABLE buf_tt-oss-ref.
  if v-task-num > 0 then
    run schedule-attr-value in this-procedure  ( input p-db-num-char
      , input p-task-type
      , input v-task-num
      , input {&attr-schedule-oss-list-h}
      , output v-oss-list
      , output v-param-type
      ) NO-ERROR .
  define variable ii-oss      as integer   no-undo.
  define variable v-entry-oss as character no-undo .

  do ii-oss = 1 to num-entries(v-oss-list, {&delim-par})
    on error undo, next
    :
    assign
      v-entry-oss = entry(ii-oss, v-oss-list, {&delim-par})
      .
    Find first ub.OperServ
      WHERE ub.OperServ.id = INTEGER(ENTRY(1, v-entry-oss, {&comma-char}))
      NO-LOCK no-error .
    if available (ub.OperServ) then 
    do:              
      CREATE tt-oss-ref.
      buffer-copy ub.OperServ to tt-oss-ref .
    END.
  end.
    
    
  EMPTY TEMP-TABLE buf_tt-gds-list.
  if v-task-num > 0 then
    run schedule-attr-value in this-procedure  ( input p-db-num-char
      , input p-task-type
      , input v-task-num
      , input {&attr-schedule-gds-list-h}
      , output v-gds-list
      , output v-param-type
      ) NO-ERROR .
  define variable ii-gds      as integer   no-undo.
  define variable v-entry-gds as character no-undo .

  do ii-gds = 1 to num-entries(v-gds-list, {&delim-par})
    on error undo, next
    :
    assign
      v-entry-gds = entry(ii-gds, v-gds-list, {&delim-par})
      .
    find first ub.goods-attr no-lock
      where ub.goods-attr.attr-code  = {&attr-oper-serv-id} 
      and ub.goods-attr.gds-code = INTEGER(ENTRY(1, v-entry-gds, {&comma-char})) 
      no-error . 
    if available (ub.goods-attr) then 
    do:
      find first ub.goods no-lock where ub.goods-attr.gds-code = ub.goods.gds-code no-error .
      if available (ub.goods) then 
      do:
        CREATE tt-gds-list.
        ASSIGN
          tt-gds-list.artic     = ub.goods.artic
          tt-gds-list.gds-code  = ub.goods.gds-code
          tt-gds-list.gds-name  = ub.goods.gds-name
          tt-gds-list.prod-code = ub.goods.prod-code
          tt-gds-list.prod-type = ub.goods.prod-type
          .
      end.
    end.
  end.
 
  run rep/r-help-road.p ( INPUT num-days
    , INPUT v-folder
    , INPUT v-file
    , INPUT ?
    , INPUT ?
    , INPUT ""
    , INPUT ""
    , INPUT p-log-handle
    , INPUT TABLE tt-obj
    , INPUT TABLE tt-oss-ref
    , INPUT TABLE tt-gds-list
    ) .
end.