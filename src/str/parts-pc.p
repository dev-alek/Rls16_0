block-level on error undo, throw.
/*

$Revision: 220955104cd9, 2417, rls $
$Author: SSlivenko $
$Date: 2020/06/10 18:13:46 $
$Workfile: parts-pc.p $
$Archive: str/parts-pc.p $

Создание и заполнение документа смены типа партий

Автор: Чернова Светлана Александровна
Дата создания: 03/03/10
Author: Svetlana Chernova
Creation date: 03/03/10

Автор1: Бахтадзе Наталья Викторовна
Дата создания1: 03/24/06

*/
using ibs.th.str.alcohol.*.

define input parameter parparentproc    as widget-handle no-undo .
define input parameter par-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter par-source-purch-code like ub.parts.purch-code no-undo .
define input parameter par-dest-purch-code like ub.parts.purch-code no-undo .
define input parameter par-dest-status_ like ub.trn-doc.status_ no-undo .
define input parameter par-fact-date    like ub.trn-doc.fact-date no-undo .
define input parameter par-fact-time    like ub.trn-doc.fact-time no-undo .
define input parameter par-shift-date   like ub.trn-doc.shift-date no-undo .
define input parameter par-shift-num   like ub.trn-doc.shift-num no-undo .
define input parameter par-shift-name as character no-undo.

define variable chg-qnty      as   decimal no-undo .

define variable vss-revision    as character no-undo initial "$Revision: 220955104cd9, 2417, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2020/06/10 18:13:46 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: parts-pc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/parts-pc.p $":U .
define variable vss-description as character no-undo initial "Создание и заполнение документа смены типа партий":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/waitfram.i noprocess }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/libtfarh.i }
{ str/doc-code.i }
{ str/clcprtsl.i }
{ trg/partrqst.i }
{ str/trdcalib.i }
{ trg/holdprts.i }
{ gbl/key-rec.i  }
{ trg/partcopy.i }
{ str/get-pr.i def }
{ str/corparts.i }
{ str/out-vatp.i def }
{ str/in-vatp.i def supp_doc-line.  supp_trn-doc.  }
{ cmp/gds-list.i gds-list def }

function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).

/*    del-list = replace (del-list, "," + string (recid (parts)), "").*/
/*    del-list = replace (del-list, string (recid (parts)) + ",", "").*/
/*    del-list = replace (del-list, string (recid (parts)), "").*/

  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.

  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".

  def var v-num-parfirst-list as integer no-undo .

  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .

  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.

  return v-result-list .

end function.

define temp-table temp-parts no-undo
  like ub.parts
  field free-qnty as decimal
  field free-cli-qnty as decimal
.

define variable vardoc-code like ub.trn-doc.doc-code no-undo .
define variable var-term-node like ub.gds-prt.node-code no-undo .
define variable varchg-inv as logical   no-undo.
define variable v-doc-num    like ub.price-list.doc-num    no-undo .
define variable v-price-sale like ub.price-list.price-sale no-undo .
define variable v-road-tax   like ub.price-list.road-tax   no-undo .
define variable v-excise     like ub.price-list.excise     no-undo .
define variable v-prt-b-code like ub.bar-code.b-code       no-undo .
define variable v-inv-pay    like ub.shop.inv-pay          no-undo .

define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}

define buffer buf_sysconf   for ub.sysconf .
define buffer buf_parts     for ub.parts .
define buffer buf_trn-doc   for ub.trn-doc .
define buffer buf_doc-line  for ub.doc-line .
define buffer buf_clients   for ub.clients .
define buffer buf_shop      for ub.shop .
define buffer buf_store     for ub.store .
define buffer buf_gds-dtl   for ub.gds-dtl .
define buffer buf_goods     for ub.goods .
define buffer buf_gds-prt   for ub.gds-prt.
define buffer supp_doc-line for ub.doc-line .
define buffer supp_gds-dtl  for ub.gds-dtl .
define buffer supp_trn-doc  for ub.trn-doc .
define buffer supp1_parts   for ub.parts .
define buffer supp2_parts   for ub.parts .

define temp-table temp-supp no-undo
field doc-code like ub.trn-doc.doc-code
field cli-type like ub.trn-doc.cli-type
field cli-code like ub.trn-doc.cli-code
index pi is unique primary
doc-code
index clii is unique cli-type cli-code
.

