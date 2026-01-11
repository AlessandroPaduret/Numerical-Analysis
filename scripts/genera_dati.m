%% 1. Parametri del Problema
k = 100; % ordine di grandezza

n_nodi = k;                     % Numero di nodi (vertici)
n_esperimenti = ceil(k/2);      % Numero di esperimenti (M >= m per il Problema 1)
t_finale = 0.1;                 % Tempo finale di osservazione (piccolo per l'euristica)
n_t = 50;                       % Numero di istanti temporali
t = linspace(0, t_finale, n_t); % Vettore dei tempi

%% 2. Generazione del Grafo e del Laplaciano
prob_edge = 0.3; 
A = double(rand(n_nodi,n_nodi) < prob_edge);  % imposta 1 se superata probabilità 0 altrimenti
A = triu(A,1); % triangolare superiore scartando la diagonale
A = A | A'; % Rendiamo la matrice simmetrica (grafo non orientato)


% Calcolo della matrice Laplaciana L = D - A
L = laplacian(graph(A));

% Diagonalizzazione del Laplaciano: L = Q * Lambda * Q'
[Q, Lambda] = eig(full(L)); 

%% 3. Generazione dei Dati Iniziali (U{1})
% U{1} è una matrice m x M dove ogni colonna è un esperimento al tempo 1
U = cell(1, n_t);
U{1} = randn(n_nodi, n_esperimenti); 

%% 4. Simulazione della Diffusione (Riempimento della cella U)
% Usiamo la formula: u(t) = Q * exp(-Lambda * t) * Q' * u(0)
% Calcoliamo l'evoluzione per ogni istante temporale k

for k = 2:n_t
    
    % Calcoliamo la matrice esponenziale e^(-Lambda * t)
    exp_Lambda_t = diag(exp(-diag(Lambda) * t(k)));
    
    % Calcoliamo lo snapshot al tempo k per tutti gli M esperimenti
    U{k} = Q * exp_Lambda_t * Q' * U{1};
    
    % (Opzionale) Aggiunta di rumore bianco per testare la robustezza
    rumore = 1e-4 * randn(n_nodi, n_esperimenti); 
    U{k} = U{k} + rumore;
end

%% 5. Salvataggio dei Dati
% Questi sono i file che useranno Solutore1 e Solutore2
save('dati_sintetici.mat', 'A', 't', 'U', 'n_nodi', 'n_esperimenti', 'n_t', '-v7.3');
fprintf('Dati sintetici generati e salvati correttamente.\n');