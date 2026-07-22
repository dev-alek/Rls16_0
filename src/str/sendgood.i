/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

пересылка товаров на кассу - общий код для всех видов пересылки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/05
Author: Bakhtadze Natalya
Creation date: 12/28/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ str/bc-gnrt.i new bc }
{ str/defc-gds.i }
{ str/defcncrd.i }
{ str/defc-txr.i }
{ cmp/library.i  }
{ str/round-m.i  }
/*{ gbl/cur-time.i }*/
{ trg/factord.i  }
{ str/lib-trn.i  }
{ str/tax-val.i  }
{ ref/gdsoattr.i }
{ ref/disgdsru.i }
{ bge/bgelib.i }
{ str/cd-xml.i }
{ gbl/gdcstcod.i }
{ str/cdsnddef.i }
{ str/name-2cd.i }
{ gbl/disrules.i work }
{ gbl/cd-attr.i }
{ str/cd-mrkt.i }
{ ref/gds-attr.i }
{ ref/bc-oattr.i }
{ str/mpl-auto.i }
{ gbl/ggoattr.i }

define variable v-del-mrkt-gds               as logical        no-undo .
define variable v-send-stock-qnty            as logical        no-undo .
DEFINE VARIABLE jj                           as integer        no-undo .
/*счетчик записей скидок на товар*/
DEFINE VARIABLE crgd                         as integer        no-undo .

/*счетчик записей текущего пакета налогов*/
DEFINE VARIABLE cr-txr                       as integer        no-undo .
/*счетчик записей текущего пакета категорийных скидок NCR*/
define variable cr-ncr-dis-kat               as integer        no-undo .
/*флаг начала пакета налогов*/
DEFINE VARIABLE start-paket-txr              as logical init yes no-undo .
/*считчик для показа работы процесса*/
define variable v-count                      as integer          no-undo .
/**/

DEFINE VARIABLE var-report-num               as integer          no-undo .
DEFINE VARIABLE g#log                        as logical          no-undo .
DEFINE VARIABLE v-today                      as date             no-undo .
DEFINE VARIABLE v-time                       as integer          no-undo .
define variable v-r-b-curr-magia             as integer          no-undo .
/**/
DEFINE VARIABLE ind                          as integer          no-undo .
/*вспом строковая переменная */
DEFINE VARIABLE s as character no-undo.
/*вспомогат переменная для чтения настроек*/
define variable v-index as integer no-undo .
/*вспомогат переменная для чтения настроек*/
DEFINE VARIABLE conf-attr                         as character        no-undo .
/*вспомогат переменная для чтения настроек*/
DEFINE VARIABLE conf-par                         as character        no-undo .
/*вспомогат переменная для чтения настроек*/
DEFINE VARIABLE par-type                        as character        no-undo .
/*переменная для хранения причин ошибок*/
DEFINE VARIABLE prichina                     as character        no-undo .

define buffer lock-batchprocess for ub.batchprocess .
define buffer request_prod-bc for ub.prod-bc.
define buffer r-gds-prt for ub.gds-prt.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.

define stream plucash.
define stream bar.
DEFINE VARIABLE chk_name                     as character        no-undo .
DEFINE VARIABLE bar_code                     as character        no-undo .
DEFINE VARIABLE b_code                       as character        no-undo .
DEFINE VARIABLE curr_cass                    as decimal          no-undo .
DEFINE VARIABLE dob-curr                     as character        no-undo .
DEFINE VARIABLE l-empty-scale                as logical          no-undo .
/*НАЗВАНИЕ МАГАЗИНА*/
DEFINE VARIABLE for-SHOP-NAME                as character        no-undo .
/*производитель*/
DEFINE VARIABLE for-producer                 as character        no-undo .
/*производитель*/
DEFINE VARIABLE for-producer-int             as integer          no-undo .
/*количество на складе*/
DEFINE VARIABLE for-fact-qnty                like ub.gds-obj.fact-qnty no-undo .
/*ОКДП*/
DEFINE VARIABLE for-okdp                     like ub.goods.okdp  no-undo .
/*правило ночн скидки*/
DEFINE VARIABLE temp-discnt-rule_            as integer          no-undo .
DEFINE VARIABLE temp-discnt-method_          as character        no-undo .
/*правило ночн скидки-pdf*/
DEFINE VARIABLE temp-discnt-rule_pdf         as integer          no-undo .
/*правило стандартной скидки*/
DEFINE VARIABLE std-discnt-rule_             as integer          no-undo .
/*не подлежит скидке на итог*/
DEFINE VARIABLE for-wd                       as integer          no-undo .
/*не подлежит товарной скидке*/
DEFINE VARIABLE for-wgd                      as integer          no-undo .
/*свободная цена на кассе*/
DEFINE VARIABLE for-fp                       as logical          no-undo .
/*код группы на кассе*/
define variable for-petrol-purse             as logical          no-undo .
/*флаг товара топливного кошелька*/
define variable need-auth                    as logical          no-undo .
/*флаг товара, требующего авторизации на кассе*/
DEFINE VARIABLE for-grp-code                 like ub.sum-grp.grp-code no-undo .
/*основной код товара*/
DEFINE VARIABLE main-b-code                  like ub.bar-code.b-code  no-undo .
/*цена в спуле*/
DEFINE VARIABLE for-price                    as decimal          no-undo .
/*дор налог*/
DEFINE VARIABLE for-road                     as decimal          no-undo .
/*акциз*/
DEFINE VARIABLE for-excise                   as decimal          no-undo .
/*флаг продажи по партияи*/
DEFINE VARIABLE cashparts                    like ub.gds-obj.cash-parts no-undo .
/*флаг топливного товара*/
DEFINE VARIABLE petrol-trk                   as logical          no-undo .
/*строка налогов*/
DEFINE VARIABLE tax-string                   as character        no-undo init "" .
/*флаг обработки след товара*/
DEFINE VARIABLE new-good                     as logical          no-undo init yes .
/*код представленяи на POS_IBM*/
DEFINE VARIABLE IBM-good-code                as character        no-undo .
/*строка скидок на кол-во*/
DEFINE VARIABLE qnty-discnt-rule_            as integer          no-undo init 0 .
/*строка категорийных скидок*/
DEFINE VARIABLE kat-discnt-rule_             as integer          no-undo init 0 .
DEFINE VARIABLE kat-discnt-method_           as character        no-undo .
/*правило категор скидки-pdf*/
DEFINE VARIABLE kat-discnt-rule_pdf          as integer          no-undo .
/*строка скидок по дате*/
DEFINE VARIABLE date-discnt-rule_            as integer          no-undo init 0 .
/*правило  abs скидки*/
DEFINE VARIABLE abs-discnt-rule_             as integer          no-undo init 0 .
/*правило  скидки на сумму */
DEFINE VARIABLE tot-discnt-rule_             as integer          no-undo init 0 .
/*код тары*/
define variable for-taracode                 as character        no-undo init "00".
define variable dflt-cd                      as character        no-undo .



