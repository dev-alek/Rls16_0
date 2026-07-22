block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fixvalid.p $
$Archive: utl/fixvalid.p $

Проверка корректности версий эталонных данных fix-gate fixrum fixdr fixcstml fixattrp

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/08
Author: Bakhtadze Natalya
Creation date: 04/10/08

*/

define input parameter p-sources-full-path as character no-undo .
/*путь к исходникам - к директории , которая содержит cmp gbl и т.д. таккой чтоб p-source-full-path */
define output parameter p-correct as logical no-undo .
define output parameter p-message as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fixvalid.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fixvalid.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define stream instream.

define variable v-txt-file-list as character no-undo init "~
cmp/fixattrp.txt~
,cmp/fixdr.txt~
,cmp/fixrum.txt~
,cmp/fixcstml.txt~
,cmp/fix-gate.txt~
,cmp/fix-lay.txt~
".

define variable v-ver-file-list as character no-undo init "~
gbl/attrprps.i~
,gbl/disrules.i~
,gbl/rumconf.i~
,gbl/cstmlabs.i~
,gbl/gateconf.i~
,gbl/layconf.i~
".

define variable v-ver-var-list as character no-undo init "~
ap-revision~
,rule-revision~
,rum-revision~
,cl-revision~
,gate-revision~
,layout-revision~
".

/*список НОМЕРОВ ЗАПИСЕЙ в текстовых файлах конфигураци где лежит номер версии*/
define variable v-ver-record-num-list as character no-undo init "~
first~
,first~
,last~
,first~
,last~
,last~
".

/*список полей в ЗАПИСЯХ в текстовых файлах конфигураци где лежит номер версии*/
define variable v-ver-record-field-list as character no-undo init "~
property-value~
,des~
,documentation~
,custom-tooltip~
,descr~
,layout-name~
".

define variable v-description-list as character no-undo init "~
КОНФИГУРАЦИЯ АТРИБУТОВ~
,КОНФИГУРАЦИЯ ПРАВИЛ СКИДОК И РАСПИСАНИЙ~
,КОНФИГУРАЦИЯ МАШИНЫ ПРАВИЛ (RUM)~
,КОНФИГУРАЦИЯ НАСТРАИВАЕМЫХ ПОЛЕЙ~
,КОНФИГУРАЦИЯ ГЕЙТОВ~
,КОНФИГУРАЦИЯ РАСКЛАДОК~
".

define variable ss as character no-undo .
define variable ss1 as character no-undo .
define variable rev-string as character no-undo .
define variable v-ii as integer no-undo .
define variable v-num-rec as integer no-undo .
define variable v-index as integer no-undo .
define variable v-txt-revis as character no-undo .
define variable v-gbl-revis as character no-undo .
define variable v-path-txt as character no-undo .
define variable v-path-gbl as character no-undo .


do v-ii = 1 to num-entries(v-txt-file-list):
  rev-string = ''.
  v-num-rec = 0.
  v-path-txt = p-sources-full-path  + entry(v-ii, v-txt-file-list).
  if search(v-path-txt) = ? then do:
    return error substitute("В исходниках не найден файл &1", entry(v-ii, v-txt-file-list)).
  end.
  v-path-gbl = p-sources-full-path + entry(v-ii, v-ver-file-list).
  if search(v-path-gbl) = ? then do:
    return error substitute("В исходниках не найден файл &1", entry(v-ii, v-ver-file-list)).
  end.
  input stream instream from value(search(v-path-txt)).
  _repeat1:
  repeat:
    import stream instream unformatted ss.
    v-num-rec = v-num-rec + 1.
    if ss <> '"**END OF PACKET**"' then do:
      ss1 = ss.
    end.
    if entry(v-ii, v-ver-record-num-list) = "first" then do:
      if v-num-rec = 2 then leave _repeat1.
    end.
  end.
  input stream instream close.
  case entry(v-ii, v-ver-record-num-list):
    when "first" then do:
      rev-string = ss.
    end.
    when "last" then do:
      rev-string = ss1.
    end.
  end case.
  /*разберем строку в псевдо -XML формате по упрощенному варианту*/
  /*
  "<num-fields>" "12" "<int64-id>" "0" "<db-num>" "0" "<uniq-key-rec>" "" "<field-name_>" "" "<resource-type>" "gate" "<descr>" "v15_0.2" "<part-num>" "0" "<user-db-num>" "0" "<user-name>" "0-43" "<sys-date>" "11/02/08" "<sys-time>" "20:36:17" "<sys-time-int>" "74177"
  */

  v-index = index(rev-string, substitute("&2<&3>&2&1"
                                        ,{&space-char}
                                         ,{&double-quote}
                                         ,entry(v-ii, v-ver-record-field-list))).
  rev-string = substring(rev-string, v-index).
  /*"<descr>" "v15_0.2" "<part-num>" "0" "<user-db-num>" "0" "<user-name>" "0-43" "<sys-date>" "11/02/08" "<sys-time>" "20:36:17" "<sys-time-int>" "74177"*/
  rev-string = substring(rev-string,
                                    length(substitute("&2<&3>&2&1"
                                        ,{&space-char}
                                         ,{&double-quote}
                                         ,entry(v-ii, v-ver-record-field-list))) + 1).
  /*v15_0.2" "<part-num>" "0" "<user-db-num>" "0" "<user-name>" "0-43" "<sys-date>" "11/02/08" "<sys-time>" "20:36:17" "<sys-time-int>" "74177"*/

  v-txt-revis = entry(2, rev-string, {&double-quote}).
  input stream instream from value(search(v-path-gbl)).
  _repeat2:
  repeat:
    import stream instream unformatted ss.
    if index(ss, substitute("&1&2", {&space-char}, entry(v-ii, v-ver-var-list))) > 0 then do:
      v-gbl-revis = trim(trim(trim(entry( num-entries(ss, {&space-char}), ss, {&space-char}), {&single-quote}), {&double-quote}), {&single-quote}).
      leave _repeat2.
    end.
  end.
  input stream instream close.
  if v-txt-revis <> v-gbl-revis then do:
    p-message = p-message + {&new-line} +
                substitute("Не совпадают версии для &1 в файле &2 и файле &3&4СВЕРЬТЕ ВЕРСИИ С VSS!!!!!"
                           ,entry(v-ii, v-description-list)
                           ,entry(v-ii, v-txt-file-list)
                           ,entry(v-ii, v-ver-file-list)
                           ,{&new-line}).
  end.
end.
if trim(p-message, {&new-line}) = '':U then do:
  p-correct = yes.
end.