/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Некие общие переменные для перемылки на кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/04
Author: Bakhtadze Natalya
Creation date: 06/23/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*вспомогательная переменная для имени файла*/
define variable fname                        as character      no-undo .
/*вспомогательная переменная для имени директории вывода*/
define variable out                          as character      no-undo .
/*вспомогательная переменная для имени директории вывода*/
define variable out2                          as character      no-undo .
/*вспомогательная переменная для имени директории ввода*/
DEFINE VARIABLE in_                          as character      no-undo .
/*вспомогательная переменная для имени директории ввода конткреного магазина*/
DEFINE VARIABLE spl                          as character      no-undo .
/*вспомогательная переменная для имени директории архива*/
DEFINE VARIABLE sav                          as character      no-undo .
/*вспомогательная переменная для имени директории удаленных касс*/
DEFINE VARIABLE v-remote                     as character      no-undo .
/*
define variable i as integer no-undo.
define variable t as int no-undo.
*/
/*флаг начала пакета*/
DEFINE VARIABLE start-paket                  as logical init yes no-undo .
/*счетчик записей текущего пакета*/
define variable cr as integer no-undo.
/*тип кассы - передавать время изменения записи в спуле*/
define variable Cash-OS2                    as logical        no-undo .
/*тип кассы - не передавать время изменения записи в спуле*/
define variable Cash-DOS                     as logical        no-undo .
/*флаг засоренности директории большим кол-вом файлов*/
define variable BadFlag                      as logical        no-undo .
/*ошибка операционки*/
define variable os-er                        as integer        no-undo .
/*время для спула*/
DEFINE VARIABLE OS2-time                     as character      no-undo .
define variable glog as logical no-undo .
/*имя log-file */
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-md5-signature              as character      no-undo .
define variable v-cd-list-update             as character no-undo .
define variable v-cd-list-delete             as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
{ gbl/thbj-def.i }
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .



define stream   IBMStream .

define temp-table temp-cd no-undo like ub.cash-desk .

{ str/tekkatsk.i " " IBMSTREAM }

&glob sending-error     if error-status:error then do:                                                  ~
                          run write-log-and-file in p-log-handle (                                      ~
                                input 1                                                                 ~
                              , input log-file-name                                                     ~
                              , input 1                                                                 ~
                              , input substitute("&1 &2", error-status:get-message(1), return-value)    ~
                                                                  ).                                    ~
                          assign                                                                        ~
                          v-view-log = yes                                                              ~
                          .                                                                             ~
                        end
                        /*точку не ставим для контроля синтаксиса*/

procedure fill-temp-cd :
define input parameter p-db-num   like ub.cash-desk.db-num no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-clear-table as logical no-undo .

define buffer buf_temp-cd for temp-cd.
define buffer buf_cash-desk for ub.cash-desk.

  do
  on error undo, return error
  :

     if p-clear-table  then do:
       for each buf_temp-cd:
         delete buf_temp-cd.
       end.
     end.
     for each buf_cash-desk no-lock where
            buf_cash-desk.db-num = p-db-num
        AND buf_cash-desk.obj-code = p-obj-code
        and buf_cash-desk.cash-on  = yes
     BREAK by buf_cash-desk.pos-type:
       if first-of(buf_cash-desk.pos-type) then do:
         create buf_temp-cd.
         buffer-copy buf_cash-desk to buf_temp-cd.
       end.
     end.
  end.

end procedure. /* fill-temp-cd */


/* $Workfile$ e n d */