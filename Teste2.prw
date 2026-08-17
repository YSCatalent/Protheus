#include 'protheus.ch'


user function TSTCATF()
//RpcSetEnv("01","001")
//DbSelectArea("SB1")
//SB1->(DbSetOrder(15))
local xret := formula("099")
return nil

user function TST01()
//RpcSetEnv("01","002")
DbSelectArea("ZEK")
DbSetOrder(1)

DbSelectArea("ZEk")
DbSetOrder(5)

return nil
//IIF(SF4->F4_ESTOQUE="S" .AND. !SUBS(SD1->D1_CF,2,3)$"556/407", GetAdvFVal("SBM","BM_XCTEST",xFilial("SBM")+SB1->B1_GRUPO,1,""), IIF(SUBS(SD1->D1_CLVL,1,2)="RD","1170101", IIF(SUBS(SB1->B1_CONTA,1,3)="212" .AND. SUBS(SA2->A2_CONTA,1,1)="5",SA2->A2_CONTA,IIF(SUBS(SD1->D1_CONTA,1,3)$"133",TABELA("XC","ADTATF"),IIF((ALLTRIM(SB1->B1_CONTA)="" .OR. SUBS(SB1->B1_CONTA,1,3)="461") .AND. SD1->D1_TIPO="C",TABELA("XC","ADTIMP"),SB1->B1_CONTA)))))
