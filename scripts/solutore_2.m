
function [A_rec] = solutore_2(U, t, options)
    %% Parametri del problema
    arguments
        U (:,:) cell
        t (:,1) double
        options.soglia_rumore (1,1) double = 1e-8 % Ordine di grandezza del rumore
    end

    [n_nodi, ~] = size(U{1});
    n_t = length(t);
    
    %% Calcolo traiettorie (simile a prima)
    % Per migliorare il caso di pochi esperimenti aumentiamoli artificialmente
    % utilizzando ogni istante temporale come un nuovo esperimento
    U_big_0 = cat(2,U{1:n_t-1}); % Concatenazione
    U_big_1 = cat(2,U{2:n_t});

    % Risolve Uc = I tramite SVD
    c = pinv(U_big_0, 1e-8);
    
    % Calcoliamo le derivate U{1}*c(:,i) - U{2}*c(:,i) / dt
    dt = t(2)-t(1);
    L = (U_big_1 * c - eye(n_nodi)) / dt;
    
    %% Costruzione grafo
    % Preallochiamo la memoria per ricostruzione grafo
    A_rec = false(n_nodi, n_nodi); % Matrice di adiacenza da ricostruire
    % false risparmia memoria (87.5%) ed è sufficiente perché matrice di adiacenza ha solo 0 e 1 come valori
    
    % Imposta la diagonale di L = 0 per non confondere il kmeans
    % vogliamo cioè distinguere nodi vicini e lontani, e non "nodi stessi" e "altri nodi"
    L(1:n_nodi+1:end) = 0;
    
    L(L < 0) = 0; % Se una derivata è negativa => derivata=0
    
    % Rendiamo simmetrica L per evitare grafo orientato
    L = (L + L') / 2;
    
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
    
    % Rendiamo simmetrico il grafo
    A_rec = A_rec & A_rec'; % Eliminiamo falsi positivi tramite AND (1&0 = 0, 1&1 = 1)
    A_rec(1:n_nodi+1:end) = 0; % Azzeriamo la diagonale
end
