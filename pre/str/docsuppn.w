define input parameter parparentproc as handle no-undo.
define input parameter pardoc-rec as recid no-undo.
define new shared temp-table tt-title no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index purch-code is   primary unique purch-code
.
define new shared temp-table d-supp no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field supp-name  like ub.clients.obj-name
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp       is   primary unique supp-type supp-code purch-code
  index i2                                                 purch-code
.
define new shared temp-table d-supp-grp no-undo
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
define new shared temp-table d-slt-vat no-undo
  field vat-pc  like ub.doc-line.vat-pc
  field slt-pc  like ub.doc-line.slt-pc
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt is   primary unique vat-pc slt-pc
.
define new shared temp-table d-slt-vat-cons no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.
define new shared temp-table d-slt-vat-cons-grp no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field grp-code      like ub.goods.grp-code
  field grp-name      like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.
define new shared temp-table d-supp-slts-vats-cons no-undo
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
define new shared temp-table d-slts-vats no-undo
  field vat-pc  like ub.parts.vat-pc
  field slt-pc  like ub.parts.slt-pc
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt is   primary unique vat-pc slt-pc
.
define new shared temp-table d-slts-vats-cons no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.
define new shared temp-table d-slts-vats-cons-grp no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field grp-name      like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.
define new shared temp-table tt-title-fin no-undo
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index purch-findoc  is   primary unique contract-code purch-code
.
define new shared temp-table d-supp-fin no-undo
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
define new shared temp-table d-supp-grp-fin no-undo
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
define new shared temp-table d-slt-vat-cons-fin no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.
define new shared temp-table d-slt-vat-cons-grp-fin no-undo
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
define new shared temp-table d-supp-slts-vats-cons-fin no-undo
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
define new shared temp-table d-slts-vats-cons-fin no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.
define new shared temp-table d-slts-vats-cons-grp-fin no-undo
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable varr-b-value      as character no-undo.
define variable varroad-tax-label as character no-undo.
define variable varuse-table-list as character no-undo.
define variable varfin-table-list as character no-undo.
define variable varlog            as logical   no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b-value
  )  .
DEFINE BUTTON b-add
     LABEL "НДС &док-та"
     SIZE 12.5 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-cont
     LABEL "Договор&ы"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "Вы&ход"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sp
     LABEL "НДС &пост-ка"
     SIZE 12.5 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-rub AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE varacc-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Учет. цены"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varacc-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varexcise AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Акциз"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varno-vat-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Без НДС"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varno-vat-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varov-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Переоценка"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varov-vat AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "НДС по переоц"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varpay-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "К оплате"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varpay-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varroad-tax AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varsale-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Продажные цены"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varvat-acc-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "НДС уч.цены"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varvat-acc-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varvat-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "НДС"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varvat-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE inv-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Все строки", 1,
"&Излишки", 2,
"&Недостача", 3
     SIZE 35.25 BY 1 NO-UNDO.
DEFINE QUERY b-d-supp FOR
      d-supp SCROLLING.
DEFINE QUERY b-d-supp-grp FOR
      d-supp-grp SCROLLING.
DEFINE QUERY b-title FOR
      tt-title SCROLLING.
DEFINE BROWSE b-d-supp
  QUERY b-d-supp DISPLAY
      d-supp.supp-name format "x(20)"
d-supp.supp-type   format "x(3)"
d-supp.supp-code
d-supp.purch-name format "x(11)"
d-supp.fact-qnty
d-supp.acc-base
d-supp.acc-rubl
d-supp.acc-vat-base
d-supp.acc-vat-rubl
d-supp.pay-base
d-supp.pay-rubl
d-supp.no-vat-base
d-supp.no-vat-rubl
d-supp.vat-base
d-supp.vat-rubl
d-supp.slt-base
d-supp.slt-rubl
d-supp.sale-base
d-supp.ov-base
d-supp.ov-vat
d-supp.road-tax
d-supp.excise
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 5.33
         TITLE "Поставщик-Тип приобретения" ROW-HEIGHT-CHARS .58.
