DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Дополнительный экран просмотра в учете (разбивки по договорам) ".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define  shared temp-table tt-title no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index purch-code is   primary unique purch-code
.
define  shared temp-table d-supp no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field supp-name  like ub.clients.obj-name
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp       is   primary unique supp-type supp-code purch-code
  index i2                                                 purch-code
.
define  shared temp-table d-supp-grp no-undo
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field purch-code like ub.parts.purch-code
  field grp-code   like ub.goods.grp-code
  field purch-name as   character
  field supp-name  like ub.clients.obj-name
  field grp-name   like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp       is   primary unique supp-type supp-code purch-code grp-code
  index i2                                                 purch-code
.
define  shared temp-table d-slt-vat no-undo
  field vat-pc  like ub.doc-line.vat-pc
  field slt-pc  like ub.doc-line.slt-pc
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt is   primary unique vat-pc slt-pc
.
define  shared temp-table d-slt-vat-cons no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.
define  shared temp-table d-slt-vat-cons-grp no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field grp-code      like ub.goods.grp-code
  field grp-name      like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.
define  shared temp-table d-supp-slts-vats-cons no-undo
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field supp-name  like ub.clients.obj-name
  field vat-pc     like ub.parts.vat-pc
  field slt-pc     like ub.parts.slt-pc
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index pi         is   primary   unique supp-type supp-code vat-pc slt-pc purch-code
.
define  shared temp-table d-slts-vats no-undo
  field vat-pc  like ub.parts.vat-pc
  field slt-pc  like ub.parts.slt-pc
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt is   primary unique vat-pc slt-pc
.
define  shared temp-table d-slts-vats-cons no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.
define  shared temp-table d-slts-vats-cons-grp no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field grp-name      like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.
define  shared temp-table tt-title-fin no-undo
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index purch-findoc  is   primary unique contract-code purch-code
.
define  shared temp-table d-supp-fin no-undo
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field supp-name     like ub.clients.obj-name
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp          is   primary unique contract-code supp-type supp-code purch-code
  index i2                                purch-code
.
define  shared temp-table d-supp-grp-fin no-undo
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field supp-name     like ub.clients.obj-name
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp          is   primary unique contract-code supp-type supp-code purch-code grp-code
  index i2                                purch-code
.
define  shared temp-table d-slt-vat-cons-fin no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.
define  shared temp-table d-slt-vat-cons-grp-fin no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field grp-code      like ub.goods.grp-code
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code grp-code
.
define  shared temp-table d-supp-slts-vats-cons-fin no-undo
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field supp-name     like ub.clients.obj-name
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index pi            is   primary unique contract-code supp-type supp-code vat-pc slt-pc purch-code
.
define  shared temp-table d-slts-vats-cons-fin no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.
define  shared temp-table d-slts-vats-cons-grp-fin no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code grp-code
.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
DEFINE VARIABLE v_road-tax-label AS CHARACTER NO-UNDO.
DEFINE BUTTON   Btn_Exit  LABEL "Вы&ход " SIZE-CHARS 10.00 BY 1.00 DEFAULT AUTO-GO.
DEFINE BUTTON b-help LABEL "Помо&щь" SIZE-CHARS 10.00 BY 1.00 DEFAULT.
DEFINE VARIABLE table-type AS INTEGER NO-UNDO VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
  "&Поставщики",          1,
  "&НДС и НП",            2,
  "Н&ДС и НП поставщика", 3,
  "Поставщики &и НДС-НП", 4,
  "Тип приобретени&я",    5  SIZE-CHARS 98.75 BY 1.00 INITIAL 1.
