block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление документа матценностей

Автор: Гридчина Полина Дмитриевна
Дата создания: 02/11/03
Author: Polina Gridchina
Creation date: 02/11/03

Автор1   Перваков Михаил Сергеевич
Автор2   Бахтадзе Наталья Викторовна

*/


define input  parameter p-doc-code like ub.wth-doc.doc-code no-undo .
define input  parameter parphchip-num      as   integer                      no-undo.
define input  parameter p-file-name-err    as   char                         no-undo.
define output parameter parchip-num        as   integer                      no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Удаление документа матценностей".
{ cmp/vssrevis.i "substitute('&1':u,p-doc-code)"}
{ cmp/trg-def.i }
{ str/wthparts.i }
{ str/wth-arh.i }
define buffer buf_wth-doc     for ub.wth-doc .
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_out-doc for ub.wth-doc.
define variable v-db-doc        as integer      no-undo.
define variable v-db-out-doc    as integer      no-undo.
main-block: do  transaction
on error  undo main-block, return error substitute( "&1 &2 &3&4&5&6&7", vss-workfile,vss-revision,vss-description,{&new-line}, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define variable l-shift-on      as logical   no-undo .
  define variable varobj-date     as date                      no-undo.
  define variable varshift-date   like ub.shift-obj.shift-date no-undo.
  define variable varshift-num    like ub.shift-obj.shift-num  no-undo.
  define variable varshift-name as character no-undo.

  find first buf_wth-doc exclusive-lock
    where buf_wth-doc.doc-code = p-doc-code
    no-error .
  if not available buf_wth-doc then do:
    undo, return error substitute("&1 &3 &4",
                          "Ошибка задания входных параметров."  ,
                          "Документ МЦ"  ,
                          p-doc-code).
  end.
  /*Удаление порожденных/связанных документов */
  if not g#news then do:
  /*  and buf_wth-doc.obj-type =  and buf_wth-doc.source-type = {&wthd-wth-doc} then do:*/
    if buf_wth-doc.doc-type = {&expense} and not buf_wth-doc.exter_ then do:  /*Если это внутренний расход, смотрим из одной ли базы объекты*/
        { gbl/objdbnum.i
          buf_wth-doc.obj-type
          buf_wth-doc.obj-code
          v-db-doc
        }
        { gbl/objdbnum.i
          buf_wth-doc.cli-type
          buf_wth-doc.cli-code
          v-db-out-doc
        }
        if v-db-doc <> v-db-out-doc then do:
        undo, return error   substitute("Документ создан для объектов  с разными номерам БД.&4Номер БД документа &5&4Номер БД порожденного документа  &6",
                       vss-workfile,
                       vss-revision,
                       vss-description,
                       {&new-line},
                       v-db-doc,
                       v-db-out-doc)
           .
        end.

    end.
    find first buf_out-doc no-lock where
            buf_out-doc.source-ref = buf_wth-doc.doc-code
        and buf_out-doc.source-type = {&wthd-wth-doc}
        and buf_out-doc.borned no-error.
    if available buf_out-doc then do:
  /*    message 'удаление связанного документа' view-as alert-box.   */
      if buf_out-doc.status_ <> {&fact} then do:
        undo, return error substitute('Нельзя удалять связанный документ не в статусе &1.&2Номер документа &3',
                                      {&fact},
                                      {&new-line},
                                      buf_out-doc.doc-code
                                      ).
      end.

      run trg/wthdocdl.p ( buf_out-doc.doc-code
                          ,input parphchip-num
                          ,input p-file-name-err
                          ,output parchip-num
                          ) no-error.
        if error-status:error then do:
              undo, return error return-value.
        end.
        parphchip-num =  parchip-num .
    end.      /*удаление порожденных*/
  end. /*if not g#news*/


  /* При  приеме новостей, остатки и архивы пересчиываются только в ГБД. */

  if not g#news or (g#news and  g#db-num  = 0)  then do:

      { gbl/curobjdt.i buf_wth-doc.obj-type buf_wth-doc.obj-code varobj-date no-error }
    if error-status :error
    or varobj-date = ?
    then do:
      undo, return error   "Нет текущей даты на объекте продажи".
    end.


    { gbl/objat.i
      buf_wth-doc.obj-type
      buf_wth-doc.obj-code
      "'shift-on=request'"
      l-shift-on
    }
    if l-shift-on then do:
      /* на объекте включены смены */
      { gbl/curshift.i
        buf_wth-doc.obj-type
        buf_wth-doc.obj-code
        varshift-date
        varshift-num
        varshift-name
        no-error
      }
      if error-status :error then do:
        undo, return error   "Ошибка при поиске текущей смены на объекте " .
      end.
    end.
    else do:
      assign
        varshift-date = ?
        varshift-num  = ?.
    end.
     /* блокируем МЦ на объекте */
    run trg/lock-wth.p
      (input p-doc-code                         /* v-wth-doc-doc-code     */
      ,input yes                                /* p-check-inv            */
      ,input buf_wth-doc.fact-order             /* p-document-fact-order  */
      ,input (buf_wth-doc.status_ = {&fact})    /* p-fact-close           */
      ,input g#news                             /* p-is-news              */
      ) no-error .
    if error-status :error
    then do:
      message
        "Не удалось наложить блокировку на все товары принадлежащие документу" skip
        "Документ" buf_wth-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box information .
      undo , return error .
    end.
  end.  /*g#news*/


    assign
      buf_wth-doc.is-del = true
    .
    /*создаем копию*/
    if not g#news then do:
      run hstc-wth-doc in this-procedure
        (input recid(buf_wth-doc)
        ,input varobj-date
        ,input varshift-date
        ,input varshift-num
        ,input varshift-name
        ,input g#userid
        ,input buf_wth-doc.source-ref
        ,input parphchip-num
        ,output parchip-num
        ) .
    end.

  if not g#news or (g#news and  g#db-num  = 0)  then do:
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf_chk-pay for  ub.chk-pay.
    define buffer buf_c-chk-doc for  ub.c-chk-doc.
    define buffer buf_c-chk-pay for  ub.c-chk-pay.

    /*отвязываем чеки МЦ и их историю*/
    for each buf_chk-doc exclusive-lock
      where buf_chk-doc.out-code = buf_wth-doc.doc-code
        and BUF_chk-doc.obj-type = buf_wth-doc.obj-type
        and buf_chk-doc.obj-code = buf_wth-doc.obj-code
    on error undo, return error
    :
    if  lookup(string(buf_chk-doc.chk-type),{&wth-receipt-codes} )  = 0 then next.  /*От  документов МЦ могут отвязываться только чеки МЦ*/

      for each buf_chk-pay
        where buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        assign
          buf_chk-pay.out-code = ?
        .
        if g#news then do:
          delete buf_chk-pay.
        end.
      end.
      for each buf_c-chk-doc
        where buf_c-chk-doc.doc-code = buf_c-chk-doc.doc-code
      on error undo, return error
      :
        assign
          buf_c-chk-doc.out-code = ?
        .
        if g#news then do:
          delete buf_c-chk-doc.
        end.
      end.
      for each buf_c-chk-pay
        where buf_c-chk-pay.doc-code = buf_c-chk-doc.doc-code
      on error undo, return error
      :
        assign
          buf_c-chk-pay.out-code = ?
        .
        if g#news then do:
          delete buf_c-chk-pay.
        end.
      end.
      assign
        buf_chk-doc.out-code = ?
      .
      if g#news then do:
        delete buf_chk-doc.
      end.
    end.

    /* пересчет архивов */
    run wth-arhdoc-delete in this-procedure ( buf_wth-doc.doc-code
                            )  no-error.
    if error-status :error
    then do:
      undo Main-Block, return error return-value .
    end.
  end.  /*g#news*/

  /* Проверка партий на возможность удаления*/
  if buf_wth-doc.status_ = {&fact}
  and (not g#news or (g#news and  g#db-num  = 0))
  then do:
        run str/chkwthd.p
          ( input p-doc-code
          , p-file-name-err
           ) no-error .
        if error-status :error
        then do:
          undo Main-Block, return error return-value .
        end.
  end.
   /*Обработка партий*/
   /*Удаление порожденных партий */

  for each buf_wth-parts exclusive-lock
    where buf_wth-parts.doc-code = buf_wth-doc.doc-code
    on error undo Main-Block, return error return-value:
    /*На всякий случай проверяется зона*/
    if lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) > 0 then delete buf_wth-parts.
  end.
   /*Разрезервирование партий*/

  for each buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code
    on error undo Main-Block, return error return-value:

         run wth-doc-razrez in this-procedure
          (INPUT RECID(buf_wth-parts),
           input yes
          ).

  end.


      define variable v-obj-type   as character no-undo .
      define variable v-obj-code   as integer   no-undo .
      define variable v-fact-order as decimal   no-undo .
      define variable v-doc-code     like ub.wth-doc.doc-code no-undo .
      define variable v-fact-date    like ub.wth-doc.fact-date     no-undo .
      define variable v-user-db-num  like ub.wth-doc.user-db-num   no-undo .
      define variable v-user-name    like ub.wth-doc.user-name     no-undo .
      define variable v-sys-date     like ub.wth-doc.sys-date      no-undo .
      define variable v-sys-time-int like ub.wth-doc.sys-time-int  no-undo .
      define variable v-sys-time     like ub.wth-doc.sys-time      no-undo .

      assign
        v-obj-type   = buf_wth-doc.obj-type
        v-obj-code   = buf_wth-doc.obj-code
        v-fact-order = buf_wth-doc.fact-order
        v-doc-code   = buf_wth-doc.doc-code
        v-fact-date  = buf_wth-doc.fact-date
        v-user-db-num = buf_wth-doc.user-db-num
        v-user-name   = buf_wth-doc.user-name
        v-sys-date   = buf_wth-doc.sys-date
        v-sys-time   = buf_wth-doc.sys-time
        v-sys-time-int   = buf_wth-doc.sys-time-int
      .

      delete buf_wth-doc .
   if not g#news or (g#news and  g#db-num  = 0)  then do:

      /* пересчет остатков по МЦ */
      run str/reclcwtf.p
        (input v-obj-type
        ,input v-obj-code
        ,input v-fact-order
        ,input no
        ,input {&c-wth-obj_delete}
        ,input v-doc-code
        ,input v-fact-date
        ,input v-user-db-num
        ,input v-user-name
        ,input v-sys-date
        ,input v-sys-time-int
        ,input v-sys-time
        ) .
    end.

  end.


procedure hstc-wth-doc :

  define input parameter parrec-wth-doc as   recid                 no-undo.
  define input parameter parobj-date    as   date                    no-undo.
  define input parameter parshift-date  like ub.shift-obj.shift-date no-undo.
  define input parameter parshift-num   like ub.shift-obj.shift-num  no-undo.
  define input parameter parshift-name  like ub.shift-obj.shift-name no-undo.
  define input parameter paruserid      as   character               no-undo.
  define input parameter parout-code    like ub.wth-doc.source-ref   no-undo.
  define input  parameter parphchip-num      as   integer                      no-undo.
  define output parameter parchip-num        as   integer                      no-undo.


  define buffer hstc_wth-doc          for ub.wth-doc.
  define buffer hstc_wth-line         for ub.wth-line.
  define buffer hstc_wth-dtl          for ub.wth-dtl.
  define buffer hstc_wth-parts        for ub.wth-parts.
  define buffer hstc_c-wth-doc        for ub.c-wth-doc.
  define buffer hstc_c-wth-line       for ub.c-wth-line.
  define buffer hstc_c-wth-dtl        for ub.c-wth-dtl.
  define buffer hstc_c-wth-parts      for ub.c-wth-parts.
  define buffer hstc_inkas-pay-wth    for ub.inkas-pay-wth.
  define buffer hstc_c-inkas-pay-wth  for ub.c-inkas-pay-wth.

  do
  on error undo, return error return-value
  :

    find first hstc_wth-doc
      where recid (hstc_wth-doc) = parrec-wth-doc
      .
    create hstc_c-wth-doc .
    buffer-copy hstc_wth-doc to hstc_c-wth-doc .
    assign
      hstc_c-wth-doc.chip-num        = (if parphchip-num <> ?
                                       then parphchip-num
                                       else next-value(s-corr-chip, {&db-name_schema}))
      hstc_c-wth-doc.corr-inkas-code = buf_wth-doc.source-ref
      hstc_c-wth-doc.corr-date       = parobj-date
      hstc_c-wth-doc.corr-shift-date = parshift-date
      hstc_c-wth-doc.corr-shift-num  = parshift-num
      hstc_c-wth-doc.corr-shift-name  = parshift-name
      hstc_c-wth-doc.corr-user-name        = paruserid
      hstc_c-wth-doc.corr-user-db-num = g#db-num
    .
    for each hstc_wth-line
      where hstc_wth-line.doc-code = hstc_wth-doc.doc-code
    on error undo, return error
    :
      create hstc_c-wth-line.
      buffer-copy hstc_wth-line to hstc_c-wth-line.
      assign
      hstc_c-wth-line.corr-user-db-num = hstc_c-wth-doc.corr-user-db-num
      hstc_c-wth-line.chip-num = hstc_c-wth-doc.chip-num
      .
    end.
    for each hstc_wth-dtl
      where hstc_wth-dtl.doc-code = hstc_wth-doc.doc-code
    on error undo, return error
    :
      create hstc_c-wth-dtl.
      buffer-copy hstc_wth-dtl to hstc_c-wth-dtl.
      assign
      hstc_c-wth-dtl.corr-user-db-num = hstc_c-wth-doc.corr-user-db-num
      hstc_c-wth-dtl.chip-num = hstc_c-wth-doc.chip-num
      .
    end.
    for each hstc_wth-parts
      where hstc_wth-parts.out-code = hstc_wth-doc.doc-code
    on error undo, return error
    :
      create hstc_c-wth-parts.
      buffer-copy hstc_wth-parts to hstc_c-wth-parts.
      assign
      hstc_c-wth-parts.corr-user-db-num = hstc_c-wth-doc.corr-user-db-num
      hstc_c-wth-parts.chip-num = hstc_c-wth-doc.chip-num
      .
    end.
    for each hstc_inkas-pay-wth where
            hstc_inkas-pay-wth.inkas-code = hstc_wth-doc.doc-code
    on error undo, return error
            :
      create hstc_c-inkas-pay-wth.
      buffer-copy hstc_inkas-pay-wth to hstc_c-inkas-pay-wth.
      assign
        hstc_c-inkas-pay-wth.chip-num = hstc_c-wth-doc.chip-num
        hstc_c-inkas-pay-wth.corr-user-db-num = hstc_c-wth-doc.corr-user-db-num
        .
    end.
    assign
    parchip-num = hstc_c-wth-doc.chip-num
    .
  end.

end procedure.