DEFINE BROWSE b-d-supp-grp
  QUERY b-d-supp-grp DISPLAY
      d-supp-grp.supp-name format "x(20)"
d-supp-grp.supp-type format "x(3)"
d-supp-grp.supp-code
d-supp-grp.purch-name format "x(7)"
d-supp-grp.grp-name format "x(30)"
d-supp-grp.fact-qnty
d-supp-grp.acc-base
d-supp-grp.acc-rubl
d-supp-grp.acc-vat-base
d-supp-grp.acc-vat-rubl
d-supp-grp.pay-base
d-supp-grp.pay-rubl
d-supp-grp.no-vat-base
d-supp-grp.no-vat-rubl
d-supp-grp.vat-base
d-supp-grp.vat-rubl
d-supp-grp.slt-base
d-supp-grp.slt-rubl
d-supp-grp.sale-base
d-supp-grp.ov-base
d-supp-grp.ov-vat
d-supp-grp.road-tax
d-supp-grp.excise
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 5.71
         TITLE "Поставщик-Тип приобретения-Группа товаров" ROW-HEIGHT-CHARS .58.
DEFINE BROWSE b-title
  QUERY b-title DISPLAY
      tt-title.purch-name format "x(11)"
tt-title.fact-qnty
tt-title.acc-base
tt-title.acc-rubl
tt-title.acc-vat-base
tt-title.acc-vat-rubl
tt-title.pay-base
tt-title.pay-rubl
tt-title.no-vat-base
tt-title.no-vat-rubl
tt-title.vat-base
tt-title.vat-rubl
tt-title.slt-base
tt-title.slt-rubl
tt-title.sale-base
tt-title.ov-base
tt-title.ov-vat
tt-title.road-tax
tt-title.excise
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 4.79
         TITLE "Тип приобретения" ROW-HEIGHT-CHARS .58.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 9
     b-sp AT ROW 1 COL 21.5
     b-cont AT ROW 1 COL 34
     inv-type AT ROW 1 COL 46 NO-LABEL
     b-help AT ROW 1 COL 91
     varacc-base AT ROW 2.79 COL 12 COLON-ALIGNED
     varacc-rubl AT ROW 2.79 COL 29.5 COLON-ALIGNED NO-LABEL
     varsale-base AT ROW 2.79 COL 81.25 COLON-ALIGNED
     varvat-acc-base AT ROW 3.71 COL 12 COLON-ALIGNED
     varvat-acc-rubl AT ROW 3.71 COL 29.5 COLON-ALIGNED NO-LABEL
     varov-base AT ROW 3.71 COL 81.25 COLON-ALIGNED
     varpay-base AT ROW 4.67 COL 12 COLON-ALIGNED
     varpay-rubl AT ROW 4.67 COL 29.5 COLON-ALIGNED NO-LABEL
     varov-vat AT ROW 4.67 COL 81.25 COLON-ALIGNED
     varno-vat-base AT ROW 5.67 COL 12 COLON-ALIGNED
     varno-vat-rubl AT ROW 5.67 COL 29.5 COLON-ALIGNED NO-LABEL
     varexcise AT ROW 5.67 COL 81.25 COLON-ALIGNED
     varvat-base AT ROW 6.67 COL 12 COLON-ALIGNED
     varvat-rubl AT ROW 6.67 COL 29.5 COLON-ALIGNED NO-LABEL
     varroad-tax AT ROW 6.67 COL 81.25 COLON-ALIGNED
     b-title AT ROW 7.83 COL 1
     b-d-supp AT ROW 12.67 COL 1
     b-d-supp-grp AT ROW 18.04 COL 1
     FILL-rub AT ROW 2.13 COL 29.88 COLON-ALIGNED NO-LABEL
     "Валюта" VIEW-AS TEXT
          SIZE 6.63 BY .67 AT ROW 2.13 COL 14.5
          BGCOLOR 3 FGCOLOR 15
     SPACE(78.24) SKIP(21.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Учет"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-d-supp:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 4.
ASSIGN
       b-d-supp-grp:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 5.
ASSIGN
       b-title:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  run str/docspadd.w .
END.
ON CHOOSE OF b-cont IN FRAME Dialog-Frame
DO:
  run str/calc-sup.p ( INPUT pardoc-rec, INPUT varfin-table-list, INPUT YES, INPUT ?, INPUT YES ) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO:
    MESSAGE "Ошибка в расчетах." VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  run str/docspcon.w .
  run str/calc-sup.p ( INPUT pardoc-rec, INPUT varuse-table-list, INPUT YES, INPUT ?, INPUT YES ) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO: MESSAGE "Ошибка в расчетах." VIEW-AS ALERT-BOX ERROR. END.
  OPEN QUERY b-d-supp FOR EACH d-supp.    OPEN QUERY b-d-supp-grp FOR EACH d-supp-grp.    OPEN QUERY b-title FOR EACH tt-title.
  RUN calc-title IN THIS-PROCEDURE.
  DISPLAY varacc-base
          varacc-rubl
          varvat-acc-base
          varvat-acc-rubl
          varno-vat-base
          varno-vat-rubl
          varov-base
          varov-vat
          varpay-base
          varpay-rubl
          varsale-base
          varvat-base
          varvat-rubl
          varroad-tax
          varexcise
  WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-sp IN FRAME Dialog-Frame
DO:
  run str/docspprt.w .
END.
ON VALUE-CHANGED OF inv-type IN FRAME Dialog-Frame
DO:
  for each d-supp :
    delete d-supp .
  end.
  for each d-slt-vat :
    delete d-slt-vat .
  end.
  for each d-slt-vat-cons :
    delete d-slt-vat-cons .
  end.
  assign inv-type.
  run str/calc-sup.p ( input pardoc-rec, input varuse-table-list, input yes, input inv-type, input yes ) no-error.
  if error-status :error then do: message "Ошибка в расчетах." view-as alert-box error. end.
  OPEN QUERY b-d-supp FOR EACH d-supp.    OPEN QUERY b-d-supp-grp FOR EACH d-supp-grp.    OPEN QUERY b-title FOR EACH tt-title.
  run calc-title in this-procedure.
  display varacc-base
          varacc-rubl
          varvat-acc-base
          varvat-acc-rubl
          varno-vat-base
          varno-vat-rubl
          varov-base
          varov-vat
          varpay-base
          varpay-rubl
          varsale-base
          varvat-base
          varvat-rubl
          varroad-tax
          varexcise
  with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame Dialog-Frame anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse b-title :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse b-d-supp :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse b-d-supp-grp :handle
  ) .
