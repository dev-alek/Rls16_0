/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 21

Автор: Чернова Светлана Александровна
Дата создания: 04/24/09
Author: Svetlana Chernova
Creation date: 04/24/09

---------------------------&start-codex_id=21;ruleset_id=1;-------------------------------
Операции над ДНЦ
Закрытие ДНЦ по ГТПЛ на факт
---------------------------&end-codex_id=21;ruleset_id=1;-------------------------------

*/


/*---------------------------&start-using-class&-------------------------------*/

block-level on error undo, throw.

/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-plt-id as integer no-undo .
define input parameter p-plt-db-num as integer no-undo .
define input parameter p-pdf-id as integer no-undo .
define input parameter p-pdf-db-num as integer no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 1".

define variable v-pricewithvat as decimal   no-undo .
define variable v-prod-vat     as decimal   no-undo .

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getsect.i def}
{ cmp/library.i  }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ str/lib-trn.i  }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "shared" }
{ rul/cl-hist.i "shared" }
{ gbl/gate-clb.i }
{ str/pdf-list.i pdf-list def "shared" }
{ gbl/key-rec.i }
{ ref/xobjgrp.i  }  /* список объектов  */
{ str/pdf-attr.i }
{ str/trdcalib.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/hvrdtax.i  }
define buffer buf_price-doc-forming for ub.price-doc-forming  .
{ str/alt-calc.i "func"  }
{ str/alt-calc.i "proc" "''"  "''"  }
{ str/mpl-lib.i  }
{ str/mpl-lib3.i }
{ trg/check-bc.i }
{ ref/gdsoattr.i }
{ str/lastincs.i }
define temp-table temp-pdf no-undo like ub.price-doc-forming-gds .

define temp-table temp-tt no-undo
field b-code as integer
field gds-code as integer
field price-sale as decimal
index pi b-code.
/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-current-pdf-id as integer no-undo .
define variable v-current-pdf-db-num as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "pdf-clos.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
define variable vartemp-char as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-type as character no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-code-attr as character no-undo .

{ str/dia2auto.i }
{ rul/seterror.i }

define buffer buf_temp-cmd for temp-cmd.

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-tpl as character no-undo.
  define variable p-coeff as decimal no-undo .

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.

/* ------------------------- &start-def-vars& -----------------------------------*/


/* ------------------------- &end-def-vars& -----------------------------------*/
if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  { str/cdviewlg.i  "'!!!При выполнении произошли ошибки!!!'"   log-file-name not-delete }
  if v-es then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :
_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:
  define variable v-ii as integer no-undo .
  define variable v-loc-file-name as character no-undo .
  define variable v-err as logical no-undo .
  define variable v-success as logical   no-undo .


/* ------------------------- &end-hn-option& -----------------------------------*/
  run write-log  in p-log-handle (
                                  input 0
                                , "&DLine").
define variable v-is-n as logical   no-undo .
define buffer ver_price-doc  for ub.price-doc  .
define buffer ver_price-list for ub.price-list  .

  for each pdf-list :
    v-is-n = false .
    for each ver_price-doc no-lock where
             ver_price-doc.pdf-id      = pdf-list.pdf-id    and
             ver_price-doc.pdf-db      = pdf-list.pdf-db    and
             ver_price-doc.plt-id      = pdf-list.plt-id    and
             ver_price-doc.plt-db-num  = pdf-list.plt-db-num
             :
     for each ver_price-list no-lock where
              ver_price-list.doc-num =  ver_price-doc.doc-num and
              ver_price-list.main-price = false
              :
              v-is-n  = true .
      end.
    end.
 end.

  if v-is-n = false then return .
  &scop my-message substitute(".............Скидочные ДНЦ")
  {&display-message}.


  _stroka:
  for each pdf-list
  On error undo _stroka, next _stroka
  :
  v-is-n = false .
  for each ver_price-doc no-lock where
            ver_price-doc.pdf-id     = pdf-list.pdf-id     and
            ver_price-doc.pdf-db     = pdf-list.pdf-db     and
            ver_price-doc.plt-id     = pdf-list.plt-id     and
            ver_price-doc.plt-db-num = pdf-list.plt-db-num :
        for each ver_price-list no-lock where
                  ver_price-list.doc-num =  ver_price-doc.doc-num and
                  ver_price-list.main-price = false
                  :
                  v-is-n  = true .
          end.
  end.
  if v-is-n = false then next .

    assign
    v-current-pdf-id     = pdf-list.pdf-id
    v-current-pdf-db-num = pdf-list.pdf-db
    num-rec = num-rec + 1
    .
    &scop my-message substitute ("Обработка ДНЦ &1 &2", pdf-list.pdf-id , pdf-list.pdf-db)
    {&display-message}.
    if v-err then next.
    /* ------------------------- &start-rule& -----------------------------------*/

     run exec-proc ( pdf-list.pdf-id , pdf-list.pdf-db , pdf-list.plt-id , pdf-list.plt-db-num ) no-error .
     if error-status :error then do:
        undo, return error return-value .
     end.

    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/

     release pdf-list.
    /* ------------------------- &end-release-obj& -------------------------------------*/

    num-rec-ok = num-rec-ok + 1.
    run write-counter  in p-log-handle ( input substitute("Обработано ДНЦ списка : &1, из них удачно: &2", num-rec, num-rec-ok )).
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
        &scop my-message substitute("Процесс прерван пользователем")
        {&display-message}.
        leave _stroka.
    end.
  end. /*for each ord-list where*/
  &scop my-message substitute("Обработано ДНЦ списка : &1, из них удачно: &2", num-rec, num-rec-ok)
  {&display-message}.

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.

  do
  on error undo, return error
  :
