
function [A_rec] = solutore_2(U, t, options)
    
    %% 1. Parametri del Problema
    arguments
        U (:,:) cell
        t (:,1) double
        options.soglia_rumore (1,1) double = 1e-8    % Ordine di grandezza del rumore
    end

    [n_nodi, ~] = size(U{1});
    n_t = length(t);
    
    %% 2.1 Calcolo traiettorie (Quello di prima)
    % per migliorare il caso di pochi esperimenti aumentiamli artificialmente
    % utilizzando ogni istante temporale come un nuovo esperimento
    
    U_big_0 = cat(2,U{ 1:n_t-1 });
    U_big_1 = cat(2,U{ 2:n_t});

    c = pinv(U_big_0, 1e-8);
    
    % Calcoliamo le derivate U{1}*c(:,i) - U{2}*c(:,i) / dt
    dt = t(2)-t(1);
    A_pesata = (U_big_1 * c - U_big_0 * c) / dt;
    
    %% 3. Costruzione grafo
    
    % Preallochiamo la memoria per ricostruzione grafo
    A_rec = false(n_nodi, n_nodi); % Matrice di adiacenza da ricostruire
    % false risparmia memoria (87.5%) ed è sufficiente perché matrice di adiacenza ha
    % solo 0 e 1 come valori
    
    % imposta la diag(derivate) = 0 perché un useriemo il kmeans per capire 
    % nodi vicini e lontani ma vogliamo escludere che nodo non può collegarsi a se stesso 
    A_pderivateesata(1:n_nodi+1:end) = 0;
    
    A_pesata(A_pesata < 0) = 0; % Se una derivata è negativa => derivata=0
    
    % rendiamo simmetrica le derivate per evitare grafo orientato
    A_pesata = (A_pesata + A_pesata') / 2;
    
    % per ogni vertice 
    for i = 1:n_nodi
    
        % Salta se le derivate sono troppo piccole(significa solo rumore)
        if max(A_pesata(:,i)) > options.soglia_rumore
            % etichetto nodi vicini da lontani
            [idx, C] = kmeans(A_pesata(:,i), 2);
        
            % il cluster con il valore medio più alto è quello dei vicini
            [~, cluster_vicini] = max(C); % la ~ scarta il valore max perchè ci interessa solo l'indice
        
            % se il nodo è vicino imposta 1 nella matrice adiacenze
            A_rec(i, :) = (idx == cluster_vicini);
        end
    
    end
    
    % rendiamo simmetrico il grafo (elimina falsi positivi)
    A_rec = A_rec & A_rec'; 
    A_rec(1:n_nodi+1:end) = 0;
    
end