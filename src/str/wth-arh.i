/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для расчета архива по серийным МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 08/01/07
Author: Polina Gridchina
Creation date: 08/01/07

Input:

Output:

*/
{ cmp/str-glbl.i }
define temp-table tt-parts-cli    no-undo like ub.arh-wth-cli
 .

define temp-table tt-parts-cli-tot    no-undo like ub.arh-wth-cli-tot
/*  field qnty     as int
  field sum-rubl like ub.wth-line.sum-gds-rubl
  field sum-base like ub.wth-line.sum-gds-base*/ .

define temp-table tt-parts-cli-doc no-undo like ub.arh-wth-cli-doc
/*  field qnty as int
  field sum-rubl like ub.wth-line.sum-gds-rubl
  field sum-base like ub.wth-line.sum-gds-base*/.

define temp-table tt-parts-tot    no-undo like ub.arh-wth-tot.
define temp-table tt-parts-wp     no-undo like ub.arh-wth-w-p.


define buffer buf-prev_arh-wth-cli   for ub.arh-wth-cli.
define buffer buf-arh-wth-cli        for ub.arh-wth-cli.
define buffer buf-recalc-cli         for ub.arh-wth-cli.
define buffer buf-prev_arh-wth-cli-doc   for ub.arh-wth-cli-doc.
define buffer buf-arh-wth-cli-doc    for ub.arh-wth-cli-doc.
define buffer buf-recalc-cli-doc     for ub.arh-wth-cli-doc.
define buffer buf-prev_arh-wth-tot   for ub.arh-wth-tot.
define buffer buf-arh-wth-tot        for ub.arh-wth-tot.
define buffer buf-recalc-tot         for ub.arh-wth-tot.
define buffer buf-prev_arh-wth-wp    for ub.arh-wth-w-p.
define buffer buf-arh-wth-wp         for ub.arh-wth-w-p.
define buffer buf-recalc-wp          for ub.arh-wth-w-p.
define buffer buf-arh_wth-doc        for ub.wth-doc.
define buffer buf-prev_arh-wth-cli-tot   for ub.arh-wth-cli-tot.
define buffer buf-arh-wth-cli-tot        for ub.arh-wth-cli-tot.
define buffer buf-recalc-cli-tot         for ub.arh-wth-cli-tot.

&SCOPE  psum-tt-arh    if buf-arh_wth-doc.doc-type = {&income} or (buf-arh_wth-doc.doc-type = {&exchange} and  buf_wth-parts.type = {&income}) or  buf_wth-parts.type = {&return} then  ~
    assign tt-parts-tot.in-qnty     = tt-parts-tot.in-qnty     + buf_wth-parts.fact-qnty ~
           tt-parts-tot.in-sum-rubl = tt-parts-tot.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl~
           tt-parts-tot.in-sum-base = tt-parts-tot.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .~
    else   assign tt-parts-tot.out-qnty  = tt-parts-tot.out-qnty + buf_wth-parts.fact-qnty                    ~
           tt-parts-tot.out-sum-rubl = tt-parts-tot.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl ~
           tt-parts-tot.out-sum-base = tt-parts-tot.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  . ~


procedure wth-arh-mode:
  define input  parameter parext-doc-type like ub.wth-doc.ext-doc-type no-undo.
  define input  parameter pardoc-code like ub.wth-doc.doc-code no-undo.
  define output parameter parinc-exp      as   integer                 no-undo.
  define buffer buf_wth-parts   for ub.wth-parts.
                                                            /*надо определить типы по которым вообще не считаются архивы*/
  case parext-doc-type:
    when {&WDEDT_Exp_Ext}
    or when {&WDEDT_Put_Cash}
    or when {&WDEDT_Put_Sale}
    or when {&WDEDT_Put_Cli}
    or when {&WDEDT_Dst_Cli}
    or when {&WDEDT_Exch}
    then do:
      if can-find(first buf_wth-parts where buf_wth-parts.out-code = pardoc-code)
      then parinc-exp = 1. /*по клиентам*/
      else parinc-exp = 0.
    end.
/*    when {&WDEDT_Inc_Ext}
    or when {&WDEDT_Exp_Ext}
    or when {&WDEDT_Inc_Int}
    or when {&WDEDT_Exp_Int}
    or when {&WDEDT_Inc_Obj}
    or when {&WDEDT_Exp_Obj}
    or when {&WDEDT_Ret_Int}
    or when {&WDEDT_Dst}
    then do:
      if can-find(first buf_wth-parts where buf_wth-parts.out-code = pardoc-code)
      then parinc-exp = 2. /*мц на объекте*/
      else parinc-exp = 0.
    end.    */
  end case.

