
%% Valutazione della Ricostruzione    
function statistiche(A, A_rec)

    % 1. Consideriamo solo la parte sopra la diagonale (essendo simmetrici)
    % Questo evita di contare ogni arco due volte.
    tri_A = triu(A, 1);
    tri_Rec = triu(A_rec, 1);
    
    % 2. Calcolo dei casi
    TP = sum(tri_A(:) == 1 & tri_Rec(:) == 1);
    FP = sum(tri_A(:) == 0 & tri_Rec(:) == 1);
    FN = sum(tri_A(:) == 1 & tri_Rec(:) == 0);
    TN = sum(tri_A(:) == 0 & tri_Rec(:) == 0);
    
    % 3. Calcolo percentuali e metriche
    tot_archi_reali = sum(tri_A(:));
    tot_archi_rec = sum(tri_Rec(:));
    
    accuratezza = (TP + TN) / numel(tri_A) * 100;
    precisione = TP / (TP + FP) * 100; % Quanti dei trovati sono corretti?
    recupero = TP / (TP + FN) * 100;    % Quanti dei reali abbiamo trovato?
    
    %% Stampa Risultati
    fprintf('--- Risultati Ricostruzione ---\n');
    fprintf('Archi Reali: %d\n', tot_archi_reali);
    fprintf('Archi Ricostruiti: %d\n', tot_archi_rec);
    fprintf('-------------------------------\n');
    fprintf('Falsi Positivi (Archi Fantasma): %d\n', FP);
    fprintf('Falsi Negativi (Archi Persi):    %d\n', FN);
    fprintf('-------------------------------\n');
    fprintf('Accuratezza Globale:  %.2f%%\n', accuratezza);
    fprintf('Precisione:           %.2f%%\n', precisione);
    fprintf('Archi veri trovati:   %.2f%%\n', recupero);

end