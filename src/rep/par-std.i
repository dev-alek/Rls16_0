/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

стандартные параметрф для всех отчетов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 01/17/03 2:22

*/
define variable cconnect as character no-undo .
define variable user-name as character no-undo .

{ gbl/usrfulnm.i
  v-cntxt-userid
  user-name
}

 get-key-value section "rep-sets" key "conpar" value cconnect .


define variable v-base-key as character no-undo .

run gbl/base-key.p
   (output v-base-key
  ) .

{ rep/par-actu.i run-proc
     "'base-key'"
     "''"
     "'character'"
     v-base-key
     "'ключ'"
}

{ rep/par-actu.i run-proc
     "'db-connect'"
     "''"
     "'character'"
     cconnect
     "'строка коннекта к БД'"
  }
{ rep/par-actu.i run-proc
     "'report-code'"
     "''"
     "'character'"
     ReportProc
     "'уникальный код отчета'"
  }

define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .

{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-host-code v-host-name }

{ rep/par-actu.i run-proc
     "'firm-name'"
     "''"
     "'character'"
      v-host-name
     "'имя фирмы'"
  }


{ rep/par-actu.i run-proc
     "'firm-code'"
     "''"
     "'integer'"
     "string(v-cntxt-host-code-obj)"
     "'код фирмы'"
  }

  { rep/par-actu.i run-proc
     "'user-name'"
     "''"
     "'character'"
     user-name
     "'имя пользователя'"
  }
  { rep/par-actu.i run-proc
     "'store-type'"
     "''"
     "'character'"
       v-cntxt-obj-type
     "'текущий объект - тип' "
  }
  { rep/par-actu.i run-proc
     "'store-code'"
     "''"
     "'integer'"
     "string(v-cntxt-obj-code)"
     "'текущий объект - код'"
  }

  { rep/par-actu.i run-proc
     "'date-start'"
     "''"
     "'data'"
     "string(x-date-start,'99/99/9999')"
     "'дата начала интервала' "
  }
  { rep/par-actu.i run-proc
     "'date-end'"
     "''"
     "'data'"
     "string(x-date-end,'99/99/9999')"
     "'дата конца интервала'"
  }
  { rep/par-actu.i run-proc
     "'user-id'"
     "''"
     "'character'"
     "v-cntxt-userid"
     "'код пользователя'"
  }

define variable v-base-code like ub.sysconf.base-code no-undo .
{ gbl/basecode.i v-cntxt-host-code-obj v-base-code }
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
          buf_currency.curr-code = v-base-code.
  { rep/par-actu.i run-proc
     "'base-type'"
     "''"
     "'character'"
     "string(buf_currency.curr-abbr)"
     "'тип базовой валюты'"
   }
  { rep/par-actu.i run-proc
     "'base-code'"
     "''"
     "'integer'"
     "string(v-base-code)"
     "'код базовой валюты'"
    }

if Show-Crsa or Show-Cost or Show-Sale then do:
{ rep/par-actu.i run-proc  "'crsa'" "''" "'logical'" "string(show-Crsa,'yes/no')" "'  продажные цены'" }
{ rep/par-actu.i run-proc  "'cost'" "''" "'logical'" "string(show-cost,'yes/no')" "'  учетные цены'" }
{ rep/par-actu.i run-proc  "'sale'" "''" "'logical'" "string(show-sale,'yes/no')" "'  цены документа'" }
end.

else do:
{ rep/par-actu.i run-proc "'set-pay-type'"   "''" "'integer'"   string(x-set_pay_type)  "'тип цены Продажные цены=1 Учетные цены=2 Цены документа=3 '" }
end.

{ rep/par-actu.i run-proc "'rubl-val'"       "''" "'integer'"   string(x-SET_val_TYPE)  "'печатать в {&abbr_rublyah} или валюте {&abbr_rub}=1  вал=2  обе=3 '"  }
{ rep/par-actu.i run-proc "'reportname'"     "''" "'character'" reportname              "'название отчета'"   }
{ rep/par-actu.i run-proc "'select-good'"    "''" "'integer'"   string(x-selectgood)    "'тип выбора товара all=1 grp=2 prod=3 choice=4 one=5 grp-prod=6'" }

 define variable ii as integer no-undo .
 define variable ii-name as character no-undo .
 define variable ii-1 as integer no-undo .
 define variable ii-name-1 as character no-undo .
  define variable ii-2 as integer no-undo .
 define variable ii-name-2 as character no-undo .
 define variable ii-3 as integer no-undo .
 define variable ii-name-3 as character no-undo .

 if x-selectgood = {&g-all}     Or
    x-selectgood = {&g-grp}     Or
    x-selectgood = {&g-prod}    Or
    x-selectgood = {&g-choice}  then do:
 ii = 0.
      for each gds-list :
        ii = ii + 1 .
        if ii = 1 then ii-name = "список товаров - содержит gds-code  (уникальный ключ товара)" .
                  else ii-name = "" .

        { rep/par-actu.i run-proc "'gds-list'"  string(ii)    "'integer'"   string(gds-list.gds-code)   ii-name  }
      end.
 end.

 if x-selectgood = {&g-grp} then do:
 ii-2 = 0.
      for each tmp#grp :
        ii-2 = ii-2 + 1 .
        if ii-2 = 1 then ii-name-2 = "список товаров - содержит  <node-code#grp-name>  (уникальный ключ списка групп)" .
                  else ii-name-2 = "" .
        { rep/par-actu.i run-proc "'tmp#grp'"  string(ii-2) "'integer character '"  "string(tmp#grp.node-code) + '#' +  (tmp#grp.grp-name)"   ii-name-2  }
      end.
 end.
 if x-selectgood = {&g-prod} then do:
 ii-3 = 0.
      for each g#cli :
        ii-3 = ii-3 + 1 .
        if ii-3 = 1 then ii-name-3 = "список товаров - содержит  <node-code#grp-name>  (уникальный ключ списка производителе)" .
                    else ii-name-3 = "" .
        { rep/par-actu.i run-proc "'g#cli'"  string(ii-3) "'character integer'"  "g#cli.obj-type + '#' + string(g#cli.obj-code)"    ii-name-3  }
      end.
 end.


{ rep/par-actu.i run-proc "'select-object'"  "''" "'character'" x-selectobject          "'тип выбора объекта   -currency -choice -firm -все'" }
 ii-1 = 0.
  for each obj-list :
    ii-1 = ii-1 + 1 .
    if ii-1 = 1 then ii-name-1 = "список объектов - содержит <obj-type#obj-code>  (уникальный ключ clients)" .
              else ii-name-1 = "" .

    { rep/par-actu.i run-proc "'obj-list'"  string(ii-1)    "'character integer'"  "obj-list.obj-type + '#' + string (obj-list.obj-code)"   ii-name-1  }
  end.

/* $Workfile$ e n d */