end procedure.  /*wth-arh-mode*/

 procedure wth-arh-calctt-loc:      /*Заполнение временных консолидированных таблиц и локирование архивов*/
  define input parameter pardoc-code as char no-undo.
  define input parameter par-lock as log no-undo.
  define var vararh-mode as int no-undo.
  define buffer buf_wth-parts   for ub.wth-parts.
  define variable v-cli-type    as character    no-undo.
  define variable v-cli-code    as integer      no-undo.
  define variable v-zone        as character    no-undo.

  do on error undo, return error substitute ("Создание архивов по документу &4 &1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2),pardoc-code) :
  find first buf-arh_wth-doc where buf-arh_wth-doc.doc-code = pardoc-code no-lock no-error.
  if not available buf-arh_wth-doc then do:
    return error substitute ("Не найден документ МЦ с номером &1.", pardoc-code).
  end.
  run wth-arh-mode(input buf-arh_wth-doc.ext-doc-type
          ,input buf-arh_wth-doc.doc-code
          ,output vararh-mode).
  empty temp-table tt-parts-cli.
  empty temp-table tt-parts-cli-tot.
  empty temp-table tt-parts-wp.
  empty temp-table tt-parts-cli-doc.
  empty temp-table tt-parts-tot   .
  for each buf_wth-parts no-lock where
           buf_wth-parts.out-code = pardoc-code
       and buf_wth-parts.stts = 0 :
   if  not g#news                 /* Итоговый архив по МЦ по объектам других баз считается только в ГБД */
       or (g#news and  g#db-num  = 0)
   then do:
      find first tt-parts-tot where
                tt-parts-tot.wth-code = buf_wth-parts.wth-code
            and tt-parts-tot.par-code = buf_wth-parts.par-code
            /*and tt-parts-tot.gds-code = buf_wth-parts.gds-code*/
            and tt-parts-tot.obj-type = buf_wth-parts.obj-type
            and tt-parts-tot.obj-code = buf_wth-parts.obj-code
            and tt-parts-tot.ext-doc-type = buf_wth-parts.ext-doc-type
          /*  and tt-parts-tot.w-p-code = buf_wth-parts.w-p-code*/
            and tt-parts-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
            no-error.
      if not available tt-parts-tot then do:
        create tt-parts-tot.
        assign tt-parts-tot.wth-code = buf_wth-parts.wth-code
              tt-parts-tot.par-code = buf_wth-parts.par-code
              tt-parts-tot.gds-code = buf_wth-parts.gds-code
              tt-parts-tot.w-p-code = buf_wth-parts.w-p-code
              tt-parts-tot.obj-type = buf_wth-parts.obj-type
              tt-parts-tot.obj-code = buf_wth-parts.obj-code
              tt-parts-tot.ext-doc-type = buf_wth-parts.ext-doc-type
              tt-parts-tot.doc-code = buf_wth-parts.out-code
              tt-parts-tot.host-code = buf_wth-parts.host-code
              tt-parts-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
      {&psum-tt-arh}

      /* Баланс по МХ */

      if lookup(buf-arh_wth-doc.ext-doc-type,{&WDEDT_SUM_Free-in}) > 0
      or (buf-arh_wth-doc.ext-doc-type = {&WDEDT_exch}  and buf_wth-parts.type = {&expense})
      or lookup (buf-arh_wth-doc.ext-doc-type,{&WDEDT_SUM_Free-Out}) > 0 then
      v-zone = {&free-code}.
      else if lookup(buf-arh_wth-doc.ext-doc-type,{&WDEDT_SUM_Put-In}) > 0
      or (buf-arh_wth-doc.ext-doc-type = {&WDEDT_exch}  and buf_wth-parts.type = {&income})
      or lookup (buf-arh_wth-doc.ext-doc-type,{&WDEDT_SUM_Put-Out}) > 0 then
      v-zone = {&put-zone}.
      if v-zone = {&free-code} or  v-zone = {&put-zone} then do:
        find first tt-parts-wp where
                  tt-parts-wp.obj-type = buf_wth-parts.obj-type
              and tt-parts-wp.obj-code = buf_wth-parts.obj-code
              and tt-parts-wp.w-p-code = buf_wth-parts.w-p-code
              and tt-parts-wp.wth-code = buf_wth-parts.wth-code
              and tt-parts-wp.par-code = buf_wth-parts.par-code
              and tt-parts-wp.out-code = v-zone
            /*  and tt-parts-wp.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type*/
              no-error.
        if not available tt-parts-wp then do:
          create tt-parts-wp.
          assign tt-parts-wp.wth-code = buf_wth-parts.wth-code
                tt-parts-wp.par-code = buf_wth-parts.par-code
                tt-parts-wp.gds-code = buf_wth-parts.gds-code
                tt-parts-wp.w-p-code = buf_wth-parts.w-p-code
                tt-parts-wp.obj-type = buf_wth-parts.obj-type
                tt-parts-wp.obj-code = buf_wth-parts.obj-code
                tt-parts-wp.out-code = v-zone
                tt-parts-wp.ext-doc-type = buf_wth-parts.ext-doc-type
                tt-parts-wp.doc-code = buf_wth-parts.out-code
                tt-parts-wp.host-code = buf_wth-parts.host-code
             /*   tt-parts-wp.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type*/
          .
        end.
        if buf-arh_wth-doc.doc-type = {&income} or (buf-arh_wth-doc.doc-type = {&exchange} and  buf_wth-parts.type = {&income}) then
        { str/arhtsum.i tt-parts-wp }
     /*   message tt-parts-wp.in-qnty   tt-parts-wp.out-qnty  buf_wth-parts.type buf_wth-parts.fact-qnty view-as alert-box.*/
      end.
    end.
    if vararh-mode = 1 then do:
      if buf_wth-parts.in-code = {&forged} then
      assign v-cli-type = '':U
             v-cli-code = 0.
      else assign v-cli-type = buf_wth-parts.cli-type
             v-cli-code = buf_wth-parts.cli-code.
      find first tt-parts-cli where
                tt-parts-cli.wth-code = buf_wth-parts.wth-code
            and tt-parts-cli.par-code = buf_wth-parts.par-code
            and tt-parts-cli.ser-code = buf_wth-parts.ser-code
            and tt-parts-cli.db-num   = buf_wth-parts.db-num
            and tt-parts-cli.cli-type = v-cli-type
            and tt-parts-cli.cli-code = v-cli-code
            and tt-parts-cli.obj-type = buf_wth-parts.obj-type
            and tt-parts-cli.obj-code = buf_wth-parts.obj-code
            and tt-parts-cli.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-cli.gds-code = buf_wth-parts.gds-code
            and tt-parts-cli.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
            no-error.
      if not available tt-parts-cli then do:
        create tt-parts-cli.
        assign tt-parts-cli.wth-code = buf_wth-parts.wth-code
              tt-parts-cli.par-code = buf_wth-parts.par-code
              tt-parts-cli.ser-code = buf_wth-parts.ser-code
              tt-parts-cli.db-num   = buf_wth-parts.db-num
              tt-parts-cli.cli-type = v-cli-type
              tt-parts-cli.cli-code = v-cli-code
              tt-parts-cli.obj-type = buf_wth-parts.obj-type
              tt-parts-cli.obj-code = buf_wth-parts.obj-code
              tt-parts-cli.doc-code  = buf_wth-parts.out-code
              tt-parts-cli.ext-doc-type = buf_wth-parts.ext-doc-type
              tt-parts-cli.gds-code = buf_wth-parts.gds-code
              tt-parts-cli.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
    if buf-arh_wth-doc.doc-type = {&income}
    or buf-arh_wth-doc.doc-type = {&return}
    or (buf-arh_wth-doc.doc-type = {&exchange} and buf_wth-parts.type = {&income})
    then
    { str/arhtsum.i tt-parts-cli }




      find first tt-parts-cli-doc where    /*детальный по покупателю*/
                tt-parts-cli-doc.wth-code = buf_wth-parts.wth-code
            and tt-parts-cli-doc.par-code = buf_wth-parts.par-code
            and tt-parts-cli-doc.cli-type = v-cli-type
            and tt-parts-cli-doc.cli-code = v-cli-code
            and tt-parts-cli-doc.host-code = buf_wth-parts.host-code
            and tt-parts-cli-doc.contract-code = buf_wth-parts.contract-code
            and tt-parts-cli-doc.gds-code = buf_wth-parts.gds-code
            and tt-parts-cli-doc.obj-type = buf_wth-parts.obj-type
            and tt-parts-cli-doc.obj-code = buf_wth-parts.obj-code
            and tt-parts-cli-doc.w-p-code = buf_wth-parts.w-p-code
            and tt-parts-cli-doc.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-cli-doc.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
            no-error.
      if not available tt-parts-cli-doc then do:
        create tt-parts-cli-doc.
        buffer-copy buf_wth-parts using wth-code
                                        par-code
                                        host-code
                                        contract-code
                                        gds-code
                                        obj-type
                                        obj-code
                                        w-p-code
                                        ext-doc-type
                    to tt-parts-cli-doc.
        assign tt-parts-cli-doc.doc-code = buf_wth-parts.out-code
               tt-parts-cli-doc.cli-code = v-cli-code
               tt-parts-cli-doc.cli-type = v-cli-type
               tt-parts-cli-doc.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .

      end.

      if buf-arh_wth-doc.doc-type = {&income}
      or buf-arh_wth-doc.doc-type = {&return}
      or (buf-arh_wth-doc.doc-type = {&exchange} and buf_wth-parts.type = {&income} )
      then
      { str/arhtsum.i tt-parts-cli-doc }



      find first tt-parts-cli-tot where    /*итоговый по покупателю*/
                tt-parts-cli-tot.cli-type = v-cli-type
            and tt-parts-cli-tot.cli-code = v-cli-code
            and tt-parts-cli-tot.obj-type = buf_wth-parts.obj-type
            and tt-parts-cli-tot.obj-code = buf_wth-parts.obj-code
           /* and tt-parts-cli-tot.host-code = buf_wth-parts.host-code */
            and tt-parts-cli-tot.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-cli-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
      no-error.
      if not available tt-parts-cli-tot then do:
        create tt-parts-cli-tot.
        assign tt-parts-cli-tot.cli-type = v-cli-type
              tt-parts-cli-tot.cli-code  = v-cli-code
              tt-parts-cli-tot.obj-type  = buf_wth-parts.obj-type
              tt-parts-cli-tot.obj-code  = buf_wth-parts.obj-code
              tt-parts-cli-tot.doc-code  = buf_wth-parts.out-code
              tt-parts-cli-tot.host-code = buf_wth-parts.host-code
              tt-parts-cli-tot.ext-doc-type = buf_wth-parts.ext-doc-type
              tt-parts-cli-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
      if buf-arh_wth-doc.doc-type = {&income}
      or buf-arh_wth-doc.doc-type = {&return}
      or (buf-arh_wth-doc.doc-type = {&exchange} and buf_wth-parts.type = {&income} )
      then
      assign tt-parts-cli-tot.in-qnty     = tt-parts-cli-tot.in-qnty     + buf_wth-parts.fact-qnty
            tt-parts-cli-tot.in-sum-rubl = tt-parts-cli-tot.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
            tt-parts-cli-tot.in-sum-base = tt-parts-cli-tot.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
      else   assign tt-parts-cli-tot.out-qnty = tt-parts-cli-tot.out-qnty  + buf_wth-parts.fact-qnty
            tt-parts-cli-tot.out-sum-rubl = tt-parts-cli-tot.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
            tt-parts-cli-tot.out-sum-base = tt-parts-cli-tot.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .

    end.
  end.
  /*локирование архивов*/
  if par-lock then do:
    for each tt-parts-tot:
      find last   buf-arh-wth-tot exclusive-lock  where
                  buf-arh-wth-tot.wth-code =  tt-parts-tot.wth-code
              and buf-arh-wth-tot.par-code =  tt-parts-tot.par-code
              and buf-arh-wth-tot.obj-type = tt-parts-tot.obj-type
              and buf-arh-wth-tot.obj-code = tt-parts-tot.obj-code
              and buf-arh-wth-tot.ext-doc-type = tt-parts-tot.ext-doc-type
              and buf-arh-wth-tot.sum-type = tt-parts-tot.sum-type     no-error.
      if not available buf-arh-wth-tot then do:
        create buf-arh-wth-tot.
        buffer-copy tt-parts-tot using
                    wth-code
                    par-code
                    gds-code
                    obj-type
                    obj-code
                    w-p-code
                    sum-type
                    ext-doc-type
        to buf-arh-wth-tot.
      end.
    end.
    for each tt-parts-wp:
      find last   buf-arh-wth-wp exclusive-lock  where
                  buf-arh-wth-wp.wth-code =  tt-parts-wp.wth-code
              and buf-arh-wth-wp.par-code =  tt-parts-wp.par-code
              and buf-arh-wth-wp.obj-type = tt-parts-wp.obj-type
              and buf-arh-wth-wp.obj-code = tt-parts-wp.obj-code
              and buf-arh-wth-wp.w-p-code = tt-parts-wp.w-p-code
              and buf-arh-wth-wp.out-code = tt-parts-wp.out-code     no-error.
      if not available buf-arh-wth-wp then do:
        create buf-arh-wth-wp.
        buffer-copy tt-parts-wp using
                    wth-code
                    par-code
                    gds-code
                    obj-type
                    obj-code
                    w-p-code
                    doc-code
                    out-code
                    ext-doc-type
        to buf-arh-wth-wp.
      end.
    end.

    for each tt-parts-cli:
      find last  buf-arh-wth-cli exclusive-lock where
                 buf-arh-wth-cli.wth-code =  tt-parts-cli.wth-code
            and  buf-arh-wth-cli.par-code =  tt-parts-cli.par-code
            and  buf-arh-wth-cli.ser-code =  tt-parts-cli.ser-code
            and  buf-arh-wth-cli.db-num   =  tt-parts-cli.db-num
            and  buf-arh-wth-cli.cli-type =  tt-parts-cli.cli-type
            and  buf-arh-wth-cli.cli-code =  tt-parts-cli.cli-code
            and  buf-arh-wth-cli.obj-type =  tt-parts-cli.obj-type
            and  buf-arh-wth-cli.obj-code =  tt-parts-cli.obj-code
            and  buf-arh-wth-cli.sum-type = tt-parts-cli.sum-type
            and  buf-arh-wth-cli.ext-doc-type =  tt-parts-cli.ext-doc-type
            and  buf-arh-wth-cli.gds-code =  tt-parts-cli.gds-code
             no-error.
      if not available buf-arh-wth-cli then do:
        create buf-arh-wth-cli.
        buffer-copy tt-parts-cli using wth-code
                                       sum-type
                                       par-code
                                       ser-code
                                       db-num
                                       cli-type
                                       cli-code
                                       obj-type
                                       obj-code
                                       ext-doc-type
                                       gds-code to buf-arh-wth-cli.
      end.
    /*  message tt-parts-cli.ext-doc-type 'arh-cli'.   */
    end.
    for each tt-parts-cli-doc:
      find last buf-arh-wth-cli-doc exclusive-lock  where
                 buf-arh-wth-cli-doc.wth-code = tt-parts-cli-doc.wth-code
            and  buf-arh-wth-cli-doc.par-code = tt-parts-cli-doc.par-code
            and  buf-arh-wth-cli-doc.cli-type = tt-parts-cli-doc.cli-type
            and  buf-arh-wth-cli-doc.cli-code = tt-parts-cli-doc.cli-code
            and  buf-arh-wth-cli-doc.host-code     = tt-parts-cli-doc.host-code
            and  buf-arh-wth-cli-doc.contract-code = tt-parts-cli-doc.contract-code
            and  buf-arh-wth-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
            and  buf-arh-wth-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
            and  buf-arh-wth-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
            and  buf-arh-wth-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
            and  buf-arh-wth-cli-doc.sum-type      = tt-parts-cli-doc.sum-type
            and  buf-arh-wth-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
            no-error.
      if not available buf-arh-wth-cli-doc then do:
        create buf-arh-wth-cli-doc.
        buffer-copy tt-parts-cli-doc using
                    wth-code
                    par-code
                    cli-type
                    cli-code
                    host-code
                    contract-code
                    gds-code
                    obj-type
                    obj-code
                    w-p-code
                    ext-doc-type
                    sum-type
                    to buf-arh-wth-cli-doc.
      end.

    end.
    for each tt-parts-cli-tot:

      find last  buf-arh-wth-cli-tot exclusive-lock where
                 buf-arh-wth-cli-tot.cli-type =  tt-parts-cli-tot.cli-type
            and  buf-arh-wth-cli-tot.cli-code =  tt-parts-cli-tot.cli-code
            and  buf-arh-wth-cli-tot.obj-type =  tt-parts-cli-tot.obj-type
            and  buf-arh-wth-cli-tot.obj-code =  tt-parts-cli-tot.obj-code
            /*and  buf-arh-wth-cli-tot.host-code =  tt-parts-cli-tot.host-code*/
            and  buf-arh-wth-cli-tot.sum-type = tt-parts-cli-tot.sum-type
            and  buf-arh-wth-cli-tot.ext-doc-type =  tt-parts-cli-tot.ext-doc-type
      no-error.
      if not available buf-arh-wth-cli-tot then do:
        create buf-arh-wth-cli-tot.
        buffer-copy tt-parts-cli-tot using cli-type sum-type cli-code obj-type obj-code ext-doc-type host-code to buf-arh-wth-cli-tot.
      end.
    end.

  end.  /*par-lock*/
  end.      /*error*/
 end procedure.  /*wth-arh-calctt*/

 procedure wth-arhdoc-close:  /*Расчет архивов*/
 define input parameter pardoc-code as char no-undo.
 define variable vararh-mode  as integer      no-undo.
/* message 'Расчет архивов' view-as alert-box.   */
  do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  find first buf-arh_wth-doc where buf-arh_wth-doc.doc-code = pardoc-code no-lock no-error.
  if not available buf-arh_wth-doc then do:
    return error substitute ("Не найден документ МЦ с номером &1.", pardoc-code).
  end.
  run wth-arh-mode(input buf-arh_wth-doc.ext-doc-type
          ,input buf-arh_wth-doc.doc-code
          ,output vararh-mode).
  /*if vararh-mode = 0 then return.*/
  if buf-arh_wth-doc.status_ <> {&fact} then do:
    return error substitute ("Документ МЦ с номером &1 не в статусе факт. Создание архивов невозможно.", pardoc-code).
  end.
  if buf-arh_wth-doc.fact-order = 0 or
    buf-arh_wth-doc.fact-order = ? then do:
    return error substitute ("В документе МЦ с номером &1 не проставлен fact-order.", buf-arh_wth-doc.doc-code).
  end.
  if  not g#news                 /* Итоговый архив по МЦ по объектам других баз считается только в ГБД */
       or (g#news and  g#db-num  = 0)
  then do:
    for each  tt-parts-tot on error undo, return error:
        find last  buf-prev_arh-wth-tot where buf-prev_arh-wth-tot.wth-code =  tt-parts-tot.wth-code
                                          and buf-prev_arh-wth-tot.par-code =  tt-parts-tot.par-code
                                          and buf-prev_arh-wth-tot.obj-type = tt-parts-tot.obj-type
                                          and buf-prev_arh-wth-tot.obj-code = tt-parts-tot.obj-code
                                          and buf-prev_arh-wth-tot.ext-doc-type = tt-parts-tot.ext-doc-type
                                         /* and buf-prev_arh-wth-tot.w-p-code = tt-parts-tot.w-p-code*/
                                          and buf-prev_arh-wth-tot.sum-type = tt-parts-tot.sum-type
                                          and buf-prev_arh-wth-tot.fact-order < buf-arh_wth-doc.fact-order
                                          no-error.
/*        if not available buf-prev_arh-wth-tot then do:
          return error substitute('Не найдена запись архива по номиналам МЦ, код МЦ &1, код номинала &2, МХ &3,расшир. тип &4.'
                                ,tt-parts-tot.wth-code
                                ,tt-parts-tot.par-code
                                ,tt-parts-tot.w-p-code
                                ,tt-parts-tot.ext-doc-type)  .
        end. */

        if available buf-prev_arh-wth-tot and buf-prev_arh-wth-tot.fact-order = 0 then do:
            /*заполняем заглушку, созданную при локировании*/
            find first buf-arh-wth-tot where recid(buf-arh-wth-tot) = recid(buf-prev_arh-wth-tot) exclusive-lock.

        end.
        else do:
          create buf-arh-wth-tot.
          buffer-copy tt-parts-tot to buf-arh-wth-tot .
        end.
        assign  buf-arh-wth-tot.doc-code = buf-arh_wth-doc.doc-code
                buf-arh-wth-tot.fact-order = buf-arh_wth-doc.fact-order
                buf-arh-wth-tot.in-qnty     = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.in-qnty  else 0)    + tt-parts-tot.in-qnty
                buf-arh-wth-tot.in-sum-rubl = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.in-sum-rubl else 0) + tt-parts-tot.in-sum-rubl
                buf-arh-wth-tot.in-sum-base = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.in-sum-base else 0) + tt-parts-tot.in-sum-base
                buf-arh-wth-tot.out-qnty    = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.out-qnty else 0)    + tt-parts-tot.out-qnty
                buf-arh-wth-tot.out-sum-rubl = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.out-sum-rubl else 0) + tt-parts-tot.out-sum-rubl
                buf-arh-wth-tot.out-sum-base = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.out-sum-base else 0) + tt-parts-tot.out-sum-base
                .
         /*  message   buf-arh-wth-tot.in-qnty     buf-arh-wth-tot.out-qnty  view-as alert-box.*/
        /*Пересчет архивов*/
        for each buf-recalc-tot where buf-recalc-tot.fact-order > buf-arh_wth-doc.fact-order
              and buf-recalc-tot.wth-code = tt-parts-tot.wth-code
              and buf-recalc-tot.par-code = tt-parts-tot.par-code
              and buf-recalc-tot.obj-type = tt-parts-tot.obj-type
              and buf-recalc-tot.obj-code = tt-parts-tot.obj-code
              and buf-recalc-tot.ext-doc-type = tt-parts-tot.ext-doc-type
             /* and buf-recalc-tot.w-p-code = tt-parts-tot.w-p-code*/
              and buf-recalc-tot.sum-type = tt-parts-tot.sum-type
              on error undo, return error :

              assign buf-recalc-tot.out-qnty    = buf-recalc-tot.out-qnty     + tt-parts-tot.out-qnty
                    buf-recalc-tot.out-sum-rubl = buf-recalc-tot.out-sum-rubl + tt-parts-tot.out-sum-rubl
                    buf-recalc-tot.out-sum-base = buf-recalc-tot.out-sum-base + tt-parts-tot.out-sum-base
                    buf-recalc-tot.in-qnty      = buf-recalc-tot.in-qnty    + tt-parts-tot.in-qnty
                    buf-recalc-tot.in-sum-rubl = buf-recalc-tot.in-sum-rubl + tt-parts-tot.in-sum-rubl
                    buf-recalc-tot.in-sum-base = buf-recalc-tot.in-sum-base + tt-parts-tot.in-sum-base
                    .

        end.
     end.
     for each  tt-parts-wp on error undo, return error:
        find last  buf-prev_arh-wth-wp where buf-prev_arh-wth-wp.wth-code  = tt-parts-wp.wth-code
                                          and buf-prev_arh-wth-wp.par-code = tt-parts-wp.par-code
                                          and buf-prev_arh-wth-wp.obj-type = tt-parts-wp.obj-type
                                          and buf-prev_arh-wth-wp.obj-code = tt-parts-wp.obj-code
                                          and buf-prev_arh-wth-wp.out-code = tt-parts-wp.out-code
                                          and buf-prev_arh-wth-wp.w-p-code = tt-parts-wp.w-p-code
                                          /*and buf-prev_arh-wth-wp.sum-type = tt-parts-wp.sum-type*/
                                          and buf-prev_arh-wth-wp.fact-order < buf-arh_wth-doc.fact-order
                                          no-error.

        if available buf-prev_arh-wth-wp and buf-prev_arh-wth-wp.fact-order = 0 then do:
            /*заполняем заглушку, созданную при локировании*/
            find first buf-arh-wth-wp where recid(buf-arh-wth-wp) = recid(buf-prev_arh-wth-wp) exclusive-lock.

        end.
        else do:
          create buf-arh-wth-wp.
          buffer-copy tt-parts-wp to buf-arh-wth-wp .
        end.
        assign  buf-arh-wth-wp.doc-code = buf-arh_wth-doc.doc-code
                buf-arh-wth-wp.fact-order = buf-arh_wth-doc.fact-order
                buf-arh-wth-wp.ext-doc-type = buf-arh_wth-doc.ext-doc-type
                buf-arh-wth-wp.in-qnty     = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.in-qnty  else 0)    + tt-parts-wp.in-qnty
                buf-arh-wth-wp.in-sum-rubl = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.in-sum-rubl else 0) + tt-parts-wp.in-sum-rubl
                buf-arh-wth-wp.in-sum-base = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.in-sum-base else 0) + tt-parts-wp.in-sum-base
                buf-arh-wth-wp.out-qnty    = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.out-qnty else 0)    + tt-parts-wp.out-qnty
                buf-arh-wth-wp.out-sum-rubl = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.out-sum-rubl else 0) + tt-parts-wp.out-sum-rubl
                buf-arh-wth-wp.out-sum-base = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.out-sum-base else 0) + tt-parts-wp.out-sum-base
                .

        /*Пересчет архивов*/
        for each buf-recalc-wp where buf-recalc-wp.fact-order > buf-arh_wth-doc.fact-order
              and buf-recalc-wp.wth-code = tt-parts-wp.wth-code
              and buf-recalc-wp.par-code = tt-parts-wp.par-code
              and buf-recalc-wp.obj-type = tt-parts-wp.obj-type
              and buf-recalc-wp.obj-code = tt-parts-wp.obj-code
              and buf-recalc-wp.out-code = tt-parts-wp.out-code
              and buf-recalc-wp.w-p-code = tt-parts-wp.w-p-code
              and buf-recalc-wp.sum-type = tt-parts-wp.sum-type
              on error undo, return error :

              assign buf-recalc-wp.out-qnty    = buf-recalc-wp.out-qnty     + tt-parts-wp.out-qnty
                    buf-recalc-wp.out-sum-rubl = buf-recalc-wp.out-sum-rubl + tt-parts-wp.out-sum-rubl
                    buf-recalc-wp.out-sum-base = buf-recalc-wp.out-sum-base + tt-parts-wp.out-sum-base
                    buf-recalc-wp.in-qnty      = buf-recalc-wp.in-qnty    + tt-parts-wp.in-qnty
                    buf-recalc-wp.in-sum-rubl = buf-recalc-wp.in-sum-rubl + tt-parts-wp.in-sum-rubl
                    buf-recalc-wp.in-sum-base = buf-recalc-wp.in-sum-base + tt-parts-wp.in-sum-base
                    .

        end.
     end.

  end.
  if vararh-mode = 1 then do: /*Создание архивов по клиентам*/
    for each  tt-parts-cli on error undo, return error:
      find last  buf-prev_arh-wth-cli where  buf-prev_arh-wth-cli.wth-code =  tt-parts-cli.wth-code
                                        and  buf-prev_arh-wth-cli.par-code =  tt-parts-cli.par-code
                                        and  buf-prev_arh-wth-cli.ser-code =  tt-parts-cli.ser-code
                                        and  buf-prev_arh-wth-cli.db-num   =  tt-parts-cli.db-num
                                        and  buf-prev_arh-wth-cli.cli-type =  tt-parts-cli.cli-type
                                        and  buf-prev_arh-wth-cli.cli-code =  tt-parts-cli.cli-code
                                        and  buf-prev_arh-wth-cli.obj-type =  tt-parts-cli.obj-type
                                        and  buf-prev_arh-wth-cli.obj-code =  tt-parts-cli.obj-code
                                        and  buf-prev_arh-wth-cli.ext-doc-type =  tt-parts-cli.ext-doc-type
                                        and  buf-prev_arh-wth-cli.gds-code =  tt-parts-cli.gds-code
                                        and  buf-prev_arh-wth-cli.sum-type = tt-parts-cli.sum-type
                                        and  buf-prev_arh-wth-cli.fact-order < buf-arh_wth-doc.fact-order
                                        no-error.
