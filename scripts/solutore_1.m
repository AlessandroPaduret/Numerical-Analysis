
function [A_rec] = solutore_1(U, t, options)
    
    %% 1. Parametri del Problema
    arguments
        U (1,:) cell
        t (:,1) double
        options.soglia_rumore (1,1) double = 1e-8    % Ordine di grandezza del rumore
    end

    n_nodi = size(U{1},1);

    %% 2. Calcolo traiettorie
    % calcolo le c_i di ogni vertice così da simulare lui come unico nodo caldo
    % delle rete
    c = U{1} \ eye(n_nodi);
    
    % Calcoliamo le derivate U{1}*c(:,i) - U{2}*c(:,i) / dt
    dt = t(2)-t(1);
    derivate = -(U{1} * c - U{2} * c) / dt;
    
    %% 3. Costruzione grafo
    
    % Preallochiamo la memoria per ricostruzione grafo
    A_rec = zeros(n_nodi, n_nodi); % Matrice di adiacenza da ricostruire
    
    % imposta la diag(derivate) = 0 perché un useriemo il kmeans per capire 
    % nodi vicini e lontani ma vogliamo escludere che nodo non può collegarsi a se stesso 
    derivate(1:n_nodi+1:end) = 0;
    
    % rendiamo simmetrica le derivate per evitare grafo orientato
    derivate = (derivate + derivate') / 2;
    
    % per ogni vertice 
    for i = 1:n_nodi

        % Salta se le derivate sono troppo piccole(significa solo rumore)
        if max(derivate(:,i)) < options.soglia_rumore
            continue;
        end

        % etichetto nodi vicini da lontani
        [idx, C] = kmeans(derivate(:,i), 2);
    
        % il cluster con il valore medio più alto è quello dei vicini
        [~, cluster_vicini] = max(C); % la ~ scarta il valore max perchè ci interessa solo l'indice
    
        % se il nodo è vicino imposta 1 nella matrice adiacenze
        A_rec(i, :) = (idx == cluster_vicini);
    end
    
    % rendiamo simmetrico il grafo (elimina falsi positivi)
    A_rec = A_rec & A_rec'; 
    A_rec(1:n_nodi+1:end) = 0;
    
    % Salviamo la soluzione
    save('A_rec.mat', 'A_rec'); % Salva la matrice di adiacenza ricostruita

end