DEFINE QUERY b-supp                FOR d-supp-fin                SCROLLING.
DEFINE QUERY b-supp-grp            FOR d-supp-grp-fin            SCROLLING.
DEFINE QUERY b-supp-slts-vats-cons FOR d-supp-slts-vats-cons-fin SCROLLING.
DEFINE QUERY b-slts-vats-cons      FOR d-slts-vats-cons-fin      SCROLLING.
DEFINE QUERY b-slts-vats-cons-grp  FOR d-slts-vats-cons-grp-fin  SCROLLING.
DEFINE QUERY b-slt-vat-cons        FOR d-slt-vat-cons-fin        SCROLLING.
DEFINE QUERY b-slt-vat-cons-grp    FOR d-slt-vat-cons-grp-fin    SCROLLING.
DEFINE QUERY b-title               FOR tt-title-fin              SCROLLING.
DEFINE BROWSE b-supp QUERY b-supp DISPLAY
  d-supp-fin.contract-code COLUMN-LABEL "Договор"            FORMAT ">>>>>>>":U
  d-supp-fin.supp-name     COLUMN-LABEL "Поставщик"          FORMAT "x(20)":U                                        d-supp-fin.supp-type     COLUMN-LABEL "Тип"                                        d-supp-fin.supp-code     COLUMN-LABEL "Код"
  d-supp-fin.purch-name    COLUMN-LABEL "Тип приобр."        FORMAT "x(11)":U
  d-supp-fin.fact-qnty     COLUMN-LABEL "Факт. кол-во"                                        d-supp-fin.acc-base      COLUMN-LABEL "Учет. цены (вал)"                                        d-supp-fin.acc-rubl      COLUMN-LABEL "Учет. цены (руб)"                                        d-supp-fin.acc-vat-base  COLUMN-LABEL "НДС уч. цены (вал)"                                        d-supp-fin.acc-vat-rubl  COLUMN-LABEL "НДС уч. цены (руб)"                                        d-supp-fin.pay-base      COLUMN-LABEL "К оплате (вал)"                                        d-supp-fin.pay-rubl      COLUMN-LABEL "К оплате (руб)"                                        d-supp-fin.no-vat-base   COLUMN-LABEL "Без НДС (вал)"                                        d-supp-fin.no-vat-rubl   COLUMN-LABEL "Без НДС (руб)"                                        d-supp-fin.vat-base      COLUMN-LABEL "НДС (вал)"                                        d-supp-fin.vat-rubl      COLUMN-LABEL "НДС (руб)"                                        d-supp-fin.slt-base      COLUMN-LABEL "НП (вал)"                                        d-supp-fin.slt-rubl      COLUMN-LABEL "НП (руб)"                                        d-supp-fin.sale-base     COLUMN-LABEL "Продаж.цены"                                        d-supp-fin.ov-base       COLUMN-LABEL "Переоценка"                                        d-supp-fin.ov-vat        COLUMN-LABEL "НДС по переоценке"                                        d-supp-fin.road-tax                                        d-supp-fin.excise        COLUMN-LABEL "Акциз"
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "Поставщик-Тип приобретения".
DEFINE BROWSE b-supp-grp QUERY b-supp-grp DISPLAY
  d-supp-grp-fin.contract-code COLUMN-LABEL "Договор"            FORMAT ">>>>>>>":U
  d-supp-grp-fin.supp-name     COLUMN-LABEL "Поставщик"          FORMAT "x(20)":U                                        d-supp-grp-fin.supp-type     COLUMN-LABEL "Тип"                                        d-supp-grp-fin.supp-code     COLUMN-LABEL "Код"
  d-supp-grp-fin.purch-name    COLUMN-LABEL "Тип приобр."        FORMAT "x(11)":U
  d-supp-grp-fin.grp-name      COLUMN-LABEL "Группа товаров"     FORMAT "x(30)":U
  d-supp-grp-fin.fact-qnty     COLUMN-LABEL "Факт. кол-во"                                        d-supp-grp-fin.acc-base      COLUMN-LABEL "Учет. цены (вал)"                                        d-supp-grp-fin.acc-rubl      COLUMN-LABEL "Учет. цены (руб)"                                        d-supp-grp-fin.acc-vat-base  COLUMN-LABEL "НДС уч. цены (вал)"                                        d-supp-grp-fin.acc-vat-rubl  COLUMN-LABEL "НДС уч. цены (руб)"                                        d-supp-grp-fin.pay-base      COLUMN-LABEL "К оплате (вал)"                                        d-supp-grp-fin.pay-rubl      COLUMN-LABEL "К оплате (руб)"                                        d-supp-grp-fin.no-vat-base   COLUMN-LABEL "Без НДС (вал)"                                        d-supp-grp-fin.no-vat-rubl   COLUMN-LABEL "Без НДС (руб)"                                        d-supp-grp-fin.vat-base      COLUMN-LABEL "НДС (вал)"                                        d-supp-grp-fin.vat-rubl      COLUMN-LABEL "НДС (руб)"                                        d-supp-grp-fin.slt-base      COLUMN-LABEL "НП (вал)"                                        d-supp-grp-fin.slt-rubl      COLUMN-LABEL "НП (руб)"                                        d-supp-grp-fin.sale-base     COLUMN-LABEL "Продаж.цены"                                        d-supp-grp-fin.ov-base       COLUMN-LABEL "Переоценка"                                        d-supp-grp-fin.ov-vat        COLUMN-LABEL "НДС по переоценке"                                        d-supp-grp-fin.road-tax                                        d-supp-grp-fin.excise        COLUMN-LABEL "Акциз"
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "Поставщик-Тип приобретения-Группа товаров".
DEFINE BROWSE b-supp-slts-vats-cons QUERY b-supp-slts-vats-cons DISPLAY
  d-supp-slts-vats-cons-fin.contract-code COLUMN-LABEL "Договор"            FORMAT ">>>>>>>":U
  d-supp-slts-vats-cons-fin.supp-name     COLUMN-LABEL "Поставщик"          FORMAT "x(20)":U                                        d-supp-slts-vats-cons-fin.supp-type     COLUMN-LABEL "Тип"                                        d-supp-slts-vats-cons-fin.supp-code     COLUMN-LABEL "Код"
  d-supp-slts-vats-cons-fin.vat-pc        COLUMN-LABEL "НДС"                                        d-supp-slts-vats-cons-fin.slt-pc        COLUMN-LABEL "НП"
  d-supp-slts-vats-cons-fin.purch-name    COLUMN-LABEL "Тип приобр."        FORMAT "x(11)":U
  d-supp-slts-vats-cons-fin.fact-qnty     COLUMN-LABEL "Факт. кол-во"                                        d-supp-slts-vats-cons-fin.acc-base      COLUMN-LABEL "Учет. цены (вал)"                                        d-supp-slts-vats-cons-fin.acc-rubl      COLUMN-LABEL "Учет. цены (руб)"                                        d-supp-slts-vats-cons-fin.acc-vat-base  COLUMN-LABEL "НДС уч. цены (вал)"                                        d-supp-slts-vats-cons-fin.acc-vat-rubl  COLUMN-LABEL "НДС уч. цены (руб)"                                        d-supp-slts-vats-cons-fin.pay-base      COLUMN-LABEL "К оплате (вал)"                                        d-supp-slts-vats-cons-fin.pay-rubl      COLUMN-LABEL "К оплате (руб)"                                        d-supp-slts-vats-cons-fin.no-vat-base   COLUMN-LABEL "Без НДС (вал)"                                        d-supp-slts-vats-cons-fin.no-vat-rubl   COLUMN-LABEL "Без НДС (руб)"                                        d-supp-slts-vats-cons-fin.vat-base      COLUMN-LABEL "НДС (вал)"                                        d-supp-slts-vats-cons-fin.vat-rubl      COLUMN-LABEL "НДС (руб)"                                        d-supp-slts-vats-cons-fin.slt-base      COLUMN-LABEL "НП (вал)"                                        d-supp-slts-vats-cons-fin.slt-rubl      COLUMN-LABEL "НП (руб)"                                        d-supp-slts-vats-cons-fin.sale-base     COLUMN-LABEL "Продаж.цены"                                        d-supp-slts-vats-cons-fin.ov-base       COLUMN-LABEL "Переоценка"                                        d-supp-slts-vats-cons-fin.ov-vat        COLUMN-LABEL "НДС по переоценке"                                        d-supp-slts-vats-cons-fin.road-tax                                        d-supp-slts-vats-cons-fin.excise        COLUMN-LABEL "Акциз"
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 21.20
     TITLE "Поставщик-НДС поставщика-НП поставщика-Тип приобретения".
