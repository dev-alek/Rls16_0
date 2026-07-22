/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры, обслуживающие общение с МБ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/20/08
Author: Bakhtadze Natalya
Creation date: 06/20/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-nodes no-undo
field nhandle as handle
field nname as character
index pi is unique primary
nhandle
.

&glob sec-per-command 10


procedure set-cmd-file :
define input parameter p-cmd-name as character no-undo .
define input parameter p-nid as character no-undo .
define input parameter p-d-card as character no-undo .
define input parameter p-xml-file as character no-undo .

do
on error undo, return error
:
  define variable hdoc as handle no-undo .
  define variable hroot as handle no-undo .
  define variable hrow as handle no-undo .
  define variable hfield as handle no-undo .
  define variable htext as handle no-undo .
  define variable v-ii as integer no-undo .
  /*начинаем инициализацию*/
  /*проверка связи*/
  create x-document hdoc.
  create x-noderef hroot.
  create x-noderef hrow.
  create x-noderef hfield.
  create x-noderef htext.
  hdoc:create-node(hroot, "InitVid", "element").
  hdoc:encoding = "WINDOWS-1251".
  hdoc:append-child(hroot).
  hroot:set-attribute("mode", "command").
  hroot:set-attribute("vid",  substitute("&1", p-d-card)).
  if p-nid <> "":U then do:
    hroot:set-attribute("nid", p-nid).
  end.
  hroot:set-attribute("token", substitute("&1&2", v-cntxt-obj-type, v-cntxt-obj-code)).
  if p-cmd-name <> "" then do:
    do v-ii = 1 to num-entries(p-cmd-name):
      run value( substitute("command_set_&1", entry(v-ii, p-cmd-name))) in this-procedure ( input p-d-card
                                                                        ,input hdoc
                                                                        ,input hroot).
    end.
  end.
  hdoc:save("file", p-xml-file).
  for each temp-nodes:
    delete object temp-nodes.nhandle.
    delete temp-nodes.
  end.
  delete object hdoc.
  delete object hroot.
  delete object hrow.
  delete object hfield.
  delete object htext.


end.

end procedure. /* set-cmd-file */

procedure get-cmd-file :
define input parameter p-cmd-name as character no-undo .
define input parameter p-xml-file as character no-undo .
define input parameter p-d-card as character no-undo .
define input parameter p-option as character no-undo .
define output parameter p-error-code as character no-undo.

define variable hdoc as handle no-undo .
define variable hroot as handle no-undo .
define variable htext as handle no-undo .
define variable hattr as handle no-undo .
define variable herror as handle no-undo .
define variable v-ii as integer no-undo .
define variable v-mode as character no-undo .
define variable v-d-card as character no-undo .
define variable v-obj-type-code as character no-undo .
define variable v-error-mess as character no-undo .
define variable v-error-mess2 as character no-undo .
define variable glog as logical no-undo .

