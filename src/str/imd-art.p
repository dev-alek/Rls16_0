block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: imd-art.p $
$Archive: str/imd-art.p $

Драйвер импорта из внешнего текстового файла ( по артиклам поставщика )

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05



*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter frame-title   as char                no-undo. /* заголовок фрейма и журнала */
define input  parameter doc-num       like price-doc.doc-num no-undo. /* номер переоценки для импорта */
define input  parameter e-code        like trn-doc.exch-code no-undo. /* код валюты поставщика для ПН */
define input  parameter pardoc-code   like trn-doc.doc-code  no-undo. /* код создаваемого документа */
define input  parameter parcli-type   like ub.trn-doc.cli-type  no-undo. /*поставщик*/
define input  parameter parcli-code   like ub.trn-doc.cli-code  no-undo.
define input  parameter parhost-code  like ub.trn-doc.host-code no-undo.
define output parameter count-upd     as int init 0          no-undo. /* изменено */
define output parameter counter       as int init 0          no-undo. /* закачано */
define output parameter count-all     as int init 0          no-undo. /* просмотрено */

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: imd-art.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/imd-art.p $":U .
define variable vss-description as character no-undo initial "Драйвер импорта из внешнего текстового файла любой информации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/is-num.i   }
{ str/lib-trn.i  }
{ str/libbcrcn.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log        as logical   no-undo .
define variable g#report-num as integer   no-undo .


{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).

&scop err-source ~
  if msg-line <> count-all then ~
    put stream err unformatted ~
    "------------------------------------------------------------------------------------" {&new-line} ~
    "Строка №: " count-all {&new-line}

&scop wrn-source ~
  if wrn-line <> count-all then ~
    put stream wrn unformatted ~
    "------------------------------------------------------------------------------------" {&new-line} ~
    "Строка №: " count-all {&new-line}

&scop put-source ~
  if msg-line <> count-all then do: ~
    put stream err unformatted ~
    source-string ~
    {&new-line}. ~
    /*msg-line = count-all.*/ ~
  end.
&scop put-source-wrn ~
  if wrn-line <> count-all then do: ~
    put stream wrn unformatted ~
    source-string ~
    {&new-line}. ~
    wrn-line = count-all. ~
  end.

&scop err-put-beg ~
  {&err-source} ~
  " Артикул : "                      goods.artic ~
  " Производитель : "                goods.prod-type ~
  " "                                goods.prod-code ~
  " Код товара : "                   goods.gds-code ~
  " Основная единица измерения : "   goods.unit-base {&new-line}
&scop wrn-put-beg ~
  {&wrn-source} ~
  " Артикул : "                      goods.artic ~
  " Производитель : "                goods.prod-type ~
  " "                                goods.prod-code ~
  " Код товара : "                   goods.gds-code ~
  " Основная единица измерения : "   goods.unit-base {&new-line}

&scop err-put ~
  {&err-put-beg} ~
  {&new-line}. ~
  {&put-source} ~
  put stream err unformatted
&scop wrn-put ~
  {&wrn-put-beg} ~
  {&new-line}. ~
  {&put-source-wrn} ~
  put stream wrn unformatted


&scop err-bar-code ~
  {&err-put-beg} ~
  " Бар-код : "                     bar-code.b-code ~
  " Единица измерения Бар-кода : " bar-code.unit-cli ~
  " коэффициент Бар-кода : "        bar-code.cli-base-rate ~
  {&new-line}. ~
  {&put-source} ~
  put stream err unformatted

&scop wrn-bar-code ~
  {&wrn-put-beg} ~
  " Бар-код : "                    bar-code.b-code ~
  " Единица измерения Бар-кода : " bar-code.unit-cli ~
  " коэффициент Бар-кода : "        bar-code.cli-base-rate ~
  {&new-line}. ~
  {&put-source-wrn} ~
  put stream wrn unformatted

def shared stream inp.
def shared stream err.
def shared stream wrn.
define variable source-string  as char FORMAT "x(232)"      no-undo.
define variable text-string    as char FORMAT "x(232)"      no-undo.
define variable string-type    as char                      no-undo.
define variable i-artic         like goods.artic            no-undo.
define variable i-artic-supp    like cli-gds.cli-art        no-undo.
define variable i-code          like prod-bc.b-str          no-undo.
define variable i-prod-code     like goods.prod-code        no-undo.
define variable i-scale         like gds-prt.f-name         no-undo.
define variable i-prod-bc       like prod-bc.b-str          no-undo.
define variable i-price         like doc-line.price-cli     no-undo.
define variable i-qnty          like doc-line.cli-qnty      no-undo.
define variable i-VAT           like doc-line.VAT-pc        no-undo.
define variable i-SLT           like doc-line.VAT-pc        no-undo.
define variable i-wt-brutto     like doc-line.wt-brutto     no-undo.
define variable i-num-place     like doc-line.num-place     no-undo.
define variable i-d-pcnt        like price-list.d-pcnt      no-undo.
define variable i-unit-cli      like bar-code.unit-cli      no-undo.
define variable i-cli-base-rate like bar-code.cli-base-rate no-undo.
define variable i-bc-on         as   logical                no-undo.
define variable i-cst-code      like parts.cst-code         no-undo.
define variable local-code      like goods.gds-code         no-undo.
define variable size           as dec                       no-undo. /* коэффициент из бар-кода */
define variable scale-level    as int                       no-undo. /* уровень шкалы */
define variable msg-line       as int init 0                no-undo. /* чтоб повторно не выводить номер и исходную строку в сообщениях */
define variable wrn-line       as int init 0                no-undo. /* чтоб повторно не выводить номер и исходную строку в сообщениях */
define variable v-b-code as integer   no-undo .

/* для режима prod-bc */
define variable par-bc-pfx     as char                      no-undo. /* для чтения параметра конфигурации */
define variable par-pl-pfx     as char                      no-undo. /* для чтения параметра конфигурации */
define variable par-bc-frmt    as char                      no-undo. /* для чтения параметра конфигурации */
define variable par-pl-frmt    as char                      no-undo. /* для чтения параметра конфигурации */
define variable par-dif-pdbc   as logical                   no-undo. /* для чтения параметра конфигурации */
define variable par-dpl-off    as logical                   no-undo. /* для чтения параметра конфигурации */

define variable varfile-scan   as logical                   no-undo.
define variable varcode-scan   as char                      no-undo.
define variable varqnty-scan   as char                      no-undo.
define variable varprice-scan  as char                      no-undo.

define variable v-host-code    like sysconf.host-code  no-undo.
define variable v-obj-type     like trn-doc.obj-type   no-undo.
define variable v-obj-code     like trn-doc.obj-code   no-undo.
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
define variable par-type    as character       no-undo.
define variable vararticle-supplier as logical no-undo.
define variable v-num as integer no-undo init 2 .
/* теперь в импорте указывается код ставки налога */
define variable v-vat-pc as decimal   no-undo .
define variable v-slt-pc as decimal   no-undo .
define variable v-today  as date      no-undo .
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.



define buffer other-goods for goods.
define buffer goods-units for units.
define buffer bf_clients  for clients.
define buffer bf_cli-gds  for cli-gds.
define buffer trouble-goods for goods.
run adm/shattri.p (
    input "get":U
    ,input  '':U /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-gds-ref}
    ,input  {&attr-gds-ref_dif-pdbc} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-dif-pdbc
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  '':U /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-gds-ref}
    ,input  {&attr-gds-ref_dpl-off} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-dpl-off
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.