/*флаг взвешиваемого товара*/
DEFINE VARIABLE is-sc                        as logical          no-undo .
/*код тары для бар-кода - отдельно от товарного*/
DEFINE VARIABLE taracode-bc                  as character        no-undo .

/*код налогов*/
DEFINE VARIABLE rdtaxcd                      as INTEGER          no-undo .
DEFINE VARIABLE vattaxcd                     as INTEGER          no-undo .
DEFINE VARIABLE exctaxcd                     as INTEGER          no-undo .
define variable v-is-null-price              like ub.fbr-gds-obj.is-null-price  no-undo .
define variable v-is-menu                    like ub.fbr-gds-obj.is-menu no-undo .
define variable v-is-semi-finished           like ub.fbr-gds-obj.is-semi-finished no-undo .
define variable v-is-modificator             like ub.fbr-gds-obj.is-modificator no-undo .
define variable v-fbr-grp-code               like ub.fbr-gds-grp.node-code no-undo .
define variable v-fbr-obj-code               like ub.fbr-gds-obj.fbr-obj-code no-undo .

/*-----------------НАСТРОЙКИ--------------------------------*/
/*на кассу товары всем списком имеющихся в наличии*/
DEFINE VARIABLE alllstcs                     as logical           no-undo init no .
/*нет автомата пересылки товаров*/
DEFINE VARIABLE noautocs                     as logical           no-undo init no .
/*маски коротких кодов*/
DEFINE VARIABLE mask_s-c                     as character         no-undo .
/*уникальный цифровой артикул + ДОПБК = артикулу*/
DEFINE VARIABLE unq-artc                     as logical           no-undo init no .
/*на кассу дву строки обычного имени товара*/
DEFINE VARIABLE nam-2str                     as logical           no-undo init no .
/*на кассу имя товара или артикул*/
DEFINE VARIABLE nam-artc                     as logical           no-undo init no .
/*what do i send to cash-desk - loc code name or GTD*/
DEFINE VARIABLE name-2cd                     as character       no-undo .
/*what do i send to cash-desk - for parts loc code or parts code?*/
DEFINE VARIABLE cod-pcod                     as logical           no-undo .
/*настройка - пересылать ли налоги на товар*/
DEFINE VARIABLE tax-cass                     as logical           no-undo init no .
/*настройка кассы IPC-servispl - префикс весового кода*/
DEFINE VARIABLE ipcsc-pfx                    as integer           no-undo init 23 .
/*настройка кассы IPC-servispl - префикс штучного кода*/
DEFINE VARIABLE ipcpg-pfx                    as integer           no-undo init 24 .
/*соотвествтия кодов скидок значения для NCR-MG*/
DEFINE VARIABLE ncrgmdsc                     as character         no-undo .
/*строковое значение полученного в итоге разбора кода скидки кассы NCR*/
DEFINE VARIABLE ncrdsc                       as character         no-undo .
/*приоритеты скидок - при наличии у товара двух или более видов скидок - временная, на количество и т.д. - для NCR-MG*/
DEFINE VARIABLE ncrdrank                     as character         no-undo  init "TX":U.
/*настройка кассы NCR - префикс весового кода*/
DEFINE VARIABLE ncrsc-pfx                    as character         no-undo init "23":U .
/*вспомог перемен*/
DEFINE VARIABLE ncrsc-frmt                   as character         no-undo init "EAN13" .
/*настройка кассы NCR - префикс штучного весового кода*/
DEFINE VARIABLE ncrpg-pfx                    as character         no-undo init "24":U .
/*вспомог перемен*/
DEFINE VARIABLE ncrpg-frmt                   as character         no-undo init "EAN13" .
/*гдк хранить файлы неприкосоновеннхы ручнхы настроек может быть no TH NCR*/
define variable ncr-save-param               as character         no-undo init 'no'.
/*количество зарезервированных на кассе ставок налогов*/
DEFINE VARIABLE txfixnum                     as INTEGER           no-undo .
/*точность представления - кол-во знаков после зап*/
DEFINE VARIABLE rnd-znak                     as integer           no-undo init 2 .
/*какие скидки импользуются на кассе - категорийный или на количество*/
DEFINE VARIABLE amntdisc                     as integer           no-undo .
/*способ задания временной скидки - по товару или через ПДФ*/
DEFINE VARIABLE how-temp-disc                as character         no-undo .
/*способ задания категорийной скидки - по товару или через ПДФ*/
DEFINE VARIABLE how-pcnt-kat                 as character         no-undo .
/*какие атрибуты выбирать в сооте с предыдущим параметром*/
DEFINE VARIABLE discnt-to-send               as character         no-undo .
/*текущий объект = ресторан*/
define variable v-is-restaurant              as logical no-undo .
/*разбивать НДС по ставкам*/
define variable cd-vat                       as integer           no-undo .
/*список ссответсвтия кодов ставок налогов - категория налогов на кассе для cd-vat = 1*/
define variable cdtaxlst                     as character         no-undo .
/*количество записей товаров в первой странице наименований товаров для кассы MARIA - объект 20*/
define variable v-20-part1 as integer no-undo init 2621.
/*строка правил скидок*/
define variable v-record as character no-undo .
/*список соответствий по скидкам для кассы мария */
define variable dr-list as character no-undo .
/*список приоритетов шаблонов правл скидок для скидок по НП*/
define variable drgdsrank as character no-undo .