run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
assign varuse-table-list = "d-supp,d-slt-vat,d-slt-vat-cons,d-supp-grp,d-slt-vat-cons-grp,d-supp-slts-vats-cons,d-slts-vats,d-slts-vats-cons,d-slts-vats-cons-grp"
       varfin-table-list = "d-supp-fin,d-supp-grp-fin,d-supp-slts-vats-cons-fin,d-slt-vat-cons-fin,d-slt-vat-cons-grp-fin,d-slts-vats-cons-fin,d-slts-vats-cons-grp-fin,tt-title-fin".
assign
fill-rub = "Рубли"
tt-title.fact-qnty:label in browse b-title = "Факт. кол-во"
tt-title.purch-name:label in browse b-title  = "Тип приобр"
tt-title.acc-base:label  in browse b-title= "Учетные цены (вал)"
tt-title.acc-rubl:label in browse b-title = "Учетные цены (руб)"
tt-title.acc-vat-base:label  in browse b-title= "НДС уч.цены (вал)"
tt-title.acc-vat-rubl:label in browse b-title = "НДС уч. цены (руб)"
tt-title.no-vat-base:label in browse b-title = "Без НДС (вал)"
tt-title.no-vat-rubl:label in browse b-title = "Без НДС (руб)"
tt-title.vat-base:label in browse b-title = "НДС (вал)"
tt-title.vat-rubl:label in browse b-title = "НДС (руб)"
tt-title.slt-base:label in browse b-title = "НП (вал)"
tt-title.slt-rubl:label in browse b-title = "НП (руб)"
tt-title.pay-base:label in browse b-title = "К оплате (вал)"
tt-title.pay-rubl:label in browse b-title = "К оплате (руб)"
tt-title.sale-base:label in browse b-title = "Продаж. цены"
tt-title.ov-base:label in browse b-title = "Переоценка"
tt-title.ov-vat:label in browse b-title = "НДС по переоценке"
tt-title.excise:label  in browse b-title= "Акциз (руб)".
run tax-name (input 'rdt':U, output varroad-tax-label) no-error.
assign
  tt-title.road-tax:label in browse b-title = varroad-tax-label
  varroad-tax:label in frame Dialog-Frame = substring(varroad-tax-label,1,12).
