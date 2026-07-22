/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

удаление товаров с кассы - из группы

Автор: Шкляр Елена Львовна
Дата создания: 03/24/06
Author: Shklyar Elena
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable choice as integer.

define variable v-chk-act-host-code as integer   no-undo .
{ gbl/hostcode.i
  {&shop}
  abs(i-obj-code)
  v-chk-act-host-code
}
if modetype <> ? then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-goods_deletion':U
    {&cntxt-object}
    v-chk-act-host-code
    {&shop}
    abs(i-obj-code)
    0
    0
    0
    true
    g#log
  }

  if NOT g#log then
      return .
end.

FIND FIRST cash-desk No-LOCK WHERE
           cash-desk.db-num = g#db-num and
          (cash-desk.pos-type = {&cd-type-ibm} OR
           cash-desk.pos-type = {&cd-type-ibm-XML} OR
           cash-desk.pos-type = {&cd-type-ipc-servispl} OR
           cash-desk.pos-type = {&cd-type-ncr-gm} OR
           cash-desk.pos-type = {&cd-type-ncr-AS-R} OR
           cash-desk.pos-type = {&cd-type-MAGIA-XML} or
           cash-desk.pos-type = {&cd-type-autotank}
           ) AND
           cash-desk.obj-code = i-obj-code No-ERROR.
If NOT avail cash-desk then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Удаление товаров с касс реализуется только для касс &1 &2 &3 &4 &5 &6"
                            , {&cd-type-ibm}
                            , {&cd-type-ibm-xml}
                            , {&cd-type-ipc-servispl}
                            , {&cd-type-ncr-gm}
                            , {&cd-type-ncr-AS-R}
                            , {&cd-type-MAGIA-XML}
                            , {&cd-type-autotank}
                          )
                                          ).
    return.
end.

if modetype = ? then do:
  run cb_get-grp-list in p-parent-handle ( input this-procedure:handle ) no-error.
  modetype = no.
end.
else do:
   for each ub.goods no-lock where ub.goods.grp-code = i-grp-code:
   create gds-list.
   buffer-copy ub.goods to gds-list .
   end.
/*                                                                                                              */
/*      run str/gds-list.w (input parparentproc, input ub.shop.host-code, input {&shop}, input abs(i-obj-code)).*/
/*      if not can-find(first gds-list no-lock) then do:                                                        */
/*          message "Вы не определили список товаров для удаления!"                                             */
/*          view-as alert-box WARNING.                                                                          */
/*          return.                                                                                             */
/*      end.                                                                                                    */
/*      g#log = yes.                                                                                            */
/*      message "Удалить все товары списка c касс ?"                                                            */
/*      view-as alert-box question buttons OK-Cancel update g#log.                                              */
/*      if g#log <> true then return.                                                                           */
  end.



/*PROCEDURE term-prt.*/
/*заполняет таблицу cash-gds сканируя баркоды и ДОПБК*/
{ str/term-prt.i ub.goods}
FOR EACH cash-gds :
    delete cash-gds.
END.
FOR EACH cash-txr :
    delete cash-txr.
END.
assign
cr = 0
crgd = 0
cr-txr = 0
cr-ncr-dis-kat = 0
.
if choice = 1
  then do:
     create cash-gds.
      assign
      cash-gds.main-prt-b-code = ?
      cash-gds.b-str           = "*"
      cr                       = 1
      cash-gds.ean-lz          = "*"
      cash-gds.obj-type        = {&shop}
      cash-gds.obj-code        = i-obj-code
   
   .
     
  end.    

  else IF ModeType  then do:
/*все проходившие*/
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Подготовка данных")
                                          ).
assign
  v-count = 0
