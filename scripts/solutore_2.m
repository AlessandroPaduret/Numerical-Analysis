%% 1. Caricamento dati
load('dati_sintetici.mat'); % Carica A, t, n_t, U, n_nodi, n_esperimenti

%% 2. Calcolo traiettorie
% per migliorare il caso di pochi esperimenti aumentiamli artificialmente
% utilizzando ogni istante temporale come un nuovo esperimento

U_big_0 = zeros(n_nodi, n_esperimenti*(n_t-1));
U_big_1 = zeros(n_nodi, n_esperimenti*(n_t-1));

% Usiamo n-1 istanti per la base e n per il calcolo della derivata
for k = 1:(length(U)-1)
    U_big_0(:, n_esperimenti*(k-1)+1 : n_esperimenti*k) = U{k};   % Stato "presente"
    U_big_1(:, n_esperimenti*(k-1)+1 : n_esperimenti*k) = U{k+1};  % Stato "futuro"
end

% calcolo le c_i di ogni vertice così da simulare lui come unico nodo caldo
% delle rete
c = pinv(U_big_0, 1e-5); % pinv(matrice, tolleranza) per stabilità

% una alternativa equivalente a pinv 
% [U_svd, Sigma, V] = svd(U_big_0, 'econ'); % Decomposizione
% c = V * diag(1./diag(Sigma)) * U_svd';


% Calcoliamo le derivate U{1}*c(:,i) - U{2}*c(:,i) / dt
dt = t(2)-t(1);
derivate = (U_big_1 * c - U_big_0 * c) / dt;

%% 3. Costruzione grafo

% Preallochiamo la memoria per ricostruzione grafo
A_rec = false(n_nodi, n_nodi); % Matrice di adiacenza da ricostruire
% false risparmia memoria (87.5%) ed è sufficiente perché matrice di adiacenza ha
% solo 0 e 1 come valori

% imposta la diag(derivate) = 0 perché un useriemo il kmeans per capire 
% nodi vicini e lontani ma vogliamo escludere che nodo non può collegarsi a se stesso 
derivate(1:n_nodi+1:end) = 0;

derivate(derivate < 0) = 0; % Se una derivata è negativa => derivata=0

% rendiamo simmetrica le derivate per evitare grafo orientato
derivate = (derivate + derivate') / 2;

% per ogni vertice 
for i = 1:n_nodi

    % Salta se le derivate sono troppo piccole(significa solo rumore)
    if max(derivate(:,i)) < 1e-8
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
