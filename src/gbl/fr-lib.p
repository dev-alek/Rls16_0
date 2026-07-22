block-level on error undo, throw.
/*

$Revision: 8daa160be6fd, 983, rls $
$Author: PGridchina $
$Date: Fri Jun 23 11:47:54 2017 +0300 $
$Workfile: fr-lib.p $
$Archive: gbl/fr-lib.p $

Библиотека для работы с фискальным регистратором

Автор: Белоусов Илья Александрович
Дата создания: 07/14/08
Author: Ilia Belousov
Creation date: 07/14/08

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: 8daa160be6fd, 983, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 23 11:47:54 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fr-lib.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/fr-lib.p $":U .
define variable vss-description as character no-undo init "Библиотека для работы с фискальным регистратором".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/fr-lib.i   }


if valid-handle (g#fr-lib)
and g#fr-lib <> this-procedure :handle
and g#fr-lib :get-signature('library_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#fr-lib skip
    g#fr-lib :type skip
    g#fr-lib :file-name skip
    valid-handle(g#fr-lib) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#fr-lib = this-procedure :handle
  .
end.

if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.

on delete of this-procedure do:
  assign
    g#fr-lib = ?
  .
end.

&scop shtrikh-m  100
&scop prim08tkm  200

DEFINE VARIABLE v-fr          AS COM-HANDLE     NO-UNDO . /* Ссылка на драйвер */
DEFINE VARIABLE v-fr-type     AS INTEGER INIT ? NO-UNDO . /* Тип ФР */
DEFINE VARIABLE v-fr-FiskSts  AS INTEGER INIT -1 NO-UNDO. /* Статус фискального режима */
DEFINE VARIABLE v-fr-ShiftNum AS INTEGER INIT -1 NO-UNDO.     /* Номер смены */
DEFINE VARIABLE v-fr-KKMNum   AS character INIT "":U NO-UNDO. /* Номер ККМ */

DEFINE VARIABLE v-fr-TimOut     AS INTEGER     INIT 5000 NO-UNDO.      /* Значение тайм-аута */
DEFINE VARIABLE v-fr-LastDoc    AS INTEGER     INIT -1 NO-UNDO.        /* Номер последнего документа */
DEFINE VARIABLE v-fr-LastDate   AS DATE        NO-UNDO.                /* Дата последнего документа */
DEFINE VARIABLE v-fr-LastTime   AS INTEGER     INIT -1 NO-UNDO.        /* Время последнего документа */
DEFINE VARIABLE v-fr-ch-beg     AS character   NO-UNDO.                /* Заголовок чека */
DEFINE VARIABLE v-fr-ch-end     AS character   INIT "             СПАСИБО ЗА ПОКУПКУ" NO-UNDO. /* Конец чека */

DEFINE VARIABLE v-fr-AF         AS character   INIT "->>>>>>>>>>>>>>>>>>>>9.99":U NO-UNDO.   /* Формат суммы и цены        */
DEFINE VARIABLE v-fr-QF         AS character   INIT "->>>>>>>>>>>>>>>>>>>>9.999":U NO-UNDO.  /* Формат количества          */
DEFINE VARIABLE v-fr-QF2        AS character   INIT "->>>>>>>>>>>>>>>>>>>>9":U NO-UNDO.      /* Формат штучного количества */
DEFINE VARIABLE v-fr-trim       AS character   INIT " ":U NO-UNDO.                           /* Символы обрезки формата    */

define variable v-cd-mode       as character    no-undo.
define variable v-cd-submode    as character    no-undo.
define variable v-model    as integer      no-undo.

define variable v-cash-drawer-plug    as logical      no-undo.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-init Include
PROCEDURE fr-init :
/*------------------------------------------------------------------------------
  Purpose: Подключение к ФР и инициализацияю.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-dc-number     as integer        no-undo.
define input parameter p-shop-number   as integer        no-undo.
define input parameter p-serial-number as character        no-undo.
define input  parameter p-fr-type      as character      no-undo .
define input  parameter p-com-port     as character      no-undo .
define output parameter p-fr-model     as integer        no-undo.
define output parameter p-err-message  as character      no-undo.
define output parameter p-ok           as logical        no-undo.

define variable v-ok                 as logical      no-undo.
define variable v-err-message        as character    no-undo.
define variable v-i                  as integer      no-undo .
define variable v-return             as int          no-undo .
define variable v-Type-KKM           as char         no-undo .
define variable v-Ser-Num            as char         no-undo .
define variable v-LastShiftNum       as int          no-undo .
define variable         v-datefirstdoc       as character no-undo .
define variable         v-timefirstdoc       as character no-undo .
define variable         v-cLastShiftNum      as char      no-undo .
define variable v-status-current as character no-undo .
define variable v-status-const   as character no-undo .


    case p-fr-type:
      when {&fr-type-prim08tk} then v-fr-type = {&prim08tkm} .
      when {&fr-type-shtrih-fr-k-01} then v-fr-type = {&shtrikh-m} .
    end case .


if v-fr-type = ? then
do:
   assign
      p-err-message = "Не определен фискальный регистратор"
      p-ok = no
      error-status:error = yes
      .
   return error.
end.

bl:
DO
ON ERROR UNDO, RETURN ERROR
:
 case v-fr-type :
   when {&shtrikh-m} then
  _shtrikh:
   DO:
      RELEASE OBJECT v-fr NO-ERROR.
      v-fr = ?.


      CREATE "AddIn.DrvFR":U v-fr CONNECT NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR NOT VALID-HANDLE(v-fr)
      THEN DO:
         CREATE "AddIn.DrvFR":U v-fr NO-ERROR.
      END.

      IF ERROR-STATUS:ERROR
      OR NOT VALID-HANDLE(v-fr)
      THEN DO:
         ASSIGN

            p-err-message = "Не найден COM-сервер для ФР Штрих"
            p-ok = FALSE
         .
         LEAVE _shtrikh.
      END.


      v-fr:Password = 1.
      v-fr:CONNECT() NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR v-fr:ResultCode <> 0
      THEN DO:
         ASSIGN
            p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription + STRING(v-fr:ResultCode) ELSE ""
            p-ok = FALSE

         .
         /* ищем другой ФР */
         LEAVE _shtrikh.
      END.


      IF INT(v-fr:ECRMode) = 8 THEN  /* открыт документ */
      DO:
         x_v-fr-check_re_bl:
         DO WHILE YES:
            v-fr:GetECRStatus(). /* Получить состояние ФР */
            DO WHILE v-fr:ResultCode <> 0:
                  IF v-fr:ResultCode = -1
                  THEN DO:
                     /*
                     ASSIGN
                        p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
                        p-ok          = TRUE
                     .
                     */
                  END.
                  v-fr:GetECRStatus().
            END.

            CASE INTEGER(v-fr:ECRAdvancedMode):
               WHEN 0 THEN DO:  /* ФР готов */
                  LEAVE x_v-fr-check_re_bl.
               END.
               WHEN 3 OR  /* ФР в фазе печати */
               WHEN 5     /* ФР в фазе печати длинного отчета */
               THEN DO:
                  v-fr:ContinuePrint().
               END.
               OTHERWISE DO:  /* ФР не готов, требуется вмешательство оператора */
                  ASSIGN
                     p-err-message = v-fr:ECRAdvancedModeDescription
                     p-ok          = TRUE
                  .
                  RETURN.
               END.
            END CASE.
            /*
            IF v-fr:ECRAdvancedMode = 0
            THEN LEAVE x_v-fr-check_re_bl.
            ELSE IF v-fr:ECRAdvancedMode = 3
               THEN v-fr:ContinuePrint().
               ELSE IF v-fr:ECRAdvancedMode = 2
                     THEN DO:
                        v-fr:Beep() NO-ERROR.
                        message
                           v-fr:ECRAdvancedModeDescription
                           skip
                        view-as alert-box information.
                     END.
                     ELSE IF v-fr:ECRAdvancedMode = 1
                           THEN DO:
                              v-fr:Beep() NO-ERROR.
                              message
                                 v-fr:ECRAdvancedModeDescription
                                 skip
                              view-as alert-box information.
                           END.
            */
         END. /* DO WHILE YES */
         v-fr:Password = 30.
         v-fr:SysAdminCancelCheck().
         v-fr:Password = 1.

         IF v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
               p-ok = FALSE
            .
            RETURN.
         END.
      END. /* открыт документ */

      v-fr:GetECRStatus() NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR v-fr:ResultCode <> 0
      THEN DO:
         ASSIGN
            p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription + STRING(v-fr:ResultCode) ELSE ""
            p-ok = FALSE
         .
         RETURN.
      END.
      IF v-fr:SerialNumber <> p-serial-number
      THEN DO:
         assign
            p-err-message = SUBSTITUTE ( "Серийный номер ФР (&1) отличается от указанного в настройках (&2)"
                                    , v-fr:SerialNumber
                                    , p-serial-number
                                    )
            p-ok      = FALSE
         .
         RETURN.
      END.

      v-fr:GetDeviceMetrics() NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR v-fr:ResultCode <> 0
      THEN DO:
         ASSIGN
            p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription + STRING(v-fr:ResultCode) ELSE ""
            p-ok = FALSE
         .
         RETURN.
      END.

      ASSIGN
         p-fr-model = v-fr:UModel
         v-model    = v-fr:UModel
         p-ok = yes
         p-err-message = ""
      .
   END.
   /*  ПРИМ08ТК  */
   when {&prim08tkm} then
   do:
    do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
     :


     run fr-openDll(input p-com-port,
                     output v-return) .



     run Fr-GetStatusCurrent(output v-status-const ,
                             output v-status-current ,
                             output v-return )
                            .
      if substr(v-status-const,12,1) = '1' then
      do:
         message "Чековая лента близка к концу"
            view-as alert-box title "Сообщение".
      end.

      if substr(v-status-const,11,1) = '1' then
      do:
         message "Печать остановлена из-за конца бумаги"
            view-as alert-box title "Сообщение".
      end.

      if substr(v-status-const,10,1) = '1' then
      do:
         message "Открыта крышка принтера"
            view-as alert-box title "Сообщение".
      end.

      if substr(v-status-current,12,1) = "1" then
      do:
         message "Необходимо снять Z-отчет"
                      view-as alert-box title "Сообщение".

      end.



     if v-return = 0 or v-return = 21 then
     do:
       run Fr-GetFiscalNums (output v-Type-KKM,
                             output v-Ser-num,
                             output v-return).



       if v-return = 0 then
       do:
          if v-Ser-Num <> p-serial-number then
          do:
            assign
              p-err-message = SUBSTITUTE ( "Серийный номер ФР (&1) отличается от указанного в настройках (&2)"
                                    , v-Ser-num
                                    , p-serial-number
                                    )
              p-ok = False
              .
            return .
          end.
          p-fr-model = 8 .


          assign p-ok = yes
                 p-err-message = ""
                   .


          run Fr-GetResource(output v-return ,
                             output v-lastshiftnum ,
                             output v-datefirstdoc ,
                             output v-timefirstdoc) .



          if v-return = 0 then
          do :
            v-cLastShiftNUm = string(v-lastShiftNum,'9999999') .
            run Fr-WriteCMOS(input 0 , /* смещение в CMOS */
                             input v-cLastShiftNum ,
                             output v-return).
            run Fr-WriteCMOS(input 7 , /* смещение в CMOS */
                             input v-datefirstdoc ,
                             output v-return).
            run Fr-WriteCMOS(input 13 , /* смещение в CMOS */
                             input v-timefirstdoc ,
                             output v-return).

          end .
          if substr(v-status-current,5,1) = "0" then
          do:
            run Fr-SetDate(output v-return) .  /* Установить время с сервера */

          end.
       end .
     end .
     else
     do :
       assign
         p-ok = no
         p-err-message = " "
         .

       if v-return = 194 then
       do:
         p-err-message = "Необходимо включить фискальный регистратор" .
       end.

       return .

     end .
    end .  /* on error */
   end .
  end case .

END. /* DO ON ERROR */
END PROCEDURE. /* fr-init */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-set Include
PROCEDURE fr-set :
/*------------------------------------------------------------------------------
  Purpose: Установка настроек ФР
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter  p-pay-chk               as character        no-undo. /* + */
define input parameter  p-z-zero                as logical          no-undo. /* + */
define input parameter  p-cashier-name          as character        no-undo. /* + */
define input parameter  p-cash-drawer-plug      as logical          no-undo.
define input parameter  p-cash-drawer-plug-imp  as integer          no-undo.
define input parameter  p-cutter                as logical          no-undo.
define input parameter  p-cash-drawer-level     as integer          no-undo.
define input parameter  p-publ-chk              as character /* extent 6  */    no-undo. /* + */
define input parameter  p-head-chk              as character /* extent 6  */    no-undo. /* + */
define input parameter  p-print-good-code       as logical          no-undo. /* ??? */
define input parameter  p-max-netto             as DECIMAL          no-undo.
define input parameter  p-cash-shift            as logical          no-undo.
define input parameter  p-cash-drawer-open      as logical          no-undo.
define input parameter  p-cash-drawer-limit     as DECIMAL          no-undo.
define input  parameter p-clear-cash-counter    as logical          no-undo .
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