DEFINE BROWSE b-slts-vats-cons QUERY b-slts-vats-cons DISPLAY
  d-slts-vats-cons-fin.contract-code COLUMN-LABEL "Договор"            FORMAT ">>>>>>>":U
  d-slts-vats-cons-fin.vat-pc        COLUMN-LABEL "НДС"                                        d-slts-vats-cons-fin.slt-pc        COLUMN-LABEL "НП"
  d-slts-vats-cons-fin.purch-name    COLUMN-LABEL "Тип приобр."        FORMAT "x(11)":U
  d-slts-vats-cons-fin.fact-qnty     COLUMN-LABEL "Факт. кол-во"                                        d-slts-vats-cons-fin.acc-base      COLUMN-LABEL "Учет. цены (вал)"                                        d-slts-vats-cons-fin.acc-rubl      COLUMN-LABEL "Учет. цены (руб)"                                        d-slts-vats-cons-fin.acc-vat-base  COLUMN-LABEL "НДС уч. цены (вал)"                                        d-slts-vats-cons-fin.acc-vat-rubl  COLUMN-LABEL "НДС уч. цены (руб)"                                        d-slts-vats-cons-fin.pay-base      COLUMN-LABEL "К оплате (вал)"                                        d-slts-vats-cons-fin.pay-rubl      COLUMN-LABEL "К оплате (руб)"                                        d-slts-vats-cons-fin.no-vat-base   COLUMN-LABEL "Без НДС (вал)"                                        d-slts-vats-cons-fin.no-vat-rubl   COLUMN-LABEL "Без НДС (руб)"                                        d-slts-vats-cons-fin.vat-base      COLUMN-LABEL "НДС (вал)"                                        d-slts-vats-cons-fin.vat-rubl      COLUMN-LABEL "НДС (руб)"                                        d-slts-vats-cons-fin.slt-base      COLUMN-LABEL "НП (вал)"                                        d-slts-vats-cons-fin.slt-rubl      COLUMN-LABEL "НП (руб)"                                        d-slts-vats-cons-fin.sale-base     COLUMN-LABEL "Продаж.цены"                                        d-slts-vats-cons-fin.ov-base       COLUMN-LABEL "Переоценка"                                        d-slts-vats-cons-fin.ov-vat        COLUMN-LABEL "НДС по переоценке"                                        d-slts-vats-cons-fin.road-tax                                        d-slts-vats-cons-fin.excise        COLUMN-LABEL "Акциз"
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "НДС поставщика-НП поставщика-Тип приобретения".
DEFINE BROWSE b-slts-vats-cons-grp QUERY b-slts-vats-cons-grp DISPLAY
  d-slts-vats-cons-grp-fin.contract-code COLUMN-LABEL "Договор"            FORMAT ">>>>>>>":U
  d-slts-vats-cons-grp-fin.vat-pc        COLUMN-LABEL "НДС"                                        d-slts-vats-cons-grp-fin.slt-pc        COLUMN-LABEL "НП"
  d-slts-vats-cons-grp-fin.purch-name    COLUMN-LABEL "Тип приобр."        FORMAT "x(11)":U
  d-slts-vats-cons-grp-fin.grp-name      COLUMN-LABEL "Группа товаров"     FORMAT "x(30)":U
  d-slts-vats-cons-grp-fin.fact-qnty     COLUMN-LABEL "Факт. кол-во"                                        d-slts-vats-cons-grp-fin.acc-base      COLUMN-LABEL "Учет. цены (вал)"                                        d-slts-vats-cons-grp-fin.acc-rubl      COLUMN-LABEL "Учет. цены (руб)"                                        d-slts-vats-cons-grp-fin.acc-vat-base  COLUMN-LABEL "НДС уч. цены (вал)"                                        d-slts-vats-cons-grp-fin.acc-vat-rubl  COLUMN-LABEL "НДС уч. цены (руб)"                                        d-slts-vats-cons-grp-fin.pay-base      COLUMN-LABEL "К оплате (вал)"                                        d-slts-vats-cons-grp-fin.pay-rubl      COLUMN-LABEL "К оплате (руб)"                                        d-slts-vats-cons-grp-fin.no-vat-base   COLUMN-LABEL "Без НДС (вал)"                                        d-slts-vats-cons-grp-fin.no-vat-rubl   COLUMN-LABEL "Без НДС (руб)"                                        d-slts-vats-cons-grp-fin.vat-base      COLUMN-LABEL "НДС (вал)"                                        d-slts-vats-cons-grp-fin.vat-rubl      COLUMN-LABEL "НДС (руб)"                                        d-slts-vats-cons-grp-fin.slt-base      COLUMN-LABEL "НП (вал)"                                        d-slts-vats-cons-grp-fin.slt-rubl      COLUMN-LABEL "НП (руб)"                                        d-slts-vats-cons-grp-fin.sale-base     COLUMN-LABEL "Продаж.цены"                                        d-slts-vats-cons-grp-fin.ov-base       COLUMN-LABEL "Переоценка"                                        d-slts-vats-cons-grp-fin.ov-vat        COLUMN-LABEL "НДС по переоценке"                                        d-slts-vats-cons-grp-fin.road-tax                                        d-slts-vats-cons-grp-fin.excise        COLUMN-LABEL "Акциз"
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "НДС поставщика-НП поставщика-Тип приобретения-Группа товаров".
DEFINE BROWSE b-slt-vat-cons QUERY b-slt-vat-cons DISPLAY
  d-slt-vat-cons-fin.contract-code COLUMN-LABEL "Договор"            FORMAT ">>>>>>>":U
  d-slt-vat-cons-fin.vat-pc        COLUMN-LABEL "НДС"                                        d-slt-vat-cons-fin.slt-pc        COLUMN-LABEL "НП"
  d-slt-vat-cons-fin.purch-name    COLUMN-LABEL "Тип приобр."        FORMAT "x(11)":U
  d-slt-vat-cons-fin.fact-qnty     COLUMN-LABEL "Факт. кол-во"                                        d-slt-vat-cons-fin.acc-base      COLUMN-LABEL "Учет. цены (вал)"                                        d-slt-vat-cons-fin.acc-rubl      COLUMN-LABEL "Учет. цены (руб)"                                        d-slt-vat-cons-fin.acc-vat-base  COLUMN-LABEL "НДС уч. цены (вал)"                                        d-slt-vat-cons-fin.acc-vat-rubl  COLUMN-LABEL "НДС уч. цены (руб)"                                        d-slt-vat-cons-fin.pay-base      COLUMN-LABEL "К оплате (вал)"                                        d-slt-vat-cons-fin.pay-rubl      COLUMN-LABEL "К оплате (руб)"                                        d-slt-vat-cons-fin.no-vat-base   COLUMN-LABEL "Без НДС (вал)"                                        d-slt-vat-cons-fin.no-vat-rubl   COLUMN-LABEL "Без НДС (руб)"                                        d-slt-vat-cons-fin.vat-base      COLUMN-LABEL "НДС (вал)"                                        d-slt-vat-cons-fin.vat-rubl      COLUMN-LABEL "НДС (руб)"                                        d-slt-vat-cons-fin.slt-base      COLUMN-LABEL "НП (вал)"                                        d-slt-vat-cons-fin.slt-rubl      COLUMN-LABEL "НП (руб)"                                        d-slt-vat-cons-fin.sale-base     COLUMN-LABEL "Продаж.цены"                                        d-slt-vat-cons-fin.ov-base       COLUMN-LABEL "Переоценка"                                        d-slt-vat-cons-fin.ov-vat        COLUMN-LABEL "НДС по переоценке"                                        d-slt-vat-cons-fin.road-tax                                        d-slt-vat-cons-fin.excise        COLUMN-LABEL "Акциз"
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "НДС документа-НП документа-Тип приобретения".
DEFINE BROWSE b-slt-vat-cons-grp QUERY b-slt-vat-cons-grp DISPLAY
  d-slt-vat-cons-grp-fin.contract-code COLUMN-LABEL "Договор"            FORMAT ">>>>>>>":U
  d-slt-vat-cons-grp-fin.vat-pc        COLUMN-LABEL "НДС"                                        d-slt-vat-cons-grp-fin.slt-pc        COLUMN-LABEL "НП"
  d-slt-vat-cons-grp-fin.purch-name    COLUMN-LABEL "Тип приобр."        FORMAT "x(11)":U
  d-slt-vat-cons-grp-fin.grp-name      COLUMN-LABEL "Группа товаров"     FORMAT "x(30)":U
  d-slt-vat-cons-grp-fin.fact-qnty     COLUMN-LABEL "Факт. кол-во"                                        d-slt-vat-cons-grp-fin.acc-base      COLUMN-LABEL "Учет. цены (вал)"                                        d-slt-vat-cons-grp-fin.acc-rubl      COLUMN-LABEL "Учет. цены (руб)"                                        d-slt-vat-cons-grp-fin.acc-vat-base  COLUMN-LABEL "НДС уч. цены (вал)"                                        d-slt-vat-cons-grp-fin.acc-vat-rubl  COLUMN-LABEL "НДС уч. цены (руб)"                                        d-slt-vat-cons-grp-fin.pay-base      COLUMN-LABEL "К оплате (вал)"                                        d-slt-vat-cons-grp-fin.pay-rubl      COLUMN-LABEL "К оплате (руб)"                                        d-slt-vat-cons-grp-fin.no-vat-base   COLUMN-LABEL "Без НДС (вал)"                                        d-slt-vat-cons-grp-fin.no-vat-rubl   COLUMN-LABEL "Без НДС (руб)"                                        d-slt-vat-cons-grp-fin.vat-base      COLUMN-LABEL "НДС (вал)"                                        d-slt-vat-cons-grp-fin.vat-rubl      COLUMN-LABEL "НДС (руб)"                                        d-slt-vat-cons-grp-fin.slt-base      COLUMN-LABEL "НП (вал)"                                        d-slt-vat-cons-grp-fin.slt-rubl      COLUMN-LABEL "НП (руб)"                                        d-slt-vat-cons-grp-fin.sale-base     COLUMN-LABEL "Продаж.цены"                                        d-slt-vat-cons-grp-fin.ov-base       COLUMN-LABEL "Переоценка"                                        d-slt-vat-cons-grp-fin.ov-vat        COLUMN-LABEL "НДС по переоценке"                                        d-slt-vat-cons-grp-fin.road-tax                                        d-slt-vat-cons-grp-fin.excise        COLUMN-LABEL "Акциз"
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "НДС документа-НП документа-Тип приобретения-Группа товаров".
DEFINE BROWSE b-title QUERY b-title DISPLAY
  tt-title-fin.contract-code COLUMN-LABEL "Договор"            FORMAT ">>>>>>>":U
  tt-title-fin.purch-name    COLUMN-LABEL "Тип приобр."        FORMAT "x(11)":U
  tt-title-fin.fact-qnty     COLUMN-LABEL "Факт. кол-во"                                        tt-title-fin.acc-base      COLUMN-LABEL "Учет. цены (вал)"                                        tt-title-fin.acc-rubl      COLUMN-LABEL "Учет. цены (руб)"                                        tt-title-fin.acc-vat-base  COLUMN-LABEL "НДС уч. цены (вал)"                                        tt-title-fin.acc-vat-rubl  COLUMN-LABEL "НДС уч. цены (руб)"                                        tt-title-fin.pay-base      COLUMN-LABEL "К оплате (вал)"                                        tt-title-fin.pay-rubl      COLUMN-LABEL "К оплате (руб)"                                        tt-title-fin.no-vat-base   COLUMN-LABEL "Без НДС (вал)"                                        tt-title-fin.no-vat-rubl   COLUMN-LABEL "Без НДС (руб)"                                        tt-title-fin.vat-base      COLUMN-LABEL "НДС (вал)"                                        tt-title-fin.vat-rubl      COLUMN-LABEL "НДС (руб)"                                        tt-title-fin.slt-base      COLUMN-LABEL "НП (вал)"                                        tt-title-fin.slt-rubl      COLUMN-LABEL "НП (руб)"                                        tt-title-fin.sale-base     COLUMN-LABEL "Продаж.цены"                                        tt-title-fin.ov-base       COLUMN-LABEL "Переоценка"                                        tt-title-fin.ov-vat        COLUMN-LABEL "НДС по переоценке"                                        tt-title-fin.road-tax                                        tt-title-fin.excise        COLUMN-LABEL "Акциз"
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 21.20
     TITLE "Тип приобретения".