define buffer buf_currency for ub.currency.
define buffer buf_producer for ub.clients.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
{ gbl/disrules.i cash-desk }
define temp-table temp-cd-plu no-undo like ub.cd-plu .

{ str/ncradisc.i }

/* #2789 пункт 3.4, проверка по gds-коду товара принадлежности его к группе с атрибутом Запрет отправки на кассу */
FUNCTION check-ban-sales-via-cd return logical ( input p-gds-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.

    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
   if p-gds-code <> 0 then do:
    find first lc_goods where lc_goods.gds-code = p-gds-code.
    v-upper-code = lc_goods.grp-code.
    
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input {&ggoattr-ban-sales-via-cd},
          output v-value,
          output v-type
        ).

       if v-value = "yes" then
          return true.
       else 
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input shop.host-code,
             input "",
             input 0,
             input {&ggoattr-ban-sales-via-cd},
             output v-value,
             output v-type
             ).

          if v-value = "yes" then
             return true.        
          else 
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input shop.host-code,
                input {&shop},
                input i-obj-code,
                input {&ggoattr-ban-sales-via-cd},
                output v-value,
                output v-type
                ).

             if v-value = "yes" then
                return true.    
             else v-upper-code = lc_gds-grp.upper-code.    
          end .          
       end.   
      end.
    end.
end.

FUNCTION convert-tax-code returns integer
                                          ( input p-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .

  do jj = 1 to num-entries(p-cdtaxlst, ";"):
    if entry(jj, p-cdtaxlst, ";") begins (string(p-rate-code) + "-") then do:
      return integer(entry(2, entry(jj, p-cdtaxlst, ";"), "-":U)).
    end.
  end.

END FUNCTION.

FUNCTION convert-maria-tax-code returns character
                                          ( input p-vat-rate-code as integer
                                           ,input p-slt-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .
define variable aa as character no-undo extent 8.
define variable v-return-value as character no-undo .

  do jj = 1 to 8:
    if jj <= num-entries(p-cdtaxlst, ";") then do:
      if entry(jj, p-cdtaxlst, ";") begins (string(p-vat-rate-code) + "-") then do:
        aa[jj] = '1'.
      end.
      if entry(jj, p-cdtaxlst, ";") begins (string(p-slt-rate-code) + "-") then do:
        aa[jj] = '1'.
      end.
    end.
    if aa[jj] = '':U then aa[jj] = '0'.
    v-return-value = aa[jj] + v-return-value.
  end.
return v-return-value.
END FUNCTION.

FUNCTION convert-maria-tax-code-2 returns integer
                                          ( input p-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .
define variable v-return-value as integer no-undo .

  do jj = 1 to num-entries(p-cdtaxlst, ";"):
    if entry(jj, p-cdtaxlst, ";") begins (string(p-rate-code) + "-") then do:
      return jj.
    end.
  end.
return 0.
END FUNCTION.

&scop NEW-GOOD  assign ~
                new-good = yes ~
                temp-discnt-rule_ = 0 ~
                temp-discnt-method_ = '' ~
                petrol-trk = no ~
                tax-string = "" ~
                std-discnt-rule_ = 0 ~
                for-wd = 0 ~
                for-fp = no ~
                cashparts = no ~
                for-grp-code = 1 ~
                for-petrol-purse = no ~
                qnty-discnt-rule_ = 0 ~
                kat-discnt-rule_ = 0 ~
                kat-discnt-method_ = '' ~
                date-discnt-rule_ = 0 ~
                for-producer = "":U ~
                main-b-code = 0 ~
                for-taracode = '00' ~
                abs-discnt-rule_ = 0 ~
                for-wgd = 0 ~
                . ~
empty temp-table temp-dis-gds-rule. ~
run cur-time in this-procedure(output v-today, output v-time).


&scop  get-gds-obj-fields ~
      run get-gds-obj-fields in this-procedure( ~
                                                 buffer ~{&buffer-name~} ~
                                                ,input ~{&find-option~} ~
                                                ,input ~{&gds-code-field~} ~
                                                ,input i-obj-code ~
                                                ,input {&shop} ~
                                                ,output for-fact-qnty ~
                                                ,output cashparts ~
                                                ,output v-is-null-price ~
                                                ,output v-is-menu ~
                                                ,output v-is-semi-finished ~
                                                ,output v-is-modificator ~
                                                ,output v-fbr-grp-code ~
                                                ,output v-fbr-obj-code ~
                                                ) no-error . ~
      if error-status:error then do: ~
        run write-log-and-file in p-log-handle (   ~
              input 1                                                                  ~
            , input log-file-name                                                      ~
            , input 1                                                                  ~
            , input substitute("!!!Ошибка при получении характеристик товара &1 &2&3 на объекте"      ~
                                , ~{&buffer-name~}.artic                               ~
                                , ~{&buffer-name~}.prod-type                           ~
                                , ~{&buffer-name~}.prod-code                           ~
                                )                                                       ~
                                  ).                                                    ~
        assign                                                                          ~
        v-view-log = yes                                                                ~
        . ~
     end.

{ str/sclspref.i }
&if "{&called}" = "send-gds" or "{&called}" = "send-codes-only" &then
define variable callpoint                    as character      no-undo .
&if "{&called}" = "send-gds" &then
/*ПОКА только в режиме send-gds может быть параметр p-other - а там опция означающа
что надо снимать флажки D с товаров M A R K E T E R
и отсылать количество по складу*/
assign
v-del-mrkt-gds = lookup("del-mrkt-gds":U, p-other) > 0
v-send-stock-qnty = lookup("send-stock-qnty":U, p-other) > 0
.
&endif
{ str/asc-gds.i  gds-list }
&else
{ str/asc-gds.i  ub.goods }
&endif

&if "{&called}" = "s-prodbc" or "{&called}" = "send-bc" &then
/*для отсылки бар-кода мы в этом месте еще не знаем i-obj-code*/
define variable cdpcknum as integer no-undo init 200.
&else
/*определим размер пакета*/
{ str/cdpcknum.i {&shop} abs(i-obj-code) }
&endif

{ gbl/conf-rd.i
"'txfixnum'"
0
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
IF not error-status:error then
txfixnum = integer(conf-par).

{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_rnd-znk} then rnd-znak = thbjattr_thbj-attr.property-value-integer .
end.

for each thbjattr_thbj-attr :
  delete thbjattr_thbj-attr .
end.

{ gbl/getsect.i run "''" 0 {&attr-gds-ref} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-gds-ref_unq-artc} then unq-artc = thbjattr_thbj-attr.property-value-logical .
end.

assign
rdtaxcd  = integer({&road-tax-code})
vattaxcd = integer({&vat-tax-code})
exctaxcd = integer({&excise-tax-code}).

assign
var-report-num = dynamic-next-value( "next-report":U, "ubflt":U)
.

&if "{&called}" = "s-prodbc" or "{&called}" = "send-bc" &then
/*цикл по всем магазинам данной БД*/

&if "{&called}" = "s-prodbc" &then
FIND ub.prod-bc WHERE recid( ub.prod-bc ) = inp-recid NO-LOCK .
if not g#news then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Подготовка данных - ДОП.БК &1", ub.prod-bc.b-str)
                                              ).
&else
FIND b-bc WHERE recid( b-bc ) = inp-recid NO-LOCK .
if not g#news then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Подготовка данных - бар-код &1", b-bc.b-code)
                                              ).
&endif
_shop:
    FOR EACH ub.shop NO-LOCK ,
        FIRST ub.clients WHERE
              ub.clients.obj-type = {&shop} AND
              ub.clients.obj-code = ub.shop.obj-code AND
              ub.clients.db-num = g#db-num NO-LOCK,
        FIRST ub.sysconf WHERE sysconf.host-code = ub.shop.host-code:
      assign
      new-good = yes.
      assign
      i-obj-code = ub.shop.obj-code
      v-is-restaurant = ub.shop.is-catering
      for-shop-name = ub.clients.obj-name
      .
      if (    ub.shop.cd-bc-alt
           or ub.shop.cd-bc-base
           or ub.shop.cd-loc-alt
           or ub.shop.cd-loc-base
           or ub.shop.cd-parts-all
           or ub.shop.cd-parts-not-blank
           or ub.shop.cd-parts-ser
           or ub.shop.cd-pb-alt
           or ub.shop.cd-pb-base
           or ub.shop.cd-sc-base   ) = no then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Не выбраны типы кодов для пересылки на кассы &1&2 -&3" +
                               "(АРМ Администратор-Справочники-Магазины-Изменить-На кассу)"
                               , ub.clients.obj-type
                               , ub.clients.obj-code
                               , {&new-line}
                               )
                                                  ).
        next _shop.
      end.

      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Пересылка на кассы &1&2 информации о бар-кодах и ДопБК", ub.clients.obj-type, ub.clients.obj-code)
                                                ).
