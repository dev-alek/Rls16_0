block-level on error undo, throw.
/*

$Revision: 20b73597f255, 21, test $
$Author: SKiryxin $
$Date: Wed Mar 05 15:13:08 2014 +0300 $
$Workfile: r-exp-sl.p $
$Archive: rep/r-exp-sl.p $

Отчет для Nielsen запуск из интерфейса

Автор: Белоусов Илья Александрович
Дата создания: 04/13/09
Author: Ilia Belousov
Creation date: 04/13/09

*/

{ rep/exp-sl.i   }

define input parameter p-date          as date             no-undo.
define input parameter p-ftp-address   as character        no-undo.
define input parameter p-ftp-path      as character        no-undo.
define input parameter p-ftp-target-dir as character        no-undo.
define input parameter p-login         as character        no-undo.
define input parameter p-password      as character        no-undo.
define input parameter p-name          as character        no-undo.
define input parameter p-log-handle    as handle no-undo .
/*define input parameter p-visible       as logical          no-undo.*/
define input parameter table   FOR tt-obj.

define variable vss-revision    as character no-undo init "$Revision: 20b73597f255, 21, test $":U .
define variable vss-author      as character no-undo init "$Author: SKiryxin $":U .
define variable vss-date        as character no-undo init "$Date: Wed Mar 05 15:13:08 2014 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-exp-sl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-exp-sl.p $":U .
define variable vss-description as character no-undo init "Отчет для Nielsen запуск из интерфейса".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/auto-def.i    }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ trg/factord.i  }
{ gbl/ftp-df.i }



DEFINE temp-table tt-line no-undo
    field   obj-code    as integer
    field   obj-type    as character
    field   grp-name    as character
    field   grp-code    as integer
    field   prod-name   as character
    field   b-code      as integer
    field   src-code    as character
    field   gds-name    as character
    field   gds-code    as integer
    field   qnty        as decimal
    field   summ        as decimal

    INDEX   pi          IS PRIMARY UNIQUE
            obj-code
            obj-type
            src-code
            b-code.

define stream out-stream.
define stream lst-out.
define stream StreamLog.

define buffer buf_tt-line        for tt-line .
define buffer buf_chk-doc  for ub.chk-doc.
define buffer buf_chk-gds  for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods          for ub.goods .
define buffer buf_producer for ub.clients.
define buffer buf_prod-bc        for ub.prod-bc .


do
on error undo, return error
:
   define variable v-begin-date        as date        no-undo .
   define variable v-end-date          as date        no-undo .
   define variable v-begin-date0       as date        no-undo .
   define variable v-end-date0         as date        no-undo .
   define variable v-par-val           as character   no-undo .
   define variable v-par-type          as character   no-undo .
/*   define variable v-message           as character   no-undo .*/
   define variable v-file-name         as character   no-undo . /* Путь к отчету */
   define variable v-file-name-mapping as character   no-undo . /* Путь к файлу mapping */
   define variable v-file-name-mapping-new as character   no-undo . /* Путь к файлу mapping */
   define variable v-fmt               as character   no-undo .
   define variable v-weekday-today     as integer     no-undo .
   define variable v-b-code            as integer     no-undo .
   define variable v-bar               as character   no-undo .
   define variable v-prod-name         as character   no-undo .
   define variable v-gds-code          as integer     no-undo .   
   define variable v-fact-order-start  as decimal     no-undo .
   define variable v-fact-order-end    as decimal     no-undo .
   define variable v-empty-1           as decimal     no-undo .
   define variable v-empty-2           as decimal     no-undo .
   define variable v-gds-name          as character   no-undo .
   define variable v-grp-code          as integer     no-undo .
   define variable v-counter           as integer     no-undo .
   define variable v-label             as character   no-undo .
   define variable v-archive-ok as logical      no-undo.
   define variable v-can-print  as logical      no-undo.
   define variable v-comment    as character    no-undo.
   define variable v-grp-name as character no-undo. 

   &scop display-message    run write-log-and-file in p-log-handle (  ~
         input 1                                                      ~
         , input log-file-name                                          ~
         , input 1                                                      ~
         , input ~{&my-message~})

   define frame info
      v-label        label "Этап" format "x(16)" skip
      v-counter      label "Записей" format ">>>,>>>,>>9" skip
      with view-as dialog-box side-labels 1 columns three-d title "Формирование отчета"
   .
   assign
      log-file-name = "Rep_Nielsen.log"
   .

   IF p-date = ?
   THEN DO:
      assign
         v-weekday-today = WEEKDAY(TODAY)
         v-begin-date    = TODAY - v-weekday-today - 5
         v-end-date      = TODAY - v-weekday-today + 1
         v-begin-date0   = v-begin-date
         v-end-date0     = v-end-date
      .
   END.
   ELSE DO:
      assign
         v-weekday-today = WEEKDAY(p-date)
         v-begin-date    = p-date - v-weekday-today - 5
         v-end-date      = p-date - v-weekday-today + 1
         v-end-date0     = v-end-date
         v-begin-date0    = v-begin-date
      .
   END.

