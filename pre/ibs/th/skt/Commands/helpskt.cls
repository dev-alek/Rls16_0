using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.Commands.HelpSkt inherits ICommand:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Обработка запросов в сокет сервер для help" get.
   constructor public HelpSkt (  ):
      super ().
      addMethod("",         "ATD",          "Запросы Атд").
      addMethod("ATD",      "CashDesk",     "Список касс").
      addMethod("ATD",      "GetTank",      "Список резервуаров").
      addMethod("",         "SaleMark",     "Продажа маркированого товара").
      addMethod("SaleMark", "sale_lock",    "Заблокировать для продажи").
      addMethod("SaleMark", "unlock_all",   "Разблокировать все").
      addMethod("SaleMark", "commit",       "Закрыть чек").
      addMethod("SaleMark", "return_lock",  "Заблокировать для возврата").
      addMethod("",         "SendCash",     "Отправка данных на кассу").
      addMethod("SendCash", "goods",        "Отправка товаров на кассу").
      addMethod("SendCash", "posonline",    "Отправка настроек для проверки КМ на кассу").
      addMethod("",          "TableMenu",   "TableMenu").
      addMethod("TableMenu", "grp",         "Группы товаров").
      addMethod("TableMenu", "gds",         "Товары в группе grp=<номер магазина>;<номер группы>").
      addMethod("",          "ThInfo",      "Информация по TradeHousse").
      addMethod("ThInfo",    "getcashdesk", "Список касс").
      addMethod("ThInfo",    "VerifyRest",  "Выгрузка остатков").
      addMethod("",          "TSD",                   "ТСД").
      addMethod("TSD",       "Descr",                 "Запрос справочников").
      addMethod("TSD",       "Doc",                   "Обмен документами (база mysql)").
      addMethod("TSD",       "Users" ,                "Пользователи").
      addMethod("TSD",       "Object" ,               "Обекты (магазины)").
      addMethod("TSD",       "Client" ,               "Клиенты(организации и люди)").
      addMethod("TSD",       "goods" ,                "Товары").
      addMethod("TSD",       "TH_barcodes" ,          "Баркоды").
      addMethod("TSD",       "TH_goodsAndBarcodes" ,  "Товары и баркоды").
      addMethod("TSD",       "documents" ,            "Запрос документов (xml)").
      addMethod("TSD",       "Setting" ,              "Настройки и версии").
      addMethod("TSD",       "getnewversion" ,        "Получить файл версии").
   end constructor.
   define temp-table tt-Method
       field ftype   as character
       field fmethod as char
       field fdesc   as char
       index ftype ftype fmethod
       .
   method override public void Execute_( input req as ibs.th.skt.Commands.IRequest, input resp as class IResponse ):
      define variable vAdr as character no-undo.
      vAdr = "http://" + req:HndlSocket:local-host + ":" + string(req:HndlSocket:local-port).
      resp:ConvertPage = "utf-8".
      if req:queryPar ne ""
      then
         resp:setContent(MainHelp(req:queryPar,vAdr)).
      else
         resp:setContent(MainHelp(vAdr)).
      resp:Content-Type = "text/html".
      resp:condition = resp:STSlist:WriteResponse:NameProp.
   end method.
   method private longchar MainHelp(iAdr as char):
      define variable vHtml as character no-undo.
      vHtml =
"<!DOCTYPE HTML>"  + chr(13) + chr(10) +
' <html>'  + chr(13) + chr(10) +
'  <head>'  + chr(13) + chr(10) +
'   <meta charset="utf-8">'  + chr(13) + chr(10) +
'    <style type="text/css">'  + chr(13) + chr(10) +
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125)  + chr(13) + chr(10) +
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125)  + chr(13) + chr(10) +
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125)  + chr(13) + chr(10) +
'   </style>'  + chr(13) + chr(10) +
'  </head>'  + chr(13) + chr(10) +
              '<body>' + chr(13) + chr(10) +
              '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">' + chr(13) + chr(10) +
              '<thead>'                        + chr(13) + chr(10) +
              ' <tr class="set_columns">'      + chr(13) + chr(10) +
              ' <td style="width:150px"></td>'  + chr(13) + chr(10) +
              ' <td style="width:250px"></td>' + chr(13) + chr(10) +
              ' <td style="width:250px"></td>' + chr(13) + chr(10) +
              ' <td style="width:50px"></td>' + chr(13) + chr(10) +
              '</tr>'                          + chr(13) + chr(10) .
      vHtml = vHtml +
              '<tr><!-- шапка таблицы -->' + chr(13) + chr(10) +
              '<td colspan="11" style="text-align: right;"></td>' + chr(13) + chr(10) +
              '</tr>' + chr(13) + chr(10) +
              '<tr>' + chr(13) + chr(10) +
              '<td colspan="11" style="text-align: right;">Дата формирования ' + string(today,"99.99.9999") + " " + string(time,"HH:MM:SS") + '</td>' + chr(13) + chr(10) +
              '</tr>' + chr(13) + chr(10) +
              '<tr>' + chr(13) + chr(10) +
              '<td colspan="11" style="font-weight: bold; text-align: center;">Список запросов Socet Server</td>' + chr(13) + chr(10) +
              '</tr>' + chr(13) + chr(10)
              .
      vHtml = vHtml +
              '</thead>'  + chr(13) + chr(10) +
              '<tr>'  + chr(13) + chr(10) +
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Виды запросов</td>'        + chr(13) + chr(10) +
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Описание</td>'             + chr(13) + chr(10) +
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Postman file import</td>'  + chr(13) + chr(10) +
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Cкачать json</td>'         + chr(13) + chr(10) +
              '</tr>'  + chr(13) + chr(10) +
              '<tbody>' + chr(13) + chr(10)
              .
      for each tt-Method where tt-Method.ftype eq "" no-lock:
         vHtml = vHtml + addString(tt-Method.fdesc     ,iadr + "/help?" + tt-Method.fmethod    ,iadr + "/postman/" + tt-Method.fmethod + ".json" ).
      end.
      vHtml = vHtml +
              '<tbody>' + chr(13) + chr(10) +
              '</table>'
              .
      return vHtml.
   end.
   method private longchar MainHelp(itype as character, iAdr as char):
      define variable vHtml as character no-undo.
      vHtml =
