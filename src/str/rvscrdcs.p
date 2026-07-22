block-level on error undo, throw.
/*

$Revision: 94114751b278, 3560, rls $
$Author: EShklyar $
$Date: 2023/11/27 08:31:19 $
$Workfile: rvscrdcs.p $
$Archive: str/rvscrdcs.p $

создание топливных документов по документу сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/14/06
Author: Dmitry Ukhanov
Creation date: 11/14/06

*/

using ibs.th.str.ptrl.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.*.
using ibs.th.gbl.logging.*.
using ibs.th.ref.*.

define input  parameter parparentproc as handle    no-undo.
define input  parameter p-rvs-rowid   as rowid     no-undo .
define output parameter p-docs-info   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 94114751b278, 3560, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/11/27 08:31:19 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rvscrdcs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rvscrdcs.p $":U .
define variable vss-description as character no-undo init "создание топливных документов по документу сверки".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ str/lib-trn.i      }
{ cmp/library.i      }
{ str/lib-calc.i     }
{ str/doc-code.i     }
{ cmp/gds-list.i gds-list def }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/ptrlprop.i def }
{ ref/gdsoattr.i     }
{ str/placelib.i     }
{ gbl/attr-lib.i     }
{ ref/gds-attr.i     }
{ str/is-sug.i       }
{ str/is-gas.i       }
{ str/trdcalib.i }
{ gbl/thbjattr.i }
{ str/attrlist.i }
do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

  define buffer buf_rvs-doc       for ub.rvs-doc .
  define buffer buf_rvs-line      for ub.rvs-line .
  define buffer com_rvs-line      for ub.rvs-line .
  define buffer buf_rvs-line-attr for ub.rvs-line-attr .

  define buffer buf-add_clients   for ub.clients .
  define buffer buf_sysconf       for ub.sysconf .
  define buffer buf_goods         for ub.goods .
  define buffer buf_gds-prt       for ub.gds-prt .
  define buffer buf_prt-obj       for ub.prt-obj .
  define buffer buf_pl-gds        for ub.pl-gds .

  define buffer buf_trn-doc       for ub.trn-doc .
  define buffer buf_doc-line      for ub.doc-line .
  define buffer buf_inv-line      for ub.inv-line .
  define buffer buf_gds-dtl       for ub.gds-dtl .
  define buffer buf_doc-pl        for ub.doc-pl .
  define buffer buf_doc-line-sum  for ub.doc-line-sum .

  define buffer bf_doc-line       for ub.doc-line.
  define buffer bf_inv-line       for ub.inv-line.
  define buffer bf-prev_doc-line  for ub.doc-line.
  define buffer bf-prev_trn-doc   for ub.trn-doc.
  define buffer bf-prev_doc-pl    for ub.doc-pl.
  define buffer bf-wst_trn-doc    for ub.trn-doc.
  define buffer bf-wst_doc-line   for ub.doc-line.
  define buffer bf-wst_inv-line   for ub.inv-line.
  define buffer bf-wst_doc-pl     for ub.doc-pl.
  define buffer buf_sale-doc      for ub.sale-doc .
  define buffer buf_place         for ub.place .
  define buffer buf2_place        for ub.place .

  define temp-table tt-line-for-doc no-undo
    field gds-code      like ub.rvs-line.gds-code
    field pl-code       like ub.rvs-line.pl-code
    field fact-qnty     like ub.doc-pl.fact-qnty
    field fact-cli-qnty like ub.doc-pl.fact-qnty
    index pi is unique primary gds-code pl-code
    .
  define buffer buf_tt-line-for-doc for tt-line-for-doc .

  define buffer buf-spi_trn-doc     for ub.trn-doc .
  define buffer buf-spi_doc-line    for ub.doc-line .
  define buffer buf-spi_inv-line    for ub.inv-line .
  define buffer buf-spi_gds-dtl     for ub.gds-dtl .
  define buffer buf-spi_parts       for ub.parts .
  define buffer buf-spi_doc-pl      for ub.doc-pl .
  

  define variable chs-gds-inv                   as logical   no-undo.
  define variable vartot-docold                 like ub.trn-doc.tot-doc no-undo.
  define variable vartot-rublold                like ub.trn-doc.tot-rubl no-undo.
  define variable i-total-doc-line_tot-ovold    like ub.trn-doc.tot-ov no-undo.
  define variable i-total-doc-line_fact-rublold like ub.trn-doc.fact-rubl no-undo.
  define variable i-total-doc-line_fact-baseold like ub.trn-doc.fact-base no-undo.
  define variable i-total-doc-line_fact-qntyold like ub.trn-doc.fact-qnty no-undo.
  define variable i-total-doc-line_doc-qntyold  like ub.trn-doc.doc-qnty no-undo.
  define variable i-total-doc-line_cli-qntyold  like ub.trn-doc.cli-qnty no-undo.
  define variable i-total-parts_fact-baseold    as decimal   no-undo.
  define variable i-total-parts_fact-rublold    as decimal   no-undo.
  define variable i-total-parts_fact-qntyold    as decimal   no-undo.
  define variable stfactplvalue                 as character no-undo.
  define variable stfactpltype                  as character no-undo.
  define variable v-reserv-qnty-base            like ub.doc-line.fact-qnty no-undo.
  define variable v-reserv-qnty-cli             like ub.doc-line.cli-qnty no-undo.
  define variable v-chg-qnty                    like ub.doc-line.fact-qnty no-undo.
  define variable v-fact-qnty                   like ub.doc-line.fact-qnty no-undo.
  define variable v-fact-cli-qnty               like ub.doc-line.cli-qnty no-undo.
  define variable varupdate                     as logical   no-undo initial yes.
  define variable varrevision                   as logical   no-undo initial no.
  define variable varpercrev                    as decimal   no-undo initial ?.
  define variable varauto-tank                  as logical   no-undo initial no.
  define variable varpercauto                   as decimal   no-undo initial ?.
  define variable varinv                        as logical   no-undo initial no.
  define variable varpercinv                    as decimal   no-undo initial ?.
  define variable varinv-set                    as logical   no-undo initial no.
  define variable varvalue                      as character no-undo.
  define variable vartype                       as character no-undo.
  define variable v-lgas-gds                    as logical   no-undo.

  define variable O_PKH                         as decimal   no-undo.
  define variable O_FACT                        as decimal   no-undo.
  define variable v-metering-error              as decimal   no-undo.
  define variable v-normal-wastage              as decimal   no-undo.
  define variable v-normal-tp                   as decimal   no-undo.
  define variable v-normal-tp-auto              as decimal   no-undo.
  define variable v-normal-tp-pl                as decimal   no-undo.
  define variable v-normal-wastage-winter       as decimal   no-undo init ?.
  define variable v-normal-wastage-summer       as decimal   no-undo init ?.
  define variable v-norm-wast-decomm            as decimal   no-undo init 0.
  define variable v-rsrv-qnty                   like ub.doc-line.fact-qnty no-undo.
  define variable v-value                       as character no-undo.
  define variable v-ok                          as logical   no-undo.
  define variable logstr                        as character no-undo.

  define variable O_PKH-base                    as decimal   no-undo.
  define variable O_FACT-base                   as decimal   no-undo.
  define variable O_PKH-cli                     as decimal   no-undo.
  define variable O_FACT-cli                    as decimal   no-undo.
  define variable K1                            as decimal   no-undo.
  define variable v-metering-error-base         as decimal   no-undo.
  define variable v-metering-error-cli          as decimal   no-undo.
  define variable v-metering-error-dens         as decimal   no-undo.
  define variable v-metering-qnty-base          as decimal   no-undo .
  define variable v-metering-qnty-cli           as decimal   no-undo .
  define variable K2                            as decimal   no-undo.
  define variable v-normal-wastage-base         as decimal   no-undo.
  define variable v-normal-wastage-cli          as decimal   no-undo.
  define variable v-normal-wastage-dens         as decimal   no-undo .
  define variable K3                            as decimal   no-undo.
  define variable v-metering-pipe-error-base    as decimal   no-undo.
  define variable v-metering-pipe-error-cli     as decimal   no-undo.
  define variable v-metering-pipe-qnty-cli      as decimal   no-undo .
  define variable oNormWast                     as class     ibs.th.ref.normwastsub no-undo.
  define variable v-wastage-qnty-base           as decimal   no-undo .
  define variable v-wastage-qnty-cli            as decimal   no-undo .
  define variable WST-base                      as decimal   no-undo.
  define variable WST-cli                       as decimal   no-undo.
  define variable varfact-order-prev-inv        like ub.trn-doc.fact-order no-undo.
  define variable InfoSecsObj                   as class     InfoSectionsTotal      no-undo.
  
  define variable v-all-state-measure-qnty as decimal no-undo .
  define variable v-all-state-measure-cli-qnty as decimal no-undo .
  define variable v-avg-state-density as decimal no-undo .
  define variable v-num-tanks as integer no-undo .
  define variable v-all-state-add-cli-qnty as decimal no-undo .
  
  define variable dM                            as decimal   no-undo.
  define variable dMMBd                         as decimal   no-undo.
  define variable MKN                           as decimal   no-undo.
  define variable MKKN                          as decimal   no-undo.
  define variable MFO                           as decimal   no-undo.
  define variable beta1                         as decimal   no-undo.
  define variable beta2                         as decimal   no-undo.
  define variable MFOT                          as decimal   no-undo.
  define variable MFOR                          as decimal   no-undo.
  define variable MI                            as decimal   no-undo.
  define variable dMPT                          as decimal   no-undo.
  define variable dMPOT                         as decimal   no-undo.
  define variable MPOT                          as decimal   no-undo.
  define variable MNED                          as decimal   no-undo.
  
  define variable v-par-type                    as character no-undo.
  define variable ii                            as integer   no-undo.


  /* создавать ли TDEDT_Spi_Vnesh */
  define variable v-cre-add-docs                as logical   no-undo .
  define variable v-without-mt-err              as logical   no-undo .
  define variable rvsinvsubObj                  as class     rvsinvsub              no-undo.
  define variable rvsinvstrObj                  as class     rvsinvstr              no-undo.
  
  define variable v-inv-code                    as character no-undo .
  define variable v-spi-code                    as character no-undo .
  define variable v-host-code                   as integer   no-undo .
  define variable v-prt-root                    as integer   no-undo .
  define variable v-recid                       as recid     no-undo .

  define variable v-log                         as logical   no-undo .
  define variable v-type                        as character no-undo .

  define variable v-input-type-p                as character no-undo .
  define variable v-input-type-T                as character no-undo .
  define variable v-input-type-l                as character no-undo .
  define variable v-input-type-err-msg          as character no-undo .
  define variable pl-rvd-dens                   as logical   no-undo .
  define variable pl-rvd-lvl                    as logical   no-undo .
  define variable pl-rvd-temp                   as logical   no-undo .

  define variable rdc-value                     as character no-undo .
  define variable rdc-type                      as character no-undo .

  { gbl/getcntxt.i get }
  find first buf_rvs-doc
    where rowid( buf_rvs-doc ) = p-rvs-rowid
    .
  
  if v-cntxt-obj-type <> buf_rvs-doc.obj-type
    or v-cntxt-obj-code <> buf_rvs-doc.obj-code
    then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Сверка &1 резервуаров на объекте &2 &3", buf_rvs-doc.rvs-code, buf_rvs-doc.obj-type, buf_rvs-doc.obj-code ) skip
      substitute("На текущем объекте нельзя создать инвентаризацию по данной сверке." ) skip
      view-as alert-box error .
    return error .
  end.

  logger:Path = "log-rvsinv.log".
  logger:StrLogPut =
    {&new-line} + 
    "-----------------------------------------------" + {&new-line} +
    string (now) + {&new-line}.  
  assign
    v-log = no
    .
  message
    "Вы хотите сделать инвентаризацию по сверке?"    skip
    "ДА     - по всем товарам из сверки"             skip
    "НЕТ    - не делать инвентаризацию"              skip
    "ОТМЕНА - опционально по товарам и резервуарам"
    view-as alert-box buttons yes-no-cancel update v-log.
  if v-log = no then 
  do:
    return no-apply.
  end.

  assign
    chs-gds-inv = v-log
    p-docs-info = "":U
    .
  /* Проверки типа ввода  */
  RUN gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-value, output rdc-type) no-error .
  
  v-input-type-err-msg = "" .
  if chs-gds-inv
    and rdc-value = "pomi-rn"
    then 
  do :
    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code,
      first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
      and buf_place.obj-code = buf_rvs-doc.obj-code
      and buf_place.pl-code = buf_rvs-line.pl-code,
      first buf_goods no-lock where buf_goods.gds-code = buf_rvs-line.gds-code :
      if is-sug(buf_goods.gds-code)
        or is-gas(buf_goods.gds-code)
        then next .
      assign
        v-input-type-p = "" 
        v-input-type-T = ""
        v-input-type-l = ""
        .
      for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "input-type-p"
        :
        v-input-type-p = buf_rvs-line-attr.attr-value .                              
      end .
      for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "input-type-T"
        :
        v-input-type-T = buf_rvs-line-attr.attr-value .                              
      end .
      for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "input-type-l"
        :
        v-input-type-l = buf_rvs-line-attr.attr-value .                              
      end .
      /*      а - получение данных с аси   */
      /*      ф - получение данных из файла*/
      /*      р - ручное                   */
      
      run placelib_get-attr  ( input {&place-rvd-dnsty}
        ,input buf_rvs-line.obj-code
        ,input buf_rvs-line.obj-type
        ,input buf_rvs-line.pl-code
        ,output v-value
        ,output v-ok      ) no-error.
      if not v-ok then pl-rvd-dens = no.
      else pl-rvd-dens = logical(v-value) .
          
      run placelib_get-attr  ( input {&place-rvd-lvl}
        ,input buf_rvs-line.obj-code
        ,input buf_rvs-line.obj-type
        ,input buf_rvs-line.pl-code
        ,output v-value
        ,output v-ok      ) no-error.
      if not v-ok then pl-rvd-lvl = no.
      else pl-rvd-lvl = logical(v-value) .
  
      run placelib_get-attr  ( input {&place-rvd-tmp}
        ,input buf_rvs-line.obj-code
        ,input buf_rvs-line.obj-type
        ,input buf_rvs-line.pl-code
        ,output v-value
        ,output v-ok      ) no-error.
      if not v-ok then pl-rvd-temp = no.
      else pl-rvd-temp = logical(v-value) . 
        
      if ((v-input-type-p = "р" or v-input-type-p = "ак" or v-input-type-p = "фк" or (v-input-type-p = "а" and not pl-rvd-dens))
        and (v-input-type-T = "р" or v-input-type-T = "ак" or v-input-type-T = "фк" or (v-input-type-T = "а" and not pl-rvd-temp))
        and (v-input-type-l = "р" or v-input-type-l = "ак" or v-input-type-l = "фк" or (v-input-type-l = "а" and not pl-rvd-lvl)))
        then 
      do : 
      end .
      else 
      do:
        v-input-type-err-msg = v-input-type-err-msg + " Резервуар " + string(buf_place.pl-code) + " " + buf_place.pl-name + " с " + buf_goods.gds-name + {&new-line} .
        if not (v-input-type-p = "р" or v-input-type-p = "ак" or v-input-type-p = "фк")
          then 
        do :
          v-input-type-err-msg = v-input-type-err-msg + "   - Плотность" + {&new-line} .
        end .
        if not (v-input-type-T = "р" or v-input-type-T = "ак" or v-input-type-T = "фк")
          then 
        do :
          v-input-type-err-msg = v-input-type-err-msg + "   - Температура" + {&new-line} .
        end .
        if not (v-input-type-l = "р" or v-input-type-l = "ак" or v-input-type-l = "фк")
          then 
        do :
          v-input-type-err-msg = v-input-type-err-msg + "   - Уровень" + {&new-line} .
        end .
      end .
    end .
  end .
  
  if v-input-type-err-msg > ""
    then 
  do :
    v-input-type-err-msg = "Невозможно создать инвентаризацию по сверке. Отсутствуют ручные замеры по резервуарам:" + {&new-line} + v-input-type-err-msg .
    message v-input-type-err-msg view-as alert-box .
    return no-apply .
  end .
  
  /* создание документа инвентаризации */
  
  block_cre-inv :
  do transaction
    on error  undo block_cre-inv, retry block_cre-inv
    on stop   undo block_cre-inv, retry block_cre-inv
    on endkey undo block_cre-inv, retry block_cre-inv
    :
    if retry then 
    do:
      assign
        p-docs-info = "":U
        .
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании документа" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo block_cre-inv, leave block_cre-inv .
    end.

    for each tt-line-for-doc
      on error undo block_cre-inv, retry block_cre-inv
      :
      delete tt-line-for-doc .
    end.

    { gbl/ptrlprop.i
      run
      buf_rvs-doc.obj-type
      buf_rvs-doc.obj-code
    }

    if not error-status :error then 
    do:
      assign
        v-without-mt-err = ptrlprop-rvsnmter
        .
    end.
    logger:StrLogPut = 
      "Настройки секции для " + buf_rvs-doc.obj-type + " " + string(buf_rvs-doc.obj-code) + ": " + {&new-line} + 
      " - Расхождение в инвентаризации по сверке делать без учета погрешности измерения: " + string(ptrlprop-rvsnmter) + {&new-line} +
      " - Настройки инвентаризации по сверке: " + string(ptrlprop-algoincome) + {&new-line} +
      " - Температура к которой приводится плотность и объем (°С): " + string(ptrlprop-temp-for-pomi) + {&new-line} +
      /*            " - При воде в сверке отправлять сообщения на список адресов: " skip*/
      /*            " - Допустимый % расхождения массы в резервуаре: " skip             */
      " - Алгоритм принятия топлива к учету: " + string(ptrlprop-algrvspt) + {&new-line} +
      " - Обязательный выбор автотранспорта из справочника: " + string(ptrlprop-mand-choice-autocar) + {&new-line} +
      " - Погрешность изм массы для горизонтальных резер: " + string(ptrlprop-Delta-mass-horiz) + {&new-line} +
      " - Погрешность изм массы для вертикальных резер: " + string(ptrlprop-Delta-mass-vert) + {&new-line} .
    /*            " - Допустимый % расхождения массы при приеме СУГ: " skip*/
            

    assign
      v-cre-add-docs = false
      .
    if ptrlprop-invclipt <> ? then 
    do:
      find first buf-add_clients
        where buf-add_clients.obj-type = {&cmp}
        and buf-add_clients.obj-code = ptrlprop-invclipt
        no-error .
      if available buf-add_clients then 
      do:
        assign
          v-cre-add-docs = true
          .
        { gbl/hostcode.i
          v-cntxt-obj-type
          v-cntxt-obj-code
          v-host-code
        }
        find first buf_sysconf no-lock
          where buf_sysconf.host-code = v-host-code
          .
        if buf_sysconf.cons-vat-pc = ? then 
        do:
          message
            vss-workfile vss-revision vss-description skip
            "У Вас не установлен НДС для консигнационного товара по фирме." skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo block_cre-inv, retry block_cre-inv .
        end.
      end.
    end.

    /* Создаем инвентаризацию */
    { str/adinvdoc.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-cntxt-userid
      v-recid
    }
    find first buf_trn-doc exclusive-lock
      where recid( buf_trn-doc ) = v-recid
      .
    assign
      v-inv-code           = buf_trn-doc.doc-code
      buf_trn-doc.agnt     = buf_rvs-doc.agnt
      buf_trn-doc.wrkr     = buf_rvs-doc.wrkr
      buf_trn-doc.boss     = buf_rvs-doc.boss
      buf_trn-doc.out-code = buf_rvs-doc.rvs-code
      .

    logger:StrLogPut = 
      "Создается инвентаризация: " + string(v-inv-code) + {&new-line} .

    /*Фиксируем дату и время создания инвентаризации*/
    create ub.inv-doc-attr .
    assign
    ub.inv-doc-attr.doc-code = buf_rvs-doc.rvs-code
    ub.inv-doc-attr.attr-code = "create_date"
    ub.inv-doc-attr.attr-value = string(today)
    .
    create ub.inv-doc-attr .
    assign
    ub.inv-doc-attr.doc-code = buf_rvs-doc.rvs-code
    ub.inv-doc-attr.attr-code = "create_time"
    ub.inv-doc-attr.attr-value = string(time)
    .
    
    /* Заполняем инвентаризацию товарами */
    block_rvs-line:
    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code,
      first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
      and buf_place.obj-code = buf_rvs-doc.obj-code
      and buf_place.pl-code = buf_rvs-line.pl-code,
      first buf_goods no-lock where buf_goods.gds-code = buf_rvs-line.gds-code
      on error undo block_cre-inv, retry block_cre-inv
      :
      if is-gas(buf_goods.gds-code)
        then 
      do :
        next block_rvs-line.
      end .
      run placelib_get-attr  ( input {&place-com-tanks}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,output v-value
        ,output v-ok      ) no-error.

      if  v-ok
      and v-value > ""
      then do :
        do ii = 1 to num-entries(v-value) :
          find first buf2_place no-lock where buf2_place.obj-type = buf_rvs-doc.obj-type
                                          and buf2_place.obj-code = buf_rvs-doc.obj-code
                                          and buf2_place.loc1     = entry(ii, v-value)
                                          and buf2_place.status_  = ""
                                          no-error .
          if available buf2_place
          then do :
            find first com_rvs-line where com_rvs-line.gds-code = buf_goods.gds-code
                                      and com_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                      and com_rvs-line.obj-type = buf_rvs-doc.obj-type
                                      and com_rvs-line.obj-code = buf_rvs-doc.obj-code
                                      and com_rvs-line.pl-code  = buf2_place.pl-code
                                      no-error .
            if not available com_rvs-line
            then do :
              message substitute ("Внимание! Не сделана сверка по резервуару №&1, включенному в связку сообщающихся резервуаров! Документ инвентаризации не создан!", buf2_place.loc1)
                view-as alert-box error .
              undo block_cre-inv, leave block_cre-inv .
            end .
          end .
        end .
        run placelib_get-attr  ( input {&place-is-main}
          ,input buf_place.obj-code
          ,input buf_place.obj-type
          ,input buf_place.pl-code
          ,output v-value
          ,output v-ok      ) no-error.
        if v-ok and logical(v-value)
          then 
        do :
          
        end .
        else 
        do :
          next block_rvs-line.
        end .                        
      end .
      if chs-gds-inv <> yes then 
      do:
        assign
          v-log = no
          .
        message
          substitute( 'Будем проводить инвентаризацию по товару (&1 &2 &3) "&4"', buf_goods.artic, buf_goods.prod-type, buf_goods.prod-code, buf_goods.gds-name ) skip
          substitute( " на месте хранения &1", buf_rvs-line.pl-code ) skip
          substitute( " системное количество &1", buf_rvs-line.system-qnty ) skip
          substitute( " фактический остаток &1?", buf_rvs-line.state-measure-qnty )
          view-as alert-box buttons yes-no update v-log.
        if v-log <> yes then 
        do:
          next block_rvs-line.
        end.
        else 
        do :
          if rdc-value = "pomi-rn"
            and not is-sug(buf_goods.gds-code)
            then 
          do :
            assign
              v-input-type-p = "" 
              v-input-type-T = ""
              v-input-type-l = ""
              .
            for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
              and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
              and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
              and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
              and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
              and buf_rvs-line-attr.attr-code = "input-type-p"
              :
              v-input-type-p = buf_rvs-line-attr.attr-value .                              
            end .
            for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
              and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
              and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
              and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
              and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
              and buf_rvs-line-attr.attr-code = "input-type-T"
              :
              v-input-type-T = buf_rvs-line-attr.attr-value .                              
            end .
            for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
              and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
              and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
              and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
              and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
              and buf_rvs-line-attr.attr-code = "input-type-l"
              :
              v-input-type-l = buf_rvs-line-attr.attr-value .                              
            end .
            
            run placelib_get-attr  ( input {&place-rvd-dnsty}
              ,input buf_rvs-line.obj-code
              ,input buf_rvs-line.obj-type
              ,input buf_rvs-line.pl-code
              ,output v-value
              ,output v-ok      ) no-error.
            if not v-ok then pl-rvd-dens = no.
            else pl-rvd-dens = logical(v-value) .
          
            run placelib_get-attr  ( input {&place-rvd-lvl}
              ,input buf_rvs-line.obj-code
              ,input buf_rvs-line.obj-type
              ,input buf_rvs-line.pl-code
              ,output v-value
              ,output v-ok      ) no-error.
            if not v-ok then pl-rvd-lvl = no.
            else pl-rvd-lvl = logical(v-value) .
  
            run placelib_get-attr  ( input {&place-rvd-tmp}
              ,input buf_rvs-line.obj-code
              ,input buf_rvs-line.obj-type
              ,input buf_rvs-line.pl-code
              ,output v-value
              ,output v-ok      ) no-error.
            if not v-ok then pl-rvd-temp = no.
            else pl-rvd-temp = logical(v-value) . 

            if ((v-input-type-p = "р" or v-input-type-p = "ак" or v-input-type-p = "фк" or (v-input-type-p = "а" and not pl-rvd-dens))
              and (v-input-type-T = "р" or v-input-type-T = "ак" or v-input-type-T = "фк" or (v-input-type-T = "а" and not pl-rvd-temp))
              and (v-input-type-l = "р" or v-input-type-l = "ак" or v-input-type-l = "фк" or (v-input-type-l = "а" and not pl-rvd-lvl)))
              then 
            do : 
            end .
            else 
            do :
              v-input-type-err-msg = "Невозможно добавить строку. Отсутствуют данные ручных замеров резервуара "
                + string(buf_place.pl-code) + " " + buf_place.pl-name + " с " + buf_goods.gds-name
                + " по параметрам:" + {&new-line} .
              if not (v-input-type-p = "р" or v-input-type-p = "ак" or v-input-type-p = "фк")
                then 
              do :
                v-input-type-err-msg = v-input-type-err-msg + "   - Плотность" + {&new-line} .
              end .
              if not (v-input-type-T = "р" or v-input-type-T = "ак" or v-input-type-T = "фк")
                then 
              do :
                v-input-type-err-msg = v-input-type-err-msg + "   - Температура" + {&new-line} .
              end .
              if not (v-input-type-l = "р" or v-input-type-l = "ак" or v-input-type-l = "фк")
                then 
              do :
                v-input-type-err-msg = v-input-type-err-msg + "   - Уровень" + {&new-line} .
              end .                    
              v-input-type-err-msg = v-input-type-err-msg + {&new-line}
                + "Продолжить создание инвентаризации?"
                .
              message
                v-input-type-err-msg
                view-as alert-box buttons yes-no update v-log.
              if not v-log
                then 
              do :
                undo block_cre-inv, return .
              end .
              else 
              do :
                next block_rvs-line .
              end .
            end .
          end . /* if rdc-value = "pomi-rn" and not sug and not gas */
        end .
      end. /* if chs-gds-inv <> yes */

      { str/adinvlin.i
        parparentproc
        v-inv-code
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        v-recid
        no-error
      }
      if error-status :error then 
      do:
        undo block_cre-inv, retry block_cre-inv.
      end.

      find first buf_doc-line exclusive-lock
        where recid( buf_doc-line ) = v-recid
        .
      assign
        buf_doc-line.doc-density  = buf_rvs-line.state-density
        buf_doc-line.fact-density = buf_doc-line.doc-density
        .
    end. /* each buf_rvs-line */
    
    find first buf_doc-line no-lock where buf_doc-line.doc-code = v-inv-code no-error .
    if not available buf_doc-line
      then 
    do :
      message "В инвентаризацию не добавлен ни один товар!" view-as alert-box .
      undo block_cre-inv, leave block_cre-inv .
    end .

    /* инвентаризация накл- - разр+ */
    run close-doc in this-procedure
      ( input v-inv-code
      , input recid( buf_trn-doc )
      ) no-error .
    if error-status :error then 
    do:
      undo block_cre-inv, leave block_cre-inv .
    end.

    { gbl/conf-rd.i
      "'stfactpl'"
      "''"
      "''"
      0
      "''"
      "''"
      "''"
      no
      stfactplvalue
      stfactpltype
      no-error
    }
    if not error-status :error
      and stfactplvalue <> ?
      and stfactplvalue <> "?"
      then 
    do:
      { str/chkqtpl.i
        stfactplvalue
        varupdate
        varrevision
        varpercrev
        varauto-tank
        varpercauto
        varinv
        varpercinv
        varinv-set
        no-error
      }
      if error-status :error then 
      do:
        message
          return-value skip
          error-status :get-message( 1 )
          view-as alert-box.
        undo block_cre-inv, retry block_cre-inv .
      end.
      logger:StrLogPut =
        "Конфигурационный параметр: " + {&new-line} + 
        " - Определение работы с фактическим количеством бензина во внешнем приходе: " + stfactplvalue + {&new-line}.
      if varrevision = yes then 
      do:
        assign
          K1 = varpercrev.
      end.
      if varauto-tank = yes then 
      do:
        assign
          K1 = varpercauto.
      end.
      if varinv = yes then 
      do:
        assign
          K1 = varpercinv.
      end.
    end.
    if K1 = ? then 
    do:
      assign
        K1 = 0.0
        .
    end.
    define variable K1-all as decimal no-undo.
    K1-all = K1.
    
    for each buf_doc-line exclusive-lock
      where buf_doc-line.doc-code = v-inv-code
      ,first buf_inv-line exclusive-lock
      where buf_inv-line.doc-code  = buf_doc-line.doc-code
      and buf_inv-line.artic     = buf_doc-line.artic
      and buf_inv-line.prod-type = buf_doc-line.prod-type
      and buf_inv-line.prod-code = buf_doc-line.prod-code
      ,first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
      and buf_goods.prod-type = buf_doc-line.prod-type
      and buf_goods.prod-code = buf_doc-line.prod-code
      on error undo block_cre-inv, retry block_cre-inv
      :
      
      run gds-attr-value in this-procedure
        (  input buf_goods.gds-code
        ,input {&attr-fuel-type}
        ,output varvalue
        ,output vartype
        ) .
      if varvalue = "lgas" then 
      do:
        v-lgas-gds = true.
      end.
      logger:StrLogPut =
        "Товар: " + string(buf_goods.gds-code) + " " + buf_goods.gds-name .    
      
      K1 = K1-all.
      
      find first buf_rvs-line no-lock
        where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
        and buf_goods.gds-code = buf_rvs-line.gds-code no-error.
      find first buf_rvs-line-attr where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "delta-mass-qnty" no-lock no-error.
      
      if available (buf_rvs-line-attr)
        then 
      do:
        decimal (buf_rvs-line-attr.attr-value) no-error.
        if not error-status:error
          then 
        do: 
          if not decimal (buf_rvs-line-attr.attr-value) = 0
            then K1 = decimal (buf_rvs-line-attr.attr-value) no-error.
        end.
      end.
      
      oNormWast = new normwastsub ().
      oNormWast:ParGdsOAttr:GdsCode = buf_goods.gds-code.
      oNormWast:ParGdsOAttr:ObjType = buf_trn-doc.obj-type.
      oNormWast:ParGdsOAttr:ObjCode = buf_trn-doc.obj-code.
      oNormWast:ParGdsOAttr:OnDate = if buf_trn-doc.fact-date <> ? then buf_trn-doc.fact-date else buf_trn-doc.doc-date.
      oNormWast:FillNormWast().
      
      if error-status:error
        and not v-lgas-gds
        and not is-gas(buf_goods.gds-code)
        then 
      do:
        message
          "ОШИБКА при определние нормы естественной убыли." skip
          "По строке товара : " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
          "на объекте: " buf_trn-doc.obj-type " " buf_trn-doc.obj-code
          skip
          view-as alert-box error.
        undo block_cre-inv, retry block_cre-inv.
      end.
      
      v-normal-wastage = oNormWast:NormalWastageDate.
      logger:StrLogPut =
        " Норма естественной убыли = " + string(v-normal-wastage) .    
      if v-normal-wastage = ? then 
      do:
        assign
          K2 = 0.0
          .
      end.
      else 
      do:
        assign
          K2 = v-normal-wastage
          .
      end.
      run placelib_get-attr  ( 
        input {&place-error-mass}
        ,input buf_rvs-line.obj-code
        ,input buf_rvs-line.obj-type
        ,input buf_rvs-line.pl-code
        ,output v-value
        ,output v-ok      ) no-error.

      if v-ok then 
      do:
        K3 = decimal(v-value). 
        logger:StrLogPut =
          " Погрешность измерения массы = " + string(K3) .    
      end.
      { str/reclcinv.i
        "'old'":U
        recid(buf_doc-line)
        v-inv-code
        vartot-docold
        vartot-rublold
        i-total-doc-line_tot-ovold
        i-total-doc-line_fact-rublold
        i-total-doc-line_fact-baseold
        i-total-doc-line_fact-qntyold
        i-total-doc-line_doc-qntyold
        i-total-doc-line_cli-qntyold
        i-total-parts_fact-baseold
        i-total-parts_fact-rublold
        i-total-parts_fact-qntyold
        no-error
      }
      if error-status :error then 
      do:
        undo block_cre-inv, retry block_cre-inv.
      end.
      assign
        buf_inv-line.wast-cli-qnty  = buf_inv-line.before-cli-qnty
        buf_inv-line.after-cli-qnty = buf_inv-line.before-cli-qnty
        .
      logger:StrLogPut =
        " Количество естеств. убыли в единицах клиента = " + string(buf_inv-line.wast-cli-qnty) + {&new-line} + 
        " Количество после инвентаризации в единицах клиента = " + string(buf_inv-line.after-cli-qnty) + {&new-line}.    
      
      find first buf_gds-prt no-lock
        where buf_gds-prt.upper-code = buf_goods.prt-root
        .
      if not v-cntxp-doc-prt
        or buf_gds-prt.node-name = {&empty-scale}
        then 
      do:
        { gbl/gdsdtlcr.i
          buf_gds-prt.node-code
          buf_doc-line
          buf_gds-dtl
          no-error
        }
        if error-status :error then 
        do:
          undo block_cre-inv, retry block_cre-inv.
        end.
        find first buf_prt-obj no-lock
          where buf_prt-obj.prt-code  = buf_gds-prt.node-code
          and buf_prt-obj.prod-code = buf_goods.prod-code
          and buf_prt-obj.prod-type = buf_goods.prod-type
          and buf_prt-obj.artic     = buf_goods.artic
          and buf_prt-obj.obj-code  = buf_trn-doc.obj-code
          and buf_prt-obj.obj-type  = buf_trn-doc.obj-type
          no-error.
        assign
          buf_gds-dtl.doc-qnty  = 0
          buf_gds-dtl.fact-qnty = ( if available buf_prt-obj then buf_prt-obj.fact-qnty else 0 )
          .
        if buf_doc-line.doc-qnty <> buf_gds-dtl.fact-qnty then 
        do:
          message
            "ОШИБКА" skip
            "Кол-во товара по строке : " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
            "на объекте: " buf_trn-doc.obj-type " " buf_trn-doc.obj-code " , равное " buf_doc-line.doc-qnty skip
            " не совпадает с кол-ом по корневому признаку, равном " buf_gds-dtl.fact-qnty "." skip
            view-as alert-box error.
          undo block_cre-inv, retry block_cre-inv.
        end. /* несоответствие строки и признака */

        block_doc-pl:
        for each buf_doc-pl exclusive-lock
          where buf_doc-pl.out-code = v-inv-code
          and buf_doc-pl.gds-code = buf_goods.gds-code
          and buf_doc-pl.obj-type = buf_trn-doc.obj-type
          and buf_doc-pl.obj-code = buf_trn-doc.obj-code
          ,each buf_rvs-line no-lock
          where buf_rvs-line.gds-code = buf_doc-pl.gds-code
          and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type = buf_doc-pl.obj-type
          and buf_rvs-line.obj-code = buf_doc-pl.obj-code
          and buf_rvs-line.pl-code  = buf_doc-pl.pl-code
          on error undo block_cre-inv, retry block_cre-inv
          :
          find first buf_pl-gds no-lock
            where buf_pl-gds.obj-type = buf_rvs-line.obj-type
            and buf_pl-gds.obj-code = buf_rvs-line.obj-code
            and buf_pl-gds.pl-code  = buf_rvs-line.pl-code
            and buf_pl-gds.gds-code = buf_rvs-line.gds-code
            no-error.
          if available buf_pl-gds then 
          do:
            assign
              v-fact-qnty     = buf_pl-gds.fact-qnty
              v-fact-cli-qnty = buf_pl-gds.cli-fact-qnty
              .
          end.
          else 
          do:
            assign
              v-fact-qnty     = 0.0
              v-fact-cli-qnty = 0.0
              .
          end.
          
          assign
            v-all-state-measure-qnty = 0.0
            v-all-state-measure-cli-qnty = 0.0
            v-avg-state-density = 0.0
            v-all-state-add-cli-qnty = 0.0
            v-num-tanks = 1 
          .
          
          assign
            O_PKH-base            = v-fact-qnty
            O_FACT-base           = buf_rvs-line.state-measure-qnty + buf_rvs-line.state-add-qnty
            O_PKH-cli             = v-fact-cli-qnty
            O_FACT-cli            = buf_rvs-line.state-measure-cli-qnty + buf_rvs-line.state-add-qnty * buf_rvs-line.state-density
            /*Согласно разъяснениям Главного технического управления Государственного комитета РСФСР № 12-3/47-233 от 16.04.1990 г.,*/
            /*установленные ГОСТ 26976-86 пределы погрешности измерений (нормы точности) могут применяться только по отношению к фактическому остатку нефтепродуктов, */
            /*измеренному в резервуарах при инвентаризации, без учета количества нефтепродукта в трубопроводе.*/
            /*            v-metering-error-base = K1 / 100 * buf_rvs-line.state-measure-qnty    */
            /*            v-metering-error-cli  = K1 / 100 * buf_rvs-line.state-measure-cli-qnty*/
            /*            v-metering-error-dens = buf_rvs-line.state-density                    */
            /*            v-metering-error-base = K1 / 100 * O_FACT-base*/
            /*            v-metering-error-cli  = K1 / 100 * O_FACT-cli*/
            v-all-state-measure-qnty = buf_rvs-line.state-measure-qnty
            v-all-state-measure-cli-qnty = buf_rvs-line.state-measure-cli-qnty
            v-all-state-add-cli-qnty = buf_rvs-line.state-add-qnty * buf_rvs-line.state-density
            v-avg-state-density   = buf_rvs-line.state-density
            v-metering-qnty-base  = 0.0
            v-metering-qnty-cli   = 0.0
            v-normal-wastage-base = 0.0
            v-normal-wastage-cli  = 0.0
            v-normal-wastage-dens = 1 / buf_goods.cli-base-rate
            v-wastage-qnty-base   = 0.0
            v-wastage-qnty-cli    = 0.0
            v-reserv-qnty-base    = 0.0
            v-reserv-qnty-cli     = 0.0
            v-normal-tp           = 0.0
            v-normal-tp-auto      = 0.0
            v-normal-tp-pl        = 0.0
            .          
          logger:StrLogPut =
            " Складское место - " + string(buf_doc-pl.pl-code) + {&new-line} + 
            "  - Объем расчетно-книжный (л) = " + string(if O_PKH-base <> ? then O_PKH-base else 0) + {&new-line} +
            "  - Объем НП, включая трубопровод (л) = " + string(if O_FACT-base <> ? then O_FACT-base else 0) + {&new-line} +
            "  - Масса расчетно-книжная (кг) = " + string(if O_PKH-cli <> ? then O_PKH-cli else 0) + {&new-line} +
            "  - Масса НП, включая трубопровод (кг) = " + string(if O_FACT-cli <> ? then O_FACT-cli else 0) + {&new-line} 
            /*      "  - v-normal-wastage-dens = " + string(v-normal-wastage-dens) + {&new-line}*/
            .
            
          run placelib_get-attr  ( input {&place-com-tanks}
            ,input buf_doc-pl.obj-code
            ,input buf_doc-pl.obj-type
            ,input buf_doc-pl.pl-code
            ,output v-value
            ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          then do :
            do ii = 1 to num-entries(v-value) :
              find first buf_place no-lock where buf_place.obj-type = buf_pl-gds.obj-type
                and buf_place.obj-code = buf_pl-gds.obj-code
                and buf_place.loc1     = entry(ii, v-value)
                and buf_place.status_  = ""
                no-error .
              if available buf_place
              then do :
                find first com_rvs-line where com_rvs-line.gds-code = buf_doc-pl.gds-code
                  and com_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                  and com_rvs-line.obj-type = buf_doc-pl.obj-type
                  and com_rvs-line.obj-code = buf_doc-pl.obj-code
                  and com_rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_rvs-line
                then do :
                  message substitute ("Внимание! Не сделана сверка по резервуару №&1, включенному в связку сообщающихся резервуаров! Документ инвентаризации не создан!", buf_place.loc1)
                    view-as alert-box error .
                  undo block_cre-inv, leave block_cre-inv .
                end .
                else do :
                  assign
                    O_FACT-base = O_FACT-base + (com_rvs-line.state-measure-qnty + com_rvs-line.state-add-qnty)
                    O_FACT-cli  = O_FACT-cli + (com_rvs-line.state-measure-cli-qnty + com_rvs-line.state-add-qnty * com_rvs-line.state-density)
                    
                    v-all-state-measure-qnty      = v-all-state-measure-qnty + com_rvs-line.state-measure-qnty
                    v-all-state-measure-cli-qnty  = v-all-state-measure-cli-qnty + com_rvs-line.state-measure-cli-qnty
                    v-avg-state-density           = v-avg-state-density + com_rvs-line.state-density
                    v-all-state-add-cli-qnty      = v-all-state-add-cli-qnty + (buf_rvs-line.state-add-qnty * buf_rvs-line.state-density)
                    v-num-tanks = v-num-tanks + 1
                  .
                end .
              end .
            end .
            assign v-avg-state-density = v-avg-state-density / v-num-tanks .
          end .  
                 
          if not v-lgas-gds
            and not is-gas(buf_goods.gds-code)
            then 
          do:
            assign
              v-metering-error-base = K1 / 100 * v-all-state-measure-qnty
              v-metering-error-cli  = K1 / 100 * v-all-state-measure-cli-qnty
              v-metering-error-dens = v-avg-state-density
              .
          end.
          else 
          do:
            assign
              v-metering-error-base = 0
              v-metering-error-cli  = 0
              v-metering-error-dens = 0
              .            
          end.
          logger:StrLogPut =
            "    Погрешность:" + {&new-line} + 
            "    - в литрах: " + string(if v-metering-error-base <> ? then v-metering-error-base else 0) + {&new-line} +
            "    - в кг: " + string(if v-metering-error-cli <> ? then v-metering-error-cli else 0) + {&new-line} 
            .  
                
          if ptrlprop-expptrl = {&calc-petrol-weight} then 
          do:
            /* работаем относительно килограммов */
            assign
              O_FACT           = O_FACT-cli
              O_PKH            = O_PKH-cli
              v-metering-error = v-metering-error-cli
              .
            logger:StrLogPut =
              "Работаем относительно килограммов" + {&new-line} 
              /*      "    - остаток = " + string(O_FACT) + {&new-line} +            */
              /*      "    - кол-во = " + string(O_PKH) + {&new-line} +              */
              /*      "    - погрешность = " + string(v-metering-error) + {&new-line}*/
              .              
          end.
          else 
          do:
            /* работаем относительно литров */
            assign
              O_FACT           = O_FACT-base
              O_PKH            = O_PKH-base
              v-metering-error = v-metering-error-base
              .

            logger:StrLogPut =
              "Работаем относительно литров" + {&new-line}  
              /*      "    - остаток = " + string(O_FACT) + {&new-line} +            */
              /*      "    - кол-во = " + string(O_PKH) + {&new-line} +              */
              /*      "    - погрешность = " + string(v-metering-error) + {&new-line}*/
              .                   
          end.

          if not v-lgas-gds
            and not is-gas(buf_goods.gds-code)
            and not ptrlprop-algrvspt = 4 
            then 
          do:

            if (O_PKH - O_FACT) <= 0  then 
            do:
              /* излишки */
              logger:StrLogPut =
                "Излишки" + {&new-line} 
                .   
              if (O_FACT - O_PKH) - v-metering-error <= 0 then 
              do:
                /* все укладывается в погрешность */
                assign
                  v-rsrv-qnty          = 0
                  v-metering-qnty-base = v-metering-error-base
                  v-metering-qnty-cli  = v-metering-error-cli
                  .
                logger:StrLogPut =
                  "Все укладывается в погрешность " + string(if v-metering-error <> ? then v-metering-error else 0) + {&new-line} + 
                  "погрешность в кг   " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + {&new-line} +
                  "погрешность в литрах   " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + {&new-line}.
      
                case ptrlprop-algrvspt :
                  when 1 then 
                    do:
                    end.
                  when 2 then 
                    do:
                      if v-metering-error > (O_FACT - O_PKH) then 
                      do:
                        /* уменьшим погрешность измерения, чтобы она была не больше дельты РКН и ФАКТ */
                        if ptrlprop-expptrl = {&calc-petrol-weight} then 
                        do:
                          assign
                            v-metering-error-cli  = (O_FACT-cli - O_PKH-cli)
                            v-metering-error-base = v-metering-error-cli / v-metering-error-dens
                            .
                          logger:StrLogPut =                          
                            "Алгоритм №2 для литров" + {&new-line} + 
                            "погрешность в кг   " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + {&new-line} +
                            "погрешность в литрах   " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + {&new-line} .
                        end.
                        else 
                        do:
                          assign
                            v-metering-error-base = (O_FACT-base - O_PKH-base)
                            v-metering-error-cli  = v-metering-error-base * v-metering-error-dens
                            .
                          logger:StrLogPut =
                            "Алгоритм №2 для кг" + {&new-line} + 
                            "погрешность в кг   " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + {&new-line} +
                            "погрешность в литрах   " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + {&new-line} .
                        end.
                      end.
                    end.
                  when 4 then 
                    do:
                    end.
                end case.
              end.
              else 
              do:
                /* в погрешность не укладывается, пересчитываем по алгоритму */
                assign
                  v-rsrv-qnty          = (O_FACT - O_PKH) - (if v-without-mt-err = true then 0 else v-metering-error)
                  v-metering-qnty-base = (if v-without-mt-err = true then 0 else v-metering-error-base)
                  v-metering-qnty-cli  = (if v-without-mt-err = true then 0 else v-metering-error-cli )
                  .
                logger:StrLogPut =
                  "В погрешность не укладывается, пересчитываем по алгоритму" + {&new-line} + 
                  "кол-во   " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + {&new-line} +
                  "погрешность в кг   " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + {&new-line} +
                  "погрешность в литрах   " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + {&new-line} .
              end.
            end. /* излишки */
            else 
            do:
              /* недостача */
              if K2 <> 0 then 
              do:
                /* расчет естественной убыли */
                assign
                  WST-base = 0.0
                  WST-cli  = 0.0
                  .
                logger:StrLogPut =
                  "Недостача" + {&new-line} + 
                  "Ищем предыдущую инвентарзацию" + {&new-line}
                  .   
                /* ищем предыдущую инвентаризацию */
                find last bf-prev_doc-line no-lock
                  where bf-prev_doc-line.obj-type     = buf_doc-line.obj-type
                  and bf-prev_doc-line.obj-code     = buf_doc-line.obj-code
                  and bf-prev_doc-line.prod-type    = buf_doc-line.prod-type
                  and bf-prev_doc-line.prod-code    = buf_doc-line.prod-code
                  and bf-prev_doc-line.artic        = buf_doc-line.artic
                  and bf-prev_doc-line.ext-doc-type = {&TDEDT_Inv}
                  and bf-prev_doc-line.status_      = {&fact}
                  use-index dt-fo
                  no-error.
                if available bf-prev_doc-line then 
                do:
                  assign
                    varfact-order-prev-inv = bf-prev_doc-line.fact-order
                    
                    .
                  find first bf-prev_doc-pl no-lock
                    where bf-prev_doc-pl.obj-type = bf-prev_doc-line.obj-type
                    and bf-prev_doc-pl.obj-code = bf-prev_doc-line.obj-code
                    and bf-prev_doc-pl.pl-code  = buf_rvs-line.pl-code
                    and bf-prev_doc-pl.out-code = bf-prev_doc-line.doc-code
                    and bf-prev_doc-pl.gds-code = buf_rvs-line.gds-code
                    no-error.
                  
                  if ptrlprop-algrvspt = 3 and oNormWast:IsDecommissioned
                    then 
                  do:
                    find first bf-prev_trn-doc no-lock where bf-prev_trn-doc.doc-code = bf-prev_doc-line.doc-code.
                    oNormWast:ParGdsOAttr:ToInvDate = buf_rvs-doc.fact-date.
                    oNormWast:ParGdsOAttr:FromInvDate =  if bf-prev_trn-doc.fact-date <> ? then bf-prev_trn-doc.fact-date else bf-prev_trn-doc.doc-date.
                    oNormWast:ParGdsOAttr:FromInvFQKg = bf-prev_doc-pl.cli-rest-af-qnty.
                    oNormWast:ParGdsOAttr:PlCode = buf_rvs-line.pl-code.
                    oNormWast:FillNormWast().
                  end.
                  logger:StrLogPut =
                    "Алгоритм " + string(ptrlprop-algrvspt) + {&new-line} + 
                    "Естественная убыль - " + string(oNormWast:IsDecommissioned) + {&new-line}
                    .                     
                end.
                else 
                do:
                  assign
                    varfact-order-prev-inv = 0
                    .
                end.
             
  
                if ptrlprop-algrvspt = 3
                  then 
                do:
                  
                  logger:StrLogPut =
                    "Технологические потери по документам ПН в межинвентаризационный период (если есть)" + 
                    "Объект: " + buf_rvs-line.obj-type + string (buf_rvs-line.obj-code) + {&new-line} +
                    "Товар: " + string (buf_goods.gds-code) + " - " + buf_goods.gds-name
                    .
                  
                  for each bf-wst_doc-line no-lock
                    where ( bf-wst_doc-line.obj-type         = buf_doc-line.obj-type
                    and bf-wst_doc-line.obj-code     = buf_doc-line.obj-code
                    and bf-wst_doc-line.prod-type    = buf_doc-line.prod-type
                    and bf-wst_doc-line.prod-code    = buf_doc-line.prod-code
                    and bf-wst_doc-line.artic        = buf_doc-line.artic
                    and 
                    (
                    (bf-wst_doc-line.ext-doc-type <> {&TDEDT_Inv} and bf-wst_doc-line.ext-doc-type <> {&TDEDT_Peresort} and oNormWast:IsDecommissioned)
                    or
                    (bf-wst_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} and not oNormWast:IsDecommissioned)
                    )
                    and bf-wst_doc-line.status_      = {&fact}
                    and bf-wst_doc-line.fact-order   > varfact-order-prev-inv
                    )
                    on error undo block_cre-inv, retry block_cre-inv
                    :
                    
                    if oNormWast:IsDecommissioned
                      then 
                    do:
                      find first bf-wst_trn-doc no-lock where bf-wst_trn-doc.doc-code = bf-wst_doc-line.doc-code.
                      find first bf-wst_doc-pl no-lock
                        where bf-wst_doc-pl.obj-type = bf-wst_doc-line.obj-type
                        and bf-wst_doc-pl.obj-code = bf-wst_doc-line.obj-code
                        and bf-wst_doc-pl.pl-code  = buf_rvs-line.pl-code
                        and bf-wst_doc-pl.out-code = bf-wst_doc-line.doc-code
                        and bf-wst_doc-pl.gds-code = buf_rvs-line.gds-code
                        no-error.
                      if available (bf-wst_doc-pl)
                        then 
                      do:
                        if bf-wst_trn-doc.doc-type = {&income}
                          then oNormWast:NormalWastageHdnler:RegDoc(bf-wst_trn-doc.fact-date, bf-wst_doc-pl.cli-fact-qnty).
                        else oNormWast:NormalWastageHdnler:RegDoc(bf-wst_trn-doc.fact-date, - bf-wst_doc-pl.cli-fact-qnty).
                      end.
                    end.
                    
                    if  bf-wst_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} 
                      then 
                    do:
                      
                      InfoSecsObj = new InfoSectionsTotal ().
                      
                      find first ub.place no-lock where ub.place.pl-code = buf_rvs-line.pl-code 
                        and ub.place.obj-code = buf_rvs-line.obj-code and ub.place.obj-type = buf_rvs-line.obj-type no-error.
                      
                      def var listSecLoc as char no-undo.
                       
                      if available (ub.place)
                        then 
                      do:
                        
                        InfoSecsObj:Initialization(bf-wst_doc-line.doc-code, buf_goods.gds-code).
                        InfoSecsObj:GetDBAllAttr().
                        InfoSecsObj:CalculateTotal().
                        listSecLoc = InfoSecsObj:GetInfoSectionProp(ub.place.loc1).
                        if listSecLoc <> ""
                          then 
                        do:
                          do ii = 1 to num-entries (listSecLoc, {&delim-par}):
                            InfoSecsObj:GetInfoSectionProp(integer (entry (ii, listSecLoc, {&delim-par} ))).
                            logger:StrLogPut =
                              "Номер ПН: " + bf-wst_doc-line.doc-code + {&new-line} +
                              "Место хранения:" + string (ub.place.pl-code) + " - " + ub.place.pl-name + {&new-line} +
                              "Потери при сливе в резервуар: " + string (InfoSecsObj:InfoSectionCurr:TPNormPL) + {&new-line} +
                              "Потери при сливе из АЦ: " + string (InfoSecsObj:InfoSectionCurr:TPNormAuto) + {&new-line} +
                              "Сумма технолог. потерь: " + string (InfoSecsObj:InfoSectionCurr:TPNorm) + {&new-line}
                              .
                            v-normal-tp = v-normal-tp + InfoSecsObj:InfoSectionCurr:TPNorm.
                            v-normal-tp-auto = v-normal-tp-auto + round (InfoSecsObj:InfoSectionCurr:TPNormAuto, 0).
                            v-normal-tp-pl = v-normal-tp-pl + round (InfoSecsObj:InfoSectionCurr:TPNormPL, 0).
                          end.
                        end.
                      end.
                    end.
                  end.
                  
                  if oNormWast:IsDecommissioned
                    then 
                  do:
                    oNormWast:CalcWastNorm().
                    logger:StrLogPut =
                      "Норма естественной убыли хранения " + string (oNormWast:NormWastDays)
                      .
                  end.
                  
                end.
                else 
                do: 
                  for each bf-wst_doc-line no-lock
                    where ( bf-wst_doc-line.obj-type         = buf_doc-line.obj-type
                    and bf-wst_doc-line.obj-code     = buf_doc-line.obj-code
                    and bf-wst_doc-line.prod-type    = buf_doc-line.prod-type
                    and bf-wst_doc-line.prod-code    = buf_doc-line.prod-code
                    and bf-wst_doc-line.artic        = buf_doc-line.artic
                    and bf-wst_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
                    and bf-wst_doc-line.status_      = {&fact}
                    and bf-wst_doc-line.fact-order   > varfact-order-prev-inv
                    and (not can-find (first buf_sale-doc
                    where buf_sale-doc.doc-code = bf-wst_doc-line.doc-code
                    and buf_sale-doc.doc-kind = {&sale-add2-in-tech-refuell}))
                    )
                    or
                    ( bf-wst_doc-line.obj-type         = buf_doc-line.obj-type
                    and bf-wst_doc-line.obj-code     = buf_doc-line.obj-code
                    and bf-wst_doc-line.prod-type    = buf_doc-line.prod-type
                    and bf-wst_doc-line.prod-code    = buf_doc-line.prod-code
                    and bf-wst_doc-line.artic        = buf_doc-line.artic
                    and bf-wst_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                    and bf-wst_doc-line.status_      = {&fact}
                    and bf-wst_doc-line.fact-order   > varfact-order-prev-inv
                    )
                    on error undo block_cre-inv, retry block_cre-inv
                    :
                    find first bf-wst_doc-pl no-lock
                      where bf-wst_doc-pl.obj-type = bf-wst_doc-line.obj-type
                      and bf-wst_doc-pl.obj-code = bf-wst_doc-line.obj-code
                      and bf-wst_doc-pl.pl-code  = buf_rvs-line.pl-code
                      and bf-wst_doc-pl.out-code = bf-wst_doc-line.doc-code
                      and bf-wst_doc-pl.gds-code = buf_rvs-line.gds-code
                      no-error.
                    if available bf-wst_doc-pl then 
                    do:
                      assign
                        WST-base = WST-base + (if bf-wst_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} then bf-wst_doc-pl.fact-qnty else - bf-wst_doc-pl.fact-qnty)
                        WST-cli  = WST-cli + (if bf-wst_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} then bf-wst_doc-pl.cli-fact-qnty else - bf-wst_doc-pl.cli-fact-qnty )
                        .
                    end.
  
                    
                    
                  end.
                end.
  
                assign
                  v-normal-wastage-base = WST-base * K2 / 1000
                  v-normal-wastage-cli  = WST-cli  * K2 / 1000
                  v-normal-wastage-dens = WST-cli / WST-base
                  .
                logger:StrLogPut =
                  "Норма естественной убыли" + {&new-line} +
                  "в килограммах: " + string(if v-normal-wastage-cli <> ? then v-normal-wastage-cli else 0) + {&new-line} +
                  "в литрах: " + string(if v-normal-wastage-base <> ? then v-normal-wastage-base else 0) + {&new-line} +
                  "плотность: " + string(if v-normal-wastage-dens <> ? then v-normal-wastage-dens else 0) + {&new-line}
                  .
              end.
  
              if ptrlprop-expptrl = {&calc-petrol-weight} then 
              do:
                /* работаем относительно килограммов */
                if v-normal-wastage-cli <= 0.0 then 
                do:
                  assign
                    v-normal-wastage-base = 0.0
                    v-normal-wastage-cli  = 0.0
                    .
                end.
                else 
                do:
                  if v-normal-wastage-cli > (O_PKH-cli - O_FACT-cli) then 
                  do:
                    assign
                      v-normal-wastage-cli  = (O_PKH-cli - O_FACT-cli)
                      v-normal-wastage-base = v-normal-wastage-cli / v-normal-wastage-dens
                      .
                  end.
                end.
                assign
                  v-normal-wastage = v-normal-wastage-cli
                  .
              end.
              else 
              do:
                if v-normal-wastage-base <= 0.0 then 
                do:
                  assign
                    v-normal-wastage-base = 0.0
                    v-normal-wastage-cli  = 0.0
                    .
                end.
                else 
                do:
                  if v-normal-wastage-base > (O_PKH-base - O_FACT-base) then 
                  do:
                    assign
                      v-normal-wastage-base = (O_PKH-base - O_FACT-base)
                      v-normal-wastage-cli  = v-normal-wastage-base * v-normal-wastage-dens
                      .
                  end.
                end.
                assign
                  v-normal-wastage = v-normal-wastage-base
                  .
              end.
  
              assign
                v-wastage-qnty-base = v-normal-wastage-base
                v-wastage-qnty-cli  = v-normal-wastage-cli
                .
  
              case ptrlprop-algrvspt :
                when 1 then 
                  do:
                    if (O_PKH - O_FACT) - v-metering-error - v-normal-wastage <= 0 then 
                    do:
                      /* все укладывается в погрешность + естественная убыль */
                      logger:StrLogPut =
                        "Все укладывается в погрешность " + string(if v-metering-error <> ? then v-metering-error else 0) + " + естественную убыль: "
                        +  string(if v-normal-wastage <> ? then v-normal-wastage else 0) + {&new-line} .
                      .
                      assign
                        v-rsrv-qnty          = 0.0
                        v-metering-qnty-base = v-metering-error-base
                        v-metering-qnty-cli  = v-metering-error-cli
                        .
                      if v-normal-wastage > 0 then 
                      do:
                        if (O_PKH - O_FACT) - v-metering-error > 0 then 
                        do:
                          /* в погрешность не укладывается, поэтому учитываем естественную убыль */

                          logger:StrLogPut =
                            "В погрешность не укладывается, поэтому учитываем естественную убыль " +  string(if v-normal-wastage <> ? then v-normal-wastage else 0) + {&new-line} .
                          .
                          if v-normal-wastage > (O_PKH - O_FACT) - v-metering-error then 
                          do:
                            /* уменьшим естественную убыль, чтобы дельта РКН и ФАКТ была равна погрешности измерения */
                            logger:StrLogPut =
                              "Уменьшим естественную убыль, чтобы дельта РКН и ФАКТ была равна погрешности измерения " + {&new-line} .
                            if ptrlprop-expptrl = {&calc-petrol-weight} then 
                            do:
                              assign
                                v-normal-wastage-cli  = (O_PKH-cli - O_FACT-cli) - v-metering-error-cli
                                v-normal-wastage-base = v-normal-wastage-cli / v-normal-wastage-dens
                                .
                              logger:StrLogPut =
                                "Естественная убыль: " + string(if v-normal-wastage-cli <> ? then v-normal-wastage-cli else 0) + " " 
                                + string(if v-normal-wastage-base <> ? then v-normal-wastage-base else 0) + {&new-line} .
                            end.
                            else 
                            do:
                              assign
                                v-normal-wastage-base = (O_PKH-base - O_FACT-base) - v-metering-error-base
                                v-normal-wastage-cli  = v-normal-wastage-base * v-normal-wastage-dens
                                .
                              logger:StrLogPut =
                                "Естественная убыль: " + string(if v-normal-wastage-cli <> ? then v-normal-wastage-cli else 0) + " " 
                                + string(if v-normal-wastage-base <> ? then v-normal-wastage-base else 0) + {&new-line} .
                            end.
                          end.
                        end.
                        else 
                        do:
                          /* все укладывается в погрешность */
                          logger:StrLogPut =
                            "Все укладывается в погрешность" + {&new-line} .
                          assign
                            v-normal-wastage-cli  = 0.0
                            v-normal-wastage-base = 0.0
                            .
                        end.
                      end.
                    end.
                    else 
                    do:
                      /* в погрешность не укладывается, пересчитываем по алгоритму */
                      logger:StrLogPut =
                        "В погрешность не укладывается, пересчитываем по алгоритму" .
                      assign
                        v-rsrv-qnty          = - ( (O_PKH - O_FACT)
                                                  - (if v-cre-add-docs   = true then v-normal-wastage else 0.0)
                                                  - (if v-without-mt-err = true then 0.0 else v-metering-error)
                                                )
                        v-metering-qnty-base = (if v-without-mt-err = true then 0 else v-metering-error-base)
                        v-metering-qnty-cli  = (if v-without-mt-err = true then 0 else v-metering-error-cli )
                        .
                      logger:StrLogPut =
                        "Кол-во: v-rsrv-qnty " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + {&new-line} +
                        "Погрешность v-metering-qnty-base " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + {&new-line} +
                        "Погрешность v-metering-qnty-cli" + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + {&new-line} 
                        .
                    end.
                  end.
                when 2 then 
                  do:
                    if v-normal-wastage = (O_PKH - O_FACT) then 
                    do:
                      /* естественная убыль покрыла разницу */
                      assign
                        v-rsrv-qnty          = - ( (O_PKH - O_FACT)
                                        - (if v-cre-add-docs = true then v-normal-wastage else 0.0)
                                      )
                        v-metering-qnty-base = 0.0
                        v-metering-qnty-cli  = 0.0
                        .
                      logger:StrLogPut =
                        "Естественная убыль покрыла разницу" + string(if v-normal-wastage <> ? then v-normal-wastage else 0) + {&new-line} +
                        "Кол-во: v-rsrv-qnty " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + {&new-line} +
                        "Погрешность v-metering-qnty-base " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + {&new-line} +
                        "Погрешность v-metering-qnty-cli " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + {&new-line} 
                        .
                    end.
                    else 
                    do:
                      if (O_PKH - O_FACT) - v-metering-error - v-normal-wastage <= 0 then 
                      do:
                        /* все укладывается в погрешность + естественная убыль */
                        logger:StrLogPut =
                          "Все укладывается в погрешность " + string(if v-metering-error <> ? then v-metering-error else 0) + " + естественную убыль: " +  
                          string(if v-normal-wastage <> ? then v-normal-wastage else 0) + {&new-line} .
                        if v-metering-error > (O_PKH - O_FACT) - v-normal-wastage  then 
                        do:
                          /* уменьшим погрешность измерения, чтобы она была не больше дельты РКН и ФАКТ с учетом ЕУ */
                          if ptrlprop-expptrl = {&calc-petrol-weight} then 
                          do:
                            assign
                              v-metering-error-cli  = (O_PKH-cli - O_FACT-cli) - v-normal-wastage-cli
                              v-metering-error-base = v-metering-error-cli / v-metering-error-dens
                              v-metering-error      = v-metering-error-cli
                              .
                          end.
                          else 
                          do:
                            assign
                              v-metering-error-base = (O_PKH-base - O_FACT-base) - v-normal-wastage-base
                              v-metering-error-cli  = v-metering-error-base * v-metering-error-dens
                              v-metering-error      = v-metering-error-base
                              .
                          end.
                          logger:StrLogPut =
                            "уменьшим погрешность измерения, чтобы она была не больше дельты РКН и ФАКТ с учетом ЕУ" + {&new-line} +
                            "Погрешность v-metering-error-base " + string(if v-metering-error-base <> ? then v-metering-error-base else 0) + {&new-line} +
                            "Погрешность v-metering-error-cli " + string(if v-metering-error-cli <> ? then v-metering-error-cli else 0) + {&new-line} +
                            "Погрешность v-metering-error " + string(if v-metering-error <> ? then v-metering-error else 0) + {&new-line} 
                            .
                        end.
                        assign
                          v-rsrv-qnty          = - ( (O_PKH - O_FACT)
                                          - (if v-cre-add-docs = true then v-normal-wastage else 0.0)
                                          - v-metering-error
                                        )
                          v-metering-qnty-base = v-metering-error-base
                          v-metering-qnty-cli  = v-metering-error-cli
                          .
                        logger:StrLogPut =
                          "Кол-во: v-rsrv-qnty " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + {&new-line} +
                          "Погрешность v-metering-qnty-base " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + {&new-line} +
                          "Погрешность v-metering-qnty-cli" + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + {&new-line} 
                          .
                      end. /* if (O_PKH - O_FACT) - v-metering-error - v-normal-wastage <= 0 then */
                      else 
                      do:
                        /* в погрешность не укладывается, пересчитываем по алгоритму */
                        assign
                          v-rsrv-qnty          = - ( (O_PKH - O_FACT)
                                                    - (if v-cre-add-docs   = true then v-normal-wastage else 0.0)
                                                    - (if v-without-mt-err = true then 0.0 else v-metering-error)
                                                  )
                          v-metering-qnty-base = (if v-without-mt-err = true then 0 else v-metering-error-base)
                          v-metering-qnty-cli  = (if v-without-mt-err = true then 0 else v-metering-error-cli )
                          .
                        logger:StrLogPut =
                          "в погрешность не укладывается, пересчитываем по алгоритму " + {&new-line} +
                          "Кол-во: v-rsrv-qnty " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + {&new-line} +
                          "Погрешность v-metering-qnty-base " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + {&new-line} + 
                          "Погрешность v-metering-qnty-cli" + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + {&new-line} 
                          .
                      end.
                    end.
                  end.
                when 2 then 
                  do:
  
                  end.
                
                
              end case.
              if v-cre-add-docs   = true
                and v-normal-wastage-base <> 0.0
                and v-normal-wastage-cli <> 0.0
                then 
              do:
                create tt-line-for-doc.
                assign
                  tt-line-for-doc.gds-code      = buf_rvs-line.gds-code
                  tt-line-for-doc.pl-code       = buf_rvs-line.pl-code
                  tt-line-for-doc.fact-qnty     = v-normal-wastage-base
                  tt-line-for-doc.fact-cli-qnty = v-normal-wastage-cli
                  .
              end.
            end. /* недостача */
            if ptrlprop-algrvspt = 3
              then 
            do:
            
              rvsinvsubObj = new rvsinvsub ().
              
              rvsinvsubObj:RvsCode  = buf_rvs-line.rvs-code.
              rvsinvsubObj:ObjType  = buf_rvs-line.obj-type.
              rvsinvsubObj:ObjCode  = buf_rvs-line.obj-code.
              rvsinvsubObj:PlCode   = buf_rvs-line.pl-code. 
              rvsinvsubObj:GdsCode  = buf_rvs-line.gds-code.
              MKN = O_PKH-cli.
              MFO = O_FACT-cli.
              MFOR = v-all-state-measure-cli-qnty.
              MFOT = v-all-state-add-cli-qnty.
              beta1 = K1.
              beta2 = K3.
              dMMBd = (beta1 * MFOR + beta2 * MFOT) / 100.
              rvsinvsubObj:Diff = MFO - MKN.
              
              dM = MFO - MKN.
              
              logger:StrLogPut =
                "Алгоритм: " + string(ptrlprop-algrvspt) + {&new-line} +
                "Номер сверки: " + string(rvsinvsubObj:RvsCode) + {&new-line} +
                "Номер резервуара: " + string(rvsinvsubObj:PlCode) + {&new-line} +
                "Код товара: " + string(rvsinvsubObj:GdsCode) + {&new-line} +        
                "MKN: " + string(MKN) + {&new-line} +        
                "MFO: " + string(MFO) + {&new-line}  +       
                "MFOR: " + string(MFOR) + {&new-line}  +       
                "MFOT: " + string(MFOT) + {&new-line}   +      
                "beta1: " + string(beta1) + {&new-line} +        
                "beta2: " + string(beta2) + {&new-line} +        
                "dMMBd: " + string(dMMBd) + {&new-line}  +                      
                "rvsinvsubObj:Diff: " + string(beta2) + {&new-line} +        
                "dM: " + string(dMMBd) + {&new-line}   .
              if absolute (dM) <= dMMBd
                then 
              do:
                v-rsrv-qnty = 0.
                v-reserv-qnty-cli = 0.
              end.
              else 
              do: /*излишки*/
                if MFO > MKN
                  then 
                do:
                  dM = MFO - MKN.
                  MI = dM - dMMBd. 
                  MKKN = MKN + MI.
                  v-rsrv-qnty = (MI) / v-avg-state-density.
                  logger:StrLogPut =
                    "Излишки: " + {&new-line} +
                    "MI: " + string(MI) + {&new-line} +
                    "MKKN: " + string(MKKN) + {&new-line} +
                    "v-rsrv-qnty: " + string(v-rsrv-qnty) + {&new-line}         
                    .
                end.
                else 
                do: /*недостача*/
                  dMPT = v-normal-tp.
                  dMPOT = oNormWast:NormWastDays + dMPT.
                  MPOT = MKN - MFO - dMMBd.
                  if absolute (dM) <= dMMBd + dMPOT
                    then 
                  do:
                    MKKN = MFO + dMMBd.
                  end.
                  else 
                  do:
                    MKKN = MFO + dMMBd.
                  /*                  MNED = MKN - MFO - dMMBd - dMPOT.*/
                  end.
                  v-rsrv-qnty = (MKKN - MKN) / v-avg-state-density.
                 
                  logger:StrLogPut =
                    "Недостача: " + {&new-line} +
                    "dMPT: " + string(dMPT) + {&new-line} +
                    "dMPOT: " + string(dMPOT) + {&new-line} +
                    "MPOT: " + string(MPOT) + {&new-line} +
                    "MKKN: " + string(MKKN) + {&new-line} +
                    "v-rsrv-qnty: " + string(v-rsrv-qnty) + {&new-line}         
                    .
                end.
                
              end.
  
              if v-rsrv-qnty >= 0 /*не баланс всегда отрицательное число, но для удобства сделаем ему знак плюч если излишки*/ 
                then 
              do: 
                rvsinvsubObj:Diff = absolute (rvsinvsubObj:Diff).
              end.
              else 
              do:
                rvsinvsubObj:Diff = - absolute (rvsinvsubObj:Diff).
              end.
                          
              rvsinvsubObj:MeteringErr = dMMBd.
              if rvsinvsubObj:Diff < 0
                then 
              do:
                rvsinvsubObj:TPNormalAuto = v-normal-tp-auto.
                rvsinvsubObj:TPNormalPl = v-normal-tp-pl.
                rvsinvsubObj:NormalWastage = oNormWast:NormWastDays.
              end.
              else 
              do:
                rvsinvsubObj:NormalWastage = 0.
                rvsinvsubObj:TPNormalAuto = 0.
                rvsinvsubObj:TPNormalPl = 0.
              end.
              rvsinvstrObj = new rvsinvstr ().
              rvsinvstrObj:insertDB(rvsinvsubObj).
              logger:StrLogPut =
                "--------------" + {&new-line} +
                "Данные для инвентаризации:" +
                {&new-line} + 
                rvsinvsubObj:ObjType + string (rvsinvsubObj:ObjCode) + {&new-line} +
                "Сверка:" + rvsinvsubObj:RvsCode + {&new-line} +
                "Место хранения:" + string (rvsinvsubObj:PlCode) + {&new-line} +
                "Расчетно-книжный остаток (включая трубопровод) MKN: " + string (MKN) + {&new-line} +
                "Факт. остаток по рез. изм. в резер. MFOR: " + string (MFOR) + {&new-line} +
                "Факт. остаток по рез. изм. в трубопроводе MFOT: " + string (MFOT) + {&new-line} +
                "Факт. остаток по рез. изм. MFO: " + string (MFO) + {&new-line} +
                "Погр.изм. резер. beta1, %: " + string (beta1) + {&new-line} +
                "Погр.изм. трубопровод beta2, %: " + string (beta2) + {&new-line} +
                "Допускаемый небаланс dMMBd = (beta1 * MFOR + beta2 * MFOT) / 100: " + string(dMMBd) + {&new-line} +
                "Сумма по ПН технол. потерь в резервуаре: " + string (v-normal-tp-pl) + {&new-line} +
                "Сумма по ПН технол. потерь при сливе из АЦ: " + string (v-normal-tp-auto) + {&new-line} +
                "Общая сумма по ПН технол. потерь dMPT: " + string (v-normal-tp) + {&new-line} +
                "Общая сумма ест. убыли при хр. dMHREY : " + string (oNormWast:NormWastDays) + {&new-line} +
                "Небаланс |dM|: " + string (absolute (dM)) + {&new-line} +
                "Недостача MNED : " + string (absolute (MNED)) + {&new-line} +
                "Излишки MI : " + string (absolute (MI)) + {&new-line} +
                "Скорректированный расчетно-книжный остаток (включая трубопровод) MKKN: " + string (MKKN) + {&new-line}
                .
              
              
            
            
              def var v-infom-mess as char no-undo. 
              if absolute (rvsinvsubObj:Diff) > rvsinvsubObj:MeterErrWast
                then 
              do:
                v-infom-mess = v-infom-mess + substitute ("Назв. товара - &2&1Скл.место - &3, РКО,кг - &4, Факт., кг - &5&1&6, кг - &7&1"
                  , {&new-line}
                  ,buf_goods.gds-name
                  ,string(rvsinvsubObj:PlCode)
                  ,string(round (MKN, 3))
                  ,string(round (MFO, 3))
                  ,(if rvsinvsubObj:Diff < 0 then "Недостача" else "Излишки")
                  ,string (round (rvsinvsubObj:DeficitOver, 3))
                  ).
              end.
            
            end.
            
            if not ptrlprop-algrvspt = 3
              then
              
              if ptrlprop-expptrl = {&calc-petrol-weight} then 
              do:
                /* работаем относительно килограммов */
                assign
                  v-reserv-qnty-cli = v-rsrv-qnty
                  .
                if varinv-set = true then 
                do: /* установлен параметр, выставляем кол-ва по плотности */
                  assign
                    v-reserv-qnty-base = ( v-fact-cli-qnty + v-reserv-qnty-cli - (if v-cre-add-docs = true then v-normal-wastage-cli else 0.0)
                                          ) / buf_rvs-line.state-density - ( v-fact-qnty - (if v-cre-add-docs = true then v-normal-wastage-base else 0.0) )
                    .
                  logger:StrLogPut =
                    "Установлен параметр, выставляем кол-ва по плотности" + {&new-line} +
                    "Кол-во : " + string(if v-reserv-qnty-base <> ? then v-reserv-qnty-base else 0) + {&new-line}    
                    .
                end.
                else 
                do:
                  assign
                    v-reserv-qnty-base = v-reserv-qnty-cli / v-avg-state-density
                    .
                  logger:StrLogPut =
                        
                    "Кол-во : " + string(if v-reserv-qnty-base <> ? then v-reserv-qnty-base else 0) + {&new-line}    
                    .
                end.
              end.
              else 
              do:
                assign
                  v-reserv-qnty-base = v-rsrv-qnty
                  .
                if varinv-set = true then 
                do: /* установлен параметр, выставляем кол-ва по плотности */
                  assign
                    v-reserv-qnty-cli = ( v-fact-qnty + v-reserv-qnty-base - (if v-cre-add-docs = true then v-normal-wastage-base else 0.0)
                                        ) * buf_rvs-line.state-density - ( v-fact-cli-qnty - (if v-cre-add-docs = true then v-normal-wastage-cli else 0.0) )
                    .
                  logger:StrLogPut =
                    "Установлен параметр, выставляем кол-ва по плотности" + {&new-line} +
                    "Кол-во : " + string(if v-reserv-qnty-cli <> ? then v-reserv-qnty-cli else 0) + {&new-line}    
                    .
                end.
                else 
                do:
                  assign
                    v-reserv-qnty-cli = v-reserv-qnty-base * v-avg-state-density
                    .

                  logger:StrLogPut =
                        
                    "Кол-во : " + string(if v-reserv-qnty-cli <> ? then v-reserv-qnty-cli else 0) + {&new-line}    
                    .
                end.
              end.
            else 
            do:
              v-reserv-qnty-base = v-rsrv-qnty.
              assign
                v-reserv-qnty-cli = v-reserv-qnty-base * v-avg-state-density
                .

              logger:StrLogPut =
                        
                "Кол-во : " + string(v-reserv-qnty-cli) + {&new-line}    
                .
            end.
          end.
          else do:
            assign
              v-reserv-qnty-cli  = O_FACT-cli - O_PKH-cli
              v-reserv-qnty-base = O_FACT-base - O_PKH-base 
              .

            logger:StrLogPut =
              "Кол-во кг: " + string(v-reserv-qnty-cli) + {&new-line} +   
              "Кол-во литры: " + string(v-reserv-qnty-base) + {&new-line}    
              .
          end.
          if v-reserv-qnty-cli = ? then v-reserv-qnty-cli = 0 .
          if v-reserv-qnty-base = ? then v-reserv-qnty-base = 0 .
          
          if v-reserv-qnty-base <> 0 then 
          do:
            assign
              v-chg-qnty = v-reserv-qnty-base
              .
            run trg/rsrv-dtl.p
              ( input parparentproc
              , input {&rsrv-dtl_action_reserv} + "," + {&rsrv-dtl_pl-code} + "=" + string(buf_rvs-line.pl-code)
              , buffer buf_gds-dtl
              , input-output v-chg-qnty
              , input-output buf_doc-line.price-base
              , input-output buf_doc-line.price-rubl
              , input -1
              , input ""
              ) no-error.
            if error-status :error then 
            do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка резервирования." skip
                error-status:get-message(1)      skip
                error-status:get-message(2)      skip
                return-value
                view-as alert-box error.
              undo block_cre-inv, retry block_cre-inv.
            end.
            if v-chg-qnty <> v-reserv-qnty-base then 
            do:
              message
                vss-workfile vss-revision vss-description skip
                "Не удалось произвести автоматическое резервирование на все кол-во." skip
                substitute( "Для документа инвентаризации по месту хранения &1", buf_rvs-line.pl-code ) skip
                "Инвентаризация не может быть сделана автоматически."
                view-as alert-box.
              undo block_cre-inv, retry block_cre-inv.
            end.
          end.
          if v-reserv-qnty-base <> 0
            or v-reserv-qnty-cli <> 0
            then 
          do:
            assign
              buf_gds-dtl.fact-qnty       = buf_gds-dtl.fact-qnty       + v-reserv-qnty-base
              buf_gds-dtl.doc-qnty        = buf_gds-dtl.doc-qnty        + v-reserv-qnty-base
              buf_doc-line.doc-qnty       = buf_doc-line.doc-qnty       + v-reserv-qnty-base
              buf_doc-line.fact-qnty      = buf_doc-line.fact-qnty      + v-reserv-qnty-base
              buf_doc-line.cli-qnty       = buf_doc-line.cli-qnty       + v-reserv-qnty-cli
              buf_inv-line.wast-cli-qnty  = buf_inv-line.wast-cli-qnty  + v-reserv-qnty-cli

              buf_doc-pl.doc-qnty         = buf_doc-pl.doc-qnty         + v-reserv-qnty-base
              buf_doc-pl.cli-qnty         = buf_doc-pl.cli-qnty         + v-reserv-qnty-cli
              buf_doc-pl.rest-af-qnty     = buf_doc-pl.rest-af-qnty     + v-reserv-qnty-base
              buf_doc-pl.cli-rest-af-qnty = buf_doc-pl.cli-rest-af-qnty + v-reserv-qnty-cli
              buf_doc-pl.fact-qnty        = buf_doc-pl.doc-qnty
              buf_doc-pl.cli-doc-qnty     = buf_doc-pl.cli-qnty
              buf_doc-pl.cli-fact-qnty    = buf_doc-pl.cli-qnty
              .
          end.

          create buf_doc-line-sum .
          assign
            buf_doc-line-sum.doc-code  = v-inv-code
            buf_doc-line-sum.gds-code  = buf_rvs-line.gds-code
            buf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", {&sum-wastage-doc}, {&delim-par}, "base":U, buf_rvs-line.pl-code )
            buf_doc-line-sum.fact-qnty = v-wastage-qnty-base
            /*                buf_doc-line-sum.sale-sum-base       = varwast-sum-sale-base-line * wast-goods.normal-wastage * 0.01*/
            /*                buf_doc-line-sum.sale-sum-rubl       = varwast-sum-sale-rubl-line * wast-goods.normal-wastage * 0.01*/
            /*                buf_doc-line-sum.cost-sum-base       = varwast-sum-base-line      * wast-goods.normal-wastage * 0.01*/
            /*                buf_doc-line-sum.cost-sum-rubl       = varwast-sum-rubl-line      * wast-goods.normal-wastage * 0.01*/
            .
          create buf_doc-line-sum .
          assign
            buf_doc-line-sum.doc-code  = v-inv-code
            buf_doc-line-sum.gds-code  = buf_rvs-line.gds-code
            buf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", "mterr":U, {&delim-par}, "base":U, buf_rvs-line.pl-code )
            buf_doc-line-sum.fact-qnty = v-metering-qnty-base
            .
          create buf_doc-line-sum .
          assign
            buf_doc-line-sum.doc-code  = v-inv-code
            buf_doc-line-sum.gds-code  = buf_rvs-line.gds-code
            buf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", {&sum-wastage-doc}, {&delim-par}, "cli":U, buf_rvs-line.pl-code )
            buf_doc-line-sum.fact-qnty = v-wastage-qnty-cli
            .
          create buf_doc-line-sum .
          assign
            buf_doc-line-sum.doc-code  = v-inv-code
            buf_doc-line-sum.gds-code  = buf_rvs-line.gds-code
            buf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", "mterr":U, {&delim-par}, "cli":U, buf_rvs-line.pl-code )
            buf_doc-line-sum.fact-qnty = v-metering-qnty-cli
            .

        end. /* each buf_rvs-line */
        assign
          buf_inv-line.after-cli-qnty = buf_inv-line.wast-cli-qnty
          buf_doc-line.doc-density    = buf_inv-line.wast-cli-qnty / buf_doc-line.doc-qnty
          .
        if buf_doc-line.doc-density = ? then 
        do:
          assign
            buf_doc-line.doc-density = 1 / buf_goods.cli-base-rate
            .
        end.

        assign
          buf_doc-line.fact-density = buf_doc-line.doc-density
          .
      end. /* пустая шкала или отсутствие шкалы */
      else 
      do:
        message
          "Режим инвентаризации по сверке работает только в товарах без признаков." skip
          "Откатываем создание инвентаризации."
          view-as alert-box error.
        undo block_cre-inv, retry block_cre-inv.
      end.
      { str/reclcinv.i
        "'update'":U
        recid(buf_doc-line)
        v-inv-code
        vartot-docold
        vartot-rublold
        i-total-doc-line_tot-ovold
        i-total-doc-line_fact-rublold
        i-total-doc-line_fact-baseold
        i-total-doc-line_fact-qntyold
        i-total-doc-line_doc-qntyold
        i-total-doc-line_cli-qntyold
        i-total-parts_fact-baseold
        i-total-parts_fact-rublold
        i-total-parts_fact-qntyold
        no-error
      }
      if error-status :error then 
      do:
        undo block_cre-inv, retry block_cre-inv.
      end.
    end. /* each buf_doc-line */

    run gbl/calc-trn.p
      ( input parparentproc
      , recid( buf_trn-doc )
      ) no-error.
    if error-status :error then 
    do:
      undo block_cre-inv, retry block_cre-inv.
    end.

    if v-cre-add-docs = true then 
    do:

      find first tt-line-for-doc no-lock
        where tt-line-for-doc.fact-qnty > 0
        no-error.
      if available tt-line-for-doc then 
      do:
        run doc-code in this-procedure
          ( input  "pair"
          , input  v-cntxt-obj-type
          , input  v-cntxt-obj-code
          , input  v-inv-code
          , output v-spi-code
          ) no-error.
        if error-status:error then 
        do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка вычисления номера документа списания." skip
            return-value skip
            trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
          undo block_cre-inv, retry block_cre-inv.
        end.
        { str/crtrndoc.i
          ?
          ?
          buf_trn-doc.base-rate
          buf_trn-doc.base-scale
          buf-add_clients.obj-code
          buf-add_clients.obj-type
          buf-add_clients.obj-name
          v-cntxt-db-num
          v-cntxt-userid
          {&percent}
          v-spi-code
          buf_trn-doc.doc-date
          {&write-off}
          no
          buf_trn-doc.host-code
          no
          buf_trn-doc.obj-code
          buf_trn-doc.obj-type
          no
          buf_trn-doc.pay-code
          "substitute( '@  Списание к документу инвентаризации &1', v-inv-code )"
          no
          "{&without-slt}"
          {&wayb}
          "{&inc-vat}"
          {&TDEDT_Spi_Vnesh}
          ?
          no-error
        }
        if error-status:error then 
        do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при генерации документа списания по инвентаризации &1", v-inv-code ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo block_cre-inv, retry block_cre-inv.
        end.
        find buf-spi_trn-doc
          where buf-spi_trn-doc.doc-code = v-spi-code
          .
        assign
          buf-spi_trn-doc.shift-date = buf_trn-doc.shift-date
          buf-spi_trn-doc.shift-num  = buf_trn-doc.shift-num
          buf-spi_trn-doc.out-code   = v-inv-code
          buf-spi_trn-doc.exch-code  = buf_trn-doc.exch-code
          buf-spi_trn-doc.exch-rate  = buf_trn-doc.exch-rate
          buf-spi_trn-doc.exch-scale = buf_trn-doc.exch-scale
          buf-spi_trn-doc.print-rubl = buf_trn-doc.print-rubl
          buf-spi_trn-doc.agnt       = buf_trn-doc.agnt
          buf-spi_trn-doc.wrkr       = buf_trn-doc.wrkr
          buf-spi_trn-doc.boss       = buf_trn-doc.boss
          .

        for each tt-line-for-doc no-lock
          ,first buf_goods no-lock
          where buf_goods.gds-code = tt-line-for-doc.gds-code
          break by tt-line-for-doc.gds-code
          on error undo block_cre-inv, retry block_cre-inv
          :
          find first buf-spi_doc-line no-lock
            where buf-spi_doc-line.doc-code  = v-spi-code
            and buf-spi_doc-line.artic     = buf_goods.artic
            and buf-spi_doc-line.prod-type = buf_goods.prod-type
            and buf-spi_doc-line.prod-code = buf_goods.prod-code
            no-error .
          if not available buf-spi_doc-line then 
          do:
            { str/adinvlin.i
              parparentproc
              v-spi-code
              buf_goods.artic
              buf_goods.prod-type
              buf_goods.prod-code
              v-recid
            }
            { gbl/termnode.i
              buf_goods.prt-root
              v-prt-root
            }
            { str/crgdsdtl.i
              buf_trn-doc.obj-code
              buf_trn-doc.obj-type
              v-spi-code
              buf_goods.artic
              buf_goods.prod-code
              buf_goods.prod-type
              v-prt-root
              yes
            }
          end.
          create buf-spi_doc-pl.
          assign
            buf-spi_doc-pl.obj-type      = buf_trn-doc.obj-type
            buf-spi_doc-pl.obj-code      = buf_trn-doc.obj-code
            buf-spi_doc-pl.pl-code       = tt-line-for-doc.pl-code
            buf-spi_doc-pl.out-code      = v-spi-code
            buf-spi_doc-pl.gds-code      = buf_goods.gds-code
            buf-spi_doc-pl.doc-qnty      = tt-line-for-doc.fact-qnty
            buf-spi_doc-pl.fact-qnty     = tt-line-for-doc.fact-qnty
            buf-spi_doc-pl.cli-qnty      = tt-line-for-doc.fact-cli-qnty
            buf-spi_doc-pl.cli-doc-qnty  = tt-line-for-doc.fact-cli-qnty
            buf-spi_doc-pl.cli-fact-qnty = tt-line-for-doc.fact-cli-qnty
            .

          find first buf-spi_gds-dtl exclusive-lock
            where buf-spi_gds-dtl.doc-code    = v-spi-code
            and buf-spi_gds-dtl.artic       = buf_goods.artic
            and buf-spi_gds-dtl.prod-type   = buf_goods.prod-type
            and buf-spi_gds-dtl.prod-code   = buf_goods.prod-code
            and buf-spi_gds-dtl.prt-code    = v-prt-root
            .
          find first buf_doc-line exclusive-lock
            where buf_doc-line.doc-code  = v-inv-code
            and buf_doc-line.artic     = buf_goods.artic
            and buf_doc-line.prod-type = buf_goods.prod-type
            and buf_doc-line.prod-code = buf_goods.prod-code
            .
          find first buf-spi_doc-line exclusive-lock
            where buf-spi_doc-line.doc-code  = v-spi-code
            and buf-spi_doc-line.artic     = buf_goods.artic
            and buf-spi_doc-line.prod-type = buf_goods.prod-type
            and buf-spi_doc-line.prod-code = buf_goods.prod-code
            .
          find first buf-spi_inv-line exclusive-lock
            where buf-spi_inv-line.doc-code  = v-spi-code
            and buf-spi_inv-line.artic     = buf_goods.artic
            and buf-spi_inv-line.prod-type = buf_goods.prod-type
            and buf-spi_inv-line.prod-code = buf_goods.prod-code
            .
          if first-of( tt-line-for-doc.gds-code ) then 
          do:
            assign
              v-fact-qnty     = 0.0
              v-fact-cli-qnty = 0.0
              .
            for each buf_tt-line-for-doc
              where buf_tt-line-for-doc.gds-code = buf_goods.gds-code
              on error undo block_cre-inv, retry block_cre-inv
              :
              assign
                v-fact-qnty     = v-fact-qnty     + buf_tt-line-for-doc.fact-qnty
                v-fact-cli-qnty = v-fact-cli-qnty + buf_tt-line-for-doc.fact-cli-qnty
                .
            end.
            assign
              buf-spi_doc-line.doc-density   = v-fact-cli-qnty / v-fact-qnty
              buf-spi_doc-line.fact-density  = buf-spi_doc-line.doc-density
              buf-spi_doc-line.cli-base-rate = 1.0 / buf-spi_doc-line.doc-density
              buf-spi_doc-line.cli-qnty      = 0.0
              buf-spi_doc-line.doc-qnty      = 0.0
              buf-spi_doc-line.fact-qnty     = 0.0
              buf-spi_doc-line.price-rubl    = buf_doc-line.price-rubl
              buf-spi_doc-line.price-base    = buf_doc-line.price-base
              buf-spi_doc-line.price-cli     = buf_doc-line.price-cli
              buf-spi_gds-dtl.doc-qnty       = 0.0
              buf-spi_gds-dtl.fact-qnty      = 0.0
              /*                buf-spi_gds-dtl.price-rubl     = buf_doc-line.price-rubl*/
              /*                buf-spi_gds-dtl.price-base     = buf_doc-line.price-base*/
              .
          end.

          if tt-line-for-doc.fact-qnty <> 0 then 
          do:
            assign
              v-chg-qnty = tt-line-for-doc.fact-qnty
              .
            run trg/rsrv-dtl.p
              ( input parparentproc
              , input {&rsrv-dtl_action_reserv} + "," + {&rsrv-dtl_pl-code} + "=" + string(tt-line-for-doc.pl-code)
              , buffer buf-spi_gds-dtl
              , input-output v-chg-qnty
              , input-output buf-spi_doc-line.price-base
              , input-output buf-spi_doc-line.price-rubl
              , input -1
              , input ""
              ) no-error.
            if error-status :error then 
            do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка резервирования." skip
                error-status:get-message(1)      skip
                error-status:get-message(2)      skip
                return-value
                view-as alert-box error.
              undo block_cre-inv, retry block_cre-inv.
            end.
            if v-chg-qnty <> tt-line-for-doc.fact-qnty then 
            do:
              message
                vss-workfile vss-revision vss-description skip
                "Не удалось произвести автоматическое резервирование на все кол-во." skip
                substitute( "Для списания естественной убыли по месту хранения &1", tt-line-for-doc.pl-code ) skip
                "Инвентаризация не может быть сделана автоматически."
                view-as alert-box.
              undo block_cre-inv, retry block_cre-inv.
            end.
            assign
              buf-spi_gds-dtl.fact-qnty      = buf-spi_gds-dtl.fact-qnty      + tt-line-for-doc.fact-qnty
              buf-spi_gds-dtl.doc-qnty       = buf-spi_gds-dtl.doc-qnty       + tt-line-for-doc.fact-qnty
              buf-spi_doc-line.doc-qnty      = buf-spi_doc-line.doc-qnty      + tt-line-for-doc.fact-qnty
              buf-spi_doc-line.fact-qnty     = buf-spi_doc-line.fact-qnty     + tt-line-for-doc.fact-qnty
              buf-spi_doc-line.cli-qnty      = buf-spi_doc-line.cli-qnty      + tt-line-for-doc.fact-cli-qnty
              buf-spi_inv-line.wast-cli-qnty = buf-spi_inv-line.wast-cli-qnty + tt-line-for-doc.fact-cli-qnty
              .
          end.
        end.

        run gbl/calc-trn.p
          ( input parparentproc
          , recid( buf-spi_trn-doc )
          ) no-error.
        if error-status :error then 
        do:
          undo block_cre-inv, retry block_cre-inv.
        end.

        for each buf-spi_doc-line exclusive-lock
          where buf-spi_doc-line.doc-code = v-spi-code
          ,each buf-spi_inv-line exclusive-lock
          where buf-spi_inv-line.doc-code  = buf-spi_doc-line.doc-code
          and buf-spi_inv-line.artic     = buf-spi_doc-line.artic
          and buf-spi_inv-line.prod-type = buf-spi_doc-line.prod-type
          and buf-spi_inv-line.prod-code = buf-spi_doc-line.prod-code
          on error undo block_cre-inv, retry block_cre-inv
          :
          { str/corinvln.i
            buf-spi_doc-line.doc-code
            buf-spi_doc-line.artic
            buf-spi_doc-line.prod-type
            buf-spi_doc-line.prod-code
            ?
            ?
            ?
            ?
            buf-spi_inv-line.wast-cli-qnty
            buf-spi_doc-line.fact-density
            v-recid
            no-error
          }
          if error-status :error
            then 
          do:
            message
              "Ошибка создания топливной строки накладной." skip( 0 )
              return-value skip( 0 )
              error-status :get-message( 1 )
              view-as alert-box error .
            undo block_cre-inv, retry block_cre-inv.
          end.
        end.

        run close-doc in this-procedure
          ( input v-spi-code
          , recid( buf-spi_trn-doc )
          ) no-error.
        if error-status :error then 
        do:
          undo block_cre-inv, retry block_cre-inv.
        end.
      end.
    end.
    /* Выводим в новый нередактируемый статус */
    assign
      buf_trn-doc.status_ = {&rvs-froze}
      buf_trn-doc.flag_   = yes
      p-docs-info         = substitute( "Документ инвентаризации &1", v-inv-code )
      .
    if available buf-spi_trn-doc then 
    do:
      assign
        buf-spi_trn-doc.status_ = {&rvs-froze}
        buf-spi_trn-doc.flag_   = yes
        p-docs-info             = p-docs-info + {&new-line} + substitute( "Документ списания &1", v-spi-code )
        .
    end.
  end. /* block_cre-inv transaction */
  
  
  /* Выводим окно с атрибутами по инвентаизации */
  run init-attr-general in this-procedure .
      find first buf_doc-line no-lock where buf_doc-line.doc-code = v-inv-code no-error .
    if available buf_doc-line
      then 
    do :
    run str/inv-attr.w (input ParParentproc, input "b-lkp,b-chg", input v-inv-code, input table tt-upd-attr) no-error.
    end .
  
  
  if v-infom-mess <> ""
    then 
  do:
    message "В результате произведенных замеров были выявлены следующие расхождения, превышающие погрешность измерения:" skip v-infom-mess view-as alert-box information title "Сообщение".
  end.

  for each tt-line-for-doc
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
    delete tt-line-for-doc .
  end.