/*---------------------------&start-process-rule-call-param&-------------------------------*/


  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-tpl"
 no-error.
if available buf_rule-call-param then do:
assign p-tpl = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-coeff"
 no-error.
if available buf_rule-call-param then do:
   assign p-coeff = buf_rule-call-param.param-value-decimal.
end.



/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 1
      then do:
        assign

        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        .
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

/*не удалять!!!!*/


procedure exec-proc :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db     as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .

define buffer buf_pdf-gds for ub.price-doc-forming-gds  .
define buffer buf_price-doc for ub.price-doc  .
define buffer buf_price-list-type for ub.price-list-type  .

define variable v-dis-plt-id as integer   no-undo .
define variable v-dis-plt-db as integer   no-undo .
define variable v-exs-obj as logical   no-undo .

do
  on error undo, return error return-value
  :

  &scop my-message substitute("Формирование скидочных ДНЦ по ТПЛ &1" , p-tpl)
  {&display-message}.

  assign
    v-dis-plt-id = int(entry(1,p-tpl,"-"))
    v-dis-plt-db = int(entry(2,p-tpl,"-"))
  no-error .
    if p-coeff = 0  or p-coeff = ? then do:
        &scop my-message substitute("Не верно задан коэффициент в настройках машины правил"  )
        {&display-message}.
        return error return-value .
    end.
  /* Проверим наличие такого ТПЛ и не удален ли он  */
    find first buf_price-list-type no-lock where
               buf_price-list-type.plt-id = v-dis-plt-id and
               buf_price-list-type.plt-db = v-dis-plt-db no-error .
     if error-status :error then do:
        &scop my-message substitute("Не найден ТПЛ &1(&2)  для порождения ДНЦ :  &3 &4 "  ,v-dis-plt-id,v-dis-plt-db, return-value , error-status :get-message(1)  )
        {&display-message}.
        return error return-value .
     end.
     if buf_price-list-type.stts  =  int({&pdf-delete})  then do:
        &scop my-message substitute("ТПЛ &1(&2) Удален !!! пропускаем "  ,v-dis-plt-id,v-dis-plt-db  )
        {&display-message}.
        return  .
     end.
     run metod-gop-obj in this-procedure (
        g#db-num ,
        buf_price-list-type.gop-id   ,
        buf_price-list-type.gop-db-num  ) no-error .
        if error-status :error then do:
            &scop my-message substitute("Сбор оъектов по  ТПЛ &1(&2) : &3 &4 "  ,v-dis-plt-id,v-dis-plt-db, return-value , error-status :get-message(1)  )
            {&display-message}.
            return error return-value .
        end.

  /* Проверка на пересечение объектов */
  v-exs-obj = false .
  for each buf_price-doc no-lock where
      buf_price-doc.pdf-id     = p-pdf-id    and
      buf_price-doc.pdf-db     = p-pdf-db    and
      buf_price-doc.plt-id     = p-plt-id    and
      buf_price-doc.plt-db-num = p-plt-db-num :
       find first x_obj-group where
                  x_obj-group.obj-type = buf_price-doc.obj-type and
                  x_obj-group.obj-code = buf_price-doc.obj-code no-error .
        if available x_obj-group then do:
           v-exs-obj = true .
           leave.
        end.
   end.
    if v-exs-obj = false then do:
        &scop my-message substitute("По ТПЛ &1(&2) скидочные ДНЦ созданы не будут"  ,v-dis-plt-id,v-dis-plt-db, return-value , error-status :get-message(1)  )
        {&display-message}.
        return .
    end.
  /* Создание ДНЦ по Скидочному ТПЛ  p-tpl */
      /*1. Создание по переоценкам ДНЦ по Скидочному ТПЛ  p-tpl */
      /*2. Атрибуты Скидочного ДНЦ с oбъектами исключениями */
      /*3. Атрибуты Переоценок связка с новыми скидочными ДНЦ */


  for each buf_price-doc no-lock where
      buf_price-doc.pdf-id     = p-pdf-id    and
      buf_price-doc.pdf-db     = p-pdf-db    and
      buf_price-doc.plt-id     = p-plt-id    and
      buf_price-doc.plt-db-num = p-plt-db-num :
       find first x_obj-group where
                  x_obj-group.obj-type = buf_price-doc.obj-type and
                  x_obj-group.obj-code = buf_price-doc.obj-code no-error .
        if not available x_obj-group then do:
           next.
        end.

      empty temp-table temp-tt .
      empty temp-table temp-pdf .

      run create-pdf-from-tpl (buf_price-doc.doc-num,v-dis-plt-id,v-dis-plt-db) no-error .
      if error-status :error then do:
        &scop my-message substitute("Переоценка &1 -> Скидочный ТПЛ &2(&3): ошибка &4 &5" ,buf_price-doc.doc-num,v-dis-plt-id,v-dis-plt-db, return-value , error-status :get-message(1)  )
        {&display-message}.
        return error return-value .
      end.
  end.