define variable v-Return as int no-undo .
define variable v-cashier-name  as char no-undo .
define variable v-header as character extent 6 no-undo .
define variable v-i as integer   no-undo .
define variable v-const-status as character no-undo .
define variable v-current-status as character no-undo .
define variable v-clear-cash-counter as char no-undo .
define variable v-cutter as character no-undo .

   CASE v-fr-type :
   when {&prim08tkm} then
   do:
     do
     on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
     on stop   undo, return error substitute( "&1. stop", vss-workfile )
     on endkey undo, return error substitute( "&1. endkey", vss-workfile )
     :
     /* Кассир  */
       v-cashier-name = replace(p-cashier-name, "Кассир", "") .
       run Fr-ChangeOpName( input v-cashier-name,
                          output v-Return) .
       if v-Return = 0 then
       do:
          run Fr-GetStatusCurrent(output v-const-status,
                                  output v-current-status,
                                  output v-return
                                  ) .
          if substr(v-current-status,5,1) = '0' then      /* если смена закрыта  , то меняем заголовки и пр. */
          do:
            assign
            v-cutter = "1"
            v-clear-cash-counter = "0".
            if p-cutter then
            do:
              assign
                 v-cutter = '0'.
            end.
            if p-clear-cash-counter then
            do:
              assign
                 v-clear-cash-counter = '1'.
            end.

            run Fr-SetParamDoc(input v-clear-cash-counter,
                               input v-cutter)
                               .

            DO v-i = 1 to NUM-ENTRIES(p-head-chk, {&delim-par}) :
              assign
                v-header[v-i] = ENTRY(v-i , p-head-chk, {&delim-par}) .
            END .

            run SetHeaderNew( input v-header[1],
                 input v-header[2],
                 input v-header[3],
                 input v-header[4],
                 input '',
                 input '',
                 output v-return )
                 .

            assign
              v-header = ''
              .

            DO v-i = 1 to NUM-ENTRIES(p-publ-chk, {&delim-par}) :
              assign
                v-header[v-i] = ENTRY(v-i , p-publ-chk, {&delim-par}) .
            END .


            run SetTail( input v-header[1],
                 input v-header[2],
                 input v-header[3],
                 input v-header[4],
                 output v-return )
                 .

            DO v-i = 1 to NUM-ENTRIES(p-pay-chk, {&delim-par}):

              IF v-i > 4 THEN LEAVE .

            END.


          end.
          assign
            p-ok = yes
            p-err-message = "" .
       end.

     end.
   end.
   WHEN {&shtrikh-m} THEN DO:

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   ASSIGN
      v-cash-drawer-plug = p-cash-drawer-plug
   .

      /* Заполнение свойств ККМ */
      v-fr:GetECRStatus().
      IF v-fr:ResultCode <> 0
      THEN DO:
         assign
            p-err-message = v-fr:ResultCodeDescription
            p-ok      = FALSE
         .
         RETURN.
      END.

      /* !!! Проверка фискального режима
      v-fr-fisksts = -1.
      v-fr-fisksts = v-fr:InfIsFiscal.
      */

      /* !!! Время последнего документа
      v-fr-LastTime = -1.
      v-fr-LastTime = (INT(ENTRY(1, v-fr:TimeStr, ":":U)) * 3600) + (INT(ENTRY(2, v-fr:TimeStr, ":":U)) * 60) + INT(ENTRY(3, v-fr:TimeStr, ":":U)).
      */

      /* !!! Дата последнего документа
      v-fr-LastDate = ?.
      v-fr-LastDate = v-fr:DATE. /*DATE(INT(v-fr:InfDateMonth), INT(v-fr:InfDateDay), INT(v-fr:InfDateYear))*/
      IF v-fr:ECRMode = 3 THEN v-fr-LastDate = TODAY - 1.
      */

      IF v-fr:ECRMode = 10
      THEN DO:
         v-fr:Password = 30.
         v-fr:InterruptTest().
         IF v-fr:ResultCode <> 0
         THEN DO:
            assign
               p-err-message = v-fr:ResultCodeDescription
               p-ok      = FALSE
            .
            RETURN.
         END.
      END.

      /* !!! Номер последнего документа
      v-fr-LastDoc = -1.
      v-fr-LastDoc = INT(v-fr:OpenDocumentNumber).
      */

      /* !!! Номер ККМ
      v-fr-KKMNum = "":U.
      v-fr-KKMNum = STRING(v-fr:SerialNumber).
      */

      /* !!! Номер смены
      v-fr-ShiftNum = -1.
      v-fr-ShiftNum = INT(v-fr:SessionNumber) + 1.
      */

      /*
      IF v-fr:ECRMode = 4 THEN
      DO:
      END.
      */
      v-fr:Password = 30.

      /* Настройки ФР */
      /* Автообнуление наличности при Z-отчете */
      ASSIGN
      v-fr:TableNumber = 1
      v-fr:RowNumber = 1
      v-fr:FieldNumber = 2
      v-fr:ValueOfFieldInteger = IF p-z-zero THEN 1 ELSE 0
      .
      v-fr:GetFieldStruct().
      v-fr:WriteTable().

      /* Подключение ДЯ */
      ASSIGN
      v-fr:TableNumber = 1
      v-fr:RowNumber = 1
      v-fr:FieldNumber = 7
      v-fr:ValueOfFieldInteger = IF p-cash-drawer-plug THEN 1 ELSE 0
      .
      v-fr:GetFieldStruct().
      v-fr:WriteTable().

      /* ??? Печать текстовых строк на ленте журнала
      ASSIGN
         v-fr:FieldNumber = 3
         v-fr:ValueOfFieldInteger = 1
      .
      v-fr:GetFieldStruct().
      v-fr:WriteTable().
      */

      /* Отрезка чека после завершения */
      ASSIGN
         v-fr:FieldNumber = 8
         v-fr:ValueOfFieldInteger = IF p-cutter  THEN 2 ELSE 0
      .
      v-fr:GetFieldStruct().
      v-fr:WriteTable().

      /* РЕКЛАМА */
      define variable v-count    as integer      no-undo.
      define variable v-found as logical no-undo .
      v-found = no.
      _publ:
      DO v-count = 1 to NUM-ENTRIES(p-publ-chk, {&delim-par}):
        v-found = length(ENTRY(v-count, p-publ-chk, {&delim-par})) > 0 or v-found.
        ASSIGN
        v-fr:TableNumber  = 4
        v-fr:RowNumber    = v-count
        v-fr:FieldNumber  = 1
        v-fr:ValueOfFieldString = ENTRY(v-count, p-publ-chk, {&delim-par})
         .
        IF v-count > 3 THEN LEAVE _publ.
        v-fr:GetFieldStruct().
        v-fr:WriteTable().
      END.
      /*КОЛИЧЕСТВО СТРОК РЕКЛАМНОГО ТЕКСТА лежит в таблица 1 ряд 1 поле 44 -  мин 3 макс 10*/
      ASSIGN
      v-fr:TableNumber = 1
      v-fr:RowNumber = 1
      v-fr:FieldNumber = 44
      v-fr:ValueOfFieldInteger = 3
      .
      v-fr:GetFieldStruct().
      /*на смом деле клише - заголовок идет за рекламой - сколько строк занимает реклмам нужно узнать!! чтобы значть куда тюхать клише*/
      define variable v-adv-lines-num as integer no-undo .
      v-adv-lines-num =  v-fr:MAXValueOfField.
      v-fr:WriteTable().
      /*включим.Выключим печать*/
      /*ПЕАчАТЬ СТРОК РЕКЛАМНОГО ТЕКСТА лежит в таблица 1 ряд 1 поле 4*/
      ASSIGN
      v-fr:TableNumber = 1
      v-fr:RowNumber = 1
      v-fr:FieldNumber = 4
      v-fr:ValueOfFieldInteger = (if v-found then 1 else 0)
      .
      v-fr:GetFieldStruct().
      v-fr:WriteTable().


      /* !!!! ИНН */


      /* строки заголовка чека */
      v-found = no.
      define variable v-line as character no-undo .
      _clish:
      DO v-count = 1 to 6 /* раньше пытались 6 строк втиснуть но 6 строк печатается только если отлючить отрезание!!!
      и уменьшить шрифт!      NUM-ENTRIES(p-head-chk, {&delim-par}) */ :
        if v-count < 3 then do:
          /*поэтому пропустим 2 строки*/
          v-line = ''.
        end.
        else do:
          assign
          v-line = ENTRY(v-count - 2, p-head-chk, {&delim-par})
          v-found = length(v-line) > 0 or v-found.
        end.
        ASSIGN
        v-fr:TableNumber = 4
        v-fr:RowNumber   = v-count + v-adv-lines-num  /*сколько строк занято рекламным текстом!!!!*/
        v-fr:FieldNumber = 1
        v-fr:ValueOfFieldString = v-line
         .
        IF v-count > 6 THEN LEAVE _clish.
        v-fr:GetFieldStruct().
        v-fr:WriteTable().
      END.
      /*включим.Выключим печать*/
      /*ПЕЧАТАТЬ ЛИ КЛИШЕ лежит в таблица 1 ряд 1 поле 46*/
      ASSIGN
      v-fr:TableNumber = 1
      v-fr:RowNumber = 1
      v-fr:FieldNumber = 46
      v-fr:ValueOfFieldInteger = (if v-found then 1 else 0)
      .
      v-fr:GetFieldStruct().
      v-fr:WriteTable().



      /* Кассир */
      ASSIGN
         v-fr:TableNumber = 2
         v-fr:RowNumber   = 1
         v-fr:FieldNumber = 2
         v-fr:ValueOfFieldString = p-cashier-name
      .
      v-fr:GetFieldStruct().
      v-fr:WriteTable().

      /* Виды оплаты */
      _set_pay:
      DO v-count = 1 to NUM-ENTRIES(p-pay-chk, {&delim-par}):

         IF v-count > 4 THEN LEAVE _set_pay.

         ASSIGN
            v-fr:TableNumber = 5
            v-fr:RowNumber   = v-count + 1
            v-fr:FieldNumber = 1
            v-fr:ValueOfFieldString = ENTRY(v-count, p-pay-chk, {&delim-par})
         .
         v-fr:GetFieldStruct().
         v-fr:WriteTable().
      END.

      v-fr:GetECRStatus().
      IF v-fr:ResultCode <> 0
      THEN DO:
         assign
            p-err-message = v-fr:ResultCodeDescription
            p-ok      = FALSE
         .
         RETURN.
      END.
      /*
      assign
         v-fr:TableNumber = 4
         v-fr:RowNumber   = 6
         v-fr:FieldNumber = 1
      .
      v-fr:ReadTable().
      v-fr:Password = 1.

      */
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .

   END. /* {&shtrikh-m} */
END. /* DO ON ERROR */
   OTHERWISE DO:
   END.
   END CASE.
END PROCEDURE.  /* fr-set */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-dtset Include
PROCEDURE fr-dtset :
/*------------------------------------------------------------------------------
  Purpose: Установка даты на ФР
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
define variable   v-return    as integer no-undo .

case v-fr-type :
  when {&shtrikh-m} then
  do:
    IF VALID-HANDLE(v-fr)
    THEN DO
    ON ERROR UNDO, RETURN ERROR
    :
       ASSIGN
            v-fr:Password = 30.
            v-fr:date     = TODAY
         .
         v-fr:SetDate() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
               p-ok = FALSE
            .
            RETURN.
         END.
         assign p-ok = yes
                p-err-message = IF v-fr:ResultCode <> 0 then v-Fr:ResultCodeDescription else ""
                .
    END.   /* on error  */
  end.

  when {&prim08tkm} then
  do:
    do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
     run Fr-SetDate(output v-return) .
     if v-return = 0 then
     do:
        assign
          p-ok = yes
          p-err-message = "" .
     end.
     else
     do:
        assign
           p-ok = no .
        run Fr-ErrorMessage(output p-err-message) .
     end.

    end.
  end.
      OTHERWISE DO:
      END.
END CASE.

END PROCEDURE. /* fr-dtset */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-dtget Include
PROCEDURE fr-dtget :
/*------------------------------------------------------------------------------
  Purpose: Дата на ФР
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-date         as date             no-undo.
define output parameter p-err-message  as character        no-undo.
define output parameter p-ok           as logical          no-undo.
define variable    v-return   as int  no-undo .
define variable    v-dateKKm  as char no-undo .
define variable    v-timeKKM  as char no-undo .

case v-fr-type :
 when {&shtrikh-m} then
 do:
  IF VALID-HANDLE(v-fr)
    THEN DO
     ON ERROR UNDO, RETURN ERROR
    :
   ASSIGN
      p-date         = v-fr:date
      p-ok           = TRUE
      p-err-message  = v-fr:ResultCodeDescription
   .
  END.  /* do on error */
 end.
 when {&prim08tkm} then
 do:
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :
    run Fr-GetDate(output v-return  ,
                   output v-dateKKM ,
                   output v-timeKKM
                   )
                   .
    if v-return = 0  then
    do:
     assign
       p-date = date(v-dateKKM)
       p-ok = yes
       p-err-message =  ''.
    end.
    else
    do:
      run Fr-ErrorMessage(output p-err-message) .
      assign p-ok = no .
    end.

   end.
 end.
 end case .
END PROCEDURE. /* fr-dtget */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-tmset Include
PROCEDURE fr-tmset :
/*------------------------------------------------------------------------------
  Purpose: Установка времени на ФР
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo .
define output parameter p-ok          as logical          no-undo .
define variable  v-return as int no-undo .

case v-fr-type :
  when {&shtrikh-m} then
  do:
    IF VALID-HANDLE(v-fr)
    THEN DO
    ON ERROR UNDO, RETURN ERROR
    :
         ASSIGN
            v-fr:Password = 30.
            v-fr:ConfirmDate().
            v-fr:TIME = TIME / 86400.
         .
         v-fr:SetTime() NO-ERROR .

         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
               p-ok = FALSE
            .
            RETURN .
         END .

         assign p-ok = yes
                p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
                .

    end . /* on error */
  end .
  when {&prim08tkm} then
  do:
    do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
     run Fr-SetDate(output v-return) .
     if v-return = 0 then
     do:
        assign
          p-ok = yes
          p-err-message = "" .
     end.
     else
     do:
        assign
           p-ok = no .
        run Fr-ErrorMessage(output p-err-message) .
     end .

    end.
  end .
end case .
END PROCEDURE. /* fr-tmset */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-tmget Include
PROCEDURE fr-tmget :
/*------------------------------------------------------------------------------
  Purpose: Установка времени на ФР
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-time        as integer        no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
define variable    v-return   as int  no-undo .
define variable    v-dateKKm  as char no-undo .
define variable    v-timeKKM  as char no-undo .


case v-fr-type :
  when {&shtrikh-m} then
  do:
    IF VALID-HANDLE(v-fr)
    THEN DO
    ON ERROR UNDO, RETURN ERROR
    :
     ASSIGN
      p-time = (INT(ENTRY(1, v-fr:TimeStr, ":":U)) * 3600) + (INT(ENTRY(2, v-fr:TimeStr, ":":U)) * 60) + INT(ENTRY(3, v-fr:TimeStr, ":":U))
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
        .
    END.  /* do on error */
  end.
when {&prim08tkm} then
 do:
    do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
      run Fr-GetDate(output v-return ,
                   output v-dateKKM ,
                   output v-timeKKM
                    )
                   .
     if v-return = 0  then
     do:
       assign
         p-time = int(substr(v-timeKKM,1,2)) * 3600 + int(substr(v-timeKKM,3,2)) * 60
         p-ok = yes
         p-err-message =  ''.
     end.
     else
     do:
        run Fr-ErrorMessage(output p-err-message) .
        assign p-ok = no .
     end.

    end.
 end.

end case .
END PROCEDURE. /* fr-tmget */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-ctrl Include
PROCEDURE fr-ctrl :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter  p-dr-open            as logical          no-undo.
define output parameter p-err-message        as character        no-undo.
define output parameter p-ok                 as logical          no-undo.
define output parameter p-fr-mode            as integer      no-undo.
define output parameter p-fr-time            as integer      no-undo.
define output parameter p-fr-date            as date         no-undo.
define output parameter p-fr-last-shift-date as date         no-undo.
define output parameter p-fr-last-shift-num  as integer      no-undo.
define output parameter p-fr-lic             as character    no-undo.
define output parameter p-fr-shift-open      as integer      no-undo. /* 0 - close, 1 - open, 24 - open more then 24h */
define output parameter p-fr-serial          as char      no-undo.

define variable         v-return             as integer   no-undo .
define variable         v-datefirstdoc       as character no-undo .
define variable         v-timefirstdoc       as character no-undo .
define variable         v-dateKKm            as character no-undo .
define variable         v-timeKKM            as character no-undo .
define variable         v-serialNum          as character no-undo .
define variable         v-responce           as memptr    no-undo .
define variable         v-creturn            as char no-undo .
define variable         v-cLastShiftNum      as char no-undo .
define variable         v-status-const       as character no-undo .
define variable         v-status-current     as character no-undo .


