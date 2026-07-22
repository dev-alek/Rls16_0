block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: salemake.p $
$Archive: str/salemake.p $

Создание продаж по шаблонам при работе по расписанию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/05
Author: Bakhtadze Natalya
Creation date: 03/24/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-task-num    like ub.schedule.task-num no-undo .
*/

define variable p-curr-obj-type    like ub.clients.obj-type no-undo .
define variable p-curr-obj-code    like ub.clients.obj-code no-undo .
define variable p-cre-db-num       like ub.schedule.cre-db-num no-undo .
define variable p-task-type        like ub.schedule.task-type no-undo .
define variable p-task-num         like ub.schedule.task-num no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salemake.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salemake.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-curr-obj-type,p-curr-obj-code,p-cre-db-num,p-task-type,p-task-num)" }
{ cmp/trg-def.i  }
{ str/trdcalib.i }
{ ref/shd-attr.i }
{ gbl/cur-time.i }
{ cmp/strcodec.i }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ str/cre-sale.i }

define variable v-input-error as logical no-undo .
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable log-file-name as character no-undo init 'ext-sale.log'.

define shared temp-table temp-inkas no-undo like ub.inkas.

&scop display-message   run write-log-and-file in p-log-handle (                             ~
                                                                  input 1                    ~
                                                                , input log-file-name        ~
                                                                , input 1                    ~
                                                                , input ~{&my-message~})


if num-entries(p-parameter, {&delim-par}) <> 5
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 5"
                             , num-entries(p-parameter, {&delim-par})).
  .
end.
else do:
  assign
  p-curr-obj-type = entry(1, p-parameter, {&delim-par})
  p-curr-obj-code = integer(entry(2, p-parameter, {&delim-par}))
  p-cre-db-num    = integer(entry(3, p-parameter, {&delim-par}))
  p-task-type     = entry(4, p-parameter, {&delim-par})
  p-task-num      = integer(entry(5, p-parameter, {&delim-par}))
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.

if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  return.
end.

run proc-main in this-procedure no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при создании продаж по шаблонам - задача &1 &2&3:&4&5 &6"
                         , p-task-num
                         ,  p-curr-obj-type
                         ,  p-curr-obj-code
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
  return "error":U.
end.


procedure proc-main :
define variable v-shift-date-str as character no-undo.
define variable v-shift-date-str-rus as character no-undo.
define variable v-shift-date     as date no-undo .
define variable v-shift-num      as integer no-undo.
define variable v-filter-str     as character no-undo .
define variable v-filter-str-rus as character no-undo .
define variable v-filter-name    as character no-undo .
define variable v-create         as logical no-undo .
DEFINE VARIABLE v-time           as integer no-undo .
define variable v-dop            as character no-undo .
define variable v-dop1           as character no-undo .
define variable v-dop2           as character no-undo .
define variable v-dop3           as character no-undo .
define variable v-dop-int        as integer   no-undo .
define variable v-today          as date      no-undo .
define variable v-filter-on      as logical no-undo .
define variable cas-shft         as logical no-undo .
define variable conf-attr        as character no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par         as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-type         as character no-undo.
define variable v-where-phrase   as character no-undo .
define variable v-where-phrase-rus as character no-undo .
define variable v-rid            as recid no-undo .



define buffer buf_schedule-attr for ub.schedule-attr.
define buffer buf2_schedule-attr for ub.schedule-attr.
define buffer buf_inkas for ub.inkas.
define buffer buf_doc-attr for ub.doc-attr.


  do
  on error undo, return error return-value
  :

    run cur-time in this-procedure (output v-today, output v-time).
    { gbl/cas-shft.i p-curr-obj-type p-curr-obj-code cas-shft }
    _buf_schedule-attr:
    for each buf_schedule-attr where
            buf_schedule-attr.cre-db-num = p-cre-db-num
        AND buf_schedule-attr.task-type = {&btpr-type-autosale}
        AND buf_schedule-attr.task-num = p-task-num
        and buf_schedule-attr.attr-code begins ({&attr-schedule-date-list-h} + {&delim-par}):
       find first buf2_schedule-attr no-lock where
            buf2_schedule-attr.cre-db-num = p-cre-db-num
        AND buf2_schedule-attr.task-type = {&btpr-type-autosale}
        AND buf2_schedule-attr.task-num = p-task-num
        and buf2_schedule-attr.attr-code =
           ({&attr-schedule-filter-h} + {&delim-par} +
           string(integer(entry(2, buf_schedule-attr.attr-code, {&delim-par})))
           ) no-error.
       assign
       v-create = no
       v-filter-str = "":U
       v-filter-str-rus = "":U
       v-where-phrase = "":U
       v-where-phrase-rus = "":U
       v-filter-name      = "":U
       .
