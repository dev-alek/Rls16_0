block-level on error undo, throw.
/*

$Revision: 6b96c295e5e2, 2873, rls $
$Author: VRukavishnikov $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: r-fin-doc-list.p $
$Archive: rep/r-fin-doc-list.p $

Список кассовых документов

Автор: Рукавишников Вадим
Дата создания: 27/01/21
Author: Rukavishnikov Vadim
Creation date: 27/01/21

*/
define input parameter iCntxtHostCodeObj as integer   no-undo.
define input parameter iDocStatus        as character no-undo.
define input parameter iDocType          as character no-undo.

define variable vss-revision    as character     no-undo init "$Revision: $":U .
define variable vss-author      as character     no-undo init "$Author: $":U .
define variable vss-date        as character     no-undo init "$Date: $":U .
define variable vss-workfile    as character     no-undo init "$Workfile: $":U .
define variable vss-archive     as character     no-undo init "$Archive: $":U .
define variable vss-description as character     no-undo init "Список кассовых документов".
define variable parparentproc   as widget-handle no-undo.
define variable mParamStr       as character     no-undo extent 10.

{cmp/vssrevis.i}
{cmp/str-glbl.i}
{cmp/r-page1.i}
{ref/fd-attr.i}
{cmp/trg-def.i}
{gbl/prn-lib.i "new shared"}

define temp-table tt-rep no-undo
   field host-code        as integer
   field shift            as character
   field shift-date       as date
   field prn-doc-code     as character
   field receiver         as character
   field receiver-name    as character
   field contract         as character
   field fin-doc-type     as character
   field doc-date         as date
   field fin-ext-doc-type as character
   field perm-date        as date
   field pay-date         as date
   field fact-date        as date
   field del-date         as date
   field status_          as character
   field sum-doc          as decimal
   field payer            as character
   field payer-name       as character
   field curr-abbr        as character
   field obj-info         as character
   field fio              as character
index pi host-code shift prn-doc-code.

define temp-table tt-fin-doc-attr no-undo
   field host-code    as integer
   field fin-doc-code as integer
   field shift-date   as date
index pi host-code fin-doc-code.

define stream sOutStr-html.

function fGetContract returns character
  (input iHostCode     as integer,
   input iContractCode as integer):
   define buffer bcontract for contract.
   define variable vPrnCode as character no-undo.

   find first bcontract where
              bcontract.host-code     = iHostCode
          AND bcontract.contract-code = iContractCode
   no-lock no-error.
   if available bcontract then
      vPrnCode = bcontract.contract-prn-code.

  return vprncode.
end function.

function fGetCurrency returns character
   (input iCurrCode as integer):
   define buffer bcurrency for currency.
   define variable vCurrAbbr as character no-undo.

   find first bcurrency where
              bcurrency.curr-code = iCurrCode
   no-lock no-error.
   if available bcurrency then
      vCurrAbbr = bcurrency.curr-abbr.
   else
      vCurrAbbr = string(iCurrCode).

   return vCurrAbbr.
end function.

function fDate2Str returns character
   (input idate as date,
    input iformat as char):
   define variable vdatestr as character no-undo.
   if idate = ? then
      vdatestr = "".
   else
      vdatestr = string(idate, iformat).

   return vdatestr.
end function.

function fDec2Str returns character
   (input idec as decimal,
    input iformat as char):
   define variable vdecstr as character no-undo.
   if idec = ? then
      vdecstr = "".
   else
      vdecstr = string(idec, iformat).

   return vdecstr.
end function.

function fInt2Str returns character
   (input iInt as integer,
    input iformat as char):
   define variable vIntStr as character no-undo.
   if iInt = ? then
      vIntStr = "".
   else
      vIntStr = string(iInt, iformat).

   return vIntStr.
end function.

function fStrNvl returns character
   (input iStr     as character,
    input iDefault as character):
   return if iStr > "" then iStr else iDefault.
end function.

