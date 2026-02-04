clear;

[ A, t, U ] = buildsyntheticdata(n_nodi=40,n_esperimenti=20,n_t=50);

% CAMBIARE IL NUMERO DI ESPERIMENTI SOPRA!
A_rec = solutore_1(U, t);
%A_rec = solutore_2(U, t);
%A_rec = solutore_sliding(U, t, window=2, step=1);
%A_rec = solutore_vettorizzato(U, t, soglia_rumore=1e-5);

statistiche(A, A_rec);

visualizza_dati(U, t, A, A_rec);