{ str/sclspref.i }

def frame a
counter   label "Закачано"
count-upd label "Изменено"
count-all label "Просмотрено"
with side-labels view-as dialog-box.
view frame a.
    /* отключаем триггер, потому что документ неполноценный */
    on write of trn-doc override do: end.
    clear-imp:
    do transaction
      on error undo clear-imp, return error
      on stop  undo clear-imp, return error :
      find trn-doc where trn-doc.doc-code = pardoc-code no-error.
      if available trn-doc then do:
        run delete-trn-doc in this-procedure .
      end.

      create trn-doc .
      assign
        trn-doc.doc-code  = pardoc-code
        trn-doc.cr-db-num = v-cntxt-db-num
        trn-doc.doc-type  = {&income}
        trn-doc.internal  = no
        trn-doc.exch-code = e-code
      .
      assign
          v-obj-type = store-type
          v-obj-code = store-code
      .
    end.
frame a :title = frame-title.

put stream err unformatted fill ({&new-line}, 2) frame a :title fill ({&new-line}, 3).
assign varfile-scan = ?
       vararticle-supplier = no.
file-line:
repeat on endkey undo, leave :
  disp count-upd counter count-all with frame a.
  do on endkey undo, leave:
    import stream  inp unformatted source-string no-error.
  end.
  if error-status:error then undo, leave.
  if source-string = "" then
    next file-line.
  count-all = count-all + 1.

    assign
      vararticle-supplier = yes.
    if parcli-type = ? and
       parcli-code = ? then do:
      message "Нет данных по поставщику."
      view-as alert-box error.
      return error.
    end.
    else do:
      find first bf_clients where bf_clients.obj-type = parcli-type and
                                  bf_clients.obj-code = parcli-code no-lock no-error.
      if not available bf_clients then do:
        message "Ведем импорт по артикулу поставщика." skip
                "Не найден поставщик " parcli-type parcli-code " ."
        view-as alert-box error.
        return error.
      end.
    end.


  /* разбиваем строку на тип и параметры */
  assign
    string-type     = "ITEM"
    text-string     = source-string
    i-artic-supp    = ""
    i-artic         = ""
    i-code          = ""
    i-prod-code     = 0
    i-scale         = ""
    i-prod-bc       = ""
    i-price         = 0
    i-qnty          = 0
    i-unit-cli      = ""
    i-cli-base-rate = 1
    i-d-pcnt        = 0
    i-VAT           = 0
    i-SLT           = 0
    size            = 1
    i-bc-on         = ?
    i-cst-code      = ""
    i-wt-brutto     = 0
    i-num-place     = 0
    .
  if num-entries (text-string, ";") <> 8 then do:
    {&err-source} "Неправильное число параметров: " string (num-entries (text-string, ";"))
                  " (должно быть 8 ) . Пропускаем." {&new-line}.
    {&put-source}
    next file-line.
  end.

  assign
    i-artic-supp    = trim    (entry (1, text-string, ";"))
    i-prod-bc       = trim    (entry (2, text-string, ";"))
    i-code          = trim    (entry (2, text-string, ";"))
    i-qnty          = decimal (entry (3, text-string, ";"))
    i-price         = decimal (entry (4, text-string, ";"))
    i-cst-code      =          entry (5, text-string, ";")
    i-unit-cli      =          entry (6, text-string, ";")
    i-cli-base-rate = decimal (entry (7, text-string, ";"))
    i-VAT           = decimal (entry (8, text-string, ";"))

/*    i-SLT           = decimal (entry (10, text-string, ";"))*/
/*    i-d-pcnt        = decimal (entry (8, text-string, ";")) */
    .
    if i-unit-cli <> "" then do:
       find first units  where units.unit-name  = i-unit-cli no-lock no-error .
       if error-status :error then do:
         {&wrn-source}        substitute ("Не верная единица измерения поставщика &1 . ",i-unit-cli ) {&new-line}.
         wrn-line = count-all.
         i-unit-cli      = "" .
         i-cli-base-rate = 0  .

       end.
    end.


   if i-cli-base-rate = 0 then i-cli-base-rate = 1.
   assign i-bc-on = yes.
  /* проверяем корректность параметров */
  if i-artic-supp = "" then do:
    {&err-source} "Пустой артикул поставщика. Пропускаем." {&new-line}.
    {&put-source}
    next file-line.
  end.
  if i-qnty = 0 then do:
    {&err-source} "Пустое поле количество. Пропускаем." {&new-line}.
    {&put-source}
    next file-line.
  end.
  if i-price = 0 then do:
    {&err-source} "Пустое поле цена. Пропускаем." {&new-line}.
    {&put-source}
    next file-line.
  end.


if decimal(i-code) <> 0 then do:
   find first bar-code no-lock where bar-code.b-code = int(i-code) no-error .
end.

define variable v-gds-code as integer   no-undo .
   /* есть или нет арт поставщика  */
      find first bf_cli-gds where bf_cli-gds.cli-type  = parcli-type  and
                                  bf_cli-gds.cli-code  = parcli-code  and
                                  bf_cli-gds.host-code = parhost-code and
                                  bf_cli-gds.cli-art   = i-artic-supp no-lock no-error.
      if not available bf_cli-gds then do:
         {&wrn-source}        substitute ("Не найден артикул поставщика &1 по фирме &2 для поставщика &3 &4. ", i-artic-supp, parhost-code, parcli-type, parcli-code) {&new-line}.
         wrn-line = count-all.
         run find-goods (output v-gds-code) .
         find first goods no-lock where goods.gds-code = v-gds-code no-error .
         if not error-status :error then do:
            {&wrn-put} substitute ("Прошла идентификация товара по бар-коду &1 . ", i-code) {&new-line}.
            run add-cli-gds no-error .
            if error-status :error then
               next file-line.
         end.
         else do:
                run gbl/d-askw.w
                (input "Вопрос" /* Заголовок окна */
                ,input "По артиклу поставшика <" + i-artic-supp + ">, по фирме " + string (parHost-code) + " не найдено товара." + {&new-line} /* Общее сообщение */
                  + "Ваши действия:" + {&new-line}
                ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                            /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                            /* второй символ - разделитель атрибутов в описании кнопок */
                ,input "Пропустить|Выбор" /* список названий кнопок  */
                                                /* каждая кнопка может иметь необязательный */
                                                /* список атрибутов, влияющих на поведение кнопки */
                ,input "Артикул <" + i-artic-supp + "> не будет закачен|" /* список описаний кнопок */
                    + "Предлагается справочник товаров, в нем надо выбрать товар , к которому припишется артикул поставщика <"  + i-artic-supp + ">"
                ,input 2 /* значение возвращаемое при нажатии enter */
                ,input 1 /* значение возвращаемое при нажатии escape */
                ,output v-num /* выбор пользователя */
                ).
              if v-num = 1 then do:
                {&err-source} "Не удалось определить товар. Пропускаем." {&new-line}.
                {&put-source}
                next file-line.
              end.
              else do:
              run new-art-supp in this-procedure  (1) no-error .
                  if error-status :error then do:
                      {&err-source} "Не удалось определить товар. Пропускаем." {&new-line}.
                      {&put-source}
                      next file-line.
                  end.
              end.
         end.
      end.