&else

FIND ub.shop WHERE ub.shop.obj-code = abs(i-obj-code) NO-LOCK .
find   FIRST ub.clients WHERE
          ub.clients.obj-type = {&shop} AND
          ub.clients.obj-code = ub.shop.obj-code  no-error .
if available ub.clients then
assign
for-shop-name = ub.clients.obj-name.
else for-shop-name = {&shop} + string(ub.shop.obj-code).
run adm/shattri.p (
    input "get":U
    ,input  {&shop}
    ,input  abs(i-obj-code)
    ,input  {&attr-cd-sending}
    ,input  {&attr-cd-sending_alllstcs} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then alllstcs = v-value-logical.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  {&shop}
    ,input  abs(i-obj-code)
    ,input  {&attr-cd-sending}
    ,input  {&attr-cd-sending_noautocs} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then noautocs = v-value-logical.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  {&shop}
    ,input  abs(i-obj-code)
    ,input  {&attr-cd-sending}
    ,input  {&attr-cd-sending_mask_s-c} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then mask_s-c = v-value-character.
else mask_s-c = "".
delete object v-tth.
/*
если нет автомата пересылки товаров на кассы, то
во всех режимах кроме простой переслыки на кассу не из новостей выдаем только мессадж*/
if noautocs

&if  "{&called}" = "send-gds" &then
         and g#news
&endif
&if  "{&called}" = "pdf" &then
         and g#news
&endif
then do:
    message "Пошлите товары на кассы объекта МАГАЗИН "
    if i-obj-code > 0
    then i-obj-code
    else (- i-obj-code)
    view-as alert-box WARNING.
&if "{&called}" = "s-prodbc" or "{&called}" = "send-bc" &then
    next _shop.
&else
    return.
&endif
end.


&if "{&called}" <> "send-tsd" &then
  if (    ub.shop.cd-bc-alt
        or ub.shop.cd-bc-base
        or ub.shop.cd-loc-alt
        or ub.shop.cd-loc-base
        or ub.shop.cd-parts-all
        or ub.shop.cd-parts-not-blank
        or ub.shop.cd-parts-ser
        or ub.shop.cd-pb-alt
        or ub.shop.cd-pb-base
        or ub.shop.cd-sc-base   ) = no then do:

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не выбраны типы кодов для пересылки на кассы &1&2", {&shop}, abs(i-obj-code))
                                            ).
    run finish-send in this-procedure no-error .
    return.
  end.