DEFINE FRAME fr-D-SplitByContract-8
    Btn_Exit            AT ROW  1.00 COL  1.00
  b-help           AT ROW  1.00 COL 11.00
  table-type            AT ROW  2.20 COL  1.00 NO-LABEL
  b-supp                AT ROW  3.40 COL  1.00
  b-supp-grp            AT ROW 14.10 COL  1.00
  b-slts-vats-cons      AT ROW  3.40 COL  1.00
  b-slts-vats-cons-grp  AT ROW 14.10 COL  1.00
  b-slt-vat-cons        AT ROW  3.40 COL  1.00
  b-slt-vat-cons-grp    AT ROW 14.10 COL  1.00
  b-title               AT ROW  3.40 COL  1.00
  b-supp-slts-vats-cons AT ROW  3.40 COL  1.00 SKIP( 0.12 )
WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
     TITLE "УЧЕТ (Договоры)" DEFAULT-BUTTON Btn_Exit.
ASSIGN FRAME fr-D-SplitByContract-8 :SCROLLABLE = NO.
ASSIGN b-supp                :NUM-LOCKED-COLUMNS IN FRAME fr-D-SplitByContract-8 = 5
       b-supp-grp            :NUM-LOCKED-COLUMNS IN FRAME fr-D-SplitByContract-8 = 5
       b-supp-slts-vats-cons :NUM-LOCKED-COLUMNS IN FRAME fr-D-SplitByContract-8 = 6
       b-slts-vats-cons      :NUM-LOCKED-COLUMNS IN FRAME fr-D-SplitByContract-8 = 4
       b-slts-vats-cons-grp  :NUM-LOCKED-COLUMNS IN FRAME fr-D-SplitByContract-8 = 4
       b-slt-vat-cons        :NUM-LOCKED-COLUMNS IN FRAME fr-D-SplitByContract-8 = 4
       b-slt-vat-cons-grp    :NUM-LOCKED-COLUMNS IN FRAME fr-D-SplitByContract-8 = 4
       b-title               :NUM-LOCKED-COLUMNS IN FRAME fr-D-SplitByContract-8 = 2.