/*      if not available buf-prev_arh-wth-cli then do:
        return error substitute('Не найдена запись архива по покупателю &1 &2,код МЦ &3, код номинала &4.'
                               ,tt-parts-cli.cli-type
                               ,tt-parts-cli.cli-code
                               ,tt-parts-cli.wth-code
                               ,tt-parts-cli.par-code)  .
      end. */
      if available buf-prev_arh-wth-cli and buf-prev_arh-wth-cli.fact-order = 0 then do:
          /*заполняем заглушку, созданную при локировании*/
          find first buf-arh-wth-cli where recid(buf-arh-wth-cli) = recid(buf-prev_arh-wth-cli) exclusive-lock.

      end.
      else do:
        create buf-arh-wth-cli.
        buffer-copy tt-parts-cli to buf-arh-wth-cli .
      end.
      assign  buf-arh-wth-cli.doc-code   = buf-arh_wth-doc.doc-code
              buf-arh-wth-cli.fact-order = buf-arh_wth-doc.fact-order
      .
      if available buf-prev_arh-wth-cli then do:
        assign buf-arh-wth-cli.out-qnty =  buf-prev_arh-wth-cli.out-qnty  + tt-parts-cli.out-qnty
               buf-arh-wth-cli.out-sum-rubl = buf-prev_arh-wth-cli.out-sum-rubl + tt-parts-cli.out-sum-rubl
               buf-arh-wth-cli.out-sum-base = buf-prev_arh-wth-cli.out-sum-base + tt-parts-cli.out-sum-base
               buf-arh-wth-cli.in-qnty = buf-prev_arh-wth-cli.in-qnty + tt-parts-cli.in-qnty
               buf-arh-wth-cli.in-sum-rubl = buf-prev_arh-wth-cli.in-sum-rubl + tt-parts-cli.in-sum-rubl
               buf-arh-wth-cli.in-sum-base = buf-prev_arh-wth-cli.in-sum-base + tt-parts-cli.in-sum-base
               .
      end.
      else do:
        assign buf-arh-wth-cli.out-qnty =  tt-parts-cli.out-qnty
               buf-arh-wth-cli.out-sum-rubl = tt-parts-cli.out-sum-rubl
               buf-arh-wth-cli.out-sum-base = tt-parts-cli.out-sum-base
               buf-arh-wth-cli.in-qnty =  tt-parts-cli.in-qnty
               buf-arh-wth-cli.in-sum-rubl =  tt-parts-cli.in-sum-rubl
               buf-arh-wth-cli.in-sum-base =  tt-parts-cli.in-sum-base
               .
      end.
            /*Пересчет архивов*/
      for each buf-recalc-cli where buf-recalc-cli.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-cli.wth-code = tt-parts-cli.wth-code
            and buf-recalc-cli.par-code = tt-parts-cli.par-code
            and buf-recalc-cli.ser-code = tt-parts-cli.ser-code
            and buf-recalc-cli.db-num   = tt-parts-cli.db-num
            and buf-recalc-cli.cli-type = tt-parts-cli.cli-type
            and buf-recalc-cli.cli-code = tt-parts-cli.cli-code
            and buf-recalc-cli.obj-type = tt-parts-cli.obj-type
            and buf-recalc-cli.obj-code = tt-parts-cli.obj-code
            and buf-recalc-cli.ext-doc-type = tt-parts-cli.ext-doc-type
            and buf-recalc-cli.sum-type = tt-parts-cli.sum-type
            and buf-recalc-cli.gds-code = tt-parts-cli.gds-code
            on error undo, return error:

            assign buf-recalc-cli.out-qnty     = buf-recalc-cli.out-qnty + tt-parts-cli.out-qnty
                  buf-recalc-cli.out-sum-rubl = buf-recalc-cli.out-sum-rubl + tt-parts-cli.out-sum-rubl
                  buf-recalc-cli.out-sum-base = buf-recalc-cli.out-sum-base + tt-parts-cli.out-sum-base
                  buf-recalc-cli.in-qnty       = buf-recalc-cli.in-qnty + tt-parts-cli.in-qnty
                  buf-recalc-cli.in-sum-rubl  = buf-recalc-cli.in-sum-rubl + tt-parts-cli.in-sum-rubl
                  buf-recalc-cli.in-sum-base  = buf-recalc-cli.in-sum-base + tt-parts-cli.in-sum-base
              .
      end.
    end.  /*tt-part-cli*/
