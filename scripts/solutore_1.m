function [A_rec] = solutore_1(U, t, options)
    
    %% 1. Parametri del Problema
    arguments
        U (1,:) cell
        t (:,1) double
        options.soglia_rumore (1,1) double = 1e-8    % Ordine di grandezza del rumore
    end

    n_nodi = size(U{1},1);

    %% 2. Calcolo traiettorie
    % risolva Uc = I
    c = pinv(U{1});
    
    % Calcoliamo le derivate (U{2}*c - U{1}*c) / dt
    % nota: U{1}*c = I per come è definita c
    dt = t(2) - t(1);
    L = (U{2} * c - eye(n_nodi)) / dt;

    %% 3. Costruzione grafo
    
    % Preallochiamo la memoria per ricostruzione grafo
    A_rec = zeros(n_nodi, n_nodi); % Matrice di adiacenza da ricostruire
    
    % imposta la diag(derivate) = 0 perché un useriemo il kmeans per capire 
    L(1:n_nodi+1:end) = 0;
    
    % rendiamo simmetrica le derivate per evitare grafo orientato
    L = (L + L') / 2;
    
    % per ogni vertice 
    for i = 1:n_nodi

        % Salta se le derivate sono troppo piccole(significa solo rumore)
        if max(L(:,i)) < options.soglia_rumore
            continue;
        end

        % etichetto nodi vicini da lontani
        [idx, C] = kmeans(L(:,i), 2);
    
        % il cluster con il valore medio più alto è quello dei vicini
        [~, cluster_vicini] = max(C); % la ~ scarta il valore max perchè ci interessa solo l'indice
    
        % se il nodo è vicino imposta 1 nella matrice adiacenze
        A_rec(i, :) = (idx == cluster_vicini);
    end
    
    % rendiamo simmetrico il grafo (elimina falsi positivi)
    A_rec = A_rec & A_rec'; 
    A_rec(1:n_nodi+1:end) = 0;
    
end