case v-fr-type:
 /*   PRIM08TK  ПРИМ08ТК   */
 when {&prim08tkm} then
 do:
    do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
      run Fr-GetStatusCurrent(output v-status-const ,
                              output v-status-current ,
                              output v-return )
                            .
                            /*
      message "v-status-const = "  v-status-const skip
              "v-status-curr  = "  v-status-current skip
              program-name(2)
              view-as alert-box title "Сообщение" .
                              */
      if substr(v-status-const,12,1) = '1' then
      do:
         message "Чековая лента близка к концу"
            view-as alert-box title "Сообщение".
      end.

      if substr(v-status-const,11,1) = '1' then
      do:
         message "Печать остановлена из-за конца бумаги"
            view-as alert-box title "Сообщение".
      end.

      if substr(v-status-const,10,1) = '1' then
      do:
         message "Открыта крышка принтера"
            view-as alert-box title "Сообщение".
      end.


      if substr(v-status-current,9,1) = '0' then
      do:
         RUN StartSeans(OUTPUT v-Return) .

      end.

      run Fr-ReadCMOS(input 0 , /* смещение в CMOS */
                    input 7 ,
                    output v-cLastShiftNum ,
                    output v-return) .

      run Fr-ReadCMOS(input 7 , /* смещение в CMOS */
                    input 6 ,
                    output v-datefirstdoc ,
                    output v-return) .

      run Fr-ReadCMOS(input 13 , /* смещение в CMOS */
                    input 4 ,
                    output v-timefirstdoc ,
                    output v-return) .


      if v-return = 0 then
      do:
        assign
          p-fr-last-shift-num = int(v-cLastShiftNum)
          p-fr-last-shift-date = today - 1
          .
        run Fr-GetDate(output v-return,
                     output v-dateKKM,
                     output v-timeKKM) .
        if v-return = 0 then
        do:
          run Fr-GetSerialNUM(output v-return, output v-serialNum) .
          if v-return = 0 then
          do:
            assign
              p-ok = yes
              p-fr-mode = 0
              p-fr-serial = v-serialNum
              p-fr-time  = int(substr(v-timeKKM,1,2)) * 3600 + int(substr(v-timeKKM,3,2)) * 60
             .

            if v-timefirstdoc = "0000" then
            do:
              p-fr-shift-open = 0 .
            end .
            else
            do:
                assign
                  .
            end.
            run fr-prim08ECRstatus(output p-fr-mode,output p-err-message) .
          end.
        end .

      end.


      if substr(v-status-current,12,1) = '1' then     /* требуется закрытие смены */
      do:
           assign
             p-fr-shift-open = 24
             p-ok = no
              .
           return .
      end.

      if substr(v-status-current,5,1) = '0' then     /*  сменa закрыта */
      do:
           assign
             p-fr-shift-open = 0
             .
      end.
      else
      do:
           assign
             p-fr-shift-open = 1
             .

      end.

      if v-return <> 0 then
      do:
        assign p-ok = no .
        run GetLastDllError(output v-return) .

        set-size(v-Responce) = 120 .
        run GetErrorMessage(output v-Responce ,output v-creturn) .
        p-err-message = get-string(v-Responce,1) .
        set-size(v-Responce) = 0 .
        p-err-message = string(v-return) + ' - ' + p-err-message .


      end.

    end.
 end.
 /*   shtrih  ШТРИХ     */
 when {&shtrikh-m} then
 do:
  IF VALID-HANDLE(v-fr)
  THEN DO
  ON ERROR UNDO, RETURN ERROR
   :
         v-fr:GetECRStatus() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3 &4"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         , v-fr:ResultCode
                                         )
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-fr-mode            = v-fr:ECRMode  /* Режим */
            p-fr-time            = (INT(ENTRY(1, v-fr:TimeStr, ":":U)) * 3600) + (INT(ENTRY(2, v-fr:TimeStr, ":":U)) * 60) + INT(ENTRY(3, v-fr:TimeStr, ":":U))
            p-fr-date            = v-fr:date
            p-fr-last-shift-date = v-fr:LastSessionDate    /* ДатаПоследнейСмены */
            p-fr-last-shift-num  = v-fr:LastSessionNumber  /* НомерПоследнейСмены */
            /*
            v-fr-lic             = v-fr:License            /*  Лицензия. */
            */
            p-fr-serial          = v-fr:SerialNumber  /* № ФР */
            p-fr-shift-open      = IF v-fr:IsFMSessionOpen THEN 1 ELSE 0 /* Смена */
         .


         /***************************************************************
          **   критические параметры
          **
          ***************************************************************/

         /* Крышка корпуса открыта !!!!
         IF v-fr:LidPositionSensor
         THEN DO:
            ASSIGN
               p-err-message = "Крышка корпуса открыта"
            .
            RETURN.
         END.
         */

         /* Денежный ящик открыт? */
         IF v-fr:IsDrawerOpen
         AND NOT p-dr-open
         THEN DO:
            ASSIGN
               p-err-message = "Закройте денежный ящик."
            .
            RETURN.
         END.

         /*  Лицензии нет */
         IF NOT v-fr:LicenseIsPresent
         THEN DO:
            ASSIGN
               p-err-message = "Нет лицензии"
            .
            RETURN.
         END.

         /* Истекли 24 часа */
         IF v-fr:IsFM24HoursOver
         THEN DO:
            ASSIGN
               p-fr-shift-open = 24
               p-err-message   = "Истекли 24 часа открытой смены"
            .
            RETURN.
         END.
/*
         /* Переполнение ЭКЛЗ .  Это просто предупреждение */
         IF v-fr:IsEKLZOverflow
         THEN DO:
            ASSIGN
               p-err-message = "Переполнение ЭКЛЗ"
            .
            RETURN.
         END.
*/
         /* Последняя запись ВФПИ спорчена */
         IF v-fr:IsLastFMRecordCorrupted
         THEN DO:
            ASSIGN
               p-err-message = "Последняя запись ВФПИ спорчена"
            .
            RETURN.
         END.

   END. /* on error */
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
 end.  /* &shtrikh-m  */

 OTHERWISE DO:
 END.

END CASE.
END PROCEDURE. /* fr-ctrl */


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-add-sale Include
PROCEDURE fr-add-sale :
/*------------------------------------------------------------------------------
  Purpose: Добавление линии чека продажи
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-barcode       AS character   NO-UNDO .
define input parameter p-name          AS character   NO-UNDO .
define input parameter p-price         AS DECIMAL     NO-UNDO .
define input parameter p-qnty          AS DECIMAL     NO-UNDO .
define input parameter p-unit-base     AS character   NO-UNDO .
define input parameter p-d-card        AS character   NO-UNDO .
define input parameter p-discount      AS DECIMAL     NO-UNDO .
define output parameter p-err-message  as character   no-undo .
define output parameter p-ok           as logical     no-undo .

define variable v-statusConst   as char no-undo .
define variable v-statusCurrent as char no-undo .
define variable v-return        as int  no-undo .
define variable v-chek-num      as int  no-undo .
define variable v-prim-price    as int  no-undo .
define variable v-prim-qty    as int  no-undo .
define variable v-prim-dsc    as int  no-undo .
define variable v-OType       as int  no-undo .
define variable v-itogo       as char no-undo .
define variable v-itogo-str   as char no-undo .
define variable v-disc-str    as char no-undo .
define variable v-Free-Field as character no-undo .

if v-fr-type = {&prim08tkm} then
do:
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :
     run Fr-GetStatusCurrent(output v-StatusConst ,
                           output v-StatusCurrent ,
                           output v-return )
                           .
     if substr(v-StatusCurrent,14,3) = '000' then   /* Документ закрыт  */
     do:
       assign
         v-Free-Field = "" .
       if p-d-card <> "" then
       do:
          assign
             v-Free-Field = "  Диск.карта  N " + p-d-card .
       end.
       run Fr-StartReceiptPlus (input  0 ,
                                input  v-Free-Field ,
                              output v-chek-num,
                              output v-return
                                      ) .
       run Fr-FirstDoc.

     end.
     assign v-prim-price = p-price * 100
            v-prim-qty   = p-qnty  * 1000
            v-prim-dsc   = p-discount * 100 .

     run Fr-ItemReceiptPlus( input p-name ,
                           input p-barcode ,
                           input substr(p-unit-base,1,3) ,
                           input "" ,
                           input fill('-',40) ,
                           input v-prim-price ,
                           input v-prim-qty ,
                           input 1 ,
                           input v-prim-dsc ,
                          output v-Return ,
                          output v-Itogo ,
                          output v-Itogo-str ,
                          output v-Disc-str
                           ) .
     if v-return = 0 then
     do:
       assign
         p-ok = yes
         p-err-message = "" .
     end.
     else
     do:
       assign p-ok = no .
       run Fr-ErrorMessage(output p-err-message) .
     end.

   end.
   return .
end.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:

   CASE v-fr-type:
      WHEN {&shtrikh-m} THEN DO:
         IF p-qnty > 0
         THEN DO:
            ASSIGN
               v-fr:Password          = 1
               v-fr:Quantity          = p-qnty
               v-fr:Price             = p-price
               v-fr:Department        = 0
               v-fr:StringForPrinting = p-name
            .
            v-fr:Sale() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3 &4"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          , v-fr:ECRMode
                                          )
                  p-ok = FALSE
               .
               RETURN.
            END.
         END.
         ELSE DO:
            IF p-qnty < 0
            THEN DO:
               ASSIGN
                  v-fr:Password          = 1
                  v-fr:Quantity          = p-qnty
                  v-fr:Price             = p-price
                  v-fr:Department        = 0
                  v-fr:StringForPrinting = p-name
               .
               v-fr:Storno() NO-ERROR.
               IF ERROR-STATUS:ERROR
               OR v-fr:ResultCode <> 0
               THEN DO:
                  ASSIGN
                     p-err-message = SUBSTITUTE( "&1 &2 &3 &4"
                                             , RETURN-VALUE
                                             , ERROR-STATUS:GET-MESSAGE(1)
                                             , v-fr:ResultCodeDescription
                                             , v-fr:ECRMode
                                             )
                     p-ok = FALSE
                  .
                  RETURN.
               END.
            END.
            ELSE DO:
               /* !!! p-qnty = 0 */
            END.
         END.

         /* Скидка */
         IF p-discount < 0 THEN
         DO:
            ASSIGN
               v-fr:Summ1 = - p-discount
               v-fr:StringForPrinting = "":U
            .
            v-fr:Discount() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3 &4"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          , v-fr:ECRMode
                                          )
               .
               RETURN.
            END.
         END.
         ELSE IF p-discount > 0 THEN
         DO:
            ASSIGN
               v-fr:Summ1 = p-discount
               v-fr:StringForPrinting = "":U
            .
            v-fr:Charge() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3 &4"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          , v-fr:ECRMode
                                          )
               .
               RETURN.
            END.

         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-add-sale */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-add-ret Include
PROCEDURE fr-add-ret :
/*------------------------------------------------------------------------------
  Purpose: Добавление линии чека возврата
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-barcode       AS character   NO-UNDO .
define input parameter p-name          AS character   NO-UNDO .
define input parameter p-price         AS DECIMAL     NO-UNDO .
define input parameter p-qnty          AS DECIMAL     NO-UNDO .
define input parameter p-unit-base     AS character   NO-UNDO .
define input parameter p-d-card        AS character   NO-UNDO .
define input parameter p-discount      AS DECIMAL     NO-UNDO .
define output parameter p-err-message  as character   no-undo .
define output parameter p-ok           as logical     no-undo .


define variable v-statusConst   as char no-undo .
define variable v-statusCurrent as char no-undo .
define variable v-return        as int  no-undo .
define variable v-chek-num      as int  no-undo .
define variable v-prim-price    as int  no-undo .
define variable v-prim-qty    as int  no-undo .
define variable v-prim-dsc    as int  no-undo .
define variable v-OType       as int  no-undo .
define variable v-itogo       as char no-undo .
define variable v-itogo-str   as char no-undo .
define variable v-disc-str    as char no-undo .
define variable v-Free-Field  as character no-undo .

if v-fr-type = {&prim08tkm} then
do:
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :
     run Fr-GetStatusCurrent(output v-StatusConst ,
                           output v-StatusCurrent ,
                           output v-return )
                           .
     if substr(v-StatusCurrent,14,3) = '000' then   /* Документ закрыт  */
     do:
       assign
         v-Free-Field = "" .
       if p-d-card <> "" then
       do:
          assign
             v-Free-Field = " Диск.карта  N " + p-d-card .
       end.
       run Fr-StartReceiptPlus (input  2 ,           /* Возврат   */
                                input v-Free-Field,
                              output v-chek-num,
                              output v-return ) .
       run Fr-FirstDoc.
     end.


     assign v-prim-price = p-price * 100
            v-prim-qty   = p-qnty  * 1000
            v-prim-dsc   = p-discount * 100 .

     run Fr-ItemReceiptPlus( input p-name ,
                           input p-barcode ,
                           input substr(p-unit-base,1,3) ,
                           input "" ,
                           input "ВОЗВРАТ ТОВАРА" ,
                           input v-prim-price ,
                           input v-prim-qty ,
                           input 1 ,
                           input v-prim-dsc ,
                          output v-Return ,
                          output v-Itogo ,
                          output v-Itogo-str ,
                          output v-Disc-str
                           ) .
     if v-return = 0 then
     do:
       assign
         p-ok = yes
         p-err-message = "" .
     end.
     else
     do:
       assign p-ok = no .
       run Fr-ErrorMessage(output p-err-message) .
     end.

   end.
   return .
end.

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:

   CASE v-fr-type:
      WHEN {&shtrikh-m} THEN DO:
         IF p-qnty > 0
         THEN DO:
            v-fr:Password = 1.
            v-fr:Quantity          = p-qnty.
            v-fr:Price             = p-price.
            v-fr:Department        = 0.
            v-fr:StringForPrinting = p-name.
            v-fr:ReturnSale() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          )
                  p-ok = FALSE
               .
               RETURN.
            END.
         END.
         ELSE DO:
            IF p-qnty < 0
            THEN DO:
               v-fr:Password = 1.
               v-fr:Quantity          = p-qnty.
               v-fr:Price             = p-price.
               v-fr:Department        = 0.
               v-fr:StringForPrinting = p-name.
               v-fr:Storno() NO-ERROR.
               IF ERROR-STATUS:ERROR
               OR v-fr:ResultCode <> 0
               THEN DO:
                  ASSIGN
                     p-err-message = SUBSTITUTE( "&1 &2 &3"
                                             , RETURN-VALUE
                                             , ERROR-STATUS:GET-MESSAGE(1)
                                             , v-fr:ResultCodeDescription
                                             )
                     p-ok = FALSE
                  .
                  RETURN.
               END.
            END.
            ELSE DO:
               /* !!! p-qnty = 0 */
            END.
         END.
         /*
         v-fr:Password = 1.
         v-fr:Quantity          = p-qnty.
         v-fr:Price             = p-price.
         v-fr:Department        = 0.
         v-fr:StringForPrinting = p-name.
         v-fr:ReturnSale() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
            .
            RETURN.
         END.
         */

         /* Скидка */
         IF p-discount < 0 THEN
         DO:
            v-fr:Summ1 = 0.00 - p-discount.
            v-fr:StringForPrinting = "":U.
            v-fr:Discount() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          )
               .
               RETURN.
            END.

         END.
         ELSE IF p-discount > 0 THEN
         DO:
            v-fr:Summ1 = 0.00 - p-discount.
            v-fr:StringForPrinting = "":U.
            v-fr:Charge() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          )
               .
               RETURN.
            END.

         END.
         /*
         v-fr:Quantity          = p-qnty.
         v-fr:Price             = p-price.
         v-fr:Department        = 0.
         v-fr:StringForPrinting = p-barcode + " ":U + p-name.
         v-fr:ReturnSale().
          Скидка
         IF p-discount < 0 THEN
         DO:
            v-fr:Summ1 = 0.00 - p-discount.
            v-fr:StringForPrinting = "":U.
            v-fr:Discount().
         END.
         ELSE IF p-discount > 0 THEN
         DO:
            v-fr:Summ1 = 0.00 - p-discount.
            v-fr:StringForPrinting = "":U.
            v-fr:Charge().
         END.
         */
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-add-ret */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-add-annul Include
PROCEDURE fr-add-annul :
/*------------------------------------------------------------------------------
  Purpose: Добавление линии коррекции
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-barcode       AS character   NO-UNDO .
define input parameter p-name          AS character   NO-UNDO .
define input parameter p-price         AS DECIMAL     NO-UNDO .
define input parameter p-qnty          AS DECIMAL     NO-UNDO .
define input parameter p-discount      AS DECIMAL     NO-UNDO .
define output parameter p-err-message  as character   no-undo .
define output parameter p-ok           as logical     no-undo .

if v-fr-type = {&prim08tkm} then
do:
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :

   end.
   return .
end.

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:

   CASE v-fr-type:
      WHEN {&shtrikh-m} THEN DO:
         v-fr:Quantity          = p-qnty.
         v-fr:Price             = p-price.
         v-fr:Department        = 0.
         v-fr:StringForPrinting = p-barcode + " ":U + p-name.
         v-fr:Storno().
         /* Скидка */
         IF p-discount < 0 THEN
         DO:
            v-fr:Summ1 = 0.00 - p-discount.
            v-fr:StringForPrinting = "":U.
            v-fr:StornoDiscount().
         END.
         ELSE IF p-discount > 0 THEN
         DO:
            v-fr:Summ1 = 0.00 - p-discount.
            v-fr:StringForPrinting = "":U.
            v-fr:StornoCharge().
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-add-annul */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-close Include
PROCEDURE fr-close :
/*------------------------------------------------------------------------------
  Purpose: Отключение драйвера ККМ
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

def var v-return as int no-undo .

if v-fr-type = {&prim08tkm} then
do:
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :
     run CloseDll(output v-return) .
     if v-return = 0 then
     do:

       assign
         p-ok = yes
         p-err-message = "" .
     end.
     else
     do:
        assign p-ok = no .
        run Fr-ErrorMessage (output p-err-message) .
     end.

   end.
   return .

end .


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:Disconnect NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE("&1 &2", RETURN-VALUE, ERROR-STATUS:GET-MESSAGE(1))
            .
            RETURN.
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.

   RELEASE OBJECT v-fr NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         p-err-message = SUBSTITUTE("&1 &2", RETURN-VALUE, ERROR-STATUS:GET-MESSAGE(1))
      .
      RETURN.
   END.

   assign
      v-fr      = ?
      p-ok    = TRUE
   .
END.  /* do on error */
END PROCEDURE.  /* fr-close */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-usrad Include
PROCEDURE fr-usrad :
/* Добавление нового оператора */
/*------------------------------------------------------------------------------
  Purpose: Отключение драйвера ККМ
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT  PARAMETER Idn            AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER Name           AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER id             AS INTEGER     NO-UNDO.
DEFINE OUTPUT PARAMETER p-err-message  AS CHARACTER   NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok           AS LOGICAL     NO-UNDO.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   NAME = TRIM(NAME).
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:Password = 30.   /* администратор */
         v-fr:TableNumber = 2. /* талица паролей */
         v-fr:RowNumber = 1.
         v-fr:FieldNumber = 2.
         v-fr:ValueOfFieldString = NAME.
         v-fr:GetFieldStruct().
            /* !!! зачем ??? */
            v-fr:Password = 1.
            v-fr:Password = 30.
         v-fr:WriteTable(). /*!!!*/
         v-fr:Password = 1.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-usrad */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME








&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-chkcl Include
PROCEDURE fr-chkcl :
/*------------------------------------------------------------------------------
  Purpose: Закрыть чек
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-summ-1        AS DEC         NO-UNDO .
define input parameter p-summ-2        AS DEC         NO-UNDO .
define input parameter p-summ-3        AS DEC         NO-UNDO .
define input parameter p-summ-4        AS DEC         NO-UNDO .
define input parameter p-card          AS CHAR        NO-UNDO .
define output parameter p-chk-num      as integer     no-undo .
define output parameter p-rest-summ    as decimal     no-undo .
define output parameter p-err-message  as character   no-undo .
define output parameter p-ok           as logical     no-undo .

if v-fr-type = {&prim08tkm} then
do:
  def var v-return as int no-undo .
  define variable v-ItogoSum  as character no-undo .
  define variable v-SurChargeSum as character no-undo .
  define variable v-ChangeSum as character no-undo .
  define variable v-summ-1    as integer  extent 4 no-undo .
  define variable v-num-doc as integer   no-undo .
  define variable v-CashMony as decimal   no-undo .
  define variable v-CashMonyStr as char   no-undo .
  define variable v-i as integer   no-undo .


   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :
     run Fr-TotalReceiptPlus( input "",output v-ItogoSum,output v-return) .
      v-summ-1[1] = abs( p-summ-1) * 100 .
      v-summ-1[2] = abs( p-summ-2) * 100 .
      v-summ-1[3] = abs( p-summ-3) * 100 .
      v-summ-1[4] = abs( p-summ-4) * 100 .
     do v-i = 1 to 4 :
       if v-summ-1[v-i] > 0 then
       do:
         run TenderReceiptPlus(input v-i - 1 ,
                  input v-summ-1[v-i],
                  input '' ,
                  input '' ,
                  output v-return ) .
         if v-return = 0 then
         do :
           run Fr-Answer(1,14,output v-ChangeSum) .

           run Fr-Answer(2,14,output v-SurChargeSum) .

           if deci(v-SurChargeSum) > 0 then
           do:
             p-rest-summ = - deci(v-SurChargeSum) .
           end.
           else
           do:
             p-rest-summ = deci(v-changeSum) .
           end.
         end .
         else
         do :

           run Fr-error-message(output p-err-message) .
           assign p-ok = no .
           undo , return .
         end .

       end.
     end.

     run CloseReceipt(output v-return ) .

     if v-return = 0 then
     do:
       run Fr-GetNumbers(output p-chk-num,
                         output v-num-doc,
                         output v-return  )
                         .
       p-chk-num = p-chk-num + 1 .

       run Fr-GetMony( 1 , 14 , output v-CashMony) .

       v-CashMonyStr = string(v-cashMony,">>>>>>>>>>9.99") .

       run Fr-WriteCMOS(input 17 , /* смещение в CMOS */
                        input v-CashMonyStr ,
                        output v-return).

       assign
          p-ok = yes
          p-err-message = ""
        .
     end .
     else
     do:
       assign
        p-ok = no .
       run Fr-ErrorMessage(output p-err-message) .
     end.


   end.

   return .
end .

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:Password = 1.
         v-fr:GetECRStatus() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
               p-ok  = FALSE
            .
         END.
         /*
         ASSIGN
            v-fr:Password = 1
            v-fr:Summ1 = ABS(p-summ-1)
            v-fr:Summ2 = ABS(p-summ-2)
            v-fr:Summ3 = ABS(p-summ-3)
            v-fr:Summ4 = ABS(p-summ-4)
         .
         v-fr:DiscountOnCheck = 100 * p-disk-summ / (p-summ + p-disk-summ).
         IF p-card > "":U THEN
         DO:
            v-fr:StringForPrinting =   "№ к: ":U + p-card.
            v-fr:PrintString().   ????
         END.
         */

         v-fr:CheckSubTotal() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3 &4"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       , v-fr:ECRMode
                                       )
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            v-fr:Password = 1
            v-fr:StringForPrinting = "------------------------------------"
            v-fr:Summ1 = ABS(p-summ-1)
            v-fr:Summ2 = ABS(p-summ-2)
            v-fr:Summ3 = ABS(p-summ-3)
            v-fr:Summ4 = ABS(p-summ-4)
         .
         v-fr:CloseCheck() NO-ERROR.

         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
               p-ok = FALSE
            .
            RETURN.
         END.
         DO WHILE INT(v-fr:ECRMode) = 8 /* открыт документ */:
            pause 1.
            v-fr:GetECRStatus() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
                  p-ok  = FALSE
               .
            END.
         END.

         ASSIGN
            p-chk-num   = INT(v-fr:OpenDocumentNumber)
            p-rest-summ = v-fr:Change
         .

      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-chkcl */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/*==========================================================================*/
procedure fr-chk-annul :
define output parameter p-chk-num  as integer          no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

def var v-return         as int no-undo .
def var v-StatusConst    as char no-undo .
def var v-StatusCurrent  as char no-undo .

if v-fr-type = {&prim08tkm} then
do:
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
   run Fr-GetStatusCurrent(output v-StatusConst ,
                           output v-StatusCurrent ,
                           output v-return )
                           .
   if substr(v-StatusCurrent,14,3) = '000' then   /* Документ закрыт  */
   do:
     return .
   end.
   run CancelReceipt(output v-return) .
   if v-return = 0 then
   do:
     assign
         p-ok = yes
         p-err-message  = "".
   end.
   else
   do:
     assign
         p-ok = no .
     run Fr-ErrorMessage(output p-err-message) .
   end.


  end.
  return .
end .

do
on error undo, return error
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         /*
         ASSIGN
            v-fr:Password     = 1
         .
         v-fr:CheckType = 0.
         v-fr:OpenCheck() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
            .
            RETURN.
         END.
         */

         ASSIGN
            v-fr:Password     = 1
         .
         v-fr:CancelCheck() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
            .
            RETURN.
         END.

         DO WHILE INT(v-fr:ECRMode) = 8 /* открыт документ */:
            v-fr:GetECRStatus() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
                  p-ok  = FALSE
               .
            END.
         END.

         p-chk-num = INT(v-fr:OpenDocumentNumber).
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
end. /* do on error */
end procedure. /* fr-chk-annul */




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-draop Include
PROCEDURE fr-draop :
/*------------------------------------------------------------------------------
  Purpose: Открыть денежный ящик
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo .
define output parameter p-ok          as logical          no-undo .
define variable         v-return      as integer   no-undo .
if v-fr-type = {&prim08tkm} then
do :
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :
     run CashDriverOpen(output v-return ) .
     if v-return = 0 then
     do:
        assign p-ok = yes
               p-err-message = ""
               .
     end.
     else
     do:
       assign p-ok = no .
       run Fr-ErrorMessage(output p-err-message) .

     end .
   end .
   return .
end .
IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   /*
   IF NOT v-cash-drawer-plug
   THEN DO:
      ASSIGN
         p-ok = TRUE
      .
   END.
   */

   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:

         ASSIGN
            v-fr:Password     = 1
            v-fr:DrawerNumber = 0
         .
         v-fr:OpenDrawer NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
            .
            RETURN.
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
   .
END.  /* do on error */
END PROCEDURE. /* fr-draop */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-shtop Include
PROCEDURE fr-shtop :
/*------------------------------------------------------------------------------
  Purpose: Открыть смену
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
   define variable v-param1 as character no-undo .
   define variable v-param2 as character no-undo .
   define variable v-return as integer   no-undo .

if v-fr-type = {&prim08tkm} then
do:
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :
     run Fr-GetParamDoc(output v-return,
                        output v-param1,
                        output v-param2)
                        .
     if substr(v-param1,7,2) = '10' then       /* '10' для открытия смены необх.команда открытие смены, '01' фискальный док.открывает смену */
     do:
        run ShiftOpen(input "",output v-return) .
        if v-return = 0 then
        do:
           assign
              p-ok = yes
              p-err-message = "" .
        end.
        else
        do:
          assign
              p-ok = no .
          run Fr-ErrorMessage(output p-err-message) .

        end.
     end.
     else
     do:

     end.
   end.
   return .
end.

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         /* !!!
         ASSIGN
            v-fr:Password     = 1
            v-fr:DrawerNumber = 0
            v-fr:MethodName   = "OpenSession"
         .
         IF v-fr:MethodSupported()
         THEN DO:
            v-fr:OpenSession NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          )
               .
               RETURN.
            END.
         END.
         */
         ASSIGN
            v-fr:Password     = 1
            v-fr:CheckType    = 0
         .
         v-fr:OpenCheck() NO-ERROR. /*!!!*/
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
            .
            RETURN.
         END.
         ASSIGN
            v-fr:Password     = 1
         .
         v-fr:CancelCheck() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
            .
            RETURN.
         END.

      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-shtop */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-shtcl Include
PROCEDURE fr-shtcl :
/*------------------------------------------------------------------------------
  Purpose: Закрыть смену Z-отчет
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  def var v-return as int no-undo .
  define variable v-cLastShiftNum      as char      no-undo .
  define variable v-CashMony           as decimal   no-undo .
  define variable v-CashMonyStr        as character no-undo .
  define variable v-datefirstdoc       as character no-undo .
  define variable v-timefirstdoc       as character no-undo .
  define variable v-LastShiftNum       as int      no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
     /* Итого продаж   */
    run Fr-GetMony( 9 , 14 , output v-CashMony) .

    v-CashMonyStr = string(v-cashMony,">>>>>>>>>>9.99") .

    run Fr-WriteCMOS(input 31 , /* смещение в CMOS ИТОГО ПРОДАЖ*/
                     input v-CashMonyStr ,
                     output v-return).
     /*    Пластик.карты                  */
    run Fr-GetMony( 11 , 14 , output v-CashMony) .

    v-CashMonyStr = string(v-cashMony,">>>>>>>>>>9.99") .

    run Fr-WriteCMOS(input 45 , /* смещение в CMOS Пласт.карты */
                     input v-CashMonyStr ,
                     output v-return).

    /* 2-й вид оплат    */

    run Fr-GetMony( 13 , 14 , output v-CashMony) .

    v-CashMonyStr = string(v-cashMony,">>>>>>>>>>9.99") .

    run Fr-WriteCMOS(input 59 , /* смещение в CMOS 2-й вид оплат */
                     input v-CashMonyStr ,
                     output v-return).
   /*   Возврат нал  */

    run Fr-GetMony( 17 , 12 , output v-CashMony) .

    v-CashMonyStr = string(v-cashMony,">>>>>>>>9.99") .

    run Fr-WriteCMOS(input 73 , /* смещение в CMOS возврат */
                     input v-CashMonyStr ,
                     output v-return).
    /*  Наличные  */


    run Fr-GetMony( 19 , 14 , output v-CashMony) .

    v-CashMonyStr = string(v-cashMony,">>>>>>>>>>9.99") .

    run Fr-WriteCMOS(input 85 , /* смещение в CMOS возврат */
                     input v-CashMonyStr ,
                     output v-return).

    run Fr-ReadCMOS(input 0 , /* смещение в CMOS */
                    input 7 ,
                    output v-cLastShiftNum ,
                    output v-return) .

    run EKLEJournalReport( input int(v-cLastShiftNum) + 1 , output v-return) .


    run ShiftClose( output v-return).

    if v-return = 0 then
    do:
          run Fr-GetResource(output v-return ,
                             output v-lastshiftnum ,
                             output v-datefirstdoc ,
                             output v-timefirstdoc) .

          if v-return = 0 then
          do :
            assign p-ok = yes
                   p-err-message = ""
                   .

            v-cLastShiftNUm = string(v-lastShiftNum,'9999999') .
            run Fr-WriteCMOS(input 0 , /* смещение в CMOS */
                             input v-cLastShiftNum ,
                             output v-return).
            run Fr-WriteCMOS(input 7 , /* смещение в CMOS */
                             input v-datefirstdoc ,
                             output v-return).
            run Fr-WriteCMOS(input 13 , /* смещение в CMOS */
                             input v-timefirstdoc ,
                             output v-return).

          end .
      assign
        p-ok = yes
        p-err-message = '' .
    end.
    else
    do:
      assign
        p-ok = no .
      run Fr-ErrorMessage(output p-err-message) .
    end .

  end.
  return .