/*Расширенный по клиент-номинал*/
    for each  tt-parts-cli-doc on error undo, return error:
      find last buf-prev_arh-wth-cli-doc where buf-prev_arh-wth-cli-doc.wth-code =  tt-parts-cli-doc.wth-code
                                        and  buf-prev_arh-wth-cli-doc.par-code = tt-parts-cli-doc.par-code
                                        and  buf-prev_arh-wth-cli-doc.cli-type = tt-parts-cli-doc.cli-type
                                        and  buf-prev_arh-wth-cli-doc.cli-code = tt-parts-cli-doc.cli-code
                                        and  buf-prev_arh-wth-cli-doc.host-code     = tt-parts-cli-doc.host-code
                                        and  buf-prev_arh-wth-cli-doc.contract-code = tt-parts-cli-doc.contract-code
                                        and  buf-prev_arh-wth-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
                                        and  buf-prev_arh-wth-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
                                        and  buf-prev_arh-wth-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
                                        and  buf-prev_arh-wth-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
                                        and  buf-prev_arh-wth-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
                                        and  buf-prev_arh-wth-cli-doc.sum-type = tt-parts-cli-doc.sum-type
                                        and  buf-prev_arh-wth-cli-doc.fact-order < buf-arh_wth-doc.fact-order
                                        no-error.