assign
d-supp.supp-name:label in browse b-d-supp = "Поставщик"
d-supp.supp-type:label in browse b-d-supp = " "
d-supp.supp-code:label in browse b-d-supp = " "
d-supp.purch-name:label in browse b-d-supp = "Тип приобр"
d-supp.fact-qnty:label in browse b-d-supp = "Факт. кол-во"
d-supp.acc-base:label in browse b-d-supp = "Учет.цены (вал)"
d-supp.acc-rubl:label in browse b-d-supp = "Учет. цены (руб)"
d-supp.acc-vat-base:label  in browse b-d-supp= "НДС уч.цены (вал)"
d-supp.acc-vat-rubl:label in browse b-d-supp = "НДС уч. цены (руб)"
d-supp.sale-base:label in browse b-d-supp  = "Продаж.цены"
d-supp.ov-base:label in browse b-d-supp = "Переоценка"
d-supp.ov-vat:label in browse b-d-supp = "НДС по переоценке"
d-supp.pay-base:label in browse b-d-supp = "К оплате (вал)"
d-supp.pay-rubl:label in browse b-d-supp = "К оплате (руб)"
d-supp.no-vat-base:label in browse b-d-supp = "Без НДС (вал)"
d-supp.no-vat-rubl:label in browse b-d-supp = "Без НДС (руб)"
d-supp.vat-base:label in browse b-d-supp = "НДС (вал)"
d-supp.vat-rubl:label in browse b-d-supp = "НДС(руб)"
d-supp.slt-base:label in browse b-d-supp = "НП (вал)"
d-supp.slt-rubl:label in browse b-d-supp = "НП (руб)"
d-supp.excise:label in browse b-d-supp = "Акциз"
.
assign
  d-supp.road-tax:label in browse b-d-supp = varroad-tax-label.
assign
d-supp-grp.supp-name:label in browse b-d-supp-grp = "Поставщик"
d-supp-grp.supp-type:label in browse b-d-supp-grp = " "
d-supp-grp.supp-code:label in browse b-d-supp-grp = " "
d-supp-grp.purch-name:label in browse b-d-supp-grp = "Тип пр"
d-supp-grp.fact-qnty:label in browse b-d-supp-grp = "Факт. кол-во"
d-supp-grp.acc-base:label in browse b-d-supp-grp = "Учет.цены (вал)"
d-supp-grp.acc-rubl:label in browse b-d-supp-grp = "Учет. цены (руб)"
d-supp-grp.acc-vat-base:label  in browse b-d-supp-grp= "НДС уч.цены (вал)"
d-supp-grp.acc-vat-rubl:label in browse b-d-supp-grp = "НДС уч. цены (руб)"
d-supp-grp.sale-base:label in browse b-d-supp-grp  = "Продаж.цены"
d-supp-grp.ov-base:label in browse b-d-supp-grp = "Переоценка"
d-supp-grp.ov-vat:label in browse b-d-supp-grp = "НДС по переоценке"
d-supp-grp.pay-base:label in browse b-d-supp-grp = "К оплате (вал)"
d-supp-grp.pay-rubl:label in browse b-d-supp-grp = "К оплате (руб)"
d-supp-grp.no-vat-base:label in browse b-d-supp-grp = "Без НДС (вал)"
d-supp-grp.no-vat-rubl:label in browse b-d-supp-grp = "Без НДС (руб)"
d-supp-grp.vat-base:label in browse b-d-supp-grp = "НДС (вал)"
d-supp-grp.vat-rubl:label in browse b-d-supp-grp = "НДС(руб)"
d-supp-grp.slt-base:label in browse b-d-supp-grp = "НП (вал)"
d-supp-grp.slt-rubl:label in browse b-d-supp-grp = "НП (руб)"
d-supp-grp.excise:label in browse b-d-supp-grp = "Акциз"
d-supp-grp.grp-name:label in browse b-d-supp-grp = "Группа товаров"
.
assign
  d-supp-grp.road-tax:label in browse b-d-supp-grp = varroad-tax-label
