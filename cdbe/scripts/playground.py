from __future__ import annotations

ns = NameSpace(ValueUUId.create("5effd624-7880-4ecb-b37a-42c37e6391e1"), "Test")

defs = Definitions()
t_A = defs.create_concept(ns, "A")
t_B = defs.create_concept(ns, "B")
t_CC = defs.create_club(ns, "CC")
defs.create_membership(t_CC, t_A)

print(defs.const().types())

defs_N = Definitions()
t_C = defs_N.create_concept(ns, "C")
t_CC_N = defs_N.create_club(ns, "CC")
defs_N.create_membership(t_CC_N, t_C)
t_CD_N = defs_N.create_club(ns, "CD")

defs.extend(defs_N.const())
print(t_CC.members())
print(t_CC_N.members())
print(defs.const().types())

c = defs.const().copy()
c.const().types()

m = ValueMap(TypeMap(Type.INT8, Type.STRING), {1: "One", 2: "Two"})

m.get(3,"default")

