/*не должен использоваться в load-rec.p*/
define {1} shared variable himp2Cd as handle no-undo.
&if defined(handle_only) = 0
&then
{ cmp/gds-list.i gds-list def "{1} shared" }
{ cmp/dc-list.i  dc-list  def " {1} shared "  }
define {1} shared temp-table dc-dis-card-mask no-undo like ub.dis-card-mask.
define {1} shared temp-table dc-dis-card-mask-attr no-undo like ub.dis-card-mask-attr.
{ cmp/dcp-list.i  dcp-list  def " {1} shared "  }
{ cmp/stpllist.i stpl-list  def " {1} shared "  }
{ cmp/pbc-list.i pbc-list def {1} }
{ cmp/bc-list.i bc-list def {1} }
{ cmp/gdsolist.i gdsolist def "{1} shared" }
{ str/defc-txn.i "{1} shared" }
{ str/defc-txr.i "{1} shared" }
{ str/pdf-list.i pdf-list def "{1} shared" }
{ str/defc-pay-list.i "{1} shared" }
{ str/defc-ext-classif.i "{1} shared" }
{ str/def-PromoAction-list.i "{1} shared" }
{ str/def-thbjattr-list.i "{1} shared" }           
define {1} shared var sendEMRC   as logical no-undo.
define {1} shared var settingUpd as logical no-undo.
define {1} shared var sendMarkType as logical no-undo.
define {1} shared var sendGisMt as logical no-undo.
&endif