&endif
&if "{&called}" = "send-tsd" &then
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка на ТСД &1&2 информации о товарах", {&shop}, abs(i-obj-code))
                                          ).
&else
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка на кассы &1&2 информации о товарах", {&shop}, abs(i-obj-code))
                                          ).
&endif
&if "{&called}" = "send-gds" or "{&called}" = "send-codes-only" &then
  if Not g#news and i-obj-code > 0 then callpoint = "R":U.
  if g#news then callpoint = "N":U.
&endif

if i-obj-code < 0 then i-obj-code = - i-obj-code. /* а в новостях и из справочника он реально задается */
FIND ub.sysconf WHERE ub.sysconf.host-code = ub.shop.host-code NO-LOCK.

{ gbl/r-b-curr.i ub.shop.host-code v-r-b-curr-magia }
find first buf_currency no-lock where
           buf_currency.curr-code = v-r-b-curr-magia no-error .
if not available buf_currency or
buf_currency.okv-code = 0 then do:
  message
  "Не задан код ОКВ для валюты с кодом" buf_currency.curr-code
  view-as alert-box error .
  return error .
end.
assign
v-r-b-curr-magia = (if buf_currency.curr-code = 0 then 1 else buf_Currency.okv-code)
v-is-restaurant = ub.shop.is-catering
.

&endif
{ gbl/dflt-cd.i {&shop} abs(i-obj-code) dflt-cd no-error }
IF error-status:error then do:
  assign
  dflt-cd = ''.
end.

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
run adm/shattri.p (
    input "get":U
    ,input  {&shop}
    ,input  i-obj-code
    ,input  {&attr-cd-inf-send}
    ,input  '':U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then return error .
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = {&shop}
    and thbjattr_thbj-attr.obj-code = i-obj-code
    and thbjattr_thbj-attr.upper-prop-code = {&attr-cd-inf-send}
on error undo, return error :
  case thbjattr_thbj-attr.prop-code:
    when {&attr-cd-inf-send_nam-artc} then do:
      nam-artc = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-cd-inf-send_cod-pcod} then do:
      cod-pcod = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-cd-inf-send_tax-cass} then do:
      tax-cass = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-cd-inf-send_nam-2str} then do:
      nam-2str = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-cd-inf-send_name-2cd} then do:
      name-2cd = thbjattr_thbj-attr.property-value-character.
    end.
    when {&attr-cd-inf-send_amntdisc} then do:
      amntdisc = thbjattr_thbj-attr.property-value-integer.
    end.
    when {&attr-cd-inf-send_how-temp-disc} then do:
      how-temp-disc = thbjattr_thbj-attr.property-value-character.
      if how-temp-disc = {&dthbjr-temp-disc-pdf} then do:
        run get-thbj-rule in this-procedure ( input {&shop}
                                             ,input i-obj-code
                                             ,input ub.shop.host-code
                                             ,input {&dthbjr-temp-disc-pdf}
                                             ,input dflt-cd
                                             ,input "1,2,3"
                                             ,buffer buf_dis-thbj-rule
                                             ) no-error.
        if available buf_dis-thbj-rule then do:
          temp-discnt-rule_pdf = buf_dis-thbj-rule.rule-num.
        end.
      end. /*if how-temp-disc = {&dthbjr-temp-disc-pdf} then do:*/
      else do:
        temp-discnt-rule_pdf = 0.
      end.
    end.
    when {&attr-cd-inf-send_how-pcnt-kat} then do:
      how-pcnt-kat = thbjattr_thbj-attr.property-value-character.
      if how-pcnt-kat = {&dthbjr-pcnt-kat-pdf} then do:
        run get-thbj-rule in this-procedure ( input {&shop}
                                             ,input i-obj-code
                                             ,input ub.shop.host-code
                                             ,input {&dthbjr-pcnt-kat-pdf}
                                             ,input dflt-cd
                                             ,input "1,2,3"
                                             ,buffer buf_dis-thbj-rule
                                             ) no-error.
        if available buf_dis-thbj-rule then do:
          kat-discnt-rule_pdf = buf_dis-thbj-rule.rule-num.
        end.
      end. /*if how-temp-disc = {&dthbjr-temp-disc-pdf} then do:*/
      else do:
        kat-discnt-rule_pdf = 0.
      end.
    end.
  end case.
