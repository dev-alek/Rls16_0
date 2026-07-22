block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cashmain.p $
$Archive: gbl/cashmain.p $

Инициализация АРМа Касса

Автор: Белоусов Илья Александрович
Дата создания: 07/07/08
Author: Ilia Belousov
Creation date: 07/07/08

*/

define input parameter p-user-id    as character no-undo .
define input parameter p-user-password    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cashmain.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/cashmain.p $":U .
define variable vss-description as character no-undo init "Инициализация АРМа Касса".
{ cmp/vssrevis.i }
{ cmp/trg-def.i new }
{ gbl/cur-time.i }
{ gbl/cmptime.i  }
{ gbl/sys-time.i }
{ gbl/gbclcode.i }
{ gbl/getcntxt.i def }
{ str/libthpos.i }
{ gbl/getcntxa.i }
{ gbl/mainproc.i def }

define variable conf-par               as character no-undo .
define variable par-type               as character no-undo .
define variable v-today                as date      no-undo .
define variable v-time                 as integer   no-undo .
define variable v-computer-name        as character no-undo .
define variable v-computer-tcp-name    as character no-undo .
define variable v-computer-ip-addr     as character no-undo .
define variable v-computer-login-name  as character no-undo .
define variable v-computer-process-pid as integer   no-undo .
define variable v-connect-usr          as integer   no-undo .
define variable v-connect-device       as character no-undo .
define variable v-userio-id            as integer   no-undo .
define variable v-emul                 as logical   FORMAT "да/нет"   no-undo.

define variable v-obj-code    as integer      no-undo.
define variable v-cash-num    as integer      no-undo.

define buffer buf_sys-ctrl     for ub.sys-ctrl .
define buffer buf_user-account for ub.user-account .
define buffer buf_user-login   for ub.user-login .
define variable parparentproc    as handle       no-undo.