/* MAIN */

run initTT.
run PrintTT.

procedure InitTT:
   define buffer fin-doc      for fin-doc.
   define buffer c-fin-doc    for c-fin-doc.
   define buffer fin-doc-attr for fin-doc-attr.
   define buffer user-account for user-account.

   define variable vShift    as character no-undo.
   define variable vI        as int64     no-undo.
   
   empty temp-table tt-fin-doc-attr.
   empty temp-table tt-rep.
   
   if x-tog-shift then do:
      vI = vI + 1.
      if X-shift-start = X-shift-end then
         mParamStr[vI] = "Смена: " + string(X-shift-start).
      else
         mParamStr[vI] = "Смены: c " + string(X-shift-start) + " по " + string(X-shift-end).
   end.
   
   vI = vI + 1.
   if X-date-start = X-date-end then
      mParamStr[vI] = "За дату : " + string(X-date-start, "99.99.9999").
   else
      mParamStr[vI] = "За период c " + string(X-date-start, "99.99.9999") + " по " + string(X-date-end, "99.99.9999").
   
   vI = vI + 1.
   mParamStr[vI] = "Выбор объекта: ".
   for each obj-list,
      first clients where
            clients.obj-type = obj-list.obj-type
        and clients.obj-code = obj-list.obj-code
   no-lock:
      mParamStr[vI] = mParamStr[vI] + "(" + obj-list.obj-type + string(obj-list.obj-code) + ")"
                                    + clients.obj-name + "," .
   end.
   mParamStr[vI] = trim(mParamStr[vI], ",").
   
   vI = vI + 1.
   mParamStr[vI] = "По типу документа: " + iDocType.
   
   vI = vI + 1.
   mParamStr[vI] = "По статусу документа: " + iDocStatus.

   if lookup(iDocStatus, "Все,факт") > 0 then do:
      if x-tog-shift then do:
         for each obj-list,
             each fin-doc where
                  fin-doc.host-code    =  iCntxtHostCodeObj
              and fin-doc.obj-code     =  obj-list.obj-code
              and fin-doc.obj-type     =  obj-list.obj-type
              and fin-doc.shift-date   >= X-date-start
              and fin-doc.shift-date   <= X-date-end
              and fin-doc.status_      = "факт"
              and fin-doc.fin-doc-type = (if iDocType = "Все" then fin-doc.fin-doc-type else iDocType)
         no-lock:
            if (fin-doc.shift-date = X-date-Start and fin-doc.shift-num < x-Shift-Start) or
               (fin-doc.shift-date = X-date-End   and fin-doc.shift-num > X-Shift-End)  
            then
               next.

            vShift = (if fin-doc.shift-num = integer(fin-doc.shift-name) then
                          fin-doc.shift-name
                       else
                          fin-doc.shift-name + "(" + string(fin-doc.shift-num) + ")").

            run CreateOneRec((buffer fin-doc:handle),
                             vShift,
                             fin-doc.shift-date).
         end.
      end.
      else do:
         for each obj-list,
             each fin-doc where
                  fin-doc.host-code    =  iCntxtHostCodeObj
              and fin-doc.obj-code     =  obj-list.obj-code
              and fin-doc.obj-type     =  obj-list.obj-type
              and fin-doc.doc-date     >= X-date-start
              and fin-doc.doc-date     <= X-date-end
              and fin-doc.status_      =  "факт"
              and fin-doc.fin-doc-type =  (if iDocType = "Все" then fin-doc.fin-doc-type else iDocType)
         no-lock:
            vShift = (if fin-doc.shift-num = integer(fin-doc.shift-name) then
                          fin-doc.shift-name
                       else
                          fin-doc.shift-name + "(" + string(fin-doc.shift-num) + ")").

            run CreateOneRec((buffer fin-doc:handle),
                             vShift,
                             fin-doc.shift-date).
         end.
      end.
   end.

   if lookup(iDocStatus, "Все,Удален") > 0 then do:
      if x-tog-shift then do:
         for each obj-list,
             each c-fin-doc where
                  c-fin-doc.host-code    =  iCntxtHostCodeObj
              and c-fin-doc.obj-code     =  obj-list.obj-code
              and c-fin-doc.obj-type     =  obj-list.obj-type
              and c-fin-doc.shift-date   >= X-date-start
              and c-fin-doc.shift-date   <= X-date-end
              and c-fin-doc.status_      =  "факт"
              and c-fin-doc.is-del       =  yes
              and c-fin-doc.fin-doc-type =  (if iDocType = "Все" then c-fin-doc.fin-doc-type else iDocType)
         no-lock:
            if (c-fin-doc.shift-date = X-date-Start and c-fin-doc.shift-num < x-Shift-Start) or
               (c-fin-doc.shift-date = X-date-End   and c-fin-doc.shift-num > X-Shift-End)  
            then
               next.

            vShift = (if c-fin-doc.shift-num = integer(c-fin-doc.shift-name) then
                          c-fin-doc.shift-name
                       else
                          c-fin-doc.shift-name + "(" + string(c-fin-doc.shift-num) + ")").

            run CreateOneRec((buffer c-fin-doc:handle),
                             vShift,
                             c-fin-doc.shift-date).
         end.
      end.
      else do:
         for each obj-list,
             each c-fin-doc where
                  c-fin-doc.host-code    =  iCntxtHostCodeObj
              and c-fin-doc.obj-code     =  obj-list.obj-code
              and c-fin-doc.obj-type     =  obj-list.obj-type
              and c-fin-doc.doc-date     >= X-date-start
              and c-fin-doc.doc-date     <= X-date-end
              and c-fin-doc.status_      =  "факт"
              and c-fin-doc.is-del       =  yes
              and c-fin-doc.fin-doc-type =  (if iDocType = "Все" then c-fin-doc.fin-doc-type else iDocType)
         no-lock:
            vShift = (if c-fin-doc.shift-num = integer(c-fin-doc.shift-name) then
                          c-fin-doc.shift-name
                       else
                          c-fin-doc.shift-name + "(" + string(c-fin-doc.shift-num) + ")").

            run CreateOneRec((buffer c-fin-doc:handle),
                             vShift,
                             c-fin-doc.shift-date).
         end.
      end.
   end.
   