end.
 run fill-temp-cd in this-procedure ( input g#db-num, input {&shop}, input i-obj-code, input yes).
 if can-find(first temp-cd where
                  temp-cd.obj-code = i-obj-code
             AND  (temp-cd.pos-type = {&CD-TYPE-IBM-XML}
                  or
                  temp-cd.pos-type = {&CD-TYPE-autotank}
                  )
             AND  temp-cd.db-num = g#db-num
             ) then do:
  if index(name-2cd,"GTD":U) = 0 then
  assign
  name-2cd = name-2cd + "-":U + "GTD":U.
end.

/*узнаем в каком режиме работает касса - количественные скидки или категории скидок*/
run adm/shattri.p (
  input "get":U
  ,input {&shop}
  ,input ub.shop.obj-code
  ,input  {&attr-cd-type-ipc-servispl}
  ,input  {&attr-cd-type-ipc-servispl_ipcscpfx} /*p-param-code*/
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output v-param-type
  ,INPUT-OUTPUT table-handle v-tth
  ) no-error .
IF not error-status:error then
ipcsc-pfx = v-value-integer.

error-status:error = no.

/*часть кода, ответственная за простую пересылку товаров*/
&if "{&called}" = "send-gds" &then
{ str/send-gds.i }
&endif

/*часть кода, ответственная за пересылку товаров общим списокм*/
&if "{&called}" = "sndalgds" &then
{ str/sndalgds.i }
&endif

/*часть кода, ответственная за пересылку товаров из переоценки*/
&if "{&called}" = "in-ov" &then
def buffer t-cash-gds for cash-gds.
{ str/send-prl.i }
&endif

/*часть кода, ответственная за пересылку товаров из ДНЦ*/
&if "{&called}" = "pdf" &then
def buffer t-cash-gds for cash-gds.
{ str/send-pdf.i }
&endif



/*часть кода, ответственная за удаление товаров*/
&if "{&called}" = "del-gds" &then
{ str/del-gds.i }
&endif

/*часть кода, ответственная за удаление товаров группы*/
&if "{&called}" = "del-grp" &then
{ str/del-grp.i }
&endif

/*часть кода, ответственная за пересылку prod-bc*/
&if "{&called}" = "s-prodbc" or "{&called}" = "s-prodbcn" &then
{ str/s-prodbc.i }
&endif


/*часть кода, ответственная за пересылку bar-cod*/
&if "{&called}" = "send-bc" or "{&called}" = "send-bcn" &then
{ str/send-bc.i }
&endif

&if "{&called}" = "s-prodbc" or "{&called}" = "send-bc" &then
END. /*for each shop*/
&endif /*&if "{&called}" = "s-prodbc" or "{&called}" = "send-bc" &then - цикл по всем магазинам*/

&if "{&called}" = "s-prodbcn" or "{&called}" = "send-bcn" &then
&endif /*&if "{&called}" = "s-prodbc" or "{&called}" = "send-bc" &then - цикл по всем магазинам*/


&if "{&called}" = "s-prodbc" or "{&called}" = "send-bc" or "{&called}" = "s-prodbcn" or "{&called}" = "send-bcn" &then
/*часть кода, ответственная за пересылку prod-bc*/
&if "{&called}" = "s-prodbc"  or "{&called}" = "s-prodbcn" &then
{ str/s-prodb2.i }
&endif

/*часть кода, ответственная за пересылку bar-cod*/
&if "{&called}" = "send-bc" or "{&called}" = "send-bcn" &then
{ str/send-bc2.i }
&endif

&endif
/*&if "{&called}" = "s-prodbc" or "{&called}" = "send-bc" or "{&called}" = "s-prodbcn" or "{&called}" = "send-bcn"*/

run finish-send in this-procedure no-error .
/*общие процедуры для всех видов отсылки*/

/*рождение кода согласно настройка магазина и типу товара - для кассы IBM-POS*/
{ str/ibm-gdsc.i ub.shop }
{ str/ncr-gdsc.i ub.shop }

procedure finish-send :

  do
  on error undo, return error
  :
    &if "{&called}" = "send-gds" or "{&called}" = "send-codes-only" &then
    if p-batch then do:
      if v-view-log then
      run set-view-log in p-log-handle(yes).
    end.
    else do:
      { str/cdviewlg.i
      "'!!!При отсылке информации на кассы произошли ошибки!!!'"
      log-file-name not-delete}
    end.
    &else
    { str/cdviewlg.i
    "'!!!При отсылке информации на кассы произошли ошибки!!!'"
    log-file-name not-delete}
    &endif

    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end.

end procedure. /* finish-send */

/*начало блока который нужен только припосылке всей информации о товаре и не нужен для посылки только кодов*/
&if "{&called}" <> "send-codes-only" &then
/*PROCEDURE putc-gds.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-gds.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cycle.i }

/*PROCEDURE SENDING.*/
{ str/cd-send.i }

/*sending tax-rates*/
{ str/putc-13.i }


procedure get-o-attr :
define input parameter par-gds-code like ub.goods.gds-code no-undo .
define input parameter par-obj-code like ub.clients.obj-code no-undo .
define input parameter par-obj-type like ub.clients.obj-type no-undo .
define output parameter par-std-discnt-rule as integer no-undo .
define output parameter par-temp-disc-rule as integer no-undo .
define output parameter par-temp-disc-method as character no-undo .
define output parameter par-wd-rule as integer no-undo .
define output parameter par-fp as logical no-undo .
define output parameter par-grp-code as integer no-undo init 1.
define output parameter par-petrol-purse as logical no-undo .
define output parameter par-need-auth as logical no-undo .
define output parameter par-qnty-discnt-rule as integer no-undo .
define output parameter par-kat-discnt-rule as integer no-undo .
define output parameter par-kat-discnt-method as character no-undo .
define output parameter par-date-discnt-rule as integer no-undo .
define output parameter par-abs-discnt-rule as integer no-undo .
define output parameter par-tot-discnt-rule as integer no-undo .
define output parameter par-wgd-rule as integer no-undo .
define output parameter par-taracode as character no-undo .

define buffer loc-gds-obj-attr for ub.gds-obj-attr.
define buffer loc-dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_temp-dis-gds-rule for temp-dis-gds-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.


  do
  on error undo, return error
  :
    for each  loc-gds-obj-attr No-LOCK  where
              loc-gds-obj-attr.gds-code = par-gds-code AND
              loc-gds-obj-attr.obj-code = par-obj-code AND
              loc-gds-obj-attr.obj-type = par-obj-type :
      CASE loc-gds-obj-attr.attr-code:
        when {&attr-free-price-o}  then do:
          assign
          par-fp =  if loc-gds-obj-attr.attr-value = "yes"
                    then yes
                    else no
          .
        end.
        when {&attr-sum-grp-o} then do:
          assign
          par-grp-code =  integer(loc-gds-obj-attr.attr-value) no-error
          .
        end.
        when {&attr-petrol-purse-o} then do:
          assign
          par-petrol-purse =  if loc-gds-obj-attr.attr-value = "yes"
                              then yes
                              else no
          .
        end.
        when {&attr-need-auth-o} then do:
          assign
          par-need-auth =  if loc-gds-obj-attr.attr-value = "yes"
                              then yes
                              else no
          .
        end.
        when {&attr-taracode-o}  then do:
          assign
          par-taracode = loc-gds-obj-attr.attr-value no-error
          .
        end.
      END CASE.
    end.
    define variable v-par-log as logical no-undo .
   find first loc-dis-gds-rule where
              loc-dis-gds-rule.gds-code = par-gds-code
          and loc-dis-gds-rule.pos-type = dflt-cd
          and loc-dis-gds-rule.obj-type = ''
          and loc-dis-gds-rule.obj-code = 0
          and loc-dis-gds-rule.discnt-role = {&dgr-without-gds-disc} no-error.
    if available loc-dis-gds-rule then do:
      par-wgd-rule = loc-dis-gds-rule.rule-num.
    end.
    find first loc-dis-gds-rule where
              loc-dis-gds-rule.gds-code = par-gds-code
          and loc-dis-gds-rule.pos-type = dflt-cd
          and loc-dis-gds-rule.obj-type = ''
          and loc-dis-gds-rule.obj-code = 0
          and loc-dis-gds-rule.discnt-role = {&dgr-without-disc} no-error.
    if available loc-dis-gds-rule then do:
      par-wd-rule = loc-dis-gds-rule.rule-num.
    end.
    define variable loc-host-code as integer no-undo .
    { gbl/hostcode.i par-obj-type par-obj-code loc-host-code }
    find first loc-dis-gds-rule where
              loc-dis-gds-rule.gds-code = par-gds-code
          and loc-dis-gds-rule.pos-type = dflt-cd
          and loc-dis-gds-rule.obj-type = {&cmp}
          and loc-dis-gds-rule.obj-code = loc-host-code
          and loc-dis-gds-rule.discnt-role = {&dgr-without-gds-disc} no-error.
    if available loc-dis-gds-rule then do:
      par-wgd-rule = loc-dis-gds-rule.rule-num.
    end.
    find first loc-dis-gds-rule where
              loc-dis-gds-rule.gds-code = par-gds-code
          and loc-dis-gds-rule.pos-type = dflt-cd
          and loc-dis-gds-rule.obj-type = {&cmp}
          and loc-dis-gds-rule.obj-code = loc-host-code
          and loc-dis-gds-rule.discnt-role = {&dgr-without-disc} no-error.
    if available loc-dis-gds-rule then do:
      par-wd-rule = loc-dis-gds-rule.rule-num.
    end.
    if par-wd-rule > 0 then do:
      find first buf_dis-rule no-lock where
                buf_Dis-rule.rule-num = par-wd-rule no-error.
      if available buf_dis-rule then do:
        run create-dis-rule in this-procedure ( input buf_dis-rule.rule-num
                                               , (buf_Dis-rule.time-rule-num >= 0)) no-error .
      end.
    end.
    if par-wgd-rule > 0 then do:
      find first buf_dis-rule no-lock where
                buf_Dis-rule.rule-num = par-wgd-rule no-error.
      if available buf_dis-rule then do:
        run create-dis-rule in this-procedure ( input buf_dis-rule.rule-num
                                               , (buf_Dis-rule.time-rule-num >= 0)) no-error .
      end.
    end.
    for each  loc-dis-gds-rule No-LOCK  where
              loc-dis-gds-rule.gds-code = par-gds-code
         AND  loc-dis-gds-rule.obj-code = par-obj-code
         AND  loc-dis-gds-rule.obj-type = par-obj-type
         and  loc-dis-gds-rule.pos-type = dflt-cd :
      CASE loc-dis-gds-rule.discnt-role:
        when {&dgr-std-disc} then do:
          assign
          par-std-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when {&dgr-temp-disc} then do:
          if loc-dis-gds-rule.nonunique = ''
          then do:
          assign
          par-temp-disc-rule = loc-dis-gds-rule.rule-num
          .
        end.
          else do:
            if par-temp-disc-method = '' then do:
              find first buf_dis-cfg-rule no-lock where
                        buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
                    and buf_dis-cfg-rule.pos-type = dflt-cd
                    and buf_dis-cfg-rule.templ-rl-root = loc-dis-gds-rule.templ-rl-root no-error.

              assign
              par-temp-disc-method = (if available buf_dis-cfg-rule
                                      then buf_dis-cfg-rule.nonunique
                                      else {&question-mark})
              .
            end.
            create buf_temp-dis-gds-rule.
            buffer-copy
            loc-dis-gds-rule
            to
            buf_temp-dis-gds-rule
            .
            release buf_temp-dis-gds-rule.
          end.
        end.
        when {&dgr-pcnt-kat} then do:
          if loc-dis-gds-rule.nonunique = ''
          then do:
            assign
            par-kat-discnt-rule = loc-dis-gds-rule.rule-num
            .
          end.
          else do:
            if par-kat-discnt-method = '' then do:
              find first buf_dis-cfg-rule no-lock where
                        buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
                    and buf_dis-cfg-rule.pos-type = dflt-cd
                    and buf_dis-cfg-rule.templ-rl-root = loc-dis-gds-rule.templ-rl-root no-error.

              assign
              par-kat-discnt-method = (if available buf_dis-cfg-rule
                                      then buf_dis-cfg-rule.nonunique
                                      else {&question-mark})
              .
            end.
            create buf_temp-dis-gds-rule.
            buffer-copy
            loc-dis-gds-rule
            to
            buf_temp-dis-gds-rule
            .
            release buf_temp-dis-gds-rule.
          end.
        end.
        when {&dgr-pcnt-date} then do:
          assign
          par-date-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when {&dgr-without-disc} then do:
          assign
          par-wd-rule =  loc-dis-gds-rule.rule-num
          .
        end.
        when {&dgr-without-gds-disc} then do:
          assign
          par-wgd-rule =  loc-dis-gds-rule.rule-num
          .
        end.
        when {&dgr-pcnt-qnty} then do:
          assign
          par-qnty-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when {&dgr-pcnt-kat}  then do:
          assign
          par-kat-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when {&dgr-abs-disc}  then do:
          assign
          par-abs-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when {&dgr-pcnt-tot}  then do:
          assign
          par-tot-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
      END CASE.
      find first buf_dis-rule no-lock where
                buf_Dis-rule.rule-num = loc-dis-gds-rule.templ-rl-root no-error.
      if available buf_dis-rule then do:
        run create-dis-rule in this-procedure ( input loc-dis-gds-rule.rule-num
                                               , (buf_Dis-rule.time-rule-num >= 0)) no-error .
      end.
    end.
  end.

end procedure. /* get-o-attr */

procedure get-gds-obj-fields :
define parameter buffer buf_gds-obj for ub.gds-obj .
define input parameter par-find-buffer as logical no-undo .
define input parameter par-gds-code like ub.goods.gds-code no-undo .
define input parameter par-obj-code like ub.clients.obj-code no-undo .
define input parameter par-obj-type like ub.clients.obj-type no-undo .
define output parameter par-fact-qnty like ub.gds-obj.fact-qnty no-undo .
define output parameter par-cash-parts as logical no-undo .
define output parameter p-is-null-price              like ub.fbr-gds-obj.is-null-price  no-undo .
define output parameter p-is-menu                    like ub.fbr-gds-obj.is-menu no-undo .
define output parameter p-is-semi-finished           like ub.fbr-gds-obj.is-semi-finished no-undo .
define output parameter p-is-modificator             like ub.fbr-gds-obj.is-semi-finished no-undo .
define output parameter p-fbr-grp-code               like ub.fbr-gds-grp.node-code no-undo .
define output parameter p-fbr-obj-code               like ub.fbr-gds-obj.fbr-obj-code no-undo .



  do
  on error undo, return error
  :
    if par-find-buffer then do:
      find first buf_gds-obj no-lock where
                buf_gds-obj.gds-code = par-gds-code AND
                buf_gds-obj.obj-type = par-obj-type AND
                buf_gds-obj.obj-code = par-obj-code no-error .

    end.
    if not avail buf_gds-obj
    and ub.shop.is-catering = no
    then do:
      return.
    end.
    assign
    par-fact-qnty = (if available buf_gds-obj
                     then buf_gds-obj.fact-qnty
                     else 0)
    .
    assign
    par-cash-parts = (if available buf_gds-obj
                      then buf_gds-obj.cash-parts
                      else no)
    .
    if available buf_fbr-gds-obj then do:
      assign
      p-is-null-price     =  buf_fbr-gds-obj.is-null-price
      p-is-menu           =  buf_fbr-gds-obj.is-menu
      p-is-semi-finished  =  buf_fbr-gds-obj.is-semi-finished
      p-is-modificator    =  buf_fbr-gds-obj.is-modificator
      p-fbr-grp-code      =  buf_fbr-gds-obj.fbr-grp-code
      p-fbr-obj-code      =  buf_fbr-gds-obj.fbr-obj-code
      .
    end.
  end.

end procedure. /* get-gds-obj-fields */

&endif
/*конец блока который нужен только припосылке всей информации о товаре и не нужен для посылки только кодов*/


procedure get-prt-and-unit :
define input parameter par-prt-root like ub.goods.prt-root no-undo .
define input parameter par-unit-base like ub.goods.unit-base no-undo .
define output parameter par-empty-scale as logical no-undo .

  do
  on error undo, return error
  :
    FIND FIRST ub.gds-prt where
               ub.gds-prt.upper-code = par-prt-root NO-LOCK .
    assign
    par-empty-scale = NOT (ub.shop.doc-prt AND ( ub.gds-prt.node-name <> {&empty-scale}))
    .
    FIND FIRST ub.units WHERE
               ub.units.unit-name = par-unit-base NO-LOCK .

  end.

end procedure. /* get-prt-and-unit */

{ str/defcncrd.i proc-create }


procedure get-thbj-rule :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-discnt-role as character no-undo .
define input  parameter p-pos-type as character   no-undo .
define input  parameter p-reg-list as character no-undo .
define parameter buffer  buf_dis-thbj-rule for ub.dis-thbj-rule.

define variable v-region-type as character no-undo .
define variable v-region-code as integer   no-undo .
define variable v-region-host as integer   no-undo .
define variable v-region-ii as integer   no-undo .


_v-region-ii:
do v-region-ii = 1 to 3:
  if lookup(string(v-region-ii), p-reg-list) = 0 then next _v-region-ii.
  case v-region-ii:
    when 1 then do:
      assign
      v-region-type = p-obj-type
      v-region-code = p-obj-code
      v-region-host = p-host-code
      .
    end.
    when 2 then do:
      assign
      v-region-type = ''
      v-region-code = 0
      v-region-host = p-host-code
      .
    end.
    when 3 then do:
      assign
      v-region-type = ''
      v-region-code = 0
      v-region-host = 0
      .
    end.
  end case.
  find first buf_dis-thbj-rule no-lock where
            buf_dis-thbj-rule.obj-type = v-region-type
        and buf_dis-thbj-rule.obj-code = v-region-code
        and buf_dis-thbj-rule.host-code = v-region-host
        and buf_dis-thbj-rule.discnt-role = p-discnt-role
        and buf_dis-thbj-rule.pos-type = p-pos-type no-error.
  if available buf_dis-thbj-rule then do:
    find first buf_dis-rule no-lock where
              buf_Dis-rule.rule-num = buf_dis-thbj-rule.templ-rl-root no-error.
    if available buf_dis-rule then do:
      run create-dis-rule in this-procedure ( input buf_dis-thbj-rule.rule-num
                                            , (buf_Dis-rule.time-rule-num >= 0)) no-error .
    end.
    leave _v-region-ii.
  end.
end.
END PROCEDURE.




/* $Workfile$ e n d */