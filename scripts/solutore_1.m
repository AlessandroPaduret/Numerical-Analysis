function [A_rec] = solutore_1(U, t, options)
    %% Parametri del problema
    arguments
        U (1,:) cell
        t (:,1) double
        options.soglia_rumore (1,1) double = 1e-8 % Ordine di grandezza del rumore
    end

    n_nodi = size(U{1},1);

    %% Calcolo traiettorie
    % Risolve Uc = I tramite SVD
    c = pinv(U{1}, options.soglia_rumore);
    
    % Calcoliamo le derivate (U{2}*c - U{1}*c) / dt
    % Nota: U{1}*c = I per come è definita c
    dt = t(2) - t(1);
    L = (U{2} * c - eye(n_nodi)) / dt;

    %% Costruzione grafo
    
    % Preallochiamo la memoria per ricostruzione grafo
    A_rec = false(n_nodi, n_nodi); % Matrice di adiacenza da ricostruire
    % false risparmia memoria (87.5%) ed è sufficiente perché matrice di adiacenza ha solo 0 e 1 come valori
    
    % Imposta la diagonale di L = 0 per non confondere il kmeans
    % vogliamo cioè distinguere nodi vicini e lontani, e non "nodi stessi" e "altri nodi"
    L(1:n_nodi+1:end) = 0;
    
    % Rendiamo simmetrica L per evitare grafo orientato
    L = (L + L') / 2;

    L(L < 0) = 0; % Se una derivata è negativa => derivata=0
    
    % Per ogni vertice 
    for i = 1:n_nodi
        % Salta se le derivate sono troppo piccole (significa solo rumore)
        if max(L(:,i)) > options.soglia_rumore
            % Etichetto nodi vicini da lontani
            [idx, C] = kmeans(L(:,i), 2);
        
            % Il cluster con il valore medio più alto è quello dei vicini
            [~, cluster_vicini] = max(C); % la ~ scarta il valore max perchè ci interessa solo l'indice
        
            % Se il nodo è vicino imposta 1 nella matrice adiacenze
            A_rec(i, :) = (idx == cluster_vicini);
        end
    end
    
    % Rendiamo simmetrico il grafo (elimina falsi positivi)
    A_rec = A_rec & A_rec'; 
    A_rec(1:n_nodi+1:end) = 0;
end
