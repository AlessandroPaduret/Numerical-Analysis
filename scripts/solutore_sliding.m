function [A_rec] = solutore_sliding(U, t, options)
    
    arguments
        U (:,:) cell
        t (:,1) double
        options.soglia_rumore (1,1) double = 1e-8
        options.window (1,1) double = 2    % Ampiezza finestra
        options.step (1,1) double = 1 % Salto tra una finestra e l'altra
    end
    
    window = round(options.window);
    step = round(options.step);
    [n_nodi, n_esperimenti] = size(U{1});
    n_t = length(U);
    
    % Calcoliamo quante finestre (esperimenti virtuali) avremo
    istanti_inizio = 1 : step : (n_t - window + 1);
    n_finestre = length(istanti_inizio);
    n_tot_colonne = n_esperimenti * n_finestre;
    
    % --- PREALLOCAZIONE ---
    % Prepariamo i "contenitori" giganti con le dimensioni finali
    m_accumulata = zeros(n_nodi, n_tot_colonne);
    U_accumulata = zeros(n_nodi, n_tot_colonne);
    
    % 1. SLIDING WINDOW: facciamo scorrere la finestra su tutto il tempo n_t
    % Ci fermiamo a n_t - k per non uscire dai bordi
    for start_t = 1 : n_finestre
        
        idx_window = start_t : (start_t + window - 1);
        t_window = t(idx_window);
        
        % Regressione locale per questa specifica finestra
        T_mat = [t_window, ones(window, 1)];
        U_tensor_k = cat(3, U{idx_window});
        U_history = reshape(permute(U_tensor_k, [3, 1, 2]), window, n_nodi*n_esperimenti);
        
        B = pinv(T_mat, options.soglia_rumore) * U_history;
        
        % Pendenza locale m: [n_nodi x n_esperimenti]
        m_local = reshape(B(1, :), n_nodi, n_esperimenti);
        
        % Stato di riferimento locale (media della finestra o primo istante)
        U_local = mean(U_tensor_k, 3); 
        
        % Definiamo dove inserire i dati nelle matrici preallocate
        col_start = (start_t-1) * n_esperimenti + 1;
        col_end   = start_t * n_esperimenti;
        
        % Salvataggio pendenze e stati medi
        m_accumulata(:, col_start:col_end) = m_local;
        U_accumulata(:, col_start:col_end) = U_local;
    end

    

    %% 2. Proiezione Globale (La tua logica Moore-Penrose)
    % Adesso abbiamo una matrice U_accumulata che contiene la "storia" 
    % di come ogni nodo è stato visto acceso/spento in ogni finestra.
    c = pinv(U_accumulata, options.soglia_rumore); 
    
    % derivate: [n_nodi x n_nodi]
    A_pesata = m_accumulata * c;
    
    %% 3. Post-Processing (K-means)
    A_pesata(1:n_nodi+1:end) = 0;
    A_pesata = max(0, (A_pesata + A_pesata') / 2);
    
    %% 5. K-means (L'unica parte necessariamente iterativa sui nodi)
    % Trasformiamo la matrice in un vettore colonna di tutti i possibili archi
    v_global = A_pesata(:); 
    
    % K-means su tutti gli archi contemporaneamente
    [idx_global, C] = kmeans(v_global, 2, 'Replicates', 5);
    
    % Ricostruiamo la matrice A_rec dai risultati del clustering
    [~, cluster_vicini] = max(C);
    A_rec = reshape(idx_global == cluster_vicini, n_nodi, n_nodi);
    
    A_rec = A_rec & A_rec';
    A_rec(1:n_nodi+1:end) = 0;
end