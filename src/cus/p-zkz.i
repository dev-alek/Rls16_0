/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригеры по печати бланков заказов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/02
Author: Svetlana Chernova
Creation date: 03/02/02

*/
/* t-doc-line это буфер на ord-line  */
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&SCOP f-l Word-Sum,Total-Word,RedLine
{ gbl/std-func.i {&f-l} }


ON CHOOSE OF MENU-ITEM m_PRINT1 /* 6.  */
DO:
  /* define variable v-rez as logical   no-undo . */
  if not available shar-buf_ord-doc then return .
  /* run ver-edi in this-procedure (  buffer shar-buf_ord-doc
                                  ,output v-rez
  ).
  if v-rez = false then return . */

  run cus/torg-26.p ( parParentProc, recid(shar-buf_ord-doc) ).
END.

ON CHOOSE OF MENU-ITEM m_print4
DO:
    
    
      g#log = true  . 
            message "Экспорт в excel ." skip "Продолжать ?"
                view-as alert-box question buttons ok-cancel update g#log.
            {&if-not-true}
            IF NOT AVAILABLE shar-buf_ord-doc THEN RETURN .     
            RUN cus/z-tot1.p (PARPARENTPROC ,  shar-buf_ord-doc.doc-code , shar-buf_ord-doc.obj-TYPE ,shar-buf_ord-doc.obj-code   ).
    
    END.


     ON CHOOSE OF MENU-ITEM m_print5
        DO:
   
            if  g#type = {&f-p} then do:

/*            g#log = true  .                                                   */
/*                                                                              */
/*                message "Экспорт в excel ." skip "Продолжать ?"               */
/*                    view-as alert-box question buttons ok-cancel update g#log.*/
/*            {&if-not-true}                                                    */
            IF NOT AVAILABLE shar-buf_ord-doc THEN RETURN .
            RUN cus/z-tot-det.p (PARPARENTPROC ,  shar-buf_ord-doc.doc-code , shar-buf_ord-doc.obj-TYPE ,shar-buf_ord-doc.obj-code   ).
 end.
 else do:      
     message "Печать документа только для заказов Фирма - Поставщик" view-as alert-box.
     end.
        END.
 
 
 

ON CHOOSE OF MENU-ITEM m_PRINT2 /* 7.  */
DO:
define variable j as integer init 0 no-undo .
DEFINE  BUFFER post-firm    for ub.firm.
DEFINE  BUFFER zak-firm     for ub.firm.
DEFINE  BUFFER ord-blank-1  for ub.ord-blank.
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .

define variable PrintRubl  as logical   no-undo .
define variable Abbr       as character no-undo .
define variable PropisSum  as character no-undo .
define variable B-Sum      as decimal   no-undo .

DEFINE VARIABLE N#ROW         as  integer  no-undo .
DEFINE VARIABLE GoodN#ROW     as  integer  no-undo .
DEFINE VARIABLE GoodEI#ROW    as  integer  no-undo .
DEFINE VARIABLE OKEI#ROW      as  integer  no-undo .
DEFINE VARIABLE Qnty#ROW      as  integer  no-undo .
DEFINE VARIABLE Cost#ROW      as  integer  no-undo .
DEFINE VARIABLE Summa#ROW     as  integer  no-undo .
DEFINE VARIABLE N#col         as  integer  no-undo .
DEFINE VARIABLE GoodN#col     as  integer  no-undo .
DEFINE VARIABLE GoodEI#col    as  integer  no-undo .
DEFINE VARIABLE OKEI#col      as  integer  no-undo .
DEFINE VARIABLE Qnty#col      as  integer  no-undo .
DEFINE VARIABLE Cost#col      as  integer  no-undo .
DEFINE VARIABLE Summa#col     as  integer  no-undo .
DEFINE VARIABLE Sort#ROW      as  integer  no-undo .
DEFINE VARIABLE Sort#COL      as  integer  no-undo .
DEFINE VARIABLE GoodCode#ROW  as  integer  no-undo .
DEFINE VARIABLE GoodCode#COL  as  integer  no-undo .
DEFINE VARIABLE CliArt#ROW    as  integer  no-undo .
DEFINE VARIABLE CliArt#COL    as  integer  no-undo .
DEFINE VARIABLE Art#ROW       as  integer  no-undo .
DEFINE VARIABLE Art#COL       as  integer  no-undo .

/* define variable v-rez as logical   no-undo . */

  if not available shar-buf_ord-doc then return .
  /*run ver-edi in this-procedure ( buffer shar-buf_ord-doc
                                  ,output v-rez
  ) .
  if v-rez = false then return .*/


define variable Current-ROW  as integer no-undo .

 if blank#name = ?  or blank#name = "" Then
    Find first ub.ord-blank
         where ub.ord-blank.cli-code = shar-buf_ord-doc.cli-code
           and ub.ord-blank.cli-type = shar-buf_ord-doc.cli-type
           and ub.ord-blank.last-use = TRUE
         no-lock no-error.
   else
    Find first ub.ord-blank
         where ub.ord-blank.cli-code = shar-buf_ord-doc.cli-code
           and ub.ord-blank.cli-type = shar-buf_ord-doc.cli-type
           and ub.ord-blank.blank-name = blank#name
          no-lock no-error.
   if not  available  ub.ord-blank  then do :
      Message "Для этого поставщика нет формы !   Задайте ее в режиме  <<выбор формы печати>>".
      Return.
      End.
   if  available  ub.ord-blank  then do :
       Assign blank#name = ?.
       For each ord-blank-1 where ub.ord-blank-1.cli-code = shar-buf_ord-doc.cli-code
                              and ub.ord-blank-1.cli-type = shar-buf_ord-doc.cli-type   exclusive-lock :
       if  ord-blank.blank-name = ub.ord-blank-1.blank-name and
           ord-blank.cli-code = ub.ord-blank-1.cli-code     and
           ord-blank.cli-type = ub.ord-blank-1.cli-type then  ord-blank-1.last-use = TRUE .
           Else ord-blank-1.last-use = false  .
       End.
   /**/
 B-Sum = shar-buf_ord-doc.sum-Service + shar-buf_ord-doc.sum-Ship + shar-buf_ord-doc.sum-cli.
 FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = shar-buf_ord-doc.exch-code no-error .
 if shar-buf_ord-doc.exch-code <> 0 then
       assign
        PrintRubl = false
        abbr = ub.currency.curr-abbr
        .
 else  PrintRubl =  true .

      if NOT PrintRubl then
           assign
            PropisSum = Total-Word( B-Sum, ub.currency.curr-abbr, ub.currency.part-abbr )
          .
      else
          run rep/wp-rub.p ( B-Sum , output PropisSum, output abbr).


CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        return no-apply .
    end.
ASSIGN
  chExcelApplication:Visible = FALSE
  chWorkbook  = chExcelApplication:Workbooks:Add ( ub.ord-blank.file-name )
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  chExcelApplication:Interactive    = false
  chExcelApplication:ScreenUpdating = false
  .

  /* Шапка */
       /* Поставщик */
      Find first post-firm where  post-firm.firm-code = shar-buf_ord-doc.cli-code no-lock  no-error .
      if available post-firm THEN
       Assign
        chWorkSheet:Range ("PosAddres1"):Value   = post-firm.addres1
        chWorkSheet:Range ("PosAddres2"):Value   = post-firm.addres2
        chWorkSheet:Range ("PosOKPO")   :Value   = post-firm.okpo
        chWorkSheet:Range ("PosPhone1") :Value   = post-firm.phone1-note
        chWorkSheet:Range ("PosPhone2") :Value   = post-firm.phone no-error.
       /* Заказчик */
       Find first Zak-firm where  Zak-firm.firm-code = g#host-code no-lock  no-error .
       if available Zak-firm THEN
       Assign
        chWorkSheet:Range ("ZakAddres1"):Value   = Zak-firm.addres1
        chWorkSheet:Range ("ZakAddres2"):Value   = Zak-firm.addres2
        chWorkSheet:Range ("ZakOKPO")   :Value   = Zak-firm.okpo
        chWorkSheet:Range ("ZakPhone1") :Value   = Zak-firm.phone1-note
        chWorkSheet:Range ("ZakPhone2") :Value   = Zak-firm.phone no-error.

        /*почему-то иногда не выводит, если в 1 assign все поместить!!!*/
       Assign chWorkSheet:Range ("ZakFullname"):Value = G#host-name no-error.
       Assign chWorkSheet:Range ("Number")     :Value = shar-buf_ord-doc.doc-code no-error .
       Assign chWorkSheet:Range ("NumberPost") :Value = entry(1, shar-buf_ord-doc.cli-out-doc, {&delim-par}) no-error.
       Assign chWorkSheet:Range ("TimePost")   :Value = string(shar-buf_ord-doc.ship-time, "HH:MM") no-error.
       Assign chWorkSheet:Range ("DatePost")   :Value = string(shar-buf_ord-doc.ship-date, "99/99/9999") no-error.
       Assign chWorkSheet:Range ("FullName")   :Value = shar-buf_ord-doc.cli-name     no-error.
       Assign
        chWorkSheet:Range ("DateDoc") :Value  = if shar-buf_ord-doc.fact-date <> ?
          THEN string(shar-buf_ord-doc.fact-date, "99/99/9999")
          Else string(shar-buf_ord-doc.doc-date, "99/99/9999")
        no-error.
       Assign chWorkSheet:Range ("SumShip")   :Value = shar-buf_ord-doc.sum-Ship no-error.
       Assign chWorkSheet:Range ("SumService"):Value = shar-buf_ord-doc.sum-Service no-error.
       Assign chWorkSheet:Range ("SumPropis") :Value = PropisSum  no-error .

      /* Определим абсолютные значения для колонок таблицы - чтобы вставлять произвольное количество строк */
     Assign

     N#ROW            =   chWorkSheet:Range ("N" ):Row
     N#COL            =   chWorkSheet:Range ("N" ):Column

     Sort#ROW         =   chWorkSheet:Range ("Sort" ):Row
     Sort#COL         =   chWorkSheet:Range ("Sort" ):Column
     GoodCode#ROW     =   chWorkSheet:Range ("GoodCode" ):Row
     GoodCode#COL     =   chWorkSheet:Range ("GoodCode" ):Column

     GoodN#ROW  = chWorkSheet:Range ("GoodN" ):Row
     GoodEI#ROW = chWorkSheet:Range ("EIn"   ):Row
     OKEI#ROW   = chWorkSheet:Range ("GoodEI"):Row
     Qnty#ROW   = chWorkSheet:Range ("Qnty"  ):Row
     Cost#ROW   = chWorkSheet:Range ("Cost"  ):Row
     Summa#ROW  = chWorkSheet:Range ("Summa" ):Row
     CliArt#ROW = chWorkSheet:Range ("CliArt" ):Row
     Art#ROW = chWorkSheet:Range ("Art" ):Row

     GoodN#COL  = chWorkSheet:Range ("GoodN" ):Column
     GoodEI#COL = chWorkSheet:Range ("EIn"   ):Column
     OKEI#COL   = chWorkSheet:Range ("GoodEI"):Column
     Qnty#COL   = chWorkSheet:Range ("Qnty"  ):Column
     Cost#COL   = chWorkSheet:Range ("Cost"  ):Column
     Summa#COL  = chWorkSheet:Range ("Summa" ):Column
     CliArt#COL = chWorkSheet:Range ("CliArt" ):Column
     Art#COL = chWorkSheet:Range ("Art" ):Column
     no-error.
     /* GoodCode  Sort  */

         Current-ROW = maximum( if N#ROW       = ? then 0 else N#ROW      ,
                                if GoodN#ROW   = ? then 0 else GoodN#ROW  ,
                                if GoodEI#ROW  = ? then 0 else GoodEI#ROW ,
                                if OKEI#ROW    = ? then 0 else OKEI#ROW   ,
                                if Art#ROW     = ? then 0 else Art#ROW    ,
                                if CliArt#ROW  = ? then 0 else CliArt#ROW ,
                                if Qnty#ROW    = ? then 0 else Qnty#ROW   ,
                                if Cost#ROW    = ? then 0 else Cost#ROW   ,
                                if Summa#ROW   = ? then 0 else Summa#ROW  )
                                .
      /* таблица */
      For each  t-doc-line where t-doc-line.doc-code = shar-buf_ord-doc.doc-code no-lock :
       chWorkSheet:Rows(Current-ROW):Insert .
      End.
      For each  t-doc-line where t-doc-line.doc-code = shar-buf_ord-doc.doc-code no-lock :
         J = J + 1 .
                  FIND FIRST ub.goods No-LOCK
              WHERE ub.goods.prod-type = t-doc-line.prod-type
               AND  ub.goods.prod-code = t-doc-line.prod-code
               AND  ub.goods.artic     = t-doc-line.artic
                    NO-ERROR.
         FIND FIRST ub.units WHERE ub.units.unit-name = t-doc-line.unit-cli NO-LOCK NO-ERROR .

         Assign chWorkSheet:Range (string(COL-NAME[N#col])        + String(N#ROW        + J)):Value  = J no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodN#col])    + String(GoodN#ROW    + J)):Value  = ub.goods.gds-name no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Sort#col])     + String(Sort#ROW     + J)):Value  = ub.goods.Sort     no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodCode#col]) + String(GoodCode#ROW + J)):Value  = ub.goods.gds-code no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodEI#col])   + String(GoodEI#ROW   + J)):Value  = t-doc-line.unit-cli  no-error.
         Assign chWorkSheet:Range (string(COL-NAME[OKEI#col])     + String(OKEI#ROW     + J)):Value  = if available ub.units THEN String(ub.units.OKEI,">>>>>") Else "" no-error.
         Assign chWorkSheet:Range (string(COL-NAME[CliArt#col])   + String(CliArt#ROW   + J)):Value  = t-doc-line.cli-art no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Art#col])      + String(Art#ROW      + J)):Value  = t-doc-line.artic no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Qnty#col])     + String(Qnty#ROW     + J)):Value  = t-doc-line.cli-qnty no-error .
         Assign chWorkSheet:Range (string(COL-NAME[Cost#col])     + String(Cost#ROW     + J)):Value  = t-doc-line.price-cli no-error .
         Assign chWorkSheet:Range (string(COL-NAME[Summa#col])    + String(Summa#ROW    + J)):Value  = round ( t-doc-line.cli-qnty * t-doc-line.price-cli , 2) no-error .
         /*
         if error-status :error and  J  = 1 then message
           "Внимание ! Шаблон Excel не содержит поля  КОЛИЧЕСТВО !!!"
           view-as alert-box information
         .  */
       END.
      chWorkSheet:Rows(Current-ROW):Delete.
      assign
      chExcelApplication:Interactive    = true
      chExcelApplication:ScreenUpdating = true
      chExcelApplication:Visible        = TRUE
      .
   End.
  message "Форма Заказа подготовлена. Связь с Excel будет закрыта."  view-as alert-box .
  RELEASE OBJECT chWorksheet NO-ERROR.
  RELEASE OBJECT chWorkbook NO-ERROR.
  chExcelApplication :QUIT().
  RELEASE OBJECT  chExcelApplication  NO-ERROR.
  RETURN NO-APPLY.
END.

  ON CHOOSE OF MENU-ITEM m_print6 IN MENU M-print
    DO:
      define variable j as integer init 0 no-undo .
      DEFINE  BUFFER post-firm    for ub.firm.
      DEFINE  BUFFER zak-firm     for ub.firm.
      DEFINE  BUFFER ord-blank-1  for ub.ord-blank.
      DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
      DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
      DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .

      define variable PrintRubl  as logical   no-undo .
      define variable Abbr       as character no-undo .
      define variable PropisSum  as character no-undo .
      define variable B-Sum      as decimal   no-undo .

      DEFINE VARIABLE N#ROW         as  integer  no-undo .
      DEFINE VARIABLE GoodN#ROW     as  integer  no-undo .
      DEFINE VARIABLE GoodEI#ROW    as  integer  no-undo .
      DEFINE VARIABLE OKEI#ROW      as  integer  no-undo .
      DEFINE VARIABLE Qnty#ROW      as  integer  no-undo .
      DEFINE VARIABLE Cost#ROW      as  integer  no-undo .
      DEFINE VARIABLE Summa#ROW     as  integer  no-undo .
      DEFINE VARIABLE N#col         as  integer  no-undo .
      DEFINE VARIABLE GoodN#col     as  integer  no-undo .
      DEFINE VARIABLE GoodEI#col    as  integer  no-undo .
      DEFINE VARIABLE OKEI#col      as  integer  no-undo .
      DEFINE VARIABLE Qnty#col      as  integer  no-undo .
      DEFINE VARIABLE Cost#col      as  integer  no-undo .
      DEFINE VARIABLE Summa#col     as  integer  no-undo .
      DEFINE VARIABLE Sort#ROW      as  integer  no-undo .
      DEFINE VARIABLE Sort#COL      as  integer  no-undo .
      DEFINE VARIABLE GoodCode#ROW  as  integer  no-undo .
      DEFINE VARIABLE GoodCode#COL  as  integer  no-undo .
      DEFINE VARIABLE CliArt#ROW    as  integer  no-undo .
      DEFINE VARIABLE CliArt#COL    as  integer  no-undo .
      DEFINE VARIABLE Art#ROW       as  integer  no-undo .
      DEFINE VARIABLE Art#COL       as  integer  no-undo .
      DEFINE VARIABLE CliName#COL         as  integer  no-undo .
      DEFINE VARIABLE CliCode#COL         as  integer  no-undo .
      DEFINE VARIABLE CliType#COL         as  integer  no-undo .
      DEFINE VARIABLE CliAdress1#COL      as  integer  no-undo .
      DEFINE VARIABLE CliAdress2#COL      as  integer  no-undo .
      DEFINE VARIABLE CliName#ROW         as  integer  no-undo .
      DEFINE VARIABLE CliCode#ROW         as  integer  no-undo .
      DEFINE VARIABLE CliType#ROW         as  integer  no-undo .
      DEFINE VARIABLE CliAdress1#ROW      as  integer  no-undo .
      DEFINE VARIABLE CliAdress2#ROW      as  integer  no-undo .
      /* define variable v-rez as logical   no-undo . */
   
             
      if not available shar-buf_ord-doc then return .
      define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
      define buffer buf_ord-line     for ub.ord-line      .
      define variable Current-ROW  as integer no-undo .
      define variable v-rez as logical   no-undo .
      define variable v-cli-art as character no-undo .
      define buffer buf_clients for ub.clients  .
      if blank#name = ?  or blank#name = "" Then
        Find first ub.ord-blank
          where ub.ord-blank.cli-code = shar-buf_ord-doc.cli-code
          and ub.ord-blank.cli-type = shar-buf_ord-doc.cli-type
          and ub.ord-blank.last-use = TRUE
          no-lock no-error.
      else
        Find first ub.ord-blank
          where ub.ord-blank.cli-code = shar-buf_ord-doc.cli-code
          and ub.ord-blank.cli-type = shar-buf_ord-doc.cli-type
          and ub.ord-blank.blank-name = blank#name
          no-lock no-error.
      if not  available  ub.ord-blank  then 
      do :
        Message "Для этого поставщика нет формы !   Задайте ее в режиме  <<выбор формы печати>>".
        Return.
      End.
      if  available  ub.ord-blank  then 
      do :
        Assign 
          blank#name = ?.
        For each ord-blank-1 where ub.ord-blank-1.cli-code = shar-buf_ord-doc.cli-code
          and ub.ord-blank-1.cli-type = shar-buf_ord-doc.cli-type   exclusive-lock :
          if  ord-blank.blank-name = ub.ord-blank-1.blank-name and
            ord-blank.cli-code = ub.ord-blank-1.cli-code     and
            ord-blank.cli-type = ub.ord-blank-1.cli-type then  ord-blank-1.last-use = TRUE .
          Else ord-blank-1.last-use = false  .
        End.

        CREATE "Excel.Application" chExcelApplication.
        assign
          chExcelApplication:Visible = false
          chWorkbook  = chExcelApplication:Workbooks:Add ( ub.ord-blank.file-name )
          chWorkSheet = chExcelApplication:Sheets:Item (1)
          chExcelApplication:Interactive    = false
          chExcelApplication:ScreenUpdating = false
          .

        /* Шапка */
        /* Поставщик */
        Find first post-firm where  post-firm.firm-code = shar-buf_ord-doc.cli-code no-lock  no-error .
        if available post-firm THEN
          Assign
            chWorkSheet:Range ("PosAddres1"):Value   = post-firm.addres1
            chWorkSheet:Range ("PosAddres2"):Value   = post-firm.addres2
            chWorkSheet:Range ("PosOKPO")   :Value   = post-firm.okpo
            chWorkSheet:Range ("PosPhone1") :Value   = post-firm.phone1-note
            chWorkSheet:Range ("PosPhone2") :Value   = post-firm.phone no-error.
        /* Заказчик */
        Find first Zak-firm where  Zak-firm.firm-code = g#host-code no-lock  no-error .
        if available Zak-firm THEN
          Assign
            chWorkSheet:Range ("ZakAddres1"):Value   = Zak-firm.addres1
            chWorkSheet:Range ("ZakAddres2"):Value   = Zak-firm.addres2
            chWorkSheet:Range ("ZakOKPO")   :Value   = Zak-firm.okpo
            chWorkSheet:Range ("ZakPhone1") :Value   = Zak-firm.phone1-note
            chWorkSheet:Range ("ZakPhone2") :Value   = Zak-firm.phone no-error.

        /*почему-то иногда не выводит, если в 1 assign все поместить!!!*/
        Assign 
          chWorkSheet:Range ("ZakFullname"):Value = G#host-name no-error.
        Assign 
          chWorkSheet:Range ("Number")     :Value = shar-buf_ord-doc.doc-code no-error .
        Assign 
          chWorkSheet:Range ("NumberPost") :Value = entry(1, shar-buf_ord-doc.cli-out-doc, {&delim-par}) no-error.
        Assign 
          chWorkSheet:Range ("TimePost")   :Value = string(shar-buf_ord-doc.ship-time, "HH:MM") no-error.
        Assign 
          chWorkSheet:Range ("DatePost")   :Value = string(shar-buf_ord-doc.ship-date, "99/99/9999") no-error.
        Assign 
          chWorkSheet:Range ("FullName")   :Value = shar-buf_ord-doc.cli-name     no-error.
        Assign
          chWorkSheet:Range ("DateDoc") :Value  = if shar-buf_ord-doc.fact-date <> ?
          THEN string(shar-buf_ord-doc.fact-date, "99/99/9999")
          Else string(shar-buf_ord-doc.doc-date, "99/99/9999")
        no-error.
        Assign 
          chWorkSheet:Range ("SumShip")   :Value = shar-buf_ord-doc.sum-Ship no-error.
        Assign 
          chWorkSheet:Range ("SumService"):Value = shar-buf_ord-doc.sum-Service no-error.
       
 
        /* Определим обсолютные значения для колонок таблицы - чтобы вставлять произвольное количество строк */
        Assign

          N#ROW        = chWorkSheet:Range ("N" ):Row
          N#COL        = chWorkSheet:Range ("N" ):Column
          Sort#ROW     = chWorkSheet:Range ("Sort" ):Row
          Sort#COL     = chWorkSheet:Range ("Sort" ):Column
          GoodCode#ROW = chWorkSheet:Range ("GoodCode" ):Row
          GoodCode#COL = chWorkSheet:Range ("GoodCode" ):Column

          GoodN#ROW    = chWorkSheet:Range ("GoodN" ):Row
          GoodEI#ROW   = chWorkSheet:Range ("EIn"   ):Row
          OKEI#ROW     = chWorkSheet:Range ("GoodEI"):Row
     Qnty#ROW     = chWorkSheet:Range ("Qnty"  ):Row
     Cost#ROW     = chWorkSheet:Range ("Cost"  ):Row
     Summa#ROW    = chWorkSheet:Range ("Summa" ):Row
     CliArt#ROW   = chWorkSheet:Range ("CliArt"):Row
     Art#ROW      = chWorkSheet:Range ("Art"   ):Row
     CliName#ROW  = chWorkSheet:Range ("CliName"   ):ROW
     CliCode#ROW  = chWorkSheet:Range ("CliCode"   ):ROW
     CliType#ROW  = chWorkSheet:Range ("CliType"   ):ROW
     CliAdress1#ROW = chWorkSheet:Range ("CliAdress1"   ):ROW
     CliAdress2#ROW = chWorkSheet:Range ("CliAdress2"   ):ROW

     GoodN#COL    = chWorkSheet:Range ("GoodN" ):Column
     GoodEI#COL   = chWorkSheet:Range ("EIn"   ):Column
     OKEI#COL     = chWorkSheet:Range ("GoodEI"):Column
     Qnty#COL     = chWorkSheet:Range ("Qnty"  ):Column
     Cost#COL     = chWorkSheet:Range ("Cost"  ):Column
     Summa#COL    = chWorkSheet:Range ("Summa" ):Column
     CliArt#COL   = chWorkSheet:Range ("CliArt"):Column
     Art#COL      = chWorkSheet:Range ("Art"   ):Column
     CliName#COL  = chWorkSheet:Range ("CliName"   ):Column
     CliCode#COL  = chWorkSheet:Range ("CliCode"   ):Column
     CliType#COL  = chWorkSheet:Range ("CliType"   ):Column
     CliAdress1#COL = chWorkSheet:Range ("CliAdress1"   ):Column
     CliAdress2#COL = chWorkSheet:Range ("CliAdress2"   ):Column
             
     no-error.
      /* GoodCode  Sort  */

      Current-ROW = maximum( if N#ROW       = ? then 0 else N#ROW      ,
        if GoodN#ROW   = ? then 0 else GoodN#ROW  ,
        if GoodEI#ROW  = ? then 0 else GoodEI#ROW ,
        if OKEI#ROW    = ? then 0 else OKEI#ROW   ,
        if Art#ROW  = ? then 0 else Art#ROW ,
        if CliArt#ROW  = ? then 0 else CliArt#ROW ,
        if Qnty#ROW    = ? then 0 else Qnty#ROW   ,
        if Cost#ROW    = ? then 0 else Cost#ROW   ,
        if Summa#ROW   = ? then 0 else Summa#ROW  ,
        if CliName#ROW = ? then 0 else CliName#ROW,
        if CliCode#ROW = ? then 0 else CliCode#ROW,
        if CliAdress1#ROW = ? then 0 else CliAdress1#ROW,
        if CliType#ROW = ? then 0 else CliType#ROW,
        if CliAdress2#ROW = ? then 0 else CliAdress2#ROW)
        .
      /* таблица */
      for each tt-ord-doc-rcv :
        delete tt-ord-doc-rcv .
      end.  
      for each ub.ord-doc-rcv where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code:      
        For each  buf_ord-line-rcv where
          buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
          buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
          no-lock :
          chWorkSheet:Rows(Current-ROW):Insert .
        End.

        For each  buf_ord-line-rcv where
          buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
          buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
          no-lock :
            
          J = J + 1 .
          FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = buf_ord-line-rcv.prod-type AND
            ub.goods.prod-code = buf_ord-line-rcv.prod-code AND
            ub.goods.artic     = buf_ord-line-rcv.artic  NO-ERROR.
          find first ub.units where ub.units.unit-name = buf_ord-line-rcv.unit-cli no-lock no-error .

                   find first buf_ord-line no-lock where
                              buf_ord-line.artic = buf_ord-line-rcv.artic and
                              buf_ord-line.prod-type = buf_ord-line-rcv.prod-type and
                              buf_ord-line.prod-code = buf_ord-line-rcv.prod-code no-error.
          if available buf_ord-line then v-cli-art = buf_ord-line.cli-art .
          else v-cli-art = "" .
/*      find first tt-ord-doc-rcv where tt-ord-doc-rcv.nn = J and                                */
/*                                      tt-ord-doc-rcv.gds-name = ub.goods.gds-name and          */
/*                                      tt-ord-doc-rcv.gds-sort = ub.goods.sort and              */
/*                                      tt-ord-doc-rcv.gds-code = ub.goods.gds-code and          */
/*                                      tt-ord-doc-rcv.unit-cli = buf_ord-line-rcv.unit-cli and  */
/*                                      tt-ord-doc-rcv.cli-art = v-cli-art and                   */
/*                                      tt-ord-doc-rcv.artic = buf_ord-line-rcv.artic and        */
/*                                      tt-ord-doc-rcv.cli-qnty = buf_ord-line-rcv.cli-qnty and  */
/*                                      tt-ord-doc-rcv.price-cli = buf_ord-line-rcv.price-cli and*/
/*                                      tt-ord-doc-rcv.cost = buf_ord-line-rcv.price-cli and     */
/*                                      tt-ord-doc-rcv.cli-code = shar-buf_ord-doc.cli-code and  */
/*                                      tt-ord-doc-rcv.cli-type = shar-buf_ord-doc.cli-type      */
/*                                      no-lock no-error .                                       */
/*      if available tt-ord-doc-rcv then delete tt-ord-doc-rcv .                                 */
          create tt-ord-doc-rcv .
          assign
          tt-ord-doc-rcv.nn = J
          tt-ord-doc-rcv.gds-name = ub.goods.gds-name
          tt-ord-doc-rcv.gds-sort = ub.goods.Sort
          tt-ord-doc-rcv.gds-code = ub.goods.gds-code
          tt-ord-doc-rcv.unit-cli = buf_ord-line-rcv.unit-cli
          .
          assign
          tt-ord-doc-rcv.OKEI = if available ub.units THEN String(ub.units.OKEI,">>>>>") Else "" no-error.
          assign
          tt-ord-doc-rcv.cli-art = v-cli-art
          tt-ord-doc-rcv.artic = buf_ord-line-rcv.artic
          tt-ord-doc-rcv.cli-qnty = buf_ord-line-rcv.cli-qnty
          tt-ord-doc-rcv.price-cli = buf_ord-line-rcv.price-cli
          tt-ord-doc-rcv.cost = buf_ord-line-rcv.price-cli
          tt-ord-doc-rcv.summa = round ( buf_ord-line-rcv.cli-qnty * buf_ord-line-rcv.price-cli , 2) no-error.
          assign 
          tt-ord-doc-rcv.cli-name = ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code)
          tt-ord-doc-rcv.cli-code = shar-buf_ord-doc.cli-code
          tt-ord-doc-rcv.cli-type = shar-buf_ord-doc.cli-type.
          if ub.ord-doc-rcv.obj-type = {&shop} then do:
            find first ub.shop where ub.shop.obj-code = ub.ord-doc-rcv.obj-code no-lock no-error.
            assign
              tt-ord-doc-rcv.addres1 = ub.shop.addres1
              tt-ord-doc-rcv.addres2 = ub.shop.addres2
            .
          end.
          if ub.ord-doc-rcv.obj-type = {&stock} then do:
            find first ub.store where ub.store.obj-code = ub.ord-doc-rcv.obj-code no-lock no-error.
            assign
              tt-ord-doc-rcv.addres1 = ub.store.addres1
              tt-ord-doc-rcv.addres2 = ub.store.addres2
            .
          end.
          .
                  
        End.
      end.   

for each tt-ord-doc-rcv exclusive-lock:
chWorkSheet:Rows(Current-ROW):Insert .
end.        
for each tt-ord-doc-rcv exclusive-lock:
  B-sum = B-sum + tt-ord-doc-rcv.summa .
          Assign 
            chWorkSheet:Range (string(COL-NAME[N#col])        + String(N#ROW        + J)):Value  = tt-ord-doc-rcv.nn no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[GoodN#col])    + String(GoodN#ROW    + J)):Value  = tt-ord-doc-rcv.gds-name no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[Sort#col])     + String(Sort#ROW     + J)):Value  = tt-ord-doc-rcv.gds-sort     no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[GoodCode#col]) + String(GoodCode#ROW + J)):Value  = tt-ord-doc-rcv.gds-code no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[GoodEI#col])   + String(GoodEI#ROW   + J)):Value  = tt-ord-doc-rcv.unit-cli  no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[OKEI#col])     + String(OKEI#ROW     + J)):Value  = tt-ord-doc-rcv.OKEI no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[CliArt#col])   + String(CliArt#ROW   + J)):Value  = tt-ord-doc-rcv.cli-art no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[Art#col])      + String(Art#ROW      + J)):Value  = tt-ord-doc-rcv.artic no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[Qnty#col])     + String(Qnty#ROW     + J)):Value  = tt-ord-doc-rcv.cli-qnty no-error .
          Assign 
            chWorkSheet:Range (string(COL-NAME[Cost#col])     + String(Cost#ROW     + J)):Value  = tt-ord-doc-rcv.price-cli no-error .
          Assign 
            chWorkSheet:Range (string(COL-NAME[Summa#col])    + String(Summa#ROW    + J)):Value  = tt-ord-doc-rcv.summa no-error .
          Assign 
            chWorkSheet:Range (string(COL-NAME[Cost#col])     + String(Cost#ROW     + J)):Value  = tt-ord-doc-rcv.price-cli no-error .
          Assign 
            chWorkSheet:Range (string(COL-NAME[CliName#COL])  + String(CliName#ROW  + J)):Value  = tt-ord-doc-rcv.cli-name no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[CliCode#COL])  + String(CliCode#ROW  + J)):Value  = tt-ord-doc-rcv.cli-code no-error.
          Assign 
            chWorkSheet:Range (string(COL-NAME[CliType#COL])  + String(CliType#ROW     + J)):Value  = tt-ord-doc-rcv.cli-type no-error .
          Assign 
            chWorkSheet:Range (string(COL-NAME[CliAdress1#COL]) + String(CliAdress1#ROW     + J)):Value  = tt-ord-doc-rcv.addres1 no-error .
          Assign 
            chWorkSheet:Range (string(COL-NAME[CliAdress2#COL]) + String(CliAdress2#ROW    + J)):Value  = tt-ord-doc-rcv.addres2 no-error .
          /*
          if error-status :error and  J  = 1 then message
            "Внимание ! Шаблон Excel не содержит поля  КОЛИЧЕСТВО !!!"
            view-as alert-box information
          .  */
          chWorkSheet:Rows(Current-ROW):Delete.
end. 
          assign
            chExcelApplication:Interactive    = true
            chExcelApplication:ScreenUpdating = true
            chExcelApplication:Visible        = TRUE .
        FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = shar-buf_ord-doc.exch-code no-error .
        if shar-buf_ord-doc.exch-code <> 0 then
          assign
            PrintRubl = false
            abbr = ub.currency.curr-abbr
            .
        else  PrintRubl =  true .

        if NOT PrintRubl then
          assign
            PropisSum = Total-Word( B-Sum, ub.currency.curr-abbr, ub.currency.part-abbr )
            .
        else
          run rep/wp-rub.p ( B-Sum , output PropisSum, output abbr).
         Assign 
          chWorkSheet:Range ("SumPropis") :Value = PropisSum  no-error .   
    End.
/*  message "Форма подготовлена. Связь с Excel будет закрыта."  view-as alert-box .*/
  RELEASE OBJECT chWorksheet NO-ERROR.
  RELEASE OBJECT chWorkbook NO-ERROR.
  chExcelApplication :QUIT().
  RELEASE OBJECT  chExcelApplication  NO-ERROR.
  RETURN NO-APPLY.

END.

ON CHOOSE OF MENU-ITEM m_PRINT3 /* 8. */
DO:
  if not available shar-buf_ord-doc then return .
  run cus/l-blank.w ( INPUT shar-buf_ord-doc.cli-TYPE , INPUT shar-buf_ord-doc.cli-CODE, output blank#name ).
  RETURN NO-APPLY.
END.

procedure ver-edi :
define parameter buffer buf_ord-doc for ub.ord-doc.
define output parameter v-res as logical   no-undo .
/*почему-то запрещено для edi-заказа*/
v-res = (buf_ord-doc.whole-send-news <> integer({&doc-dm-edi})).
if not v-res then do:
  message "Печатать запрещено!"
  view-as alert-box warning .
end.
end procedure. /* ver-edi */


ON CHOOSE OF MENU-ITEM m_print1-rcv
DO:
  define variable v-rez as logical   no-undo .
  if not available ub.ord-doc-rcv then return .
  run cus/torg-261.p ( parParentProc, recid(ub.ord-doc-rcv) ).
END.

ON CHOOSE OF MENU-ITEM m_print2-rcv
DO:
define buffer post-firm   for ub.firm.
define buffer zakz-shop   for ub.shop.
define buffer zakz-store  for ub.store.
define buffer ord-blank-1 for ub.ord-blank.

define variable j as integer init 0 no-undo .
define variable chexcelapplication      as com-handle no-undo .
define variable chworkbook              as com-handle no-undo .
define variable chworksheet             as com-handle no-undo .
define variable printrubl     as logical no-undo .
define variable abbr          as character no-undo .
define variable propissum     as character no-undo .
define variable b-sum         as decimal no-undo .
define variable N#ROW         as integer  no-undo .
define variable GoodN#ROW     as integer  no-undo .
define variable GoodEI#ROW    as integer  no-undo .
define variable OKEI#ROW      as integer  no-undo .
define variable Qnty#ROW      as integer  no-undo .
define variable Cost#ROW      as integer  no-undo .
define variable Summa#ROW     as integer  no-undo .
define variable N#col         as integer  no-undo .
define variable GoodN#col     as integer  no-undo .
define variable GoodEI#col    as integer  no-undo .
define variable OKEI#col      as integer  no-undo .
define variable Qnty#col      as integer  no-undo .
define variable Cost#col      as integer  no-undo .
define variable Summa#col     as integer  no-undo .
define variable Sort#ROW      as integer  no-undo .
define variable Sort#COL      as integer  no-undo .
define variable GoodCode#ROW  as integer  no-undo .
define variable GoodCode#COL  as integer  no-undo .
define variable CliArt#ROW    as integer  no-undo .
define variable CliArt#COL    as integer  no-undo .
define variable Art#ROW       as integer  no-undo .
define variable Art#COL       as integer  no-undo .

define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
define buffer buf_ord-line     for ub.ord-line      .

define variable v-rez as logical   no-undo .
define variable v-cli-art as character no-undo .

if not available ub.ord-doc-rcv then return .

define variable Current-ROW  as integer no-undo .
define buffer buf_clients for ub.clients  .


find first buf_clients no-lock where
           buf_clients.obj-code = ub.ord-doc-rcv.cli-code and
           buf_clients.obj-type = ub.ord-doc-rcv.cli-type
           no-error .

 if blank#name-rcv = ?  or blank#name-rcv = "" Then
    Find first ub.ord-blank
         where ub.ord-blank.cli-code = ub.ord-doc-rcv.cli-code
           and ub.ord-blank.cli-type = ub.ord-doc-rcv.cli-type
           and ub.ord-blank.last-use-rcv = TRUE
          no-lock no-error.
   else
    Find first ub.ord-blank
         where ub.ord-blank.cli-code = ub.ord-doc-rcv.cli-code
           and ub.ord-blank.cli-type = ub.ord-doc-rcv.cli-type
           and ub.ord-blank.blank-name = blank#name-rcv
          no-lock no-error.

   if not  available  ub.ord-blank  then do :
      message "Для этого поставщика нет формы !   Задайте ее в режиме  <<выбор формы печати>>".
      return.
   end.

   if  available  ub.ord-blank  then do :
       Assign blank#name-rcv = ?.
       For each ord-blank-1
          where ord-blank-1.cli-code = ub.ord-doc-rcv.cli-code
            and ord-blank-1.cli-type = ub.ord-doc-rcv.cli-type
            exclusive-lock :
       if  ub.ord-blank.blank-name = ord-blank-1.blank-name and
           ub.ord-blank.cli-code = ord-blank-1.cli-code     and
           ub.ord-blank.cli-type = ord-blank-1.cli-type then
           ord-blank-1.last-use-rcv = TRUE .
           Else ord-blank-1.last-use-rcv = false  .
       End.
   /**/
define variable v-sum as decimal   no-undo .
v-sum = 0 .
  For each  buf_ord-line-rcv where
            buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code  and
            buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
            no-lock :
            v-sum = v-sum + (buf_ord-line-rcv.cli-qnty * buf_ord-line-rcv.price-cli).
  end.
 B-Sum = ub.ord-doc-rcv.sum-Service + ub.ord-doc-rcv.sum-Ship + v-sum.
 FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = ub.ord-doc-rcv.exch-code no-error .
 if ub.ord-doc-rcv.exch-code <> 0 then
       assign
        PrintRubl = false
        abbr = ub.currency.curr-abbr
        .
 else  PrintRubl =  true .

      if NOT PrintRubl then
           assign
            PropisSum = Total-Word( B-Sum, ub.currency.curr-abbr, ub.currency.part-abbr )
          .
      else
          run rep/wp-rub.p ( B-Sum , output PropisSum, output abbr).


CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        return no-apply .
    end.
ASSIGN
  chExcelApplication:Visible = FALSE
  chWorkbook  = chExcelApplication:Workbooks:Add ( ub.ord-blank.file-name )
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  chExcelApplication:Interactive    = false
  chExcelApplication:ScreenUpdating = false
  .

  /* Шапка */
       /* Поставщик */

      Find first post-firm where  post-firm.firm-code = ub.ord-doc-rcv.cli-code no-lock  no-error .
      if available post-firm THEN
       Assign
        chworksheet:range ("Fullname")  :Value   = buf_clients.obj-name
        chWorkSheet:Range ("PosAddres1"):Value   = post-firm.addres1
        chWorkSheet:Range ("PosAddres2"):Value   = post-firm.addres2
        chWorkSheet:Range ("PosOKPO")   :Value   = post-firm.okpo
        chWorkSheet:Range ("PosPhone1") :Value   = post-firm.phone1-note
        chWorkSheet:Range ("PosPhone2") :Value   = post-firm.phone no-error.

       /* Заказчик - объект */
       find first buf_clients no-lock where
                  buf_clients.obj-code = ub.ord-doc-rcv.obj-code and
                  buf_clients.obj-type = ub.ord-doc-rcv.obj-type no-error .
       if ub.ord-doc-rcv.obj-type = {&shop} then do:
          find first zakz-shop where  zakz-shop.obj-code = ub.ord-doc-rcv.obj-code no-lock  no-error .
          if available zakz-shop then
          assign
            chworksheet:range ("ZakFullname"):Value  = buf_clients.obj-name
            chWorkSheet:Range ("ZakAddres1"):Value   = zakz-shop.addres1
            chWorkSheet:Range ("ZakAddres2"):Value   = zakz-shop.addres2
            chWorkSheet:Range ("ZakPhone2") :Value   = zakz-shop.phone
            no-error.
       end.
       else do:
          find first zakz-store where  zakz-store.obj-code = ub.ord-doc-rcv.obj-code no-lock  no-error .
          if available zakz-store then
          assign
            chworksheet:range ("ZakFullname"):Value  = buf_clients.obj-name
            chWorkSheet:Range ("ZakAddres1"):Value   = zakz-store.addres1
            chWorkSheet:Range ("ZakAddres2"):Value   = zakz-store.addres2
            chWorkSheet:Range ("ZakPhone2") :Value   = zakz-store.phone
            no-error.
       end.

        /*почему-то иногда не выводит, если в 1 assign все поместить!!!*/
       Assign chworksheet:range ("Number")     :value = ub.ord-doc-rcv.rcv-code no-error.
       Assign chworksheet:range ("NumberZakaz"):value = ub.ord-doc-rcv.doc-code no-error.
       Assign chworksheet:range ("NumberPost") :value = entry( 1, ub.ord-doc-rcv.sub-par, {&delim-par} ) no-error.
       Assign chworksheet:range ("TimePost")   :value = string(ub.ord-doc-rcv.ship-time,"hh:mm") no-error.
       Assign chworksheet:range ("DatePost")   :value = string(ub.ord-doc-rcv.ship-date, "99/99/9999") no-error.
       Assign chworksheet:range ("SumShip")    :value = ub.ord-doc-rcv.sum-ship no-error.
       Assign chworksheet:range ("SumService") :value = ub.ord-doc-rcv.sum-service  no-error.
       Assign chworksheet:range ("SumPropis")  :value = propissum      no-error .
       Assign
        chworksheet:range ("DateDoc") :value  = if ub.ord-doc-rcv.fact-date <> ?
        then string(ub.ord-doc-rcv.fact-date, "99/99/9999" )
        else string(ub.ord-doc-rcv.doc-date,  "99/99/9999" )
        no-error .

      /* Определим обсолютные значения для колонок таблицы - чтобы вставлять произвольное количество строк */
     Assign

    N#ROW        = chWorkSheet:Range ("N" ):Row
     N#COL        = chWorkSheet:Range ("N" ):Column
     Sort#ROW     = chWorkSheet:Range ("Sort" ):Row
     Sort#COL     = chWorkSheet:Range ("Sort" ):Column
     GoodCode#ROW = chWorkSheet:Range ("GoodCode" ):Row
     GoodCode#COL = chWorkSheet:Range ("GoodCode" ):Column

     GoodN#ROW    = chWorkSheet:Range ("GoodN" ):Row
     GoodEI#ROW   = chWorkSheet:Range ("EIn"   ):Row
     OKEI#ROW     = chWorkSheet:Range ("GoodEI"):Row
     Qnty#ROW     = chWorkSheet:Range ("Qnty"  ):Row
     Cost#ROW     = chWorkSheet:Range ("Cost"  ):Row
     Summa#ROW    = chWorkSheet:Range ("Summa" ):Row
     CliArt#ROW   = chWorkSheet:Range ("CliArt"):Row
     Art#ROW      = chWorkSheet:Range ("Art"   ):Row

     GoodN#COL    = chWorkSheet:Range ("GoodN" ):Column
     GoodEI#COL   = chWorkSheet:Range ("EIn"   ):Column
     OKEI#COL     = chWorkSheet:Range ("GoodEI"):Column
     Qnty#COL     = chWorkSheet:Range ("Qnty"  ):Column
     Cost#COL     = chWorkSheet:Range ("Cost"  ):Column
     Summa#COL    = chWorkSheet:Range ("Summa" ):Column
     CliArt#COL   = chWorkSheet:Range ("CliArt"):Column
     Art#COL      = chWorkSheet:Range ("Art"   ):Column
     no-error.
     /* GoodCode  Sort  */

         Current-ROW = maximum( if N#ROW       = ? then 0 else N#ROW      ,
                                if GoodN#ROW   = ? then 0 else GoodN#ROW  ,
                                if GoodEI#ROW  = ? then 0 else GoodEI#ROW ,
                                if OKEI#ROW    = ? then 0 else OKEI#ROW   ,
                                if Art#ROW  = ? then 0 else Art#ROW ,
                                if CliArt#ROW  = ? then 0 else CliArt#ROW ,
                                if Qnty#ROW    = ? then 0 else Qnty#ROW   ,
                                if Cost#ROW    = ? then 0 else Cost#ROW   ,
                                if Summa#ROW   = ? then 0 else Summa#ROW  )
                                .
      /* таблица */
      For each  buf_ord-line-rcv where
                buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
                buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
                no-lock :
       chWorkSheet:Rows(Current-ROW):Insert .
      End.
      For each  buf_ord-line-rcv where
                buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code  and
                buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
                no-lock :
         J = J + 1 .
         FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = buf_ord-line-rcv.prod-type AND
                                        ub.goods.prod-code = buf_ord-line-rcv.prod-code AND
                                        ub.goods.artic     = buf_ord-line-rcv.artic  NO-ERROR.
         find first ub.units where ub.units.unit-name = buf_ord-line-rcv.unit-cli no-lock no-error .

         find first buf_ord-line no-lock where
                    buf_ord-line.artic = buf_ord-line-rcv.artic and
                    buf_ord-line.prod-type = buf_ord-line-rcv.prod-type and
                    buf_ord-line.prod-code = buf_ord-line-rcv.prod-code and
                    buf_ord-line.doc-code  = buf_ord-line-rcv.doc-code no-error .

          if available buf_ord-line then v-cli-art = buf_ord-line.cli-art .
                                    else v-cli-art = "" .

         Assign chWorkSheet:Range (string(COL-NAME[N#col])        + String(N#ROW        + J)):Value  = J no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodN#col])    + String(GoodN#ROW    + J)):Value  = ub.goods.gds-name no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Sort#col])     + String(Sort#ROW     + J)):Value  = ub.goods.Sort     no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodCode#col]) + String(GoodCode#ROW + J)):Value  = ub.goods.gds-code no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodEI#col])   + String(GoodEI#ROW   + J)):Value  = buf_ord-line-rcv.unit-cli  no-error.
         Assign chWorkSheet:Range (string(COL-NAME[OKEI#col])     + String(OKEI#ROW     + J)):Value  = if available ub.units THEN String(ub.units.OKEI,">>>>>") Else "" no-error.
         Assign chWorkSheet:Range (string(COL-NAME[CliArt#col])   + String(CliArt#ROW   + J)):Value  = v-cli-art no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Art#col])      + String(Art#ROW      + J)):Value  = buf_ord-line-rcv.artic no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Qnty#col])     + String(Qnty#ROW     + J)):Value  = buf_ord-line-rcv.cli-qnty no-error .
         Assign chWorkSheet:Range (string(COL-NAME[Cost#col])     + String(Cost#ROW     + J)):Value  = buf_ord-line-rcv.price-cli no-error .
         Assign chWorkSheet:Range (string(COL-NAME[Summa#col])    + String(Summa#ROW    + J)):Value  = round ( buf_ord-line-rcv.cli-qnty * buf_ord-line-rcv.price-cli , 2) no-error .
         /*
         if error-status :error and  J  = 1 then message
           "Внимание ! Шаблон Excel не содержит поля  КОЛИЧЕСТВО !!!"
           view-as alert-box information
         .  */
       END.
      chWorkSheet:Rows(Current-ROW):Delete.
      assign
      chExcelApplication:Interactive    = true
      chExcelApplication:ScreenUpdating = true
      chExcelApplication:Visible        = TRUE .
   End.
  message "Форма Поставки подготовлена. Связь с Excel будет закрыта."  view-as alert-box .
  RELEASE OBJECT chWorksheet NO-ERROR.
  RELEASE OBJECT chWorkbook NO-ERROR.
  chExcelApplication :QUIT().
  RELEASE OBJECT  chExcelApplication  NO-ERROR.
  RETURN NO-APPLY.
END.

ON CHOOSE OF MENU-ITEM m_PRINT3-rcv
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/l-blank.w ( input ub.ord-doc-rcv.cli-type , input ub.ord-doc-rcv.cli-code, output blank#name-rcv ).
  return no-apply.
END.

/* $Workfile$ e n d */