"<!DOCTYPE HTML>"  + chr(13) + chr(10) +
' <html>'  + chr(13) + chr(10) +
'  <head>'  + chr(13) + chr(10) +
'   <meta charset="utf-8">'  + chr(13) + chr(10) +
'    <style type="text/css">'  + chr(13) + chr(10) +
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125)  + chr(13) + chr(10) +
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125)  + chr(13) + chr(10) +
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125)  + chr(13) + chr(10) +
'   </style>'  + chr(13) + chr(10) +
'  </head>'  + chr(13) + chr(10) +
              '<body>' + chr(13) + chr(10) +
              '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">' + chr(13) + chr(10) +
              '<thead>'                        + chr(13) + chr(10) +
              ' <tr class="set_columns">'      + chr(13) + chr(10) +
              ' <td style="width:150px"></td>'  + chr(13) + chr(10) +
              ' <td style="width:450px"></td>' + chr(13) + chr(10) +
              '</tr>'                          + chr(13) + chr(10) .
      find first tt-Method where tt-Method.ftype eq ""
                             and tt-Method.fmethod eq itype
      no-lock no-error.
      vHtml = vHtml +
              '<tr><!-- шапка таблицы -->' + chr(13) + chr(10) +
              '<td colspan="11" style="text-align: right;"></td>' + chr(13) + chr(10) +
              '</tr>' + chr(13) + chr(10) +
              '<tr>' + chr(13) + chr(10) +
              '<td colspan="11" style="font-weight: bold; text-align: center;">' + (if available tt-Method then tt-Method.fdesc else "") + '</td>' + chr(13) + chr(10) +
              '</tr>' + chr(13) + chr(10) +
              '<tr>' + chr(13) + chr(10) +
              '<td colspan="11" style="text-align: center;">' + getfile("Открыть json", iadr + "/postman/" + itype + ".json" ) + '</td>' + chr(13) + chr(10) +
              '</tr>' + chr(13) + chr(10) +
              '<tr>' + chr(13) + chr(10) +
              '<td colspan="11" style="text-align: center;">' + getfile("Скачать json", iadr + "/postman/" + itype + ".json", yes ) + '</td>' + chr(13) + chr(10) +
              '</tr>' + chr(13) + chr(10)
              .
      vHtml = vHtml +
              '</thead>'  + chr(13) + chr(10) +
              '<tr>'  + chr(13) + chr(10) +
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Виды запросов</td>'        + chr(13) + chr(10) +
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Описание</td>'             + chr(13) + chr(10) +
              '</tr>'  + chr(13) + chr(10) +
              '<tbody>' + chr(13) + chr(10)
              .
      for each tt-Method where tt-Method.ftype eq itype no-lock:
         vHtml = vHtml + substitute (
               '<tr>&1'+
               '<td text_wrap="true">&2</td>&1' +
               '<td text_wrap="true">&3</td>&1' +
               '</tr>&1' ,
               chr(13) + chr(10) ,
               tt-Method.fmethod,
               tt-Method.fdesc).
      end.
      vHtml = vHtml +
              '<tbody>' + chr(13) + chr(10) +
              '</table>'
              .
      return vHtml.
   end.
   method private longchar addString(iStr1 as char,
                                     iStr2 as char,
                                     iStr3 as char):
      return substitute (
      '<tr>&1'+
      '<td text_wrap="true">&2</td>&1' +
      '<td text_wrap="true">&3</td>&1' +
      '<td text_wrap="true">&4</td>&1' +
      '<td text_wrap="true">&5</td>&1' +
      '</tr>&1' ,
      chr(13) + chr(10) ,
      iStr1,
      getfile(iStr1 + " help",istr2),
      getfile(iStr1 + " json",istr3),
      getfile("Скачать",istr3,yes)
      ).
   end.
   method private char getfile (iText as character, iAdr as char):
      return getfile (ITEXT,IADR, no).
   end.
   method private char getfile (iText as character,iAdr as char,iSave as logical):
      return substitute ('<a href="&2"  target="_blank">&1</a>',itext,iadr + if iSave then "?SaveFile" else "").
   end.
   method  private void addMethod(iType  as char,iMethod as char, iDesc as char):
      create tt-Method.
      assign
         tt-Method.ftype   = itype
         tt-Method.fmethod = iMethod
         tt-Method.fdesc   = iDesc
      .
   end.
end class.