end.
end procedure. /* exec-proc */

procedure create-pdf-from-tpl :
define input  parameter p-doc-num as character no-undo .
define input  parameter p-dis-plt-id as integer   no-undo .
define input  parameter p-dis-plt-db as integer   no-undo .

/*
Создать ДНЦ как переоценка
Добавить атрибуты ДНЦ минус все объекты , кроме переоценочных
Атрибуты Переоценок связка с новыми скидочными ДНЦ
*/
define buffer buf_price-list for ub.price-list  .
define buffer buf_goods      for ub.goods  .
define buffer buf_bar-code   for ub.bar-code  .
define buffer neos_price-list for ub.price-list  .
define buffer neos_bar-code   for ub.bar-code  .
define buffer buf_price-doc for ub.price-doc  .
define buffer buf_doc-attr for ub.doc-attr  .

define variable v-cli-base-rate      as decimal   no-undo .
define variable v-price-cli-base-rate as decimal   no-undo .
define variable v-new-price-sale as decimal   no-undo .
define variable v-pdf-id     as integer   no-undo .
define variable v-pdf-db-num as integer   no-undo .
define variable v-str as character no-undo .


  do
  on error undo, return error return-value
  :
  find first  buf_price-doc no-lock where
              buf_price-doc.doc-num   =  p-doc-num no-error .

   for each buf_price-list no-lock where
            buf_price-list.doc-num   =  p-doc-num and
            buf_price-list.main-price = true ,
      first buf_bar-code no-lock where
            buf_bar-code.b-code = buf_price-list.b-code ,
      first buf_goods no-lock where
            buf_goods.gds-code = buf_bar-code.gds-code :
            v-cli-base-rate  = 0 .
            v-price-cli-base-rate  = 0 .
            for each neos_price-list no-lock where
                     neos_price-list.doc-num    =  p-doc-num and
                     neos_price-list.artic     = buf_goods.artic and
                     neos_price-list.prod-type = buf_goods.prod-type and
                     neos_price-list.prod-code = buf_goods.prod-code and
                     neos_price-list.main-price = false  ,
                first neos_bar-code no-lock where
                      neos_bar-code.b-code     = neos_price-list.b-code and
                      neos_bar-code.unit-cli   <> buf_goods.unit-base
                      by neos_bar-code.cli-base-rate descending
                      by neos_price-list.price-sale    :
                        v-cli-base-rate        = neos_bar-code.cli-base-rate.
                        v-price-cli-base-rate  = neos_price-list.price-sale.
                        leave .
           end.
        if v-cli-base-rate  = 0 or  v-price-cli-base-rate  = 0 then next.
        v-new-price-sale = p-coeff * ( v-price-cli-base-rate / v-cli-base-rate ) .
        run new-pdf-line-tt ( buf_price-list.b-code , v-new-price-sale, buf_goods.gds-code ) .
    end.

    define buffer bbb_price-doc-forming-gds for ub.price-doc-forming-gds  .

    for each bbb_price-doc-forming-gds no-lock where
             bbb_price-doc-forming-gds.plt-id = buf_price-doc.plt-id and
             bbb_price-doc-forming-gds.plt-db = buf_price-doc.plt-db and
             bbb_price-doc-forming-gds.pdf-db = buf_price-doc.pdf-db and
             bbb_price-doc-forming-gds.pdf-id = buf_price-doc.pdf-id ,
       first buf_price-list no-lock where
             buf_price-list.doc-num    = buf_price-doc.doc-num and
             buf_price-list.b-code     = bbb_price-doc-forming-gds.b-code  and
             buf_price-list.price-type = ""                    and
             buf_price-list.main-price = false
             :
           create temp-pdf.
           buffer-copy bbb_price-doc-forming-gds to temp-pdf .
    end.


    /* Сделать ДНЦ */
    run new-pdf (
          input buf_price-doc.doc-num
        , input  p-dis-plt-id
        , input  p-dis-plt-db
        , output v-pdf-id
        , output v-pdf-db-num
        ) no-error .
      if error-status :error then do:
        &scop my-message substitute("Ошибка при создании   ДНЦ: &1(&2) &3 &4 ",v-pdf-id, v-pdf-db-num, return-value , error-status :get-message(1))
        {&display-message} .
        undo, return error return-value .
      end.

    run make-attr-objexcl (
          v-pdf-id
        , v-pdf-db-num
        , p-dis-plt-id
        , p-dis-plt-db
        , buf_price-doc.obj-type
        , buf_price-doc.obj-code   ).

        v-str = string(p-dis-plt-id) + "," + string(p-dis-plt-dB) + "," + string(v-pdf-id) + "," + string(v-pdf-db-num) .
        v-code-attr =  {&trdcattr-relprpdf} + {&delim-par} + string(p-dis-plt-id) + {&delim-par} + string(p-dis-plt-dB) .
    /* Сделать атрибуты связки */

    find first buf_doc-attr exclusive-lock where
               buf_doc-attr.doc-code  = buf_price-doc.doc-num and
               buf_doc-attr.attr-code = v-code-attr no-error.
    if not available buf_doc-attr then do:
      create buf_doc-attr.
      assign buf_doc-attr.doc-code  = buf_price-doc.doc-num
             buf_doc-attr.attr-code = v-code-attr .
    end.
    assign buf_doc-attr.attr-value = v-str.

      { str/tdatothn.i
        buf_price-doc.doc-num
        v-code-attr
        no-error
      }
      if error-status :error then do:
        &scop my-message substitute("Ошибка при обработке атрибута  ДНЦ: &1(&2) переоценка :&3 &4 &5 &6",v-pdf-id, v-pdf-db-num, buf_price-doc.doc-num , return-value , error-status :get-message(1) , v-code-attr)
        {&display-message} .
        undo, return error return-value .
      end.

      &scop my-message substitute("Создано ДНЦ &1(&2)", v-pdf-id, v-pdf-db-num )
      {&display-message}.
  end.

