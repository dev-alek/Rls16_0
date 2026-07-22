block-level on error undo, throw.
 /*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exp-kanp.p $
$Archive: cus/exp-kanp.p $

Экспорт накладных Заказчика "Кан-Ру"

Автор: Житкевич Александр
Дата создания: 27/09/11
Author: Zhitkevich
Creation date: 27/09/11
*/





   define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
   define variable vss-author      as character no-undo init "$Author: expertek $":U .
   define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
   define variable vss-workfile    as character no-undo init "$Workfile: exp-kanp.p $":U .
   define variable vss-archive     as character no-undo init "$Archive: cus/exp-kanp.p $":U .
   define variable vss-description as character no-undo init "Экспорт текущих остатков ".


   define input parameter parparentproc    as widget-handle no-undo .
   define input parameter p-parent-handle  as widget-handle no-undo .
   define input parameter p-log-handle  as handle no-undo .
   define input parameter p-cre-db-num     as integer      no-undo .
   define input parameter p-task-type      as character    no-undo.
   define input parameter p-task-num       as integer      no-undo.
   define input parameter p-db-num         as integer      no-undo .

 define variable v-counter                   as integer      no-undo.
  define variable v-param-list                as character    no-undo.
  define variable v-param-type                as character    no-undo.
  define variable v-node-code   like gds-prt.upper-code       no-undo.
  define variable v-prt-name    as character no-undo .  .
  define variable v-val-attr as char no-undo.
  define variable v-attr-type as char no-undo.


  /* Пути выгрузок */
   define var v-impstr as char.   /* путь расх внутренего */
   define var v-impstr-2 as char. /* путь удал наклд  */
   define var v-impstr-3 as char.
   define var v-impstr-4 as char. /*путь файла соответствий*/
   define var v-impstr-5 as char. /*путь выгрузки данных по внешним расходам*/
   define var v-impstr-6 as char.
   define var v-impstr-9 as char.

   /* Строка выгрузки v-dnow дата выгрузки используется для подстановки даты в имя текст. файла выгрузки */
   define stream v-s1.
   define variable v-dnow as char no-undo.
   define variable st as char no-undo.
   define variable st2 as char no-undo.
   define variable dateb as date no-undo.
   define variable dateend as date no-undo.
   define variable kol-vo as int no-undo.
   define variable t1 as char no-undo.
   define variable v-task-num    as integer      no-undo.
   define variable v-obj-list    as character    no-undo.
   define variable v-char-status as char no-undo.
   define variable i as integer no-undo.
   define variable v-dd as date no-undo.  /* сменная дата для подстановки в документ */
   define variable v-email as char no-undo.
   define variable p-subject as char no-undo.
   define variable p-text-err as char no-undo.
   define variable p-attach-files2 as char no-undo.
   define variable v-emailpath as char no-undo.
   define variable v-count as integer.
   define variable e-mail2 as char.
   define variable e-mail3 as char.

   define var art as char no-undo.
   define var v-setrun as int no-undo. /* переменная запуска пересорт и выгр кассиров */
   define var v-paramdop as char no-undo.
   define var v-pref as char no-undo.

   define variable varinv-prs     as character no-undo.
   define variable varinv-prstype as character no-undo.


   define buffer buf_schedule for ub.schedule.
   define buffer buf_schedule-attr for ub.schedule-attr.
   define buffer buf_trn-doc for ub.trn-doc.
   define buffer buf_c-trn-doc for ub.c-trn-doc.
   define buffer buf_gds-dtl for gds-dtl.
   define buffer buf_gds-prt for gds-prt.
   define buffer buf_doc-line      for ub.doc-line .
   define buffer buf_clients  for ub.clients.
   define buffer buf_person   for ub.person.
   define buffer buf_staff    for ub.staff.
   define buffer buf_goods    for ub.goods.


    /* буфер для временной таблицы   outs внешн систем  test1 - тоесть если склад то W если магазин то R */
  DEFINE TEMP-TABLE imptable
     FIELD obj-type LIKE trn-doc.obj-type
     FIELD obj-code LIKE trn-doc.obj-code
     FIELD st AS CHARACTER FORMAT "x(76)".    /* параметр который будет подставляться */



   { cmp/vssrevis.i }
   { cmp/str-glbl.i }
   { cmp/library.i  }
   { cmp/showinf.i  }
   { gbl/getcntxt.i def }
   { ref/shd-attr.i }
   { bge/doctype.i}
   { gbl/waitfram.i }
   { str/trdcalib.i }
   { gbl/getsect.i  def }

   if p-db-num = 0 and p-task-num = 0 and p-cre-db-num = 0 and entry(1, p-task-type , ";") = "noauto" then
   do:
      dateb = date(entry ( 2, p-task-type , ";")).
      dateend = date(entry (3 , p-task-type , ";")).
      v-impstr = entry ( 4 , p-task-type , ";" ).
      v-impstr-2 = entry ( 5 ,p-task-type , ";" ).
      v-impstr-3 = entry ( 6 , p-task-type , ";" ).
      v-impstr-4 = entry ( 7 , p-task-type , ";" ).
      v-impstr-5 = entry ( 10 , p-task-type , ";" ).
      v-impstr-6 = entry ( 8 , p-task-type , ";" ).
      v-impstr-9 = entry ( 9 , p-task-type , ";" ).
      v-email    = entry ( 2 , p-task-type , "!" ) no-error.

   end.
   else
   do:
      run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , output v-param-list
        , output v-param-type
    ).

        v-impstr = entry ( 1 , v-param-list , "!" ).
        v-impstr-2 = entry ( 2 , v-param-list , "!" ).
        v-impstr-3 = entry ( 3 , v-param-list , "!" ).
        v-impstr-4 = entry ( 4 , v-param-list , "!" ).
        v-impstr-5 = entry ( 8 , v-param-list , "!" ).
        v-impstr-6 = entry ( 5 , v-param-list , "!" ).
        v-impstr-9 = entry ( 6 , v-param-list , "!" ).
        v-email    = entry ( 7 , v-param-list , "!" ) no-error.

        v-dnow = string(today - 1).
        v-dnow =  REPLACE ( v-dnow , "/"  , "." ).

