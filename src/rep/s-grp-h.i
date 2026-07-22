/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обший код для печати почасового отчета по сумма продаж  XL-delim и во frame

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/02/05
Author: Bakhtadze Natalya
Creation date: 09/02/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer tot_full-grp for full-grp.

for each obj-list no-lock:
  assign
  accum-obj-list = accum-obj-list + 1.
  if accum-obj-list > 1 then LEAVE.
end.


IF METHOD = "GOODS" then WIth-goods = yes.
else with-goods = no.
CASE method:
  when "pay-desk":U then do:
    for each ub.cash-desk no-lock :
      if X-SelectObject = {&all} then.
      else do:
        find first obj-list No-LOCK WHERE
                  obj-list.obj-code = ub.cash-desk.obj-code AND
                  obj-list.obj-type = {&shop} No-ERROR.
        if not available obj-list then next.
      end.
      create full-grp.
      assign
      full-grp.grp-code =   ub.cash-desk.cash-num
      full-grp.other-code = ub.cash-desk.obj-code
      full-grp.full-name = substitute("БД_&1_маг_&2_Касса_&3"
                                                ,  ub.cash-desk.db-num
                                                ,  ub.cash-desk.obj-code
                                                ,  ub.cash-desk.cash-num)
      .
    end. /* for each cash-desk no-lock :*/
    create full-grp.
    assign
    full-grp.grp-code =   0
    full-grp.other-code = 0
    full-grp.full-name = '':U
    .

  end. /*when pay-desk*/
  when "pays":U then do:
    for each ub.cash-pay No-LOCK:
      create full-grp.
      assign
      full-grp.obj-code = 0
      full-grp.grp-code = ub.cash-pay.cdpay-code
      full-grp.other-code = ub.cash-pay.curr-code
      .
      FIND FIRST ub.currency No-LOCK WHERE
                ub.currency.curr-code = ub.cash-pay.curr-code no-error.
      full-grp.full-name = substitute("&1_Валюта_&2"
                                      , ub.cash-pay.obj-name
                                      ,(if available ub.currency
                                        then ub.currency.curr-abbr
                                        else string(cash-pay.curr-code))).
    end.
  end.
  when "GOODS" or
  when "GROUPS" then do:
    run waitfram-show in this-procedure ("Строю дерево групп ..."). /*пробелы не стирать!!!*/
    for each ub.gds-grp no-lock:
      find first for-grp where
                for-grp.upper-code = ub.gds-grp.node-code No-LOCK No-ERROR.
      if not avail for-grp then do:
        create full-grp.
        assign
        full-grp.obj-code = 0
        full-grp.grp-code = ub.gds-grp.node-code.
        if tree then
        run grplib-get-full-name in this-procedure(input ub.gds-grp.node-code, output full-grp.full-name).
        else
        full-grp.full-name = ub.gds-grp.node-name.
        full-grp.full-name = replace(full-grp.full-name, " ", "_").
      end.
    end.
    run waitfram-hide in this-procedure .
  end. /*goods groups*/
end CASE.