do
on error undo, return error
:
  create x-document hdoc.
  create x-noderef hroot.
  create x-noderef htext.
  create x-noderef hattr.
  create x-noderef herror.
  assign
  glog = hdoc:load("file", p-xml-file, false) no-error.
  if error-status:error
  or not glog
  or  error-status:get-message(1) <> ""
  then do:
    message
    "Ошибка при чтении файла XML-ответа от программы инициализации"
    error-status:get-message(1) skip
    return-value view-as alert-box .
    undo, return error .
  end.
  else if p-cmd-name <> ''
  and p-cmd-name <> "readid" then do:
    /*message "OK" p-cmd-name view-as alert-box .*/
  end.
  hdoc:get-document-element(hroot).
  if hroot:get-attribute-node(hattr, "mode") then do:
    v-mode = hattr:node-value.
  end.
  if hroot:get-attribute-node(hattr, "vid") then do:
    v-d-card = hattr:node-value.
  end.
  if hroot:get-attribute-node(hattr, "token") then do:
    v-obj-type-code = hattr:node-value.
  end.
  if hroot:get-attribute-node(hattr, "error") then do:
    assign
    p-error-code = hattr:node-value no-error.
    repeat v-ii = 1 to hroot:num-children:
      hroot:get-child(htext,v-ii).
      if htext:subtype = "text"
      then do:
        v-error-mess = trim(htext:node-value).
        leave.
      end.
    end.
  end.
  if v-mode <> "result"
  then do:
    undo, return error substitute("Ответ программы инициализации МБ имеет неверный формат: &1", v-mode).
  end.
  /*
  if not v-d-card begins "0x" then do:
    define variable v-str as character no-undo.
    define variable v-hex as integer no-undo.
    run  dec-to-hex in this-procedure ( STRING(v-d-card), output v-str, output v-hex) .
    v-d-card = substitute("&1&2", fill("0", (8 - length(v-str))), v-str).
  end.
  */
  if v-d-card <> p-d-card
  then do:
    for each temp-nodes:
      delete object temp-nodes.nhandle.
      delete temp-nodes.
    end.
    delete object hdoc.
    delete object hroot.
    delete object hattr.
    delete object htext.
    delete object herror.
    undo, return error substitute("Ответ программы инициализации МБ прислал данные для МБ с ДРУГИМ идентификаторовм &1", v-d-card).
  end.
  if v-obj-type-code <> substitute("&1&2", v-cntxt-obj-type, v-cntxt-obj-code) then do:
    for each temp-nodes:
      delete object temp-nodes.nhandle.
      delete temp-nodes.
    end.
    delete object hdoc.
    delete object hroot.
    delete object hattr.
    delete object htext.
    delete object herror.
    undo, return error substitute("Ответ программы инициализации МБ имеет неверного адресата: &1", v-obj-type-code).
  end.
  repeat v-ii = 1 to hroot:num-children:
    hroot:get-child(htext, v-ii).
    case htext:subtype:
      when "ELEMENT" then do:
        if index(p-cmd-name, htext:name) > 0 then do:
          run value( substitute("command_get_&1", htext:name)) in this-procedure ( input p-d-card
                                                                            ,input hdoc
                                                                            ,input htext) .
          if return-value <> "" then do:
            v-error-mess2 = return-value.
          end.
        end.
      end. /*when "ELEMENT" then do:*/
    end case.
  end. /*  repeat v-ii = 1 to hroot:num-children:*/
  for each temp-nodes:
    delete object temp-nodes.nhandle.
    delete temp-nodes.
  end.
  delete object hdoc.
  delete object hroot.
  delete object hattr.
  delete object htext.
  delete object herror.
  if p-option = "no-error" then do:
    return substitute("Ошибка при чтении ответа на команду(-ы) &1&2&3"
                         , v-error-mess
                         , {&new-line}
			, v-error-mess2).

  end.
  if v-error-mess <> ''
  or v-error-mess2 <> ''
  then do:
    return error substitute("Ошибка при чтении ответа на команду(-ы) &1&2&3"
                         , v-error-mess
                         , {&new-line}
			, v-error-mess2).
  end.
end.
end procedure. /* get-cmd-file */

procedure command_set_readid :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .

define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "ReadID".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "ReadID", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token",  p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  end.

end procedure. /* command_set_readid */

procedure command_get_readid :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .

define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-hdoc as handle.
define variable v-error-mess as character no-undo .
define variable v-error-code as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef .
  do
  on error undo, return error
  :

    find first buf2_temp-ef .
    create x-noderef hattr.
    if p-hnode:get-attribute-node(hattr, "vrn") then do:
      assign
      buf2_temp-ef.car-reg-number = hattr:node-value no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "format") then do:
      assign
      buf2_temp-ef.ef-format = integer(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "issuer") then do:
      assign
      buf2_temp-ef.issue-code = integer(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "db") then do:
      assign
      buf2_temp-ef.db = integer(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "oper") then do:
      assign
      buf2_temp-ef.user-id = integer(hattr:node-value)  no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "date") then do:
      assign
      buf2_temp-ef.issue-date = date(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "time") then do:
      assign
      buf2_temp-ef.issue-time = integer(entry(1, hattr:node-value, ":")) * 3600 + integer(entry(1, hattr:node-value, ":")) * 60 + integer(entry(1, hattr:node-value, ":"))
      no-error
      .
    end.
    if P-hnode:get-attribute-node(hattr, "begin") then do:
      assign
      buf2_temp-ef.valid-from = date(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "end") then do:
      assign
      buf2_temp-ef.valid-date = date(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      assign
      v-error-code = hattr:node-value no-error.
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    if v-error-code = "99"
    or v-error-code = ""
    or v-error-code = ?
    then return "".
    return v-error-mess.
  end.

end procedure. /* command_get_readid */

procedure command_set_writeid :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .

define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where
                buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "WriteID".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteID", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
      buf_temp-nodes.nhandle:set-attribute("vrn", buf_temp-ef.car-reg-number).
      buf_temp-nodes.nhandle:set-attribute("issuer", string(buf_temp-ef.issue-code)).
      buf_temp-nodes.nhandle:set-attribute("db", string(buf_temp-ef.db-num)).
      buf_temp-nodes.nhandle:set-attribute("oper", string(buf_temp-ef.user-id)).
      buf_temp-nodes.nhandle:set-attribute("date", (if buf_temp-ef.issue-date = ?
                                                    then {&question-mark}
                                                    else string(buf_temp-ef.issue-date, "99.99.9999"))).
      buf_temp-nodes.nhandle:set-attribute("time", string(buf_temp-ef.issue-time, "hh:mm:ss") ).
      buf_temp-nodes.nhandle:set-attribute("begin", (if buf_temp-ef.valid-from = ?
                                                    then {&question-mark}
                                                    else string(buf_temp-ef.valid-from, "99.99.9999"))).
      buf_temp-nodes.nhandle:set-attribute("end",  (if buf_temp-ef.valid-date = ?
                                                   then {&question-mark}
                                                   else string(buf_temp-ef.valid-date + 1, "99.99.9999"))).
  end.

end procedure. /* command_set_readid */


procedure command_get_writeid :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .

define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.

end procedure. /* command_get_writeid */

procedure command_set_readbrand :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .

define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "ReadBrand".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "ReadBrand", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token",  p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  end.

end procedure. /* command_set_readbrand */


procedure command_get_readbrand :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .

define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-hdoc as handle.
define variable v-error-mess as character no-undo .
define variable v-error-code as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef .
  do
  on error undo, return error
  :

    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "format") then do:
      assign
      buf2_temp-ef.ef-format = integer(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "brand") then do:
      assign
      buf2_temp-ef.car-brand = hattr:node-value  no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      assign
      v-error-code = hattr:node-value no-error.
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    if v-error-code = "99"
    or v-error-code = ""
    or v-error-code = ?
    then return "".
    return v-error-mess.
  end.

end procedure. /* command_get_readbrand */


procedure command_set_writebrand :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .

define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where
                buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "WriteBrand".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteBrand", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
      buf_temp-nodes.nhandle:set-attribute("brand", buf_temp-ef.car-brand).
  end.

end procedure. /* command_set_writebrand */


procedure command_get_writebrand :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .

define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.

end procedure. /* command_get_writebrand */

procedure command_set_writelimit :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .

define variable v-ii as integer no-undo .
define variable v-wl-handle as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf_temp-ef for temp-ef.
do
on error undo, return error
:
  find first buf_temp-ef where
            buf_temp-ef.d-card = p-d-card.
  create buf_temp-nodes.
  create x-noderef buf_temp-nodes.nhandle.
  assign
  buf_temp-nodes.nname = "WriteLimit".
  p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteLimit", "ELEMENT").
  p-hroot:append-child(buf_temp-nodes.nhandle).
  buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
  buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  v-wl-handle = buf_temp-nodes.nhandle.
  do v-ii = 1 to 4:
    find first buf_temp-ef1 where
              buf_temp-ef1.d-card = p-d-card
            and buf_temp-ef1.petrol-num = v-ii no-error.
    create buf_temp-nodes.
    create x-noderef buf_temp-nodes.nhandle.
    p-hdoc:create-node(buf_temp-nodes.nhandle, "Limit", "ELEMENT").
    v-wl-handle:append-child(buf_temp-nodes.nhandle).
    buf_temp-nodes.nhandle:set-attribute("n", string(v-ii)).
    if available buf_temp-ef1 then do:
      buf_temp-nodes.nhandle:set-attribute("product", string(buf_temp-ef1.ef-petrol-code)).
      buf_temp-nodes.nhandle:set-attribute("total", (if buf_temp-ef1.unlim-common-limit
                                                     then "unlimited"
                                                     else string(buf_temp-ef1.common-limit))).
      buf_temp-nodes.nhandle:set-attribute("month", (if buf_temp-ef1.unlim-month-limit
                                                     then "unlimited"
                                                     else string(buf_temp-ef1.month-limit))).
      buf_temp-nodes.nhandle:set-attribute("day", (if buf_temp-ef1.unlim-day-limit
                                                   then "unlimied"
                                                   else string(buf_temp-ef1.day-limit))).
      buf_temp-nodes.nhandle:set-attribute("doze", string(buf_temp-ef1.standard-dose)).
    end.
    else do:
      buf_temp-nodes.nhandle:set-attribute("product", string(0)).
      buf_temp-nodes.nhandle:set-attribute("total", string(0)).
      buf_temp-nodes.nhandle:set-attribute("month", string(0)).
      buf_temp-nodes.nhandle:set-attribute("day", string(0)).
      buf_temp-nodes.nhandle:set-attribute("doze", string(0)).
    end.
  end.
