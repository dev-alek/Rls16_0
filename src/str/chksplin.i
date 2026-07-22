/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита деления чеков на товары  по РКЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/05
Author: Bakhtadze Natalya
Creation date: 10/20/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-goods no-undo
field doc-code like ub.chk-gds.doc-code
field line-num like ub.chk-gds.line-num
field object-sum like ub.chk-discnt.object-sum
index pi is unique primary
doc-code
line-num.

define temp-table temp-chk-doc no-undo
field orig-doc-code like ub.chk-doc.doc-code
field doc-code like ub.chk-doc.doc-code
field obj-type like ub.chk-doc.obj-type
field obj-code like ub.chk-doc.obj-code
field netto    like ub.chk-doc.netto
index pi is unique primary
doc-code
index idoc-code orig-doc-code
.


procedure chksplin :
define parameter buffer buf_chk-doc for ub.chk-doc.
define input  parameter p-d-card-mode   as integer no-undo .
/*1 - оставлять карту только на разбиваемом чеке*/
/*2 - оставлять карту только на новом чеке*/
/*3 - оставлять карту на новом и разбиваемом чеке*/
define output parameter p-nf-gds-amount as integer no-undo .


DEFINE VARIABLE current-line-num like ub.chk-discnt.line-num no-undo .
DEFINE VARIABLE current-line-num-bonus like ub.chk-discnt.line-num no-undo .
define variable v-proprietor-host-code as integer no-undo .
define variable v-proprietor-obj-code as integer no-undo .
define variable v-proprietor-obj-type as character no-undo .
define variable v-gran as integer no-undo .
define variable v-new-doc-code as character no-undo .
define variable v-ratio as decimal no-undo .
define variable v-ratio-bonus as decimal no-undo .
define variable v-object-sum as decimal no-undo .
define variable v-object-sum-bonus as decimal no-undo .
define variable v-object-sump as decimal no-undo .
define variable v-object-sump-bonus as decimal no-undo .
define variable v-num-docs  as integer no-undo .
define variable v-ii as integer no-undo .
define buffer bufp_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer bufp_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer bufp_chk-pay for ub.chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer bufp_chk-discnt for ub.chk-discnt.
define buffer buf_bar-code for ub.bar-code.

define buffer bufp_temp-goods for temp-goods.