.
_gds-obj:
    FOR EACH ub.gds-obj WHERE
             ub.gds-obj.obj-type = {&shop} AND
             ub.gds-obj.obj-code = i-obj-code :
   /* if v-is-restaurant then do:
      find first buf_fbr-gds-obj no-lock where
                 buf_fbr-gds-obj.obj-type = {&shop}
             AND buf_fbr-gds-obj.obj-code = i-obj-code
             AND buf_fbr-gds-obj.gds-code = ub.gds-obj.gds-code no-error .
      if not available buf_fbr-gds-obj then
      NEXT _gds-obj.
    end. */

    assign
      v-count = v-count + 1
    .
       if v-count modulo 10 = 0 then do:
          run show-counter in p-log-handle .
          run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - товар &2 &3&4"
                                              , v-count
                                              , ub.gds-obj.artic
                                              , ub.gds-obj.prod-type
                                              , ub.gds-obj.prod-code)) no-error.
       end.
       FIND FIRST ub.goods where
                  ub.goods.artic = ub.gds-obj.artic AND
                  ub.goods.prod-type = ub.gds-obj.prod-type AND
                  ub.goods.prod-code = ub.gds-obj.prod-code NO-LOCK .
      {&NEW-GOOD}
      run get-prt-and-unit in this-procedure (
                                              input ub.goods.prt-root
                                              ,input ub.goods.unit-base
                                              ,output l-empty-scale
                                              ) .                                            .

&scop buffer-name ub.gds-obj
&scop find-option no
&scop gds-code-field ub.goods.gds-code
{&get-gds-obj-fields}

        FIND FIRST ub.gds-prt where
                   ub.gds-prt.upper-code = goods.prt-root NO-LOCK .
/*        if serv-elm and LOOKUP({&petrolium}, ub.units.type) > 0  and new-good then do:*/
/*         run get-rcp-string in this-procedure(                                        */
/*                                                 input ub.goods.artic                 */
/*                                                ,input ub.goods.prod-type             */
/*                                                ,input ub.goods.prod-code             */
/*                                                ,output rcp-string                    */
/*                                              ) no-error .                            */
/*          if return-value = "NEXT":U then next _gds-obj.                              */
/*        end.                                                                          */
        RUN term-prt( ub.gds-prt.prt-root, ?) no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Ошибка при обработке товара &1 &2&3"
                                  , ub.goods.artic
                                  , ub.goods.prod-type
                                  , ub.goods.prod-code
                                  )
                                    ).
          assign
          v-view-log = yes
          .
        end.
        IF NOT can-find(first cash-desk WHERE
                              cash-desk.db-num = g#db-num and
                              cash-desk.pos-type <> "ipc-servis+" AND
                              cash-desk.cash-on = yes AND
                              cash-desk.obj-code = i-obj-code)
            AND cr > 0 then do:
            /*есть только кассы IPC-servis+*/
            /*нужен только один товар*/
            RUN SENDING no-error.
            {&sending-error}.
            assign
            cr = 0
            crgd = 0
            cr-txr = 0
            cr-ncr-dis-kat = 0
            .
            LEAVE.
        end.
        ACCUMULATE ub.goods.artic (COUNT).
        if NOT alllstcs AND ( (accum count goods.artic)  modulo cdpcknum)  = 0 then do:
          run get-stop-state in p-log-handle (output v-stop).
          if v-stop then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("!!!Процедура пересылки остановлена пользователем"
                                    )
                                      ).
            leave _gds-obj.
          end.
          else do:
            /*пошлем те cash-gds, которые успели сделать*/
            assign
            error-status:error = no.
            if cr > 0 then
            RUN SENDING no-error.
            {&sending-error}.
            /*вернемся к первому и начнем писать в таблицу с головы*/
            assign
            start-paket = yes
            start-paket-txr = yes
            cr = 0
            crgd = 0
            cr-txr = 0
            cr-ncr-dis-kat = 0
            .
          end.
        end. /* (accum count goods.artic)  modulo cdpcknum)  = 0 */
    END. /*for each gds-obj*/
END. /*ВСЕ ПРОХОДИВШИЕ*/
ELSE DO:
/*по списку*/
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Подготовка данных")
                                          ).

