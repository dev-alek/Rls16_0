block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-sertif.p $
$Archive: rep/r-sertif.p $

Отчет по сертификатам (скидкам)

Автор: Шальнев Иван Сергеевич
Дата создания: 31/05/11
Author: Shalnev ivan
Creation date: 31/05/11

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-sertif.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-sertif.p $":U .
define variable vss-description as character no-undo init "Отчет по сертификатам (скидкам) (закладка № 2)".

define input parameter parparentproc as widget-handle  no-undo .
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter xsorttype     as character no-undo.
define input parameter p-str-nominal as character no-undo.

define temp-table tt-sertif no-undo
field obj-type       as character
field obj-code       as integer
field cash-num       as integer
field cash-chk-num   as integer
field chk-date       as date
field th-chk-num     as character
field cashier        as character
field chk-sum        as decimal
field discount       as decimal
field other-discount as decimal
field sum-netto      as decimal
.

define buffer buf_chk-doc    for ub.chk-doc .
define buffer buf_clients    for ub.clients .
define buffer buf_chk-discnt for ub.chk-discnt .
define buffer buf1_chk-discnt for ub.chk-discnt .

define variable Counter1        as integer   no-undo.
define variable v-tot-chk-sum   as decimal   no-undo.
define variable v-tot-discount  as decimal   no-undo.
define variable v-tot-sum-netto as decimal   no-undo.
define variable v-tot-chk       as integer   no-undo.
define variable v-free-balance  as decimal   no-undo.
define variable ii              as integer   no-undo.
define variable jj              as integer   no-undo.
define variable v-log           as logical   no-undo.
define variable v-log-2         as logical   no-undo.

&scop frame-name sertif

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i "new shared" }
{ rep/r-sym.i    }
{ cmp/breakstr.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ cmp/r-page1.i  }

do
on error undo, return error :

  run prn-lib-open-stream  in this-procedure
    ( input parParentProc
    , input {&LS_PS_A4}
    , input yes /*p-is-stream*/
    , input no /*p-append*/
    ).
  jj = 0 .
  for each sheetf :
    delete sheetf.
  end.

  assign  Counter1 = 0 .
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
  assign
    v-tot-chk-sum   = 0
    v-tot-discount  = 0
    v-tot-sum-netto = 0
    v-tot-chk       = 0
    v-log = yes
  .
  if x-date-start > today or x-date-end > today then do :
    message
      "Отчет по сертификатам не может быть снят за будущий период"
    view-as alert-box error.
    undo.
  end.
  { gbl/getcntxt.i get }

  for each obj-list no-lock :
    if v-cntxt-db-num = 0 then do :
      find first buf_clients no-lock
          where buf_clients.obj-type = obj-list.obj-type
            and buf_clients.obj-code = obj-list.obj-code no-error.
      if available buf_clients and buf_clients.db-num <> 0 then do :
        find first ub.db no-lock
            where ub.db.db-num = buf_clients.db-num no-error.
        if available ub.db and ub.db.send-check = no then do :
          message
            "По БД №" buf_clients.db-num " отключена пересылка чеков." skip
            "Данные по объекту " obj-list.obj-type obj-list.obj-code " будут нулевыми." skip
            "Продолжить формирование отчета?" skip
            view-as alert-box question buttons yes-no update v-log
          .
        end.
      end.
    end.
    if v-log = no then do :
      undo.
    end.

     do ii = 1 to num-entries(p-str-nominal):
       if entry(ii,p-str-nominal) = "100%" then do :
                                             v-log-2 = true .
                                           end.
                                           else do :
                                             v-log-2 = false .
                                           end.
       for each buf_chk-doc where
               buf_chk-doc.obj-code = obj-list.obj-code
           and buf_chk-doc.obj-type = obj-list.obj-type
           and buf_chk-doc.chk-type = 1
           and buf_chk-doc.chk-date >= x-date-start
           and buf_chk-doc.chk-date <= x-date-end no-lock
           :
             if v-log-2 = true then do :
                find first buf_chk-discnt no-lock
                      where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
                        and buf_chk-discnt.discnt-type = 2
                        and ( buf_chk-discnt.pass-discnt = 0 or buf_chk-discnt.pass-discnt = 1 )
                        and buf_chk-discnt.value-type = 1
                        and buf_chk-discnt.discnt-value-pcnt = 100 no-error.
             end.
             else do :
                find first buf_chk-discnt no-lock
                      where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
                        and buf_chk-discnt.discnt-type = 2
                        and ( buf_chk-discnt.pass-discnt = 0 or buf_chk-discnt.pass-discnt = 1 )
                        and buf_chk-discnt.value-type  = 2
                        and buf_chk-discnt.discnt-value-abs = decimal(entry(ii,p-str-nominal)) no-error.
             end.
             if available buf_chk-discnt then do :
                find first buf_clients no-lock
                    where buf_clients.obj-code = buf_chk-doc.cashier-psn-code
                      and buf_clients.obj-type = {&prs} no-error.
                create tt-sertif.
                assign
                  tt-sertif.obj-type        = buf_chk-doc.obj-type
                  tt-sertif.obj-code        = buf_chk-doc.obj-code
                  tt-sertif.cash-num        = buf_chk-doc.pay-desk
                  tt-sertif.cash-chk-num    = buf_chk-doc.chk-num
                  tt-sertif.chk-date        = buf_chk-doc.chk-date
                  tt-sertif.th-chk-num      = buf_chk-doc.doc-code
                  tt-sertif.cashier         = buf_clients.obj-name
                  tt-sertif.chk-sum         = buf_chk-doc.tot-doc
                  tt-sertif.discount        = buf_chk-discnt.discnt-value-abs
                  tt-sertif.other-discount  = buf_chk-doc.discnt - buf_chk-discnt.discnt-value-abs
                  tt-sertif.sum-netto       = buf_chk-doc.netto
                .
             end.
        end.
     end.
  end.
  for each obj-list no-lock :
    jj = jj + 1.
    find first sheetf where sheetf.sheet-num = jj no-error.
    if not available sheetf then do :
      create sheetf.
      assign
        sheetf.sheet-num = jj
      .
      run print-header(input jj).
      case xsorttype :
        when "sort-cahs-num" then do :
          for each tt-sertif
              where tt-sertif.obj-code = obj-list.obj-code
                and tt-sertif.obj-type = obj-list.obj-type
                break by tt-sertif.obj-code by tt-sertif.obj-type by tt-sertif.cash-num :
                assign
                  v-tot-chk-sum = v-tot-chk-sum + tt-sertif.chk-sum
                  v-tot-discount = v-tot-discount + tt-sertif.discount
                  v-tot-sum-netto = v-tot-sum-netto + tt-sertif.sum-netto
                  v-tot-chk = v-tot-chk + 1
                .
            run print-line.
          end.
        end.
        when "sort-cashier" then do :
          for each tt-sertif
              where tt-sertif.obj-code = obj-list.obj-code
                and tt-sertif.obj-type = obj-list.obj-type
                break by tt-sertif.obj-code by tt-sertif.obj-type by tt-sertif.cashier :
                assign
                  v-tot-chk-sum = v-tot-chk-sum + tt-sertif.chk-sum
                  v-tot-discount = v-tot-discount + tt-sertif.discount
                  v-tot-sum-netto = v-tot-sum-netto + tt-sertif.sum-netto
                  v-tot-chk = v-tot-chk + 1
                .
            run print-line.
          end.
        end.
        when "sort-disc" then do :
          for each tt-sertif
              where tt-sertif.obj-code = obj-list.obj-code
                and tt-sertif.obj-type = obj-list.obj-type
                break by tt-sertif.obj-code by tt-sertif.obj-type by tt-sertif.discount :
                assign
                  v-tot-chk-sum   = v-tot-chk-sum + tt-sertif.chk-sum
                  v-tot-discount  = v-tot-discount + tt-sertif.discount
                  v-tot-sum-netto = v-tot-sum-netto + tt-sertif.sum-netto
                  v-tot-chk       = v-tot-chk + 1
                .
            run print-line.
          end.
        end.
      end case.
      {&PutExcel}
            {&tabulation}
            {&tabulation}
            {&tabulation}
            {&tabulation}
        "Итого:"             {&tabulation}
        v-tot-chk-sum        {&tabulation}
        v-tot-discount       {&tabulation}
                             {&tabulation}
        v-tot-sum-netto      {&tabulation}
        skip.

        {&PutExcel}
        skip.
        {&PutExcel}
        skip.
        {&PutExcel}
        "Всего оплачено сертификатами " + string(v-tot-chk) + " чеков" skip.
        {&PutExcel}
        "Скидка на общую сумму " + string(v-tot-discount) + " рублей" skip.
      {&pageexcel}
      assign
        v-tot-chk-sum   = 0
        v-tot-discount  = 0
        v-tot-sum-netto = 0
        v-tot-chk       = 0
      .
    end.
  end.
  {&CloseExcel}
  output stream PrnLibStream close.
  { gbl/stopwork.i }
  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 20
                                          ).