do
on error undo, return error return-value
:

   assign
      parparentproc = this-procedure
   .
   run sys-time_get-comp-user-name in this-procedure
      (output v-computer-name
      ,output v-computer-login-name
      ,output v-computer-process-pid
      ) .


   /* Проверки */
   /* 1. Параметры сессии */
   define variable v-session-parameters    as character    no-undo.
   define variable v-num-param             as integer      no-undo.
   define variable v-counter               as integer      no-undo.
   define variable v-param-name            as character    no-undo.
   define variable v-param-value           as character    no-undo.
   define variable v-desk-num-set          as logical      no-undo.
   define variable v-obj-code-set          as logical      no-undo.

   assign
      v-session-parameters = session:parameter
      v-num-param          = num-entries(v-session-parameters)
      v-counter            = 1
   .
   IF v-num-param = 0
   OR (v-num-param modulo 2) <> 0
   THEN DO:
      message
         "Неверное число параметров"
         skip  "Работа с кассой невозможна."
      view-as alert-box error.
      quit.
   end.

   read-param:
   do while v-counter < v-num-param
   on error  undo, leave
   on endkey undo, leave
   on stop   undo, leave
   :
      assign
         v-param-name  = TRIM(entry( v-counter    , v-session-parameters ))
         v-param-value = TRIM(entry( v-counter + 1, v-session-parameters ))
         v-counter     = v-counter + 2
      .
      case v-param-name:
      WHEN "маг" THEN DO:
         assign
            v-obj-code = INTEGER(v-param-value)
         no-error.
         IF ERROR-STATUS:ERROR
         OR v-obj-code <= 0
         OR v-obj-code  = ?
         THEN DO:
            message
               "Неверный номер магазина:"
               skip v-param-value
               skip "Работа с кассой невозможна."
            view-as alert-box error.
            quit.
         END.
         assign
            v-obj-code-set = TRUE
         .
      END.
      WHEN "касса" THEN DO:
         assign
            v-cash-num = INTEGER(v-param-value)
         no-error.
         IF ERROR-STATUS:ERROR
         OR v-cash-num <= 0
         OR v-cash-num  = ?
         THEN DO:
            message
               "Неверный номер кассы:"
               skip v-param-value
               skip "Работа с кассой невозможна."
            view-as alert-box error.
            quit.
         END.
         assign
            v-desk-num-set = TRUE
         .
      END.
      WHEN "эмулятор" THEN DO:
         assign
            v-emul = LOGICAL(v-param-value)
         no-error.
         IF ERROR-STATUS:ERROR
         THEN DO:
            message
               "Неверные настройки эмулятора:"
               skip v-param-value
               skip "Работа с кассой невозможна."
            view-as alert-box error.
            quit.
         END.
      END.

      otherwise dO:
          message
            "Неизвестный параметер" v-param-name
            skip
          view-as alert-box error.
      END.
      END case.
   end.

   IF NOT v-desk-num-set
   THEN DO:
      message
         "Среди переданных параметров не было номера кассы"
         skip "Работа с кассой невозможна."
      view-as alert-box error.
      quit.
   END.

   /* 2. № магазина */
   IF NOT v-obj-code-set
   THEN DO:
      message
         "Среди переданных параметров не было номера магазина"
         skip "Работа с кассой невозможна."
      view-as alert-box error.
      quit.
   END.

   /* 3. № БД */
   RUN init-cntxt IN THIS-PROCEDURE.
   /* Вызов процедуры только в этом модуле, в остальных { gbl/getcntxt.i def } */

   IF v-cntxt-db-num <> v-cntxt-db-num-obj
   THEN DO:
      message
         SUBSTITUTE("Во входных параметрах указана касса &1 магазина &2, привязаного к &3 БД", v-cash-num, v-obj-code, v-cntxt-db-num-obj )
         skip "Текущая БД:" v-cntxt-db-num
         skip "Работа с кассой невозможна."
      view-as alert-box error.
      quit.
   END.

   FIND FIRST buf_user-account
        WHERE buf_user-account.user-id = v-cntxt-userid
        no-lock
        .

   IF buf_user-account.psn-code = 0
   OR buf_user-account.psn-code = ?
   THEN DO:
      message
         substitute("У данного пользователя &1 (&2) нет привязки к физическому лицу."
                    , buf_user-account.nik
                    , buf_user-account.user-id)
         skip "Работа с кассой невозможна."
      view-as alert-box error.
      quit.
   END.

   define variable v-cashier-code as integer no-undo .
   define variable v-password     as character no-undo .
   assign
      v-cashier-code = gbclcode-get-db-role ( input {&role-cashier}
                                            , input v-cntxt-db-num
                                            , input buf_user-account.psn-code
                                            , input ? /*p-date-start*/
                                            , output v-password
                                            )
   .
   IF v-cashier-code <= 0
   OR v-cashier-code  = ?
   THEN DO:
      run cur-time in this-procedure
         (output v-today
         ,output v-time
         ).

      message
         substitute("На текущий момент (&2) данный пользователь не является кассиром", v-today)
         skip "Работа с кассой невозможна."
      view-as alert-box error.
      quit.
   END.


   /* Вызов основного экрана */
   run gbl/set-gbl.p
      (input false                  /* p-auto        */
      ,input buf_user-account.user-id /* p-user-id     */
      ,input p-user-password        /* p-user-passwd */
      ) no-error .
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при установке глобальных переменных" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      return .
   end.

   { gbl/conf-rd.i
      "'lcns-lim':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      yes
      conf-par
      par-type
      no-error
   }
   if error-status :error
   then do:
      return. /* --->>>--- */
   end.
   if par-type <> {&type-date}
   then do:
      message
         "Неправильный тип параметра lcns-lim (должно быть date)."
         view-as alert-box error.
      return. /* --->>>--- */
   end.

   if date (conf-par) <> ?
   then do:
      /* ограничение срока лицензии включено */
      run cur-time in this-procedure
         (output v-today
         ,output v-time
         ).
      define variable v-license-left-day as integer   no-undo .
      assign
         v-license-left-day = date (conf-par) - v-today
      .
      if v-license-left-day <= 15
      then do:
         message
         "Срок действия лицензии истекает" date (conf-par) skip
         substitute("Осталось &1 дней", v-license-left-day) skip
         view-as alert-box error.
      end.
      if v-license-left-day < 0
      then do:
         message
         "Срок действия лицензии закончился" date (conf-par) skip
         "Вход в систему невозможен" skip
         view-as alert-box error.
         return . /* --->>>--- */
      end.
   end.

   { gbl/conf-rd.i
      "'is-thpos':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      yes
      conf-par
      par-type
      no-error
   }
   if error-status :error
   then do:
      return. /* --->>>--- */
   end.
   if par-type <> {&type-log}
   then do:
      message
         "Неправильный тип параметра is-thpos (должно быть logical)."
         view-as alert-box error .
      return. /* --->>>--- */
   end.
   IF NOT LOGICAL(conf-par)
   THEN  DO:
      message
         "В данной конфигурации запрещена работа с кассами IBS TH POS"
         skip
      view-as alert-box information.
      return.
   END.


   /* принудительная инициализация некоторых особо важных сиквенсов
   if current-value (s-bcgb-code, {&db-name_schema}) < 100000
   then do:
      assign
         current-value (s-bcgb-code, {&db-name_schema}) = 100000
      .
   end.
   if current-value (s-sclc-code, {&db-name_schema}) < 100
   then do:
      assign
         current-value (s-sclc-code, {&db-name_schema}) = 100
      .
   end.
   if current-value (s-scgb-code, {&db-name_schema}) < 100
   then do:
      assign
         current-value (s-scgb-code, {&db-name_schema}) = 100
      .
   end.
   if current-value (s-news-ord, {&db-name_schema}) < 0
   then do:
      assign
         current-value (s-news-ord, {&db-name_schema}) = 0
      .
   end.
   */
   define buffer buf_cd-events      for ub.cd-events .
   define variable v-version    as integer      no-undo.

   FIND LAST buf_cd-events NO-LOCK NO-ERROR.
   IF AVAILABLE buf_cd-events
   THEN DO:
      ASSIGN
         v-version = buf_cd-events.version
      .
      RELEASE buf_cd-events.
   END.
   ELSE DO:
      ASSIGN
         v-version = 0
      .
   END.

   run utl/cdevload.p ( INPUT parparentproc
                      , input-output v-version
                      ) .

   /*
   run gbl/update.p no-error .
   if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      return .
   end.
   */

   /*
   run adm/infdbnws.p no-error .
   if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при анализе/записи информации о БД" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      return .
   end.
   */



   run gbl/maincash.w
      ( INPUT parparentproc
      , input v-computer-process-pid
      , input buf_user-account.user-id
      , input v-cash-num
      , input v-emul
      ) no-error .
   if error-status :error
   then do:
      message
         "Ошибка вызова основного окна системы" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error.
   end.