/*      if not available buf-prev_arh-wth-cli-doc then do:
        return error substitute('Не найдена запись детального архива по покупателю &1 &2,код МЦ &3, код номинала &4, МХ &5,расшир. тип &6'
                               ,tt-parts-cli-doc.cli-type
                               ,tt-parts-cli-doc.cli-code
                               ,tt-parts-cli-doc.wth-code
                               ,tt-parts-cli-doc.par-code
                               ,tt-parts-cli-doc.w-p-code
                               ,tt-parts-cli-doc.ext-doc-type).
      end. */
      if available buf-prev_arh-wth-cli-doc and buf-prev_arh-wth-cli-doc.fact-order = 0 then do:
          /*заполняем заглушку, созданную при локировании*/
          find first buf-arh-wth-cli-doc where recid(buf-arh-wth-cli-doc) = recid(buf-prev_arh-wth-cli-doc) exclusive-lock.

      end.
      else do:
        create buf-arh-wth-cli-doc.
        buffer-copy tt-parts-cli-doc to buf-arh-wth-cli-doc .
      end.
      assign  buf-arh-wth-cli-doc.doc-code = buf-arh_wth-doc.doc-code
              buf-arh-wth-cli-doc.fact-order = buf-arh_wth-doc.fact-order
      .
      if available buf-prev_arh-wth-cli-doc then
        assign buf-arh-wth-cli-doc.out-qnty = buf-prev_arh-wth-cli-doc.out-qnty + tt-parts-cli-doc.out-qnty
               buf-arh-wth-cli-doc.out-sum-rubl = buf-prev_arh-wth-cli-doc.out-sum-rubl + tt-parts-cli-doc.out-sum-rubl
               buf-arh-wth-cli-doc.out-sum-base = buf-prev_arh-wth-cli-doc.out-sum-base + tt-parts-cli-doc.out-sum-base
               buf-arh-wth-cli-doc.in-qnty = buf-prev_arh-wth-cli-doc.in-qnty + tt-parts-cli-doc.in-qnty
               buf-arh-wth-cli-doc.in-sum-rubl = buf-prev_arh-wth-cli-doc.in-sum-rubl + tt-parts-cli-doc.in-sum-rubl
               buf-arh-wth-cli-doc.in-sum-base = buf-prev_arh-wth-cli-doc.in-sum-base + tt-parts-cli-doc.in-sum-base
               .
      else  assign buf-arh-wth-cli-doc.out-qnty =  tt-parts-cli-doc.out-qnty
               buf-arh-wth-cli-doc.out-sum-rubl =  tt-parts-cli-doc.out-sum-rubl
               buf-arh-wth-cli-doc.out-sum-base =  tt-parts-cli-doc.out-sum-base
               buf-arh-wth-cli-doc.in-qnty =  tt-parts-cli-doc.in-qnty
               buf-arh-wth-cli-doc.in-sum-rubl =  tt-parts-cli-doc.in-sum-rubl
               buf-arh-wth-cli-doc.in-sum-base =  tt-parts-cli-doc.in-sum-base
               .

            /*Пересчет архивов*/
      for each  buf-recalc-cli-doc where buf-recalc-cli-doc.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-cli-doc.wth-code = tt-parts-cli-doc.wth-code
            and buf-recalc-cli-doc.par-code = tt-parts-cli-doc.par-code
            and buf-recalc-cli-doc.cli-type = tt-parts-cli-doc.cli-type
            and buf-recalc-cli-doc.cli-code = tt-parts-cli-doc.cli-code
            and buf-recalc-cli-doc.host-code     = tt-parts-cli-doc.host-code
            and buf-recalc-cli-doc.contract-code = tt-parts-cli-doc.contract-code
            and buf-recalc-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
            and buf-recalc-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
            and buf-recalc-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
            and buf-recalc-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
            and buf-recalc-cli-doc.sum-type      = tt-parts-cli-doc.sum-type
            and buf-recalc-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
            on error undo, return error:

            assign buf-recalc-cli-doc.out-qnty     = buf-recalc-cli-doc.out-qnty + tt-parts-cli-doc.out-qnty
                  buf-recalc-cli-doc.out-sum-rubl = buf-recalc-cli-doc.out-sum-rubl + tt-parts-cli-doc.out-sum-rubl
                  buf-recalc-cli-doc.out-sum-base = buf-recalc-cli-doc.out-sum-base + tt-parts-cli-doc.out-sum-base
                  buf-recalc-cli-doc.in-qnty       = buf-recalc-cli-doc.in-qnty + tt-parts-cli-doc.in-qnty
                  buf-recalc-cli-doc.in-sum-rubl = buf-recalc-cli-doc.in-sum-rubl + tt-parts-cli-doc.in-sum-rubl
                  buf-recalc-cli-doc.in-sum-base = buf-recalc-cli-doc.in-sum-base + tt-parts-cli-doc.in-sum-base

                  .

      end.

    end. /*each tt-parts-cli-doc*/
    for each  tt-parts-cli-tot on error undo, return error:
      find last  buf-prev_arh-wth-cli-tot where buf-prev_arh-wth-cli-tot.cli-type =  tt-parts-cli-tot.cli-type
                                        and  buf-prev_arh-wth-cli-tot.cli-code =  tt-parts-cli-tot.cli-code
                                        and  buf-prev_arh-wth-cli-tot.obj-type =  tt-parts-cli-tot.obj-type
                                        and  buf-prev_arh-wth-cli-tot.obj-code =  tt-parts-cli-tot.obj-code
                                      /*  and  buf-prev_arh-wth-cli-tot.host-code =  tt-parts-cli-tot.host-code*/
                                        and  buf-prev_arh-wth-cli-tot.ext-doc-type =  tt-parts-cli-tot.ext-doc-type
                                        and  buf-prev_arh-wth-cli-tot.sum-type     = tt-parts-cli-tot.sum-type
                                        and  buf-prev_arh-wth-cli-tot.fact-order < buf-arh_wth-doc.fact-order
                                        no-error.
  /*    if not available buf-prev_arh-wth-cli-tot then do:
        return error substitute('Не найдена запись итогового архива по покупателю &1 &2.'
                               ,tt-parts-cli-tot.cli-type
                               ,tt-parts-cli-tot.cli-code )  .
      end.  */
      if available buf-prev_arh-wth-cli-tot and buf-prev_arh-wth-cli-tot.fact-order = 0 then do:
          /*заполняем заглушку, созданную при локировании*/
          find first buf-arh-wth-cli-tot where recid(buf-arh-wth-cli-tot) = recid(buf-prev_arh-wth-cli-tot) exclusive-lock.

      end.
      else do:
        create buf-arh-wth-cli-tot.
        buffer-copy tt-parts-cli-tot to buf-arh-wth-cli-tot .
      end.
      assign  buf-arh-wth-cli-tot.doc-code   = buf-arh_wth-doc.doc-code
              buf-arh-wth-cli-tot.fact-order = buf-arh_wth-doc.fact-order
      .
      if available buf-prev_arh-wth-cli-tot then
        assign buf-arh-wth-cli-tot.out-qnty = buf-prev_arh-wth-cli-tot.out-qnty + tt-parts-cli-tot.out-qnty
               buf-arh-wth-cli-tot.out-sum-rubl = buf-prev_arh-wth-cli-tot.out-sum-rubl + tt-parts-cli-tot.out-sum-rubl
               buf-arh-wth-cli-tot.out-sum-base = buf-prev_arh-wth-cli-tot.out-sum-base + tt-parts-cli-tot.out-sum-base
               buf-arh-wth-cli-tot.in-qnty = buf-prev_arh-wth-cli-tot.in-qnty + tt-parts-cli-tot.in-qnty
               buf-arh-wth-cli-tot.in-sum-rubl = buf-prev_arh-wth-cli-tot.in-sum-rubl + tt-parts-cli-tot.in-sum-rubl
               buf-arh-wth-cli-tot.in-sum-base = buf-prev_arh-wth-cli-tot.in-sum-base + tt-parts-cli-tot.in-sum-base

               .
      else  assign buf-arh-wth-cli-tot.out-qnty =  tt-parts-cli-tot.out-qnty
               buf-arh-wth-cli-tot.out-sum-rubl =  tt-parts-cli-tot.out-sum-rubl
               buf-arh-wth-cli-tot.out-sum-base =  tt-parts-cli-tot.out-sum-base
               buf-arh-wth-cli-tot.in-qnty =  tt-parts-cli-tot.in-qnty
               buf-arh-wth-cli-tot.in-sum-rubl =  tt-parts-cli-tot.in-sum-rubl
               buf-arh-wth-cli-tot.in-sum-base =  tt-parts-cli-tot.in-sum-base

               .

      /*Пересчет архивов*/
      for each buf-recalc-cli-tot where buf-recalc-cli-tot.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-cli-tot.cli-type = tt-parts-cli-tot.cli-type
            and buf-recalc-cli-tot.cli-code = tt-parts-cli-tot.cli-code
            and buf-recalc-cli-tot.obj-type = tt-parts-cli-tot.obj-type
            and buf-recalc-cli-tot.obj-code = tt-parts-cli-tot.obj-code
          /*  and buf-recalc-cli-tot.host-code = tt-parts-cli-tot.host-code*/
            and buf-recalc-cli-tot.ext-doc-type = tt-parts-cli-tot.ext-doc-type
            and buf-recalc-cli-tot.sum-type     = tt-parts-cli-tot.sum-type
            on error undo, return error
            :

            assign buf-recalc-cli-tot.out-qnty     = buf-recalc-cli-tot.out-qnty + tt-parts-cli-tot.out-qnty
                  buf-recalc-cli-tot.out-sum-rubl = buf-recalc-cli-tot.out-sum-rubl + tt-parts-cli-tot.out-sum-rubl
                  buf-recalc-cli-tot.out-sum-base = buf-recalc-cli-tot.out-sum-base + tt-parts-cli-tot.out-sum-base
                  buf-recalc-cli-tot.in-qnty       = buf-recalc-cli-tot.in-qnty + tt-parts-cli-tot.in-qnty
                  buf-recalc-cli-tot.in-sum-rubl = buf-recalc-cli-tot.in-sum-rubl + tt-parts-cli-tot.in-sum-rubl
                  buf-recalc-cli-tot.in-sum-base = buf-recalc-cli-tot.in-sum-base + tt-parts-cli-tot.in-sum-base

                  .

      end.
    end.  /*tt-part-cli-tot*/

  end. /*varmode = 1*/
  end. /*error*/
 end.