/* есть и не один арт поставщика  */
  find  bf_cli-gds where bf_cli-gds.cli-type  = parcli-type  and
                         bf_cli-gds.cli-code  = parcli-code  and
                         bf_cli-gds.host-code = parhost-code and
                         bf_cli-gds.cli-art   = i-artic-supp no-lock no-error.
  if available bf_cli-gds then do:
      assign
        i-artic     = bf_cli-gds.artic
        i-prod-code = bf_cli-gds.prod-code
        .

  end.
  else do:
        {&wrn-source} substitute ("По артикулу поставщика &1 по фирме &2 для поставщика &3 &4 связан с несколькими товарами .", i-artic-supp, parhost-code, parcli-type, parcli-code) {&new-line}.
        wrn-line = count-all.
  /*****/
        run gbl/d-askw.w
        (input "Вопрос" /* Заголовок окна */
        ,input "По артиклу поставшика <" + i-artic-supp + ">, по фирме " + string (parHost-code) + " найдено несколько товаров." + {&new-line} /* Общее сообщение */
          + "Ваши действия:" + {&new-line}
        ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                    /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                    /* второй символ - разделитель атрибутов в описании кнопок */
        ,input "Пропустить|Выбор" /* список названий кнопок  */
                                        /* каждая кнопка может иметь необязательный */
                                        /* список атрибутов, влияющих на поведение кнопки */
        ,input "Артикул <" + i-artic-supp + "> не будет закачен|" /* список описаний кнопок */
            + "Предлагается список товаров, в нем надо выбрать товар , который будет закачен в ПН"
        ,input 2 /* значение возвращаемое при нажатии enter */
        ,input 1 /* значение возвращаемое при нажатии escape */
        ,output v-num /* выбор пользователя */
        ).
      if v-num = 1 then do:
        {&err-source} "Не удалось определить товар. Пропускаем." {&new-line}.
        {&put-source}
        next file-line.
      end.
      else do:
      run new-art-supp in this-procedure (2) no-error .
          if error-status :error then do:
              {&err-source} "Не удалось определить товар. Пропускаем." {&new-line}.
              {&put-source}
              next file-line.
          end.
      end.

  end.

 /* проверка если товар ненайден */
 if i-prod-code = 0  then do:
    run find-goods in this-procedure (output v-gds-code) .
    find first goods no-lock where goods.gds-code = v-gds-code no-error .
    if not error-status :error then do:
      i-artic     = goods.artic .
      i-prod-code = goods.prod-code.
      if i-unit-cli = ""    then  i-unit-cli  = goods.unit-base .
      if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .

    end.
    else do:
        {&err-source} "По бар-коду не удалось определить товар. Пропускаем." {&new-line}.
        {&put-source}
        next file-line.
    end.
 end.
/* НАШЛИ ТОВАР */
    find first goods no-lock where goods.artic     =   i-artic       and
                                   goods.prod-code =   i-prod-code no-error  .
      if error-status :error then do:
          {&err-source} error-status :get-message(1) + i-artic + " " + string(i-prod-code) + " . Пропускаем." {&new-line}.
          {&put-source}
          next file-line.
      end.
/* Проверка кода из файла является ли он кодом этого товара */
define buffer bb_goods for goods.
  if decimal(i-code) <> 0 then do:
    find first bar-code no-lock where bar-code.b-code = int(i-code) no-error .
        run find-goods in this-procedure (output v-gds-code) .
        find first bb_goods no-lock where BB_goods.gds-code = v-gds-code no-error .
        if available bb_goods then do:
          if bb_goods.gds-code <> goods.gds-code then do:
              {&wrn-put} "Бар-Код " + i-code + " принадлежит другому товару , с артиклом " +
              bb_goods.artic + " " + bb_goods.prod-type + string(bb_goods.prod-code) +
              ". Закачиваем товар " + goods.artic + " " + goods.prod-type + string(goods.prod-code) +
              " по базовым ед.изм." + {&new-line}.
              { gbl/gdsbcode.i goods.gds-code ? v-b-code }
              find first bar-code where bar-code.b-code = v-b-code no-error .
          end.
        end.
        else do:
              {&wrn-put} "Бар-Код " + i-code + " не найден в БД " + {&new-line}.
              { gbl/gdsbcode.i goods.gds-code ? v-b-code }
              find first bar-code where bar-code.b-code = v-b-code no-error .
        end.

  end.


   run body-proc in this-procedure (input goods.gds-code ) no-error .
   if error-status :error then   next file-line.

   run analiz-b-code in this-procedure (  i-artic-supp ,
                        goods.artic  ,
                        goods.gds-code ,
                        i-code       )
                        no-error .
   if error-status :error then
   do:
   message 124 .
   {&wrn-put}  error-status :get-message(1) + return-value  + {&new-line}.
   next file-line.
   end.



   run body-proc in this-procedure (input goods.gds-code ) no-error .
   if error-status :error then next file-line.

  /* вызываем процедуру импорта для конкретного режима */
  run imp-input-way-bill in this-procedure  no-error.
  if error-status:error then do:
      {&err-put} SUBSTITUTE("Ошибка при вызове внутренней процедуры imp-input-way-bill &1 &2 &3",
                                                  return-value,
                                                  error-status:get-message(1),
                                                  error-status:get-message(2))  + {&new-line}.
      next file-line.
    end.
END.
hide frame a .

/*==========================================================================
      ПРОЦЕДУРЫ ИМПОРТА
==========================================================================*/

procedure imp-prod-bc:
/*--------------------------------------------------------------------------
    импорт доп. БК
--------------------------------------------------------------------------*/
def buffer same-prod-bc  for prod-bc.
def buffer same-bar-code for bar-code.
def buffer same-goods    for goods.

if not available bar-code then do:
/*возьмем собственный*/
  { gbl/gdsbcode.i goods.gds-code ? v-b-code }
  find first bar-code where bar-code.b-code = v-b-code no-error .
end.
{&wrn-put} ">> Импорт доп.бар-код " + i-prod-bc  {&new-line}.

tr:
do on error undo tr, return error SUBSTITUTE("Ошибка при импорте доп. бар-кода &1 &2 &3 ", i-prod-bc, error-status:get-message(1), error-status:get-message(2)):
if  length (i-prod-bc) > 13 /* длинный доп. БК */ and
    not is-numeral (i-prod-bc,
                    "letter,digit") or
    length (i-prod-bc) <= 13 /* EAN или другой не длинный доп. БК */ and
    not is-numeral (i-prod-bc,
                    "digit") then do:
  {&err-put} "Доп. БК содержит пробелы или недопустимые символы. Пропускаем доп.бар-код." {&new-line}.
  return.
end.
if  i-prod-bc begins par-bc-pfx and
    (length (i-prod-bc) = 13 and
    par-bc-frmt = "EAN13" or
    length (i-prod-bc) = 8 and
    par-bc-frmt = "EAN8") or
    (i-prod-bc begins par-pl-pfx and
    par-pl-pfx <> ? and
    par-pl-frmt <> ?) and
    (length (i-prod-bc) = 13 and
    par-pl-frmt = "EAN13" or
    length (i-prod-bc) = 8 and
    par-pl-frmt = "EAN8") then do:
  {&err-put} "Доп. БК имеет префикс, зарезервированный для собственных товарных (складских мест) бар-кодов. Пропускаем доп.бар-код." {&new-line}.
  return.
