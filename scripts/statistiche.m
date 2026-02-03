function statistiche(A, A_rec)
    %% Consideriamo solo la parte sopra la diagonale (essendo simmetrici)
    % Questo evita di contare ogni arco due volte.
    tri_A = triu(A, 1);
    tri_Rec = triu(A_rec, 1);
    
    %% Calcolo dei casi
    TP = sum(tri_A(:) == 1 & tri_Rec(:) == 1);
    FP = sum(tri_A(:) == 0 & tri_Rec(:) == 1);
    FN = sum(tri_A(:) == 1 & tri_Rec(:) == 0);
    TN = sum(tri_A(:) == 0 & tri_Rec(:) == 0);
    
    %% Calcolo percentuali e metriche
    tot_archi_reali = sum(tri_A(:));
    tot_archi_rec = sum(tri_Rec(:));
    
    % Accuratezza = Quante caselle della matrice ho indovinato in totale
    accuratezza = (TP+TN)/numel(tri_A)*100; % "numel" estituisce il numero di elementi n nell'array A
    precisione = TP/(TP+FP)*100; % Delle connessioni che sono state ricostruite, quante sono vere
    recupero = TP/(TP+FN)*100; % Quante connessioni vere ho trovato
    
    %% Stampa risultati
    fprintf('--- Risultati ricostruzione ---\n');
    fprintf('Archi reali: %d\n', tot_archi_reali);
    fprintf('Archi ricostruiti: %d\n', tot_archi_rec);
    fprintf('-------------------------------\n');
    fprintf('Falsi positivi: %d\n', FP);
    fprintf('Falsi negativi: %d\n', FN);
    fprintf('-------------------------------\n');
    fprintf('Accuratezza globale: %.2f%%\n', accuratezza);
    fprintf('Precisione: %.2f%%\n', precisione);
    fprintf('Archi veri trovati: %.2f%%\n', recupero);
end