ON WINDOW-CLOSE OF FRAME fr-D-SplitByContract-8 DO: APPLY "END-ERROR":U TO SELF. END.
ON VALUE-CHANGED OF table-type IN FRAME fr-D-SplitByContract-8 DO:
  ASSIGN table-type.
  CASE table-type :
    WHEN 1 THEN DO:
      DISABLE b-supp-slts-vats-cons b-slts-vats-cons b-slts-vats-cons-grp b-slt-vat-cons
              b-slt-vat-cons-grp    b-title
      WITH FRAME fr-D-SplitByContract-8.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slts-vats-cons      :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slts-vats-cons-grp  :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slt-vat-cons        :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slt-vat-cons-grp    :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-title               :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-supp                :VISIBLE IN FRAME fr-D-SplitByContract-8 = YES
              b-supp-grp            :VISIBLE IN FRAME fr-D-SplitByContract-8 = YES.
      ENABLE  b-supp b-supp-grp WITH FRAME fr-D-SplitByContract-8.
      OPEN QUERY b-supp                FOR EACH d-supp-fin.
      OPEN QUERY b-supp-grp            FOR EACH d-supp-grp-fin.
      APPLY "ENTRY":U TO b-supp IN FRAME fr-D-SplitByContract-8.
    END.
    WHEN 2 THEN DO:
      DISABLE b-supp-slts-vats-cons b-slts-vats-cons b-slts-vats-cons-grp b-supp
              b-supp-grp            b-title
      WITH FRAME fr-D-SplitByContract-8.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slts-vats-cons      :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slts-vats-cons-grp  :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slt-vat-cons        :VISIBLE IN FRAME fr-D-SplitByContract-8 = YES
              b-slt-vat-cons-grp    :VISIBLE IN FRAME fr-D-SplitByContract-8 = YES
              b-title               :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-supp                :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-supp-grp            :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO.
      ENABLE  b-slt-vat-cons b-slt-vat-cons-grp WITH FRAME fr-D-SplitByContract-8.
      OPEN QUERY b-slt-vat-cons        FOR EACH d-slt-vat-cons-fin.
      OPEN QUERY b-slt-vat-cons-grp    FOR EACH d-slt-vat-cons-grp-fin.
      APPLY "ENTRY":U TO b-slt-vat-cons IN FRAME fr-D-SplitByContract-8.
    END.
    WHEN 3 THEN DO:
      DISABLE b-supp-slts-vats-cons b-slt-vat-cons b-slt-vat-cons-grp b-supp
              b-supp-grp            b-title
      WITH FRAME fr-D-SplitByContract-8.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slts-vats-cons      :VISIBLE IN FRAME fr-D-SplitByContract-8 = YES
              b-slts-vats-cons-grp  :VISIBLE IN FRAME fr-D-SplitByContract-8 = YES
              b-slt-vat-cons        :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slt-vat-cons-grp    :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-title               :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-supp                :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-supp-grp            :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO.
      ENABLE  b-slts-vats-cons b-slts-vats-cons-grp WITH FRAME fr-D-SplitByContract-8.
      OPEN QUERY b-slts-vats-cons      FOR EACH d-slts-vats-cons-fin.
      OPEN QUERY b-slts-vats-cons-grp  FOR EACH d-slts-vats-cons-grp-fin.
      APPLY "ENTRY":U TO b-slts-vats-cons IN FRAME fr-D-SplitByContract-8.
    END.
    WHEN 4 THEN DO:
      DISABLE b-slt-vat-cons   b-slt-vat-cons-grp   b-supp b-supp-grp b-title
              b-slts-vats-cons b-slts-vats-cons-grp
      WITH FRAME fr-D-SplitByContract-8.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME fr-D-SplitByContract-8 = YES
              b-slts-vats-cons      :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slts-vats-cons-grp  :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slt-vat-cons        :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slt-vat-cons-grp    :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-title               :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-supp                :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-supp-grp            :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO.
      ENABLE  b-supp-slts-vats-cons WITH FRAME fr-D-SplitByContract-8.
      OPEN QUERY b-supp-slts-vats-cons FOR EACH d-supp-slts-vats-cons-fin.
      APPLY "ENTRY":U TO b-supp-slts-vats-cons IN FRAME fr-D-SplitByContract-8.
    END.
    WHEN 5 THEN DO:
      DISABLE b-slt-vat-cons   b-slt-vat-cons-grp   b-supp b-supp-grp
              b-slts-vats-cons b-slts-vats-cons-grp b-supp-slts-vats-cons
      WITH FRAME fr-D-SplitByContract-8.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slts-vats-cons      :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slts-vats-cons-grp  :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slt-vat-cons        :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-slt-vat-cons-grp    :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-title               :VISIBLE IN FRAME fr-D-SplitByContract-8 = YES
              b-supp                :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO
              b-supp-grp            :VISIBLE IN FRAME fr-D-SplitByContract-8 = NO.
      ENABLE  b-title WITH FRAME fr-D-SplitByContract-8.
      OPEN QUERY b-title               FOR EACH tt-title-fin.
      APPLY "ENTRY":U TO b-title IN FRAME fr-D-SplitByContract-8.
    END.
  END CASE.