procedure wth-arhdoc-delete:
 define input parameter pardoc-code as char no-undo.
  do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  find first buf-arh_wth-doc where buf-arh_wth-doc.doc-code = pardoc-code no-lock no-error.
  if not available buf-arh_wth-doc then do:
    return error substitute ("Не найден документ МЦ с номером &1.", pardoc-code).
  end.
  if buf-arh_wth-doc.status_ <> {&fact} then do:
    return error substitute ("Документ МЦ с номером &1 не в статусе факт. Создание архивов невозможно.", pardoc-code).
  end.
  if buf-arh_wth-doc.fact-order = 0 or
    buf-arh_wth-doc.fact-order = ? then do:
    return error substitute ("В документе МЦ с номером &1 не проставлен fact-order.", buf-arh_wth-doc.doc-code).
  end.
  /*заполнение  времен. таблиц */
  run wth-arh-calctt-loc(input buf-arh_wth-doc.doc-code
                        ,input no) no-error.
  if error-status:error then  return error return-value + error-status:get-message(1).
  for each  tt-parts-tot on error undo, return error return-value:
      find first  buf-arh-wth-tot where buf-arh-wth-tot.wth-code =  tt-parts-tot.wth-code
                                        and buf-arh-wth-tot.par-code =  tt-parts-tot.par-code
                                        and buf-arh-wth-tot.obj-type = tt-parts-tot.obj-type
                                        and buf-arh-wth-tot.obj-code = tt-parts-tot.obj-code
                                        and buf-arh-wth-tot.ext-doc-type = tt-parts-tot.ext-doc-type
                                        and buf-arh-wth-tot.sum-type = tt-parts-tot.sum-type
                                        and buf-arh-wth-tot.fact-order = buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-arh-wth-tot then do:
          delete buf-arh-wth-tot.
      end.
       /*Пересчет архивов*/
      for each buf-recalc-tot where buf-recalc-tot.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-tot.wth-code = tt-parts-tot.wth-code
            and buf-recalc-tot.par-code = tt-parts-tot.par-code
            and buf-recalc-tot.obj-type = tt-parts-tot.obj-type
            and buf-recalc-tot.obj-code = tt-parts-tot.obj-code
            and buf-recalc-tot.ext-doc-type = tt-parts-tot.ext-doc-type
            and buf-recalc-tot.sum-type = tt-parts-tot.sum-type

             :

            assign buf-recalc-tot.out-qnty     = buf-recalc-tot.out-qnty - tt-parts-tot.out-qnty
                  buf-recalc-tot.out-sum-rubl = buf-recalc-tot.out-sum-rubl - tt-parts-tot.out-sum-rubl
                  buf-recalc-tot.out-sum-base = buf-recalc-tot.out-sum-base - tt-parts-tot.out-sum-base
                  buf-recalc-tot.in-qnty       = buf-recalc-tot.in-qnty - tt-parts-tot.in-qnty
                  buf-recalc-tot.in-sum-rubl = buf-recalc-tot.in-sum-rubl - tt-parts-tot.in-sum-rubl
                  buf-recalc-tot.in-sum-base = buf-recalc-tot.in-sum-base - tt-parts-tot.in-sum-base
                  .

      end. /*пересчет*/
  end. /*tt-parts-tot*/
  for each  tt-parts-wp on error undo, return error return-value:
      find first  buf-arh-wth-wp where buf-arh-wth-wp.wth-code =  tt-parts-wp.wth-code
                                        and buf-arh-wth-wp.par-code =  tt-parts-wp.par-code
                                        and buf-arh-wth-wp.obj-type = tt-parts-wp.obj-type
                                        and buf-arh-wth-wp.obj-code = tt-parts-wp.obj-code
                                        and buf-arh-wth-wp.out-code = tt-parts-wp.out-code
                                        and buf-arh-wth-wp.w-p-code = tt-parts-wp.w-p-code
                                        and buf-arh-wth-wp.sum-type = tt-parts-wp.sum-type
                                        and buf-arh-wth-wp.fact-order = buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-arh-wth-wp then do:
          delete buf-arh-wth-wp.
      end.
       /*Пересчет архивов*/
      for each buf-recalc-wp where buf-recalc-wp.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-wp.wth-code = tt-parts-wp.wth-code
            and buf-recalc-wp.par-code = tt-parts-wp.par-code
            and buf-recalc-wp.obj-type = tt-parts-wp.obj-type
            and buf-recalc-wp.obj-code = tt-parts-wp.obj-code
            and buf-recalc-wp.out-code = tt-parts-wp.out-code
            and buf-recalc-wp.w-p-code = tt-parts-wp.w-p-code
            and buf-recalc-wp.sum-type = tt-parts-wp.sum-type

             :

            assign buf-recalc-wp.out-qnty     = buf-recalc-wp.out-qnty - tt-parts-wp.out-qnty
                  buf-recalc-wp.out-sum-rubl = buf-recalc-wp.out-sum-rubl - tt-parts-wp.out-sum-rubl
                  buf-recalc-wp.out-sum-base = buf-recalc-wp.out-sum-base - tt-parts-wp.out-sum-base
                  buf-recalc-wp.in-qnty       = buf-recalc-wp.in-qnty - tt-parts-wp.in-qnty
                  buf-recalc-wp.in-sum-rubl = buf-recalc-wp.in-sum-rubl - tt-parts-wp.in-sum-rubl
                  buf-recalc-wp.in-sum-base = buf-recalc-wp.in-sum-base - tt-parts-wp.in-sum-base
                  .

      end. /*пересчет*/
  end. /*tt-parts-wp*/

  for each  tt-parts-cli:
    find last  buf-arh-wth-cli where  buf-arh-wth-cli.wth-code =  tt-parts-cli.wth-code
                                      and  buf-arh-wth-cli.par-code =  tt-parts-cli.par-code
                                      and  buf-arh-wth-cli.cli-type =  tt-parts-cli.cli-type
                                      and  buf-arh-wth-cli.ser-code =  tt-parts-cli.ser-code
                                      and  buf-arh-wth-cli.db-num   =  tt-parts-cli.db-num
                                      and  buf-arh-wth-cli.cli-code =  tt-parts-cli.cli-code
                                      and  buf-arh-wth-cli.obj-type =  tt-parts-cli.obj-type
                                      and  buf-arh-wth-cli.obj-code =  tt-parts-cli.obj-code
                                      and  buf-arh-wth-cli.ext-doc-type =  tt-parts-cli.ext-doc-type
                                      and buf-arh-wth-cli.sum-type = tt-parts-cli.sum-type
                                      and  buf-arh-wth-cli.gds-code =  tt-parts-cli.gds-code
                                      and  buf-arh-wth-cli.fact-order = buf-arh_wth-doc.fact-order
                                      no-error.
    if available buf-arh-wth-cli then do:
        delete buf-arh-wth-cli.
    end.
   /*Пересчет архивов*/
    for each buf-recalc-cli where buf-recalc-cli.fact-order > buf-arh_wth-doc.fact-order
          and buf-recalc-cli.wth-code = tt-parts-cli.wth-code
          and buf-recalc-cli.par-code = tt-parts-cli.par-code
          and buf-recalc-cli.ser-code = tt-parts-cli.ser-code
          and buf-recalc-cli.db-num   = tt-parts-cli.db-num
          and buf-recalc-cli.cli-type = tt-parts-cli.cli-type
          and buf-recalc-cli.cli-code = tt-parts-cli.cli-code
          and buf-recalc-cli.obj-type = tt-parts-cli.obj-type
          and buf-recalc-cli.obj-code = tt-parts-cli.obj-code
          and buf-recalc-cli.ext-doc-type = tt-parts-cli.ext-doc-type
          and buf-recalc-cli.sum-type = tt-parts-cli.sum-type
          and buf-recalc-cli.gds-code = tt-parts-cli.gds-code:

          assign buf-recalc-cli.out-qnty     = buf-recalc-cli.out-qnty - tt-parts-cli.out-qnty
                buf-recalc-cli.out-sum-rubl = buf-recalc-cli.out-sum-rubl - tt-parts-cli.out-sum-rubl
                buf-recalc-cli.out-sum-base = buf-recalc-cli.out-sum-base - tt-parts-cli.out-sum-base
                buf-recalc-cli.in-qnty       = buf-recalc-cli.in-qnty - tt-parts-cli.in-qnty
                buf-recalc-cli.in-sum-rubl = buf-recalc-cli.in-sum-rubl - tt-parts-cli.in-sum-rubl
                buf-recalc-cli.in-sum-base = buf-recalc-cli.in-sum-base - tt-parts-cli.in-sum-base

                .
    end.
  end.  /*tt-part-cli*/