.
assign
  d-supp-grp.supp-name:RESIZABLE in browse b-d-supp-grp = true
  d-supp-grp.supp-type:RESIZABLE in browse b-d-supp-grp = true
  d-supp-grp.purch-name:RESIZABLE in browse b-d-supp-grp = true
  d-supp-grp.grp-name:RESIZABLE in browse b-d-supp-grp = true
  d-supp.supp-name:RESIZABLE in browse b-d-supp = true
  d-supp.supp-type:RESIZABLE in browse b-d-supp = true
  d-supp.purch-name:RESIZABLE in browse b-d-supp = true
  tt-title.purch-name:RESIZABLE in browse b-title  = true
.
run str/calc-sup.p ( input pardoc-rec, input varuse-table-list, input yes, input ?, input yes ).
run calc-title in this-procedure.
  RUN enable_UI.
  find first trn-doc where recid(trn-doc) = pardoc-rec no-lock.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  trn-doc.host-code
    ,input  trn-doc.obj-type
    ,input  trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if not varlog then return error.
  if trn-doc.doc-type = 'инв':U then do:
      assign inv-type:sensitive = yes
                inv-type:visible = yes.
    end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE calc-title :
assign
varacc-base = 0.00
varacc-rubl = 0.00
varvat-acc-base = 0.00
varvat-acc-rubl = 0.00
varno-vat-base = 0.00
varno-vat-rubl = 0.00
varov-base = 0.00
varov-vat = 0.00
varpay-base = 0.00
varpay-rubl = 0.00
varsale-base = 0.00
varvat-base = 0.00
varvat-rubl = 0.00
varroad-tax = 0.00
varexcise = 0.00
.
define variable v-curr-r-b as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
for each tt-title:
assign
varacc-base = varacc-base + tt-title.acc-base
varacc-rubl = varacc-rubl + tt-title.acc-rubl
varvat-acc-base = varvat-acc-base + tt-title.acc-vat-base
varvat-acc-rubl = varvat-acc-rubl + tt-title.acc-vat-rubl
varno-vat-base = varno-vat-base + tt-title.no-vat-base
varno-vat-rubl = varno-vat-rubl + tt-title.no-vat-rubl
varov-base = varov-base + tt-title.ov-base
varov-vat = varov-vat + tt-title.ov-vat
varpay-base = varpay-base + tt-title.pay-base
varpay-rubl = varpay-rubl + tt-title.pay-rubl
varvat-base = varvat-base + tt-title.vat-base
varvat-rubl = varvat-rubl + tt-title.vat-rubl
varroad-tax = varroad-tax + tt-title.road-tax
varexcise = varexcise + tt-title.excise
.
if v-curr-r-b = 'base':U then
    assign
        varsale-base = varsale-base + tt-title.sale-base
        .
else
  assign
    varsale-base = varsale-base + tt-title.sale-rubl
    .
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varacc-base varacc-rubl varsale-base varvat-acc-base varvat-acc-rubl
          varov-base varpay-base varpay-rubl varov-vat varno-vat-base
          varno-vat-rubl varexcise varvat-base varvat-rubl varroad-tax FILL-rub
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-add b-sp b-cont b-help b-title b-d-supp b-d-supp-grp FILL-rub
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY b-d-supp FOR EACH d-supp.    OPEN QUERY b-d-supp-grp FOR EACH d-supp-grp.    OPEN QUERY b-title FOR EACH tt-title.
END PROCEDURE.