end .

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:GetECRStatus() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
            .
            RETURN.
         END.

         IF v-fr:ECRMode = 8
         /* открыт документ */
         THEN
         _ann-doc:
         DO:
            x_v-fr-check_re_bl:
            DO WHILE YES:
               v-fr:GetECRStatus(). /* Получить состояние ФР */
               DO WHILE v-fr:ResultCode <> 0:
                     IF v-fr:ResultCode = -1
                     THEN DO:
                        /*
                        ASSIGN
                           p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
                           p-ok          = TRUE
                        .
                        */
                     END.
                     v-fr:GetECRStatus().
               END.

               CASE INTEGER(v-fr:ECRAdvancedMode):
                  WHEN 0 THEN DO:  /* ФР готов */
                     LEAVE x_v-fr-check_re_bl.
                  END.
                  WHEN 3 OR  /* ФР в фазе печати */
                  WHEN 5     /* ФР в фазе печати длинного отчета */
                  THEN DO:
                     v-fr:ContinuePrint().
                  END.
                  OTHERWISE DO:  /* ФР не готов, требуется вмешательство оператора */
                     ASSIGN
                        p-err-message = v-fr:ECRAdvancedModeDescription
                        p-ok          = TRUE
                     .
                  END.
               END CASE.
               /*
               IF v-fr:ECRAdvancedMode = 0
               THEN LEAVE x_v-fr-check_re_bl.
               ELSE IF v-fr:ECRAdvancedMode = 3
                  THEN v-fr:ContinuePrint().
                  ELSE IF v-fr:ECRAdvancedMode = 2
                        THEN DO:
                           v-fr:Beep() NO-ERROR.
                           message
                              v-fr:ECRAdvancedModeDescription
                              skip
                           view-as alert-box information.
                        END.
                        ELSE IF v-fr:ECRAdvancedMode = 1
                              THEN DO:
                                 v-fr:Beep() NO-ERROR.
                                 message
                                    v-fr:ECRAdvancedModeDescription
                                    skip
                                 view-as alert-box information.
                              END.
               */
            END. /* DO WHILE YES */
            v-fr:Password = 30.
            v-fr:SysAdminCancelCheck().
            v-fr:Password = 1.

            IF v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
               .
               LEAVE _ann-doc. /*RETURN ERROR v-fr:ResultCodeDescription.*/
            END.
         END. /* открыт документ */
         v-fr:GetECRStatus() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "-2 &1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
            .
            RETURN.
         END.
         DO WHILE (v-fr:ResultCode <> 0 OR v-fr:ECRAdvancedMode <> 0):
            v-fr:GetECRStatus().
         END.
         IF v-fr:ECRMode = 2
         OR v-fr:ECRMode = 3
         THEN DO:
            v-fr:Password = 30.
            v-fr:PrintReportWithCleaning() NO-ERROR.
            IF ERROR-STATUS:ERROR
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          )
               .
               RETURN.
            END.
            IF v-fr:ResultCode <> 0
            THEN
            DO WHILE (v-fr:ResultCode <> 0 OR v-fr:ECRAdvancedMode <> 0):
               v-fr:GetECRStatus().
            END.
         END.

      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-shtcl */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-ShowProperties Include
PROCEDURE fr-ShowProperties :
/*------------------------------------------------------------------------------
  Purpose: Показать настройки кассы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:Password = 30.
         v-fr:ShowProperties.

      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-ShowProperties */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-discount Include
PROCEDURE fr-discount :
/*------------------------------------------------------------------------------
  Purpose: Скидка
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-discount    as decimal          no-undo.
define input  parameter p-name        as character        no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

define variable v-OType    as int no-undo .
define variable v-discount as int no-undo .
define variable v-return   as int no-undo .
define variable v-itogo    as char no-undo .
define variable v-itogo-disc    as char no-undo .


if v-fr-type = {&prim08tkm} then
do:
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :
     if p-discount < 0 then /* наценка */
     do:
       assign
         v-discount = - p-discount * 100
         v-OType = 0 .
     end .
     else  /*    скидка  */
     do:
       assign
        v-discount =  p-discount * 100
        v-OType = 1 .
     end.
     run Fr-SubTotalReceiptPlus( input "", output v-itogo , output v-return ) .

     run Fr-ComissionReceiptPlus( input v-OType ,
                                input v-discount ,
                                input p-name ,
                                output v-itogo ,
                                output v-itogo-disc ,
                                output v-return )
                                .
     if v-return = 0 then
     do:
       assign p-ok = yes
            p-err-message = "".
     end .
     else
     do:
       assign p-ok = no .
       run Fr-ErrorMessage(output p-err-message ) .
     end.

   end.
   return .

end.

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         IF p-discount > 0
         THEN DO:
            v-fr:Password          = 1.
            v-fr:Summ1             = p-discount.
            v-fr:StringForPrinting = p-name.
            v-fr:Discount() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          )
               .
               RETURN.
            END.
         END.
         ELSE DO:
            IF p-discount < 0
            THEN DO:
               v-fr:Password          = 1.
               v-fr:Summ1             = ABS(p-discount).
               v-fr:StringForPrinting = p-name.
               v-fr:Charge() NO-ERROR.
               IF ERROR-STATUS:ERROR
               OR v-fr:ResultCode <> 0
               THEN DO:
                  ASSIGN
                     p-err-message = SUBSTITUTE( "&1 &2 &3"
                                             , RETURN-VALUE
                                             , ERROR-STATUS:GET-MESSAGE(1)
                                             , v-fr:ResultCodeDescription
                                             )
                  .
                  RETURN.
               END.
            END.
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-discount */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-subtotal Include
PROCEDURE fr-subtotal :
/*------------------------------------------------------------------------------
  Purpose: Подитог
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  define variable v-itogo as character no-undo .
  define variable v-return as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    run Fr-SubTotalReceiptPlus(input "", output v-itogo , output v-return ) .
    if v-return = 0 then
    do:
      assign
      p-ok = yes
      .
    end.
    else
    do:
      assign p-ok = no .
      run Fr-errorMessage(output p-err-message) .
    end.


  end.
  return .
end.

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:Password          = 1.
         v-fr:CheckSubTotal() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
            .
            RETURN.
         END.

         /*
         v-len = LENGTH(STRING(v-fr:Summ1)).
         v-st-print = FILL(" ", (31 - v-len)).
         define variable v-len         as integer      no-undo.
         define variable v-st-print    as character    no-undo.
         v-fr:Password          = 1.
         v-fr:StringForPrinting = SUBSTITUTE("Подитог:&1&2", v-st-print, v-fr:Summ1).
         */
         v-fr:Password          = 1.
         v-fr:StringForPrinting = FILL("-", 48).
         v-fr:PrintString() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
            .
            RETURN.
         END.
         v-fr:Password          = 1.
         v-fr:StringForPrinting = SUBSTITUTE("Подитог:&1&2", FILL(" ", (31 - LENGTH(STRING(v-fr:Summ1)))), v-fr:Summ1).
         v-fr:PrintString() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
            .
            RETURN.
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-subtotal */
/* _UIB-CODE-BLOCK-END */




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-subtotal Include
PROCEDURE fr-subtotal-without-print :
/*------------------------------------------------------------------------------
  Purpose: Подитог
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-summ-total  as decimal          no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  define variable v-itogo as character no-undo .
  define variable v-return as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    run Fr-SubTotalReceiptPlus(input "", output v-itogo , output v-return ) .
    if v-return = 0 then
    do:
      assign
        p-ok = yes
        p-summ-total = deci(v-itogo)
        .
    end.
    else
    do:
       assign p-ok = no .
       run Fr-errorMessage(output p-err-message) .
    end.

  end.
  return .
end.

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:Password          = 1.
         v-fr:CheckSubTotal() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
            .
            RETURN.
         END.
         ASSIGN
            p-summ-total = v-fr:Summ1
         .

      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-subtotal */
/* _UIB-CODE-BLOCK-END */




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-print-str Include
PROCEDURE fr-print-str :
/*------------------------------------------------------------------------------
  Purpose: Печать любой строки
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter  p-string as character        no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

define variable v-string as character no-undo .
define variable v-return as integer   no-undo .

if v-fr-type = {&prim08tkm} then
do:
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
     run OpenFDoc(output v-return) .

     if v-return = 0 then
     do:
       run PrintOEMDoc(input p-string ,
                           input length(p-string) ,
                           output v-return )
                           .
       run CloseFDoc(output v-return) .

     end .
  end .
  p-ok = yes .
  return .
end.

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:GetECRStatus(). /* Получить состояние ФР */
         DO WHILE (v-fr:ResultCode <> 0 OR v-fr:ECRAdvancedMode <> 0):
            v-fr:GetECRStatus().
         END.

         v-fr:Password = 1.
         v-fr:StringForPrinting = p-string.
         v-fr:PrintString() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3 &4"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       , v-fr:ResultCode
                                       )
            .
            RETURN.
         END.
         v-fr:GetECRStatus(). /* Получить состояние ФР */
         DO WHILE (v-fr:ResultCode <> 0 OR v-fr:ECRAdvancedMode <> 0):
            v-fr:GetECRStatus().
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-print-str */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME





&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-wide-print-str Include
PROCEDURE fr-wide-print-str :
/*------------------------------------------------------------------------------
  Purpose: Печать любой строки
  Parameters:  <none>
  Notes: !!! не поддерживается в данной версии
------------------------------------------------------------------------------*/
define input parameter  p-string as character        no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  define variable v-return as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
     run OpenFDoc(output v-return) .

     if v-return = 0 then
     do:
       run FontSelectFDoc(33,output v-return) .
       run PrintOEMDoc(input p-string ,
                           input length(p-string) ,
                           output v-return )
                           .
       run FontSelectFDoc(1,output v-return) .

       run CloseFDoc(output v-return) .

     end .

  end.
  assign p-ok = yes .
  return .
end.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:GetECRStatus(). /* Получить состояние ФР */
         DO WHILE v-fr:ResultCode <> 0:
            v-fr:GetECRStatus().
         END.

         v-fr:Password = 1.
         v-fr:StringForPrinting = p-string.
         v-fr:PrintWideString() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3 &4"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       , v-fr:ResultCode
                                       )
            .
            RETURN.
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-wide-print-str */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME





&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-get-reg Include
PROCEDURE fr-get-reg :
/*------------------------------------------------------------------------------
  Purpose: получить значение регистра
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-reg-type     as character        no-undo.
define input  parameter p-reg-num      as integer          no-undo.
define output parameter p-reg-value    as character        no-undo.
define output parameter p-reg-name     as character        no-undo.
define output parameter p-err-message  as character        no-undo.
define output parameter p-ok           as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  define variable v-CashMony as character no-undo .
  define variable v-return   as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    if p-reg-type = 'cash' then
    do:
     case p-reg-num:
      when 241 then
      do:
        run Fr-GetMony(1,14,
                      output v-CashMony) .

         assign
           p-ok = yes
           p-reg-value = v-CashMony
           p-reg-name  = "Наличность в кассе"
           .

                /*
        run Fr-ReadCMOS(input 17 ,
                    input 14 ,
                    output v-CashMony ,
                    output v-return).
        if v-return = 0 then
        do:
         assign
           p-ok = yes
           p-reg-value = v-CashMony
           p-reg-name  = "Наличность в кассе"
           .

        end .
                  */
      end .
      when 0 then
      do:
        run Fr-ReadCMOS(input 31 , /* смещение в CMOS */
                    input 14 ,
                    output v-CashMony ,
                    output v-return).
        if v-return = 0 then
        do:
         assign
           p-ok = yes
           p-reg-value = v-CashMony
           p-reg-name  = "Итого продаж"
           .

        end.

      end.
     when 80 then
      do:
        run Fr-ReadCMOS(input 45 , /* смещение в CMOS */
                    input 14 ,
                    output v-CashMony ,
                    output v-return)
                    .

        if v-return = 0 then
        do:
         assign
           p-ok = yes
           p-reg-value = v-CashMony
           p-reg-name  = "Итого пласт.карт"
           .

        end.

      end.
     when 76 then
      do:
        run Fr-ReadCMOS(input 59 , /* смещение в CMOS */
                    input 14 ,
                    output v-CashMony ,
                    output v-return).
        if v-return = 0 then
        do:
         assign
           p-ok = yes
           p-reg-value = v-CashMony
           p-reg-name  = "Итого "
           .

        end.

      end.
     when 2 then
      do:
        run Fr-ReadCMOS(input 73 , /* смещение в CMOS */
                    input 12 ,
                    output v-CashMony ,
                    output v-return).
        if v-return = 0 then
        do:
         assign
           p-ok = yes
           p-reg-value = v-CashMony
           p-reg-name  = "Итого возврат"
           .

        end.

      end.
     when 72 then
      do:
        run Fr-ReadCMOS(input 85 , /* смещение в CMOS */
                    input 14 ,
                    output v-CashMony ,
                    output v-return).
        if v-return = 0 then
        do:
         assign
           p-ok = yes
           p-reg-value = v-CashMony
           p-reg-name  = "Итого наличных"
           .

        end.

      end.
     OTHERWISE
      DO:
       assign
         p-ok = yes
         p-reg-value = '0'
         p-reg-name  = "прим08тк"
         .

      END.

     end case .

    end.
    else
    do :
       assign
         p-ok = yes
         p-reg-value = '0'
         p-reg-name  = "прим08тк"
         .

    end.
  end.

  return .
end.

IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         ASSIGN
            v-fr:Password = 1
            v-fr:RegisterNumber = p-reg-num
         .
         case p-reg-type:
            when "cash" THEN DO:
               v-fr:GetCashReg() NO-ERROR.
               IF ERROR-STATUS:ERROR
               OR v-fr:ResultCode <> 0
               THEN DO:
                  ASSIGN
                     p-err-message = SUBSTITUTE( "&1 &2 &3"
                                             , RETURN-VALUE
                                             , ERROR-STATUS:GET-MESSAGE(1)
                                             , v-fr:ResultCodeDescription
                                             )
                  .
                  RETURN.
               END.
               ASSIGN
                  p-reg-value = v-fr:ContentsOfCashRegister
                  p-reg-name  = v-fr:NameCashReg
               .
            END.
            WHEN "oper" THEN DO:
               v-fr:GetOperationReg() NO-ERROR.
               IF ERROR-STATUS:ERROR
               OR v-fr:ResultCode <> 0
               THEN DO:
                  ASSIGN
                     p-err-message = SUBSTITUTE( "&1 &2 &3"
                                             , RETURN-VALUE
                                             , ERROR-STATUS:GET-MESSAGE(1)
                                             , v-fr:ResultCodeDescription
                                             )
                  .
                  RETURN.
               END.
               ASSIGN
                  p-reg-value = v-fr:ContentsOfOperationRegister
                  p-reg-name  = v-fr:NameOperationReg
               .
            END.
            OTHERWISE DO:
            END.
         END CASE.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-get-reg */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME





&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-x-rep Include
PROCEDURE fr-x-rep :
/*------------------------------------------------------------------------------
  Purpose: X-отчет
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  def var v-return as int no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    run Xreport(output v-return).

    if v-return = 0 then
    do:
       assign
         p-ok = yes
         p-err-message = ""
         .
    end.
    else
    do:
       assign
         p-ok = no
         .
       run Fr-errorMessage(output p-err-message) .



    end .

  end.
  return .
end.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:GetECRStatus() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
               p-ok = FALSE
            .
            RETURN.
         END.
         IF v-fr:ECRMode = 2
         OR v-fr:ECRMode = 3
         OR v-fr:ECRMode = 4
         THEN DO:
            v-fr:Password = 30.
            v-fr:PrintReportWithoutCleaning() NO-ERROR.
            IF ERROR-STATUS:ERROR
            OR v-fr:ResultCode <> 0
            THEN DO:
               ASSIGN
                  p-err-message = SUBSTITUTE( "&1 &2 &3"
                                          , RETURN-VALUE
                                          , ERROR-STATUS:GET-MESSAGE(1)
                                          , v-fr:ResultCodeDescription
                                          )
                  p-ok = FALSE
               .
               RETURN.
            END.
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-x-rep */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-CashIncome Include
PROCEDURE fr-CashIncome :
/*------------------------------------------------------------------------------
  Purpose: Внесение денег
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-summ as decimal          no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

define variable v-SumTo  as integer   no-undo .
define variable v-return as integer   no-undo .

if v-fr-type = {&prim08tkm} then
do:
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
     v-sumTo = abs(p-summ) * 100 .

     run ToCash(input v-SumTo , output v-return ) .

     if v-return = 0 then
     do:
       assign
        p-ok = yes
        p-err-message = ""
        .

     end.
     else
     do:
       assign
         p-ok = no .
       run Fr-errorMessage(output p-err-message) .

     end.


  end.
  return .
end.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         v-fr:Password = 1.
         v-fr:Summ1 = ABSOLUTE(p-summ).
         v-fr:CashIncome() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
               p-ok = FALSE
            .
            RETURN.
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-CashIncome */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-CashOutcome Include
PROCEDURE fr-CashOutcome :
/*------------------------------------------------------------------------------
  Purpose: Инкассаци
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-summ as decimal          no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

define variable v-SumNal  as decimal   no-undo .
define variable v-SumFrom as integer   no-undo .
define variable v-return  as integer   no-undo .
define variable v-SumTo  as decimal   no-undo .

if v-fr-type = {&prim08tkm} then
do:
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
     run Fr-GetMony(input 1,input 14, output v-SumNal) .

                       /*
     run Fr-GetMony(input 2,input 14, output v-SumFrom) .

     run Fr-GetMony(input 3,input 14, output v-SumTo) .

     message "v-SumNal  = " v-SumNal  skip
             "v-SumFrom = " v-sumFrom skip
             "v-SumTo   = " v-SumTo   skip
             "p-Summ    = " p-Summ    skip
             "Инкассация "
        view-as alert-box .
                         */

     if p-summ > v-sumNal  then
     do:
       p-err-message = substitute("Вы хотите изъять денег &1 больше чем в кассе &2",p-summ,v-SumNal) .
       message p-err-message
       view-as alert-box title "Ошибка" .
       assign
       p-ok = no
       .
       return .
     end.
     v-sumfrom = abs(p-summ) * 100 .
     run FromCash(input v-Sumfrom , output v-return ) .

     if v-return = 0 then
     do:
       assign
        p-ok = yes
        p-err-message = ""
        .

     end.
     else
     do:
       assign
         p-ok = no .
       run Fr-errorMessage(output p-err-message) .

     end.

  end.

  return .
end.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
  CASE v-fr-type :
    WHEN {&shtrikh-m} THEN DO:
      v-fr:Password = 1.
      v-fr:Summ1 = ABSOLUTE(p-summ).
      v-fr:CashOutcome() NO-ERROR.

      IF ERROR-STATUS:ERROR
      or v-fr:ResultCode = 70
      THEN DO:
        /*revis 1584 почему-то убрали проверку v-fr:result-code под соусом ПРАВИЛЬНОЕ СОЧЕТАНИЕ ИНКАССАЦИИ И Z-ОТЧЕТА*/
        /*в итоге ФР отвечает - НЕТ ДЕНЕГ В КАССЕ - а эта ошибка игнорируется и в IBS TH создается чек , а на ФР НЕТ!!!*/
        /*TODO!!!*/
        /*пока будем проверять на эту конректную ошибку до выяснения всех обстоятельств*/
        ASSIGN
        p-err-message = SUBSTITUTE( "&1 &2 &3"
                                , RETURN-VALUE
                                , ERROR-STATUS:GET-MESSAGE(1)
                                , v-fr:ResultCodeDescription
                                )
        p-ok = FALSE
        .
        RETURN.
      END.
      IF v-fr:ResultCode <> 0
      THEN DO WHILE (v-fr:ResultCode <> 0 OR v-fr:ECRAdvancedMode <> 0):
        v-fr:GetECRStatus().
      END.
    END.
    OTHERWISE DO:
    END.
  END CASE.
  ASSIGN
  p-ok = TRUE
  p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
  .
END.  /* do on error */
END PROCEDURE. /* fr-CashOutcome */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-cut Include
PROCEDURE fr-cut :
/*------------------------------------------------------------------------------
  Purpose: Отрезать чек
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-not-full    as logical          no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  define variable v-return as integer   no-undo .

  run FreeDocCutPlus(input 1,output v-return) .

  p-ok = yes .
  return .
end.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         ASSIGN
            v-fr:Password = 1
            /*
            v-fr:CutType  = p-not-full
            */
         .
         v-fr:CutCheck() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
               p-ok = FALSE
            .
            RETURN.
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-cut */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-DocTitle Include
PROCEDURE fr-DocTitle :
/*------------------------------------------------------------------------------
  Purpose: Печать заголовка документа
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-doc-number  as character          no-undo.
/*непонятно !!! почему не integer - */
define input  parameter p-doc-name    as character          no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-return as integer   no-undo .
    define variable v-SerNum as character no-undo .
    run GetSerialNum(output v-return) .
    if v-return <> 0  then
    do:
      assign p-ok = no .
      run fr-Error-message(output p-err-message) .
      return .
    end.
    else
    do:
      run Fr-Answer(input 1,
                       input 11,
                       output v-serNum )
                       .
      run fr-print-str("Серийный N: " + v-SerNum,
              output p-err-message ,
              output p-ok )
              .

    end.
    /* перевести в режим принтера */
    run fr-print-str(p-doc-name ,
              output p-err-message ,
              output p-ok )
              .

  end.
      .
  p-ok = yes .
  return .
end.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
  CASE v-fr-type :
    WHEN {&shtrikh-m} THEN DO:
      ASSIGN
      v-fr:Password        = 1
      v-fr:DocumentNumber  = p-doc-number
      v-fr:DocumentName    = string(p-doc-name, "X(29)") /*видимо не очищается то место в памяти где лежит образ этой строки
      поэтому если не сделать строчку максимально допустимого размера - вылезает номер последнего чека -
      */
      .
      v-fr:GetECRStatus(). /* Получить состояние ФР */
      DO WHILE (v-fr:ResultCode <> 0 OR v-fr:ECRAdvancedMode <> 0):
        v-fr:GetECRStatus().
      END.
      v-fr:PrintDocumentTitle() NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR v-fr:ResultCode <> 0
      THEN DO:
        ASSIGN
        p-err-message = SUBSTITUTE( "&1 &2 &3"
                                , RETURN-VALUE
                                , ERROR-STATUS:GET-MESSAGE(1)
                                , v-fr:ResultCodeDescription
                                )
        p-ok = FALSE
        .
        RETURN.
      END.
      v-fr:GetECRStatus(). /* Получить состояние ФР */
      DO WHILE (v-fr:ResultCode <> 0 OR v-fr:ECRAdvancedMode <> 0):
        v-fr:GetECRStatus().
      END.
    END.
    OTHERWISE DO:
    END.
  END CASE.
  ASSIGN
  p-ok = TRUE
  p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
  .
END.  /* do on error */
END PROCEDURE. /* fr-DocTitle */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-OutputReceipt Include
PROCEDURE fr-OutputReceipt :
/*------------------------------------------------------------------------------
  Purpose: Печать заголовка документа
  Parameters:  <none>
  Notes: !!! не поддерживается в данной версии
------------------------------------------------------------------------------*/
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  p-ok = yes .
  return .
end.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         ASSIGN
            v-fr:Password        = 1
         .
         v-fr:OutputReceipt() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
               p-ok = FALSE
            .
            RETURN.
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-OutputReceipt */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fr-FeedDocument Include
PROCEDURE fr-FeedDocument :
/*------------------------------------------------------------------------------
  Purpose: Сдвиг чека или документа
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-count       as integer          no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

if v-fr-type = {&prim08tkm} then
do:
  define variable v-i as integer   no-undo .
  define variable v-inn  as character no-undo .
  define variable v-regn as character no-undo .
  define variable v-str-reg  as character no-undo .
  define variable v-str-reg1 as character no-undo .

  run fr-GetFiscalNums( output v-str-reg ,
                        output v-str-reg1 ,
                        output v-i) .
  if v-i = 0 then
  do:
      run Fr-Answer(input 3,
                       input 15,
                       output v-inn )
                       .
      v-str-reg1 = "ИНН: " + v-inn .

      run Fr-Answer(input 4,
                       input 15,
                       output v-regn )
                       .

      v-str-reg = "Рег. N:" + v-regn .
      v-str-reg = v-str-reg + fill(" ",6) + v-str-reg1 .
      run fr-print-str(input v-str-reg ,
                     output p-err-message ,
                     output p-ok )
                     .

      run Fr-GetDate( output v-i ,
                      output v-regn,
                      output v-inn ) .

      v-regn = string(date(v-regn),"99-99-9999") .

      v-str-reg = v-regn + fill(" ",40 - length(v-regn) - length(v-inn) - 1) + substr(v-inn,1,2) + ":" + substr(v-inn,3,2) .
      run fr-print-str(input v-str-reg ,
                     output p-err-message ,
                     output p-ok )
                     .

  end.


  do v-i = 3 to p-count :
    run fr-print-str(input ' ' ,
                     output p-err-message ,
                     output p-ok )
                     .
  end .
  p-ok = yes .
  return .
end.


IF VALID-HANDLE(v-fr)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         ASSIGN
            v-fr:Password        = 1
            v-fr:StringQuantity  = p-count
         .
         v-fr:FeedDocument() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                       , RETURN-VALUE
                                       , ERROR-STATUS:GET-MESSAGE(1)
                                       , v-fr:ResultCodeDescription
                                       )
               p-ok = FALSE
            .
            RETURN.
         END.
         v-fr:GetECRStatus(). /* Получить состояние ФР */
         DO WHILE v-fr:ResultCode <> 0:
            v-fr:GetECRStatus().
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
      p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
   .
END.  /* do on error */
END PROCEDURE. /* fr-FeedDocument */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/*==========================================================================*/
procedure fr-open-chk :
define input  parameter p-chk-type as integer          no-undo.
define output parameter p-chk-num  as integer          no-undo.
define output parameter p-err-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
define variable v-return        as int no-undo .
define variable v-num-chek      as char no-undo .
def var         v-statusConst   as char no-undo .
def var         v-statusCurrent as char no-undo .
define variable v-chk-type as integer   no-undo .
define variable         v-datefirstdoc       as character no-undo .
define variable         v-timefirstdoc       as character no-undo .

do
on error undo, return error
:
   CASE v-fr-type :
      WHEN {&shtrikh-m} THEN DO:
         ASSIGN
            v-fr:Password     = 1
         .
         v-fr:CheckType = p-chk-type.
         v-fr:OpenCheck() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR v-fr:ResultCode <> 0
         THEN DO:
            ASSIGN
               p-err-message = SUBSTITUTE( "&1 &2 &3"
                                         , RETURN-VALUE
                                         , ERROR-STATUS:GET-MESSAGE(1)
                                         , v-fr:ResultCodeDescription
                                         )
            .
            RETURN.
         END.

         p-chk-num = INT(v-fr:OpenDocumentNumber).
         ASSIGN
         p-ok = TRUE
         p-err-message = IF v-fr:ResultCode <> 0 THEN v-fr:ResultCodeDescription ELSE ""
         .

      END.
      when {&prim08tkm} then
      do :
        do
        on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        on stop   undo, return error substitute( "&1. stop", vss-workfile )
        on endkey undo, return error substitute( "&1. endkey", vss-workfile )
        :
         run Fr-GetStatusCurrent( output v-statusConst ,
                                  output v-statusCurrent ,
                                  output v-return
                                 ).
         if substr(v-statusCurrent,14,3) = "000" then   /* закрыт документ */
         do:
           if p-chk-type = 6 then
           do:    /* возврат */
             v-chk-type = 2 .
           end.
           else
           do:
             v-chk-type = 0.
           end.
           run Fr-StartReceiptPlus(input  v-chk-type ,
                                   input "" ,
                                   output p-chk-num ,
                                   output v-return
                                   )
                                   .
         end .
         if v-return = 0 then
         do:

           run Fr-FirstDoc.

           assign
              p-ok = yes
              p-err-message = ''
                     .
         end.
         else
         do:
           assign
               p-ok = no .
           run Fr-ErrorMessage(output p-err-message) .
         end.

        end.
      end .
      OTHERWISE DO:
      END.
   END CASE.
   .
end. /* do on error */
end procedure. /* fr-open-chk */

procedure fr-firstDoc:   /* Дата и время 1-го документа*/
define variable         v-datefirstdoc       as character no-undo .
define variable         v-timefirstdoc       as character no-undo .
define variable         v-return       as integer no-undo .

           run Fr-ReadCMOS(input 7 , /* смещение в CMOS */
                    input 6 ,
                    output v-datefirstdoc ,
                    output v-return) .

          run Fr-ReadCMOS(input 13 , /* смещение в CMOS */
                    input 4 ,
                    output v-timefirstdoc ,
                    output v-return) .
          if v-timefirstdoc = "0000" then
          do:

            run Fr-GetDate(output v-return,
                           output v-datefirstdoc ,
                           output v-timefirstdoc )
                           .
            run Fr-WriteCMOS(input 7 , /* смещение в CMOS */
                             input v-datefirstdoc ,
                             output v-return).
            run Fr-WriteCMOS(input 13 , /* смещение в CMOS */
                             input v-timefirstdoc ,
                             output v-return).

          end.

end procedure .

/*  ========================= PRIM08tk  ПРИМ08ТК   */
procedure Fr-OpenDLL:
define input  parameter p-com-port as character no-undo .
define output parameter v-return as int no-undo .
define variable v-OpName as char no-undo .
define variable v-Psw    as char no-undo .
define variable v-DevName as char no-undo .
def    var      v-FlagOem as int  no-undo .

 assign
    v-OpName = "Иванов"
    v-Psw    = "AERF"
    v-DevName = p-com-port
    v-FlagOem = 0
    .
    /*
   v-opName =  codepage-convert(v-OpName,"ibm866" ,session:charset) .
      */
run OpenDLL
      (input v-OpName ,
       input v-Psw ,
       input v-DevName ,
       input v-FlagOem ,
       output v-Return)
       .
 if v-return = 0 then
 do:
    RUN StartSeans(OUTPUT v-Return)
       .

 end.
end procedure.

procedure Fr-GetFiscalNums:
 def output parameter p-Type-KKM     as char no-undo .
 def output parameter p-SerialNumKKM as char no-undo .
 def output parameter p-Return       as int  no-undo .
 def var v-return     as int    no-undo .
 def var v-Responce   as memptr no-undo .
 def var v-c-Responce as char   no-undo .
 def var v-err-msg    as char   no-undo .
 def var v-creturn    as char   no-undo .
 def var v-count      as int    no-undo .


 run GetFiscalNums(output p-return) .

 if p-return = 0 then
 do:

    set-size(v-responce) = 20 .
    /* серийный номер */

    run GetFldStr(7,output v-Responce,output v-creturn ) .
       /* Ответ на запрос*/

    p-serialNumKKM = get-string(v-Responce,1) .


    set-size(v-responce) = 0 .

    set-size(v-responce) = 60 .
    /* тип ККМ */

    run GetFldStr(5,output v-Responce,output v-creturn ) .
       /* Ответ на запрос*/

    p-type-KKM = get-string(v-Responce,1) .
                 /*
    p-type-KKM = codepage-convert(p-type-KKM,session:charset,"ibm866") .
                   */
    set-size(v-responce) = 0 .


 end.
 /*
 else
 do:
   run fr-error .

 end.
   */

end procedure.
/*===========================================================*/
Procedure Fr-ChangeOpName :
/* Устанавливаем кассира */
def input  parameter p-opName as char no-undo .
def output parameter p-return as int  no-undo .
           /*
p-OpName = codepage-convert(p-OpName,"ibm866",session:charset) .
             */
run ChangeOpName( input p-OpName,
                output p-return) .
                /*
if p-return > 0 then
do:
  run fr-Error.
end.
                  */

end procedure .
/*=========================================================*/
procedure Fr-GetResource:
/*   Получить номер последней закрытой смены, дата первого открытого документа, время его же */