_main:
do
on error undo, return error return-value
:

  /*
  if buf_chk-doc.out-code = ? then do:
    undo, return error substitute("чек &1 НЕ привязан к продаже&2 разбить невоможно", buf_chk-doc.doc-code, {&new-line}).
  end.
  */
  /*убедимся что этот чек именно того типа что нам нужен - смесь товаров и услуг*/
  if not buf_chk-doc.office = {&gds-goods}
  and not buf_chk-doc.office = {&gds-office} then do:
     return substitute("чек &1 не может быть разбит на по отделам(магазинам)&2имеются ошибки в чеке&3"
                      ,buf_chk-doc.doc-code
                      ,{&new-line}
                      ,buf_chk-doc.office).
  end.
  for each buf_chk-gds where
          buf_chk-gds.doc-code = buf_chk-doc.doc-code
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    /*определим к какому предприятию относится товар*/
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = buf_chk-gds.b-code no-error .
    if not available buf_bar-code then do:
      undo _main, return error substitute("Не найден бар-код &1&2строка &3 чек &4 дата &5 касса &6 № на кассе&7"
                                          , buf_chk-gds.b-code
                                          , {&new-line}
                                          , buf_chk-gds.line-num
                                          , buf_chk-doc.doc-code
                                          , buf_Chk-doc.chk-date
                                          , buf_chk-doc.pay-desk
                                          , buf_chk-doc.chk-num).
    end.
    run tpsi-gds-proprietor in this-procedure (
                                                input buf_bar-code.gds-code
                                              ,input g#db-num
                                              ,output v-proprietor-host-code
                                              ,output v-proprietor-obj-type
                                              ,output v-proprietor-obj-code ) no-error.
    if error-status:error then do:
      undo _main, return error (substitute("Ошибка при получении принадлежности товара с кодом &1&2строка &3 чек &4 дата &5 касса &6 № на кассе&7&2"
                                          , buf_bar-code.gds-code
                                          , {&new-line}
                                          , buf_chk-gds.line-num
                                          , buf_chk-doc.doc-code
                                          , buf_Chk-doc.chk-date
                                          , buf_chk-doc.pay-desk
                                          , buf_chk-doc.chk-num) +
                                substitute("&1&2&3&2"
                                            , error-status:get-message(1)
                                            , {&new-line}
                                            , return-value ))
                                          .
    end.
    if v-proprietor-obj-code = 0
    or v-proprietor-obj-code = ?
    then do:
      assign
      v-proprietor-obj-type = buf_chk-doc.obj-type
      v-proprietor-obj-code = buf_chk-doc.obj-code
      .
      { gbl/hostcode.i v-proprietor-obj-type v-proprietor-obj-code v-proprietor-host-code }
    end.
    assign
    v-gran = 0
    v-gran = if r-index(buf_chk-gds.doc-code, '-':U) > 0
             then r-index(buf_chk-gds.doc-code, '-':U)
             else 0
    v-new-doc-code = (if v-gran > 0
                     then substring(buf_chk-gds.doc-code, 1, v-gran - 1)
                     else buf_chk-gds.doc-code) + '>' + string(v-proprietor-obj-code).
    find first temp-chk-doc where
              temp-chk-doc.doc-code = v-new-doc-code
          and temp-chk-doc.obj-type = v-proprietor-obj-type
          and temp-chk-doc.obj-code = v-proprietor-obj-code no-error .
    if not available temp-chk-doc then do:
      create temp-chk-doc.
      assign
      temp-chk-doc.orig-doc-code = buf_chk-doc.doc-code
      temp-chk-doc.doc-code = v-new-doc-code
      temp-chk-doc.obj-type = v-proprietor-obj-type
      temp-chk-doc.obj-code = v-proprietor-obj-code
      v-num-docs            = v-num-docs + 1
      .
      create bufp_chk-doc.
      buffer-copy buf_chk-doc
      except
      obj-type obj-code doc-code
      netto tot-doc discnt sub-discnt out-code
      d-card src-d-card cli-type src-cli-type cli-code src-cli-code
      to bufp_chk-doc
      assign
      bufp_chk-doc.doc-code = v-new-doc-code
      bufp_chk-doc.obj-type = v-proprietor-obj-type
      bufp_chk-doc.obj-code = v-proprietor-obj-code
      bufp_chk-doc.PS = buf_chk-doc.ps + "@":U + "split":U
      .
      if p-d-card-mode = 2
      or p-d-card-mode = 3
      then do:
        assign
        bufp_chk-doc.d-card       = buf_chk-doc.d-card
        bufp_chk-doc.src-d-card   = buf_chk-doc.src-d-card
        bufp_chk-doc.cli-type     = buf_chk-doc.cli-type
        bufp_chk-doc.src-cli-type = buf_chk-doc.src-cli-type
        bufp_chk-doc.cli-code     = buf_chk-doc.cli-code
        bufp_chk-doc.src-cli-code = buf_chk-doc.src-cli-code
        .
      end.
    end.
    else do:
      find first bufp_chk-doc where
                bufp_chk-doc.doc-code = v-new-doc-code
            and bufp_chk-doc.obj-type = v-proprietor-obj-type
            and bufp_chk-doc.obj-code = v-proprietor-obj-code no-error .
    end.
    create bufp_chk-gds .
    create temp-goods.
    create bufp_temp-goods.
    buffer-copy buf_chk-gds
    except doc-code out-code
    d-card src-d-card cli-type src-cli-type cli-code src-cli-code
    to bufp_chk-gds
    assign
    bufp_chk-gds.doc-code = v-new-doc-code
    bufp_chk-doc.netto    = bufp_chk-doc.netto + (bufp_chk-gds.price-base - bufp_chk-gds.discnt ) * bufp_chk-gds.doc-qnty
    temp-chk-doc.netto    = bufp_chk-doc.netto
    bufp_chk-doc.tot-doc  = bufp_chk-doc.tot-doc + bufp_chk-gds.price-base * bufp_chk-gds.doc-qnty
    bufp_chk-doc.discnt   = bufp_chk-doc.discnt + bufp_chk-gds.discnt * bufp_chk-gds.doc-qnty
    bufp_chk-doc.sub-discnt   = bufp_chk-doc.sub-discnt +  (if bufp_chk-gds.write-off-code <> 0
                                                        and bufp_chk-gds.write-off-code <> ?
                                                        then ((if bufp_chk-gds.write-off-code > 0 then 1 else - 1) *
                                                                bufp_chk-gds.src-qnty * (bufp_chk-gds.src-price - bufp_chk-gds.src-discnt)
                                                              )
                                                        else 0)
    temp-goods.line-num    = buf_chk-gds.line-num
    temp-goods.doc-code    = buf_chk-gds.doc-code
    temp-goods.object-sum  = buf_chk-gds.src-price * buf_chk-gds.src-qnty
    bufp_temp-goods.line-num    = buf_chk-gds.line-num
    bufp_temp-goods.doc-code    = bufp_chk-gds.doc-code
    bufp_temp-goods.object-sum  = bufp_chk-gds.src-price * bufp_chk-gds.src-qnty
    .
    if p-d-card-mode = 2
    or p-d-card-mode = 3
    then do:
      assign
      bufp_chk-gds.d-card       = buf_chk-gds.d-card
      bufp_chk-gds.src-d-card   = buf_chk-gds.src-d-card
      bufp_chk-gds.cli-type     = buf_chk-gds.cli-type
      bufp_chk-gds.src-cli-type = buf_chk-gds.src-cli-type
      bufp_chk-gds.cli-code     = buf_chk-gds.cli-code
      bufp_chk-gds.src-cli-code = buf_chk-gds.src-cli-code
      .
    end.
    if p-d-card-mode = 2 then do:
      assign
      buf_chk-gds.d-card       = '':U
      buf_chk-gds.src-d-card   = '':U
      buf_chk-gds.cli-type     = '':U
      buf_chk-gds.src-cli-type = '':U
      buf_chk-gds.cli-code     = 0
      buf_chk-gds.src-cli-code = 0
      .
    end.
    release bufP_chk-doc.
    release bufp_chk-gds.
    release temp-chk-doc.
    p-nf-gds-amount = p-nf-gds-amount + 1.
  end.
  for each buf_chk-pay where
              buf_chk-pay.doc-code = buf_chk-doc.doc-code,
    each temp-chk-doc where temp-chk-doc.orig-doc-code = buf_chk-doc.doc-code
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
    v-ratio = temp-chk-doc.netto / buf_chk-doc.netto.
    if v-ratio <> 0 then do:
      find first bufP_chk-pay where
                bufp_chk-pay.doc-code = temp-chk-doc.doc-code
          and  bufp_chk-pay.line-num = buf_chk-pay.line-num no-error.
      if not available bufp_chk-pay then do:
        create bufp_chk-pay.
        buffer-copy buf_chk-pay
        except doc-code obj-type obj-code tot-sum tot-rubl tot-base out-code
        to
        bufp_chk-pay
        assign
        bufp_chk-pay.doc-code = temp-chk-doc.doc-code
        bufp_chk-pay.obj-type = temp-chk-doc.obj-type
        bufp_chk-pay.obj-code = temp-chk-doc.obj-code
        bufp_chk-pay.tot-sum =  buf_chk-pay.tot-sum  * v-ratio
        bufp_chk-pay.tot-rubl =  buf_chk-pay.tot-rubl * v-ratio
        bufp_chk-pay.tot-base =  buf_chk-pay.tot-base  * v-ratio
        .
      end.
    end.
  end.
  for each bufp_chk-doc where
         bufp_chk-doc.doc-code begins (buf_chk-doc.doc-code + '>')
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))

  :
    assign
    current-line-num = 0
    current-line-num-bonus = 0
    v-object-sum  = 0
    v-object-sump = 0
    v-ii = v-ii + 1
    .
    _buf_chk-discnt:
    for each buf_chk-discnt where
              buf_chk-discnt.doc-code = buf_chk-doc.doc-code
    by buf_chk-discnt.line-num
    by buf_chk-discnt.discnt-id
    by abs(buf_chk-discnt.object-line-num)
    by buf_chk-discnt.object-line-num
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      CASE buf_chk-discnt.record-type:
        when 0 then do:
          for each temp-goods no-lock where
                  abs(temp-goods.line-num) > abs(current-line-num)
              and abs(temp-goods.line-num) <= abs(buf_chk-discnt.line-num):
            assign
            v-object-sum = v-object-sum + temp-goods.object-sum
            .
            if temp-goods.doc-code = bufp_chk-doc.doc-code
            then do:
              assign
              v-object-sump = v-object-sump + temp-goods.object-sum
              .
            end.
          end. /*for each temp-goods no-lock where*/
          assign
          v-ratio = v-object-sump / v-object-sum
          .
          assign
          current-line-num = buf_chk-discnt.line-num
          .
          if buf_chk-discnt.line-type = integer({&discnt-gds})
          and can-find(first temp-goods where
                              temp-goods.doc-code = bufp_chk-doc.doc-code
                          and temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
          end. /*if buf_chk-discnt.line-type = integer({&discnt-gds}) then do:*/
          else do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
            CASE buf_chk-discnt.line-type:
              when integer({&discnt-sub-total})
              or
              when integer({&discnt-total}) then do:
                /*надо знать отношение goods/office object-sum для каждой скидки */
                assign
                bufp_chk-discnt.object-sum = v-ratio * buf_chk-discnt.object-sum
                bufp_chk-discnt.discnt-value-abs = v-ratio * buf_chk-discnt.discnt-value-abs
                bufp_chk-discnt.discnt-value-pcnt =  if bufp_chk-discnt.object-sum <> 0
                                                    then bufp_chk-discnt.discnt-value-abs / bufp_chk-discnt.object-sum * 100
                                                    else 0
                .
              end.
              when integer({&discnt-receipt})
              or
              when integer({&discnt-payment}) then do:
                assign
                bufp_chk-discnt.discnt-value-abs = buf_chk-discnt.discnt-value-abs * bufp_chk-doc.netto / buf_chk-doc.netto
                bufp_chk-discnt.object-sum       = buf_chk-discnt.discnt-value-abs * bufp_chk-doc.netto / buf_chk-doc.netto
                bufp_chk-discnt.discnt-value-pcnt =  if bufp_chk-discnt.object-sum <> 0
                                                      then bufp_chk-discnt.discnt-value-abs / bufp_chk-discnt.object-sum * 100
                                                      else 0
                .
              end.
            END CASE. /*CASE buf_chk-discnt.line-type: */
          end. /* not   if buf_chk-discnt.line-type = integer({&discnt-gds}) then do:*/
        end. /*when 0*/
        when 1
        or
        when 2
        then do:
          if can-find(first temp-goods where
                            temp-goods.doc-code = bufp_chk-doc.doc-code
                        and temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
          end.
        end.  /*when 1 or when 2*/
        when 4 then do:
          for each temp-goods no-lock where
                  abs(temp-goods.line-num) > abs(current-line-num-bonus)
              and abs(temp-goods.line-num) <= abs(buf_chk-discnt.line-num):
            assign
            v-object-sum-bonus = v-object-sum-bonus + temp-goods.object-sum
            .
            if temp-goods.doc-code = bufp_chk-doc.doc-code
            then do:
              assign
              v-object-sump-bonus = v-object-sump-bonus + temp-goods.object-sum
              .
            end.
          end. /*for each temp-goods no-lock where*/
          assign
          v-ratio-bonus = v-object-sump-bonus / v-object-sum-bonus
          .
          assign
          current-line-num-bonus = buf_chk-discnt.line-num
          .
          if buf_chk-discnt.line-type = integer({&discnt-gds})
          and can-find(first temp-goods where
                              temp-goods.doc-code = bufp_chk-doc.doc-code
                          and temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
          end. /*if buf_chk-discnt.line-type = integer({&discnt-gds}) then do:*/
          else do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
            CASE buf_chk-discnt.line-type:
              when integer({&discnt-sub-total})
              or
              when integer({&discnt-total}) then do:
                /*надо знать отношение goods/office object-sum для каждой скидки */
                assign
                bufp_chk-discnt.object-sum = v-ratio-bonus * buf_chk-discnt.object-sum
                bufp_chk-discnt.discnt-value-abs = v-ratio-bonus * buf_chk-discnt.discnt-value-abs
                bufp_chk-discnt.discnt-value-pcnt =  if bufp_chk-discnt.object-sum <> 0
                                                    then bufp_chk-discnt.discnt-value-abs / bufp_chk-discnt.object-sum * 100
                                                    else 0
                .
              end.
              when integer({&discnt-receipt})
              or
              when integer({&discnt-payment}) then do:
                assign
                bufp_chk-discnt.discnt-value-abs = buf_chk-discnt.discnt-value-abs * bufp_chk-doc.netto / buf_chk-doc.netto
                bufp_chk-discnt.object-sum       = buf_chk-discnt.discnt-value-abs * bufp_chk-doc.netto / buf_chk-doc.netto
                bufp_chk-discnt.discnt-value-pcnt =  if bufp_chk-discnt.object-sum <> 0
                                                      then bufp_chk-discnt.discnt-value-abs / bufp_chk-discnt.object-sum * 100
                                                      else 0
                .
              end.
            END CASE. /*CASE buf_chk-discnt.line-type: */
          end. /* not   if buf_chk-discnt.line-type = integer({&discnt-gds}) then do:*/
        end. /*when 4*/
        when 5  then do:
          if can-find(first temp-goods where
                            temp-goods.doc-code = bufp_chk-doc.doc-code
                        and temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
          end.
        end.  /*when 5*/
      END CASE. /*CASE buf_chk-discnt.record-type:*/
      if available bufp_chk-discnt then do:
        if p-d-card-mode = 2
        or p-d-card-mode = 3
        then do:
          assign
          bufp_chk-discnt.d-card       = buf_chk-discnt.d-card
          bufp_chk-discnt.src-d-card   = buf_chk-discnt.src-d-card
          .
        end.
        if p-d-card-mode = 2
        and v-ii = v-num-docs
        then do:
          assign
          buf_chk-discnt.d-card       = '':U
          buf_chk-discnt.src-d-card   = '':U
          .
        end.
      end.
    end. /*for each chk-discnt*/
  end. /*for each buf_chkp_Doc*/
  if p-d-card-mode = 2 then do:
    assign
    buf_chk-doc.d-card       = '':U
    buf_chk-doc.src-d-card   = '':U
    buf_chk-doc.cli-type     = '':U
    buf_chk-doc.src-cli-type = '':U
    buf_chk-doc.cli-code     = 0
    buf_chk-doc.src-cli-code = 0
    .
  end.
  assign
  buf_chk-doc.chk-type = (if buf_chk-doc.chk-type > 0 and buf_chk-doc.chk-type < 100
                         then (buf_chk-doc.chk-type + 100)
                         else buf_chk-doc.chk-type)
  .
  return ''.
end. /*doe*/

end procedure. /* chksplin */