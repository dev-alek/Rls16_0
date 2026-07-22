/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами для резервуаров

Автор: Шальнев Иван Сергеевич
Дата создания: 12/22/11
Author: Ivan Shalnev
Creation date: 12/22/11

*/

&global-define place-type         "place-type"                /*тип резервуара(вертикальный,горизонтальный)*/
&global-define place-SI           "place-SI"                    /*средство измерения*/
&global-define place-diameter     "place-diameter"        /*диаметр резервуара(мм)*/
&global-define dead-balance       "dead-balance"        /*мертвый остаток*/
&global-define water-level        "water-level"        /*Допустимый уровень воды(мм)*/
/*&global-define place-ratio-error  "place-ratio-error"  /*относительная погрешность составления калибровочной таблицы резервуара*/*/
&global-define place-dens-prov    "dens-prov"         /*плотность при поверке резервуара*/
&global-define place-virtual      "place-virtual"     /*виртуальный резервуар*/
&global-define place-twice-code   "place-twice-code" /*Код сдвоенного резервуара*/
&global-define place-sert-urov    "place-sert-urov" /*Сертифицированный уровнемер по массе*/
&global-define place-local        "place-local"     /*Расположение резервуара*/
&global-define place-error-mass   "place-error-mass" /*Погрешность измерения массы*/
&global-define place-asi-sertif   "place-asi-sertif" /*АСИ сертифицированно*/
&global-define place-rvd-dnsty    "place-rvd-dnsty" /*РВД плотности*/
&global-define place-rvd-lvl      "place-rvd-lvl" /*РВД уровня*/
&global-define place-rvd-tmp      "place-rvd-tmp" /*РВД температуры*/
&global-define place-SI-dens      "place-SI-dens"                    /*средство измерения плотности*/
&global-define place-SI-level     "place-SI-level"                    /*средство измерения уровня*/
&global-define place-SI-temp      "place-SI-temp"                    /*средство измерения температуры*/
&global-define place-passp-num    "place-passp-num"                    /*номер по паспорту*/
&global-define place-passp-type   "place-passp-type"                    /*тип по паспорту*/
&global-define place-dead-high    "place-dead-high"                    /*высота мертвой полости*/
&global-define place-temp-coef    "place-temp-coef"                    /*Температурный коэффициент линейного расширения материала стенки резервуара,*/
&global-define disable-water-alarm   "disable-water-alarm" /*Отключить сообщения по воде*/
&global-define disable-level-alarm   "disable-level-alarm" /*Отключить сообщения по уровню*/
&global-define place-ponton        "place-ponton"                    /*наличие понтона*/
&global-define place-ponton-mass   "place-ponton-mass"                    /*масса понтона*/
&global-define place-ponton-height "place-ponton-height"                    /*высота всплытия понтона*/
&global-define place-com-vessel    "place-com-vessel"                    /*признак сообщающегося резервуара*/
&global-define place-com-tanks     "place-com-tanks"                    /*коды сообщающихся резервуаров*/
&global-define place-is-main       "place-is-main"                    /*признак главного резервуара (СР)*/
&global-define place-gate-valve    "place-gate-valve"                    /*Задвижка в резервуаре при переподключении рукавов при прие-ме СУГ*/
&global-define place-gate-valve-tanks "place-gate-valve-tanks"              /*коды резервуаров, объединенных задвижкой*/
&global-define place-auto-gate-valve "place-auto-gate-valve"              /* Автоматическая задвижка между сообщающимися резервуарами с НП */

&global-define place-current      "place-current"      /* Текущий резервуар для СР с автоматической задвижкой (в список не добавлять!) */
&global-define place-need-RVD-rvs "place-need-RVD-rvs" /* Необходимо сделать сверку с РВД (в список не добавлять!) */
&global-define init-shift-period-rvs "init-shift-period-rvs" /* Номер сменной сверки для инициализации функционала контроля плотности НП (в список не добавлять!) */
&global-define pending-table-version "pending-table-version" /* Номера версий ГТ (и др. параметров), ожидающих применения (в список не добавлять!) */
&global-define current-table-version "current-table-version" /* Текущий номер версии ГТ (и др. параметров) (в список не добавлять!) */
&global-define message-table-version "message-table-version" /* Необходим вывод сообщения об ожидании/применении новой версии ГТ (и др. параметров) (в список не добавлять!) */

&global-define list-place-attr    'place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve,place-gate-valve-tanks,place-auto-gate-valve':u /*список атрибутов резервуара*/


procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.

define buffer buf_place-attr for ub.place-attr .

  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.

end.

procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.


define buffer buf_place-attr for ub.place-attr .

  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.

end.


procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.

define buffer buf_place-attr for ub.place-attr .

  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.

end.