end.

end procedure. /* command_set_writelimit */

procedure command_get_writelimit :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .

define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
  do
  on error undo, return error
  :
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.

end procedure. /* command_get_writelimit */


procedure command_set_readlimit :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .

define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "ReadLimit".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "ReadLimit", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token",  p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  end.

end procedure. /* command_set_readlimit */

procedure command_get_readlimit :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .

define variable v-ii as integer no-undo .
define variable hattr as handle no-undo.
define variable htext as handle no-undo .
define variable v-hdoc as handle no-undo .
define variable helem as handle no-undo .
define variable v-error-mess as character no-undo .
define variable v-error-code as character no-undo .
define variable v-petrol-num as integer no-undo init ?.
define variable v-ef-petrol-code as integer no-undo .
define variable v-total as decimal no-undo .
define variable v-total-chr as character no-undo .
define variable v-month as decimal no-undo .
define variable v-month-chr as character no-undo .
define variable v-day as decimal no-undo .
define variable v-day-chr as character no-undo .
define variable v-doze as decimal no-undo .
define variable v-gds-code as integer no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef .
define buffer buf2_temp-ef1 for vidtemp-ef1 .
define buffer buf_prop-ref for ub.prop-ref.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "format") then do:
      assign
      buf2_temp-ef.ef-format = integer(hattr:node-value) no-error.
    end.
    /*надо спуститься вниз и разобрать тэг ReadLimit*/
    create x-noderef htext.
    do v-ii = 1 to p-hnode:num-children:
      P-hnode:get-child(htext, v-ii).
      if htext:subtype = "element"
      and htext:name = "Limit" then do:
        assign
        v-ef-petrol-code = ?
        v-total = ?
        v-month = ?
        v-day = ?
        v-doze = ?
        v-gds-code = ?
        .
        if htext:get-attribute-node(hattr, "n") then do:
          v-petrol-num = integer(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "product") then do:
          v-ef-petrol-code = integer(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "total") then do:
          v-total-chr = hattr:node-value.
          if v-total-chr = "unlimited" then do:
            v-total = ?.
          end.
          else do:
            v-total = decimal(hattr:node-value) no-error.
          end.
        end.
        if htext:get-attribute-node(hattr, "month") then do:
          v-month-chr = hattr:node-value.
          if v-month-chr = "unlimited" then do:
            v-month = ?.
          end.
          else do:
            v-month = decimal(hattr:node-value) no-error.
          end.
        end.
        if htext:get-attribute-node(hattr, "day") then do:
          v-day-chr = hattr:node-value.
          if v-day-chr = "unlimited" then do:
            v-day = ?.
          end.
          else do:
            v-day = decimal(hattr:node-value) no-error.
          end.
        end.
        if htext:get-attribute-node(hattr, "doze") then do:
          v-doze = decimal(hattr:node-value) no-error.
        end.
        if v-petrol-num <> ?
        and v-petrol-num <=4
        and v-petrol-num > 0
        then do:
           v-gds-code =  get-petrol-gds-code (v-ef-petrol-code) no-error.
           assign
           buffer buf2_temp-ef:handle:buffer-field( substitute( "petrol-code-&1", v-petrol-num)):buffer-value = v-gds-code.
           if v-ef-petrol-code > 0 then do:
            find first buf2_temp-ef1 where
                        buf2_temp-ef1.d-card = p-d-card
                  and buf2_temp-ef1.ef-petrol-code = v-ef-petrol-code no-error.
            if not available buf2_temp-ef1 then do:
              /*надо найти чему этом v-ef-petrol-code соответствует у нас*/
              find first buf_prop-ref no-lock where
                        buf_prop-ref.dtm-code = {&dc-prop_easyfuel-limits}
                    and buf_prop-ref.sum-id = propreft-petrol-to-String(v-gds-code) no-error.
              create buf2_temp-ef1.
              assign
              buf2_temp-ef1.d-card = p-d-card
              buf2_temp-ef1.petrol-code = (if v-gds-code = ? then - v-ef-petrol-code else v-gds-code)
              buf2_temp-ef1.sum-id   = (if available buf_prop-ref then buf_prop-ref.sum-id else "")
              buf2_temp-ef1.dt-code  = (if available buf_prop-ref then buf_prop-ref.dt-code else  - v-gds-code)
              buf2_temp-ef1.dtm-code  = {&dc-prop_easyfuel-limits}
              buf2_temp-ef1.ef-petrol-code  = v-ef-petrol-code
              .
            end.
            assign
            buf2_temp-ef1.common-limit  = v-total
            buf2_temp-ef1.month-limit  = v-month
            buf2_temp-ef1.day-limit  = v-day
            buf2_temp-ef1.standard-dose = v-doze
            buf2_temp-ef1.petrol-num  = v-petrol-num
            .
          end.
        end.
      end.
    end.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      assign
      v-error-code = hattr:node-value no-error.
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    if v-error-code = "99"
    or v-error-code = ""
    or v-error-code = ?
    then return "".
    return v-error-mess.
  end.