/*Расширенный по клиент-номинал*/
  for each  tt-parts-cli-doc:
    find last  buf-arh-wth-cli-doc where  buf-arh-wth-cli-doc.wth-code =  tt-parts-cli-doc.wth-code
                                      and  buf-arh-wth-cli-doc.par-code = tt-parts-cli-doc.par-code
                                      and  buf-arh-wth-cli-doc.cli-type = tt-parts-cli-doc.cli-type
                                      and  buf-arh-wth-cli-doc.cli-code = tt-parts-cli-doc.cli-code
                                      and  buf-arh-wth-cli-doc.host-code     = tt-parts-cli-doc.host-code
                                      and  buf-arh-wth-cli-doc.contract-code = tt-parts-cli-doc.contract-code
                                      and  buf-arh-wth-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
                                      and  buf-arh-wth-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
                                      and  buf-arh-wth-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
                                      and  buf-arh-wth-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
                                      and  buf-arh-wth-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
                                      and buf-arh-wth-cli-doc.sum-type = tt-parts-cli-doc.sum-type
                                      and  buf-arh-wth-cli-doc.fact-order < buf-arh_wth-doc.fact-order
                                      no-error.
    if available  buf-arh-wth-cli-doc then do:
      delete buf-arh-wth-cli-doc.
    end.
        /*Пересчет архивов*/
    for each  buf-recalc-cli-doc where buf-recalc-cli-doc.fact-order > buf-arh_wth-doc.fact-order
          and buf-recalc-cli-doc.wth-code = tt-parts-cli-doc.wth-code
          and buf-recalc-cli-doc.par-code = tt-parts-cli-doc.par-code
          and buf-recalc-cli-doc.cli-type = tt-parts-cli-doc.cli-type
          and buf-recalc-cli-doc.cli-code = tt-parts-cli-doc.cli-code
          and buf-recalc-cli-doc.host-code     = tt-parts-cli-doc.host-code
          and buf-recalc-cli-doc.contract-code = tt-parts-cli-doc.contract-code
          and buf-recalc-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
          and buf-recalc-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
          and buf-recalc-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
          and buf-recalc-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
          and buf-recalc-cli-doc.sum-type      = tt-parts-cli-doc.sum-type
          and buf-recalc-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type:

          assign buf-recalc-cli-doc.out-qnty     = buf-recalc-cli-doc.out-qnty - tt-parts-cli-doc.out-qnty
                buf-recalc-cli-doc.out-sum-rubl = buf-recalc-cli-doc.out-sum-rubl - tt-parts-cli-doc.out-sum-rubl
                buf-recalc-cli-doc.out-sum-base = buf-recalc-cli-doc.out-sum-base - tt-parts-cli-doc.out-sum-base
                buf-recalc-cli-doc.in-qnty       = buf-recalc-cli-doc.in-qnty - tt-parts-cli-doc.in-qnty
                buf-recalc-cli-doc.in-sum-rubl  = buf-recalc-cli-doc.in-sum-rubl - tt-parts-cli-doc.in-sum-rubl
                buf-recalc-cli-doc.in-sum-base  = buf-recalc-cli-doc.in-sum-base - tt-parts-cli-doc.in-sum-base

                .
    end.
  end. /*each tt-parts-cli-doc*/
  for each  tt-parts-cli-tot:
    find last  buf-arh-wth-cli-tot where   buf-arh-wth-cli-tot.cli-type =  tt-parts-cli-tot.cli-type
                                      and  buf-arh-wth-cli-tot.cli-code =  tt-parts-cli-tot.cli-code
                                      and  buf-arh-wth-cli-tot.obj-type =  tt-parts-cli-tot.obj-type
                                      and  buf-arh-wth-cli-tot.obj-code =  tt-parts-cli-tot.obj-code
                                      and  buf-arh-wth-cli-tot.ext-doc-type =  tt-parts-cli-tot.ext-doc-type
                                      and  buf-arh-wth-cli-tot.sum-type = tt-parts-cli-tot.sum-type
                                      and  buf-arh-wth-cli-tot.fact-order = buf-arh_wth-doc.fact-order
                                      no-error.
    if available buf-arh-wth-cli-tot then do:
        delete buf-arh-wth-cli-tot.
    end.
   /*Пересчет архивов*/
    for each buf-recalc-cli-tot where buf-recalc-cli-tot.fact-order > buf-arh_wth-doc.fact-order
          and buf-recalc-cli-tot.cli-type = tt-parts-cli-tot.cli-type
          and buf-recalc-cli-tot.cli-code = tt-parts-cli-tot.cli-code
          and buf-recalc-cli-tot.obj-type = tt-parts-cli-tot.obj-type
          and buf-recalc-cli-tot.obj-code = tt-parts-cli-tot.obj-code
          and buf-recalc-cli-tot.sum-type = tt-parts-cli-tot.sum-type
          and buf-recalc-cli-tot.ext-doc-type = tt-parts-cli-tot.ext-doc-type
          :

          assign buf-recalc-cli-tot.out-qnty     = buf-recalc-cli-tot.out-qnty - tt-parts-cli-tot.out-qnty
                buf-recalc-cli-tot.out-sum-rubl = buf-recalc-cli-tot.out-sum-rubl - tt-parts-cli-tot.out-sum-rubl
                buf-recalc-cli-tot.out-sum-base = buf-recalc-cli-tot.out-sum-base - tt-parts-cli-tot.out-sum-base
                buf-recalc-cli-tot.in-qnty       = buf-recalc-cli-tot.in-qnty - tt-parts-cli-tot.in-qnty
                buf-recalc-cli-tot.in-sum-rubl = buf-recalc-cli-tot.in-sum-rubl - tt-parts-cli-tot.in-sum-rubl
                buf-recalc-cli-tot.in-sum-base = buf-recalc-cli-tot.in-sum-base - tt-parts-cli-tot.in-sum-base
                .
    end.
  end.  /*tt-part-cli-tot*/

end. /*error*/
end procedure.