/* В конце имени файла - вставляем расширение ".txt" */
          if v-impstr <> "" then
        assign v-impstr = SUBSTRING(STRING(v-impstr), 1 ,length(v-impstr) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-2 <> "" then
        assign v-impstr-2 = SUBSTRING(STRING(v-impstr-2), 1 ,length(v-impstr-2) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-3 <> "" then
        assign v-impstr-3 = SUBSTRING(STRING(v-impstr-3), 1 ,length(v-impstr-3) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-5 <> "" then
        assign v-impstr-5 = SUBSTRING(STRING(v-impstr-5), 1 ,length(v-impstr-5) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-6 <> "" then
        assign v-impstr-6 = SUBSTRING(STRING(v-impstr-6), 1 ,length(v-impstr-6) - 4 ) + STRING(v-dnow) + ".txt".
          if v-impstr-9 <> "" then
        assign v-impstr-9 = SUBSTRING(STRING(v-impstr-9), 1 ,length(v-impstr-9) - 4 ) + STRING(v-dnow) + ".txt".

             assign  dateb = today - 1
               dateend = today - 1.

   end.

/*Аналогия процедуры.                                                                                                                           */
/*Проверка файла соответствия на ошибки. Если без ошибок, то запись значений во временную таблицу.                                              */
/*Формат файла-соответствия: <ТипОбъектаТН>,<КодОбъектаТН>,<КодОбъектаВыгрузки(пользовательский)> где Разделитель - запятая.                    */
/*Функционал:   1) Предупреждает пользователя о пустом файле соответствия;                                                                      */
/*              2) Пробелы и табудяции в строках - расцениваются как "пустые строки", не вызывающие ошибки;                                     */
/*              3) MESSAGE - показывает номера строк с ошибками (не правильное число параметров, которых всегда должно быть три в одной строке).*/
      do: 
        def var v-file-line-str as character initial "" no-undo. /*строка из открываемого файла*/
        def var v-file-line-str-t   as character    initial "" no-undo.     /*строка из открываемого файла обработанная функцией TRIM*/
        def var v-file-line-num as integer initial 0 no-undo. /*счётчик номера строки (из открываемого файла)*/
        def var v-count-err as integer initial 0 no-undo. /*счётчик ошибочных строк (для послед. отчёта об ошиб)*/
        def var v-complex-err as character initial "" no-undo. /*список ошибок в формате <№строки>,<кол-во параметров>*/
        def var v-err-msg-string as character initial "" no-undo. /*расширенная строка сообщения об ошибке (неправильный формат файла-соответствия)*/
        def var v-sum-parameter as integer initial 0 no-undo. /*кол-во параметров. (Если отличается от трёх, то ошибка)*/
        def var v-flag-err as logical INITIAL false no-undo. /*флаг - есть ли хоть одна ошибка в парам. соответствия*/
        def var v-char-space        as integer      initial 0 no-undo.      /*счётчик строк с одними только пробелами, табуляторами, переводом строки, возвратом каретки - символами "невидимками", располагающих пользователя к ошибкам.*/
        INPUT FROM value(v-impstr-4).
        
            repeat:
                import  unformatted v-file-line-str.
                    v-file-line-num = v-file-line-num + 1.
                    v-file-line-str-t = trim(v-file-line-str). /*На случай, если: В СТРОКЕ ТОЛЬКО ПРОБЕЛЫ И ТАБУЛЯТОРЫ, ПЕРЕВОД СТРОКИ, ВОЗВРАТ КАРЕТКИ, чтобы не считать их параметрами.*/
                    v-sum-parameter = NUM-ENTRIES(v-file-line-str-t, ",").
                    if length(v-file-line-str) <> ? and length(v-file-line-str) >= 0 and v-sum-parameter = 0 then
                        do:
                            v-char-space = v-char-space + 1. /*Суммируем строки с пробелами, табуляторами, переводами строки, возвратом каретки. Потом сравним с счётчиком общего кол-ва строк в файле, дабы вывести сбщ о пустом файле.*/
                        end.

                    case v-sum-parameter:
                        WHEN 0 THEN
                            do:
                                next. /*если встречаем пустую строку, то переходим к след. выборке (Обязательная проверка!)*/
                            end.
                        WHEN 1 THEN /*видим один параметр (вместо трёх) в строке файла соотв. Значит ошибка.*/
                            do:
                                v-complex-err = v-complex-err + string(v-file-line-num)
                                + ", ".
                                v-flag-err = true.
                                v-count-err = v-count-err + 1.
                            end.
                        WHEN 2 THEN /*видим два параметра (вместо трёх) в строке файла соотв. Значит ошибка.*/
                            do:
                                v-complex-err = v-complex-err + string(v-file-line-num)
                                + ", ".
                                v-flag-err = true.
                                v-count-err = v-count-err + 1.
                            end.
                        WHEN 3 THEN /*видим три параметра в строке файла соотв. Значит ошибок нет.*/
                            do:
                                next.
                            end.
                    END CASE.

            end. /*repeat:*/

        if v-file-line-num = 0 or (v-char-space = v-file-line-num and v-flag-err = false) then /*Истина, если файл соответствия - пустой*/
            message
                "Уведомление:" skip
                "В выбранном файле соответствий не задано ни одного параметра." skip
                "В связи с этим, вся ыгрузка будет произведена с форматом по умолчанию."
            view-as alert-box.
        
        v-complex-err = substring(v-complex-err, 1, (length(v-complex-err) - 2)) + ".". /*Собираем перечень строк с ошибками для указания их в СБЩ об ошибках. По выходу из цикла - после последней цифры убираем ", " и вставляем точку.*/
        
        if v-flag-err = true and v-file-line-num > 0 then
                message
                    "Ошибка в заполнении файла соответствий!" skip
                    "Проверьте формат заполнения файла соответствий (обязательно для каждой строки:" skip
                    "   - количество параметров в строке;" skip
                "   - наличие разделителей-запятых;" skip
                "   - в конце файла добавьте пустую строку (без текста))." skip
                "Найдены строки с ошибками (с учёт. пуст. строк): №№ " v-complex-err skip
                    "Итого ошибок = " v-count-err "."
                    
                view-as alert-box error.
                
        INPUT CLOSE.

      if v-flag-err = false then
          do:

      /* запись значений во временную таблицу*/
      INPUT FROM value(v-impstr-4).
      /* <тип объекта>,<код объекта>,<номер для выгрузки> "перевод строки" */
      repeat:
         create imptable.
         IMPORT DELIMITER "," imptable.obj-type imptable.obj-code imptable.st.
              END. /*repeat:*/
              INPUT CLOSE.
      END.

      else
      return. /*if v-flag-err = false. Если флаг = ошибка, то выход из программы для корректировки файла соответствия.*/
  end.

if v-impstr <> "" then
    do:
    assign p-attach-files2 = p-attach-files2 + v-impstr.
    OUTPUT STREAM v-s1 TO value(v-impstr).

    FOR EACH buf_trn-doc
    WHERE  buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} AND  buf_trn-doc.sys-date >= dateb and buf_trn-doc.sys-date <= dateend NO-LOCK
    BY buf_trn-doc.status_ BY buf_trn-doc.doc-code :



         find first imptable no-lock where imptable.obj-type = buf_trn-doc.obj-type and imptable.obj-code = buf_trn-doc.obj-code no-error.
         IF  AVAILABLE imptable THEN
         st = imptable.st.
         else
         do:
         st = "R" + string(buf_trn-doc.obj-code).
         end.

               find first imptable no-lock where imptable.obj-type = buf_trn-doc.cli-type and imptable.obj-code = buf_trn-doc.cli-code no-error.
               IF AVAILABLE imptable then
               st2 = imptable.st.
               else
               do:
               st2 = "R" + string(buf_trn-doc.cli-code).
               end. /* закрытие цикла  IF AVAILABLE imptable then  */
               if st = st2 then  next.


               if buf_trn-doc.status_ = {&fact} and buf_trn-doc.fact-date <> buf_trn-doc.doc-date then
                do:
                 v-char-status = 'o,c'.
                /* v-dd = buf_trn-doc.fact-date. */
                 v-dd = buf_trn-doc.doc-date.
                 end.
               else
               if buf_trn-doc.status_ = {&fact} and buf_trn-doc.fact-date = buf_trn-doc.doc-date then
                 do:
                 v-char-status = 'o,c'.
                 v-dd = buf_trn-doc.doc-date.

                 end.
               else
                   do:
               v-char-status = 'o'.
               v-dd = buf_trn-doc.doc-date.
                   end.

                 do i = 1 to num-entries(v-char-status):

                   if i = 2 then v-dd = buf_trn-doc.fact-date.

                  for each buf_doc-line no-lock where
                  buf_trn-doc.doc-code = buf_doc-line.doc-code :

                       for each gds-dtl no-lock
                       where gds-dtl.prod-type = buf_doc-line.prod-type
                         and gds-dtl.prod-code = buf_doc-line.prod-code
                         and gds-dtl.artic     = buf_doc-line.artic
                         and gds-dtl.doc-code  = buf_doc-line.doc-code
                         :
                         kol-vo = gds-dtl.fact-qnty.

                               find first gds-prt no-lock
                               where gds-prt.node-code = gds-dtl.prt-code no-error
                               .
                               art = gds-dtl.artic.

                               if available (gds-prt) then do:
                                if gds-prt.node-name = {&empty-scale} then next.
                                      else
                                      v-prt-name = gds-prt.f-name.

                             /*  v-prt-name =( if gds-prt.node-name = {&empty-scale} then "-"
                                             else  gds-prt.f-name  ) .  */
                               t1  = "-".
                              if r-index(v-prt-name, "/") > 0 then overlay ( v-prt-name, r-index(v-prt-name, "/"), 1) = t1.

                              /*do while available gds-prt:
                              if available gds-prt
                                then do:
                              assign
                              v-prt-name = "-" + string( gds-prt.node-name /*, "x(10)"*/ ) + v-prt-name
                              .
                              end.
                              assign
                               v-node-code = gds-prt.upper-code
                              .
                              find first gds-prt no-lock
                              where gds-prt.node-code = v-node-code
                                      and gds-prt.root <> yes
                              no-error.
                              end.     /* закрытие цикла  do while available gds-prt:  */
                                                                                                  */
                              end. /* закрытие цикла Available gds-prt */
                              else next.

                   if v-prt-name = "-" or v-prt-name = "" then next.

                  PUT STREAM v-s1 UNFORMATTED "N10;"

                 st2   ";"
                 st    ";"
                 buf_trn-doc.doc-CODE substring(string(year(v-dd)),3,2) st ";"
               /*  year(buf_trn-doc.doc-date) "-" string(month(buf_trn-doc.doc-date),'99') "-" day(buf_trn-doc.doc-date) ";"
                 buf_trn-doc.doc-CODE substring(string(year(buf_trn-doc.doc-date)),3,2) st  ";"     */
                 year(v-dd) "-" string(month(v-dd),'99') "-" string(day(v-dd),'99') ";"
                 buf_trn-doc.doc-CODE substring(string(year(v-dd)),3,2) st  ";"
                 art + '-' +  v-prt-name ";"
                 string(kol-vo)   ";"
                 entry(i,v-char-status)
                 SKIP.



          end.  /* закрытие цикла for each gds-dtl  */

        end.  /* закрытие цикла for each buf_doc-line  */
        end. /*  do i = 1 to num-entries(v-char-status): */



        end.  /* закрытие цикла FOR EACH buf_trn-doc   */



OUTPUT STREAM v-s1 CLOSE.
end.


if v-impstr-2 <> "" then
do:

    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2  + v-impstr-2.
    else
    assign  p-attach-files2 = p-attach-files2 + "," + v-impstr-2.
OUTPUT STREAM v-s1 TO value(v-impstr-2).

     FOR EACH buf_c-trn-doc
      WHERE buf_c-trn-doc.is-del = yes  AND buf_c-trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
          AND  buf_c-trn-doc.sys-date >= dateb and buf_c-trn-doc.sys-date <= dateend    NO-LOCK:

              find first imptable no-lock where imptable.obj-type = buf_c-trn-doc.obj-type
                                   and imptable.obj-code = buf_c-trn-doc.obj-code no-error.

                  IF AVAILABLE imptable THEN
                          st = imptable.st.
                       else
                       do:
                          st = "R" + string(buf_c-trn-doc.obj-code).
                       end.

                   PUT STREAM v-s1 UNFORMATTED "N1E;"
                        st  ";"
                        buf_c-trn-doc.doc-CODE substring(string(year(buf_c-trn-doc.doc-date)),3,2)  st  ";"
                        year(buf_c-trn-doc.doc-date) "-" string(month(buf_c-trn-doc.doc-date),'99') "-" string(day(buf_c-trn-doc.doc-date),'99')
                        SKIP.

        end.  /* закрытие цикла FOR EACH buf_c-trn-doc  */
 OUTPUT STREAM v-s1 CLOSE.
end.

if v-impstr-3 <> "" then
do:
    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2  + v-impstr-3.
    else
    assign  p-attach-files2 = p-attach-files2 + "," + v-impstr-3.
 OUTPUT STREAM v-s1 TO value(v-impstr-3).

       FOR EACH buf_trn-doc WHERE  buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                                   AND  buf_trn-doc.sys-date >= dateb
                                   and buf_trn-doc.sys-date <= dateend and buf_trn-doc.status_ = {&fact}
                                   NO-LOCK
                                    BY buf_trn-doc.status_ BY buf_trn-doc.doc-code :

            find first imptable no-lock where imptable.obj-type = buf_trn-doc.obj-type  /* Добавлено по треб. Заказчика. Выгрузка отчёта в файл "Приход внешний" с дополнительной разбивкой по разным фирмам (наимен. фирм - опред. Заказчик в файле соответствий) Шутилов А. В. */
                                and imptable.obj-code = buf_trn-doc.obj-code no-error.

                IF AVAILABLE imptable then
                    st = imptable.st.
                else
                    do:
                        st = "R00":U.
                    end.


             { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nids} v-val-attr v-attr-type no-error }




                    for each buf_doc-line no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :

                                for each gds-dtl no-lock
                                where gds-dtl.prod-type = buf_doc-line.prod-type
                                and gds-dtl.prod-code = buf_doc-line.prod-code
                                and gds-dtl.artic     = buf_doc-line.artic
                                and gds-dtl.doc-code  = buf_doc-line.doc-code
                                :
                                kol-vo = gds-dtl.fact-qnty.

                                      find first gds-prt no-lock
                                      where gds-prt.node-code = gds-dtl.prt-code  no-error
                                      .

                                      art = gds-dtl.artic.
                                       if available (gds-prt) then do:
                                      if gds-prt.node-name = {&empty-scale} then next.
                                      else
                                      v-prt-name = gds-prt.f-name.
                                    /*  v-prt-name =( if gds-prt.node-name = {&empty-scale} then  "-"
                                             else  gds-prt.f-name  ) . */
                                      t1  = "-".
                                      if r-index(v-prt-name, "/") > 0 then overlay ( v-prt-name, r-index(v-prt-name, "/"), 1) = t1.

                                   /*
                                      do while available gds-prt:
                                      if available gds-prt
                                      then do:
                                      assign
                                      v-prt-name = "-" + string( gds-prt.node-name /*, "x(10)"*/ ) + v-prt-name
                                      .
                                      end.
                                      assign
                                      v-node-code = gds-prt.upper-code
                                      .
                                      find first gds-prt no-lock
                                      where gds-prt.node-code = v-node-code
                                      and gds-prt.root <> yes
                                      no-error.
                                      end.     /* закрытие цикла  do while available gds-prt:  */            */
                                      end. /* закрытие цикла Available gds-prt */
                                      else next.

                                       if v-prt-name = "-" or v-prt-name = "" then next.


      PUT STREAM v-s1 UNFORMATTED "N30;"
