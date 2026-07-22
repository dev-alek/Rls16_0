block-level on error undo, throw.
/*

$Revision: f5e72f13272f, 2363, rls $
$Author: druban $
$Date: 2020/06/10 18:13:42 $
$Workfile: goods01.p $
$Archive: ref/goods01.p $

Проверка и создание goods

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

define input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter par-mode as character no-undo . /*{&add-def} или {&update}*/
define input parameter par-copymode as logical no-undo . /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
define input parameter par-alt-bc-mode as integer no-undo . /*нужно ли вводить ДОП БК вместе с товаром*/
define input parameter par-manual as logical no-undo . /*мз карточки товара - yes*/
define input parameter par-silence as logical no-undo . /*ругаемся вслух или ?*/
define input parameter par-import as logical no-undo . /* yes - пропускается проверка на повторный артикул */
define input parameter par-file as logical no-undo . /*идет импоррт из файла - из карточки товара*/
define input parameter par-single-record as logical no-undo . /*надо сохранить только одну запись - потом выход в справ*/
define input parameter par-host-code like ub.sysconf.host-code no-undo .
define input parameter par-obj-type like ub.clients.obj-type no-undo .
define input parameter par-obj-code like ub.clients.obj-code no-undo .
define input parameter is-goods as logical no-undo . /*товар - yes услуга no*/
define input parameter par-copy-rec as recid no-undo. /*recid записи с которой копируем*/
define input parameter par-gds-code  like ub.goods.gds-code no-undo .
define input parameter par-artic like ub.goods.artic no-undo .
define input parameter par-prod-type like ub.goods.prod-type no-undo .
define input parameter par-prod-code like ub.goods.prod-code no-undo .
define input parameter par-node-code like ub.gds-prt.node-code no-undo .
define input parameter par-grp-code like ub.gds-grp.node-code no-undo .
define input parameter par-gds-name like ub.goods.gds-name no-undo .
define input parameter par-saved-name like ub.goods.gds-name no-undo .
define input parameter par-engl-name like ub.goods.engl-name no-undo .
define input parameter par-label-name like ub.goods.label-name no-undo .
define input parameter par-chk-name like ub.goods.chk-name no-undo .
define input parameter par-alpha1 like ub.goods.alpha1 no-undo .
define input parameter par-unit-base like ub.goods.unit-base no-undo .
define input parameter par-unit-cli like ub.goods.unit-cli no-undo .
define input parameter par-max-rate like ub.goods.max-rate no-undo .
define input parameter par-min-rate like ub.goods.min-rate no-undo .
define input parameter par-cli-base-rate like ub.goods.cli-base-rate no-undo .
define input parameter par-qnty-cart like ub.goods.qnty-cart no-undo .
define input parameter par-ms-base like ub.goods.ms-base no-undo .
define input parameter par-wt-base like ub.goods.wt-base no-undo .
define input parameter par-ms-cart like ub.goods.ms-cart no-undo .
define input parameter par-wt-cart like ub.goods.wt-cart no-undo .
define input parameter par-calc-method like ub.goods.calc-method no-undo .
define input parameter par-increase-pc like ub.goods.increase-pc no-undo .
define input parameter par-NegRest as logical no-undo .
define input parameter par-obj-price-base like ub.gds-obj.price-base no-undo .
define input parameter par-obj-price-rubl like ub.gds-obj.price-rubl no-undo .
define input parameter par-okdp like ub.goods.okdp no-undo .
define input parameter par-destin like ub.goods.destin no-undo .
define input parameter par-attrib like ub.goods.attrib  no-undo .
define input parameter par-user-rule like ub.goods.user-rule no-undo .
define input parameter par-sert like ub.goods.sert no-undo .
define input parameter par-struct like ub.goods.struct no-undo .
define input parameter par-deadline like ub.goods.deadline no-undo .
define input parameter par-cond-keep-code like ub.goods.cond-keep-code no-undo .
define input parameter par-sort like ub.goods.sort no-undo .
define input parameter par-proof like ub.goods.proof no-undo .
define input parameter par-normal-wastage like ub.goods.normal-wastage no-undo .
define input parameter par-normal-waste like ub.goods.normal-waste no-undo .
define input parameter par-tnved like ub.goods.tnved no-undo .
define input parameter par-nationality like ub.goods.nationality no-undo .
define input parameter par-unit-cst like ub.goods.unit-cst no-undo .
define input parameter par-cst-base-rate like ub.goods.cst-base-rate no-undo .
define input parameter par-fbr-grp-code like ub.goods.fbr-grp-code no-undo .
define input parameter par-PS like ub.goods.ps no-undo .
define input parameter par-unq-artc as logical no-undo . /*настройка*/
define input parameter par-is-jwlr   as logical no-undo . /*в системе разрешены ювелирные изделия*/
define input parameter par-is-bttl  as logical no-undo . /*в системе разрешена стеклотара */
define input parameter par-is-ptrl  as logical no-undo . /*в системе разрешено топливо */
define input parameter par-custvalue as character no-undo . /*в системе разрешена таможня */
define input parameter par-dif-nam1 as logical no-undo . /*настройка*/
define input parameter par-dif-nam2 as logical no-undo . /*настройка*/
define input parameter par-ArtDis as logical no-undo . /*автоматический артикул*/
define input parameter par-BarDis as integer no-undo . /*главный код товара берется из артикула = 1 или gds-code = 2*/
define input-output parameter par-rec as recid no-undo .
define output parameter par-nbc like ub.bar-code.b-code no-undo . /*gds-code*/

define variable vss-revision    as character no-undo init "$Revision: f5e72f13272f, 2363, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: 2020/06/10 18:13:42 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: goods01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/goods01.p $":U .
define variable vss-description as character no-undo init "Проверка и создание goods".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/t-tnved.i }
{ trg/new-bcod.i }
{ ref/bc-f-art.i }
{ cmp/croslist.i }
{ str/tt-tax.i SHARED tt-tax full }
{ ref/grplibfn.i }
{ gbl/cur-time.i }
{ trg/clientsh.i }
{ trg/bar-codh.i }
{ gbl/getcntxt.i def }

DEFINE VARIABLE prev-value-base     as decimal no-undo .
DEFINE VARIABLE prev-value-rubl     as decimal no-undo .
DEFINE VARIABLE art-dec             as decimal no-undo .
DEFINE VARIABLE prod-bc-added       as logical no-undo init yes.
DEFINE VARIABLE is-twounit          as logical no-undo .
DEFINE VARIABLE loc#log             as logical no-undo .
DEFINE VARIABLE conf-par            as character no-undo .
DEFINE VARIABLE par-type            as character no-undo .
DEFINE VARIABLE choice              as integer no-undo .
DEFINE VARIABLE var-AvtArt like ub.bar-code.b-code no-undo .
DEFINE VARIABLE main-code  like ub.bar-code.gds-code no-undo .
DEFINE VARIABLE vattaxcd as integer no-undo.
DEFINE VARIABLE slttaxcd as integer no-undo.
define variable v-grp-name like ub.goods.grp-name no-undo .
define variable v-artic like ub.goods.artic no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-gds-rec as recid no-undo .