end procedure.

procedure CreateOneRec:
   define input parameter iBuffHandle as handle    no-undo.
   define input parameter iShift      as character no-undo.
   define input parameter iShiftDate  as date      no-undo.

   define buffer user-account for user-account.

   define variable vReceiver as character no-undo.
   define variable vPayer    as character no-undo.
   define variable vObjInfo  as character no-undo.
   define variable vContract as character no-undo.
   define variable vCurrAbbr as character no-undo.
   define variable vFio      as character no-undo.

   do:
      assign
         vReceiver = iBuffHandle::receiver-type + string(iBuffHandle::receiver-code)
         vPayer    = iBuffHandle::payer-type + string(iBuffHandle::payer-code)
         vObjInfo  = if iBuffHandle::obj-code > 0 then
                        iBuffHandle::obj-type + string(iBuffHandle::obj-code)
                     else ""
         .
      vContract = fGetContract(iBuffHandle::host-code,
                               iBuffHandle::contract-code).
      vCurrAbbr = fGetCurrency(iBuffHandle::curr-code).

      find first user-account where
                 user-account.user-id = iBuffHandle:buffer-field(if iBuffHandle:table = "fin-doc" then
                                                                    "user-name-doc"
                                                                 else
                                                                    "corr-user-name"):buffer-value
      no-lock no-error .
      if avail user-account then
         vFio = trim(user-account.last-name  + " " +
                     user-account.first-name + " " +
                     user-account.second-name).

      create tt-rep.
      assign
         tt-rep.host-code        = iBuffHandle::host-code
         tt-rep.shift            = iShift
         tt-rep.shift-date       = iShiftDate
         tt-rep.prn-doc-code     = iBuffHandle::prn-doc-code
         tt-rep.receiver         = vReceiver
         tt-rep.receiver-name    = iBuffHandle::receiver-name
         tt-rep.contract         = vContract
         tt-rep.fin-doc-type     = iBuffHandle::fin-doc-type
         tt-rep.doc-date         = iBuffHandle::doc-date
         tt-rep.fin-ext-doc-type = iBuffHandle::fin-ext-doc-type
         tt-rep.perm-date        = iBuffHandle::perm-date
         tt-rep.pay-date         = iBuffHandle::pay-date
         tt-rep.fact-date        = iBuffHandle::fact-date
         tt-rep.del-date         = (if iBuffHandle:table = "c-fin-doc" then iBuffHandle:buffer-field("corr-date"):buffer-value else ?)
         tt-rep.status_          = (if iBuffHandle:table = "c-fin-doc" then "удален" else iBuffHandle::status_)
         tt-rep.sum-doc          = iBuffHandle::sum-doc
         tt-rep.payer            = vPayer
         tt-rep.payer-name       = iBuffHandle::payer-name
         tt-rep.curr-abbr        = vCurrAbbr
         tt-rep.obj-info         = vObjInfo
         tt-rep.fio              = vFio
         .
   end.