end.





&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE  {&FRAME-NAME}
procedure mainmenu_getcntxt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   define output parameter p-db-num as integer              no-undo.
   define output parameter p-user-id as character           no-undo.
   define output parameter p-cntxt-level as character       no-undo.
   define output parameter p-cntxt-host-code-obj as integer no-undo.
   define output parameter p-cntxt-obj-type as character    no-undo.
   define output parameter p-cntxt-obj-code as integer      no-undo.
   define output parameter p-cntxt-db-num-obj as integer    no-undo.
   define output parameter p-cntxt-is-admin as logical      no-undo.

   do
   on error undo, return error
   :
      assign
         p-db-num              = v-cntxt-db-num
         p-user-id             = v-cntxt-userid
         p-cntxt-level         = v-cntxt-level
         p-cntxt-host-code-obj = v-cntxt-host-code-obj
         p-cntxt-obj-type      = v-cntxt-obj-type
         p-cntxt-obj-code      = v-cntxt-obj-code
         p-cntxt-db-num-obj    = v-cntxt-db-num-obj
         p-cntxt-is-admin      = v-cntxt-is-admin
      .

   end. /* do on error */
end procedure. /* get-context */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE  {&FRAME-NAME}
procedure init-cntxt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   define variable v-login               as character    no-undo.

   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   define buffer buf_clients     for ub.clients .

   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            v-cntxt-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num     = v-cntxt-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF NOT AVAILABLE buf_user-login
         THEN DO:
            message
               "Не найден логин" v-login
               skip "для БД"     v-cntxt-db-num
            view-as alert-box information.
            QUIT.
         END.
         assign
            v-cntxt-userid = buf_user-login.user-id
         .

         FIND FIRST buf_clients
              WHERE buf_clients.obj-type = {&shop}
                AND buf_clients.obj-code = v-obj-code
              no-lock
              no-error
              .
         IF NOT AVAILABLE buf_clients
         THEN DO:
            message
               "Не найден магазин №" v-obj-code
               skip
            view-as alert-box information.
            QUIT.
         END.

         assign
            v-cntxt-host-code-obj = buf_clients.host-code
            v-cntxt-obj-type      = buf_clients.obj-type
            v-cntxt-obj-code      = buf_clients.obj-code
            v-cntxt-db-num-obj    = buf_clients.db-num
            v-cntxt-level         = {&cntxt-object}
            v-cntxt-is-admin      = FALSE
         .

   end. /* do on error */
end procedure. /* get-context */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
PROCEDURE get-quest-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-quest-print as logical no-undo .

  do
  on error undo, return error
  :
    assign
      p-quest-print = no
    .
  end.

END PROCEDURE.
