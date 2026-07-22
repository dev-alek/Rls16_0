block-level on error undo, throw.
/*

$Revision: f7e80aacd3fe, 2168, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:23:56 2019 +0300 $
$Workfile: rep_RC.p $
$Archive: bge/rep_RC.p $

Отчет по версиям RC на УБД

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


define variable vss-revision    as character no-undo init "$Revision: f7e80aacd3fe, 2168, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:56 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rep_RC.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/rep_RC.p $":U .
define variable vss-description as character no-undo init "Отчет по версиям RC на УБД".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ ref/shd-attr.i }
{ trg/factord.i  }
{ gbl/cur-time.i }
   &scop display-message    run write-log-and-file in p-log-handle (  ~
         input 1                                                      ~
         , input "shd-free.log"                                          ~
         , input 1                                                      ~
         , input ~{&my-message~})

define variable v-task-num   as integer   no-undo.
define variable v-param-list as character no-undo.
define variable v-param-type as character no-undo.

define buffer buf_schedule      for ub.schedule.
define buffer buf_schedule-attr for ub.schedule-attr.
define variable v-ii1        as integer   no-undo.
define variable v-ii2        as integer   no-undo.
define variable num-days     as integer   no-undo.
define variable v-db-list    as character no-undo .
define variable v-today      as date      no-undo.
define variable v-time       as integer   no-undo.
DEFINE variable v-date_from  as date      no-undo .
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
      AND buf_schedule-attr.attr-code   = ({&attr-schd-free-id} + {&delim-par} + 'rep-RC')
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
  if v-ii2 < 3 THEN 
  do:
    do v-ii1 = v-ii2 to 3:
      v-param-list = v-param-list
        + '':U
        + {&delim-par}.
    end.
  end.
  ASSIGN
    num-days     = INTEGER( ENTRY(1, v-param-list, {&delim-par}) )
    v-db-list    = ENTRY(2, v-param-list, {&delim-par}) 
    .
  run cur-time in this-procedure ( output v-today
  , output v-time
  ).
  v-date_from = v-today - num-days .            
  run rep/r-printRC.p ( INPUT parparentproc
    , INPUT v-date_from 
    , INPUT v-today
    , INPUT v-db-list
    , input no
    ) .
end.