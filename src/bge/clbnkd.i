/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения временных таблиц для ЭКСПОРТА/ИМПОРТА в систему КЛИЕНТ-БАНК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/20/05
Author: Bakhtadze Natalya
Creation date: 07/20/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob cl-bank-1s-version '1.01'


&if "{1}" <> "hfields" &then
define {1} temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer

    index pi is primary unique obj-type obj-code
.

DEFINE {1} TEMP-TABLE temp_hfin-schet NO-UNDO LIKE ub.fin-schet
.
DEFINE {1} TEMP-TABLE temp_cfin-schet NO-UNDO LIKE ub.fin-schet
.

define temp-table temp-bik no-undo
field host-code like ub.sysconf.host-code
field code-bank like ub.fin-bank.code-bank
field bik       like ub.fin-bank.bik
field f_name    as character
field o_name    as character
field d-count    as integer
field adresat as character
index pi is unique primary
host-code
bik
.

procedure init-host-list :
define input parameter p-host-list as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_obj-list for temp_obj-list.

  do
  on error undo, return error
  :
  for each buf_temp_obj-list
  :
      delete buf_temp_obj-list.
  end.
  do v-counter = 1 to num-entries( p-host-list ) / 2
  :
      create buf_temp_obj-list.
      assign
          buf_temp_obj-list.obj-type = entry( 2 * v-counter - 1,  p-host-list )
          buf_temp_obj-list.obj-code = integer( entry( 2 * v-counter,      p-host-list ) )
      .
  end.

  end.

end procedure. /* init-host-list */

procedure fill-hfin-schet :
define input parameter p-hfin-schet as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_hfin-schet for temp_hfin-schet.

  do
  on error undo, return error return-value
  :

      for each buf_temp_hfin-schet
      :
          delete buf_temp_hfin-schet.
      end.
      do v-counter = 1 to num-entries( p-hfin-schet ) / 6
      :
          create buf_temp_hfin-schet.
          assign
          buf_temp_hfin-schet.host-code = integer( entry( 6 * v-counter - 5,      p-hfin-schet ) )
          buf_temp_hfin-schet.r-schet = entry( 6 * v-counter - 4,  p-hfin-schet )
          buf_temp_hfin-schet.cli-type =  entry( 6 * v-counter - 3,      p-hfin-schet )
          buf_temp_hfin-schet.cli-code = integer( entry( 6 * v-counter - 2,      p-hfin-schet ) )
          buf_temp_hfin-schet.code-bank = integer( entry( 6 * v-counter - 1,      p-hfin-schet ) )
          buf_temp_hfin-schet.code-schet = integer( entry( 6 * v-counter,      p-hfin-schet ) )
          .
      end.
  end.

end procedure. /* fill-hfin-schet */


procedure fill-cfin-schet :
define input parameter p-cfin-schet as character no-undo .
define variable v-counter as integer no-undo .

define buffer buf_temp_cfin-schet for temp_cfin-schet.
  do
  on error undo, return error return-value
  :

      for each buf_temp_cfin-schet
      :
          delete buf_temp_cfin-schet.
      end.
      do v-counter = 1 to num-entries( p-cfin-schet ) / 6
      :
          create buf_temp_cfin-schet.
          assign
          buf_temp_cfin-schet.host-code = integer( entry( 6 * v-counter - 5,      p-cfin-schet ) )
          buf_temp_cfin-schet.r-schet = entry( 6 * v-counter - 4,  p-cfin-schet )
          buf_temp_cfin-schet.cli-type =  entry( 6 * v-counter - 3,      p-cfin-schet )
          buf_temp_cfin-schet.cli-code = integer( entry( 6 * v-counter - 2,      p-cfin-schet ) )
          buf_temp_cfin-schet.code-bank = integer( entry( 6 * v-counter - 1,      p-cfin-schet ) )
          buf_temp_cfin-schet.code-schet = integer( entry( 6 * v-counter,      p-cfin-schet ) )
          .
      end.
  end.

end procedure. /* fill-hfin-schet */



&endif

&if "{1}" = "hfields" &then

define {2} temp-table temp_hfields no-undo
field order_ as integer
field label_ as character
field name_ as character
field value_ as character init ?
field imported    as logical
field readed      as logical
field subject     as character
index pi is primary
name_
index ilab
label_
index ii
imported
index ir
readed
index isubject subject
.

&GLOBAL-define only-expense-fields 'stat-pl,f104,f105,f106,f107,f108,f109,f110':U

procedure create-TEMP-hfields  :
define input parameter p-mode as character no-undo .

  do
  on error undo, return error
  :

define variable ii as integer no-undo .
define variable h-init-doc as character  extent 116 init