define buffer buf_goods for ub.goods .
define buffer buf_clients for ub.clients .
define buffer buf_gds-prt for ub.gds-prt .
define buffer buf_gds-grp for ub.gds-grp .
define buffer for-goods for ub.goods .
define buffer base_units for ub.units .
define buffer cli_units for ub.units .
define buffer grp-buf for ub.gds-grp .
define buffer similar_goods for ub.goods .
define buffer cli-buf for ub.clients .
define buffer buf_prod-bc for ub.prod-bc .
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_country for ub.country.
define buffer buf_BatchProcess for ub.BatchProcess .

&scop goods-calc-methods      {&pr-calc-cost} + {&comma-char} + ~
                              {&pr-calc-grp} + {&comma-char} + ~
                              {&pr-calc-costobj} + {&comma-char} + ~
                              {&pr-calc-rsrv} + {&comma-char} + ~
                              {&pr-calc-wbill} + {&comma-char} + ~
                              {&pr-calc-wbill-novat} + {&comma-char} + ~
                              {&pr-calc-cost-wbill} + {&comma-char} + ~
                              {&pr-calc-cost-wbill-novat} + {&comma-char} + ~
                              {&pr-calc-cost-novat} + {&comma-char} + ~
                              {&pr-calc-slt} + {&comma-char} + ~
                              {&pr-calc-slt-wbill} + {&comma-char} + ~
                              {&pr-calc-prod} + {&comma-char} + ~
                              {&pr-calc-prod-vat} + {&comma-char} + ~
                              {&pr-calc-level-prod} + {&comma-char} + ~
                              {&pr-calc-level-prod-vat} + {&comma-char} + ~
                              {&pr-calc-specif} + {&comma-char} + ~
                              {&pr-calc-fix}