def output parameter p-return    as int no-undo .
def output parameter p-LastShift as int no-undo .
def output parameter p-DateFirstDoc as char no-undo .
def output parameter p-TimeFirstDoc as char no-undo .

run GetResource(output p-return) .

if p-return = 0 then
do:
  run Fr-Answer-i(3, output p-LastShift) .
  run Fr-Answer(2,16,output p-DateFirstDoc) .
  run Fr-Answer(1,16,output p-TimeFirstDoc) .

end.
/*
else
do:
  run Fr-Error.
end.
*/
end procedure .
/*============================================================*/
procedure Fr-GetDate:
def output parameter v-return    as int  no-undo .
def output parameter v-dateKKM   as char no-undo .
def output parameter v-timeKKM   as char no-undo .


def var v-flds-Count as int no-undo .
def var v-Responce   as memptr no-undo.
def var v-length     as int no-undo .

v-length = 16 .


run GetDate(output v-return) .

if v-return = 0 then
do:
    run Fr-Answer(input 1,
                  input v-length ,
                  output v-timeKKM ) .

    run Fr-Answer(input 2,
                  input v-length ,
                  output v-dateKKM ) .


end.

end procedure .
/*===================================================================*/
procedure Fr-GetSerialNum:
define output parameter v-return    as int no-undo .
define output parameter v-SerialNum as char no-undo.

run GetSerialNum(output v-return) .
if v-return = 0 then
do:
  run Fr-Answer(1,
               16,
               output v-SerialNum) .
end.
end procedure .
/*==================================================================*/
procedure Fr-StartReceiptPlus:
def input parameter v-pay      as int no-undo .
define input  parameter v-FreeField as character no-undo .
def output parameter v-ChekNum as int no-undo .
def output parameter v-return  as int no-undo .

def var v-copy    as int no-undo .
def var v-tableNo as char no-undo .
def var v-PlaceNo as char no-undo .
def var v-AccountNo as char no-undo .
/* def var v-FreeField as char format 'x(255)' no-undo .  */

assign /* v-pay = 0 */ /* Продажа, 1-сторно, 2-возврат */
       v-copy = 1
       v-tableNo = ''
       v-placeNo = ''
       v-AccountNo = ''
       .
run StartReceiptPlus( input v-pay ,
                  input v-copy ,
                  input v-tableNO ,
                  input v-placeNo ,
                  input v-AccountNo ,
                  input v-FreeField ,
                  output v-return ) .
if v-return = 0 then
do:

  run Fr-answer-i(1 , output v-ChekNum) .

end.
end procedure .
/*==========================================================*/
procedure Fr-ItemReceiptPlus:
def input parameter v-WareName   as char format 'x(40)' label " Наименование товара,услуги"
              no-undo.
def input parameter v-WareCode   as char format 'x(20)' label " Баркод " no-undo .

def input parameter v-Measure    as char format 'x(3)' label "Единица измерения" no-undo .
def input parameter v-SecId      as char format 'x(20)' label "Секция" no-undo .
def input parameter v-FreeField  as char format 'x(255)' no-undo .
def input parameter v-price      as int  format '>>>>>>>>>>>>>9' label "Цена в копейках" no-undo .
def input parameter v-Count      as int  format '->>>>>>>>>>>>9' label "кол-во" no-undo .
def input parameter v-WareType   as int  format '>9' label 'Тип товара' initial 1 no-undo .
def input parameter v-discount   as int  format '->>>>>>>>>>>>9' label " скидка " no-undo .
def output parameter v-return    as int no-undo .
def output parameter v-itogo     as char no-undo .
def output parameter v-Itogo-Str as char no-undo .
def output parameter v-Disc-Str  as char no-undo .
def var v-TaxType  as int format '9' label "НДС(0-18.00,1-10.00)"
   initial 9 no-undo .
define variable v-Free-disc as character no-undo .

if v-Price * v-Count / 1000 + v-discount < 0 then
do:
  message "Скидка по строке " v-discount skip
          "больше суммы товара " v-Price * v-Count / 1000 " все в копейках"
          view-as alert-box title "ошибка" .
  return .
end.

if v-discount <> 0  then
do:
  assign
  v-Free-disc = v-FreeField
  v-FreeField = ""
  .
end.
if v-Count < 0 then
    v-FreeField = " АННУЛЯЦИЯ ТОВАРА "  .

run ItemReceiptPlus(
                input v-WareName ,
                input v-WareCode ,
                input v-Measure  ,
                input v-SecId    ,
                input v-FreeField,
                input v-Price ,
                input v-Count ,
                input v-WareType ,
                output v-return )
                .

if v-return = 0 then
do:
    run Fr-answer( input 1,
                   input 19,
                   output v-Itogo)
                   .

    run Fr-answer( input 2,
                   input 19,
                   output v-Itogo-Str)
                   .

end.

if v-discount <> 0 and v-return = 0 then
do:
  run Fr-StrComissionReceiptPlus( input v-discount ,
                                  input v-Free-Disc ,
                                  output v-Itogo ,
                                  output v-Disc-Str,
                                  output v-return)
                                  .
end .
   /*
if v-return = 0 and v-TaxType < 2 and v-TaxType >= 0 then
do:
  run TaxReceipt(input v-TaxType,output v-Return ) .
  if v-Return > 0  then  run Fr-Error .
end.
     */
end procedure .
/*==========================================================*/
procedure Fr-ComissionReceiptPlus:
def input parameter   v-OType      as int format '9' label "1-скидка(0-наценка)" no-undo .
def input parameter   v-Sum        as int format '>>>>>>>>>>>>>9' label "сумма скидки" no-undo .
def input parameter   v-FreeField  as char format 'x(255)' no-undo .
def output parameter  v-itogo      as char no-undo .
def output parameter  v-itogo-disc as char no-undo .
def output parameter  v-return     as int no-undo .
def var v-Percent  as int format '>>>>>>>>>>>>>9' label "Процент скидки" no-undo .


def var v-creturn as char no-undo .

assign v-Percent = 0 .
              /*
v-FreeField = codepage-convert(v-FreeField , 'ibm866' ,
                 session:charset) .
                */
  run ComissionReceiptPlus(
                     input v-OType ,
                     input v-Percent ,
                     input v-Sum ,
                     input v-FreeField ,
                     output v-Return
                     ) .
if v-return = 0 then
do:
    run Fr-answer( 1 , 19 ,output v-itogo) .

    run Fr-answer( 2 , 19 ,output v-itogo-disc) .

end.


end procedure .
/*=================================================================*/
procedure Fr-StrComissionReceiptPlus :
def input parameter  v-Discount as int no-undo. /* + наценка - скидка в копейках */
def input parameter  v-Message  as char no-undo .
def output parameter v-Itogo    as char no-undo .
def output parameter v-str-disc as char no-undo .
def output parameter v-Return   as int no-undo .
def var v-OType    as int no-undo .
def var v-Percent  as int no-undo .
def var v-Sum      as int no-undo .
def var v-FreeField as char format 'x(255)' no-undo .

  assign
  v-OType = 0
  v-FreeField = v-Message
  v-Sum = abs(v-discount)
  .

  if v-discount < 0 then v-OType = 1 .

  run ComissionReceiptPlus(
                     input v-OType ,
                     input v-Percent ,
                     input v-Sum ,
                     input v-FreeField ,
                     output v-Return
                     ) .
 if v-return = 0 then
 do:
    run Fr-answer(1,19,output v-Itogo) .
    run Fr-answer(2,19,output v-Str-Disc) .
 end .


end procedure .
/*==========================================================*/

procedure Fr-WriteCMOS:
def input parameter  p-offs     as int no-undo .
def input parameter  p-operator as char no-undo .
def output parameter p-return   as int no-undo.


run WriteCMOS( input p-offs ,
               input p-operator ,
               output p-return ) .
end procedure .
/************==================================********/
procedure Fr-TotalReceiptPlus:
define input  parameter v-FreeField as char no-undo .
define output parameter v-ItogoSum  as char no-undo .
define output parameter v-return    as int  no-undo .


run TotalReceiptPlus(input v-FreeField ,
                     output v-return) .

if v-return = 0 then
do :
   run Fr-Answer(input 1, input 19 ,output v-ItogoSum) .
end .

end procedure .
/************==================================********/
procedure Fr-SubTotalReceiptPlus:
define input  parameter v-FreeField as char no-undo .
define output parameter v-ItogoSum  as char no-undo .
define output parameter v-return    as int  no-undo .


run SubTotalReceiptPlus(input v-FreeField ,
                     output v-return) .

if v-return = 0 then
do :
   run Fr-Answer(input 1, input 19 ,output v-ItogoSum) .
end .

end procedure .
/*====================================================*/
procedure Fr-GetParamDoc :
/*  процедура возвращает параметры документа 1 и 2 (биты справа на лево)*/
define output parameter v-return       as integer   no-undo .
define output parameter v-res-current1 as character no-undo .
define output parameter v-res-current2 as character no-undo .

define variable v-param-i1 as integer   no-undo .
define variable v-param-i2 as integer   no-undo .


 run GetParamDoc(output v-return) .
 /* запрос параметров  */

 if v-return = 0 then
 do:


      run GetFldWord( 5, output v-param-i1) .

      RUN ReadStatusCurrentNew(v-param-i1,
                                        16,
                      output v-res-current1 )
         .

      /*  2-oe слово параметры документа, считали как слово */

      run GetFldWord( 6, output v-param-i2) .

       RUN ReadStatusCurrentNew(v-param-i2 ,
                                        16 ,
                      output v-res-current2 )
                      .

 end .

end procedure .
/*====================================================*/
procedure Fr-GetMony :
  define input  parameter p-num-Par    as integer   no-undo.
  define input  parameter p-length-par as integer   no-undo .
  define output parameter p-CashMony   as deci   no-undo .
  def var v-mony-c as char no-undo .
  define variable v-return as integer   no-undo .

  run GetMony (output v-return) .

  if v-return = 0  then
  do :
     Run Fr-Answer(p-num-par,
                   p-length-par ,
            output v-mony-c)
            .
     p-Cashmony = deci( v-mony-c)
      .
  end .


end procedure .
/*====================================================*/
procedure Fr-GetNumbers:
define output parameter p-num-chek as integer   no-undo .
define output parameter p-num-doc  as integer   no-undo .
define output parameter p-return   as integer   no-undo .


do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  run GetNumbers(output p-return).

  if p-return = 0 then
  do:

      /* Номер сквозного документа */

      run GetFldWord( 5, output p-num-doc ) .

      /* Номер чека */

      run GetFldWord( 6, output p-num-chek ) .

  end.

end.

end procedure .
/* ================================================= */
procedure Fr-ReadCMOS:
def input  parameter v-offs   as int no-undo .
def input  parameter v-num    as int no-undo .
def output parameter v-operator as char no-undo .
def output parameter v-return as int no-undo .
def var v-Flds-Count as int no-undo .
def var v-i as int no-undo .

run ReadCMOS( input v-offs ,
              input v-num ,
              output v-return ) .

if v-return = 0 then
do:
    run GetFldsCount(output v-flds-Count) .

    do v-i = 5 to v-flds-Count :
      run GetFldByte( v-i , output v-return ) .
      if v-return = 0 then leave .
      v-operator = v-operator + chr(v-return,Session:charset,'ibm866') .
    end.
end.

end procedure .
/*============================================================*/
procedure Fr-Answer:
def input parameter  p-num    as int no-undo .
def input parameter  p-length as int no-undo .
def output parameter p-answer as char no-undo .

def var v-Flds-Count as int no-undo .
def var v-responce  as memptr no-undo .
def var v-creturn   as char   no-undo .

    run GetFldsCount(output v-flds-Count) .
    set-size(v-responce ) = p-length .

    run GetFldStr(input v-flds-Count - p-num ,
     output v-responce ,
     output v-creturn ) .
    p-answer = get-string(v-responce,1) .
    set-size(v-responce) = 0 .
end procedure .
/*================================================================*/
procedure Fr-Answer-i :
def input parameter  p-num    as int no-undo .
def output parameter p-answer as int  no-undo .

def var v-Flds-Count as int no-undo .
    run GetFldsCount(output v-flds-Count) .

    run GetFldWord(input v-flds-Count - p-num ,
     output p-answer) .

end procedure .

/* ======================================== */
Procedure Fr-ErrorMessage :
def output parameter p-err-message as char no-undo .

define variable  v-return    as integer no-undo .
define variable  v-responce  as memptr  no-undo .
define variable  v-creturn   as char    no-undo .
define variable  v-c-Responce as char   no-undo .


run GetLastDllError(output v-return) .

set-size(v-Responce) = 120 .
run GetErrorMessage(output v-Responce , output v-creturn ) .

v-c-Responce = get-string(v-Responce , 1) .
set-size(v-Responce) = 0 .

p-err-message = string(v-return) + " - " + v-c-Responce .

end procedure.
/* ====================================================*/
procedure Fr-Error:


def var v-proc     as char no-undo .
def var v-int-proc as char no-undo .
def var v-ext-proc as char no-undo .
def var v-Responce as memptr no-undo.
def var v-creturn as char no-undo.
def var v-return as int no-undo.
def var v-Answer as char no-undo .
def var v-c-Responce as char no-undo.

v-proc = program-name(2) .

if index(v-proc,' ') > 0 then
do :
  v-int-proc = trim(substr(v-proc ,1 , index(v-proc,' '))) .
  v-ext-proc = substr(v-proc , index(v-proc,' ') + 1) .
end .
else
do:
  assign v-int-proc = ''
         v-ext-proc = v-proc .
end .

   run GetLastDllError(output v-return) .

   set-size(v-Responce) = 120.
   run GetErrorMessage(output v-Responce ,output v-creturn).
   v-c-Responce = get-string(v-Responce,1).
   set-size(v-Responce) = 0.


   if v-int-proc = '' then
     message "           процедура" v-ext-proc skip
         'v-return = ' v-return skip
          'v-c-responce = ' v-c-responce
           view-as alert-box .
   else
     message "Внутренняя процедура" v-int-proc skip
           "           процедура" v-ext-proc skip
             'v-return = ' v-return skip
             'v-c-responce = ' v-c-responce
             view-as alert-box .


end procedure.
/*================================================*/
procedure Fr-SetDate:
def output parameter v-return as int no-undo .
def var v-Responce as memptr no-undo.
def var v-creturn as char no-undo.
def var     ctime as char no-undo .

def var v-Answer as char no-undo .
def var v-lenmsg as int  no-undo .



  run SetDate(output v-return) .
  if v-return = 0 then
  do:
    set-size(v-Responce) = 120.
    run GetCommand(output v-Responce ,output v-creturn).
    v-Answer = get-string(v-Responce,1).
    ctime = string(time,"HH:MM:SS" ) .
    ctime = substr(ctime,1,2) + substr(ctime,4,2) .
    v-Answer = substr(v-answer,1,16) + ctime  .
    v-lenmsg = length(v-answer) .
    put-string(v-responce,1) = v-Answer .

    run DllComWritePlus(input v-Responce,input v-lenmsg,output v-return) .
  end .
end procedure .

procedure Fr-GetStatusCurrent:
  def output parameter v-res-const    as char no-undo .
  def output parameter v-res-current  as char no-undo .
  def output parameter v-return       as int no-undo .
  DEF VAR v-status-const AS INT NO-UNDO .
  DEF VAR v-status-curr  AS INT NO-UNDO .

  run GetStatus(output v-return) .

  if v-return = 0 then
  do :
    RUN GetFldByte(1 , OUTPUT v-status-const) .

    RUN ReadStatusCurrent(v-status-const,
                                          8,
                      output v-res-const)
                      .

    RUN GetFldWord(2 , OUTPUT v-status-curr ) .

    RUN ReadStatusCurrent(v-status-curr,
                                        16,
                      output v-res-current )
                          .
    run CheckStatusNum(2, 2, output v-return) .  /* Сигнал с денежного ящика */
    v-res-const = v-res-const + string(v-return) .
    run CheckStatusNum(3, 2, output v-return) .  /* Крышка ККм открыта */
    v-res-const = v-res-const + string(v-return) .
    run CheckStatusNum(3, 5, output v-return) .  /* Печать остановлена из-за конца бумаги */
    v-res-const = v-res-const + string(v-return) .
    run CheckStatusNum(5, 3, output v-return) .  /* Чековая лента близка к концу */
    v-res-const = v-res-const + string(v-return) .

  end.