end procedure. /* command_get_readlimit */

procedure command_set_writecons :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .

define variable v-ii as integer no-undo .
define variable v-wl-handle as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf_temp-ef for temp-ef.
do
on error undo, return error
:
  find first buf_temp-ef where
            buf_temp-ef.d-card = p-d-card.
  create buf_temp-nodes.
  create x-noderef buf_temp-nodes.nhandle.
  assign
  buf_temp-nodes.nname = "WriteCons".
  p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteCons", "ELEMENT").
  p-hroot:append-child(buf_temp-nodes.nhandle).
  buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
  buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  v-wl-handle = buf_temp-nodes.nhandle.
  do v-ii = 1 to 4:
    find first buf_temp-ef1 where
              buf_temp-ef1.d-card = p-d-card
            and buf_temp-ef1.petrol-num = v-ii no-error.
    create buf_temp-nodes.
    create x-noderef buf_temp-nodes.nhandle.
    p-hdoc:create-node(buf_temp-nodes.nhandle, "Consumption", "ELEMENT").
    v-wl-handle:append-child(buf_temp-nodes.nhandle).
    buf_temp-nodes.nhandle:set-attribute("n", string(v-ii)).
    if available buf_temp-ef1 then do:
      buf_temp-nodes.nhandle:set-attribute("total", string(buf_temp-ef1.common-expense)).
      buf_temp-nodes.nhandle:set-attribute("month", string(buf_temp-ef1.month-expense)).
      buf_temp-nodes.nhandle:set-attribute("day", string(buf_temp-ef1.day-expense)).
      buf_temp-nodes.nhandle:set-attribute("date", string((if buf_temp-ef1.last-date = ?
                                                          then buf_temp-ef.valid-from
                                                          else buf_temp-ef1.last-date), "99.99.9999")).
    end.
    else do:
      buf_temp-nodes.nhandle:set-attribute("total", string(0)).
      buf_temp-nodes.nhandle:set-attribute("month", string(0)).
      buf_temp-nodes.nhandle:set-attribute("day", string(0)).
      buf_temp-nodes.nhandle:set-attribute("date", string(buf_temp-ef.valid-from, "99.99.9999")).
    end.
  end.
end.

end procedure. /* command_set_writecons */


procedure command_get_writecons :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .

define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.

end procedure. /* command_get_writecons */

procedure command_set_readcons :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .

define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "ReadCons".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "ReadCons", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token",  p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  end.

end procedure. /* command_set_readcons */

procedure command_get_readcons :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .

define variable v-ii as integer no-undo .
define variable hattr as handle no-undo.
define variable htext as handle no-undo .
define variable v-hdoc as handle no-undo .
define variable helem as handle no-undo .
define variable v-error-mess as character no-undo .
define variable v-error-code as character no-undo .
define variable v-petrol-num as integer no-undo init ?.
define variable v-total as decimal no-undo .
define variable v-month as decimal no-undo .
define variable v-day as decimal no-undo .
define variable v-last-date as date no-undo .
define variable v-last-time as integer no-undo .