end. /* создание документа инвентаризации */

procedure close-doc :
  define input  parameter p-doc-code  like ub.trn-doc.doc-code no-undo .
  define input  parameter p-doc-recid as   recid               no-undo .

  do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
    define variable varchg-inv as logical no-undo.

    run str/trn-stat.p
      ( input parparentproc
      ,input this-procedure
      ,input {&close-doc}
      ,input p-doc-code
      ,input ?
      ,input v-cntxt-db-num
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input yes
      ,output varchg-inv
      ,output table gds-list
      ) no-error.
    if error-status :error then 
    do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при переводе документа &1 из статуса накл- в накл+.", p-doc-code ) skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error return-value .
    end.
    /* инвентаризация накл+ - разр+ */
    run str/trn-stat.p
      ( input parparentproc
      ,input this-procedure
      ,input {&close-doc}
      ,input p-doc-code
      ,input ?
      ,input v-cntxt-db-num
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input yes
      ,output varchg-inv
      ,output table gds-list
      ) no-error.
    if error-status :error then 
    do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при переводе документа &1 из статуса накл+ в разр+.", p-doc-code ) skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error return-value .
    end.
    run gbl/calc-trn.p
      ( input parparentproc
      ,input p-doc-recid
      ) no-error.
  end.

end procedure. /* close-doc */