assign
v-count = 0.

_gds-list:
FOR EACH gds-list :
    /*if v-is-restaurant then do:
      find first buf_fbr-gds-obj no-lock where
                 buf_fbr-gds-obj.obj-type = {&shop}
             AND buf_fbr-gds-obj.obj-code = i-obj-code
             AND buf_fbr-gds-obj.gds-code = gds-list.gds-code no-error .
      if not available buf_fbr-gds-obj
      then NEXT _gds-list.
    end.*/
    assign
    v-count = v-count + 1.
    if v-count modulo 10 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - товар &2 &3&4"
                                          , v-count
                                          , gds-list.artic
                                          , gds-list.prod-type
                                          , gds-list.prod-code)) no-error.
    end.
    {&NEW-GOOD}
    FIND FIRST ub.goods No-LOCK WHERE
               ub.goods.artic = gds-list.artic AND
               ub.goods.prod-type = gds-list.prod-type AND
               ub.goods.prod-code = gds-list.prod-code No-ERROR.
    run get-prt-and-unit in this-procedure (
                                                input gds-list.prt-root
                                                ,input gds-list.unit-base
                                                ,output l-empty-scale
                                                ) .
    FIND FIRST ub.gds-obj WHERE
               ub.gds-obj.obj-type = {&shop} AND
               ub.gds-obj.obj-code = i-obj-code AND
               ub.gds-obj.artic = gds-list.artic AND
               ub.gds-obj.prod-type = gds-list.prod-type AND
               ub.gds-obj.prod-code = gds-list.prod-code nO-LOCK NO-ERROR.
/*    if serv-elm and LOOKUP({&petrolium}, ub.units.type) > 0  and new-good then do:*/
/*      run get-rcp-string in this-procedure(                                       */
/*                                            input gds-list.artic                  */
/*                                            ,input gds-list.prod-type             */
/*                                            ,input gds-list.prod-code             */
/*                                            ,output rcp-string                    */
/*                                          ) no-error .                            */
/*      if return-value = "NEXT":U then next _gds-list.                             */
/*    end.                                                                          */
&scop buffer-name ub.gds-obj
&scop find-option no
&scop gds-code-field ub.goods.gds-code
    {&get-gds-obj-fields}

    RUN term-prt( ub.gds-prt.prt-root,  ?) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Ошибка при обработке товара &1 &2&3"
                              , gds-list.artic
                              , gds-list.prod-type
                              , gds-list.prod-code
                              )
                                ).
      assign
      v-view-log = yes
      .
    end.
    ACCUMULATE gds-list.artic (COUNT).
    if ( (accum count gds-list.artic)  modulo cdpcknum)  = 0 then do:
      run get-stop-state in p-log-handle (output v-stop).
      if v-stop then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!Процедура пересылки остановлена пользователем"
                                )
                                  ).
        leave _gds-list.
      end.
      else do:
        assign
        error-status:error = no.
        /*пошлем те cash-gds, которые успели сделать*/
        if cr > 0 then
        RUN SENDING no-error.
        {&sending-error}.
        /*вернемся к первому и начнем писать в таблицу с головы*/
        assign
        start-paket = yes
        cr = 0
        crgd = 0
        start-paket-txr = yes
        cr-txr = 0
        cr-ncr-dis-kat = 0
        .
      end.
    end. /* (accum count gds-list.artic)  modulo cdpcknum)  = 0 */
END . /*for each gds-list*/
end. /*по списку*/

assign
error-status:error = no.
/*пошлем те cash-gds, которые успели сделать но еще не послали*/
if cr > 0 and not v-stop then
RUN SENDING no-error.
{&sending-error}.

/*нужно ли стирать temp-table?*/
FOR EACH cash-gds :
    delete cash-gds.
END.
FOR EACH cash-txr :
    delete cash-txr.
END.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Удалены товары c касс объекта &1&2", {&shop}, i-obj-code)
                                          ).

/* $Workfile$ e n d */