define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef .
define buffer buf2_temp-ef1 for vidtemp-ef1 .
define buffer buf_prop-ref for ub.prop-ref.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "format") then do:
      assign
      buf2_temp-ef.ef-format = integer(hattr:node-value) no-error.
    end.
    /*надо спуститься вниз и разобрать тэг ReadCons*/
    create x-noderef htext.
    do v-ii = 1 to p-hnode:num-children:
      P-hnode:get-child(htext, v-ii).
      if htext:subtype = "element"
      and htext:name = "Consumption" then do:
        assign
        v-total = ?
        v-month = ?
        v-day = ?
        v-last-date = ?
        .
        if htext:get-attribute-node(hattr, "n") then do:
          v-petrol-num = integer(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "total") then do:
          v-total = decimal(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "month") then do:
          v-month = decimal(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "day") then do:
          v-day = decimal(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "date") then do:
          assign
          v-last-date = date(hattr:node-value) no-error.
        end.
        if v-petrol-num <> ?
        and v-petrol-num <=4
        and v-petrol-num > 0
        then do:
          find first buf2_temp-ef1 where
                      buf2_temp-ef1.d-card = p-d-card
                and buf2_temp-ef1.petrol-num = v-petrol-num no-error.
          if available buf2_temp-ef1 then do:
            assign
            buf2_temp-ef1.common-expense  = v-total
            buf2_temp-ef1.month-expense  = v-month
            buf2_temp-ef1.day-expense  = v-day
            buf2_temp-ef1.last-date  = v-last-date
            .
          end.
        end.
      end.
    end.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      assign
      v-error-code = hattr:node-value no-error.
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    if v-error-code = "99"
    or v-error-code = ""
    or v-error-code = ?
    then return "".
    return v-error-mess.
  end.

end procedure. /* command_get_cons */


procedure command_set_writehistory :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .

define variable v-ii as integer no-undo .
define variable v-wl-handle as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-efh for temp-efh.
define buffer buf_temp-ef for temp-ef.

do
on error undo, return error
:
  find first buf_temp-ef where
            buf_temp-ef.d-card = p-d-card.
  create buf_temp-nodes.
  create x-noderef buf_temp-nodes.nhandle.
  assign
  buf_temp-nodes.nname = "WriteHistory".
  p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteHistory", "ELEMENT").
  p-hroot:append-child(buf_temp-nodes.nhandle).
  buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
  buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  v-wl-handle = buf_temp-nodes.nhandle.
  do v-ii = 1 to 6:
    find first buf_temp-efh where
              buf_temp-efh.d-card = p-d-card
            and buf_temp-efh.seq = v-ii no-error.
    create buf_temp-nodes.
    create x-noderef buf_temp-nodes.nhandle.
    p-hdoc:create-node(buf_temp-nodes.nhandle, "History", "ELEMENT").
    v-wl-handle:append-child(buf_temp-nodes.nhandle).
    buf_temp-nodes.nhandle:set-attribute("n", string(v-ii)).
    if available buf_temp-efh then do:
      buf_temp-nodes.nhandle:set-attribute("seq", string(buf_temp-efh.seq)).
      buf_temp-nodes.nhandle:set-attribute("date", string(buf_temp-efh.date_, "99.99.9999")).
      buf_temp-nodes.nhandle:set-attribute("time", string(buf_temp-efh.time_, "hh:mm:ss")).
      buf_temp-nodes.nhandle:set-attribute("azs", string(buf_temp-efh.obj-code)).
      buf_temp-nodes.nhandle:set-attribute("product", string(buf_temp-efh.ef-petrol-code)).
      buf_temp-nodes.nhandle:set-attribute("fpoint", string(buf_temp-efh.pump-code)).
      buf_temp-nodes.nhandle:set-attribute("nozzle", string(buf_temp-efh.nozzle-code)).
      buf_temp-nodes.nhandle:set-attribute("volume", string(buf_temp-efh.doc-qnty-pl100)).
      buf_temp-nodes.nhandle:set-attribute("cassa", string(buf_temp-efh.cash-desk)).
      buf_temp-nodes.nhandle:set-attribute("doc", string(buf_temp-efh.chk-num)).
    end.
    else do:
      buf_temp-nodes.nhandle:set-attribute("seq", string(0)).
      buf_temp-nodes.nhandle:set-attribute("date", string(buf_temp-ef.valid-from, "99.99.9999")).
      buf_temp-nodes.nhandle:set-attribute("time", string(0, "hh:mm:ss")).
      buf_temp-nodes.nhandle:set-attribute("azs", string(0)).
      buf_temp-nodes.nhandle:set-attribute("product", string(0)).
      buf_temp-nodes.nhandle:set-attribute("fpoint", string(1)).
      buf_temp-nodes.nhandle:set-attribute("nozzle", string(1)).
      buf_temp-nodes.nhandle:set-attribute("volume", string(0)).
      buf_temp-nodes.nhandle:set-attribute("cassa", string(0)).
      buf_temp-nodes.nhandle:set-attribute("doc", string(0)).
    end.
  end.