end.

procedure print-header :
define input parameter p-page-num as integer no-undo.
find first sheetf where sheet-num = p-page-num /*no-error*/.

    assign
    Sheetf.MergeCellsH = ""
    Sheetf.MergeCellsV = ""
    Sheetf.Excel-Column-Lable = "№ ККМ" + {&comma-char} +
                         "№ чека по ККМ" + {&comma-char} +
                         "Дата" + {&comma-char} +
                         "№ чека в Trade House" + {&comma-char} +
                         "Кассир" + {&comma-char} +
                         "Сумма по чеку" + {&comma-char} +
                         "Сертификат(Скидка)" + {&comma-char} +
                         "Прочие скидки" + {&comma-char} +
                         "Сумма оплат (нетто)"
    Sheetf.Sizes = "8,8,14,20,25,25,25,25,25"
    Sheetf.colformat = "1=0;2=0;3=dd/mm/yyyy;4=0;5=@;6=0,00;7=0,00;8=0,00;9=0,00"
    .
  str4 = "По объекту: " + obj-list.obj-type + string(obj-list.obj-code) + " " + obj-list.obj-name.
  RUN rep/extitle.p (p-page-num).
  if p-page-num = 1 then do :
    put stream PrnLibStream unformatted
    reportNAme  + {&new-line}
                + str1 + str4 {&new-line}
                + ReportHeader.
  end.
end. /*procedure print-header*/

procedure print-line.
{&PutExcel}
   tt-sertif.cash-num        {&tabulation}
   tt-sertif.cash-chk-num    {&tabulation}
   tt-sertif.chk-date        {&tabulation}
   tt-sertif.th-chk-num      {&tabulation}
   tt-sertif.cashier         {&tabulation}
   tt-sertif.chk-sum         {&tabulation}
   tt-sertif.discount        {&tabulation}
   tt-sertif.other-discount  {&tabulation}
   tt-sertif.sum-netto       {&tabulation}
   skip.

end.  /*procedure print-line*/