[

    'Дата='                           , 'doc-date'
   ,'Номер='                          , 'prn-doc-code'
   ,'Сумма='                          , 'sum-doc'
   ,'Плательщик='                     , 'payer-inn/payer-name'
   ,'Плательщик1='                    , 'payer-name'
   ,'Плательщик2='                    , 'payer-r-schet'
   ,'Плательщик3='                    , 'payer-bank-name'
   ,'Плательщик4='                    , 'payer-bank-city'
   ,'ПлательщикСчет='                 , 'payer-r-schet'
   ,'Плательщик{&abbr_inn_allshift}='                  , 'payer-INN'
   ,'Плательщик{&abbr_kpp_allshift}='                  , 'payer-kpp'
   ,'ПлательщикРасчСчет='             , 'payer-r-schet'
   ,'ПлательщикБИК='                  , 'payer-bik'
   ,'ПлательщикКорСчет='              , 'payer-c-schet'
   ,'ПлательщикБанк1='                , 'payer-bank-name'
   ,'ПлательщикБанк2='                , 'payer-bank-city'
   ,'Получатель='                     , 'receiver-inn/receiver-name'
   ,'Получатель1='                    , 'receiver-name'
   ,'Получатель2='                    , 'receiver-r-schet'
   ,'Получатель3='                    , 'receiver-bank-name'
   ,'Получатель4='                    , 'receiver-bank-city'
   ,'ПолучательСчет='                 , 'receiver-r-schet'
   ,'Получатель{&abbr_inn_allshift}='                  , 'receiver-INN'
   ,'Получатель{&abbr_kpp_allshift}='                  , 'receiver-kpp'
   ,'ПолучательРасчСчет='             , 'receiver-r-schet'
   ,'ПолучательБИК='                  , 'receiver-bik'
   ,'ПолучательКорСчет='              , 'receiver-c-schet'
   ,'ПолучательБанк1='                , 'receiver-bank-name'
   ,'ПолучательБанк2='                , 'receiver-bank-city'
   ,'СтатусСоставителя='              , 'stat-pl'
   ,'ПоказательКБК='                  , 'f104'
   ,'ПоказательОснования='            , 'f106'
   ,'ОКАТО='                          , 'f105'
   ,'ПоказательПериода='              , 'f107'
   ,'ПоказательНомера='               , 'f108'
   ,'ПоказательДаты='                 , 'f109'
   ,'ПоказательТипа='                 , 'f110'
   ,'НазначениеПлатежа='              , 'naznach-plat/'
   ,'ВидПлатежа='                     , 'vid-plat'
   ,'ВидОплаты='                      , 'vid-opl'
   ,'Очередность='                    , 'ocher-pl'
   ,'СрокПлатежа='                    , 'srok-pl'
   ,'СекцияДокумент='                 , 'fin-ext-doc-type/'
   ,'ДатаСписано='                    , 'fact-date'
   ,'ДатаПоступило='                  , 'fact-date'
   ,''                                , 'receiver-type'
   ,''                                , 'receiver-code'
   ,''                                , 'receiver-code-schet'
   ,''                                , 'payer-type'
   ,''                                , 'payer-code'
   ,''                                , 'payer-code-schet'
   ,''                                , 'fin-ext-doc-type'
   ,''                                , 'fin-doc-type'
   ,''                                , 'host-code'
   ,''                                , 'curr-code'
   ,'КвитанцияДата'                   , 'cvitdate'
   ,'КвитанцияВремя'                  , 'cvitname'
   ,'КвитанцияСодержание'             , 'cvitcont'

                                   ] no-undo.

define variable h-init-statement as character  extent 40 init


[

    'ДатаНачала='                     , 'start-date'
   ,'ДатаКонца='                      , 'end-date'
   ,'РасчСчет='                       , 'r-schet'
   ,'НачальныйОстаток='               , 'start-sum-doc'
   ,'КонечныйОстаток='                , 'end-sum-doc'
   ,'ВсегоПоступило='                 , 'in-sum-doc'
   ,'ВсегоСписано='                   , 'out-sum-doc'
   ,'СекцияРасчСчет='                 , 'fins-ext-doc-type/'
   ,''                                , 'fins-ext-doc-type'
   ,''                                , 'fins-doc-type'
   ,''                                , 'host-code'
   ,''                                , 'curr-code'
   ,''                                , 'code-schet'
   ,''                                , 'code-bank'
   ,''                                , 'cli-name'
   ,''                                , 'bank-name'
   ,''                                , 'bank-city'
   ,''                                , 'cl-bank'
   ,''                                , 'bik'
   ,'ДатаСоздания='                   , 'bank-date'
                                   ] no-undo.


    for each temp_hfields:
      delete temp_hfields.
    end.
    do ii = 1 to (if p-mode = 'exp' then 42 else 58):
      create temp_hfields.
      assign
      temp_hfields.order_ = ii
      temp_hfields.label_ = h-init-doc[ii * 2 - 1]
      temp_hfields.name_ = h-init-doc[ii * 2]
      temp_hfields.subject = {&table_fin-doc}
      .
    end.
    do ii = 1 to (if p-mode = 'exp' then 0 else 20):
      create temp_hfields.
      assign
      temp_hfields.order_ = ii
      temp_hfields.label_ = h-init-statement[ii * 2 - 1]
      temp_hfields.name_ = h-init-statement[ii * 2]
      temp_hfields.subject = {&table_fin-statement}
      .
    end.



  end.

end procedure. /* create-hfields  */


&endif

/* $Workfile$ e n d */