/*   run day-begin-fact-order IN THIS-PROCEDURE   ( INPUT v-begin-date0      */
/*                                                , OUTPUT v-fact-order-start*/
/*                                                ) .                        */
/*   run day-begin-fact-order IN THIS-PROCEDURE   ( INPUT v-end-date0 + 1    */
/*                                                , OUTPUT v-fact-order-end  */
/*                                                ) .                        */

   /* Подготовка списка товаров и бар-кодов*/
   
   v-file-name-mapping = "mapping".

   output stream out-stream to value(v-file-name-mapping + ".txt") .
   put stream out-stream unformatted
   "Gds-Code"   {&tabulation}
   "Bar-Code" {&tabulation}
   "Qnty" {&new-line}.

/*  output stream StreamLog to value(log-file-name) append.*/

  &scop my-message substitute("Создание mapping файла.")
  {&display-message}.
      
   for each buf_goods where buf_goods.stts = 0 no-lock:

       for each buf_bar-code where buf_bar-code.gds-code = buf_goods.gds-code 
                               and buf_bar-code.part-code = "" 
                               and buf_bar-code.in-code = "" no-lock:
           
           if buf_bar-code.stts_ <> 0 then next. /* Уберём удаленные */

           for each buf_prod-bc where buf_prod-bc.b-code = buf_bar-code.b-code
                                  and buf_prod-bc.b-str NE string(buf_bar-code.b-code) 
                                  and buf_prod-bc.bc-on = yes no-lock:
           
           put stream out-stream unformatted
                buf_bar-code.gds-code {&tabulation}
                buf_goods.qnty-cart {&tabulation}
                buf_prod-bc.b-str {&new-line}.
           
           end. /* for each buf_prod-bc */
           
           if buf_bar-code.b-code = buf_bar-code.gds-code then next. /* Если совпадает, то не записываем */

                put stream out-stream unformatted
                    buf_bar-code.gds-code {&tabulation}
                buf_goods.qnty-cart {&tabulation}
                    buf_bar-code.b-code     {&new-line}.
                    
       end. /* for each buf_bar-code */

   end. /* for each goods */

   &scop my-message substitute("Mapping файл создан успешно.")
   {&display-message}.

   output stream out-stream close.

   /* проверка архивов */

   tt-obj_arh_loop:
   FOR EACH tt-obj exclusive-lock
       BREAK by tt-obj.host-code
   :
      &scop my-message SUBSTITUTE("Проверка и расчет архивов по объекту: &1 &2.", tt-obj.obj-type, tt-obj.obj-code)
      {&display-message}.
      assign
      v-begin-date = v-begin-date0
      v-end-date   = v-end-date0
      .
      run rep/chk-ahz.p (
         input        tt-obj.obj-type
         , input        tt-obj.obj-code
         , input        yes                      /*p-verify-detail */
         , input        yes /*p-verify-arh*/
         , input        no  /*p-verify-ahsp*/
         , input        no  /*p-verify-aht*/
         , input        no                       /* p-check-act         */
         , input        0                        /* p-check-act-db-num  */
         , input        "":U                     /* p-check-act-user-id */
         , input-output v-begin-date
         , input-output v-end-date
         , output       v-archive-ok
         , output       v-comment
         , output       v-can-print
      ) no-error .
      if error-status :error
      or v-can-print  = false
      or (v-can-print  = true
      and (v-begin-date = ?
      or v-end-date = ?
      or v-end-date < v-end-date0
      ))
      then do:
         &scop my-message  v-comment
         {&display-message}.
        /* RETURN. */
        error-status :error = no.
        delete tt-obj.
        next tt-obj_arh_loop.
      end. /*if error-status:error then do:*/
   END.

   for each tt-obj no-lock
   BREAK by tt-obj.host-code
   :

      /* файл для выгрузки по фирме */
      IF FIRST-OF (tt-obj.host-code)
      THEN DO:
            ASSIGN

               v-file-name =  p-name
                           + STRING(tt-obj.host-code, "99999")
                           + "_"
                           + SUBSTRING(STRING(YEAR(v-begin-date), "9999"),3,2)
                           + STRING(MONTH(v-begin-date), "99")
                           + STRING(DAY(v-begin-date), "99")
                           + SUBSTRING(STRING(YEAR(v-end-date), "9999"),3,2)
                           + STRING(MONTH(v-end-date), "99")
                           + STRING(DAY(v-end-date), "99")
            v-file-name-mapping-new = p-name
                       + string(tt-obj.host-code, "99999")
                       + "_mapping_"
                       + substring(string(year(v-begin-date), "9999"),3,2)
                       + string(month(v-begin-date), "99")
                       + string(day(v-begin-date), "99")
                       + substring(string(year(v-end-date), "9999"),3,2)
                       + string(month(v-end-date), "99")
                       + string(day(v-end-date), "99").
               
      END. /* FIRST-OF */

      &scop my-message substitute("Выгрузка объект: &1 &2", tt-obj.obj-type, tt-obj.obj-code)
      {&display-message}.

           /* Постоянно переименовываем и подкладываем файл мэппинга в архив */

           os-rename value(v-file-name-mapping + ".txt":U) value(v-file-name-mapping-new + ".txt":U).
           v-file-name-mapping = v-file-name-mapping-new.

