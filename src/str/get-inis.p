block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-inis.p $
$Archive: str/get-inis.p $

Получение настроек для почты на/с кассы из ini-файла

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/22/04
Author: Bakhtadze Natalya
Creation date: 06/22/04

*/

define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.cash-desk.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-remote   like ub.cash-desk.remote  no-undo .
/*нкий параметр который говорит для чего нам настройки*/
/*может быть send или get*/
define input parameter p-mode     as character no-undo .
define output parameter out     as character no-undo .
define output parameter out2    as character no-undo .
define output parameter in_     as character no-undo .
define output parameter spl     as character no-undo .
define output parameter sav     as character no-undo .
define output parameter v-remote as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-inis.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-inis.p $":U .
define variable vss-description as character no-undo init "Получение настроек для почты на/с кассы из ini-файла".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/ini-lib.i }
{ gbl/alienini.i }

define variable v-cd-prfx as character no-undo .
define variable glog as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable yestr as character no-undo .
define variable out3 as character no-undo .
define variable out4 as character no-undo .
define variable temp-out as character no-undo .
define variable v-value as character no-undo .

CASE p-pos-type:
  when {&cd-type-MAGIA-XML} then do:
    assign
    v-cd-prfx = 'magia':U
    .
  end.
  when {&cd-type-IBM-XML} then do:
    assign
    v-cd-prfx = 'IBM-XML':U
    .
  end.
  when {&cd-type-NKT-IBM} then do:
    assign
    v-cd-prfx = 'NKT-IBM':U
    .
  end.
  when {&cd-type-IBM} then do:
    assign
    v-cd-prfx = 'IBM':U
    .
  end.
  when {&cd-type-ncr-gm} then do:
    assign
    v-cd-prfx = 'ncr-gm':U
    .
  end.
  when {&cd-type-ncr-as-r} then do:
    assign
    v-cd-prfx = 'ncr-as-r':U
    .
  end.
  when {&cd-type-r-keeper} then do:
    assign
    v-cd-prfx = 'r-keeper':U
    .
  end.
  when {&cd-type-infokiosk} then do:
    assign
    v-cd-prfx = 'infokiosk':U
    .
  end.
  when {&cd-type-pricecheck-Servispl} then do:
    assign
    v-cd-prfx = 'pricecheck-Servis+':U
    .
  end.

  when {&cd-type-maria} then do:
    assign
    v-cd-prfx = 'maria':U
    .
  end.

  when {&cd-type-autotank} then do:
    assign
    v-cd-prfx = 'autotank':U
    .
  end.


END CASE.

