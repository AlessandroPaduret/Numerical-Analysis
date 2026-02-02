function [A_rec] = solutore_vettorizzato(U, t, options)
    arguments
        U (:,:) cell
        t (:,1) double
        options.soglia_rumore (1,1) double = 1e-8
        options.k (1,1) double = 5    
        options.step (1,1) double = 1 
    end
    
    %% 1. Parametri e Dimensioni
    k = round(options.k);
    step = round(options.step);
    [n_nodi, n_esp] = size(U{1});
    n_t = length(U);
    
    % Calcolo indici di inizio di ogni finestra
    starts = 1 : step : (n_t - k + 1);
    n_fin = length(starts);
    
    %% 2. Creazione del Super-Tensore [n_nodi x n_esp x k x n_finestre]
    % Concateniamo tutta la cell in un unico blocco 3D [N x E x T]
    U_full = cat(3, U{:}); 
    
    % Generiamo una matrice di indici per tutte le finestre [k x n_finestre]
    % Ogni colonna è un set di indici temporali (es: [1,2,3,4,5]', [2,3,4,5,6]', ...)
    idx_map = (1:k)' + starts - 1; 
    
    % Estraiamo i dati: il tensore diventa [n_nodi x n_esp x k x n_finestre]
    U_sub = U_full(:, :, idx_map(:));
    U_sub = reshape(U_sub, n_nodi, n_esp, k, n_fin);

    

    %% 3. Regressione Lineare Vettoriale (Il "Backslash" Magico)
    % Trasformiamo U_sub in [k x (n_nodi * n_esp * n_fin)]
    % Vogliamo il tempo (k) sulle righe per usare T_mat \ U
    U_to_reg = reshape(permute(U_sub, [3, 1, 2, 4]), k, []);
    
    % Matrice del tempo locale (assumendo dt costante per semplicità di vettorizzazione)
    % Se t non è lineare, la regressione vettoriale richiede matrici a blocchi,
    % ma qui usiamo il tempo relativo per ogni finestra:
    dt = t(2) - t(1);
    t_rel = (0:k-1)' * dt;
    T_mat = [t_rel, ones(k, 1)];
    
    % Calcolo parallelo di tutte le pendenze e intercette
    B = T_mat \ U_to_reg; % [2 x (N * E * Fin)]
    
    % Estrazione m e U_media
    m_all_flat = B(1, :); % Pendenze
    m_accumulata = reshape(m_all_flat, n_nodi, n_esp * n_fin);
    
    % U_media: media lungo la dimensione k (la 3°) del tensore originale
    U_accumulata = reshape(mean(U_sub, 3), n_nodi, n_esp * n_fin);

    %% 4. Proiezione e Ricostruzione
    c = pinv(U_accumulata, 1e-5); 
    derivate = m_accumulata * c;
    
    % Pulizia
    derivate(1:n_nodi+1:end) = 0;
    derivate = max(0, (derivate + derivate') / 2);
    
    %% 5. K-means (L'unica parte necessariamente iterativa sui nodi)
    % Trasformiamo la matrice in un vettore colonna di tutti i possibili archi
    v_global = derivate(:); 
    
    % K-means su tutti gli archi contemporaneamente
    [idx_global, C] = kmeans(v_global, 2, 'Replicates', 5);
    
    % Ricostruiamo la matrice A_rec dai risultati del clustering
    [~, cluster_vicini] = max(C);
    A_rec = reshape(idx_global == cluster_vicini, n_nodi, n_nodi);
    
    A_rec = A_rec & A_rec';
    A_rec(1:n_nodi+1:end) = 0;
end