/*      view frame info.*/

      for each buf_chk-doc no-lock                                                         /* Фильтруем чеки по объектам, датам и типам чеков */
        where buf_chk-doc.obj-type = tt-obj.obj-type 
          and buf_chk-doc.obj-code = tt-obj.obj-code
          and buf_chk-doc.chk-date <= v-end-date
          and buf_chk-doc.chk-date >= v-begin-date
          and lookup(string(buf_chk-doc.chk-type), {&sale-out-receipt-codes} + {&sale-in-receipt-codes}) > 0:

         for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code:   /* Смотрим линии выбранного чека */

             find first  buf_tt-line                                                       /* Проверим, есть ли в таблице этот бар код */
                   where buf_tt-line.obj-code = buf_chk-doc.obj-code
                   and   buf_tt-line.obj-type = buf_chk-doc.obj-type
                   and   buf_tt-line.src-code = buf_chk-gds.src-code
                   and   buf_tt-line.b-code   = buf_chk-gds.b-code no-error.

             if not available buf_tt-line then do:
            CREATE buf_tt-line.
            ASSIGN
                   buf_tt-line.obj-code  = buf_chk-doc.obj-code
                   buf_tt-line.obj-type  = buf_chk-doc.obj-type
                   buf_tt-line.src-code  = buf_chk-gds.src-code
                   buf_tt-line.b-code    = buf_chk-gds.b-code
                   buf_tt-line.summ      = (if (lookup(string(buf_chk-doc.chk-type), {&sale-out-receipt-codes}) > 0) then buf_chk-gds.sum-base else buf_chk-gds.sum-base * (-1))
                   buf_tt-line.qnty      = (if (lookup(string(buf_chk-doc.chk-type), {&sale-out-receipt-codes}) > 0) then buf_chk-gds.doc-qnty else buf_chk-gds.doc-qnty * (-1)).
             end. /* if not available tt-line */

             else do:
            assign
                   buf_tt-line.summ = buf_tt-line.summ + (if (lookup(string(buf_chk-doc.chk-type), {&sale-out-receipt-codes}) > 0) then buf_chk-gds.sum-base else buf_chk-gds.sum-base * (-1))
                   buf_tt-line.qnty = buf_tt-line.qnty + (if (lookup(string(buf_chk-doc.chk-type), {&sale-out-receipt-codes}) > 0) then buf_chk-gds.doc-qnty else buf_chk-gds.doc-qnty * (-1)).
             end. /* else do */

         end. /*  for each buf_chk-gds */

     end. /* for each buf_chk-doc */

      if last-of (tt-obj.host-code) then do:

         /* Выгрузка в файл */
         output stream out-stream TO VALUE(v-file-name + ".txt") .
            put stream out-stream unformatted
               "ShopCode"     {&tabulation}
               "GrpName"      {&tabulation}
               "GrpCode"      {&tabulation}
               "Manufacture"  {&tabulation}
               "Src-Code"     {&tabulation}
               "Code"         {&tabulation}
               "ProductName"  {&tabulation}
               "SalesValue"   {&tabulation}
               "SalesItem"    {&new-line}.

/*         _line:*/
         for each buf_tt-line break by buf_tt-line.b-code:

/*            if  buf_tt-line.qnty = 0*/
/*            or  buf_tt-line.summ = 0*/
/*            then next _line.        */

            if first-of (buf_tt-line.b-code) then do:

                find first buf_bar-code where buf_bar-code.b-code = buf_tt-line.b-code no-lock no-error.

                find first buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock no-error.

                find first buf_producer where buf_producer.obj-type = buf_goods.prod-type
                                          and buf_producer.obj-code = buf_goods.prod-code no-lock no-error.

               ASSIGN
                v-grp-name = buf_goods.grp-name
                v-grp-code = buf_goods.grp-code
                v-gds-name = buf_goods.gds-name
                v-prod-name = buf_producer.obj-name 
                v-gds-code = buf_goods.gds-code no-error.
                
            end. /* if first-of (buf_tt-line.b-code) */
            
            assign
            buf_tt-line.grp-name  = v-grp-name
            buf_tt-line.grp-code  = v-grp-code
            buf_tt-line.gds-name  = v-gds-name
            buf_tt-line.prod-name = v-prod-name
            buf_tt-line.gds-code  = v-gds-code no-error.
            
            put stream out-stream unformatted
               buf_tt-line.obj-code  {&tabulation}
               trim(buf_tt-line.grp-name) {&tabulation}
               buf_tt-line.grp-code  {&tabulation}
               trim(buf_tt-line.prod-name) {&tabulation}
               buf_tt-line.gds-code {&tabulation}
               trim(buf_tt-line.src-code) {&tabulation}
               trim(buf_tt-line.gds-name) {&tabulation}
               trim(string(buf_tt-line.summ,"->>>>>>9.99")) {&tabulation}
               trim(string(buf_tt-line.qnty,"->>>>>>9.999")) {&new-line}.
         END.

         output stream out-stream close.
         /* запаковка*/
         run pack-file in this-procedure (input v-file-name, input v-file-name-mapping-new) no-error.
         if error-status:error
         then do:
            &scop my-message SUBSTITUTE("Ошибка упаковки:&1", RETURN-VALUE)
            {&display-message}.
            empty temp-table buf_tt-line.
            error-status :error = no.
/*            return error v-message.*/
         end.
         /* отправка по FTP */
         IF p-ftp-address <> "":U
         THEN DO:
            RUN ftp-send IN THIS-PROCEDURE (INPUT (v-file-name  + ".zip")) NO-ERROR .
            if error-status:error
            then do:
                  &scop my-message SUBSTITUTE("Ошибка отправки по FTP: &1", RETURN-VALUE)
                  {&display-message}.
            end.
            ELSE DO:
               os-delete value( v-file-name  + ".zip" ) .
            END.
         END.

         /* очистка для следующей фирмы */
         empty temp-table buf_tt-line.
      end. /* if last-of */
   END. /* EACH tt-obj */
   
   os-delete value( STRING(v-file-name-mapping-new + ".txt":U)).
   
   hide frame info.
   &scop my-message "Выгрузка закончена"
   {&display-message}.

end.

procedure pack-file :
  define input parameter  p-file-name as character  no-undo. /* Путь к файлу отчета (без .txt) */
  define input parameter  p-file-name-mapping as character no-undo. /* путь к файлу с mapping */

  define variable v-arc             as character no-undo .
  define variable v-txt             as character no-undo .
  define variable v-list-file-name  as character no-undo .
  define variable v-arc-file-name   as character no-undo .

do
on error undo, return error return-value
:
   v-arc-file-name  = p-file-name + ".zip":U.
   /* Есть ли архиватор  */
   v-arc = search( "exe/7za.exe" ).
   if v-arc = ? then do:
      return error("Не найдена программа 7za.exe, невозможно упаковать файлы в архив.").
   end.

   if search( v-arc-file-name ) <> ? then do:
      return error substitute ( "Файл &1 уже существует. Создание архива невозможно." , v-arc-file-name ).
   end.

   run gbl/_tmpfile.p ( "lst":u , ".txt":u , output v-list-file-name ).

   output stream lst-out to value(v-list-file-name).
   put stream lst-out unformatted (p-file-name + ".txt":U) skip.
   put stream lst-out unformatted (p-file-name-mapping + ".txt":U) skip.
   output stream lst-out close.

   assign
      v-txt = substitute( "&1 a -tzip &2 @&3"
                        , v-arc
                        , v-arc-file-name
                        , v-list-file-name).

   os-command silent value ( v-txt ) .

   os-delete value( v-list-file-name ) .
   os-delete value( STRING(p-file-name + ".txt":U )) .

end.


end procedure. /* pack-file */


/*==========================================================================*/
procedure ftp-send :
define input parameter p-file-name as character        no-undo.
define variable v-parameter    as character    no-undo.
do
on error undo, return error
:
        /*Перед передачей параметра чистим ip-адрес от лишних символов*/
        p-ftp-address = trim(trim(replace(p-ftp-address,'ftp:',""),{&slash-char}),{&back-slash-char}).
        /*Передача параметров*/
        v-parameter = p-ftp-address + {&delim-par} +
                      p-login + {&delim-par} +
                      p-password + {&delim-par} +
                      string({&INTERNET_FLAG_PASSIVE}) + {&delim-par} + ''
                       +
                      p-file-name  + {&delim-par} +
                      /*p-ftp-target-dir + {&slash-char} +*/ p-file-name + {&delim-par} +
                      string(no) + {&delim-par} +
                      log-file-name.

        run gbl/ftp-put.p   ( input this-procedure:handle
                          ,input this-procedure:handle
                        , input p-log-handle
                        , input v-parameter
                        ) no-error.


end. /* do on error */
end procedure. /* ftp-send */