CASE p-pos-type:
  when {&cd-type-magia-xml}
  or
  when {&cd-type-ibm-xml}
  or
  when  {&cd-type-ibm}
  or
  when  {&cd-type-nkt-ibm}
  or
  when  {&cd-type-infokiosk}
  or
  when  {&cd-type-pricecheck-Servispl}
  or
  when {&cd-type-autotank}
  then do:
    run verify-ini-entry in this-procedure (
                                            INPUT  'out'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогу out для отсылки информации на POS &1", p-pos-type)
                                            ,INPUT yes
                                            ,output out) no-error .
    if error-status:error or out = ? then return error return-value .
    RUN verify-file in this-procedure
                                      ( out
                                      , substitute("Не найден каталог &1 параметр out, секция [kassa-&2] ini-файла", out, v-cd-prfx)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .

      if not
      (p-pos-type = {&cd-type-infokiosk}
           or
      p-pos-type = {&cd-type-pricecheck-Servispl}

      )
      then do:
        run verify-ini-entry in this-procedure (
                                                INPUT  'in'
                                                ,INPUT  'kassa-' + v-cd-prfx
                                                ,INPUT substitute("отсутствует путь к подкаталогу in для приема данных с POS &1", p-pos-type)
                                                ,INPUT yes
                                                ,output in_) no-error .
        if error-status:error or in_ = ? then return error return-value .
        RUN verify-file in this-procedure
                                          ( in_
                                          , substitute("Не найден каталог &1 параметр in, секция [kassa-&2] ini-файла", in_, v-cd-prfx)
                                          ,yes
                                          ,output glog) no-error.
        if error-status:error or not glog then return error return-value .
      end.
      if p-pos-type <> {&cd-type-InfoKiosk} and
          p-pos-type <> {&cd-type-pricecheck-Servispl}
          then do:
        RUN verify-ini-entry(  input ("spl":U + string( p-obj-code ))
                              ,input substitute("kassa-&1":U, v-cd-prfx)
                              ,input substitute("отсутствует путь к подкаталогу &1 &2 в каталоге &3 &4 для приема данных с POS &6 для магазина с кодом &5"
                                              , "in"
                                              , {&new-line}
                                              , in_
                                              , {&new-line}
                                              , p-obj-code
                                              , v-cd-prfx)
                              ,input yes
                              ,output spl) no-error.
      end.
      if p-pos-type <> {&cd-type-infokiosk} and
         p-pos-type <> {&cd-type-pricecheck-Servispl}
         then do:
        if spl = ? or error-status:error then return error return-value .
        RUN verify-file(input in_ + spl
                        ,input substitute("Не найден подкаталог &1 в директории &2 &3 параметр spl&4, секция [kassa-&5] ini-файла"
                                          , spl
                                          , in_
                                          , {&new-line}
                                          , p-obj-code
                                          , v-cd-prfx)
                        ,input yes
                        ,output glog) no-error.
        if error-status:error or not glog then return error return-value .
        RUN verify-ini-entry(  input ("sav":U + string( p-obj-code ))
                              ,input substitute("kassa-&1":U, v-cd-prfx)
                              ,input substitute("отсутствует путь к подкаталогу sav &1 в каталоге &2 &3 для архива принятых данных для магазина с кодом &4 с POS &5", {&new-line}, in_, {&new-line}, p-obj-code, v-cd-prfx)
                              ,input yes
                              ,output sav) no-error.
        if error-status:error or sav = ? then do:
          if p-pos-type = {&cd-type-magia-xml} then do:
            return error return-value .
          end.
          else do:
            sav = spl.
          end.
        end.
      end.
      if p-pos-type = {&cd-type-magia-xml} then do:
        RUN verify-file(input (in_ + sav)
                        ,input substitute("Не найден подкаталог &1 в директории &2 &3 параметр sav&4, секция [kassa-&5] ini-файла",
                                  sav, in_, {&new-line}, p-obj-code, v-cd-prfx)
                        ,input yes
                        ,output glog) no-error.
        if error-status:error or not glog then return error return-value .
      end.
      if p-mode = "send":U then do:
        run str/fileqnty.p ( out, output BadFlag ) .
        if not g#news and not g#auto and BadFlag then do:
          return error substitute("!!!Количество неотправленных на кассы файлов в каталоге &1 превышает 500 ! "
                                  ,out).
        end.
      end.
      if p-pos-type <> {&cd-type-MAGIA-XML}
      and p-pos-type <> {&cd-type-infokiosk}
      and p-pos-type <> {&cd-type-pricecheck-Servispl}
      then do:
        run verify-ini-entry in this-procedure (
                                                INPUT  'remote'
                                                ,INPUT  'kassa-' + v-cd-prfx
                                                ,INPUT substitute("отсутствует путь к подкаталогу remote для отсылки информации на POS &1", p-pos-type)
                                                ,INPUT yes
                                                ,output v-remote) no-error .
        if error-status:error or v-remote = ? then v-remote = out.
        else do:
          RUN verify-file in this-procedure
                                            ( v-remote
                                            , substitute("Не найден каталог &1 параметр remote, секция [kassa-&2] ini-файла", v-remote , v-cd-prfx)
                                            ,yes
                                            ,output glog) no-error.
          if error-status:error or not glog then return error return-value .
          if p-mode = "send":u then do:
            run str/fileqntd.p ( v-remote, "out,tmp":U, output fq, output BadFlag ) .
            if not g#news and not g#auto and BadFlag then do:
              return error substitute("!!!Количество неотправленных на кассы файлов в каталоге &1 превышает 500 ! "
                                      ,v-remote).
            end.
          end.
        end.
      end.
  end.
  when {&cd-type-omron} then do:
    RUN verify-ini-entry("in":U,
                          "kassa-omron":U,
                          "отсутствует путь к подкаталогу in" + {&new-line} + "для приема чеков с POS OMRON",
                          yes,
                          output in_) no-error.
    if error-status:error or in_ = ? then return error return-value .
    RUN verify-file(in_,
                    "Не найден каталог " + in_ + {&new-line} +
                    "параметр in, секция [kassa-omron] ini-файла",
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry("spl":U,
                          "kassa-omron":U,
                          "отсутствует путь к подкаталогу spl" + {&new-line} + "для приема чеков с POS OMRON",
                          yes,
                          output spl) no-error.
    if error-status:error or spl = ? then return error return-value .
    RUN verify-file(in_ + spl,
                    "Не найден подкаталог t-i" + spl + " в директории " + in_ + {&new-line} +
                    "параметр spl, секция [kassa-omron] ini-файла",
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .

    RUN verify-ini-entry("out":U,
                          "kassa-omron":U,
                          "отсутствует путь к подкаталогу out" + {&new-line} + "для передачи информации на POS OMRON",
                          yes,
                          output out) no-error.
    if error-status:error or out = ? then return error return-value .
    RUN verify-file(out,
                    "Не найден каталог " + out + {&new-line} +
                    "параметр out, секция [kassa-omron] ini-файла",
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
  end.
  when {&cd-type-ncr-gm}
  or when {&cd-type-ncr-As-r}
  then  do:
    assign
    out2 = '':U
    out3 = '':U
    out4 = '':U
    .
    RUN verify-ini-entry("out":U,
                          substitute("kassa-&1":U,  v-cd-prfx),
                          "отсутствует путь к подкаталогу out" + {&new-line} + "для отсылки информации на POS NCR",
                          yes,
                          output out) no-error.
    if error-status:error or out = ? then return error return-value .
    RUN verify-file(out,
                    substitute("Не найден каталог &1&2 параметр out, секция [kassa-&3] ini-файла"
                               , out
                               ,{&new-line}
                               , v-cd-prfx),
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
    if p-pos-type = {&cd-type-ncr-as-r} then do:
      RUN verify-ini-entry("out2":U,
                            substitute("kassa-&1":U,  v-cd-prfx),
                            "отсутствует путь к подкаталогу out2" + {&new-line} + "для отсылки информации на POS NCR",
                            yes,
                            output out2) no-error.
      if error-status:error or out2 = ? then return error return-value .
      RUN verify-file(out2,
                      substitute("Не найден каталог &1&2 параметр out2, секция [kassa-&3] ini-файла"
                                , out2
                                ,{&new-line}
                                , v-cd-prfx),
                      yes,
                      output glog) no-error.
      if error-status:error or not glog then return error return-value .
      RUN verify-ini-entry("out3":U,
                            substitute("kassa-&1":U,  v-cd-prfx),
                            "отсутствует путь к подкаталогу out3" + {&new-line} + "для отсылки информации на POS NCR",
                            yes,
                            output out3) no-error.
      if error-status:error or out3 = ? then return error return-value .
      RUN verify-file(out3,
                      substitute("Не найден каталог &1&2 параметр out3, секция [kassa-&3] ini-файла"
                                , out3
                                ,{&new-line}
                                , v-cd-prfx),
                      yes,
                      output glog) no-error.
      if error-status:error or not glog then return error return-value .
      assign
      out2 = out2 + {&delim-par} + out3
      .
    end.
    RUN verify-ini-entry("out4":U,
                          substitute("kassa-&1":U,  v-cd-prfx),
                          "отсутствует путь к подкаталогу out4 (директория p_regpar.dat)" + {&new-line} + "для отсылки информации на POS NCR",
                          yes,
                          output out4) no-error.
    if error-status:error or out4 = ? then return error return-value .
    RUN verify-file(out4,
                    substitute("Не найден каталог &1&2 параметр out4, секция [kassa-&3] ini-файла"
                              , out4
                              ,{&new-line}
                              , v-cd-prfx),
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
    assign
    out2 = out2 + {&delim-par} + out3 + {&delim-par} + out4
    .
    RUN verify-ini-entry("in":U,
                          substitute("kassa-&1", v-cd-prfx),
                          "отсутствует путь к подкаталогу in" + {&new-line} + "для приема чеков с сервера NCR",
                          yes,
                          output in_) no-error.
    if error-status:error or in_ = ? then return error return-value .
    RUN verify-file(in_,
                    substitute("Не найден каталог &1&2параметр in, секция [kassa-&3] ini-файла"
                              , in_
                              , {&new-line}
                              , v-cd-prfx),
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry("spl":U + string( p-obj-code ),
                          substitute("kassa-&1":U,  v-cd-prfx),
                          substitute("отсутствует путь к подкаталогу spl&1в каталоге &2&3для приема чеков магазина с кодом &4 с сервера NCR"
                                     , {&new-line}
                                     , in_
                                     , {&new-line}
                                     , p-obj-code
                                     ) ,
                          yes,
                          output spl) no-error.
    if spl = ? then spl = "":U. /*ничего страшного значит только один магазин!!!*/
    else do:
      RUN verify-file(in_ + spl,
                      substitute(
                      "Не найден подкаталог &1 в директории &2&3параметр spl&4 секция [kassa-&5] ini-файла"
                                 , spl
                                 , in_
                                 ,  {&new-line}
                                 , p-obj-code
                                 , v-cd-prfx
                                 ),
                      yes,
                      output glog) no-error.
      if error-status:error or not glog then return error return-value .
    end.
    RUN verify-ini-entry("sav":U + string( p-obj-code ),
                          substitute("kassa-&1":U, v-cd-prfx),
                          "",
                          yes,
                          output sav) no-error.
    if error-status:error or sav = ? then sav = spl.
    /*если только один магазин то хранить будем в поддиректории SAV от IN*/
    if sav = ? or sav = "":U then sav = "sav".
    /*проверим наличие директории для архива вчерашнего дня*/
    yestr = right-trim((in_ + spl), {&back-slash-char}) + "\yestr\":U.
    RUN verify-file(yestr,
                    "Не найден каталог " + yestr + {&new-line} +
                    "используемый для получения архива чеков предыдущего дня",
                    yes,
                    output glog) no-error.
    if error-status:error then yestr = ?.
    assign v-remote = yestr.
  end.
  when {&cd-type-r-keeper} then do:
    run verify-ini-entry in this-procedure (
                                            INPUT  'out'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогу out для отсылки информации на POS &1", p-pos-type)
                                            ,INPUT yes
                                            ,output out) no-error .
    if error-status:error or out = ? then return error return-value .
    RUN verify-file in this-procedure
                                      ( out
                                      , substitute("Не найден каталог &1 параметр out, секция [kassa-&2] ini-файла", out, v-cd-prfx)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
    run verify-ini-entry in this-procedure (
                                            INPUT  'in'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогу in для приема данных с POS &1", p-pos-type)
                                            ,INPUT yes
                                            ,output in_) no-error .
    if error-status:error or in_ = ? then return error return-value .
    RUN verify-file in this-procedure
                                      ( in_
                                      , substitute("Не найден каталог &1 параметр in, секция [kassa-&2] ini-файла", in_, v-cd-prfx)
                                      ,yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .

    RUN verify-ini-entry(  input ("spl":U + string( p-obj-code ))
                          ,input substitute("kassa-&1":U, v-cd-prfx)
                          ,input substitute("отсутствует путь к подкаталогу &1 &2 в каталоге &3 &4 для приема данных с POS &6 для магазина с кодом &5"
                                          , "spl"
                                          , {&new-line}
                                          , in_
                                          , {&new-line}
                                          , p-obj-code
                                          , v-cd-prfx)
                          ,input yes
                          ,output spl) no-error.
    if error-status:error or spl = ? then return error return-value .
    RUN verify-file(input (in_ + spl)
                    ,input substitute("Не найден подкаталог &1 в директории &2 &3 параметр spl&4, секция [kassa-&5] ini-файла"
                                        , spl
                                        , in_
                                        , {&new-line}
                                        , p-obj-code
                                        , v-cd-prfx)
                    ,input yes
                    ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry(  input ("sav":U + string( p-obj-code ))
                          ,input substitute("kassa-&1":U, v-cd-prfx)
                          ,input substitute("отсутствует путь к подкаталогу sav &1 в каталоге &2 &3 для архива принятых данных для магазина с кодом &4 с POS &5", {&new-line}, in_, {&new-line}, p-obj-code, v-cd-prfx)
                          ,input yes
                          ,output sav) no-error.
    if error-status:error or sav = ? then do:
      return error return-value .
    end.
    if spl = sav then do:
      return error substitute("параметр sav&1, секция [kassa-&2] ini-файла - место ХРАНЕНИЯ ОБРАБОТАННЫХ файлов, принятых с касс типа &3 маг&1)&4" +
                              "параметр spl&1, секция [kassa-&2] ini-файла - место ПРИЕМА файлов с касс типа &3 маг&1)&4" +
                              "указывают на одну и ту же директорию &5 - что недопустимо"
                              , p-obj-code
                              , v-cd-prfx
                              , p-pos-type
                              , {&new-line}
                              , (in_ + sav)).
    end.
    if p-mode = "send":U then do:
      run str/fileqnty.p ( out, output BadFlag ) .
      if not g#news and not g#auto and BadFlag then do:
        return error substitute("!!!Количество неотправленных на кассы файлов в каталоге &1 превышает 500 ! "
                                ,out).
      end.
    end.
  end. /*when r-keeper*/
  when {&cd-type-maria} then do:
    run verify-ini-entry in this-procedure (
                                            INPUT  'out'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогам для отсылки информации на POS &1&2" +
                                                              "(параметр out cекция [kassa-&3] ini файла)"
                                                             , p-pos-type
                                                             , {&new-line}
                                                             , v-cd-prfx
                                                             )
                                            ,INPUT yes
                                            ,output out) no-error .
    if error-status:error or out = ? then return error return-value .
    RUN verify-file in this-procedure
                                      ( out
                                      , substitute("Не найден каталог &1 для выгрузки информации на POS типа &1"
                                                   ,out
                                                   ,p-pos-type)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .

    run verify-ini-entry in this-procedure (
                                            INPUT  'in'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогам для приема информации с POS &1&2" +
                                                              "(параметр in cекция [kassa-&3] ini файла)"
                                                             , p-pos-type
                                                             , {&new-line}
                                                             , v-cd-prfx
                                                             )
                                            ,INPUT yes
                                            ,output in_) no-error .
    if error-status:error or in_ = ? then return error return-value .

    RUN verify-file in this-procedure
                                      ( in_
                                      , substitute("Не найден каталог &1 для загрузки информации с POS типа &1"
                                                   ,in_
                                                   ,p-pos-type)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .

    RUN verify-ini-entry(  input ("spl":U + string( p-obj-code ))
                          ,input substitute("kassa-&1":U, v-cd-prfx)
                          ,input substitute("отсутствует параметр spl&1&2 секция [kassa-&5] - подкаталог в каталоге &3&2 для приема данных с POS &4 для магазина с кодом &1"
                                          , p-obj-code
                                          , {&new-line}
                                          , in_
                                          , p-pos-type
                                          , v-cd-prfx)
                          ,input yes
                          ,output spl) no-error.
    if spl = ? or error-status:error then return error return-value .
    RUN verify-file(input in_ + spl
                    ,input substitute("Не найден подкаталог &1 в директории &2&3(параметр spl&4, секция [kassa-&5] ini-файла)"
                                      , spl
                                      , in_
                                      , {&new-line}
                                      , p-obj-code
                                      , v-cd-prfx)
                    ,input yes
                    ,output glog) no-error.
    if error-status:error or not glog then return error return-value .

    run verify-ini-entry in this-procedure (
                                            INPUT  'addin-dir'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к каталогу OLE-сервера Addin.exe для обмена информацией с POS &1&2" +
                                                              "(параметр addin-dir cекция [kassa-&3] ini файла)"
                                                             , p-pos-type
                                                             , {&new-line}
                                                             , v-cd-prfx
                                                             )
                                            ,INPUT yes
                                            ,output v-remote) no-error .
    if v-remote = ? or error-status:error then return error return-value .
    RUN verify-file in this-procedure
                                      ( out
                                      , substitute("Не найден каталог &1 OLE-сервера AddIn.exe для обмена с POS типа &1"
                                                   ,v-remote
                                                   ,p-pos-type)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .

    RUN verify-ini-entry(  input ("sav":U + string( p-obj-code ))
                          ,input substitute("kassa-&1":U, v-cd-prfx)
                          ,input substitute("отсутствует путь к подкаталогу sav &1 в каталоге &2 &3 для архива принятых данных для магазина с кодом &4 с POS &5"
                                          , {&new-line}
                                          , in_
                                          , {&new-line}
                                          , p-obj-code
                                          , v-cd-prfx)
                          ,input yes
                          ,output sav) no-error.
    if error-status:error or sav = ? then return error return-value .
  end.
END CASE.