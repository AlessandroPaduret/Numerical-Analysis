
clear;

[ A, t, U ] = genera_dati_diffusione(n_nodi=40,n_esperimenti=15,n_t=50);

%A_rec = solutore_1(U,t);
%A_rec = solutore_2(U,t);
%A_rec = solutore_sliding(U,t,window=10,step=5);
A_rec = solutore_vettorizzato(U,t);


statistiche(A, A_rec);

visualizza_dati(U, t, A, A_rec);