end.
/* проверка длины кода и специальных случаев (топливо, вес) */
if length (i-prod-bc) < 6 then do:
  /* короткий код - товар должен быть топливным или весовым */
  if (lookup ({&petrolium}, goods-units.type) > 0 and
      lookup ({&divisional}, goods-units.type) > 0 or
      lookup ({&weight}, goods-units.type) > 0) and
      goods.gds-type = {&gds-goods} then do:
    /* дробный (разливной) бензин или весовой товар */
    if  lookup ({&petrolium}, goods-units.type) > 0 and
        lookup ({&divisional}, goods-units.type) > 0 then do:
      /* топливный разливной товар:
      - запрещено добавлять собственные коды
      - запрещено добавлять бар-коды признаков и партий
      - запрещено добавлять доп. бар-коды
      - можно добавлять доп. топливный (2 разрядный, разновидность весового, только добавляется вручную)
      - доп. топливный можно добавлять только один
      */
      if  lookup ({&petrolium}, units.type) > 0 and
          lookup ({&divisional}, units.type) > 0 then do:
        /* топливный код */
        if length (i-prod-bc) > 2 then do:
          {&err-put} "Топливный код: " + i-prod-bc + " не должен быть длиннее 2 разрядов. Пропускаем доп.бар-код." {&new-line}.
          return.
        end.
        /* проверяем, что топливный код - единственный */
        find first  prod-bc where
                    prod-bc.b-code = bar-code.b-code and
                    prod-bc.b-str <> i-prod-bc no-lock no-error.
        if available prod-bc then do:
          {&err-put} "Товар топливный. Уже есть топливный код у этого товара: " prod-bc.b-str
                     " Он должен быть только один. Пропускаем доп.бар-код." {&new-line}.
          return.
        end.
      end.
      else do:
        /* НЕтопливный код */
        {&err-put} "Товар топливный. Можно импортировать только топливный код (с дробно-топливной единицей измерения). Пропускаем доп.бар-код." {&new-line}.
        return.
      end.
    end.  /*бензин*/
    if lookup ({&weight}, goods-units.type) > 0 then do:
      /*ВЕСОВЫЕ КОДЫ НЕ ИМПОРТИРУЮТСЯ*/
      {&err-put} "Код  " + i-prod-bc + " - весовой. Весовые коды не импортируются. Пропускаем доп.бар-код." {&new-line}.
      return.
    end.
  end.
  else do:
    /* нетопливный и невесовой товар - короткий код */
    {&err-put} "Код короче 6 разрядов  " + i-prod-bc + " может соответствовать только весовому или дробному топливному товару. Пропускаем доп.бар-код." {&new-line}.
    return.
  end.
end.
else do:
  /* длинный код > 6 */
  if  lookup ({&petrolium}, units.type) > 0 and
      lookup ({&divisional}, units.type) > 0 or
      lookup ({&weight}, units.type) > 0 then do:
    {&err-put} "Весовой или топливный код  " + i-prod-bc + " не может быть длиннее 5 разрядов. Пропускаем доп.бар-код." {&new-line}.
    return .
  end.
end.
/* проверяем наличие такого доп. БК для той же привязки (товара, признака, партии) */
find first  same-prod-bc where
            same-prod-bc.b-str  = i-prod-bc and
            same-prod-bc.b-code = bar-code.b-code no-lock no-error.
if available same-prod-bc then do:
  {&err-put} "Доп. БК: " + i-prod-bc + " уже есть в БД. Пропускаем доп.бар-код." {&new-line}.
  return.
end.
/*
Добавление бар-кодов через import.

|---------------|-----|--------------|---------------|-------------------|
| Уже имеется в |Dpl- |  Добавляемый |     Статус    |    Статус         |
|     базе      | off |  код включен |  старого кода | добавляемого      |
|  включенный   |     |              |  после импорта| кода после импорта|
|      код      |     |              |               |                   |
--------------------------------------------------------------------------
|      Yes      | Yes |      Yes     |       No      |      No           |
--------------------------------------------------------------------------
|      Yes      | Yes |      No      |      Yes      |      No           |
--------------------------------------------------------------------------
|      Yes      | No  |      Yes     |       No      |     Yes           |
--------------------------------------------------------------------------
|      Yes      | No  |      No      |      Yes      |      No           |
--------------------------------------------------------------------------
|      No       | Yes |      Yes     |       No      |     Yes           |
--------------------------------------------------------------------------
|      No       | Yes |      No      |       No      |      No           |
--------------------------------------------------------------------------
|      No       | No  |      Yes     |       No      |     Yes           |
--------------------------------------------------------------------------
|      No       | No  |      No      |       No      |      No           |
--------------------------------------------------------------------------
*/
/* ищем повторный включенный */
find first same-prod-bc where
           same-prod-bc.b-str = i-prod-bc and
           same-prod-bc.bc-on = yes       no-lock no-error.