end procedure. /* create-pdf-from-tpl */


procedure make-attr-objexcl :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .

define buffer buf_x_obj-group for x_obj-group  .

  do
  on error undo, return error return-value
  :
      for each  buf_x_obj-group no-lock where
      NOT ( buf_x_obj-group.obj-code = p-obj-code and
            buf_x_obj-group.obj-type = p-obj-type  ) :
      run ins-pdf-attr-objdel (
          p-pdf-id ,
          p-pdf-db-num ,
          p-plt-id     ,
          p-plt-db-num ,
          buf_x_obj-group.obj-type ,
          buf_x_obj-group.obj-code
          ) .
       end.
  end.

end procedure. /* make-attr-objexcl */


procedure new-pdf-line-tt :

define input  parameter p-b-code   as integer   no-undo .
define input  parameter p-price-sale as decimal   no-undo .
define input  parameter p-gds-code   as integer   no-undo .

  do
  on error undo, return error return-value
  :
    create temp-tt.
    assign
      temp-tt.gds-code   = p-gds-code
      temp-tt.b-code     = p-b-code
      temp-tt.price-sale = p-price-sale
    .
  end.

end procedure. /* new-pdf-line-tt */


procedure new-pdf :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-dis-plt-id as integer   no-undo .
define input  parameter p-dis-plt-db as integer   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .

define variable v-counter as integer   no-undo .
define variable v-sec as integer   no-undo .
define buffer buf_goods for ub.goods  .
  do
  on error undo, return error return-value
  :
         assign
          p-pdf-id     = next-value ( s-pdf , {&db-name_schema})
          p-pdf-db-num = g#db-num
         .
         find first ub.price-list-type no-lock where
                    ub.price-list-type.plt-id = p-dis-plt-id and
                    ub.price-list-type.plt-db = p-dis-plt-db  no-error .
         if error-status :error then do:
                  &scop my-message substitute("4. ошибка &1 &2", return-value,  error-status :get-message(1) )
                  {&display-message}.
                  return error return-value .
         end.
         create ub.price-doc-forming .
         assign
            ub.price-doc-forming.plt-id       = p-dis-plt-id
            ub.price-doc-forming.plt-db-num   = p-dis-plt-db
            ub.price-doc-forming.pdf-id       = p-pdf-id
            ub.price-doc-forming.pdf-db       = p-pdf-db-num
            ub.price-doc-forming.stts         = integer({&pdf-new})
            ub.price-doc-forming.sys-date     = today
            ub.price-doc-forming.sys-time     = time
            ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
            ub.price-doc-forming.who          = g#userid
            ub.price-doc-forming.des          = substitute("Скидочный ДНЦ по шаблону скидок &1 cоздан по ПЕРЕОЦЕНКЕ &2 по неосновным кодам " ,ub.price-list-type.ban-discnt , p-doc-code)
            ub.price-doc-forming.name         = substitute("Скидочный ДНЦ:&1 cоздан по ПЕРЕОЦЕНКЕ &2" ,ub.price-list-type.ban-discnt , p-doc-code)
            ub.price-doc-forming.main-pdf-id  = ub.price-doc-forming.pdf-id
            ub.price-doc-forming.main-pdf-db  = ub.price-doc-forming.pdf-db
            ub.price-doc-forming.out-code     = p-doc-code
         .

   find first buf_price-doc-forming  exclusive-lock where recid (buf_price-doc-forming) =  recid ( ub.price-doc-forming ) no-error .  /*!!*/
      if error-status :error then do:
        &scop my-message substitute("3. ошибка &1 &2", return-value,  error-status :get-message(1) )
        {&display-message}.
        return error return-value .
      end.

    v-counter = 0.
    for each temp-tt :
        v-counter = v-counter + 1.
        find first buf_goods no-lock where buf_goods.gds-code = temp-tt.gds-code .
        run create-line-pdf-mpl-lib (
             input buf_price-doc-forming.plt-db-num
            ,input buf_price-doc-forming.plt-id
            ,input buf_price-doc-forming.pdf-db
            ,input buf_price-doc-forming.pdf-id
            ,input v-counter
            ,input temp-tt.b-code
            ,input buf_goods.artic
            ,input buf_goods.prod-type
            ,input buf_goods.prod-code
            ,input ""
            ,input 0
            ,input temp-tt.price-sale
            ,input ""
            ,input 0
            ,input-output v-sec ) no-error .
                if error-status :error then do:
                  &scop my-message substitute("1. ошибка &1 &2", return-value,  error-status :get-message(1) )
                  {&display-message}.
                  return error return-value .
                end.
    end.

    for each temp-pdf :
        v-counter = v-counter + 1.
        create ub.price-doc-forming-gds.
        buffer-copy temp-pdf to ub.price-doc-forming-gds
        assign
          ub.price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
          ub.price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
          ub.price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
          ub.price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
          ub.price-doc-forming-gds.line-num   = v-counter
        .
    end.

    ub.price-doc-forming.stts  = integer({&pdf-ready}).
    release buf_price-doc-forming no-error .
      if error-status :error then do:
        &scop my-message substitute("2. ошибка &1 &2", return-value,  error-status :get-message(1) )
        {&display-message}.
        return error return-value .
      end.
  end.

end procedure. /* new-pdf */