end.

end procedure. /* command_set_writehistory */


procedure command_get_writehistory :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .

define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.

end procedure. /* command_get_writehistory */


procedure prepare-file-names :
define input-output parameter p-out-file as character no-undo .
define input-output parameter p-in-file as character no-undo .
define variable v-xml-file-base as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-xml-path as character no-undo .

do
on error undo, return error
:
  os-delete value(p-out-file).
  os-delete value(p-in-file).
  assign
  v-xml-file-base = substring( string( next-value( s-spool, {&db-name_schema}), '99999999999999999999'), 13, 8 )
  p-out-file = substitute("&1c.xml"
                          ,v-xml-file-base
                          )
  p-in-file = substitute("&1r.xml"
                          ,v-xml-file-base
                          )
  .

end.
end procedure. /* prepare-file-names */

procedure prepare-cmd-line :
define input parameter p-out-file as character no-undo .
define input parameter p-in-file as character no-undo .
define output parameter p-cmd-line as character no-undo .
define variable v-xml-file-base as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-xml-path as character no-undo .
define variable v-python-path as character no-undo .
define variable v-com-port as character no-undo .
define variable v-controller-no as character no-undo .
define variable glog as logical no-undo .

do
on error undo, return error
:
  run gbl/filename.p  (
                   input p-out-file
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error  .
  if error-status:error then do:
    undo, return error return-value .
  end.
  assign
  v-xml-path  = v-path.
  run gbl/filename.p  (
                   input "exe/vid/vid.pyc"
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  )  .

  run verify-ini-entry in this-procedure (
                                            INPUT  'python-path'
                                          ,INPUT  'easyfuel'
                                          ,INPUT substitute("в ini-файле отсутствует путь к подкаталогу установки PYTHON")
                                          ,INPUT yes
                                          ,output v-python-path) no-error .
  if error-status:error or v-python-path = ? then return error return-value .
  RUN verify-file in this-procedure
                                    ( v-python-path
                                    , substitute("Не найден каталог &1 параметр python-path, секция [easyfuel] ini-файла", v-python-path)
                                    , yes
                                    ,output glog) no-error.
  if error-status:error or not glog then return error return-value .

  run verify-ini-entry in this-procedure (
                                            INPUT  'com-port'
                                          ,INPUT  'easyfuel'
                                          ,INPUT substitute("в ini-файле отсутствует настройка COM-порта для устройтва персонализации МБ")
                                          ,INPUT yes
                                          ,output v-com-port) no-error .
  if error-status:error or v-com-port = ? then do:
    v-com-port = "COM1".
  end.

  run verify-ini-entry in this-procedure (
                                            INPUT  'controller-no'
                                          ,INPUT  'easyfuel'
                                          ,INPUT substitute("в ini-файле отсутствует настройка номера контролера для устройтва персонализации МБ")
                                          ,INPUT yes
                                          ,output v-controller-no) no-error .
  if error-status:error or v-controller-no = ? then do:
    v-controller-no = "1".
  end.


  p-cmd-line = substitute("&7\python.exe &6 &1 &2 &3 &4 &5"
                          ,v-com-port
                          ,v-controller-no
                          ,v-xml-path + {&slash-char} + p-out-file
                          ,v-xml-path + {&slash-char} + p-in-file
                          ,""
                          ,v-full-path
                          ,prepare-path(v-python-path)
                                                    ).

end.
end procedure. /* prepare-file-names */

/* $Workfile$ e n d */