_main:
do
on error undo, return error return-value
:

  find first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = par-doc-code .
  find first  buf_sysconf no-lock where
              buf_sysconf.host-code = buf_trn-doc.host-code.
  for each buf_doc-line no-lock where
          buf_doc-line.doc-code = buf_trn-doc.doc-code
  break
  by buf_doc-line.doc-code
  by buf_doc-line.artic
  by buf_doc-line.prod-type
  by buf_doc-line.prod-code
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    if first-of(buf_doc-line.prod-code) then do:
      { str/out-vatp.i doc-line buf_doc-line. buf_trn-doc. }
    end.
    _doc-line:
    for each buf_parts where
            buf_parts.out-code = buf_doc-line.doc-code
        and buf_parts.obj-type = buf_doc-line.obj-type
        and buf_parts.obj-code = buf_doc-line.obj-code
        and buf_parts.artic = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
        and buf_parts.status_ = no
    on error undo _main,  return error :
      if buf_parts.purch-code <> par-source-purch-code then do:
        NEXT _doc-line.
      end.
      find first temp-supp no-lock where
                 temp-supp.cli-type      = buf_trn-doc.obj-type
             and temp-supp.cli-code      = buf_trn-doc.obj-code no-error .
      if available temp-supp then do:
        find first supp_trn-doc where supp_trn-doc.doc-code = temp-supp.doc-code no-error .
        if not available supp_trn-doc
        OR not (supp_trn-doc.doc-type = {&inventory}
          AND internal = no
          AND supp_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}
          AND supp_trn-doc.status_ = {&wayb}
              ) then do:

          undo _main, return error substitute("Не найден документ &1 смены типа приобретения для &2"
                                              , temp-supp.doc-code
                                              , par-doc-code).
        end.
      end. /* if avail supp_trn-doc уже есть документ коррекции*/
      else do:
        run doc-code in this-procedure
        (input "main",
          input buf_trn-doc.obj-type,
          input buf_trn-doc.obj-code,
          input ?,
          output vardoc-code ) no-error.
        if error-status:error then do:
          undo, return error substitute("Ошибка при генерации номера документа смены типа приобретения для &1:&2&3 &4"
                                        , par-doc-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value ).

        end.
        find first buf_clients no-lock where
                   buf_clients.obj-type = buf_trn-doc.obj-type
               AND buf_clients.obj-code = buf_trn-doc.obj-code .

        if buf_trn-doc.obj-type = {&shop} then do:
          find first buf_shop no-lock where
                    buf_shop.obj-code = buf_trn-doc.obj-code .
          assign
          v-inv-pay = buf_shop.inv-pay.

        end.
        else do:
          find first buf_store no-lock where
                    buf_store.obj-code = buf_trn-doc.obj-code .
          assign
          v-inv-pay = buf_store.inv-pay.
        end.
        { str/crtrndoc.i
        buf_trn-doc.acc-date
        buf_trn-doc.bge-date
        buf_trn-doc.base-rate
        buf_trn-doc.base-scale
        buf_trn-doc.obj-code
        buf_trn-doc.obj-type
        buf_clients.obj-name
        g#db-num
        g#userid
        "''"
        vardoc-code
        buf_trn-doc.doc-date
        {&inventory}
        buf_trn-doc.flag_
        buf_trn-doc.host-code
        no
        buf_trn-doc.obj-code
        buf_trn-doc.obj-type
        no
        v-inv-pay
        "('@документ коррекции типа приобретения для накладной' + {&space-char} + buf_trn-doc.doc-code)"
        no
        ?
        {&wayb}
        ?
        {&TDEDT_Chg_Purch_Code}
        ?
        no-error
        }
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при создании документа смены типа приобретения для &1:&2&3 &4"
                                        , par-doc-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value ).
        end.

        find supp_trn-doc where
            supp_trn-doc.doc-code = vardoc-code.
        create temp-supp.
        assign
        temp-supp.doc-code      = supp_trn-doc.doc-code
        temp-supp.cli-type      = supp_trn-doc.cli-type
        temp-supp.cli-code      = supp_trn-doc.cli-code
        supp_trn-doc.fact-date  = par-fact-date
        supp_trn-doc.fact-time  = par-fact-time
        supp_trn-doc.shift-date = par-shift-date
        supp_trn-doc.shift-num  = par-shift-num
        supp_trn-doc.shift-name = par-shift-name
        supp_trn-doc.out-code   = buf_trn-doc.doc-code
        supp_trn-doc.closed     = yes
        supp_trn-doc.agnt       = buf_trn-doc.agnt
        supp_trn-doc.boss       = buf_trn-doc.boss
        supp_trn-doc.wrkr       = buf_trn-doc.wrkr
        .
      end. /*not avail supp_trn-doc*/
      FIND FIRST supp_doc-line WHERE
                 supp_doc-line.doc-code  = supp_trn-doc.doc-code
            AND  supp_doc-line.artic     = buf_parts.artic
            and  supp_doc-line.prod-type = buf_parts.prod-type
            and  supp_doc-line.prod-code = buf_parts.prod-code NO-ERROR .
      if NOT available supp_doc-line then do:
        find first buf_goods No-LOCK WHERE
                   buf_goods.artic = buf_parts.artic
               AND buf_goods.prod-type = buf_parts.prod-type
               AND buf_goods.prod-code = buf_parts.prod-code.
        find first buf_gds-prt no-lock where
                    buf_gds-prt.upper-code = buf_goods.prt-root .
        { gbl/termnode.i
          buf_gds-prt.node-code
          var-term-node
        }
        CREATE supp_doc-line.
        assign
        supp_doc-line.doc-code    = supp_trn-doc.doc-code
        supp_doc-line.artic       = buf_parts.artic
        supp_doc-line.prod-type   = buf_parts.prod-type
        supp_doc-line.prod-code   = buf_parts.prod-code
        supp_doc-line.obj-type    = buf_parts.obj-type
        supp_doc-line.obj-code    = buf_parts.obj-code
        supp_doc-line.doc-qnty    = 0
        supp_doc-line.fact-qnty   = 0
        supp_doc-line.price-base  = 0
        supp_doc-line.price-rubl  = 0
        supp_doc-line.prt-OK      = yes
        supp_doc-line.prt-root    = buf_doc-line.prt-root
        supp_doc-line.VAT-pc      = buf_parts.vat-pc
        supp_doc-line.cons-vat-pc = buf_sysconf.cons-VAT-pc
        supp_doc-line.SLT-pc      = 0
        supp_doc-line.road-tax    = 0
        supp_doc-line.excise      = 0
        supp_doc-line.other-rubl  = 0
        supp_doc-line.other-base  = 0
        .
      end.  /*not avail doc-line*/
      find first supp_gds-dtl where
                supp_gds-dtl.doc-code  = supp_doc-line.doc-code
            and supp_gds-dtl.artic     = supp_doc-line.artic
            and supp_gds-dtl.prod-code = supp_doc-line.prod-code
            and supp_gds-dtl.prod-type = supp_doc-line.prod-type
            and supp_gds-dtl.prt-code  = var-term-node no-error .
      if not available supp_gds-dtl then do:
        { str/crgdsdtl.i
          supp_doc-line.obj-code
          supp_doc-line.obj-type
          supp_doc-line.doc-code
          supp_doc-line.artic
          supp_doc-line.prod-code
          supp_doc-line.prod-type
          var-term-node
          no
          no-error }
          if error-status:error then do:
            undo _main, return error substitute("Ошибка при создании строки документа &1 смены типа приобретения для &2:&3" +
                                              "товар  &4&2&5 &6"
                                                ,supp_doc-line.doc-code
                                                ,par-doc-code
                                                ,{&new-line}
                                                ,(supp_doc-line.artic + {&space-char} + supp_doc-line.prod-type + string(supp_doc-line.prod-code))
                                                ,error-status:get-message(1)
                                                ,return-value ).
          end.
        /*
        Сусловым приказано напустить outvat а не брать из прайса
        /*найдем текущую продажную цену  для gds-dtl*/
        { str/get-pr.i
          calc
          supp_trn-doc.obj-type
          supp_trn-doc.obj-code
          buf_goods.gds-code
          var-term-node
          " undo _main, return error. "
          }
        */
        FIND FIRST supp_gds-dtl WHERE
                  supp_gds-dtl.doc-code  = supp_doc-line.doc-code
              and supp_gds-dtl.artic     = supp_doc-line.artic
              and supp_gds-dtl.prod-code = supp_doc-line.prod-code
              and supp_gds-dtl.prod-type = supp_doc-line.prod-type
              and supp_gds-dtl.prt-code  = var-term-node.
        assign
        supp_gds-dtl.discnt-type = no /* сумма */
        supp_gds-dtl.fact-qnty = 0
        supp_gds-dtl.doc-qnty = 0
        supp_gds-dtl.ov = no
        supp_gds-dtl.discnt-rubl = 0
        supp_gds-dtl.discnt-base = 0
        /*текущая продажная*/
        supp_gds-dtl.price-rubl =  price-rubl-with-tax-sale
        supp_gds-dtl.price-base =  price-base-with-tax-sale
        supp_doc-line.road-tax   =  (if v-curr-r-b = {&r-b-base}
                                    then road-tax-base-sale
                                    else road-tax-rubl-sale
                                  )
        supp_doc-line.excise   =  (if v-curr-r-b = {&r-b-base}
                                    then excise-base-sale
                                    else excise-rubl-sale
                                  )

        .
        { gbl/gdsbcode.i
          buf_goods.gds-code
          supp_gds-dtl.prt-code
          v-prt-b-code
          no-error
        }
        if error-status :error then do:
          undo _main, return error substitute("Ошибка при определении бар-кода признака&1" +
                                             "документ  &2 код товара &3 код признака &4:&1&5 &6"
                                              ,{&new-line}
                                              ,supp_trn-doc.doc-code
                                              ,buf_goods.gds-code
                                              ,supp_gds-dtl.prt-code
                                              ,error-status:get-message(1)
                                              ,return-value ).
        end.
        { gbl/bcodeprc.i
          supp_gds-dtl.obj-type
          supp_gds-dtl.obj-code
          v-prt-b-code
          0
          0
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
          no-error
        }
        if error-status :error then do:
          undo _main, return error substitute("Ошибка при определении цены бар-кода&1" +
                                             "документ  &2 объект &3 код товара &4 бар-код &5:&1&6 &7"
                                              ,{&new-line}
                                              ,supp_trn-doc.doc-code
                                              ,(supp_trn-doc.obj-type + string(supp_trn-doc.obj-code) )
                                              ,buf_goods.gds-code
                                              ,v-prt-b-code
                                              ,error-status:get-message(1)
                                              ,return-value ).
        end.
        if v-price-sale = ? then do:
          undo _main, return error substitute("Отсутствует продажная цена признака&1" +
                                             "документ  &2 объект &3 код товара &4 бар-код &5:&1&6 &7"
                                              ,{&new-line}
                                              ,supp_trn-doc.doc-code
                                              ,(supp_trn-doc.obj-type + string(supp_trn-doc.obj-code) )
                                              ,buf_goods.gds-code
                                              ,v-prt-b-code
                                              ,error-status:get-message(1)
                                              ,return-value ).

        end.
        assign
        supp_gds-dtl.cur-base = v-price-sale
        .
      end. /*if not avail supp_gds-dtl*/
      run partcopy-change-purch-code in this-procedure (
                                                          input supp_trn-doc.doc-code
                                                          ,input par-dest-purch-code
                                                          ,buffer buf_parts
                                                          ,buffer supp1_parts
                                                          ,buffer supp2_parts
                                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
      if last-of(buf_doc-line.prod-code) then do:
        { str/in-vatp.i calc supp_doc-line. supp_trn-doc.  }
        assign
        supp_doc-line.price-base = price-base-with-tax-loc
        supp_doc-line.price-rubl = price-rubl-with-tax-loc
        .
      end.
    end. /*for eac buf_parts*/
  end. /*for each buf_doc-line*/
  for each temp-supp no-lock
  on error undo _main, return error
  :
    /*проставим количества в строки инвентаризации*/
    { str/filinvon.i
      temp-supp.doc-code
      {&fact}
      buf_trn-doc.flag_
      no
      this-procedure
      varchg-inv
      gds-list
      no-error
    }
    if error-status:error then do:
      undo _main, return error substitute("&1 &2 &3 Ошибка при заполнении кол-в по документу &4&5&6 &7"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,supp_trn-doc.doc-code
                                          ,{&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value ).
    end.
    find first supp_trn-doc where
               supp_trn-doc.doc-code = temp-supp.doc-code.
    /*здесь же надо заполнить шапку документа*/
     run corparts_clc-doc in this-procedure (
                                              input recid(supp_trn-doc)
                                            ) no-error .
    if error-status:error then do:
      undo _main, return error substitute("&1 &2 &3 Ошибка при обсчете шапки документа &4&5&6 &7"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,supp_trn-doc.doc-code
                                          ,{&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value ).
    end.
    assign
    supp_trn-doc.fact-time = time
    supp_trn-doc.status_ = {&fact}
    supp_trn-doc.flag_ = yes
    .
    run gbl/calc-trn.p (input parparentproc, input recid(supp_trn-doc)) no-error.
    if error-status:error then do:
          undo _main, return error substitute("&1 &2 &3 Ошибка при пересчете документа &4&5&6 &7"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,temp-supp.doc-code
                                              ,{&new-line}
                                              ,error-status:get-message(1)
                                              ,return-value ).
    end.
    { str/st-fo.i supp_trn-doc.doc-code }
    release supp_trn-doc no-error .
    if error-status:error then do:
          undo _main, return error substitute("&1 &2 &3 Ошибка при закрытии документа &4&5&6 &7"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,temp-supp.doc-code
                                              ,{&new-line}
                                              ,error-status:get-message(1)
                                              ,return-value ).
    end.

  end. /*for each temp-supp*/
end. /*doe*/