PROCEDURE cr-tt-upd :
do on error undo, return error return-value :
define variable v-other as character   no-undo.
for each tt-upd-attr: delete tt-upd-attr. end.

&scop create-record create tt-upd-attr. ~
 assign~
  tt-upd-attr.code =  ~{&~{&attr-code~}~}  . ~
                                        ~
~{ str/tdat-cod.i                   ~
     tt-upd-attr.code           ~
     tt-upd-attr.type-attr      ~
     tt-upd-attr.format-attr    ~
     tt-upd-attr.fillin_width   ~
     tt-upd-attr.fillin_height  ~
     tt-upd-attr.label-attr     ~
     tt-upd-attr.user-can-edit  ~
     tt-upd-attr.output-display ~
     v-other                    ~
     tt-upd-attr.proc-attr       ~
     tt-upd-attr.full-screen-val ~
     tt-upd-attr.sort_  ~
     no-error         ~
~}                    ~
 if error-status :error then do:    ~
   message "Ошибка при установке атрибутов инвентаризации." skip ~
           error-status :get-message(1) skip return-value ~
   view-as alert-box. ~
   return error. ~
 end.
 
 
&scop attr-val  ""
&scop attr-code trdcattr-prikaz-number
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-prikaz-date
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-inv-date
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-fio-agent
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-pos-agent
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-fio-player1
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-pos-player1
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-fio-player2
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-pos-player2
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-fio-player3
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-pos-player3
{&create-record}


end.
end procedure.

PROCEDURE init-attr-general :
/* Атрибуты расходного документа */
do on error undo, return error return-value :
run cr-tt-upd .
define variable varexist                  as logical   no-undo.
  &scop create-record run create-record in this-procedure (  input v-inv-code ~
                                                        ,  input ~{&~{&attr-code~}~} ~
                                                        ,  input  ~{&attr-val~} ~
                                                        , output varexist ) no-error.
&scop attr-val  ""
&scop attr-code trdcattr-prikaz-number
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-prikaz-date
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-inv-date
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-fio-agent
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-pos-agent
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-fio-player1
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-pos-player1
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-fio-player2
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-pos-player2
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-fio-player3
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-pos-player3
{&create-record}

end.

END PROCEDURE.

/* $Workfile: rvscrdcs.p $ e n d */