END.
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame fr-D-SplitByContract-8 anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame fr-D-SplitByContract-8. END.
  return no-apply.
end.
IF VALID-HANDLE( ACTIVE-WINDOW ) AND FRAME fr-D-SplitByContract-8 :PARENT = ? THEN FRAME fr-D-SplitByContract-8 :PARENT = ACTIVE-WINDOW.
IF CURRENT-WINDOW :WINDOW-STATE = WINDOW-MINIMIZED THEN DO: CURRENT-WINDOW :WINDOW-STATE = WINDOW-NORMAL. END.
ON WINDOW-CLOSE OF FRAME fr-D-SplitByContract-8 DO: APPLY "END-ERROR":U TO SELF. END.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame fr-D-SplitByContract-8
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame fr-D-SplitByContract-8
do:
  apply "help":u to frame fr-D-SplitByContract-8 .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame fr-D-SplitByContract-8:width - 0.3
                fh            = frame fr-D-SplitByContract-8:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block :
  RUN tax-name IN THIS-PROCEDURE ( INPUT 'rdt':U, OUTPUT v_road-tax-label ) NO-ERROR.
  ASSIGN d-slts-vats-cons-fin.road-tax      :LABEL IN BROWSE b-slts-vats-cons      = v_road-tax-label
         d-slts-vats-cons-grp-fin.road-tax  :LABEL IN BROWSE b-slts-vats-cons-grp  = v_road-tax-label
         d-supp-slts-vats-cons-fin.road-tax :LABEL IN BROWSE b-supp-slts-vats-cons = v_road-tax-label
         d-slt-vat-cons-grp-fin.road-tax    :LABEL IN BROWSE b-slt-vat-cons-grp    = v_road-tax-label
         d-slt-vat-cons-fin.road-tax        :LABEL IN BROWSE b-slt-vat-cons        = v_road-tax-label
         tt-title-fin.road-tax              :LABEL IN BROWSE b-title               = v_road-tax-label
         d-supp-fin.road-tax                :LABEL IN BROWSE b-supp                = v_road-tax-label
         d-supp-grp-fin.road-tax            :LABEL IN BROWSE b-supp-grp            = v_road-tax-label.
  DISPLAY                      table-type WITH FRAME fr-D-SplitByContract-8.
  ENABLE  Btn_Exit b-help table-type WITH FRAME fr-D-SplitByContract-8.
  APPLY   "VALUE-CHANGED":U TO table-type   IN FRAME fr-D-SplitByContract-8.
  WAIT-FOR GO OF FRAME fr-D-SplitByContract-8.
END.
HIDE FRAME fr-D-SplitByContract-8 NO-PAUSE.
