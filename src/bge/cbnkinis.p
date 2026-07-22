block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cbnkinis.p $
$Archive: bge/cbnkinis.p $

Получение настроек для экспорта/импорта в систему КЛИЕНТ-БАНК из ini-файла

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/22/04
Author: Bakhtadze Natalya
Creation date: 06/22/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-format    as character no-undo .
define input parameter p-bik       like ub.fin-bank.bik no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .


/*нкий параметр который говорит для чего нам настройки*/
/*может быть send или get*/
define input parameter p-mode     as character no-undo .
define output parameter out     as character no-undo .
define output parameter in_     as character no-undo .
define output parameter spl     as character no-undo .
define output parameter sav     as character no-undo .
define output parameter adresat as character no-undo .


def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: cbnkinis.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/cbnkinis.p $":U .
def var vss-description as character no-undo init "Получение настроек для экспорта/импорта в систему КЛИЕНТ-БАНК из ini-файла".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/ini-lib.i }


define variable v-format-prfx as character no-undo .
define variable glog as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable yestr as character no-undo .

CASE p-format:
  when {&cl-bank-1s} then do:
    assign
    v-format-prfx = '1s':U
    .
  end.
END CASE.

CASE p-format:
  when {&cl-bank-1s}
  then do:
      run verify-ini-entry in this-procedure (
                                                INPUT  p-bik + '_out'
                                              ,INPUT  'client-bank-' + v-format-prfx
                                              ,INPUT substitute("отсутствует путь к подкаталогу out для экспорта в систему КЛИЕНТ-БАНК по формату &1 для БИК &2", p-format, p-bik)
                                              ,INPUT yes
                                              ,output out) no-error .
      if error-status:error or out = ? then return error return-value .
      RUN verify-file in this-procedure
                                        ( out
                                        , substitute("Не найден каталог &1 параметр &2_out, секция [client-bank-&3] ini-файла"
                                                    , out
                                                    , p-bik
                                                    , v-format-prfx)
                                        , yes
                                        ,output glog) no-error.
      if error-status:error or not glog then return error return-value .

      run verify-ini-entry in this-procedure (
                                               INPUT  (p-bik + '_in')
                                              ,INPUT  ('client-bank-' + v-format-prfx)
                                              ,INPUT substitute("отсутствует путь к подкаталогу in для импорта данных из системы КЛИЕНТ-БАНК по формату &1 для БИК &2"
                                                              , p-format
                                                              , p-bik)
                                              ,INPUT yes
                                              ,output in_) no-error .
      if error-status:error or in_ = ? then return error return-value .
      RUN verify-file in this-procedure
                                        ( in_
                                        , substitute("Не найден каталог &1 параметр &2_in, секция [client-bank-&3] ini-файла"
                                                     , in_
                                                     , p-bik
                                                     , v-format-prfx)
                                        ,yes
                                        ,output glog) no-error.
      if error-status:error or not glog then return error return-value .

      RUN verify-ini-entry(  input substitute("&1_spl&2":U,  p-bik, p-host-code)
                            ,input substitute("client-bank-&1":U, v-format-prfx)
                            ,input substitute("отсутствует путь к подкаталогу &1&2 в каталогах экспорта/импорта данных в систему КЛИЕНТ-БАНК по формату &3 для фирмы с кодом &4"
                                            , substitute("&1_spl&2":U,  p-bik, p-host-code)
                                            , {&new-line}
                                            , v-format-prfx
                                            , p-host-code
                                            )
                            ,input yes
                            ,output spl) no-error.



     if spl = ? or error-status:error then return error return-value .
     /*сначала проверим out*/
     RUN verify-file(  input out + spl
                      ,input substitute("Не найден подкаталог &1 в директории &2&3 параметр &4_spl&5, секция [client-bank-&6] ini-файла"
                                        , spl
                                        , out
                                        , {&new-line}
                                        , p-bik
                                        , p-host-code
                                        , v-format-prfx)
                      ,input yes
                      ,output glog) no-error.
     if error-status:error or not glog then return error return-value .

     RUN verify-ini-entry(   input substitute("&1_sav&2":U, p-bik, p-host-code )
                            ,input substitute("client-bank-&1":U, v-format-prfx)
                            ,input substitute("отсутствует путь к подкаталогу &1_sav&2 в каталогах экспорта/импорта данных в систему КЛИЕНТ-БАНК&3" +
                                              "по ФОРМАТУ &4 для БИК &1 фирма &2"
                                              ,p-bik
                                              ,p-host-code
                                              ,{&new-line}
                                              ,v-format-prfx
                                              )
                            ,input yes
                            ,output sav) no-error.
      if error-status:error or sav = ? then do:
          sav = spl.
      end.
      else do:
        /* пока sav для out не проверяем*/
        /*сначала проверим out*/
        /*
        RUN verify-file(  input (out + sav)
                          ,input substitute("Не найден подкаталог &1 в директории &2&3 параметр &4_sav&5, секция [client-bank-&6] ini-файла"
                                            , sav
                                            , out
                                            , {&new-line}
                                            , p-bik
                                            , p-host-code
                                            , v-format-prfx)
                          ,input yes
                          ,output glog) no-error.
        if error-status:error or not glog then return error return-value .
        */
        /*потом проверим in_*/
        RUN verify-file(  input (in_ + sav)
                          ,input substitute("Не найден подкаталог &1 в директории &2&3 параметр &4_sav&5, секция [client-bank-&6] ini-файла"
                                            , sav
                                            , in_
                                            , {&new-line}
                                            , p-bik
                                            , p-host-code
                                            , v-format-prfx)
                          ,input yes
                          ,output glog) no-error.
        if error-status:error or not glog then return error return-value .

      end.
      run verify-ini-entry in this-procedure (
                                                INPUT  p-bik + '_adresat'
                                              ,INPUT  'client-bank-' + v-format-prfx
                                              ,INPUT substitute("отсутствует имя системы КЛИЕНТ-БАНК (параметр &1) по формату &2 для БИК &3", (p-bik + '_adresat'),  p-format, p-bik)
                                              ,INPUT yes
                                              ,output adresat) no-error .
      if error-status:error or out = ? then return error return-value .


      if p-mode = "send":U then do:
        run str/fileqnty.p ( out, output BadFlag ) .
        if not g#news and BadFlag then do:
          return error substitute("!!!Количество неотправленных в систему КЛИЕНТ-СЕРВЕР файлов в каталоге &1 превышает 500 ! "
                                  ,out).
        end.
      end.
  end.
END CASE.