_main:
do
on error undo, return error return-value
:
  assign
  vattaxcd = integer({&vat-tax-code})
  slttaxcd = integer({&slt-tax-code})
  .
  if par-mode = {&autoupdate} 
  then do on error undo, return error :
     par-mode = {&update}.
     find first buf_goods no-lock where
               recid(buf_goods) = par-rec no-error .
     if not available buf_goods then do:
        find first buf_goods no-lock where
                 buf_goods.gds-code = par-gds-code.
     end.
     if available buf_goods
     then do:
        assign 
           par-tnved      = buf_goods.tnved when par-tnved eq ?
           par-gds-name   = buf_goods.gds-name  when par-gds-name eq ? 
           par-grp-code   = buf_goods.grp-code when par-grp-code eq ?
           par-prod-type   = buf_goods.prod-type     when par-prod-type eq ?
           par-prod-code   = buf_goods.prod-code     when par-prod-code eq ?
            
           is-goods = buf_goods.gds-type eq {&gds-goods} when is-goods eq ?
           par-engl-name = buf_goods.engl-name     when par-engl-name eq ?
           par-label-name = buf_goods.label-name   when par-label-name eq ? 
           par-chk-name = buf_goods.chk-name   when par-chk-name eq ? 
           par-fbr-grp-code = buf_goods.fbr-grp-code  when par-fbr-grp-code eq ?
           par-unit-base = buf_goods.unit-base     when par-unit-base eq ?
           par-unit-cli = buf_goods.unit-cli      when par-unit-cli eq ? 
           par-min-rate = buf_goods.min-rate when par-min-rate eq ?
           par-max-rate = buf_goods.max-rate when par-max-rate eq ?
           par-cli-base-rate = buf_goods.cli-base-rate when par-cli-base-rate eq ?
           par-calc-method = buf_goods.calc-method  when par-calc-method eq ?   
           par-nationality = buf_goods.nationality   when par-nationality eq ?
           par-unit-cst = buf_goods.unit-cst     when par-unit-cst eq ?
           par-alpha1 = buf_goods.alpha1  when par-alpha1 eq ? 
           par-okdp = buf_goods.okdp       when par-okdp eq ? 
           par-increase-pc = buf_goods.increase-pc   when par-increase-pc eq ?
           par-qnty-cart =  buf_goods.qnty-cart     when par-qnty-cart  eq ?
           par-ms-base  = buf_goods.ms-base when  par-ms-base eq ?
           par-wt-base =  buf_goods.wt-base when par-wt-base eq ? 
           par-ms-cart = buf_goods.ms-cart when par-ms-cart eq ? 
           par-wt-cart = buf_goods.wt-cart when par-wt-cart eq ? 
           par-PS = buf_goods.PS      when par-PS  eq ? 
           par-NegRest = buf_goods.negative-rest when par-NegRest eq ?
           par-destin = buf_goods.destin        when par-destin  eq ? 
           par-attrib = buf_goods.attrib        when par-attrib eq ?
           par-user-rule = buf_goods.user-rule    when par-user-rule eq ?
           par-sert = buf_goods.sert          when par-sert eq ? 
           par-struct = buf_goods.struct        when par-struct eq ?
           par-deadline = buf_goods.deadline     when par-deadline eq ? 
           par-cond-keep-code = buf_goods.cond-keep-code when par-cond-keep-code eq ? 
           par-sort  = buf_goods.sort          when par-sort eq ? 
           par-proof = buf_goods.proof         when par-proof eq ? 
           par-normal-wastage = buf_goods.normal-wastage when par-normal-wastage eq ?
           par-normal-waste = buf_goods.normal-waste when par-normal-waste eq ? 
      
       
        .
     end.
  end.
  
  if par-gds-name = "" then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Название не может быть пустым !"
                                    ,"error":U
                                    ) no-error .
    if error-status :error then do:
        undo _main, return error return-value.
    end.
  end.
  /*
  if index(par-gds-name, {&double-quote}) > 0
  and r-index(par-gds-name, {&double-quote}) = index(par-gds-name, {&double-quote}) then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Название не может содержать непарную кавычку !"
                                    ,"error":U
                                    ) no-error .
    if error-status :error then do:
        undo _main, return error return-value.
    end.
  end.
  */
  if
  index(par-gds-name, {&new-line}) > 0
  or
  index(par-gds-name, {&carriage-return}) > 0
  or
  index(par-engl-name, {&new-line}) > 0
  or
  index(par-engl-name, {&carriage-return}) > 0
  or
  index(par-label-name, {&new-line}) > 0
  or
  index(par-label-name, {&carriage-return}) > 0
  or
  index(par-chk-name, {&new-line}) > 0
  or
  index(par-chk-name, {&carriage-return}) > 0
  then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Поля Названий не могут содержать символы перевода строки и возврата каретки!"
                                    ,"error":U
                                    ) no-error .
    if error-status :error then do:
        undo _main, return error return-value.
    end.
  end.



  find first buf_gds-prt share-lock where
            buf_gds-prt.node-code = par-node-code no-error .

  if not available buf_gds-prt then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Шкала выбрана неправильно !"
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
        undo _main, return error return-value.
    end.
  end.

  find first buf_gds-grp share-lock where
              buf_gds-grp.node-code = par-grp-code no-error .
  if NOT available buf_gds-grp then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Не выбрана группа ( по классификатору товаров ) !"
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
        undo _main, return error return-value.
    end.
  end.
  if can-find( first grp-buf where grp-buf.upper-code = buf_gds-grp.node-code ) then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,("Выбранная Вами группа" + {&new-line} +
                                      "делится на более детальные группы :"  + {&new-line} +
                                      "в такую группу нельзя добавлять товар !"
                                      )
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
        undo _main, return error return-value.
    end.

  end.
  if par-fbr-grp-code <> ? then do:
    find first buf_fbr-gds-grp no-lock where
                buf_fbr-gds-grp.node-code = par-fbr-grp-code
         AND    buf_fbr-gds-grp.obj-type = "":U
         and    buf_fbr-gds-grp.obj-code = 0
         no-error .
    if NOT available buf_fbr-gds-grp then do:
      run do-message in this-procedure(
                                        par-silence
                                      ,"Неверно выбрана группа блюд( по рубрикатору блюд ) !"
                                      ,"error":U
                                      ) no-error .
      if error-status:error then do:
          undo _main, return error return-value.
      end.
    end.
    if can-find( first buf_fbr-gds-grp where buf_fbr-gds-grp.upper-code = par-fbr-grp-code ) then do:
      run do-message in this-procedure(
                                        par-silence
                                      ,("Выбранная Вами группа блюд" + {&new-line} +
                                        "делится на более детальные группы :"  + {&new-line} +
                                        "в такую группу нельзя добавлять товар !"
                                        )
                                      ,"error":U
                                      ) no-error .
      if error-status:error then do:
          undo _main, return error return-value.
      end.

    end.
  end.



  if NOT can-find( ub.units where ub.units.unit-name = par-unit-base ) then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Не выбрана учетная единица измерения !"
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.

  if NOT can-find( ub.units where ub.units.unit-name =  par-unit-cli ) then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Не выбрана единица измерения поставщика !"
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.

  FIND FIRST base_units WHERE
            base_units.unit-name = par-unit-base
  NO-LOCK NO-ERROR .
  if ( available base_units ) then do:
    if  can-do( base_units.type, {&petrolium}) then do:
      { gbl/chk-actg.i
      ibs.th.gbl.gbl-var:g#db-num
      ibs.th.gbl.gbl-var:g#userid
      {&action-head-code-main}
      'actn_reference-petrolium_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      false
      loc#log
      }
      if not loc#log then undo _main, return error "Отсутствуют права на работу с топливным товаром".
      if not par-is-ptrl then do:
        run do-message in this-procedure(
                                            par-silence
                                          ,"В системе запрещена работа с топливным товаром"
                                          ,"error":U
                                          ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
    end.
    if par-unq-artc AND can-do(base_units.type, {&weight}) then do:
      run do-message in this-procedure(
                                          par-silence
                                        ,("В Вашей конфигурации диапазон весовых кодов" + {&new-line} +
                                          "уже используется несовместимым образом," + {&new-line} +
                                          "поэтому ввод весовых товаров ЗАПРЕЩЕН!")
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if can-do( base_units.type, {&serial}) AND ( par-unit-cli <> par-unit-base ) then do:
      run do-message in this-procedure(
                                          par-silence
                                        ,("Для товаров с серийными номерами" + {&new-line} +
                                          "учетная единица измерения"  + {&new-line} +
                                          "и единица измерения  поставщика"  +  {&new-line} +
                                          "должны быть ОДИНАКОВЫ !")
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.

    end.
    assign
    is-twounit = (lookup({&twounit}, base_units.type) > 0)
    .
  end.

  FIND FIRST cli_units No-LOCK WHERE
            cli_units.unit-name = par-unit-cli No-ERROR.
  if NOT can-do(base_units.type, {&petrolium}) = can-do(cli_units.type, {&petrolium}) THEN DO:
    run do-message in this-procedure(
                                        par-silence
                                      ,("Для товара eдиница измерения поставщика и основная единица измерения" + {&new-line} +
                                        "могут быть либо обе топливные либо обе нетопливные!")
                                      ,"error":U
                                      ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  END.

  if  LOOKUP({&petrolium}, base_units.type) > 0  AND (LOOKUP({&divisional}, cli_units.type ) = 0 ) then do:
    run do-message in this-procedure(
                                        par-silence
                                      ,("Для товаров типа топливо  единица измерения поставщика может быть только типа " + {&new-line} +
                                        {&petrolium} + {&comma-char} + {&divisional} + "!")
                                      ,"error":U
                                      ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.


  if  LOOKUP({&twounit}, base_units.type) > 0  then do:
    if not par-is-jwlr then do:
      run do-message in this-procedure(
                                          par-silence
                                        ,"В системе запрещена работа с товаром с двумя единицами измерения"
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    IF (LOOKUP({&pieces}, cli_units.type ) = 0 ) then do:
      run do-message in this-procedure(
                                          par-silence
                                        ,( "Для товаров, у которых тип основной единицы измерения - " + {&twounit} + {&new-line} +
                                          " единица измерения поставщика может быть только типа " + {&pieces} + "!"
                                        )
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error ("unit-cli":U + {&delim-par} + return-value).
      end.
    END.
    /*
    if par-max-rate = 0 OR
      par-min-rate = 0 then do:
      run do-message in this-procedure(
                                          par-silence
                                        ,("Для товаров, у которых тип основной единицы измерения - " + {&twounit} +
                                          "должны быть определены "  + {&new-line} +
                                          "<<Max кол. в штуке>> и <<Min кол. в штуке>>")
                                        ,"error":U
                                        ).
        if par-max-rate = 0 then do:
          if error-status:error then do:
            undo _main, return error ("min-rate":U + {&nws-delim} + return-value).
          end.
        end.
        else do:
          if error-status:error then do:
            undo _main, return error ("max-rate":U + {&nws-delim} + return-value).
          end.
        end.
    END.
    */
    if par-max-rate <= par-min-rate AND
      (par-max-rate <> 0 AND
      par-min-rate <> 0)
    then do:
      run do-message in this-procedure(
                                        par-silence
                                        ,("Для товаров, у которых тип основной единицы измерения - " + {&twounit} + {&new-line} +
                                        "max кол-во дробного в штуке должно быть больше min кол-ва дробного в штуке !")  /*пробелы не стирать!!!*/
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    IF (par-max-rate) >= 2 * (par-min-rate) AND
      (par-max-rate <> 0 AND
        par-min-rate <> 0)
    then do:
      run do-message in this-procedure(
                                        par-silence
                                        ,("Для товаров, у которых тип основной единицы измерения - " + {&twounit} + {&new-line} +
                                          "max кол-во дробного в штуке не может быть больше чем в 2 раза min кол-ва дробного в штуке!")
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
  end. /*LOOKUP({&twounit}, units.type) > 0  */

  if  LOOKUP({&bottle}, base_units.type) > 0  then do:
    if not par-is-bttl then do:
      run do-message in this-procedure(
                                        par-silence
                                        ,"В системе запрещена работа с товаром с раздельным учетом стеклотары"
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    /*нужно ли ограничивать единицу поставщика для стеклотарных товаров*/

    IF (LOOKUP({&bottle}, cli_units.type ) = 0 ) then do:
      run do-message in this-procedure(
                                        par-silence
                                        ,("Для товаров, у которых тип основной единицы измерения - " +  {&bottle} + {&new-line} +
                                        " единица измерения поставщика может быть только типа " + {&bottle} + "!")
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error ("unit-cli":U + {&delim-par} + return-value).
      end.
    END.
  end. /*LOOKUP({&bottle}, units.type) > 0  */

  IF (LOOKUP({&bottle}, base_units.type ) = 0 ) AND (LOOKUP({&bottle}, cli_units.type ) > 0 )  then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,("Для товаров, у которых тип основной единицы измерения -  не " + {&bottle} + {&new-line} +
                                          " единица измерения поставщика не может быть типа " + {&bottle} + "!")
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error ("unit-cli":U + {&delim-par} + return-value) .
    end.
  end.

  if par-cli-base-rate = 0 then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,"Коэффициент пересчета единиц измерения не может быть нулевым !"
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.

  if
  par-calc-method = ?
  or
  lookup(par-calc-method, {&goods-calc-methods}) = 0 then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,("Неверное значение способа расчета цены" +
                                        (if par-calc-method = ?
                                        then {&question-mark}
                                        else par-calc-method) + {&new-line} +
                                          "требуется указать одно из " + {&new-line} +
                                          {&goods-calc-methods})
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.

  /*Проверка при выходе из таможни*/
 if (par-file = yes and par-tnved <> "":U)
  or par-custvalue = "yes" then do:
    IF LENGTH(TRIM(par-tnved)) <> 10 THEN DO:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Код ТНВЭД должен быть 10 символов."
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
  END.
  IF par-custvalue = "yes" THEN DO:
    if not CAN-FIND(FIRST TT-tnved WHERE
                          TT-tnved.tnved = par-tnved no-lock) then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"В дополнительной информации по товару обязательно следует указать код ТНВЭД из справочника."
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    END.
    IF par-nationality <> "российский" and
      par-nationality <> "иностранный" then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Не определен статус товара - российский или иностранный."
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    END.
    if NOT can-find(ub.units where
                    ub.units.unit-name = par-unit-cst no-lock) then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Не задана таможенная единица"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if par-unit-cst =  par-unit-base then do:
      if par-cst-base-rate = 0 then par-cst-base-rate = 1.
      if par-cst-base-rate <> 1 then do:
        loc#log = no.
        run do-message in this-procedure(
                                            par-silence
                                            ,"Таможенная единица равна базовой. Установить коэффициент в 1 ?"
                                            ,"question":U
                                            ) no-error .
        if loc#log then par-cst-base-rate = 1.
        else undo _main, return error.
      end.
    end.
    if par-cst-base-rate = 0 then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Не задан коэффициент пересчета таможенной единицы."
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
  END.
  find first buf_clients no-lock where
            buf_clients.obj-type = par-prod-type AND
            buf_clients.obj-code = par-prod-code no-error .
  if NOT available buf_clients then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,"Не выбран или неизвестен производитель !"
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.
  find first buf_country no-lock where
            buf_country.alpha1 = par-alpha1 no-error .
  if not available buf_country then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,"Не выбрана или неизвестна страна !"
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.

  if par-mode = {&add-def} then do:

    if par-copymode then do:
      find first for-goods no-LOCK WHERE
                recid(for-goods) = par-copy-rec no-error .
      if not avail for-goods then do:
        run do-message in this-procedure(
                                            par-silence
                                            ,"Не найден товар, с которого производится копирование"
                                            ,"error":U
                                            ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
    end.
    if buf_clients.obj-type = {&shop}
    or buf_clients.obj-type = {&stock}
    then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Склад/магазин не может быть производителем !"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if cross-list( {&serial_weight_petrolium_twounit_bottle}, base_units.type, {&comma-char} ) AND
      buf_gds-prt.node-name <> {&empty-scale} then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,("У товаров с серийными номерами, весовых товаров, " + {&new-line} +
                                          "топлива, товаров, учитываемых по двум ед. изм."  + {&new-line} +
                                          " и товаров с учетом стеклотары" + {&new-line} +
                                          "может быть определена"  + {&new-line} +
                                          'только <ПУСТАЯ> шкала признаков.')
                                          ,"error":U
                                          ) no-error .

      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if NOT is-goods AND NOT par-file AND
      ( par-obj-price-base = 0 OR
        par-obj-price-rubl = 0 ) then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Учетная цена не может быть нулевой !"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    IF trim(par-artic) <> par-artic then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Артикул товара содержит пробелы слева или справа или другие запрещенные символы"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if length(par-artic) > 20 then do:
      run do-message in this-procedure(
                                          par-silence
                                          , substitute("Длина артикула товара &1 = &2 больше допаустимой длины (&3)"
                                                       ,par-artic
                                                       ,length(par-artic)
                                                       ,20)
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    IF par-dif-nam1 AND par-gds-name = par-saved-name then do:
      if par-ArtDis then do:
        if par-copymode and
        (for-goods.prod-type = buf_clients.obj-type AND
        for-goods.prod-code = buf_clients.obj-code) then do:
          run do-message in this-procedure(
                                              par-silence
                                              ,"Копирумый товар имеет то же название и производителя, что и его аналог!"
                                              ,"error":U
                                              ) no-error .
        end.
        else do:
          run do-message in this-procedure(
                                              par-silence
                                              ,"Вы только что ввели товар с таким названием !"
                                              ,"error":U
                                              ) no-error .
        end.
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
      else do:
        run do-message in this-procedure(
                                            par-silence
                                            ,("Вы уверены, что хотите добавить добавить еще один товар с названием" + {&new-line} +
                                              par-saved-name)
                                            ,"question":U
                                            ) no-error .
        if not loc#log then undo _main, return error.
      end.
    end.
    if par-ArtDis then do:
      run gen-b-code IN THIS-PROCEDURE (
                                        input {&gbl-bc-code}
                                        ,output par-nbc
                                      ) no-error.
      if error-status:error then undo _main, return error "Ошибка при создании кода из диапазона собственных кодов" .
    end.
    assign
    var-AvtArt = par-nbc
    .
    find first similar_goods no-lock where similar_goods.artic = (IF par-ArtDis then string(par-nbc) else par-artic)
                        and similar_goods.prod-type = buf_clients.obj-type
                        and similar_goods.prod-code = buf_clients.obj-code no-error .
    if available similar_goods then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,substitute("Товар с артикулом &1 и производителем &2&3 уже есть в справочнике !"
                                                     ,similar_goods.artic
                                                     ,similar_goods.prod-type
                                                     ,similar_goods.prod-code)
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error ("artic|prod-type|prod-code":U + {&delim-par} + return-value).
      end.
    end.

    { trg/btpr_upd.i
      &btpr-status="find"
      &btpr-type="{&btpr-type-ren-art}"
      &btpr-table="buf_BatchProcess"
      &btpr-lock-option="exclusive-lock"
      &charkey_one=par-artic
      &charkey_two=par-prod-type
      &key#_one=par-prod-code
    }
    if available buf_BatchProcess then do:
      run do-message in this-procedure(
                                        par-silence
                                       ,substitute("Товар с артикулом &1 и производителем &2 &3 создать нельзя (ren-art) !"
                                                   ,par-artic
                                                   ,par-prod-type
                                                   ,par-prod-code)
                                       ,"error":U
                                      ) no-error .
      if error-status:error then do:
          undo _main, return error return-value.
      end.
    end.

    if par-import <> yes
    then do:
        FIND first similar_goods WHERE
                similar_goods.artic = par-artic NO-LOCK no-error.
        if available similar_goods then do:
        if par-unq-artc then do:
            /* В СовМехКастории && trd артикулы используются на кассе как коды,
            поэтому дб уникальны и должна быть включена настройка unq-artc*/
            run do-message in this-procedure(
                                                par-silence
                                                ,"Товар с таким артикулом уже есть в справочнике !"
                                                ,"error":U
                                                ) no-error .
            if error-status:error then do:
            undo _main, return error ("artic|unq-artc":U + {&delim-par} + return-value).
            end.
        end.
        FIND FIRST cli-buf WHERE
                    cli-buf.obj-type = similar_goods.prod-type AND
                    cli-buf.obj-code = similar_goods.prod-code NO-LOCK.
        loc#log = no.
        if not par-manual then do:
            run do-message in this-procedure(
                                                par-silence
                                                ,(substitute("Вы добавляете товар с артикулом &1 для производителя &2&3: &4"
                                                            ,par-artic
                                                            ,par-prod-type
                                                            ,par-prod-code
                                                            ,par-gds-name
                                                            )
                                                + {&new-line} + {&new-line} +
                                                substitute("Товар с таким артикулом уже есть в справочнике для производителя &1&2: &3"
                                                            , cli-buf.obj-type
                                                            , cli-buf.obj-code
                                                            , similar_goods.gds-name
                                                            )
                                                + {&new-line} + {&new-line} +
                                                "Вы уверены, что Вы добавляете ДРУГОЙ, а не тот же самый товар ?")
                                                ,"question":U
                                                ) no-error .
            if NOT loc#log then do:
            undo _main, return error (if par-silence
                                      then  substitute("Товар с таким артикулом уже есть в справочнике для производителя &1&2: &3"
                                                            , cli-buf.obj-type
                                                            , cli-buf.obj-code
                                                            , similar_goods.gds-name
                                                            )
                                      else "artic":U).
            end.
        end.
        else do:
            run gbl/d-askw.w (input "Внимание  !!",
                        input (substitute("Вы добавляете товар с артикулом &1 для производителя &2&3: &4"
                                        ,par-artic
                                        ,par-prod-type
                                        ,par-prod-code
                                        ,par-gds-name
                                        )
                            + {&new-line} + {&new-line} +
                            substitute("Товар с таким артикулом уже есть в справочнике для производителя &1&2: &3"
                                        , cli-buf.obj-type
                                        , cli-buf.obj-code
                                        , similar_goods.gds-name
                                        )
                            ),
                        input "|",
                        input "Все равно добавить" +
                               (if par-file  then "|Перейти к СЛЕДУЮЩЕМУ|ВЫЙТИ из режима ИМПОРТА" else "|Отказ"),
                        input (if par-file  then "||" else "|"),
                        input 1,
                        input (if par-file  then 3 else 2),
                        output choice).
            CASE choice:
            when 1 then do:
                /*продолжаем сохранять*/
            end.
            when 2 then do:
                undo _main, return error "artic|next":U.
            end.
            when 3 then do:
                undo _main, return error "artic|quit":U.
            end.
            end CASE.
        end.
        end.
    end.        /* if par-import <> yes */
    if ( NOT par-ArtDis ) AND ( par-artic = "":U ) then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Артикул не может быть пустым !"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if (not par-ArtDIs AND par-unq-artc) OR (par-BarDis = 1) then do:
      art-dec = decimal (par-artic) no-error.
      if art-dec = 0 or art-dec = ? or
        art-dec <> trunc(art-dec, 0) OR
        ((par-BarDIs = 1 ) AND (length (par-artic) < 6  OR
          length (par-artic) > 7) AND
          (avail base_units AND lookup({&petrolium}, base_units.type) = 0)
        ) then do:
        run do-message in this-procedure(
                                          par-silence
                                         ,substitute("Неверный и/или нецифровой артикул &1 при создании товара с кодом=артикулу&2" +
                                                      "Артикул не может=0, а артикул не может =?, артикул не может быть < 100000&3" +
                                                      "Артикул не может быть> 9999999"
                                                      , par-artic
                                                      , {&new-line}
                                                      , {&new-line}
                                                      )

                                          ,"error":U
                                          ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
    end.
    if par-bardis = 2 then do:
/*      if par-gds-code = 0 or                                                                                                                     */
/*      par-gds-code = ?                                                                                                                           */
/*      or par-gds-code < 100000                                                                                                                   */
/*      or par-gds-code > 999999999                                                                                                                */
/*      then do:                                                                                                                                   */
/*        run do-message in this-procedure(                                                                                                        */
/*                                          par-silence                                                                                            */
/*                                          ,substitute("Неверный код товара &1 при создании товара с кодом, определенным пользователем&2" +       */
/*                                                      "Код не может=0, код не может=?, код не может быть < 100000, код не может быть > 999999999"*/
/*                                                      , par-gds-code                                                                             */
/*                                                      , {&new-line}                                                                              */
/*                                                      )                                                                                          */
/*                                          ,"error":U                                                                                             */
/*                                          ) no-error .                                                                                           */
/*        undo _main, return error return-value.                                                                                                   */
/*      end.                                                                                                                                       */
    end.
  end.   /*if par-mode = {&add-def} then do:???*/
  if par-mode = {&add-def} then do:
    do on error undo, return error :
      RUN grplib-get-full-name in this-procedure (input buf_gds-grp.node-code, output v-grp-name).
      if (par-BarDIs > 0 )then do:
        loc#log = no.
        run  chk-b-code in THIS-PROCEDURE (
                                             par-silence
                                            ,(if par-bardis = 1
                                             then integer(par-artic)
                                             else par-gds-code)
                                            ,output loc#log
                                          ) no-error.
        if error-status:error then do:
          run do-message in this-procedure(
                                            par-silence
                                            ,(if par-bardis = 1
                                              then substitute("Некорректный артикул товара &1 при создании товара с кодом=артикулу - невозможно сгенерить код &1&2&3"
                                                             , par-artic
                                                             ,{&new-line}
                                                             , return-value
                                                             )
                                              else substitute("Некорректный код товара &1 при создании товара с кодом, определенным пользователем - невозможно сгенерить код &1:&2&3"
                                                            , par-gds-code
                                                            , {&new-line}
                                                            , return-value
                                                            )
                                             )
                                            ,"error":U
                                            ) no-error .
          if error-status:error then do:
            undo _main, return error return-value.
          end.
        end.
        /*проверка возможности создания искуственного бар-кода*/
        IF can-FIND(FIRST ub.bar-code No-LOCK WHERE
                          ub.bar-code.b-code = (if par-bardis = 1 then integer(par-artic) else par-gds-code)) OR
          NOT loc#log
        then do:
          run do-message in this-procedure(
                                            par-silence
                                            ,(if par-bardis = 1
                                              then substitute("Неверный артикул товара &1 при создании товара с кодом=артикулу - уже есть товар с кодом &1 или невозможно сгенерить код &1", par-artic)
                                              else substitute("Неверный код товара &1 при создании товара с кодом, определенным пользователем - уже есть товар с кодом &1 или невозможно сгенерить код &1", par-gds-code)
                                             )

                                            ,"error":U
                                            ) no-error .
          if error-status:error then do:
            undo _main, return error return-value.
          end.
        end.
      end.
      CREATE buf_goods.
      assign
      buf_goods.gds-type = if is-goods then {&gds-goods} else {&gds-office}
      buf_goods.artic = ( if par-ArtDis
                          then string( var-AvtArt )
                          else par-artic )
      v-artic                 = buf_goods.artic
      buf_goods.okdp          = par-okdp
      buf_goods.prod-type     = buf_clients.obj-type
      buf_goods.prod-code     = buf_clients.obj-code
      buf_goods.grp-code      = buf_gds-grp.node-code
      buf_goods.gds-name      = par-gds-name
      buf_goods.engl-name     = par-engl-name
      buf_goods.prt-root      = buf_gds-prt.upper-code
      buf_goods.unit-base     = par-unit-base
      buf_goods.unit-cli      = par-unit-cli
      buf_goods.cli-base-rate = par-cli-base-rate
      buf_goods.calc-method   = par-calc-method
      buf_goods.increase-pc   = (if par-calc-method = {&pr-calc-grp} then 0 else par-increase-pc)
      buf_goods.qnty-cart     = par-qnty-cart
      buf_goods.ms-base       = par-ms-base
      buf_goods.wt-base       = par-wt-base
      buf_goods.ms-cart       = par-ms-cart
      buf_goods.wt-cart       = par-wt-cart
      buf_goods.PS            = par-PS
      buf_goods.PS = REPLACE(buf_goods.PS, {&new-line}, " ")
      buf_goods.grp-name      = ""
      buf_goods.cost-calc = {&FIFO}
      buf_goods.negative-rest = par-NegRest
      buf_goods.label-name = if par-label-name = ""
                            then buf_goods.gds-name
                            else par-label-name
      buf_goods.chk-name = if par-chk-name = ""
                          then replace(replace(buf_goods.gds-name, chr(39), ""), '"', "")
                          else par-chk-name
      buf_goods.alpha1 = par-alpha1
      buf_goods.min-rate = if LOOKUP({&twounit}, base_units.type) > 0
                          then par-min-rate
                          else 0
      buf_goods.max-rate = if LOOKUP({&twounit}, base_units.type) > 0
                          then par-max-rate
                          else 0
      buf_goods.grp-name = v-grp-name
      buf_goods.destin        = par-destin
      buf_goods.attrib        = par-attrib
      buf_goods.user-rule     = par-user-rule
      buf_goods.sert          = par-sert
      buf_goods.struct        = par-struct
      buf_goods.deadline      = par-deadline
      buf_goods.cond-keep-code = par-cond-keep-code
      buf_goods.sort          = par-sort
      buf_goods.proof          = par-proof
      buf_goods.normal-wastage = par-normal-wastage
      buf_goods.normal-waste = par-normal-waste
      buf_goods.unit-cst      = if par-custvalue = "yes"
                                then par-unit-cst else "":U
      buf_goods.tnved         = if par-custvalue = "yes" or
                                (par-file = yes and par-tnved <> "":U)
                                then par-tnved
                                else "":U
      buf_goods.cst-base-rate = if par-custvalue = "yes"
                                then par-cst-base-rate
                                else 0
      buf_goods.nationality   = if par-custvalue = "yes"
                                then par-nationality
                                else "":U
      buf_goods.fbr-grp-code  = par-fbr-grp-code
      v-gds-rec = recid (buf_goods)
      par-rec = recid (buf_goods)
      v-gds-code = buf_goods.gds-code
      .
      if not buf_clients.is-prod then do:
        FIND current buf_clients SHARE-LOCK NO-ERROR .
        if available buf_clients
        and  not buf_clients.is-prod then do:
          run clientsh_write-clients-proc in this-procedure  (
                                                       buffer buf_clients
                                                      ,input "":U /*p-source-type*/
                                                      ,input "":U  /*p-source-ref*/
                                                      ) .
          assign
          buf_clients.is-prod = yes.
        end.
        FIND current buf_clients No-LOCK NO-ERROR .
      end.
      RUN cre-bc in this-procedure (
                                    input buf_gds-prt.node-code
                                    ,input par-nbc
                                    ,input par-ArtDIs
                                    ,input var-AvtArt
                                    ,input par-BarDis
                                    ,output main-code
                                    ) no-error.
      if error-status:error then do:
        run do-message in this-procedure(
                                            par-silence
                                            ,"Ошибка при создании главного кода товара: " + return-value
                                            ,"error":U
                                            ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
      par-gds-code = v-gds-code.
      if not is-goods and not par-file then do:
        /*услуга*/
        { gbl/gdscr.i par-obj-type par-obj-code  v-artic
                  buf_clients.obj-type buf_clients.obj-code  buf_gds-prt.node-code  ub.gds-obj ub.prt-obj }
        if avail gds-obj then do:
          assign
          gds-obj.price-base = par-obj-price-base
          gds-obj.price-rubl = par-obj-price-rubl
          .
          run str/callnews.p
            ( input "gds-obj"
              ,input (buffer gds-obj:handle)
            ).
        end.
      end.
      if par-alt-bc-mode > 0 then do:
        if par-alt-bc-mode = 1 then do:
          run ref/alt-bc.w (
                        input parparentproc
                        ,input par-obj-type
                        ,input par-obj-code
                        ,input main-code
                        ).
        end.
        if par-dif-nam2 or par-alt-bc-mode = 2 then do: /*исключение дублей*/
          REPEAT while prod-bc-added:
            run dif-nam2-proc in this-procedure(
                                                 input par-dif-nam2
                                                ,input par-gds-name
                                                ,input base_units.type
                                                ,input main-code
                                                ) no-error .
            if error-status:error then do:
              run gbl/d-askw.w (input "Рекомендация",
                          input ("В соответствии с настройками системы" + {&new-line} +
                                  "необходимо ввести доп.бар-код" + {&new-line} +
                                  "( уже был сохранен товар с таким же названием)!"),
                          input "|",
                          input "Ввести Доп.БК|Продолжить без Доп.БК",
                          input "|",
                          input 1,
                          input 2,
                          output choice).
              if choice = 1 then do:
                assign
                prod-bc-added = yes
                .
              end.
              else do:
                prod-bc-added = no.
              end.
              if prod-bc-added then do:
                run ref/alt-bc.w (
                              input parparentproc
                              ,input par-obj-type
                              ,input par-obj-code
                              ,input main-code
                            ).
                prod-bc-added = no.
              end.
            end. /*error-status:error */
            else  do:
              assign
              prod-bc-added = no.
            end.
          END. /*repeate*/
        end. /* par-dif-nam2 or par-alt-bc-mode = 2 */
      end. /*par-alt-bc-mode > 0 */
      if par-unq-artc and NOT can-do( base_units.type, {&weight} ) then do:
        define variable v-b-str as character no-undo .
        define variable v-pbc-rid as recid no-undo .
        assign
          v-b-str = v-artic
          v-pbc-rid = ?
        .
        find first buf_goods exclusive-lock where
                  recid(buf_goods) = par-rec no-error .
        run trg/prod-bc1.p (
                            input  parparentproc
                            ,input par-silence /*p-silent*/
                            ,input no /*dif-pbc*/
                            ,input no  /*pbc-veto*/
                            ,input no  /*send-ref*/
                            ,input 'unq-artc' /**p-cdrg-type*/
                            ,input "" /*ean-type*/
                            ,buffer buf_goods
                            ,input main-code
                            ,input-output v-b-str
                            ,output v-pbc-rid
                            ) no-error.
        if error-status :error
        or v-pbc-rid = ? then do:
          run do-message in this-procedure(
                                           input par-silence
                                          ,input return-value
                                          ,input "error":U
                                          ) no-error .
          if error-status:error then do:
            undo _main, return error return-value.
          end.
        end.
      end.
    end. /*do on error undo, return error :*/
  end. /*add-def */

  if par-mode = {&update} then do:
    do on error undo, return error :
      find first buf_goods exclusive-lock where
                recid(buf_goods) = par-rec no-error .
      if not available buf_goods then do:
        find first buf_goods exclusive-lock where
                 buf_goods.gds-code = par-gds-code.
      end.
      assign
      par-nbc = buf_goods.gds-code
      .
      if buf_goods.gds-type = {&gds-office} and not par-file then do:
        if not par-file then do :
          if ( par-obj-price-base <> 0 ) AND
            ( par-obj-price-rubl <> 0 ) AND
            ( par-obj-price-base <> ? ) AND
            ( par-obj-price-rubl <> ? ) then .
          else do:
            run do-message in this-procedure(
                                                par-silence
                                                ,"Учетная цена не может быть нулевой !"
                                                ,"error":U
                                                ) no-error .
            if error-status:error then do:
              undo _main, return error return-value.
            end.
          end.
        end.
        { gbl/gdscr.i par-obj-type par-obj-code  buf_goods.artic
                  buf_clients.obj-type buf_clients.obj-code  buf_gds-prt.node-code  ub.gds-obj ub.prt-obj}

        if not is-goods then do:
          assign
          prev-value-base = gds-obj.price-base
          prev-value-rubl = gds-obj.price-rubl
          .
        end.
        IF
        ( par-obj-price-base <> prev-value-base OR
        par-obj-price-rubl <> prev-value-rubl ) then do:
          if avail gds-obj then do:
            FIND Current gds-obj exclusive-lock No-WAIT NO-ERROR.
            if not avail gds-obj then undo _main, return error.
            assign
            gds-obj.price-base = par-obj-price-base
            gds-obj.price-rubl = par-obj-price-rubl
            .
            run str/callnews.p
              ( input "gds-obj"
               ,input (buffer gds-obj:handle)
              ).
          end.
          else undo _main, return error.
        end.
      end. /*gds-office*/
      assign
      buf_goods.grp-code    = buf_gds-grp.node-code
      buf_goods.okdp        = par-okdp
      buf_goods.gds-name    = par-gds-name
      buf_goods.engl-name   = par-engl-name
      buf_goods.label-name   = par-label-name
      buf_goods.chk-name   = par-chk-name
      buf_goods.alpha1   = par-alpha1
      buf_goods.prt-root    = buf_gds-prt.upper-code
      buf_goods.unit-cli    = par-unit-cli
      buf_goods.cli-base-rate = par-cli-base-rate
      buf_goods.calc-method  = par-calc-method
      buf_goods.increase-pc   = (if par-calc-method = {&pr-calc-grp} then 0 else par-increase-pc)
      buf_goods.qnty-cart = par-qnty-cart
      buf_goods.ms-base = par-ms-base
      buf_goods.wt-base = par-wt-base
      buf_goods.ms-cart = par-ms-cart
      buf_goods.wt-cart = par-wt-cart
      buf_goods.PS      = par-PS
      buf_goods.PS = REPLACE(buf_goods.PS, {&new-line}, " ")
      buf_goods.grp-name = ""
      buf_goods.negative-rest = par-NegRest
      buf_goods.min-rate = if is-twounit
                            then par-min-rate
                            else buf_goods.min-rate
      buf_goods.max-rate = if is-twounit
                            then par-max-rate
                            else buf_goods.max-rate
      buf_goods.destin        = par-destin
      buf_goods.attrib        = par-attrib
      buf_goods.user-rule     = par-user-rule
      buf_goods.sert          = par-sert
      buf_goods.struct        = par-struct
      buf_goods.deadline      = par-deadline
      buf_goods.cond-keep-code = par-cond-keep-code
      buf_goods.sort          = par-sort
      buf_goods.proof         = par-proof
      buf_goods.normal-wastage = par-normal-wastage
      buf_goods.normal-waste = par-normal-waste
      buf_goods.unit-cst      = par-unit-cst
      buf_goods.tnved         = par-tnved
      buf_goods.cst-base-rate = par-cst-base-rate
      buf_goods.nationality   = par-nationality
      buf_goods.fbr-grp-code  = par-fbr-grp-code
      v-gds-rec = recid (buf_goods)
      .
      RUN grplib-get-full-name in this-procedure (input buf_gds-grp.node-code, output buf_goods.grp-name).
      run ref/dtaxgdsu.p (
                     input (if par-single-record then yes else no)
                    ,input par-host-code
                    ,input par-obj-type
                    ,input par-obj-code
                    ,input v-gds-rec
                    ,input (if par-copymode then for-goods.gds-code else 0)
                    ) no-error.
      if error-status:error then do:
        run do-message in this-procedure(
                                            par-silence
                                            , substitute("Ошибка при создании/сохранении налогов!&1&2&1&3"
                                             , {&new-line}
                                             , return-value
                                             , error-status:get-message(1))
                                            ,"error":U
                                            ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
    end.
  end.
end. /*_main*/


PROCEDURE cre-bc :
define input parameter par-c like ub.gds-prt.node-code no-undo.
define input parameter par-nbc like ub.bar-code.gds-code no-undo .
define input parameter par-ArtDis as logical no-undo .
define input parameter par-ArtAvt like ub.bar-code.b-code no-undo .
define input parameter par-BarDis as integer no-undo .
define output parameter par-main-code like ub.bar-code.gds-code no-undo .
/*ВНИМАНИЕ!!!! теперь процедура вызывается только ОДИН раз и генерит один - основной бар-код*/
DEFINE VARIABLE var-bc-code as integer no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-unit-base like ub.goods.unit-base no-undo .
define variable v-goods-recid as recid no-undo .
define buffer buf_bar-code for ub.bar-code.

_bc:
do transaction on error undo, return error :
  IF NOT par-ArtDis and par-Bardis = 0 then do:
    run gen-b-code IN THIS-PROCEDURE (
                                       input {&gbl-bc-code}
                                      ,output var-bc-code
                                      ) no-error.
    if error-status:error then do:
      undo _bc, return error return-value .
    end.
  end.
  else do:
    assign
    var-bc-code = (if par-BarDIs = 1
                   then integer(buf_goods.artic)
                   else (if par-bardis = 2
                         then integer(par-gds-code)
                         else par-nbc)
                  )
    .
  end.
  assign
  par-nbc = var-bc-code
  .

  assign
  buf_goods.gds-code  = if par-ArtDis
                        then par-ArtAvt
                        else var-bc-code
  v-gds-code          = buf_goods.gds-code
  v-unit-base         = buf_goods.unit-base
  .
  create buf_bar-code.
  assign
  buf_bar-code.b-code        = var-bc-code
  buf_bar-code.node-code     = par-c
  buf_bar-code.gds-code      = v-gds-code
  buf_bar-code.in-code       = "":U
  buf_bar-code.part-code     = "":U
  buf_bar-code.unit-cli      = v-unit-base
  buf_bar-code.cli-base-rate = 1
  par-main-code = var-bc-code
  buf_bar-code.stts          = integer({&hn-delete})
  .
  release buf_bar-code no-error .
  if error-status:error then do:
    undo _bc, return error vss-workfile + "Ошибка при создании бар-кода." + {&new-line} + return-value + {&new-line} + trim(error-status :get-message(1)).
  end.
  assign
  v-goods-recid = recid(buf_goods).
  release buf_goods no-error .
  if error-status:error then do:
    undo _bc, return error vss-workfile + "Ошибка при создании товара." + {&new-line} + return-value + {&new-line} + trim(error-status :get-message(1)).
  end.

  find first buf_bar-code where buf_bar-code.b-code = var-bc-code.
  assign
  buf_bar-code.stts = 0
  .


  run ref/dtaxgdsu.p (
                  if par-single-record then yes else no
                ,par-host-code
                ,par-obj-type
                ,par-obj-code
                ,v-goods-recid
                ,(if par-copymode then for-goods.gds-code else 0)
                ) no-error.
  if error-status:error then do:
      undo _bc, return error vss-workfile + "Ошибка при создании налогов." + {&new-line} + return-value + {&new-line} + trim(error-status :get-message(1)).
  end.
  find first buf_bar-code no-lock where
            buf_bar-code.b-code = var-bc-code .
  run bar-codh_write-bar-code-proc in this-procedure (
                                                        buffer buf_bar-code
                                                      , integer({&hn-create})
                                                      , "":U /*p-source-type*/
                                                      , "":U /*p-source-ref*/
                                                      ) .

end. /*transaction*/
END PROCEDURE.

procedure do-message :
define input parameter par-silence as logical no-undo .
define input parameter par-mess as character no-undo .
define input parameter par-title-type as character no-undo .

  do
  on error undo, return error
  :

    if not par-silence then do:
      CASE par-title-type:
        when "error":U then do:
          message
          par-mess
          view-as alert-box error.
          undo, return error par-mess.
        end.
        when "warning":U then do:
          message
          par-mess
          view-as alert-box warning.
        end.
        when "question":U then do:
          message
          par-mess
          view-as alert-box question buttons YES-NO update loc#log.
        end.
      end CASE.
    end.
    else do:
      CASE par-title-type:
        when "error":U then do:
          undo, return error par-mess.
        end.
        when "warning":U then do:
        end.
        when "question":U then do:
          loc#log = no.
        end.
      end CASE.
    end.
  end.

end procedure. /* do-warning */

PROCEDURE dif-nam2-proc:
define input parameter par-dif-nam2 as logical no-undo .
define input parameter par-gds-name like ub.goods.gds-name no-undo .
define input parameter par-units-type like ub.units.type no-undo .
define input parameter par-gds-code like ub.goods.gds-code no-undo .
  do
  on error undo, return error
  :

    if par-dif-nam2 and par-saved-name = par-gds-name
        and NOT can-do( par-units-type, {&weight}) AND
        not can-find(first ub.prod-bc where ub.prod-bc.b-code = par-gds-code)
        then return error.
  end.

END PROCEDURE.