&scop my-message substitute("!!!Ошибка при получении параметров даты и номера смены в шаблоне создания продажи:&1" + ~
                             "&2 &3"                                                                                 ~
                             , ~{&new-line~}                                                                         ~
                             , error-status:get-message(1)                                                           ~
                             , return-value )

       assign
       v-shift-date-str = entry(1, (entry(1, buf_schedule-attr.attr-value, {&delim-par})))
       v-shift-date-str-rus = entry(1, (entry(2, buf_schedule-attr.attr-value, {&delim-par})))
       v-shift-num      = integer(entry(2, (entry(1, buf_schedule-attr.attr-value, {&delim-par}))))
       v-filter-name    = entry(3, buf_schedule-attr.attr-value, {&delim-par})
       no-error .
       if error-status:error then do:
          assign
          v-view-log = yes.
         {&display-message}.
         next _buf_schedule-attr.
       end.

      IF INDEX (v-shift-date-str, "today") = 0  THEN DO:
        v-dop = str-decode(v-shift-date-str, "":U).
        ASSIGN
        v-dop = substring(v-dop, 6)
        v-dop = TRIM(v-dop, ")")
        v-dop1 = ENTRY(1, v-dop, {&comma-char})
        v-dop2 = ENTRY(2, v-dop, {&comma-char})
        v-dop3 = ENTRY(3, v-dop, {&comma-char}).
        v-shift-date = DATE( INTEGER(v-dop1),
                        INTEGER(v-dop2),
                        INTEGER(v-dop3)
                      )
        no-error
        .
      END.
      else do:
        assign
        v-dop = replace(v-shift-date-str, "today", "":U)
        v-dop = replace(v-dop, "(", "":U)
        v-dop = replace(v-dop, ")", "":U)
        v-dop-int = integer(trim(v-dop))
        v-shift-date = v-today + v-dop-int
        no-error
        .
      end.
      if error-status:error then do:
        assign
        v-view-log = yes.
        {&display-message}.
        next _buf_schedule-attr.
      end.
      if available buf2_schedule-attr then do:
         assign
         v-filter-str  = entry(1, buf2_schedule-attr.attr-value, {&delim-par})
         v-filter-str-rus  = entry(2, buf2_schedule-attr.attr-value, {&delim-par})
         .
      end.
      v-create = yes.
      _inkas:
      for each buf_Inkas no-lock where
                 buf_inkas.obj-type = p-curr-obj-type
             AND buf_inkas.obj-code = p-curr-obj-code
             and buf_inkas.shift-date = v-shift-date
             and (cas-shft = no or buf_inkas.shift-num = v-shift-num)
             and buf_inkas.status_ = {&g___new} :
        if v-filter-str <> "":U then do:
          assign
          v-where-phrase = buf_inkas.sale-filter
          v-where-phrase-rus = buf_Inkas.sale-filter-rus
          .
          if trim(v-where-phrase) = trim(v-filter-str)  then v-create = no.
       end.
       else do:
          v-create = no.
       end.
       if v-create = no then leave _inkas.
      end. /*for each buf_inkas*/
      if v-create then do:
        run cre-docs in this-procedure (
                                         input 2 /*p-auto*/
                                        ,input p-curr-obj-type
                                        ,input p-curr-obj-code
                                        ,input v-shift-date
                                        ,input (if cas-shft then v-shift-num else 0)
                                        ,input v-filter-name
                                        ,input v-filter-str
                                        ,input v-filter-str-rus
                                        ,input {&cash-desk}
                                        ,output v-rid
                                      ) no-error .
        if error-status:error then do:
&scop my-message substitute("Ошибка при создании отчета о продаже по шаблону <&1> с параметрами:&2" + ~
                            "&3&4 дата смены &5 № смены &6&2" +                                ~
                            "ДОП. фильтр по чекам &7:&2"                                       ~
                            , entry(3, buf_schedule-attr.attr-value, ~{&delim-par~})           ~
                            , ~{&new-line~}                                                    ~
                            , p-curr-obj-type                                                  ~
                            , p-curr-obj-code                                                  ~
                            , v-shift-date-str-rus                                             ~
                            , v-shift-num                                                      ~
                            , v-filter-str-rus) +                                              ~
                 substitute("&1 &2", error-status:get-message(1), return-value )
          v-view-log = yes.
          {&display-message}.
          NEXT _buf_schedule-attr.
        end.
        find first buf_Inkas no-lock where
                  recid(buf_inkas) = v-rid .
        create temp-inkas.
        buffer-copy buf_inkas to temp-inkas.
&scop   my-message       substitute("Создан документ продажи &1 по шаблону <&2> с параметрами:&3" + ~
                            "&4 дата смены &5 № смены &6&3" +                                ~
                            "ДОП. фильтр по чекам &7&3"                                        ~
                            , temp-inkas.inkas-code                                            ~
                            , entry(3, buf_schedule-attr.attr-value, ~{&delim-par~})           ~
                            , ~{&new-line~}                                                    ~
                            , p-curr-obj-type + string(p-curr-obj-code)                        ~
                            , v-shift-date-str-rus                                             ~
                            , v-shift-num                                                      ~
                            , v-filter-str-rus)

        {&display-message}.
      end.
      else do:
&scop my-message substitute("Не будет создан документ продажи по шаблону <&1> с параметрами:&2" + ~
                            "&3&4 дата смены &5 № смены &6&2" +                                ~
                            "ДОП. фильтр по чекам &7&2" +                                     ~
                            "Уже есть документ продажи с такими параметрами"                    ~
                            , entry(3, buf_schedule-attr.attr-value, ~{&delim-par~})           ~
                            , ~{&new-line~}                                                    ~
                            , p-curr-obj-type                                                  ~
                            , p-curr-obj-code                                                  ~
                            , v-shift-date-str-rus                                             ~
                            , v-shift-num                                                      ~
                            , v-filter-str-rus)

        assign
        v-view-log = yes.
        {&display-message}.
        NEXT _buf_schedule-attr.
      end.

    end. /*for each buf_schedule-attr where*/
  end. /*doe*/

end procedure. /* main */