/*вплоть до дальнейшего распоряжения*/
if method <> "TOTALS":U and method <> "pays":U then do:
  for each grp-h :
    assign
    grp-h.sum[1] = grp-h.sum[1] - grp-h.sum_disc[1]
    grp-h.sum[2] = grp-h.sum[2] - grp-h.sum_disc[2]
    grp-h.sum[3] = grp-h.sum[3] - grp-h.sum_disc[3]
    grp-h.sum[4] = grp-h.sum[4] - grp-h.sum_disc[4]
    grp-h.sum[5] = grp-h.sum[5] - grp-h.sum_disc[5]
    grp-h.sum[6] = grp-h.sum[6] - grp-h.sum_disc[6]
    grp-h.sum[7] = grp-h.sum[7] - grp-h.sum_disc[7]
    grp-h.sum[8] = grp-h.sum[8] - grp-h.sum_disc[8]
    grp-h.sum[9] = grp-h.sum[9] - grp-h.sum_disc[9]
    grp-h.sum[10] = grp-h.sum[10] - grp-h.sum_disc[10]
    grp-h.sum[11] = grp-h.sum[11] - grp-h.sum_disc[11]
    grp-h.sum[12] = grp-h.sum[12] - grp-h.sum_disc[12]
    grp-h.sum[13] = grp-h.sum[13] - grp-h.sum_disc[13]
    grp-h.sum[14] = grp-h.sum[14] - grp-h.sum_disc[14]
    grp-h.sum[15] = grp-h.sum[15] - grp-h.sum_disc[15]
    grp-h.sum[16] = grp-h.sum[16] - grp-h.sum_disc[16]
    grp-h.sum[17] = grp-h.sum[17] - grp-h.sum_disc[17]
    grp-h.sum[18] = grp-h.sum[18] - grp-h.sum_disc[18]
    grp-h.sum[19] = grp-h.sum[19] - grp-h.sum_disc[19]
    grp-h.sum[20] = grp-h.sum[20] - grp-h.sum_disc[20]
    grp-h.sum[21] = grp-h.sum[21] - grp-h.sum_disc[21]
    grp-h.sum[22] = grp-h.sum[22] - grp-h.sum_disc[22]
    grp-h.sum[23] = grp-h.sum[23] - grp-h.sum_disc[23]
    grp-h.sum[24] = grp-h.sum[24] - grp-h.sum_disc[24]
    .
  end.
END.
for each gds-h:
  assign
  gds-h.sum[1] = gds-h.sum[1] - gds-h.sum_disc[1]
  gds-h.sum[2] = gds-h.sum[2] - gds-h.sum_disc[2]
  gds-h.sum[3] = gds-h.sum[3] - gds-h.sum_disc[3]
  gds-h.sum[4] = gds-h.sum[4] - gds-h.sum_disc[4]
  gds-h.sum[5] = gds-h.sum[5] - gds-h.sum_disc[5]
  gds-h.sum[6] = gds-h.sum[6] - gds-h.sum_disc[6]
  gds-h.sum[7] = gds-h.sum[7] - gds-h.sum_disc[7]
  gds-h.sum[8] = gds-h.sum[8] - gds-h.sum_disc[8]
  gds-h.sum[9] = gds-h.sum[9] - gds-h.sum_disc[9]
  gds-h.sum[10] = gds-h.sum[10] - gds-h.sum_disc[10]
  gds-h.sum[11] = gds-h.sum[11] - gds-h.sum_disc[11]
  gds-h.sum[12] = gds-h.sum[12] - gds-h.sum_disc[12]
  gds-h.sum[13] = gds-h.sum[13] - gds-h.sum_disc[13]
  gds-h.sum[14] = gds-h.sum[14] - gds-h.sum_disc[14]
  gds-h.sum[15] = gds-h.sum[15] - gds-h.sum_disc[15]
  gds-h.sum[16] = gds-h.sum[16] - gds-h.sum_disc[16]
  gds-h.sum[17] = gds-h.sum[17] - gds-h.sum_disc[17]
  gds-h.sum[18] = gds-h.sum[18] - gds-h.sum_disc[18]
  gds-h.sum[19] = gds-h.sum[19] - gds-h.sum_disc[19]
  gds-h.sum[20] = gds-h.sum[20] - gds-h.sum_disc[20]
  gds-h.sum[21] = gds-h.sum[21] - gds-h.sum_disc[21]
  gds-h.sum[22] = gds-h.sum[22] - gds-h.sum_disc[22]
  gds-h.sum[23] = gds-h.sum[23] - gds-h.sum_disc[23]
  gds-h.sum[24] = gds-h.sum[24] - gds-h.sum_disc[24]
  .
end.


/* $Workfile$ e n d */