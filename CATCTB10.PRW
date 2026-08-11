#include 'protheus.ch'
/*
============================================================================================================
Programa..............: CATCTB10
Desenvolvedor.........: Francis O. /jMarcelino
Data Criacao..........: Novembro/ 2021
Descricao / Objetivo..:  
Solicitante/Modulo....: Catalent / Contabilidade
Release / Data........: v12.23.001  
Obs...................: Incluido nas LPs - CT5 - U_CATCTB10('500002VL')
===============================================================================================================
*/

User Function CATCTB10(LPNUM)

Local xContLP

Do CASE
    CASE LPNUM == "500002VL"        //  260 caracteres  campo valor 
        xContLP := IIF(ALLTRIM(SE1->E1_TIPO)="NCC" .OR. ALLTRIM(SE1->E1_TIPO)$"AB-/IR-/IS-/IN-" .OR. ;
        SUBS(SE1->E1_ORIGEM,1,4)="MATA" .OR. ALLTRIM(SED->ED_CREDIT)<>"" .OR. ALLTRIM(SE1->E1_FATURA)="NOTFAT" ;
        .OR. ALLTRIM(SE1->E1_NUMLIQ)<>"" .OR. SE1->E1_MULTNAT="1",0,SE1->E1_VLCRUZ)

    CASE LPNUM == "505002VL"        //  260 caracteres  campo valor
        xContLP := IIF(ALLTRIM(SE1->E1_TIPO)="NCC" .OR. ALLTRIM(SE1->E1_TIPO)$"AB-/IR-/IS-/IN-" .OR. ;
        SUBS(SE1->E1_ORIGEM,1,4)="MATA" .OR. ALLTRIM(SED->ED_CREDIT)<>"" .OR. ALLTRIM(SE1->E1_FATURA)="NOTFAT" ;
        .OR. ALLTRIM(SE1->E1_NUMLIQ)<>"" .OR. SE1->E1_MULTNAT="1",0,SE1->E1_VLCRUZ) 

    CASE LPNUM == "510001VL"        //  383 caracteres  campo valor
        xContLP := IIF(SE2->E2_PREFIXO="EIC" .OR. ALLTRIM(SE2->E2_TIPO)="NDF" .OR. ;
        ALLTRIM(SE2->E2_TIPO)$"AB-/DIC" .OR. SE2->E2_MULTNAT="1" .OR. ALLTRIM(SED->ED_CREDIT)<>"" .OR. ;
        SUBS(SE2->E2_ORIGEM,1,4)="MATA" .OR. ALLTRIM(SE2->E2_FATURA)="NOTFAT" .OR. ;
        ALLTRIM(SE2->E2_NUMLIQ)<>"" .OR. ALLTRIM(SE2->E2_ORIGEM)$"FINA376/FINA378/FINA381" .OR. ;
        SE2->E2_STATUS="D",0,SE2->(E2_VLCRUZ+E2_IRRF+E2_INSS+E2_ISS))

    CASE LPNUM == "515001VL"        //  383 caracteres  campo valor
        xContLP := IIF(SE2->E2_PREFIXO="EIC" .OR. ALLTRIM(SE2->E2_TIPO)="NDF" .OR. ;
        ALLTRIM(SE2->E2_TIPO)$"AB-/DIC" .OR. SE2->E2_MULTNAT="1" .OR. ALLTRIM(SED->ED_CREDIT)<>"" .OR. ;
        SUBS(SE2->E2_ORIGEM,1,4)="MATA" .OR. ALLTRIM(SE2->E2_FATURA)="NOTFAT" .OR. ;
        ALLTRIM(SE2->E2_NUMLIQ)<>"" .OR. ALLTRIM(SE2->E2_ORIGEM)$"FINA376/FINA378/FINA381" .OR. ;
        SE2->E2_STATUS="D",0,SE2->(E2_VLCRUZ+E2_IRRF+E2_INSS+E2_ISS))   

    CASE LPNUM == "530001HS"        //  279 caracteres  campo histórico
        xContLP := LEFT("PAGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+SE2->E2_PARCELA+" "+;
        IIF(ALLTRIM(SE2->E2_PREFIXO)="ICM","REF "+;
        ALLTRIM(GetAdvFVal("SF6","F6_DOC",SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM,5,"")),"")+;
        IIF(SUBS(SE2->E2_HIST,1,2)="P:",SUBS(SE2->E2_HIST,1,14)+" ","")+SA2->A2_NREDUZ,40)

    CASE LPNUM == "530004DB"        //  263 caracteres  campo conta débito
        xContLP := IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE5->E5_NATUREZ,1,""))<>"",;
        GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE5->E5_NATUREZ,1,""),;
        IIF(SUBS(SA2->A2_CONTA,1,1)<>"2","2120101",SA2->A2_CONTA))

    CASE LPNUM == "530024DB"        //  268 caracteres  campo conta débito
        xContLP := IIF(ALLTRIM(SE2->E2_TIPO)=="PA" .OR. ALLTRIM(SE2->E2_TIPO)="NDF",;
        TABELA("XC","BXFATD"),IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(SED->ED_CREDIT)<>"",SED->ED_CREDIT,;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531001CR"        //  287 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ALLTRIM(SED->ED_CREDIT)<>"",;
        SED->ED_CREDIT,;
        IIF(SUBS(GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""),1,1)<>"2",;
        "2120101",GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531001HS"        //  346 caracteres  campo histórico
        xContLP := LEFT("EST PAGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+SE2->E2_PARCELA+" "+;
        IIF(ALLTRIM(SE2->E2_PREFIXO)="ICM",;
        "REF "+ALLTRIM(GetAdvFVal("SF6","F6_DOC",SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM,5,"")),"")+;
        IIF(SUBS(SE2->E2_HIST,1,2)="P:",;
        SUBS(SE2->E2_HIST,1,14)+" ","")+GetAdvFVal("SA2","A2_NREDUZ",xFilial("SA2")+;
        SE5->E5_CLIFOR+SE5->E5_LOJA,1,""),40)                                                                                                        

    CASE LPNUM == "531004CR"        //  282 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE5->E5_NATUREZ,1,""))<>"",;
        GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE5->E5_NATUREZ,1,""),;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""))

    CASE LPNUM == "531005DB"        //  268 caracteres  campo conta débito
        xContLP := IIF(ALLTRIM(SE2->E2_TIPO)=="PA" .OR. ALLTRIM(SE2->E2_TIPO)="NDF",TABELA("XC","JUROSC"),;
        IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ALLTRIM(SED->ED_CREDIT)<>"",;
        SED->ED_CREDIT,GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531006DB"        //  268 caracteres  campo conta débito
        xContLP := IIF(ALLTRIM(SE2->E2_TIPO)=="PA" .OR. ALLTRIM(SE2->E2_TIPO)="NDF",;
        TABELA("XC","MULTAC"),IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(SED->ED_CREDIT)<>"",SED->ED_CREDIT,;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""))) 

    CASE LPNUM == "531007CR"        // 268 caracteres   campo conta crédito 
        xContLP := IIF(ALLTRIM(SE2->E2_TIPO)=="PA" .OR. ALLTRIM(SE2->E2_TIPO)="NDF",;
        TABELA("XC","DESCOD"),IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(SED->ED_CREDIT)<>"",SED->ED_CREDIT,;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531011CR"        //  287 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ALLTRIM(SED->ED_CREDIT)<>"",;
        SED->ED_CREDIT,IIF(SUBS(GetAdvFVal("SA2","A2_CONTA",;
        xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""),1,1)<>"2","2120101",;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531012CR"        //  287 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ALLTRIM(SED->ED_CREDIT)<>"",;
        SED->ED_CREDIT,IIF(SUBS(GetAdvFVal("SA2","A2_CONTA",;
        xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""),1,1)<>"2",;
        "2120101",GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531013CR"        //  287 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ALLTRIM(SED->ED_CREDIT)<>"",;
        SED->ED_CREDIT,IIF(SUBS(GetAdvFVal("SA2","A2_CONTA",;
        xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""),1,1)<>"2","2120101",;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531015CR"        //  287 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(SED->ED_CREDIT)<>"",SED->ED_CREDIT,;
        IIF(SUBS(GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""),1,1)<>"2",;
        "2120101",GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531017CR"        //  287 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(SED->ED_CREDIT)<>"",SED->ED_CREDIT,;
        IIF(SUBS(GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""),1,1)<>"2",;
        "2120101",GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531021CR"        //  268 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_TIPO)=="PA" .OR. ALLTRIM(SE2->E2_TIPO)="NDF",TABELA("XC","BXDACD"),;
        IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ALLTRIM(SED->ED_CREDIT)<>"",;
        SED->ED_CREDIT,GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531022CR"        //  268 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_TIPO)=="PA" .OR. ALLTRIM(SE2->E2_TIPO)="NDF",TABELA("XC","BXDEVD"),;
        IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ALLTRIM(SED->ED_CREDIT)<>"",SED->ED_CREDIT,;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "531024CR"        //  268 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE2->E2_TIPO)=="PA" .OR. ALLTRIM(SE2->E2_TIPO)="NDF",;
        TABELA("XC","BXFATD"),;
        IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ALLTRIM(SED->ED_CREDIT)<>"",;
        SED->ED_CREDIT,GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,"")))

    CASE LPNUM == "532001HS"        //  279 caracteres  campo histórico
        xContLP := LEFT("PAGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+SE2->E2_PARCELA+" "+;
        IIF(ALLTRIM(SE2->E2_PREFIXO)="ICM","REF "+;
        ALLTRIM(GetAdvFVal("SF6","F6_DOC",SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM,5,"")),"")+;
        IIF(SUBS(SE2->E2_HIST,1,2)="P:",SUBS(SE2->E2_HIST,1,14)+" ","")+SA2->A2_NREDUZ,40)

    CASE LPNUM == "588005CR"        //  358 caracteres  campo conta crédito
        xContLP := IIF(SUBS(GetAdvFVal("SED","ED_CONTA",xFilial("SED")+GetAdvFVal("SE1","E1_NATUREZ",;
        xFilial("SE1")+SUBS(SE5->E5_DOCUMEN,1,17)+SE5->E5_FORNADT+SE5->E5_LOJAADT,1,""),1,""),1,1)="2",;
        GetAdvFVal("SED","ED_CONTA",xFilial("SED")+GetAdvFVal("SE1","E1_NATUREZ",xFilial("SE1")+;
        SUBS(SE5->E5_DOCUMEN,1,17)+SE5->E5_FORNADT+SE5->E5_LOJAADT,1,""),1,""),TABELA("XC","ADTOSC"))

    CASE LPNUM == "589001CR"        //  288 caracteres  campo conta crédito
        xContLP := IIF(SUBS(SE5->E5_DOCUMEN,18,6)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE2->E2_NATUREZ,1,""))<>"",;
        GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE2->E2_NATUREZ,1,""),;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_FORNADT+SE5->E5_LOJAADT,1,"")) 

    CASE LPNUM == "589002CR"        //  281 caracteres  campo conta crédito
        xContLP := IIF(ALLTRIM(SE5->E5_CLIFOR)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE5->E5_NATUREZ,1,""))<>"",;
        GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE5->E5_NATUREZ,1,""),;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""))

    CASE LPNUM == "589006DB"        //  272 caracteres  campo conta débito
        xContLP := IIF(SUBS(GetAdvFVal("SED","ED_CONTA",xFilial("SED")+;
        GetAdvFVal("SE2","E2_NATUREZ",xFilial("SE2")+SE5->E5_DOCUMEN,1,""),1,""),1,1)="1",;
        GetAdvFVal("SED","ED_CONTA",xFilial("SED")+GetAdvFVal("SE2","E2_NATUREZ",xFilial("SE2")+;
        SE5->E5_DOCUMEN,1,""),1,""),TABELA("XC","ADTOSD"))

    CASE LPNUM == "589008DB"        //  272 caracteres  campo conta débito
        xContLP := IIF(SUBS(GetAdvFVal("SED","ED_CONTA",xFilial("SED")+;
        GetAdvFVal("SE2","E2_NATUREZ",xFilial("SE2")+SE5->E5_DOCUMEN,1,""),1,""),1,1)="1",;
        GetAdvFVal("SED","ED_CONTA",xFilial("SED")+;
        GetAdvFVal("SE2","E2_NATUREZ",xFilial("SE2")+SE5->E5_DOCUMEN,1,""),1,""),TABELA("XC","ADTOSD"))

    CASE LPNUM == "590001HS"        //  306 caracteres  campo histórico
        xContLP := LEFT("PAGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+SE2->E2_PARCELA+" "+;
        IIF(ALLTRIM(SE2->E2_PREFIXO)="ICM","REF "+;
        ALLTRIM(GetAdvFVal("SF6","F6_DOC",SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM,5,"")),"")+;
        IIF(SUBS(SE2->E2_HIST,1,2)="P:",SUBS(SE2->E2_HIST,1,14)+" ","")+" CH "+SE5->E5_NUMCHEQ+" "+;
        SA2->A2_NREDUZ,40)

    CASE LPNUM == "594001DB"        //  410 caracteres  campo conta débito
        xContLP := IIF(ALLTRIM(SE5->E5_TIPO)="RA",;
        IIF(SUBS(GetAdvFVal("SED","ED_CONTA",xFilial("SED")+SE5->E5_NATUREZ,1,""),1,1)="2",;
        GetAdvFVal("SED","ED_CONTA",xFilial("SED")+SE5->E5_NATUREZ,1,""),;
        TABELA("XC","ADTOSC")),IIF(SE5->E5_TIPO="NCC",;
        TABELA("XC","DEVOLC"),;
        IIF(ALLTRIM(SE2->E2_FORNECE)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ALLTRIM(SED->ED_CREDIT)<>"",SED->ED_CREDIT,;
        IIF(SUBS(SA2->A2_CONTA,1,1)<>"2","2120101",SA2->A2_CONTA))))

    CASE LPNUM == "596005DB"        //  358 caracteres  campo conta débito
        xContLP := IIF(SUBS(GetAdvFVal("SED","ED_CONTA",xFilial("SED")+;
        GetAdvFVal("SE1","E1_NATUREZ",xFilial("SE1")+;
        SUBS(SE5->E5_DOCUMEN,1,17)+SE5->E5_FORNADT+SE5->E5_LOJAADT,1,""),1,""),1,1)="2",;
        GetAdvFVal("SED","ED_CONTA",xFilial("SED")+;
        GetAdvFVal("SE1","E1_NATUREZ",xFilial("SE1")+;
        SUBS(SE5->E5_DOCUMEN,1,17)+SE5->E5_FORNADT+SE5->E5_LOJAADT,1,""),1,""),TABELA("XC","ADTOSC"))

    CASE LPNUM == "597001DB"        //  288 caracteres  campo conta débito
        xContLP := IIF(SUBS(SE5->E5_DOCUMEN,18,6)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE2->E2_NATUREZ,1,""))<>"",;
        GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE2->E2_NATUREZ,1,""),;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_FORNADT+SE5->E5_LOJAADT,1,""))

    CASE LPNUM == "597002DB"        //  281 caracteres  campo conta débito
        xContLP := IIF(ALLTRIM(SE5->E5_CLIFOR)$"UNIAO/ESTADO/MUNIC/INPS" .OR. ;
        ALLTRIM(GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE5->E5_NATUREZ,1,""))<>"",;
        GetAdvFVal("SED","ED_CREDIT",xFilial("SED")+SE5->E5_NATUREZ,1,""),;
        GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,1,""))

    CASE LPNUM == "597006CR"        //  272 caracteres  campo conta crédito
        xContLP := IIF(SUBS(GetAdvFVal("SED","ED_CONTA",xFilial("SED")+;
        GetAdvFVal("SE2","E2_NATUREZ",xFilial("SE2")+SE5->E5_DOCUMEN,1,""),1,""),1,1)="1",;
        GetAdvFVal("SED","ED_CONTA",xFilial("SED")+GetAdvFVal("SE2","E2_NATUREZ",xFilial("SE2")+;
        SE5->E5_DOCUMEN,1,""),1,""),TABELA("XC","ADTOSD"))

    CASE LPNUM == "597008CR"        //  272 caracteres  campo conta crédito
        xContLP := IIF(SUBS(GetAdvFVal("SED","ED_CONTA",xFilial("SED")+;
        GetAdvFVal("SE2","E2_NATUREZ",xFilial("SE2")+SE5->E5_DOCUMEN,1,""),1,""),1,1)="1",;
        GetAdvFVal("SED","ED_CONTA",xFilial("SED")+;
        GetAdvFVal("SE2","E2_NATUREZ",xFilial("SE2")+SE5->E5_DOCUMEN,1,""),1,""),TABELA("XC","ADTOSD"))

    CASE LPNUM == "610001CR"        //  256 caracteres  campo conta crédito
        xContLP := IIF(SUBS(SD2->D2_CF,2,3)="922",TABELA("XC","VDFUTC"),IIF(SUBS(SD2->D2_CF,2,3)="551",;
        TABELA("XC","VDAATF"),IIF(SA1->A1_EST="EX","31102","31101")+IIF(SUBS(SD2->D2_CF,2,3)="949","05",;
        SUBS(GetAdvFVal("SBM","BM_XCTREC",xFilial("SBM")+SB1->B1_GRUPO,1,""),6,2))))


    CASE LPNUM == "610001VL"        //  264 caracteres  campo valor
        xContLP := IIF(SD2->D2_TIPO$"DB",0,IIF(SF4->F4_DUPLIC="S",IIF(SD2->D2_TIPO="P",SD2->D2_TOTAL,;
        IIF(SD2->D2_TIPO="I",SD2->D2_ICMSRET,SD2->(D2_TOTAL+D2_VALIPI+D2_VALFRE+D2_SEGURO+D2_DESPESA+;
        IIF(SF4->F4_CREDST="4" .OR. SF4->F4_INCSOL$"AND",0,D2_ICMSRET)+D2_VALPS3+D2_VALCF3))),0))

    CASE LPNUM == "610033VL"        //  292 caracteres  campo valor
        xContLP := IIF(SD2->D2_TIPO="D",0,IIF(SF4->F4_DUPLIC="N",IIF(SF4->F4_PODER3="N",;
        IIF(SUBS(SD2->D2_CF,2,3)$"151/152/208/209/408/409/552/557/602",0,IIF(SF4->F4_LFICM="T" .OR. ;
        SUBS(SD2->D2_CF,2,3)$"111/112/113/114/116/117/118/119" .OR. ;
        (SF4->F4_LFICM$"OI" .AND. SF4->F4_BASEICM<>0),SD2->D2_VALICM,0)),0),0))

    CASE LPNUM == "630001DB"        //  256 caracteres  campo conta débito
        xContLP := IIF(SUBS(SD2->D2_CF,2,3)="922",TABELA("XC","VDFUTC"),IIF(SUBS(SD2->D2_CF,2,3)="551",;
        TABELA("XC","VDAATF"),IIF(SA1->A1_EST="EX","31102","31101")+;
        IIF(SUBS(SD2->D2_CF,2,3)="949","05",;
        SUBS(GetAdvFVal("SBM","BM_XCTREC",xFilial("SBM")+SB1->B1_GRUPO,1,""),6,2))))

    CASE LPNUM == "630001VL"        //  264 caracteres  campo valor
        xContLP := IIF(SD2->D2_TIPO$"DB",0,IIF(SF4->F4_DUPLIC="S",IIF(SD2->D2_TIPO="P",SD2->D2_TOTAL,;
        IIF(SD2->D2_TIPO="I",SD2->D2_ICMSRET,SD2->(D2_TOTAL+D2_VALIPI+D2_VALFRE+D2_SEGURO+D2_DESPESA+;
        IIF(SF4->F4_CREDST="4" .OR. SF4->F4_INCSOL$"AND",0,D2_ICMSRET)+D2_VALPS3+D2_VALCF3))),0)) 

    CASE LPNUM == "630033VL"        //  292 caracteres  campo valor
        xContLP := IIF(SD2->D2_TIPO="D",0,IIF(SF4->F4_DUPLIC="N",IIF(SF4->F4_PODER3="N",;
        IIF(SUBS(SD2->D2_CF,2,3)$"151/152/208/209/408/409/552/557/602",0,;
        IIF(SF4->F4_LFICM="T" .OR. SUBS(SD2->D2_CF,2,3)$"111/112/113/114/116/117/118/119" .OR. ;
        (SF4->F4_LFICM$"OI" .AND. SF4->F4_BASEICM<>0),SD2->D2_VALICM,0)),0),0))

    CASE LPNUM == "640033VL"        //  267 caracteres  campo valor
        xContLP := IIF(SUBS(SD1->D1_CF,1,1)="3",0,IIF(SF4->F4_DUPLIC="N",IIF(SF4->F4_PODER3="N",;
        IIF(SUBS(SD1->D1_CF,2,3)$"151/152/208/209/408/409/552/557/602",0,IIF(SF4->F4_LFICM="T" .OR. ;
        (SF4->F4_LFICM$"OI" .AND. SF4->F4_BASEICM<>0 .AND. SF4->F4_CONSUMO<>"S"),SD1->D1_VALICM,0)),0),0))

    CASE LPNUM == "650002DB"        //  436 caracteres  campo conta débito
        xContLP := IIF(SF4->F4_ESTOQUE="S" .AND. !SUBS(SD1->D1_CF,2,3)$"556/407",;
        GetAdvFVal("SBM","BM_XCTEST",xFilial("SBM")+SB1->B1_GRUPO,1,""),;
        IIF(SUBS(SD1->D1_CLVL,1,2)="RD","1170101",;
        IIF(SUBS(SB1->B1_CONTA,1,3)="212" .AND. SUBS(SA2->A2_CONTA,1,1)="5",SA2->A2_CONTA,;
        IIF(SUBS(SD1->D1_CONTA,1,3)$"133",;
        TABELA("XC","ADTATF"),;
        IIF((ALLTRIM(SB1->B1_CONTA)="" .OR. SUBS(SB1->B1_CONTA,1,3)="461") .AND. SD1->D1_TIPO="C",;
        TABELA("XC","ADTIMP"),SB1->B1_CONTA)))))

    CASE LPNUM == "650006VL"        //  291 caracteres  campo valor
        xContLP := IIF(SD1->D1_TIPO="D",0,IIF(SF4->F4_DUPLIC="S" .OR. SUBS(SD1->D1_CF,1,1)="3",;
        IIF(SF4->F4_LFICM="T" .OR. (SF4->F4_LFICM$"OI" .AND. ((SF4->F4_BASEICM<>0 .AND. SF4->F4_CONSUMO<>"S") ;
        .OR. (SF4->F4_CREDICM="S" .AND. SA2->A2_SIMPNAC="1"))),SD1->D1_VALICM,0),;
        IIF(SD1->D1_TIPO="I",SD1->D1_VALICM,0)))   

    CASE LPNUM == "650017VL"        //  296 caracteres  campo valor
        xContLP := IIF(SD1->D1_TIPO="D",0,IIF(SD1->D1_TIPO$"IP" .AND. SUBS(SD1->D1_CF,1,1)<>"3",;
        IIF(SUBS(SD1->D1_CF,2,3)$"151/152/208/209/408/409/552/557",0,IIF(SF4->F4_LFIPI="T",SD1->D1_TOTAL,;
        IIF(SF4->F4_LFICM="T" .OR. (SF4->F4_LFICM$"OI" .AND. SF4->F4_BASEICM<>0 .AND. SF4->F4_CONSUMO<>"S"),;
        SD1->D1_TOTAL,0))),0)) 

    CASE LPNUM == "650033CR"        //  276 caracteres  campo conta crédito
        xContLP := IIF(SUBS(SD1->D1_CF,2,3)$"116/117/118",TABELA("XC","VDFUTD"),;
        IIF(SUBS(SD1->D1_CF,2,3)$"352/353",IIF(SF4->F4_ESTOQUE="S",;
        GetAdvFVal("SBM","BM_XCTEST",xFilial("SBM")+SB1->B1_GRUPO,1,""),;
        SB1->B1_CONTA),IIF(SUBS(SD1->D1_CF,2,3)$"111/113/917",TABELA("XC","ICMCSC"),TABELA("XC","ICMOUT"))))


    CASE LPNUM == "650033VL"        //  291 caracteres  campo valor
        xContLP := IIF(SD1->D1_TIPO$"DPI" .OR. SUBS(SD1->D1_CF,1,1)="3",0,;
        IIF(SF4->F4_DUPLIC="N",IIF(SF4->F4_PODER3="N",;
        IIF(SUBS(SD1->D1_CF,2,3)$"151/152/208/209/408/409/552/557/602/252/253",0,;
        IIF(SF4->F4_LFICM="T" .OR. (SF4->F4_LFICM$"OI" .AND. SF4->F4_BASEICM<>0 .AND. SF4->F4_CONSUMO<>"S"),;
        SD1->D1_VALICM,0)),0),0))

    CASE LPNUM == "650102VL"        //  272 caracteres  campo valor
        xContLP := IIF(SUBS(SD1->D1_CF,1,1)$"3" .AND. !SD1->D1_TIPO$"IP",IIF(SF4->F4_DUPLIC="N" .AND. ;
        (SF4->F4_ESTOQUE="S" .OR. SF4->F4_ATUATF="S" .OR. SUBS(SD1->D1_CF,2,3)$"933/551/556"),;
        IIF(SF1->F1_FOB_R > 0,(SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL,SD1->D1_TOTAL-SD1->D1_II),0),0)

    CASE LPNUM == "650112VL"        //  256 caracteres  campo valor
        xContLP := IIF(SUBS(SD1->D1_CF,1,1)$"3",IIF(SF4->F4_DUPLIC="N",;
        IIF(SF1->F1_FOB_R > 0,;
        IIF(((SD1->D1_TOTAL-SD1->D1_II)-((SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL))>0,;
        ABS((SD1->D1_TOTAL-SD1->D1_II)-((SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL)),0),0),0),0)

    CASE LPNUM == "650113VL"        //  256 caracteres  campo valor
        xContLP := IIF(SUBS(SD1->D1_CF,1,1)$"3",IIF(SF4->F4_DUPLIC="N",;
        IIF(SF1->F1_FOB_R > 0,;
        IIF(((SD1->D1_TOTAL-SD1->D1_II)-((SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL))<0,;
        ABS((SD1->D1_TOTAL-SD1->D1_II)-((SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL)),0),0),0),0)

    CASE LPNUM == "655002CR"        //  436 caracteres  campo conta crédito
        xContLP := IIF(SF4->F4_ESTOQUE="S" .AND. !SUBS(SD1->D1_CF,2,3)$"556/407",;
        GetAdvFVal("SBM","BM_XCTEST",xFilial("SBM")+SB1->B1_GRUPO,1,""),;
        IIF(SUBS(SD1->D1_CLVL,1,2)="RD","1170101",;
        IIF(SUBS(SB1->B1_CONTA,1,3)="212" .AND. SUBS(SA2->A2_CONTA,1,1)="5",SA2->A2_CONTA,;
        IIF(SUBS(SD1->D1_CONTA,1,3)$"133",TABELA("XC","ADTATF"),;
        IIF((ALLTRIM(SB1->B1_CONTA)="" .OR. SUBS(SB1->B1_CONTA,1,3)="461") .AND. SD1->D1_TIPO="C",;
        TABELA("XC","ADTIMP"),SB1->B1_CONTA)))))

    CASE LPNUM == "655006VL"        //  291 caracteres  campo valor
        xContLP := IIF(SD1->D1_TIPO="D",0,IIF(SF4->F4_DUPLIC="S" .OR. SUBS(SD1->D1_CF,1,1)="3",;
        IIF(SF4->F4_LFICM="T" .OR. (SF4->F4_LFICM$"OI" .AND. ((SF4->F4_BASEICM<>0 .AND. SF4->F4_CONSUMO<>"S") ;
        .OR. (SF4->F4_CREDICM="S" .AND. SA2->A2_SIMPNAC="1"))),SD1->D1_VALICM,0),;
        IIF(SD1->D1_TIPO="I",SD1->D1_VALICM,0)))

    CASE LPNUM == "655017DB"        //  271 caracteres  campo conta débito
        xContLP := IIF(SD1->D1_TIPO="I",IIF(SF4->F4_AJUSTE="S",TABELA("XC","ICMATF"),;
        IIF(SF4->F4_ESTOQUE="S",GetAdvFVal("SBM","BM_XCTEST",xFilial("SBM")+SB1->B1_GRUPO,1,""),;
        IIF(SUBS(SD1->D1_CLVL,1,2)="RD","1170101",SB1->B1_CONTA))),;
        IIF(SUBS(SA2->A2_CONTA,1,1)<>"2","2120101",SA2->A2_CONTA))

    CASE LPNUM == "655017VL"        //  296 caracteres  campo valor
        xContLP := IIF(SD1->D1_TIPO="D",0,IIF(SD1->D1_TIPO$"IP" .AND. SUBS(SD1->D1_CF,1,1)<>"3",;
        IIF(SUBS(SD1->D1_CF,2,3)$"151/152/208/209/408/409/552/557",0,;
        IIF(SF4->F4_LFIPI="T",SD1->D1_TOTAL,IIF(SF4->F4_LFICM="T" ;
        .OR. (SF4->F4_LFICM$"OI" .AND. SF4->F4_BASEICM<>0 .AND. SF4->F4_CONSUMO<>"S"),SD1->D1_TOTAL,0))),0))

    CASE LPNUM == "655033DB"        //  276 caracteres  campo conta débito
        xContLP := IIF(SUBS(SD1->D1_CF,2,3)$"116/117/118",TABELA("XC","VDFUTD"),;
        IIF(SUBS(SD1->D1_CF,2,3)$"352/353",IIF(SF4->F4_ESTOQUE="S",;
        GetAdvFVal("SBM","BM_XCTEST",xFilial("SBM")+SB1->B1_GRUPO,1,""),SB1->B1_CONTA),;
        IIF(SUBS(SD1->D1_CF,2,3)$"917",TABELA("XC","ICMCSC"),TABELA("XC","ICMOUT"))))

    CASE LPNUM == "655033VL"        //  291 caracteres  campo valor
        xContLP := IIF(SD1->D1_TIPO$"DPI" .OR. SUBS(SD1->D1_CF,1,1)="3",0,IIF(SF4->F4_DUPLIC="N",;
        IIF(SF4->F4_PODER3="N",IIF(SUBS(SD1->D1_CF,2,3)$"151/152/208/209/408/409/552/557/602/252/253",0,;
        IIF(SF4->F4_LFICM="T" .OR. (SF4->F4_LFICM$"OI" .AND. SF4->F4_BASEICM<>0 .AND. SF4->F4_CONSUMO<>"S"),;
        SD1->D1_VALICM,0)),0),0))

    CASE LPNUM == "655102VL"        //  272 caracteres  campo valor
        xContLP := IIF(SUBS(SD1->D1_CF,1,1)$"3" .AND. !SD1->D1_TIPO$"IP",;
        IIF(SF4->F4_DUPLIC="N" .AND. ;
        (SF4->F4_ESTOQUE="S" .OR. SF4->F4_ATUATF="S" .OR. SUBS(SD1->D1_CF,2,3)$"933/551/556"),;
        IIF(SF1->F1_FOB_R > 0,(SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL,SD1->D1_TOTAL-SD1->D1_II),0),0)

    CASE LPNUM == "655112VL"        //  256 caracteres  campo valor
        xContLP := IIF(SUBS(SD1->D1_CF,1,1)$"3",IIF(SF4->F4_DUPLIC="N",IIF(SF1->F1_FOB_R > 0,;
        IIF(((SD1->D1_TOTAL-SD1->D1_II)-((SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL))>0,;
        ABS((SD1->D1_TOTAL-SD1->D1_II)-((SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL)),0),0),0),0)

    CASE LPNUM == "655113VL"        //  256 caracteres  campo valor
        xContLP := IIF(SUBS(SD1->D1_CF,1,1)$"3",IIF(SF4->F4_DUPLIC="N",;
        IIF(SF1->F1_FOB_R > 0,;
        IIF(((SD1->D1_TOTAL-SD1->D1_II)-((SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL))<0,;
        ABS((SD1->D1_TOTAL-SD1->D1_II)-((SF1->F1_FOB_R / SF1->F1_VALMERC) * SD1->D1_TOTAL)),0),0),0),0)

ENDCASE

Return xContLP