/*                 "R00"  ";"*/
                 st  ";"
                 "MD" ";"
                 v-val-attr ";"
                 year(buf_trn-doc.doc-date) "-" string(month(buf_trn-doc.doc-date),'99') "-" string(day(buf_trn-doc.doc-date),'99') ";"
                 art + '-' +  v-prt-name ";"
                 string(kol-vo)  ";"
                 buf_trn-doc.doc-CODE  "MD"  ";"
                 buf_trn-doc.ps
              SKIP.
               end.  /* закрытие цикла  for each gds-dtl no-lock */
         end.  /* закрытие цикла for each buf_doc-line  */
                end.  /* закрытие цикла FOR EACH buf_trn-doc   */

OUTPUT STREAM v-s1 CLOSE.
end.

if v-impstr-5 <> "" then
  do:
    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2 + v-impstr-5.
    else
    assign p-attach-files2 = p-attach-files2 + "," + v-impstr-5.
    OUTPUT STREAM v-s1 TO value(v-impstr-5).

    FOR EACH buf_trn-doc
            WHERE
            buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
            AND  buf_trn-doc.sys-date >= dateb
            AND buf_trn-doc.sys-date <= dateend
            AND buf_trn-doc.status_ = {&fact}
            NO-LOCK
            BY buf_trn-doc.status_ BY buf_trn-doc.doc-code :

        find first imptable no-lock where imptable.obj-type = buf_trn-doc.obj-type
                            and imptable.obj-code = buf_trn-doc.obj-code no-error.
            IF AVAILABLE imptable then
                st = imptable.st.
            else
                do:
                    st = "R00":U.
                end.
                
       for each buf_doc-line no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :

            for each gds-dtl no-lock
            where gds-dtl.prod-type = buf_doc-line.prod-type
            and gds-dtl.prod-code = buf_doc-line.prod-code
            and gds-dtl.artic     = buf_doc-line.artic
            and gds-dtl.doc-code  = buf_doc-line.doc-code
            :
                
            kol-vo = gds-dtl.fact-qnty.

            find first gds-prt no-lock
                where gds-prt.node-code = gds-dtl.prt-code no-error.
              
                art = gds-dtl.artic.
                if available (gds-prt) then do:
                    if gds-prt.node-name = {&empty-scale} then next.
                    else
                        v-prt-name = gds-prt.f-name.
                        t1  = "-".
                    if r-index(v-prt-name, "/") > 0 then overlay ( v-prt-name, r-index(v-prt-name, "/"), 1) = t1.

                end. /* закрытие цикла Available gds-prt */
                else next.

                if v-prt-name = "-" or v-prt-name = "" then next.

            PUT STREAM v-s1 UNFORMATTED "N20;"
                st  ";"
                buf_trn-doc.cli-code ";"
                year(buf_trn-doc.fact-date) "-" string(month(buf_trn-doc.fact-date),'99') "-" string(day(buf_trn-doc.fact-date),'99') ";"               
                art + '-' + v-prt-name ";"
                /* Количество, всегда отрицательное, так как мы отгружаем, отдаем товары.*/
                string(0 - kol-vo) ";"
                buf_trn-doc.doc-CODE
                st ";"
                buf_trn-doc.ps
            SKIP.
            end. /*закрытие цикла for each gds-dtl*/
        end. /*закрытие цикла for each buf_doc-line*/
    end. /*закрытие цикла FOR EACH buf_trn-doc*/
    
  OUTPUT STREAM v-s1 CLOSE.
  end. 

 if v-impstr-6 <> "" then
  do:
    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2  + v-impstr-6.
    else
    assign  p-attach-files2 = p-attach-files2 + "," + v-impstr-6.
    OUTPUT STREAM v-s1 TO value(v-impstr-6).


               FOR EACH buf_staff where buf_staff.date-start <= dateb and buf_staff.role = "C":U  and
                                         (buf_staff.date-end >= dateend) or (string(buf_staff.date-end) = "")  no-lock:
                  for each buf_person NO-LOCK WHERE buf_person.psn-code = buf_staff.psn-code:

/*                       find first buf_clients NO-LOCK*/
                         for each buf_clients
                         WHERE buf_clients.obj-type = {&prs}
                         AND   buf_clients.obj-code = buf_staff.psn-code no-lock:

                         if buf_clients.stts > 0 then next.

                         PUT STREAM v-s1 UNFORMATTED "N40;" ";"
                         buf_staff.staff-code ";"
                         year(today) "-" string(month(today),'99') "-" string(day(today),'99') ";"
                         buf_clients.obj-name " "  buf_person.name1 " " buf_person.name2 ";"
                         buf_person.position
                         skip.

                         end.

           end.
           end.
  OUTPUT STREAM v-s1 CLOSE.

  end.  /*  */

 if v-impstr-9 <> ""  then
    do:
    if p-attach-files2 = "" then assign p-attach-files2 = p-attach-files2  + v-impstr-9.
    else
    assign  p-attach-files2 = p-attach-files2 + "," + v-impstr-9.
           OUTPUT STREAM v-s1 TO value(v-impstr-9).


          FOR EACH buf_trn-doc WHERE ( buf_trn-doc.ext-doc-type = {&TDEDT_Peresort}
                                 or  buf_trn-doc.ext-doc-type = {&TDEDT_Inv} )
                                 AND  buf_trn-doc.fact-date >= dateb
                                 AND  buf_trn-doc.fact-date <= dateend
                                 AND  buf_trn-doc.status_ = {&fact}   NO-LOCK
                            :

        { gbl/conf-rd.i
          "'inv-prs':u"
          "'':u"
          "'':u"
          0
          "'':u"
          "'':u"
          "'':u"
          no
          varinv-prs
          varinv-prstype
          no-error
        }
        if integer(varinv-prs) <> 0  and integer(varinv-prs) = buf_trn-doc.reason-code then do:



          if  buf_trn-doc.ext-doc-type = {&TDEDT_Peresort}  then  v-pref = "WM-EX". else v-pref = "WM-IN".


                            find first imptable no-lock where imptable.obj-type = buf_trn-doc.obj-type and imptable.obj-code = buf_trn-doc.obj-code no-error.
                              IF AVAILABLE imptable then
                               st2 = imptable.st.
                              else
                              do:
                               st2 = "R" + string(buf_trn-doc.obj-code).
                              end. /* закрытие цикла  IF AVAILABLE imptable then  */



               for each buf_doc-line no-lock where
                  buf_trn-doc.doc-code = buf_doc-line.doc-code :




                for each gds-dtl no-lock
                       where gds-dtl.prod-type = buf_doc-line.prod-type
                         and gds-dtl.prod-code = buf_doc-line.prod-code
                         and gds-dtl.artic     = buf_doc-line.artic
                         and gds-dtl.doc-code  = buf_doc-line.doc-code
                         :
                          kol-vo = gds-dtl.doc-qnty.



                               find first gds-prt no-lock
                               where gds-prt.node-code = gds-dtl.prt-code no-error
                               .
                               art = gds-dtl.artic.

                               if available (gds-prt) then do:
                                if gds-prt.node-name = {&empty-scale} then next.
                                      else
                                      v-prt-name = gds-prt.f-name.

                              t1  = "-".
                              if r-index(v-prt-name, "/") > 0 then overlay ( v-prt-name, r-index(v-prt-name, "/"), 1) = t1.
                              end. /* закрытие цикла Available gds-prt */
                              else next.
                              if v-prt-name = "-" or v-prt-name = "" then next.



                           PUT STREAM v-s1 UNFORMATTED "N35;"
                           st2 ";"
                           v-pref buf_trn-doc.doc-code substring(string(year(buf_trn-doc.fact-date)),3,2)  ";"
                           year(buf_trn-doc.fact-date) "-" string(month(buf_trn-doc.fact-date),'99') "-" string(day(buf_trn-doc.fact-date),'99') ";"
                           art + '-' +  v-prt-name ";"
                           kol-vo

                           skip.

                 end. /* закрытие цикла for each gds-dtl*/
                 end.  /* закрытие if integer(varinv-prs) <> 0  and integer(varinv-prs) = bf_trn-doc.reason-code then do */
                 end. /* закрытие for each buf_doc-line no-lock where */
                 end. /* закрытие FOR EACH buf_trn-doc */


            OUTPUT STREAM v-s1 CLOSE.

    end.




       assign e-mail2 = "".
       DO i = 1 TO LENGTH(v-email):
       assign  e-mail3 = entry ( i , v-email , ";" ) no-error.
       if e-mail3 = e-mail2 then next.
       else
       assign e-mail2 = e-mail3.
       if e-mail2 <> "":U then do:
       run gbl/sendmail.p
        ( input e-mail2
        , input "Reports from Trade House"
        , input "Reports from Trade House"
        , input p-attach-files2
        ) no-error .
     end.

     end.