if available same-prod-bc then do:
  /* есть повторный включенный */
  find same-bar-code where
       same-bar-code.b-code = same-prod-bc.b-code no-lock.
  find same-goods where
       same-goods.gds-code = same-bar-code.gds-code no-lock.
  if  same-goods.prod-type = goods.prod-type AND
      same-goods.prod-code = goods.prod-code AND
      par-dif-pdbc = yes /* запрет повторных доп. БК для одного производителя */ then do:
    {&err-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic
               ", он включен и соответствует тому же производителю. Пропускаем в соответствии с настройкой." {&new-line}.
    return.
  end.
  if par-dpl-off = yes then do:
    if i-bc-on = no then do:
      {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он включен. Добавляемый код вЫключен. Таким его и добавляем." {&new-line}.
    end.
    else do:
      {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он включен. Добавляемый код тоже включен. Добавляем его вЫключеным в соответствии с настройкой." {&new-line}.
      assign
        i-bc-on = no.
      {&wrn-put} "Имевшийся в БД доп. БК (см. предыдущее сообщение) для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", который был включен, вЫключаем в соответствии с настройкой" {&new-line}.
      do transaction on error undo, return error return-value:
        find current same-prod-bc exclusive-lock.
        assign
          same-prod-bc.bc-on = no.
      end.
   end.
  end.
  else do:
    if i-bc-on = yes then do:
      {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он включен. Добавляемый код тоже включен. ВЫключаем уже имеющийся в базе код. Добавляемый оставляем включенным." {&new-line}.
      do transaction on error undo, return error return-value :
        find current same-prod-bc exclusive-lock.
        assign
          same-prod-bc.bc-on = no.
      end.
      {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он включен. Добавляемый код вЫключен. Добавляем код без изменений." {&new-line}.
    end.
  end.
end.
else do:
  find first same-prod-bc where
             same-prod-bc.b-str = i-prod-bc and
             recid (same-prod-bc) <> recid (prod-bc) no-lock no-error.
  if available same-prod-bc then do:
    /* есть повторный выключенный */
    find  same-bar-code where
          same-bar-code.b-code = same-prod-bc.b-code no-lock.
    find same-goods where
         same-goods.gds-code = same-bar-code.gds-code no-lock.
    if  same-goods.prod-type = goods.prod-type AND
        same-goods.prod-code = goods.prod-code AND
        par-dif-pdbc = yes /* запрет повторных доп. БК для одного производителя */ then do:
      {&err-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic
                 ", он вЫключен и соответствует тому же производителю. Пропускаем  доп.бар-код в соответствии с настройкой dif-pdbc." {&new-line}.
      return.
    end.
    if i-bc-on = yes then do:
      {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он выключен. Добавляемый код включен. Добавляем код без изменений." {&new-line}.
    end.
    else do:
      {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он выключен. Добавляемый код вЫключен. Добавляем код без изменений." {&new-line}.
    end.
  end.
end.
do transaction on error undo, return error return-value :
  define variable rid as recid no-undo .
  rid = ?.
  run trg/prod-bc1.p (
                      input  parparentproc
                      ,input yes /*p-silent*/
                      ,input par-dif-pdbc /* dif-pdbc */
                      ,input ? /*pbc-veto*/
                      ,input no /*send-ref*/
                      ,input '' /*cdrg-type*/
                      ,input ""
                      ,buffer goods
                      ,input bar-code.b-code
                      ,input-output i-prod-bc
                      ,output rid
                      ) no-error.
  if error-status :error
  then do:
      {&wrn-put} "Ошибка при импорте доп. БК для товара: арт. : " goods.artic ", пр-ль : " goods.prod-code {&new-line}
                 error-status:get-message(1) {&new-line} return-value  {&new-line}.

  end.
  else if rid = ? then do:
      {&wrn-put} "Невозможно импортировать доп. БК для товара: арт. : " goods.artic ", пр-ль : " goods.prod-code {&new-line}
                 error-status:get-message(1) {&new-line} return-value  {&new-line}.
  end.
end.
assign
  counter = counter + 1.
end.
end procedure.

procedure imp-input-way-bill:
/*--------------------------------------------------------------------------
    импорт внешней ПН
--------------------------------------------------------------------------*/
define variable n-c like gds-prt.node-code no-undo.
define buffer bf_doc-line-attr for doc-line-attr.

find doc-line where
     doc-line.doc-code  = trn-doc.doc-code and
     doc-line.artic     = goods.artic and
     doc-line.prod-code = goods.prod-code and
     doc-line.prod-type = goods.prod-type no-error.
if available doc-line then do:
  /* прибавляем к имеющейся строке */
  if doc-line.unit-cli      = i-unit-cli and
     doc-line.cli-base-rate = i-cli-base-rate then
    /* едизм пост-ка тот же, коэф тоже - нет проблем */
    assign
      doc-line.cli-qnty      = doc-line.cli-qnty + i-qnty
      doc-line.price-cli     = i-price
      doc-line.unit-cli      = i-unit-cli
      doc-line.cli-base-rate = i-cli-base-rate
      .
  else do:
    /* другой едизм пост-ка - нужно пересчитывать кол-ва */
    if doc-line.cli-base-rate = i-cli-base-rate then do:
      {&wrn-put} "Единица измерения поставщика в строке ПН: " doc-line.unit-cli
                 " Не совпадает с импортируемой. Заменяем на: " i-unit-cli {&new-line}.
      doc-line.unit-cli = i-unit-cli.
    end.
    else do:
      {&wrn-put} "Коэффициент в строке ПН: " doc-line.cli-base-rate
                 " Не совпадает с импортируемым. Заменяем единицу измерения поставщика на основную: " goods.unit-base
                 " и пересчитываем количества поставщика." {&new-line}.
      assign
        doc-line.unit-cli      = goods.unit-base
        doc-line.cli-qnty      = doc-line.cli-qnty * doc-line.cli-base-rate +
                                 i-qnty * i-cli-base-rate
        doc-line.cli-base-rate = 1
        doc-line.price-cli     = i-price / i-cli-base-rate
        .
    end.
  end.
end.
else do:
  /* создаем новую строку */
  { str/crdoclin.i
    trn-doc.doc-code
    goods.artic
    goods.prod-type
    goods.prod-code
    "''"
    0
    "''"
    "''"
    goods.prt-root
    0
    0
    0
    no-error
  }
  if error-status:error then do:
      {&err-put} SUBSTITUTE("Ошибка при вызове процедуры crdoclin &1 &2 &3",
                            return-value,
                            error-status:get-message(1),
                            error-status:get-message(2))  + {&new-line}.
      return error.
  end.

  find first doc-line where doc-line.doc-code  = trn-doc.doc-code and
                            doc-line.artic     = goods.artic      and
                            doc-line.prod-type = goods.prod-type  and
                            doc-line.prod-code = goods.prod-code .

  assign
    doc-line.cli-qnty      = 0
    doc-line.doc-qnty      = 0
    doc-line.fact-qnty     = 0
    doc-line.price-cli     = i-price
    doc-line.unit-cli      = i-unit-cli
    doc-line.cli-base-rate = i-cli-base-rate
    doc-line.cli-qnty      = i-qnty
    doc-line.wt-brutto     = i-wt-brutto
    doc-line.num-place     = i-num-place
    .
end.
/* ставки налогов берем всегда из последней строки */
assign
  doc-line.VAT-pc        = v-VAT-pc
  doc-line.SLT-pc        = v-SLT-pc
  .
find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = goods.gds-code    and
                                  bf_doc-line-attr.attr-code = "cst-code"        no-error.
if not available bf_doc-line-attr then do:
   create bf_doc-line-attr.
   assign
   bf_doc-line-attr.doc-code   = doc-line.doc-code
   bf_doc-line-attr.gds-code   = goods.gds-code
   bf_doc-line-attr.attr-code  = "cst-code"
   bf_doc-line-attr.attr-value = i-cst-code.
end.
/* при наличии шкалы нужно создавать gds-dtl на явно указанный либо 1 терминальный
   признак, потому что возможна смесь строк по признакам и корневому для одного товара */
if string-type = "SCALE" OR
   string-type = "CODE"  then
  /* явно задан признак - он найден выше - пишем в него */
  n-c = gds-prt.node-code.
if string-type = "ITEM" then do:
  /* признак явно не указан - берем 1 терминальный */
  find first gds-prt where gds-prt.upper-code = goods.prt-root
       use-index level no-lock no-error.
  do while true:
    n-c = gds-prt.node-code.
    find first gds-prt where gds-prt.upper-code = n-c
         use-index level no-lock no-error.
    if not available gds-prt then
      leave.
  end.
end.


find gds-dtl where
     gds-dtl.doc-code  = trn-doc.doc-code and
     gds-dtl.artic     = goods.artic and
     gds-dtl.prod-code = goods.prod-code and
     gds-dtl.prod-type = goods.prod-type and
     gds-dtl.prt-code  = n-c no-error.
if not available gds-dtl then do:
  assign counter = counter + 1.
  create gds-dtl .
  assign
    gds-dtl.doc-code      = trn-doc.doc-code
    gds-dtl.artic         = goods.artic
    gds-dtl.prod-code     = goods.prod-code
    gds-dtl.prod-type     = goods.prod-type
    gds-dtl.prt-code      = n-c
  .
end.

assign
  doc-line.doc-qnty      = doc-line.doc-qnty + (i-qnty * i-cli-base-rate)
  doc-line.fact-qnty     = doc-line.doc-qnty
  doc-line.cli-base-rate = doc-line.doc-qnty / doc-line.cli-qnty
  gds-dtl.doc-qnty       = gds-dtl.doc-qnty + (i-qnty * i-cli-base-rate)
  gds-dtl.fact-qnty      = gds-dtl.doc-qnty
  count-upd              = count-upd + 1
  .
end procedure.



procedure delete-trn-doc :

  do
  on error undo, return error
  :
    for each doc-line
      where doc-line.doc-code = trn-doc.doc-code
    on error undo, return error
    :
      delete doc-line .
    end.
    for each gds-dtl
      where gds-dtl.doc-code = trn-doc.doc-code
    on error undo, return error
    :
      delete gds-dtl .
    end.
    delete trn-doc .
  end.

end procedure. /* delete-trn-doc */

procedure body-proc :

  do
  on error undo, return error return-value
  :
  /* ищем товар */

define input  parameter p-gds-code as integer   no-undo .
      FIND first goods WHERE
                 goods.gds-code = p-gds-code no-lock no-error.

      if available goods then do:
      end.
      else do:
        {&err-source} "Товар с данными артикулом и кодом производителя (подразумевается организация) в БД отсутствует. Пропускаем." {&new-line}.
        {&put-source}
        return error .
      end.


    if i-prod-code <> 0 then do:
        if goods.artic <> i-artic then do:
          {&wrn-put} "Несоответствие доп.бар-кода и артикула поставщика. Взят по доб.бар-коду." + goods.artic {&new-line}.
        end.
    end.

    assign
     i-artic     = goods.artic
     i-prod-code = goods.prod-code
    .
      if i-unit-cli = ""    then  i-unit-cli  = goods.unit-base .
      if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .


    if i-unit-cli = "" then do:
      if available bar-code then do:
          /* подставляем едизм и коэффициент из бар-кода */
          assign
            i-cli-base-rate = bar-code.cli-base-rate
            i-unit-cli      = bar-code.unit-cli
            .
          {&wrn-bar-code} "Не указаны единица измерения и коэффициент. Берем из собственного кода." {&new-line}.
       end.
       else do:
          assign
            i-cli-base-rate = 1
            i-unit-cli      = goods.unit-base
            .
          {&wrn-put} "Не указаны единица измерения и коэффициент. Берем из товара базовые ед.изм." {&new-line}.
       end.
    end.
    if available bar-code and decimal(i-code) > 0 then do:
      find first gds-prt where gds-prt.node-code = bar-code.node-code no-lock.
      if gds-prt.is-term <> yes       then do:
        {&err-source} "Код " i-code " не является кодом терминального признака. Пропускаем." {&new-line}.
        {&put-source}
        return error .
      end.
      else do:
            if gds-prt.node-name <> {&empty-scale} then do:
                assign
                  string-type = "SCALE"
                  i-scale     = gds-prt.f-name .
                .
            end.
            else do:
                assign
                  string-type  = "ITEM"
                  i-scale      = ""
                .
            end.
      end.
    end.

   /* Признак */
   if i-scale <> ""  then do:
      /* это признак */
      find first  gds-prt where
                  gds-prt.prt-root = goods.prt-root and
                  gds-prt.is-term  = yes            and
                  gds-prt.f-name   = i-scale        no-lock no-error.
      if not available gds-prt then do:
        /*В беннетоне при переходе с одноуровневой шкалы на двухуровневую могли остаться товары привязанные к старой шкале.
          Их надо обслужить особо*/
        define variable varqnty-slash as integer no-undo.
        define variable varnum-symb   as integer no-undo.
        define variable vari-scale    like i-scale no-undo.
        assign varqnty-slash = 0.
        do varnum-symb = 1 to length(i-scale):
          if substring (i-scale, varnum-symb , 1) = "/" then do:
            assign
              varqnty-slash = varqnty-slash + 1.
          end.
        end.
        if varqnty-slash = 1 then do:
          assign
            vari-scale = substring (i-scale, r-index (i-scale, "/") + 1).
          find first  gds-prt where
                  gds-prt.prt-root = goods.prt-root and
                  gds-prt.is-term  = yes            and
                  gds-prt.f-name   = vari-scale        no-lock no-error.
          if not available gds-prt then do:
            {&err-put} "Узел шкалы " i-scale " не найден. Пропускаем." {&new-line}.
            return error .
          end.
          else do:
            {&err-put} "Узел шкалы не найден. Но НАЙДЕН для одноуровневой шкалы по нижнему уровню. Пропускаем." {&new-line}.
            return error .
          end.
        end.
        else do:
          {&err-put} "Узел шкалы не найден. Пропускаем." {&new-line}.
          return error .
        end.
      end.
   end.

  /* находим едизм для ТОВАРА */
  find goods-units where
       goods-units.unit-name = goods.unit-base no-lock.
  if i-unit-cli = "" then
    assign
      i-unit-cli = goods.unit-base
      /* коэффициент восстанавливаем */
      i-cli-base-rate = 1
      .
  if v-obj-type = ? or
     v-obj-code = ? then do:
     assign
       v-obj-type = store-type
       v-obj-code = store-code.
  end.

  { gbl/hostcode.i v-obj-type v-obj-code v-host-code }



  /* определяем текущую дату на объекте */
  { gbl/curobjdt.i
    v-obj-type
    v-obj-code
    v-today
  }

  /* если код ставки налога равен 0 - то берется текущая ставка налога по товару */
  /* если она отлична от нуля       - то берется указанная ставка налога на текущую дату */
  assign
    v-vat-pc = ?
    v-slt-pc = ?
  .


  /* в зависимости от настройки магазина shop.inout-price */
  /* в документе импорта указывается абсолютное значение налога или код ставки */
  /* если (shop|store).inout-price = true,  то в файле абсолютные значения налога */
  /* если (shop|store).inout-price = false, то в файле заданы коды ставок налогов */

  define variable v-inout-price as logical   no-undo .

/*  { gbl/objat.i*/
/*    v-obj-type*/
/*    v-obj-code*/
/*    "'inout-price=request'"*/
/*    v-inout-price*/
/*    no-error*/
/*  }*/
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop .

  case v-obj-type :
    when {&stock}
    then do:
      find buf_store no-lock
        where buf_store.obj-code = v-obj-code
        no-error .
      if not available buf_store
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден склад." skip
          v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-inout-price = buf_store.inout-price
      .
    end.
    when {&shop}
    then do:
      find buf_shop no-lock
        where buf_shop.obj-code = v-obj-code
        no-error .
      if not available buf_shop
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден магазин." skip
          v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-inout-price = buf_shop.inout-price
      .
    end.
  end.

  if v-inout-price = true
  then do:
    if i-VAT = 0
    then do:
      /* в файле абсолютные значения налога */
      /* налог не задан */
      /* берем текущее значение налога */
      { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? v-host-code v-obj-type v-obj-code v-vat-pc no-error }
    end.
    else do:
      assign
        v-vat-pc = i-VAT
      .
    end.
  end.
  else do:
    { gbl/pftaxval.i ? {&vat-tax-code} i-VAT v-today v-host-code v-obj-type v-obj-code v-vat-pc no-error }
    if v-vat-pc = ? then do:
        { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? v-host-code v-obj-type v-obj-code v-vat-pc no-error }
    end.
  end.

  if v-inout-price = true
  then do:
    if i-SLT = 0
    then do:
      { gbl/pftxvalg.i goods.gds-code {&slt-tax-code} ? v-host-code v-obj-type v-obj-code v-slt-pc no-error }
    end.
    else do:
      assign
        v-slt-pc = i-SLT
      .
    end.
  end.
  else do:
    { gbl/pftaxval.i ? {&slt-tax-code} i-SLT v-today v-host-code v-obj-type v-obj-code v-slt-pc no-error }
    if v-slt-pc = ? then do:
       { gbl/pftxvalg.i goods.gds-code {&slt-tax-code} ? v-host-code v-obj-type v-obj-code v-slt-pc no-error }
    end.
  end.


  if v-vat-pc = ?
  then do:
    {&err-put} substitute("Получено неопреледенное значение НДС. Код ставки НДС &1. Пропускаем.", i-vat) {&new-line}.
    return error .
  end.

  if v-slt-pc = ?
  then do:
    {&err-put} substitute("Получено неопреледенное значение НП. Код ставки НП &1. Пропускаем.", i-slt) {&new-line}.
    return error .
  end.

  /* проверяем тип строки */
  if lookup ({&pieces}, goods-units.type) > 0 and
     i-cli-base-rate <> truncate (i-cli-base-rate, 0) then do:
    {&err-put} "Для штучного товара коэффициент должен быть целым числом. Пропускаем." {&new-line}.
    return error .
  end.
  /* В связи с появлением в ПМС глобальных весовых бар-кодов начинаем экспортировать их
     во внешнюю приходную накладную*/
  if lookup ({&weight}, goods-units.type)  > 0 and
     not lookup (string-type, "ITEM,PART") > 0 then do:
    {&err-put} "Товар весовой : Тип строки должен быть ITEM, PART, либо CODE для товара. Пропускаем." {&new-line}.
    return error .
  end.
  if lookup ({&serial}, goods-units.type) > 0 and
     not lookup (string-type, "ITEM,PART") > 0 then do:
    {&err-put} "Товар серийный : Тип строки должен быть ITEM, PART, либо CODE для товара. Пропускаем." {&new-line}.
    return error .
  end.
  if lookup ({&petrolium}, goods-units.type) > 0 and
     lookup ({&divisional}, goods-units.type) > 0 and
     goods.gds-type = {&gds-goods} then do:
    /* дробный (разливной) бензин */
    if not lookup (string-type, "ITEM") > 0 then do:
      {&err-put} "Товар топливный : Тип строки должен быть ITEM, либо CODE для товара. Пропускаем." {&new-line}.
      return error .
    end.
    if i-unit-cli <> goods.unit-base then do:
      {&err-put} "Товар топливный : Единица измерения должна совпадать с основной. Пропускаем." {&new-line}.
      return error .
    end.
  end.

  /* находим едизм, указанный в бар-коде (входном файле) */
  find units where units.unit-name = i-unit-cli no-lock no-error.
  if not available units then do:
    {&wrn-put} "Единица измерения =  '" i-unit-cli "' отсутствует в справочнике."   {&new-line}.
     find units where units.unit-name = goods.unit-base no-lock no-error.
     if not available units then do:
        {&err-put} "Единица измерения отсутствует в справочнике. Пропускаем." {&new-line}.
        return error .
     end.
     else
     {&wrn-put} "Единица измерения  взята базовая. " units.unit-name  {&new-line}.
  end.

  /* проверяем коэффициент */
  if i-cli-base-rate <= 0 then do:
    {&err-put} "Коэффициент должен быть больше 0. Пропускаем." {&new-line}.
    return error .
  end.
  if i-cli-base-rate = ? then do:
    {&err-put} "Коэффициент не должен иметь неопределенное значение. Пропускаем." {&new-line}.
    return error .
  end.
  if i-unit-cli <> goods.unit-base and
     i-cli-base-rate = 1 then do:
    {&err-put} "Единица измерения не совпадает с основной - а коэффициент 1! Пропускаем. " {&new-line}.
    return error .
  end.
  if i-unit-cli = goods.unit-base and
     i-cli-base-rate <> 1 then do:
    {&err-put} "Единица измерения совпадает с основной. Коэффициент должен быть равен 1. Пропускаем." {&new-line}.
    return error .
  end.

  /* проверяем скидку */
  if  i-cli-base-rate = 1 and
      i-d-pcnt <> 0 then do:
    {&err-put} "Коэффициент равен 1. Скидка должна быть равна 0. Пропускаем." {&new-line}.
    return error .
  end.
  if i-cli-base-rate > 1 and
      i-d-pcnt < 0 then do:
    {&err-put} "Коэффициент больше 1. Скидка должна быть больше или равна 0. Пропускаем." {&new-line}.
    return error .
  end.
  if i-cli-base-rate < 1 and
      i-d-pcnt > 0 then do:
    {&err-put} "Коэффициент меньше 1. Скидка должна быть меньше или равна 0. Пропускаем." {&new-line}.
    return error .
  end.

  /* проверяем цену */
  if  i-price < 0 then do:
    {&err-put} "Цена неправильная. Пропускаем." {&new-line}.
    return error .
  end.

  if i-price = ? or
      i-price = 0 then do:
    {&err-put} "Цена неправильная. Пропускаем." {&new-line}.
    return error .
  end.


  end.

end procedure. /* body-proc */

procedure analiz-b-code :

  do
  on error undo, return error return-value
  :
 define input  parameter p-artic-supp as character no-undo .
 define input  parameter p-artic as character no-undo .
 define input  parameter p-gds-code as integer   no-undo .
 define input  parameter p-b-code as character no-undo .

 define buffer buf_goods for goods .
 define buffer buf2_goods for goods .

 find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .


 if p-b-code = "" or p-b-code = ? then do:
    run make-doc-line-base in this-procedure (p-gds-code) .
    return .
  end.

  /* ищем (бар-) код */
    { str/bc-rcnz.i
      parParentProc
      p-b-code
      ?
      store-type
      store-code
      yes
      no
      varscales-pref
      varpgscales-pref
      varresult
      vartype-bc
      varweight
      bar-code
      prod-bc
      place
      no-error
    }
    if not available bar-code then do:
      /* код не найден */
      {&wrn-put} "Код " + p-b-code + " для поиска в БД отсутствует. "  {&new-line}.
      run get-bar-code in this-procedure no-error.
      if error-status:error then return error return-value .

      run make-new-bar-code in this-procedure no-error .
      if error-status :error then return error return-value .
    return .
    end.

    if buf_goods.gds-code = bar-code.gds-code then do:
        run make-doc-line-bar-code in this-procedure  no-error .
        if error-status :error then return error return-value .
        return .
    end.

    if buf_goods.gds-code <> bar-code.gds-code then do:
       find first buf2_goods no-lock where buf2_goods.gds-code = bar-code.gds-code no-error .

        {&wrn-put} "Бар-Код " +  p-b-code + " принадлежит другому товару , с артиклом " +
                       buf2_goods.artic + " " + buf2_goods.prod-type + string(buf2_goods.prod-code) +
                       "." + {&new-line}.

        run make-doc-line-base in this-procedure (p-gds-code) no-error .
        if error-status :error then return error return-value .
        return .
    end.
  end.
end procedure. /* analiz-b-code */

procedure make-doc-line-bar-code :
/* создание строки накладной с бар-код едизмом */
  do
  on error undo, return error return-value
  :

    if i-cli-base-rate <> 0  then i-cli-base-rate = bar-code.cli-base-rate .
    if i-unit-cli      <> "" then  i-unit-cli      = bar-code.unit-cli     .


    /**/

  end.

end procedure. /* make-doc-line-bar-code */

procedure make-doc-line-base :
/* создание строки накладной с базовым едизмом */
  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code as integer   no-undo .
find first goods no-lock where goods.gds-code = p-gds-code no-error .
  if i-unit-cli = ""     then  i-unit-cli      = goods.unit-cli      .
  if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .
{ gbl/gdsbcode.i goods.gds-code ? v-b-code }
find first bar-code where bar-code.b-code = v-b-code no-error .

  end.

end procedure. /* make-doc-line-base */


procedure make-new-bar-code :
/* Закачка новых бар-кодов по артиклу и едизмам из файла */
  do
  on error undo, return error return-value
  :
run imp-prod-bc in this-procedure .
  /* находим или создаем собственный код, на который должен ссылаться доп. БК */
  end.
end procedure. /* make-new-bar-code */


procedure find-goods :
/* поиск товара по бар-коду */
do
on error undo, return error return-value
:
define output parameter p-gds-code as integer   no-undo .
define buffer bb_bar-code  for bar-code .
define buffer bb_prod-bc   for prod-bc  .
define buffer bb_place     for place    .

p-gds-code = ? .
    { str/bc-rcnz.i
      parParentProc
      i-code
      ?
      store-type
      store-code
      yes
      no
      varscales-pref
      varpgscales-pref
      varresult
      vartype-bc
      varweight
      bb_bar-code
      bb_prod-bc
      bb_place
      no-error
    }
    if available bb_bar-code then do:
       p-gds-code = bb_bar-code.gds-code.
    end.

end.
end procedure. /* find-goods */

procedure new-art-supp :

  do
  on error undo, return error return-value
  :
define input  parameter v-mode as integer   no-undo .

define variable var-gds-code as integer   no-undo .
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-prod-type like ub.clients.obj-type no-undo .
define variable v-prod-code like ub.clients.obj-code no-undo .
define variable new-ref-list as character no-undo init "" .
define variable i as integer   no-undo .
if v-mode = 1 then do:
/*выбор из справочника товара*/
    run ref/gds-ref.p
    (   parParentProc
      , "b-sel,b-add"
      , {&current}
      , {&all}
      , {&all}
      , ?
      , ?
      , ?
      , ?
      , store-type
      , store-code
      , ?
      , output new-ref-list).

      find first goods no-lock where recid(goods) = integer (new-ref-list) no-error .
      if error-status :error then return error return-value .
      run add-cli-gds in this-procedure  no-error .
      if error-status :error then return error return-value .
end.
if v-mode = 2 then do:
/*выбор из списка 'двойников'*/
define variable v-ret as character no-undo .
define variable vattr-codes as character no-undo .
define variable vattr-labels as character no-undo .
define buffer bb_cli-gds for cli-gds.
define buffer bb_goods for goods.
for each bb_cli-gds no-lock where
      bb_cli-gds.cli-type  = parcli-type  and
      bb_cli-gds.cli-code  = parcli-code  and
      bb_cli-gds.host-code = parhost-code and
      bb_cli-gds.cli-art   = i-artic-supp ,
   first bb_goods no-lock where
      bb_goods.artic      = bb_cli-gds.artic and
      bb_goods.prod-type  = bb_cli-gds.prod-type and
      bb_goods.prod-code  = bb_cli-gds.prod-code :

      vattr-codes  = vattr-codes  + {&delim-nws} + string (bb_goods.gds-code) .
      vattr-labels = vattr-labels + {&delim-nws} +  string(bb_goods.artic,"x(16)") + " " + bb_goods.gds-name.

end.


run gbl/d-list.w
(    INPUT "b-sel":U
    ,INPUT "К артиклу поставщика <" + i-artic-supp +  "> прикреплены"
    ,INPUT vattr-codes
    ,INPUT vattr-labels
    ,INPUT {&delim-nws}
    ,INPUT "":U
    ,output v-ret ) .
      find first goods no-lock where goods.gds-code = integer (v-ret) no-error .
      if error-status :error then return error return-value .
      i-artic     = goods.artic .
      i-prod-code = goods.prod-code.
      if i-unit-cli = ""    then  i-unit-cli  = goods.unit-base .
      if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .

end.


  end.

end procedure. /* new-art-supp */

procedure add-cli-gds :

  do
  on error undo, return error return-value
  :
  i-artic     = goods.artic .
  i-prod-code = goods.prod-code.
  if i-unit-cli = ""    then  i-unit-cli  = goods.unit-base .
  if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .

  find first bf_cli-gds where bf_cli-gds.cli-type  = parcli-type  and
             bf_cli-gds.cli-code  = parcli-code  and
             bf_cli-gds.host-code = parhost-code and
             bf_cli-gds.artic     = goods.artic and
             bf_cli-gds.prod-code = goods.prod-code and
             bf_cli-gds.prod-type = goods.prod-type
             exclusive-lock no-error.
    if not available bf_cli-gds then do:
        create cli-gds.
        assign
        cli-gds.cli-type  = parcli-type
        cli-gds.cli-code  = parcli-code
        cli-gds.host-code = parhost-code
        cli-gds.cli-art   = i-artic-supp
        cli-gds.artic     = goods.artic
        cli-gds.prod-code = goods.prod-code
        cli-gds.prod-type = goods.prod-type
        .
       {&wrn-put} substitute ("артикул поставщика &1 по фирме &2 для поставщика &3 &4. Добавлен по товару &5 &6.", i-artic-supp, parhost-code, parcli-type, parcli-code, goods.artic ,goods.gds-name) {&new-line}.
    end.
    else do:
      {&wrn-put} "У товара найденого по бар-коду артикул поставщика = < " + bf_cli-gds.cli-art + " >" {&new-line}.
          if  bf_cli-gds.cli-art   = "" then bf_cli-gds.cli-art   = i-artic-supp .
          else do:
              {&err-put} "У товара найденого по бар-коду уже есть артикул , не равный артикул поставщика "  bf_cli-gds.cli-art  ". Пропускаем." {&new-line} skip.
              return error return-value .
          end.
    end.

  end.

end procedure. /* add-cli-gds */

procedure get-bar-code:
/*--------------------------------------------------------------------------
    поиск собственного бар-кода для товара, признака, партии
    с заданной единицей измерени

    при отсутствии создание такого бар-кода
    коэффициент инициируется в только в случае создания кода
--------------------------------------------------------------------------*/
define variable s-in-code   like parts.in-code   no-undo.
define variable s-part-code like parts.part-code no-undo.
define variable new-bar-code as log              no-undo.
define variable n-c like gds-prt.node-code no-undo.

  assign
    s-in-code   = ""
    s-part-code = ""
    .
find-create-bc:
do transaction
on error undo find-create-bc, return error
on stop  undo find-create-bc, return error :

  /* признак явно не указан - берем 1 терминальный */
  find first gds-prt where gds-prt.upper-code = goods.prt-root
       use-index level no-lock no-error.
  do while true:
    n-c = gds-prt.node-code.
    find first gds-prt where gds-prt.upper-code = n-c
         use-index level no-lock no-error.
    if not available gds-prt then  leave.
  end.
 if not available gds-prt then do:
    find first  gds-prt where
          gds-prt.prt-root = goods.prt-root and
          gds-prt.is-term  = yes
          no-lock no-error.
  end.


  { gbl/barcodcr.i
    goods.gds-code
    gds-prt.node-code
    s-part-code
    s-in-code
    i-unit-cli
    i-cli-base-rate
    new-bar-code
    bar-code
    no-error
  }
  if error-status:error then do:
    {&err-source} "Ошибка при поиске / создании собственного кода " + error-status :get-message(1) + ". Пропускаем." {&new-line}.
    undo find-create-bc, return error.
  end.
  if new-bar-code then do:
    {&wrn-bar-code} "Создан собственный код с единицей измерения из входного файла." {&new-line}.
  end.
  if bar-code.cli-base-rate <> i-cli-base-rate then do:
    {&err-bar-code} "Коэффициент в собственном коде не совпадает с указанным в файле. Пропускаем." {&new-line}.
    undo find-create-bc, return error.
  end.
end.
end procedure.