end procedure .
/* ======================================================= */
procedure Fr-SetParamDoc:
  define input  parameter p-clear-cash-counter as character no-undo .
  def input parameter     p-cutter              as char      no-undo .


  def var v-res-current1 as char no-undo .
  def var v-res-current2 as char no-undo .
  def var v-param-i1     as int no-undo .
  def var v-param-i2     as int no-undo .
  def var v-return       as int  no-undo .
  def var v-res-current3 as char no-undo .
  define variable v-i as integer   no-undo .

  Run Fr-ParamDoc(output v-param-i1,
                  output v-param-i2,
                  output v-return ).
  if v-return = 0 then
  do:
        RUN ReadStatusCurrent(v-param-i1,
                                        16,
                      output v-res-current1 )
                      .

        RUN ReadStatusCurrent(v-param-i2,
                                        16,
                      output v-res-current2 )
                      .
        v-res-current2 = substr(v-res-current2,1,10) + p-cutter +
                         substr(v-res-current2,12,4) + p-clear-cash-counter .
        do v-i = 1 to 16:
          v-res-current3 = v-res-current3 + substr(v-res-current2,
                                                   16 - (v-i - 1),1)
                                                   .
        end.
        RUN WriteStatusCurrent(v-res-current3,
                                        16,
                      output v-param-i2 )
                      .
        run SetParamDoc(input v-param-i1,
                        input v-param-i2,
                        input 15 ,
                        output v-return) .

  end.

end procedure .
/* ======================================================= */

procedure Fr-ParamDoc:
 def output parameter v-param-i1 as int no-undo .
 def output parameter v-param-i2 as int no-undo .
 def output parameter v-return   as int    no-undo .

 def var v-flds-Count as int  no-undo .



 run GetParamDoc(output v-return) .
 /* запрос параметров  */

 if v-return = 0 then
 do:

    run GetFldsCount(output v-flds-Count) .
    /*  к-во полей в ответе    */

    if v-flds-Count > 6 then
    do:
      /*  1-oe слово параметры документа, считали как слово */

      run GetFldWord( 5, output v-param-i1) .

         .
      /*  2-oe слово параметры документа, считали как слово */

      run GetFldWord( 6, output v-param-i2) .

                      .



    end.
 end .

end procedure .
procedure Fr-Prim08ECRStatus:
 /* транслируем состояние ПРИМ08ТК в ШТРИХ */
 def output parameter p-fr-mode     as int  no-undo .
 def output parameter p-err-message as char no-undo .
def var v-status-const   as char no-undo .
def var v-status-current as char no-undo .
def var v-return         as int  no-undo .

run Fr-GetStatusCurrent(output v-status-const ,
                        output v-status-current ,
                        output v-return )
                        .
if substr(v-status-const,5,4) = '1000' then
do:
   assign
      p-fr-mode = 0 .
end.

if substr(v-status-const,1,1) = '0' then
do:
  assign
  p-err-message = "ККМ не присвоен серийный номер" .
end.

if substr(v-status-const,2,1) = '1' then
do:
  assign
  p-err-message = "Количество перерегистраций исчерпано"
  p-fr-mode = 5.
end.

if substr(v-status-const,3,1) = '1' then
do:
  assign
  p-err-message = "Фискальная память исчерпана "
  p-fr-mode = 5.
end.

if substr(v-status-const,4,1) = '1' then
do:
  p-err-message = "Осталось менее 30 закрытий смен"  .
end.

if p-fr-mode = 0 then
do:
   if substr(v-status-current,5,1) = '0' then
   do:
      p-fr-mode = 4.   /* Закрытая смена  */
   end.

   if substr(v-status-current,10,1) = '1' then
   do:
      p-fr-mode = 9.  /* Технологическое */
   end.

   if substr(v-status-current,5,1) = '0' then
   do:
      p-fr-mode = 3.    /* смена открыта, требуется закрытие смены */
   end.
   else
   do:
     p-fr-mode = 2.  /* смена открыта, не требуется закрытие смены */
   end.

   if substr(v-status-current,14,3) <> '000' and substr(v-status-current,14,3) <> '' then
   do:
      p-fr-mode = 8.    /* Открытый документ */
   end.

end.

end procedure .

/* ======================================================= */

PROCEDURE WriteStatusCurrent :
def input  parameter p-res as char .
def input  parameter p-length-param as int  no-undo .
def output parameter p-param-i1       as int no-undo .
/* номер параметра  */

def var v-i as int no-undo .
def var v-par-bit1 as int no-undo .

      do v-i = 1 to p-length-param :
        v-par-bit1 = int(substr(p-res,v-i,1)) .

        put-bits(p-param-i1,v-i,1) = v-par-bit1.


      end.

END PROCEDURE.

/* ======================================================= */
procedure ReadStatusCurrent:
/* номер параметра  */
def input parameter p-param-i1     as int no-undo .
def input parameter p-length-param as int no-undo .
def output parameter v-cres        as char no-undo .

def var v-i as int no-undo .
def var v-par-bit1 as int no-undo .


      do v-i = 1 to p-length-param:

        v-par-bit1 = get-bits(p-param-i1,v-i,1) .

        v-cres = string(v-par-bit1) + v-cres .

      end.


end procedure.
/*================================================*/

Procedure OpenDLL External "Azimuth.dll" persistent:
def input parameter p-OpName   as character .
def input parameter p-Psw      as character .
def input parameter p-DevName  as character .
def input parameter p-FlagOem  as Long .
def return parameter p-Return as Long .
end procedure.


PROCEDURE StartSeans EXTERNAL "Azimuth.dll" :
    DEF RETURN PARAMETER p-return AS LONG .
END PROCEDURE .

PROCEDURE ReadComm EXTERNAL "Azimuth.dll":
    def output parameter p-responce as memptr .
    def input parameter p-Count    as long .
    DEF RETURN PARAMETER p-return AS LONG .
END PROCEDURE .


Procedure CloseDLL External "Azimuth.dll" :
def return parameter p-Return as Long .
end procedure .

Procedure GetDllVer External "Azimuth.dll" :
def output parameter p-responce as memptr .
def return parameter p-Return as char .
end procedure .

Procedure GetSerialNum External "Azimuth.dll" :
def return parameter p-Return as Long .
end procedure .

Procedure GetFiscalNums External "Azimuth.dll" :
def return parameter p-Return as Long .
end procedure .

Procedure GetFldsCount External "Azimuth.dll" :
def return parameter p-Return as Long .
end procedure .



Procedure GetAnswer External "Azimuth.dll" :
def output parameter p-Responce as memptr.
def return parameter p-Return as Char .
end procedure .

procedure GetStatus External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure GetStatusNum External "Azimuth.dll" :
def input parameter p-num as long .
def return parameter p-return as long .
end procedure .

procedure GetFldStr External "Azimuth.dll" :
def input parameter p-num as long .
def output parameter p-Responce as memptr .
def return parameter p-return as char .
end procedure .

procedure GetFldWord External "Azimuth.dll" :
def input parameter p-num as long .
def return parameter p-return as long .
end procedure .

procedure GetFldInt External "Azimuth.dll" :
def input parameter p-num as long .
def return parameter p-return as long .
end procedure .

procedure GetFldByte External "Azimuth.dll" :
def input parameter p-num as long .
def return parameter p-return as long .
end procedure .


procedure GetParamDoc External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure GetResource External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure ShiftClose External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure XReport External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure GetCounters External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure GetLastDllError External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure GetErrorMessage external "Azimuth.dll" :
def output parameter p-responce as memptr .
def return parameter p-return as char .
end procedure .

procedure GetErrorMessageNo external "Azimuth.dll" :
def output parameter p-responce as memptr .
def input parameter p-Errno as long .
def return parameter p-return as char .
end procedure .

procedure GetNumbers External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure CheckStatusNum External "Azimuth.dll" :
def input parameter p-byte as long .
def input parameter p-bit  as long .
def return parameter p-return as long.
end procedure .

procedure SetHeader External "Azimuth.dll" :
def input parameter p-Header1 as char .
def input parameter p-Header2 as char .
def input parameter p-Header3 as char .
def input parameter p-Header4 as char .
def return parameter p-return as long .
end procedure .

procedure SetHeaderNew External "Azimuth.dll" :
def input parameter p-Header1 as char .
def input parameter p-Header2 as char .
def input parameter p-Header3 as char .
def input parameter p-Header4 as char .
def input parameter p-Header5 as char .
def input parameter p-Header6 as char .
def return parameter p-return as long .
end procedure .

procedure SetTail External "Azimuth.dll" :
def input parameter p-Header1 as char .
def input parameter p-Header2 as char .
def input parameter p-Header3 as char .
def input parameter p-Header4 as char .
def return parameter p-return as long .
end procedure .

procedure GetDate External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .


procedure SetDate External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure GetPayment External "Azimuth.dll" :
def input parameter p-paymentNum as long .
def return parameter p-return as long .
end procedure .

procedure ReadCMOS External "Azimuth.dll" :
def input parameter p-Offs as long .
def input parameter p-Num  as long .
def return parameter p-return as long.
end procedure .


procedure WriteCMOS External "Azimuth.dll" :
def input parameter p-Offs as long .
def input parameter p-Operator as char .
def return parameter p-return as long.
end procedure .

Procedure SetPayment External "Azimuth.dll" :
def input parameter p-Code-payment as long .
def input parameter p-Name-Payment as char .
def input parameter p-IsSecondLine as long .
def input parameter p-IsChange     as long .
def input parameter p-CurrencyIndex as long .
def input parameter p-PermOperation as long .
def input parameter p-CrossCource   as char .
def return parameter p-return as long .
end procedure .

Procedure StartReceipt external "Azimuth.dll":
def input parameter p-pay as byte .
def input parameter p-copy as byte .
def input parameter p-TableNo as char .
def input parameter p-PlaceNo as char .
def input parameter p-AccesNo as char .
def return parameter p-return as long .
end procedure.

Procedure StartReceiptPlus external "Azimuth.dll":
def input parameter p-pay as byte .
def input parameter p-copy as byte .
def input parameter p-TableNo as char .
def input parameter p-PlaceNo as char .
def input parameter p-AccesNo as char .
def input parameter p-FreeField as char .
def return parameter p-return as long .
end procedure.

procedure ItemReceiptPlus external "Azimuth.dll":
def input parameter p-WareName as char .
def input parameter p-WareCode as char .
def input parameter p-Measure  as char .
def input parameter p-SecId    as character .
def input parameter p-FreeField as char .
def input parameter p-Price    as long .
def input parameter p-Count    as long .
def input parameter p-WareType as byte .

def return parameter p-return  as long .

end procedure .


procedure ItemReceiptExx external "Azimuth.dll":
def input parameter p-WareName  as char .
def input parameter p-WareCode  as char .
def input parameter p-Measure   as char .
def input parameter p-SecId     as character .
def input parameter p-FreeField as char .
def input parameter p-Price     as char .
def input parameter p-Count     as char .
def input parameter p-WareType  as byte .

def return parameter p-return  as long .

end procedure .


procedure CashDriverOpen External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .


procedure SubTotalReceipt External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure SubTotalReceiptPlus External "Azimuth.dll" :
def input parameter p-FreeField as char .
def return parameter p-return as long .
end procedure .


procedure TotalReceipt External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure TotalReceiptPlus External "Azimuth.dll" :
def input parameter p-FreeField as char .
def return parameter p-return as long .
end procedure .

procedure TenderReceipt External "Azimuth.dll" :
def input parameter p-payType as byte .
def input parameter p-TenderSum as long .
def input parameter p-CardName as char .
def return parameter p-return as long .
end procedure .

procedure TenderReceiptPlus External "Azimuth.dll" :
def input parameter p-payType as byte .
def input parameter p-TenderSum as long .
def input parameter p-CardName as char .
def input parameter p-FreeField as char .
def return parameter p-return as long .
end procedure .


procedure CloseReceipt External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure CancelReceipt External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure SetCommTimeoutMs External "Azimuth.dll":
def input parameter p-WaitRxTime as long.
def input parameter p-WaitTxTime as long.
def return parameter p-return as long .
end procedure .

procedure FromCash External "Azimuth.dll" :
def input parameter p-Sum as long .
def return parameter p-return as long .
end procedure .


procedure ToCash External "Azimuth.dll" :
def input parameter p-Sum as long .
def return parameter p-return as long .
end procedure .


procedure GetFldFloat External "Azimuth.dll" :
def input parameter p-num as byte .
def return parameter p-return as float .

end procedure .

procedure GetMony External "Azimuth.dll" :
def return parameter p-return as long .

end procedure .

procedure ChangeOpName External "Azimuth.dll" :
def input parameter p-OpName as char .
def return parameter p-return as long .
end procedure .

procedure EJPrint External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure GetSerialAnswer External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure GetLastAnswer External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure OpenFDoc External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure CloseFDoc External "Azimuth.dll" :
def return parameter p-return as long .
end procedure .

procedure PrintOEMCRLFDoc External "Azimuth.dll" :
def input parameter  p-information as character.
def input parameter  p-len         as long.
def return parameter p-return as long .
end procedure .

procedure PrintOEMDoc External "Azimuth.dll" :
def input parameter  p-information as character.
def input parameter  p-len         as long.
def return parameter p-return as long .
end procedure .

procedure FontSelectFDoc External "Azimuth.dll" :
def input parameter  p-Font         as byte .
def return parameter p-return as long .
end procedure .

procedure ComissionReceiptPlus External "Azimuth.dll" :
def input parameter p-OType    as byte .
def input parameter p-Percent  as long .
def input parameter p-Sum      as long .
def input parameter p-FreeField as char .
def return parameter p-return as long .
end procedure .

procedure GetTaxes External "Azimuth.dll" :
def input parameter p-TIndex as byte .
def return parameter p-return as long .

end procedure .

procedure SetTaxes External "Azimuth.dll" :
def input parameter p-TIndex as byte .
def input parameter p-TType  as byte .
def input parameter p-TName  as char .
def input parameter p-TValue as char .
def input parameter p-TMin   as char .
def return parameter p-return as long .

end procedure .

procedure TaxReceipt External "Azimuth.dll" :
def input parameter p-TIndex as byte .
def return parameter p-return as long .

end procedure .

procedure EKLEJournalReport External "Azimuth.dll" :
def input parameter p-EJournalNum as long .
def return parameter p-return as long .


end procedure .

procedure FreeDocCutPlus External "Azimuth.dll" :
def input parameter p-count as byte .
def return parameter p-return as long .
end procedure .


Procedure DllComWritePlus External "Azimuth.dll" :
def input parameter p-Responce as memptr .
def input parameter p-lenmsg  as long .
def return parameter p-Return as long .
end procedure .

procedure SetParamDoc External "Azimuth.dll" :
def input parameter p-ParamDoc1 as long .
def input parameter p-ParamDoc2 as long .
def input parameter p-TimeoutSlip as long .
def return parameter p-return as long .
end procedure .


Procedure GetCommand External "Azimuth.dll" :
def output parameter p-Responce as memptr.
def return parameter p-Return as Char .
end procedure .