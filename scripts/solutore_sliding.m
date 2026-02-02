function [A_rec] = solutore_sliding(U, t, options)
    
    arguments
        U (:,:) cell
        t (:,1) double
        options.soglia_rumore (1,1) double = 1e-8
        options.window (1,1) double = 5    % Ampiezza finestra
        options.step (1,1) double = 1 % Salto tra una finestra e l'altra
    end
    
    window = round(options.window);
    step = round(options.step);
    [n_nodi, n_esperimenti] = size(U{1});
    n_t = length(U);
    
    % Calcoliamo quante finestre (esperimenti virtuali) avremo
    istanti_inizio = 1 : step : (n_t - k + 1);
    n_finestre = length(istanti_inizio);
    n_tot_colonne = n_esperimenti * n_finestre;
    
    % --- PREALLOCAZIONE ---
    % Prepariamo i "contenitori" giganti con le dimensioni finali
    m_accumulata = zeros(n_nodi, n_tot_colonne);
    U_accumulata = zeros(n_nodi, n_tot_colonne);));
    
    % 1. SLIDING WINDOW: facciamo scorrere la finestra su tutto il tempo n_t
    % Ci fermiamo a n_t - k per non uscire dai bordi
    for start_t = 1 : n_finestre
        
        idx_window = start_t : (start_t + window - 1);
        t_window = t(idx_window);
        
        % Regressione locale per questa specifica finestra
        T_mat = [t_window, ones(window, 1)];
        U_tensor_k = cat(3, U{idx_window});
        U_history = reshape(permute(U_tensor_k, [3, 1, 2]), window, []);
        
        B = T_mat \ U_history;
        
        % Pendenza locale m: [n_nodi x n_esperimenti]
        m_local = reshape(B(1, :), n_nodi, n_esperimenti);
        
        % Stato di riferimento locale (media della finestra o primo istante)
        U_local = mean(U_tensor_k, 3); 
        
        % Accumulo: concateniamo orizzontalmente
        m_accumulata = [m_accumulata, m_local];
        U_accumulata = [U_accumulata, U_local];
    end

    

    %% 2. Proiezione Globale (La tua logica Moore-Penrose)
    % Adesso abbiamo una matrice U_accumulata che contiene la "storia" 
    % di come ogni nodo è stato visto acceso/spento in ogni finestra.
    c = pinv(U_accumulata, 1e-5); 
    
    % derivate: [n_nodi x n_nodi]
    derivate = m_accumulata * c;
    
    %% 3. Post-Processing (K-means)
    derivate(1:n_nodi+1:end) = 0;
    derivate = max(0, (derivate + derivate') / 2);
    
    A_rec = false(n_nodi, n_nodi);
    for i = 1:n_nodi
        v = derivate(:, i);
        if max(v) > options.soglia_rumore
            [idx, C] = kmeans(v, 2, 'Replicates', 5);
            [~, cluster_vicini] = max(C);
            A_rec(i, :) = (idx == cluster_vicini);
        end
    end
    
    A_rec = A_rec & A_rec';
    A_rec(1:n_nodi+1:end) = 0;
end