end procedure.

procedure PrintTT:
   define variable vReportId    as character no-undo.
   define variable vFileNameRep as character no-undo.
   define variable vSumDocStr   as character no-undo.
   define variable vI           as int64     no-undo.

   do on error undo, return error return-value:
      run get-report-num(output vReportId).
      vFileNameRep = session:temp-directory + string(vReportId) + ".html".

      output stream sOutStr-html to value(vFileNameRep) convert target 'UTF-8'.
      put stream sOutStr-html unformatted
         "<!DOCTYPE HTML>" skip
            ' <html>' skip
            '  <head>' skip
            '   <meta charset="utf-8">' skip
            '    <style type="text/css">' skip
            '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
            '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
            '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
            '   </style>' skip
            '  </head>' skip
         .

      put stream sOutStr-html unformatted
           '<body>' skip
           '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">' skip
           '<thead>' skip
           '<TR class="set_columns">' skip
               '<TD style="width:  50px;"></TD>' skip
               '<TD style="width:  50px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width: 100px;"></TD>' skip
               '<TD style="width: 100px;"></TD>' skip
               '<TD style="width: 150px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width:  45px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width:  45px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width:  50px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width: 100px;"></TD>' skip
               '<TD style="width: 150px;"></TD>' skip
               '<TD style="width:  30px;"></TD>' skip
               '<TD style="width:  60px;"></TD>' skip
               '<TD style="width: 100px;"></TD>' skip
           '</TR>' skip
           '<TR>' skip
               '<TD colspan="12" STYLE="font-size: 14px;">' + 'СПИСОК КАССОВЫХ ДОКУМЕНТОВ' + '</TD>'skip
           '</TR>' skip.
      
      do vI = 1 to extent(mParamStr):
         if mParamStr[vI] = "" then leave.
         put stream sOutStr-html unformatted           
              '<TR>' skip
                  '<TD colspan="12" STYLE="font-size: 14px;">' + mParamStr[vI] + '</TD>' skip
              '</TR>' skip
            .
      end.
      
      put stream sOutStr-html unformatted           
           '<TR>' skip
               '<TD colspan="12" STYLE="font-size: 14px;">Дата печати: ' + string(today, "99.99.9999") + ' ' + string(time, "HH:MM") + '</TD>' skip
           '</TR>' skip
           '</thead>' skip
         .
      put stream sOutStr-html unformatted
         '<tbody>'
         '<TR>'skip
            '<TH style="text-align: center;">Код фирмы</TH>' skip
            '<TH style="text-align: center;">Номер смены</TH>' skip
            '<TH style="text-align: center;">Дата смены</TH>' skip
            '<TH style="text-align: center;">Номер документа </TH>' skip
            '<TH style="text-align: center;">Получатель</TH>' skip
            '<TH style="text-align: center;">Название получателя</TH>' skip
            '<TH style="text-align: center;">Договор</TH>' skip
            '<TH style="text-align: center;">Тип доку мента</TH>' skip
            '<TH style="text-align: center;">Дата документа</TH>' skip
            '<TH style="text-align: center;">Расш. тип доку мента    </TH>' skip
            '<TH style="text-align: center;">Дата разр</TH>' skip
            '<TH style="text-align: center;">Дата прин банком</TH>' skip
            '<TH style="text-align: center;">Дата факт</TH>' skip
            '<TH style="text-align: center;">Дата удаления документа</TH>' skip
            '<TH style="text-align: center;">Статус</TH>' skip
            '<TH style="text-align: center;">Сумма</TH>' skip
            '<TH style="text-align: center;">Плательщик</TH>' skip
            '<TH style="text-align: center;">Название плательщика</TH>' skip
            '<TH style="text-align: center;">Вал</TH>' skip
            '<TH style="text-align: center;">Объект</TH>' skip
            '<TH style="text-align: center;">Пользователь</TH>' skip
         '</TR>'skip
         .
      for each tt-rep:
         vSumDocStr = fDec2Str(tt-rep.sum-doc, "->>>>>>>>>>>9.99").
         put stream sOutStr-html unformatted
            '<TR>' skip
                '<TD style="text-align: right"> ' + fInt2Str(tt-rep.host-code, "999999999")         + '</TD>' skip
                '<TD style="text-align: right"> ' + fStrNvl(tt-rep.shift, "")                       + '</TD>' skip
                '<TD style="text-align: left"> '  + fdate2str(tt-rep.shift-date, "99.99.9999")      + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.prn-doc-code, "")                + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.receiver, "")                    + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.receiver-name, "")               + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.contract, "")                    + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.fin-doc-type, "")                + '</TD>' skip
                '<TD style="text-align: left"> '  + fdate2str(tt-rep.doc-date,  "99.99.9999")       + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.fin-ext-doc-type, "")            + '</TD>' skip
                '<TD style="text-align: left"> '  + fdate2str(tt-rep.perm-date, "99.99.9999")       + '</TD>' skip
                '<TD style="text-align: left"> '  + fdate2str(tt-rep.pay-date,  "99.99.9999")       + '</TD>' skip
                '<TD style="text-align: left"> '  + fdate2str(tt-rep.fact-date, "99.99.9999")       + '</TD>' skip
                '<TD style="text-align: left"> '  + fdate2str(tt-rep.del-date,  "99.99.9999")       + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.status_, "")                     + '</TD>' skip
                '<TD num="#,##0.00" val="'           + vSumDocStr + '" style="text-align: right"> ' + vSumDocStr + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.payer, "")                       + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.payer-name, "")                  + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.curr-abbr, "")                   + '</TD>' skip
                '<TD style="text-align: left"> '  + fStrNvl(tt-rep.obj-info, "")                    + '</TD>' skip
                '<TD text_wrap="true" style="text-align: left"> '  + fStrNvl(tt-rep.fio, "")        + '</TD>' skip
            '</TR>' skip.
      end.
      put stream sOutStr-html unformatted
         '</tbody>' skip
         '</table>' skip
         '</body>' skip
         '</html>' skip
         .
      output stream sOutStr-html close.

      run prn-lib-reportviewer-report-name in this-procedure (
          input parparentproc
          ,input vFileNameRep
          ) no-error.
      if error-status:error then
      do:
          message "error-status:error = " error-status:error skip return-value view-as alert-box.
          return .
      end.
   end.
end procedure.

PROCEDURE get-report-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-report-num as integer no-undo .

  do
  on error undo, return error return-value
  :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.
