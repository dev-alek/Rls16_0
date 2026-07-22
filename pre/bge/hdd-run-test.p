block-level on error undo, throw.
define input parameter p-ip     as character no-undo .
define input parameter p-tms    as character no-undo .
define input parameter p-code   as character no-undo .
define variable log-exit          as logical    no-undo .
define variable curl-path         as character  no-undo .
define variable v-post-file-name  as character  no-undo .
define variable v-response-file-name  as character  no-undo .
define variable v-cmd-file-name   as character  no-undo .
define variable v-command         as character  no-undo .
define variable v-out-str         as character  no-undo .
define variable v-pid-list        as character  no-undo .
define variable v-time-str        as character  no-undo .
define variable v-del-file        as character  no-undo .
define variable v-parsesub        as character  no-undo .
define variable hDoc              as handle     no-undo .
define variable hRoot             as handle     no-undo .
define variable good              as logical    no-undo .
define temp-table HddTest no-undo
  field db-num      as integer
  field id          as int64
  field namepc      as character
  field hddModule   as character
  field testStatus  as character
  field hddFilling  as integer
  field hddName     as character
  field hddSerial   as character
  index i1 as unique
    hddSerial hddModule
.
define temp-table hddAttributes no-undo
  field name_       as character
  field value_      as integer
  field thresh      as integer
  field type_       as character
  field raw_value   as integer
  field hddModule   as character
  field hddSerial   as character
  index i1 as unique
    hddSerial hddModule name_
.
assign
  curl-path = search("exe/curl.exe")
.
v-post-file-name = "hdd-test-req.xml" .
v-out-str = substitute ("<?xml version='1.0' encoding='windows-1251'?><data type='REQUEST'><HddTest ctrl='READ' tms = '&1' code = '&2'></HddTest><Count>100</Count></data>", p-tms, p-code) .
output to value (v-post-file-name) .
put unformatted v-out-str skip .
output close .
v-response-file-name = "hdd-test-result.xml" .
v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-post-file-name
                        , p-ip
                        , v-response-file-name) .
os-command value (v-command) .
run parse-xml (input v-response-file-name) .
procedure parse-xml :
  define input parameter p-file as character .
  CREATE X-DOCUMENT hDoc.
  CREATE X-NODEREF hRoot.
  hDoc:LOAD("file",p-file,FALSE).
  hDoc:GET-DOCUMENT-ELEMENT(hRoot).
  RUN GetChildren(hRoot, 1).
  DELETE OBJECT hDoc.
  DELETE OBJECT hRoot.
end procedure .
PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText AS HANDLE NO-UNDO.
define variable client as character no-undo.
CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .
REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    hNoderef:GET-CHILD(hText, 1) no-error .
    IF hNoderef:NAME = "HddTest"
    then do :
      create HddTest .
    end.
    IF hNoderef:NAME = "hddModule" then assign HddTest.hddModule = hText:node-value no-error .
    IF hNoderef:NAME = "testStatus" then assign HddTest.testStatus = hText:node-value no-error .
    IF hNoderef:NAME = "hddFilling" then assign HddTest.hddFilling = integer(hText:node-value) no-error .
    IF hNoderef:NAME = "hddName" then assign HddTest.hddName = hText:node-value no-error .
    IF hNoderef:NAME = "hddSerial" then assign HddTest.hddSerial = hText:node-value no-error .
    IF hNoderef:NAME = "hddAttributes"
    then do :
      create hddAttributes .
      assign
        hddAttributes.hddModule   = HddTest.hddModule
        hddAttributes.hddSerial   = HddTest.hddSerial
      .
    end.
    IF hNoderef:NAME = "name" then assign hddAttributes.name_ = hText:node-value no-error .
    IF hNoderef:NAME = "value" then assign hddAttributes.value_ = integer(hText:node-value) no-error .
    IF hNoderef:NAME = "thresh" then assign hddAttributes.thresh = integer(hText:node-value) no-error .
    IF hNoderef:NAME = "type" then assign hddAttributes.type_ = hText:node-value no-error .
    IF hNoderef:NAME = "raw_value" then assign hddAttributes.raw_value = integer(hText:node-value) no-error .
    RUN GetChildren(hNoderef, (level + 1)).
END.
DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.
